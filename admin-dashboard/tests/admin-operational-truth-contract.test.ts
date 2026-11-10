import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  adaptBusinessInquiryDetailRow,
  adaptBusinessInquiryExportRows,
  adaptBusinessInquiryListRows
} from "../src/lib/business-inquiry-admin.ts";

const feedbackMigration = await readFile(new URL("../supabase/migrations/20260819124837_add_feedback_record_origin.sql", import.meta.url), "utf8");
const syncMigration = await readFile(new URL("../supabase/migrations/20260819124856_add_sync_job_leases.sql", import.meta.url), "utf8");
const settingsMigration = await readFile(new URL("../supabase/migrations/20260819143000_bootstrap_admin_settings_contract.sql", import.meta.url), "utf8");
const relationPrivilegeMigration = await readFile(new URL("../supabase/migrations/20260819173000_harden_public_relation_privileges.sql", import.meta.url), "utf8");
const syncHandler = await readFile(new URL("../supabase/functions/prepare-content-sync/handler.ts", import.meta.url), "utf8");
const syncEdge = await readFile(new URL("../supabase/functions/prepare-content-sync/index.ts", import.meta.url), "utf8");
const settingsPage = await readFile(new URL("../src/app/(admin)/settings/page.tsx", import.meta.url), "utf8");
const settingsAction = await readFile(new URL("../src/app/(admin)/settings/actions.ts", import.meta.url), "utf8");
const settingsLibrary = await readFile(new URL("../src/lib/admin-settings.ts", import.meta.url), "utf8");
const inquiryPage = await readFile(new URL("../src/app/(admin)/business-inquiries/page.tsx", import.meta.url), "utf8");
const inquiryDetailPage = await readFile(new URL("../src/app/(admin)/business-inquiries/[id]/page.tsx", import.meta.url), "utf8");
const inquiryActions = await readFile(new URL("../src/app/(admin)/business-inquiries/actions.ts", import.meta.url), "utf8");
const workspaceStatus = await readFile(new URL("../src/app/api/workspace/status/route.ts", import.meta.url), "utf8");
const inquiryExport = await readFile(new URL("../src/app/(admin)/business-inquiries/export/route.ts", import.meta.url), "utf8");
const middleware = await readFile(new URL("../src/middleware.ts", import.meta.url), "utf8");
const auth = await readFile(new URL("../src/lib/auth.ts", import.meta.url), "utf8");
const feedbackPage = await readFile(new URL("../src/app/(admin)/feedback/page.tsx", import.meta.url), "utf8");
const bugsPage = await readFile(new URL("../src/app/(admin)/bugs/page.tsx", import.meta.url), "utf8");
const bugManager = await readFile(new URL("../src/components/admin/bug-manager.tsx", import.meta.url), "utf8");
const schemaInventory = await readFile(new URL("../supabase/verification/capture_admin_schema_inventory.sql", import.meta.url), "utf8");
const schemaInventoryValidator = await readFile(new URL("../scripts/validate-admin-schema-inventory.py", import.meta.url), "utf8");

test("business inquiry adapter rejects blank required cells without copying PII into issues", () => {
  const result = adaptBusinessInquiryListRows([
    {
      id: "10000000-0000-4000-8000-000000000001",
      reference_code: "YNI-VALID",
      company_name: "Valid BV",
      contact_person: "Synthetic Contact",
      email: "valid@example.invalid",
      inquiry_type: "partnership",
      status: "new",
      offer_interest: "employee_onboarding_pilot",
      status_changed_at: "2026-08-19T10:00:00Z",
      source_page: "/partners/apply/",
      created_at: "2026-08-19T10:00:00Z"
    },
    {
      id: "20000000-0000-4000-8000-000000000002",
      reference_code: "",
      company_name: "Hidden BV",
      contact_person: "Hidden Person",
      email: "hidden@example.invalid",
      inquiry_type: "partnership",
      status: "unknown",
      created_at: "not-a-date"
    }
  ]);
  assert.equal(result.rows.length, 1);
  assert.equal(result.issues.length, 1);
  assert.deepEqual(result.issues[0]?.missingFields.sort(), ["created_at", "reference_code", "status"]);
  assert.doesNotMatch(JSON.stringify(result.issues), /Hidden|hidden@example/u);
});

