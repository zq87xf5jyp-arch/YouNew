import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  geoAnalyticsServerContract,
  normalizeAnalyticsEvents,
  readBoundedJsonBody,
} from "../supabase/functions/analytics-ingest/geo-event-normalization.ts";

const baseEvent = {
  client_event_id: "10000000-0000-4000-8000-000000000101",
  app_instance_id: "10000000-0000-4000-8000-000000000201",
  session_id: "10000000-0000-4000-8000-000000000202",
  event_name: "explicit_city_detected",
  properties: { city: "leiden", intent_id: "healthcare" },
};

test("geo event privileged envelope fields are server-derived", () => {
  const [event] = normalizeAnalyticsEvents([
    {
      ...baseEvent,
      screen: "/private/profile/",
      platform: "iOS",
      app_version: "client-controlled",
      language: "ru",
      city: "Jane Doe",
      occurred_at: "2020-01-01T00:00:00.000Z",
      consent_version: "forged",
      schema_version: 99,
      environment: "test",
      email: "private@example.invalid",
    },
  ], {
    origin: "https://younew.nl",
    occurredAt: "2026-08-19T10:00:00.000Z",
  }) as Array<Record<string, unknown>>;

  assert.deepEqual(event, {
    ...baseEvent,
    screen: "/search/",
    platform: "Web",
    app_version: geoAnalyticsServerContract.rankingVersion,
    occurred_at: "2026-08-19T10:00:00.000Z",
    consent_version: geoAnalyticsServerContract.consentVersion,
    schema_version: geoAnalyticsServerContract.schemaVersion,
    environment: "production",
  });
  const forwarded = event as Record<string, unknown>;
  assert.equal(forwarded.city, undefined);
  assert.equal(forwarded.language, undefined);
  assert.equal(forwarded.email, undefined);
});

test("local geo validation is marked staging and Action Panel gets a bounded screen", () => {
  const [event] = normalizeAnalyticsEvents([
    { ...baseEvent, event_name: "action_panel_cta_clicked" },
  ], {
    origin: "http://127.0.0.1:3000",
    occurredAt: "2026-08-19T10:00:00.000Z",
  }) as Array<Record<string, unknown>>;

  assert.equal(event.environment, "staging");
  assert.equal(event.screen, "/essentials/");
});

test("legacy analytics events remain byte-for-byte compatible", () => {
  const legacy = { ...baseEvent, event_name: "official_source_click", platform: "iOS" };
  const [normalized] = normalizeAnalyticsEvents([legacy], {
    origin: null,
    occurredAt: "2026-08-19T10:00:00.000Z",
  });
  assert.equal(normalized, legacy);
});

test("the actual request stream is byte-bounded without trusting Content-Length", async () => {
  const valid = await readBoundedJsonBody(
    new Request("https://example.invalid/analytics", {
      method: "POST",
      body: JSON.stringify({ events: [] }),
    }),
    64,
  );
  assert.deepEqual(valid, { ok: true, value: { events: [] } });

  const request = new Request("https://example.invalid/analytics", {
    method: "POST",
    body: JSON.stringify({ events: ["x".repeat(128)] }),
  });
  assert.equal(request.headers.get("content-length"), null);
  assert.deepEqual(
    await readBoundedJsonBody(request, 64),
    { ok: false, reason: "payload_too_large" },
  );
});

test("Edge ingestion normalizes before the service-role RPC", async () => {
  const source = await readFile(
    new URL("../supabase/functions/analytics-ingest/index.ts", import.meta.url),
    "utf8",
  );
  assert.match(source, /normalizeAnalyticsEvents\([\s\S]{0,220}const result = await ingest\(events\)/);
  assert.match(source, /request\.method === "POST" && !origin[\s\S]{0,100}origin_required/);
  assert.match(source, /readBoundedJsonBody\(request, maximumPayloadBytes\)/);
  assert.match(source, /SUPABASE_SERVICE_ROLE_KEY/);
  assert.doesNotMatch(source, /await ingest\(\(payload as \{ events: unknown\[\] \}\)\.events\)/);
});
