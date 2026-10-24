const geoEventNames = new Set([
  "explicit_city_detected",
  "city_filter_applied",
  "city_filter_corrected",
  "local_result_available",
  "national_fallback_shown",
  "wrong_geo_result_reported",
  "action_panel_cta_clicked",
  "time_to_first_action",
]);

export const geoAnalyticsServerContract = {
  consentVersion: "2026-07-28",
  schemaVersion: 1,
  rankingVersion: "geo-ranking-v1",
} as const;

type NormalizationOptions = {
  origin: string | null;
  occurredAt: string;
};

type BoundedJsonResult =
  | { ok: true; value: unknown }
  | { ok: false; reason: "invalid_json" | "payload_too_large" };

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Read the actual request stream with a byte limit. Content-Length is only an
 * early rejection hint: it can be absent on chunked requests and must not be
 * trusted as the authoritative abuse boundary.
 */
export async function readBoundedJsonBody(
  request: Request,
  maximumBytes: number,
): Promise<BoundedJsonResult> {
  if (!Number.isSafeInteger(maximumBytes) || maximumBytes < 1 || !request.body) {
    return { ok: false, reason: "invalid_json" };
  }

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let receivedBytes = 0;

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      receivedBytes += value.byteLength;
      if (receivedBytes > maximumBytes) {
        await reader.cancel().catch(() => undefined);
        return { ok: false, reason: "payload_too_large" };
      }
      chunks.push(value);
    }
  } catch {
    return { ok: false, reason: "invalid_json" };
  } finally {
    reader.releaseLock();
  }

  const bytes = new Uint8Array(receivedBytes);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }

  try {
    return { ok: true, value: JSON.parse(new TextDecoder().decode(bytes)) };
  } catch {
    return { ok: false, reason: "invalid_json" };
  }
}

function environmentForOrigin(origin: string | null) {
  return origin?.startsWith("http://localhost:")
      || origin?.startsWith("http://127.0.0.1:")
    ? "staging"
    : "production";
}

function screenForEvent(name: string) {
  return name === "action_panel_cta_clicked" ? "/essentials/" : "/search/";
}

/**
 * Geo events are web-only and carry server-derived envelope fields. The
 * anonymous identifiers and bounded properties remain client supplied so the
 * hardened database RPC can perform its existing UUID and event-specific
 * validation. Unknown/legacy events pass through to that RPC unchanged.
 */
export function normalizeAnalyticsEvents(
  events: unknown[],
  { origin, occurredAt }: NormalizationOptions,
) {
  return events.map((event) => {
    if (!isRecord(event) || typeof event.event_name !== "string"
      || !geoEventNames.has(event.event_name)) {
      return event;
    }

    return {
      client_event_id: event.client_event_id,
      app_instance_id: event.app_instance_id,
      session_id: event.session_id,
      event_name: event.event_name,
      screen: screenForEvent(event.event_name),
      platform: "Web",
      app_version: geoAnalyticsServerContract.rankingVersion,
      properties: event.properties,
      occurred_at: occurredAt,
      consent_version: geoAnalyticsServerContract.consentVersion,
      schema_version: geoAnalyticsServerContract.schemaVersion,
      environment: environmentForOrigin(origin),
    };
  });
}
