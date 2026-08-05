import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL("../supabase/migrations/20260805223000_expand_privacy_safe_analytics_dashboard.sql", import.meta.url),
  "utf8"
);
const syncScript = await readFile(
  new URL("../scripts/sync-app-store-analytics.mjs", import.meta.url),
  "utf8"
);
const analyticsPage = await readFile(
  new URL("../src/app/(admin)/analytics/page.tsx", import.meta.url),
  "utf8"
);

test("analytics expansion keeps private aggregates behind RLS", () => {
  for (const view of [
    "analytics_page_metrics_periods",
    "analytics_audience_metrics_periods",
    "analytics_session_quality_periods",
    "analytics_conversion_funnel_periods"
  ]) {
    assert.match(migration, new RegExp(`create or replace view public\\.${view}`));
    assert.match(migration, new RegExp(`revoke all on table public\\.${view} from public, anon`));
    assert.match(migration, new RegExp(`grant select on table public\\.${view} to authenticated`));
  }
  assert.match(migration, /app_store_metrics_daily enable row level security/);
  assert.match(migration, /approved admins read App Store metrics/);
  assert.match(migration, /analytics_source_sync_state enable row level security/);
  assert.match(migration, /private\.is_approved_admin\(\)/);
  assert.doesNotMatch(migration, /public\.is_approved_admin\(\)/);
  assert.doesNotMatch(migration, /grant select on table public\.app_store_metrics_daily to anon/);
});

test("App Store sync stores aggregates and keeps server credentials server-side", () => {
  assert.match(syncScript, /APP_STORE_CONNECT_PRIVATE_KEY/);
  assert.match(syncScript, /SUPABASE_SERVICE_ROLE_KEY/);
  assert.match(syncScript, /analytics_source_sync_state/);
  assert.match(syncScript, /first_time_downloads/);
  assert.match(syncScript, /redownloads/);
  assert.match(syncScript, /updates/);
  assert.doesNotMatch(syncScript, /console\.log\(configuration|process\.env\)/);
  assert.doesNotMatch(syncScript, /email|device_id|user_id/i);
});

test("a successful App Store sync remains connected when the selected period is empty", () => {
  assert.match(analyticsPage, /appStoreSyncState\?\.status === "success"[\s\S]*?"connected" as const/);
  assert.match(analyticsPage, /appStoreSyncState\?\.status === "empty"[\s\S]*?"empty" as const/);
});
