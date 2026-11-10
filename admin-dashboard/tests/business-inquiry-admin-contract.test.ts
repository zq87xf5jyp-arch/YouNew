import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const baseMigration = await readFile(new URL("../supabase/migrations/20260728192120_younew_production_operations.sql", import.meta.url), "utf8");
const pipelineMigration = await readFile(new URL("../supabase/migrations/20260818191112_harden_business_inquiry_pipeline.sql", import.meta.url), "utf8");
const pipelineSqlTest = await readFile(new URL("../supabase/tests/business_inquiry_pipeline_test.sql", import.meta.url), "utf8");
const migration = `${baseMigration}\n${pipelineMigration}`;
const list = await readFile(new URL("../src/components/admin/business-inquiry-list.tsx", import.meta.url), "utf8");
const actions = await readFile(new URL("../src/app/(admin)/business-inquiries/actions.ts", import.meta.url), "utf8");
const details = await readFile(new URL("../src/app/(admin)/business-inquiries/[id]/page.tsx", import.meta.url), "utf8");
const exportRoute = await readFile(new URL("../src/app/(admin)/business-inquiries/export/route.ts", import.meta.url), "utf8");
const workspaceStatus = await readFile(new URL("../src/app/api/workspace/status/route.ts", import.meta.url), "utf8");
const pipelineContract = await readFile(new URL("../src/lib/business-inquiry-pipeline.ts", import.meta.url), "utf8");

const compatibility = await readFile(new URL("../src/lib/business-inquiry-compatibility.ts", import.meta.url), "utf8");
const editor = await readFile(new URL("../src/components/admin/business-inquiry-editor.tsx", import.meta.url), "utf8");
const updateContract = `${actions}\n${compatibility}\n${editor}`;

const canonicalStatuses = ["new", "qualified", "discovery", "proposal", "won", "lost", "archived"];
const retiredStatuses = ["reviewing", "responded", "accepted", "declined", "test"];
const lostReasons = [
  "no_observed_problem",
  "existing_solution_sufficient",
  "wrong_owner",
  "no_budget",
  "timing",
  "insufficient_proof",
  "security_privacy",
  "content_trust",
  "price_value",
  "scope_delivery",
  "no_response_after_sequence",
  "other_explicit"
];
const legacyConsumerFields = ["confirmation_code", "company", "contact_name", "work_email", "internal_note"];

test("Admin business-inquiry consumers use the authoritative migration columns", () => {
  for (const field of ["reference_code", "company_name", "contact_person", "email", "admin_notes"]) {
    assert.match(migration, new RegExp(`\\b${field}\\b`));
    assert.match(`${list}\n${updateContract}\n${details}\n${exportRoute}`, new RegExp(`\\b${field}\\b`));
  }
  for (const field of legacyConsumerFields) {
    assert.doesNotMatch(`${list}\n${updateContract}\n${details}\n${exportRoute}`, new RegExp(`\\b${field}\\b`));
  }
});

test("Future pipeline keeps its exact states; deployed schema is an explicit server-owned adapter", () => {
  for (const status of canonicalStatuses) {
    assert.match(pipelineMigration, new RegExp(`'${status}'`));
    assert.match(pipelineContract, new RegExp(`"${status}"`));
  }
  for (const status of [...retiredStatuses, "contacted", "closed", "rejected", "spam"]) {
    assert.doesNotMatch(`${pipelineContract}`, new RegExp(`"${status}"`));
  }
  assert.match(compatibility, /openStatuses: \["new", "qualified", "discovery", "proposal"\]/);
  assert.match(compatibility, /CURRENT_INQUIRY_SCHEMA: InquirySchema = "legacy-v1"/);
  assert.match(workspaceStatus, /CURRENT_INQUIRY_CONTRACT.openStatuses/);
  assert.match(list, /inquiryLabels\(schema\)/);
});

test("Pipeline migration preserves legacy meaning without inventing wins", () => {
  assert.match(pipelineMigration, /legacy_status = status/);
  assert.match(pipelineMigration, /when status in \('declined', 'test', 'archived'\) then 'archived'/);
  assert.match(pipelineMigration, /else 'new'/);
  assert.doesNotMatch(pipelineMigration, /when status = 'accepted' then 'won'/);
  assert.match(pipelineMigration, /status_changed_at/);
});

test("Lost reasons and won evidence are fail-closed in SQL and the Admin action", () => {
  for (const reason of lostReasons) {
    assert.match(pipelineMigration, new RegExp(`'${reason}'`));
    assert.match(pipelineContract, new RegExp(`"${reason}"`));
  }
  assert.match(pipelineMigration, /status = 'lost'[\s\S]+lost_reason is not null/);
  assert.match(pipelineMigration, /lost_reason is distinct from 'other_explicit'[\s\S]+lost_reason_detail is not null/);
  assert.match(pipelineMigration, /status = 'won'[\s\S]+won_evidence_type is not null[\s\S]+won_evidence_at is not null/);
  assert.match(updateContract, /status === "lost"/);
  assert.match(updateContract, /status === "won"/);
  assert.match(updateContract, /lost_reason: status === "lost" \? lostReason : null/);
  assert.match(updateContract, /won_evidence_type: status === "won" \? wonEvidenceType : null/);
  assert.match(pipelineSqlTest, /lost cannot be stored without a controlled reason/);
  assert.match(pipelineSqlTest, /future won evidence is rejected/);
  assert.match(pipelineSqlTest, /free-form lost detail is excluded from audit JSON/);
});

test("Lead qualification fields, explicit grants and owner export stay aligned", () => {
  for (const field of ["contact_role", "offer_interest", "lost_reason", "won_evidence_type", "won_evidence_at", "status_changed_at"]) {
    assert.match(pipelineMigration, new RegExp(`\\b${field}\\b`));
    assert.match(`${updateContract}\n${details}\n${exportRoute}`, new RegExp(`\\b${field}\\b`));
  }
  assert.match(`${updateContract}\n${details}`, /\blost_reason_detail\b/);
  assert.doesNotMatch(exportRoute, /\blost_reason_detail\b/);
  assert.match(pipelineMigration, /grant update \([\s\S]*contact_role[\s\S]*offer_interest[\s\S]*lost_reason[\s\S]*won_evidence_type[\s\S]*\) on table public\.business_inquiries to authenticated;/);
});
