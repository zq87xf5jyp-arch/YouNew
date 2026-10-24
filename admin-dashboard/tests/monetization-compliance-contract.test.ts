import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL(
    "../supabase/migrations/20260818235619_enforce_monetization_retention_and_private_reports.sql",
    import.meta.url
  ),
  "utf8"
);
const retentionTest = await readFile(
  new URL("../supabase/tests/monetization_retention_policy_test.sql", import.meta.url),
  "utf8"
);
const reportTest = await readFile(
  new URL("../supabase/tests/pilot_usage_report_privacy_test.sql", import.meta.url),
  "utf8"
);
const geoAnalyticsTest = await readFile(
  new URL("../supabase/tests/geo_relevance_analytics_test.sql", import.meta.url),
  "utf8"
);

test("retention defaults, dry-run, legal holds and count-only audit are migration-enforced", () => {
  for (const [policy, days] of [
    ["unfinished_applications", 30],
    ["unconfirmed_spam_leads", 90],
    ["lost_archived_leads", 365],
    ["admin_notifications", 90],
    ["raw_usage_events", 90],
    ["anonymized_aggregate_reports", 730],
    ["temporary_csv_exports", 30],
    ["technical_logs_no_pii", 30],
  ] as const) {
    assert.match(migration, new RegExp(`'${policy}', ${days},`));
  }

  assert.match(migration, /run_retention_cleanup\([\s\S]*p_dry_run boolean default true/);
  assert.match(migration, /retention_legal_holds/);
  assert.match(migration, /eligible_count bigint[\s\S]*deleted_count bigint/);
  assert.doesNotMatch(
    migration.match(/create table private\.retention_cleanup_audit[\s\S]*?\);/)?.[0] ?? "",
    /email|phone|message|payload|entity_id|resource_id/i
  );
});

test("scheduled cleanup is database-local and excludes legal accounting records", () => {
  assert.match(migration, /create extension if not exists pg_cron;/);
  assert.match(migration, /'17 3 \* \* \*'/);
  assert.match(migration, /select \* from private\.run_retention_cleanup\(false\);/);
  assert.match(retentionTest, /contracts, invoices and accounting documents are outside automated cleanup/);
  assert.doesNotMatch(migration, /delete from [^;]*(?:contract|invoice|accounting)/i);
});

test("pilot reports enforce five-person suppression and strict client separation", () => {
  assert.match(migration, /having count\(\*\) >= 5[\s\S]*count\(distinct subject_token_hash\) >= 5/);
  assert.match(migration, /where client_scope_id = p_client_scope_id/);
  assert.match(migration, /and is_sample = p_sample_data/);
  assert.match(migration, /and consent_granted/);
  assert.match(reportTest, /a different client scope is never combined into the report/);
  assert.match(reportTest, /the four-person cohort is suppressed without exposing its counts/);
});

test("report export omits PII and always labels sample data", () => {
  const exportFunction = migration.match(
    /create or replace function public\.export_pilot_usage_report[\s\S]*?\n\$function\$;/
  )?.[0];
  assert.ok(exportFunction);
  assert.match(exportFunction, /'sampleData'/);
  assert.match(exportFunction, /'sample data'/);
  assert.match(exportFunction, /'smallCohortsSuppressed', true/);
  assert.doesNotMatch(
    exportFunction,
    /client_scope_id|subject_token_hash|email|phone|ip_address|user_id|message|timeline|partner|sponsor/i
  );
  assert.match(reportTest, /export JSON contains no client scope, individual identifier, PII, message or timeline/);
});

test("runtime pgTAP plans preserve 81 core, 67 compliance and 43 geo assertions", () => {
  assert.match(retentionTest, /select plan\(35\);/);
  assert.match(reportTest, /select plan\(32\);/);
  assert.match(geoAnalyticsTest, /select plan\(43\);/);
});
