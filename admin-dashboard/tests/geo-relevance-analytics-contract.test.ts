import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL("../supabase/migrations/20260819080242_allow_geo_relevance_analytics.sql", import.meta.url),
  "utf8"
);
const client = await readFile(
  new URL("../public-site/src/lib/analytics/client.ts", import.meta.url),
  "utf8"
);

const geoEvents = [
  "explicit_city_detected",
  "city_filter_applied",
  "city_filter_corrected",
  "local_result_available",
  "national_fallback_shown",
  "wrong_geo_result_reported",
  "action_panel_cta_clicked",
  "time_to_first_action"
] as const;

test("geo analytics client and ingestion migration share one bounded allowlist", () => {
  for (const eventName of geoEvents) {
    assert.match(client, new RegExp(`name: "${eventName}"`), eventName);
    assert.match(migration, new RegExp(`''${eventName}''`), eventName);
  }
  for (const property of ["city", "intent_id", "source", "content_id", "duration_ms"]) {
    assert.match(migration, new RegExp(`['"]${property}['"]`), property);
  }
});

test("geo analytics migration preserves existing privacy and authorization boundaries", () => {
  assert.match(migration, /pg_get_functiondef\('public\.ingest_analytics_batch\(jsonb\)'::regprocedure\)/);
  assert.match(migration, /refusing an unsafe geo analytics patch/);
  assert.match(migration, /service_role/);
  assert.doesNotMatch(migration, /grant execute[^;]+(?:anon|authenticated)/i);
  assert.doesNotMatch(migration, /email|phone|full_query|raw_query|ip_address/i);
});

test("geo event schemas reject free-form keys and bound action timing", () => {
  assert.match(migration, /count\(\*\) from jsonb_object_keys\(v_properties\)\) <> 2/);
  assert.match(migration, /v_properties ->> 'source' not in \('query', 'filter'\)/);
  assert.match(migration, /v_properties ->> 'duration_ms'\)::numeric > 3600000/);
  assert.match(migration, /jsonb_typeof\(v_properties -> 'duration_ms'\) <> 'number'/);
});
