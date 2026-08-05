import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const allowedOrigins = new Set([
  "https://younew.nl",
  "https://www.younew.nl",
  "https://younew-netherlands-guide.tasty-finch-0991.chatgpt.site",
  "http://localhost:3000",
  "http://127.0.0.1:3000",
  "http://localhost:3001",
  "http://127.0.0.1:3001",
  "http://localhost:4173",
  "http://127.0.0.1:4173",
  "http://localhost:4174",
  "http://127.0.0.1:4174",
]);

const maximumPayloadBytes = 65_536;

type JsonResponseOptions = {
  status?: number;
  origin?: string | null;
  headers?: Record<string, string>;
};

function jsonResponse(
  payload: Record<string, unknown>,
  { status = 200, origin = null, headers = {} }: JsonResponseOptions = {},
) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
      ...(origin
        ? {
          "Access-Control-Allow-Origin": origin,
          Vary: "Origin",
        }
        : {}),
      ...headers,
    },
  });
}

function requestOrigin(request: Request) {
  const origin = request.headers.get("origin");
  if (!origin) return null;
  return allowedOrigins.has(origin) ? origin : undefined;
}

function configuredPublishableKeys() {
  const keys = new Set<string>();
  const legacyAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (legacyAnonKey) keys.add(legacyAnonKey);

  try {
    const publishableKeys = JSON.parse(
      Deno.env.get("SUPABASE_PUBLISHABLE_KEYS") ?? "{}",
    ) as Record<string, unknown>;
    for (const value of Object.values(publishableKeys)) {
      if (typeof value === "string" && value.startsWith("sb_publishable_")) {
        keys.add(value);
      }
    }
  } catch {
    // A missing or malformed optional key map must fail closed.
  }

  return [...keys];
}

async function digest(value: string) {
  return new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
  );
}

async function constantTimeEqual(left: string, right: string) {
  const [leftDigest, rightDigest] = await Promise.all([
    digest(left),
    digest(right),
  ]);
  if (leftDigest.byteLength !== rightDigest.byteLength) return false;

  let difference = 0;
  for (let index = 0; index < leftDigest.byteLength; index += 1) {
    difference |= leftDigest[index] ^ rightDigest[index];
  }
  return difference === 0;
}

async function hasValidPublishableKey(request: Request) {
  const provided = request.headers.get("apikey") ?? "";
  if (!provided) return false;

  for (const expected of configuredPublishableKeys()) {
    if (await constantTimeEqual(provided, expected)) return true;
  }
  return false;
}

async function ingest(events: unknown) {
  const projectURL = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!projectURL || !serviceRoleKey) {
    return { ok: false as const, status: 503, error: "storage_unavailable" };
  }

  const response = await fetch(
    `${projectURL}/rest/v1/rpc/ingest_analytics_batch_v2`,
    {
      method: "POST",
      headers: {
        apikey: serviceRoleKey,
        Authorization: `Bearer ${serviceRoleKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ p_events: events }),
    },
  );

  if (!response.ok) {
    return {
      ok: false as const,
      status: response.status >= 500 ? 503 : 400,
      error: response.status >= 500
        ? "storage_unavailable"
        : "invalid_event_batch",
    };
  }

  const accepted = Number(await response.json());
  if (accepted === -1) {
    return { ok: false as const, status: 429, error: "rate_limited" };
  }
  if (!Number.isInteger(accepted) || accepted < 0) {
    return { ok: false as const, status: 503, error: "invalid_storage_reply" };
  }

  return { ok: true as const, accepted };
}

Deno.serve(async (request: Request) => {
  const origin = requestOrigin(request);
  if (origin === undefined) {
    return jsonResponse({ error: "origin_not_allowed" }, { status: 403 });
  }

  if (request.method === "OPTIONS") {
    if (!origin) {
      return jsonResponse({ error: "origin_required" }, { status: 403 });
    }
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": origin,
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "apikey, content-type",
        "Access-Control-Max-Age": "86400",
        Vary: "Origin",
      },
    });
  }

  if (!await hasValidPublishableKey(request)) {
    return jsonResponse(
      { error: "invalid_application_key" },
      { status: 401, origin },
    );
  }

  if (request.method === "GET") {
    return jsonResponse(
      {
        status: "ok",
        schema_version: 1,
        consent_version: "2026-07-28",
        maximum_batch_size: 50,
        search_privacy_contract: "canonical_intent_and_buckets_only",
      },
      { origin },
    );
  }

  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method_not_allowed" },
      { status: 405, origin, headers: { Allow: "GET, POST, OPTIONS" } },
    );
  }

  const contentLength = Number(request.headers.get("content-length") ?? "0");
  if (
    !Number.isFinite(contentLength) ||
    contentLength < 0 ||
    contentLength > maximumPayloadBytes
  ) {
    return jsonResponse(
      { error: "payload_too_large" },
      { status: 413, origin },
    );
  }

  const payload = await request.json().catch(() => null);
  if (
    !payload ||
    typeof payload !== "object" ||
    !Array.isArray((payload as { events?: unknown }).events)
  ) {
    return jsonResponse(
      { error: "invalid_event_batch" },
      { status: 400, origin },
    );
  }

  const result = await ingest((payload as { events: unknown[] }).events);
  if (!result.ok) {
    const retryHeaders: Record<string, string> = result.status === 429
      ? { "Retry-After": "60" }
      : {};
    return jsonResponse(
      { accepted: 0, stored: false, error: result.error },
      { status: result.status, origin, headers: retryHeaders },
    );
  }

  return jsonResponse(
    { accepted: result.accepted, stored: true },
    { status: 202, origin },
  );
});
