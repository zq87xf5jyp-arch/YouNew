import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationUrl = new URL(
  "../supabase/migrations/20260805115017_privacy_safe_search_analytics.sql",
  import.meta.url
);
const edgeFunctionUrl = new URL(
  "../supabase/functions/analytics-ingest/index.ts",
  import.meta.url
);

test("search analytics migration is privacy-safe, role-gated and task producing", async () => {
  const sql = await readFile(migrationUrl, "utf8");

  assert.match(sql, /create table if not exists public\.search_analytics_events/);
  assert.match(sql, /canonical intent, bounded buckets and filters only/);
  assert.match(sql, /create or replace function public\.ingest_analytics_batch_v2/);
  assert.match(sql, /security definer\s+set search_path = ''/);
  assert.match(sql, /v_properties - v_extended_keys/);
  assert.match(sql, /jsonb_object_keys\(v_properties\)/);
  assert.match(sql, /create trigger create_search_improvement_task_after_zero/);
  assert.match(sql, /v_count < 3/);
  assert.match(sql, /occurred_at >= now\(\) - interval '7 days'/);
  assert.match(sql, /with \(security_invoker = true\)/);
  assert.match(sql, /enable row level security/);
  assert.match(sql, /private\.current_admin_role\(\)[\s\S]*'owner', 'admin', 'qa'/);
  assert.match(sql, /revoke all on function public\.ingest_analytics_batch_v2\(jsonb\) from public, anon, authenticated/);
  assert.doesNotMatch(sql, /raw_query|normalized_query|query_text|search_text/);
});

test("analytics edge function writes through the v2 validated RPC", async () => {
  const source = await readFile(edgeFunctionUrl, "utf8");

  assert.match(source, /rpc\/ingest_analytics_batch_v2/);
  assert.match(source, /canonical_intent_and_buckets_only/);
  assert.doesNotMatch(source, /SUPABASE_SERVICE_ROLE_KEY[^\n]*console/);
});