test("business inquiry list uses an explicit select and integrity adapter", () => {
  assert.match(inquiryPage, /BUSINESS_INQUIRY_LIST_SELECT/);
  assert.match(inquiryPage, /adaptBusinessInquiryListRows/);
  assert.match(inquiryPage, /inquiryIntegrityFailure/);
  assert.match(inquiryPage, /Data integrity error/);
  assert.match(inquiryPage, /available=\{!inquiryResult\.error && !inquiryIntegrityFailure\}/);
  assert.ok(
    inquiryPage.indexOf("inquiryIntegrityFailure") < inquiryPage.indexOf('(inquiryResult.data ?? []).length === 0 ? "empty"'),
    "invalid rows must take precedence over the legitimate empty state"
  );
  assert.doesNotMatch(inquiryPage, /fetchRowsResult<BusinessInquiryListRow>/);
});

test("business inquiry CSV adapter fails closed on required fields, status and dates", () => {
  const result = adaptBusinessInquiryExportRows([{
    id: "30000000-0000-4000-8000-000000000003",
    reference_code: "YNI-EXPORT",
    company_name: "Synthetic Export BV",
    contact_person: "Synthetic Person",
    email: "synthetic@example.invalid",
    inquiry_type: "pilot",
    status: "unknown",
    created_at: "invalid",
    status_changed_at: "also-invalid"
  }]);
  assert.equal(result.rows.length, 0);
  assert.deepEqual(result.issues[0]?.missingFields.sort(), ["created_at", "status", "status_changed_at"]);
  assert.doesNotMatch(JSON.stringify(result.issues), /Synthetic|example\.invalid/);
  assert.match(inquiryExport, /BUSINESS_INQUIRY_EXPORT_SELECT/);
  assert.match(inquiryExport, /adaptBusinessInquiryExportRows/);
  assert.match(inquiryExport, /Data integrity error/);
});

test("business inquiry detail rejects missing identity fields and actions require an affected row", () => {
  const invalid = adaptBusinessInquiryDetailRow({ id: "", reference_code: "YNI-1", company_name: "", status: "unknown" });
  assert.equal(invalid.row, null);
  assert.deepEqual(invalid.issue?.missingFields.sort(), ["company_name", "id", "status"]);
  assert.match(inquiryDetailPage, /BUSINESS_INQUIRY_DETAIL_SELECT/);
  assert.match(inquiryDetailPage, /adaptBusinessInquiryDetailRow/);
  assert.match(inquiryDetailPage, /Data integrity error/);
  assert.match(inquiryActions, /\.eq\("updated_at", parsed.version\)/);
  assert.match(inquiryActions, /\.select\(CURRENT_INQUIRY_CONTRACT.updateSelect\)/);
  assert.match(inquiryActions, /verifyInquiryUpdate\(updated, parsed, admin.id\)/);
  assert.match(inquiryActions, /if \(error \|\| !updated\)/g);
});

