import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL("../supabase/migrations/20260818193310_extend_lead_analytics_funnel.sql", import.meta.url),
  "utf8"
);
const sqlTest = await readFile(new URL("../supabase/tests/lead_analytics_funnel_test.sql", import.meta.url), "utf8");
const admin = await readFile(new URL("../src/app/(admin)/analytics/page.tsx", import.meta.url), "utf8");

test("analytics ingest allowlists the three approved lead events with empty properties", () => {
  assert.match(migration, /'lead_start'/);
  assert.match(migration, /'lead_submit'/);
  assert.match(migration, /'pilot_request'/);
  assert.match(sqlTest, /lead events reject every submitted property/);
  assert.match(sqlTest, /pilot_request is accepted without properties/);
});

test("the lead aggregate is security-invoker and Admin-readable only", () => {
  assert.match(migration, /create or replace view public\.analytics_lead_funnel_periods\s+with \(security_invoker = true\)/);
  assert.match(migration, /revoke all on table public\.analytics_lead_funnel_periods from public, anon, authenticated;/);
  assert.match(migration, /grant select on table public\.analytics_lead_funnel_periods to authenticated;/);
  assert.match(sqlTest, /lead funnel aggregate exposes all three approved steps/);
});

test("Admin consumes the lead funnel without labelling receipts as unique leads", () => {
  assert.match(admin, /from\("analytics_lead_funnel_periods"\)/);
  assert.match(admin, /lead_start/);
  assert.match(admin, /lead_submit/);
  assert.match(admin, /pilot_request/);
  assert.match(admin, /receipt-return events, not unique leads/i);
});
