import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationUrl = new URL(
  "../supabase/migrations/20260730130000_content_governance_platform.sql",
  import.meta.url
);
const pgTapUrl = new URL(
  "../supabase/tests/content_governance_test.sql",
  import.meta.url
);
const hardeningMigrationUrl = new URL(
  "../supabase/migrations/20260801003000_harden_content_governance_performance.sql",
  import.meta.url
);

test("governance migration is additive, fail-closed and audit preserving", async () => {
  const sql = await readFile(migrationUrl, "utf8");
  for (const required of [
    "create table if not exists public.content_governance_state",
    "create table if not exists public.content_governance_versions",
    "create table if not exists public.source_check_attempts",
    "create table if not exists public.content_review_tasks",
    "create table if not exists public.content_review_events",
    "content_origin_is_immutable",
    "initial_governance_must_be_draft_unverified",
    "review_event_required",
    "append_only_governance_history",
    "optimistic_version_conflict",
    "recent_official_source_evidence_required",
    "three consecutive hard failures spanning at least 24 hours",
    "with (security_invoker = true)",
    "Legacy rows are deliberately backfilled as migrated/draft/unverified"
  ]) {
    assert.match(sql, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
  }
  assert.doesNotMatch(sql, /\bdrop\s+table\b/i);
  assert.doesNotMatch(sql, /grant execute on function public\.verify_content_now\([^;]+to service_role/i);
  assert.match(sql, /grant execute on function public\.verify_content_now\([^;]+to authenticated/i);
});

test("research storage is purpose-limited and disabled by default", async () => {
  const sql = await readFile(migrationUrl, "utf8");
  const table = sql.match(
    /create table if not exists public\.research_observations \(([\s\S]*?)\n\);/
  )?.[1] ?? "";
  assert.ok(table);
  for (const forbidden of ["bsn", "email", "phone", "medical", "form_text", "ip_address", "user_agent"]) {
    assert.doesNotMatch(table, new RegExp(`\\b${forbidden}\\b`, "i"));
  }
  assert.match(sql, /\('research_ingestion', false,/);
  assert.match(sql, /expires_at <= created_at \+ interval '90 days'/);
  assert.match(sql, /active_research_consent_required/);
});

test("AI is not a review actor and cannot approve publication", async () => {
  const sql = await readFile(migrationUrl, "utf8");
  const reviewEvents = sql.match(
    /create table if not exists public\.content_review_events \(([\s\S]*?)\n\);/
  )?.[1] ?? "";
  assert.ok(reviewEvents);
  assert.match(reviewEvents, /actor_type text not null check \(actor_type in \('human', 'system'\)\)/);
  assert.doesNotMatch(reviewEvents, /'ai'/);
  assert.match(sql, /event\.actor_type = 'human'/);
  assert.match(sql, /human_review_event_required/);
});

test("local Supabase pgTAP suite covers RLS, provenance and immutable history", async () => {
  const sql = await readFile(pgTapUrl, "utf8");
  for (const evidence of [
    "initial_governance_must_be_draft_unverified",
    "review_event_required",
    "append_only_governance_history",
    "authenticated clients have no direct governance-table write privilege",
    "AI origin is preserved in append-only version provenance"
  ]) {
    assert.match(sql, new RegExp(evidence, "i"));
  }
  assert.match(sql, /set local role authenticated/i);
  assert.match(sql, /set local role service_role/i);
  assert.match(sql, /select plan\(12\)/i);
});

test("governance hardening covers foreign keys and avoids duplicate select policies", async () => {
  const sql = await readFile(hardeningMigrationUrl, "utf8");
  const expectedIndexes = [
    "content_governance_state_owner_idx",
    "content_governance_state_reviewed_by_idx",
    "content_governance_state_second_reviewed_by_idx",
    "content_governance_versions_actor_idx",
    "content_review_events_governance_state_idx",
    "content_review_events_task_idx",
    "content_review_tasks_owner_idx",
    "content_review_tasks_source_issue_idx",
    "governance_action_receipts_state_idx",
    "governance_feature_flags_changed_by_idx",
    "research_consents_created_by_idx",
    "research_observations_recorded_by_idx",
    "research_observations_session_idx"
  ];
  for (const index of expectedIndexes) {
    assert.match(sql, new RegExp(`create index if not exists ${index}`, "i"));
  }
  assert.doesNotMatch(sql, /governance_feature_flags for all/i);
  assert.match(sql, /created_by = \(select auth\.uid\(\)\)/i);
  assert.match(sql, /\(select private\.governance_current_admin_role\(\)\)/i);
});