test("private APIs distinguish authorization source failure and CSV export never truncates silently", () => {
  assert.match(workspaceStatus, /profileError[\s\S]*authorization_source_unavailable/);
  assert.match(inquiryExport, /userError \|\| !user/);
  assert.match(inquiryExport, /profileError[\s\S]*Authorization source unavailable/);
  assert.match(inquiryExport, /exportWatermark/);
  assert.match(inquiryExport, /\.lte\("created_at", exportWatermark\)/);
  assert.match(inquiryExport, /created_at\.lt\.\$\{cursor\.created_at\}.*id\.lt\.\$\{cursor\.id\}/);
  assert.doesNotMatch(inquiryExport, /\.range\(offset/);
  assert.match(inquiryExport, /maximumRows = 10_000/);
  assert.match(inquiryExport, /status: 413/);
  assert.match(inquiryExport, /X-YouNew-Export-Complete/);
  assert.match(inquiryExport, /X-YouNew-Export-Watermark/);
});

test("admin auth preserves valid sessions when the authorization source is unavailable", () => {
  assert.match(auth, /userError[\s\S]*authorization-source/);
  assert.match(auth, /profileError[\s\S]*authorization-source/);
  assert.match(middleware, /userError[\s\S]*authorization-source/);
  assert.match(middleware, /profileError[\s\S]*authorization-source/);
  assert.ok(
    middleware.indexOf("if (profileError)") < middleware.indexOf("await supabase.auth.signOut()"),
    "a profile outage must be handled before the confirmed not-approved sign-out path"
  );
  assert.match(syncMigration, /coalesce\(\s*lease_expires_at,\s*coalesce\(heartbeat_at, started_at, created_at\) \+ interval '15 minutes'\s*\)/);
});

test("feedback provenance is server-controlled and excluded from broad updates", () => {
  assert.match(feedbackMigration, /record_origin text not null default 'legacy_unclassified'/);
  assert.match(feedbackMigration, /v_page, v_type, v_now, 'user_submission'/);
  assert.match(feedbackMigration, /revoke update on table public\.feedback from authenticated/);
  assert.match(feedbackMigration, /grant update \(status, resolution_note, resolved_by\)/);
  assert.match(feedbackMigration, /feedback_origin_classified/);
  assert.match(workspaceStatus, /from\("feedback"\)[\s\S]*\.eq\("record_origin", "user_submission"\)/);
  assert.match(feedbackPage, /<ReadOnlySource/);
  assert.match(feedbackPage, /Это не глобальный total/);
  assert.doesNotMatch(feedbackPage, /записей всего/);
});

test("workspace link health uses fresh canonical observations and never converts missing evidence to zero", () => {
  assert.match(workspaceStatus, /from\("official_link_operational_latest"\)/);
  assert.match(workspaceStatus, /classifyOfficialLinkObservation/);
  assert.match(workspaceStatus, /canonicalSourceKeys/);
  assert.match(workspaceStatus, /linkHealthSourceState === "available" \? freshBrokenLinks : null/);
  assert.match(workspaceStatus, /sourceState: linkHealthSourceState/);
  assert.doesNotMatch(workspaceStatus, /from\("official_links"\)[\s\S]*status", "broken"/);
  assert.doesNotMatch(workspaceStatus, /brokenLinks\.count \?\? 0/);
});

test("Bugs unavailable and forbidden states never become measured zero counts", () => {
  assert.match(bugsPage, /canManageBugs\(admin\.role\)/);
  assert.match(bugsPage, /const available = state === "data" \|\| state === "empty"/);
  assert.match(bugsPage, /allowed && state !== "forbidden"/);
  assert.match(bugManager, /Количество и статусы неизвестны/);
  assert.match(bugManager, /available \? localRows\.filter\(row => row\.status === key\)\.length : "—"/);
  assert.match(bugManager, /available && localRows\.length === 0/);
});

test("schema review fingerprints security definitions instead of comparing names only", () => {
  assert.match(schemaInventory, /relrowsecurity/);
  assert.match(schemaInventory, /relforcerowsecurity/);
  assert.match(schemaInventory, /pg_get_functiondef/);
  assert.match(schemaInventory, /coalesce\(with_check, ''\)/);
  assert.match(schemaInventory, /information_schema\.table_privileges/);
  assert.match(schemaInventory, /information_schema\.column_privileges/);
  assert.match(schemaInventory, /information_schema\.routine_privileges/);
  assert.match(schemaInventory, /'PUBLIC', 'anon', 'authenticated', 'service_role'/);
  assert.match(schemaInventory, /schema_grant/);
  assert.match(schemaInventory, /pg_default_acl/);
  assert.match(schemaInventory, /pg_get_constraintdef/);
  assert.match(schemaInventory, /pg_get_triggerdef/);
  assert.match(schemaInventoryValidator, /exact_reviewed_delta_match/);
  assert.match(schemaInventoryValidator, /unexpected_public_grant_additions/);
  assert.match(schemaInventoryValidator, /reviewed_status == "reviewed"/);
  assert.match(schemaInventoryValidator, /--reviewed/);
  assert.match(schemaInventoryValidator, /--candidate/);
  assert.doesNotMatch(schemaInventoryValidator, /ALLOWED_CHANGED_IDENTITIES/);
  assert.match(schemaInventoryValidator, /len\(columns\) != 3/);
});

test("browser roles never inherit relation-owner capabilities", () => {
  assert.match(relationPrivilegeMigration, /default privileges for role postgres[\s\S]*revoke all privileges on tables/);
  assert.match(relationPrivilegeMigration, /default privileges for role supabase_admin[\s\S]*revoke all privileges on tables/);
  assert.match(relationPrivilegeMigration, /revoke truncate, references, trigger, maintain/);
  assert.match(relationPrivilegeMigration, /from public, anon, authenticated/);
});

test("historical scheduled lease proposal remains distinct from current manual fenced executor", () => {
  for (const name of ["claim_sync_job", "heartbeat_sync_job", "finalize_sync_job", "reconcile_stale_sync_jobs"]) {
    assert.match(syncMigration, new RegExp(`function (?:public|private)\\.${name}`));
  }
  assert.match(syncMigration, /status in \('queued', 'running', 'succeeded', 'failed', 'cancelled', 'timed_out'\)/);
  assert.match(syncMigration, /'\*\/5 \* \* \* \*'/);
  assert.ok(
    syncMigration.indexOf('"lease_migration":"legacy_backfill"') < syncMigration.indexOf("add constraint sync_jobs_lease_shape_check"),
    "legacy running rows must be normalized before the lease constraint is validated"
  );
  assert.match(syncMigration, /queued_at < p_reference_at - interval '10 minutes'/);
  assert.match(syncMigration, /coalesce\(heartbeat_at, started_at, queued_at\) < p_reference_at - interval '15 minutes'/);
  assert.doesNotMatch(syncMigration, /queued_at <= p_reference_at - interval '10 minutes'/);
  assert.match(syncEdge, /createSyncHandler/);
  assert.match(syncEdge, /AbortSignal\.timeout\(5000\)/);
  for (const name of ["claim_content_sync_candidate", "finalize_content_sync_candidate", "fail_content_sync_candidate", "get_content_sync_request"]) {
    assert.ok(syncHandler.includes(`"${name}"`));
  }
  assert.match(syncHandler, /invocationAttempt < 3/);
  assert.match(syncHandler, /40000/);
  assert.match(syncHandler, /\.limit\(501\)/);
  assert.doesNotMatch(syncHandler, /claim_sync_job|heartbeat_sync_job|finalize_sync_job/);
  assert.doesNotMatch(syncHandler, /\.from\("sync_jobs"\)\.update|\.upsert\(/);

});

test("settings fail closed and validate an authenticated allowlisted payload", () => {
  assert.match(settingsPage, /result\.error/);
  assert.match(settingsPage, /Сохранение заблокировано/);
  assert.match(settingsAction, /requireAdmin\(\)/);
  assert.match(settingsAction, /canManageSettings/);
  assert.match(settingsAction, /parseSettingsFormData/);
  assert.match(settingsPage, /parseStoredSettings/);
  assert.match(settingsPage, /select\("key,value,status"\)/);
  assert.match(settingsPage, /!parsed\?\.success/);
  assert.match(settingsLibrary, /z\.enum\(\["en", "nl", "ru"\]\)/);
  assert.match(settingsLibrary, /canonicalCities\(\)/);
  assert.match(settingsLibrary, /new URL\(value\)\.protocol === "https:"/);
  assert.match(settingsLibrary, /missingKeys\.length > 0/);
  assert.match(settingsLibrary, /maintenance_mode: z\.boolean\(\)/);
  assert.match(settingsAction, /select\("key,status"\)/);
  assert.match(settingsAction, /Status is deliberately omitted from the write/);
  assert.match(settingsAction, /Array<\{ key: string; value: string \| boolean \}>/);
  assert.doesNotMatch(settingsAction, /status: statuses\.get/);
  assert.doesNotMatch(settingsAction, /status: "published"/);
  assert.match(settingsMigration, /on conflict \(key\) do nothing/);
  assert.match(settingsMigration, /'maintenance_mode', 'false'::jsonb/);
  assert.match(settingsMigration, /jsonb_typeof\(value\) = 'string'/);
  assert.doesNotMatch(settingsAction, /throw new Error\(`Не удалось сохранить настройки/);
});
