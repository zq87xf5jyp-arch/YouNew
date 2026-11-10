import assert from "node:assert/strict";
import test from "node:test";
import { CURRENT_INQUIRY_SCHEMA, CURRENT_INQUIRY_CONTRACT, LEGACY_INQUIRY_LABELS, inquiryContract, adaptInquiryList, adaptInquiryDetail, parseInquiryUpdate, verifyInquiryUpdate, inquiryEditorUpdate } from "../src/lib/business-inquiry-compatibility.ts";
const id = "50000000-0000-4000-8000-000000000001", actor = "10000000-0000-4000-8000-000000000001", version = "2026-09-19T12:00:00.123456+00:00";
const row = { id, reference_code: "YN-SYNTHETIC", company_name: "Synthetic Company", contact_person: "Synthetic Contact", email: "synthetic@example.invalid", inquiry_type: "other", source_page: "/business/apply/", status: "accepted", created_at: version, updated_at: version, admin_notes: null, handled_by: null, message: "Synthetic private message" };
function form(schema = "legacy-v1", overrides: Record<string, string> = {}) {
  const data = new FormData();
  for (const [key, value] of Object.entries({ schema, id, updated_at: version, status: "new", internalNote: "Synthetic note", ...(schema === "pipeline-v2" ? { contactRole: "HR", offerInterest: "onboarding_pilot", lostReason: "", lostReasonDetail: "", wonEvidenceType: "", wonEvidenceDate: "" } : {}), ...overrides })) data.set(key, value);
  return data;
}
test("deployed mode and distinct statuses/projections do not invent wins or migration", () => {
  assert.equal(CURRENT_INQUIRY_SCHEMA, "legacy-v1");
  assert.deepEqual(Object.keys(LEGACY_INQUIRY_LABELS), ["new", "reviewing", "responded", "accepted", "declined", "test", "archived"]);
  for (const field of ["contact_role", "offer_interest", "legacy_status", "lost_reason", "lost_reason_detail", "won_evidence_type", "won_evidence_at", "status_changed_at"]) {
    for (const selection of [CURRENT_INQUIRY_CONTRACT.listSelect, CURRENT_INQUIRY_CONTRACT.detailSelect, CURRENT_INQUIRY_CONTRACT.exportSelect, CURRENT_INQUIRY_CONTRACT.updateSelect]) assert.ok(!selection.split(",").includes(field));
    assert.ok(inquiryContract("pipeline-v2").detailSelect.split(",").includes(field));
  }
  const legacy = adaptInquiryList([row], "legacy-v1");
  assert.equal(legacy.rows[0]?.status, "accepted"); assert.equal(legacy.rows[0]?.schema, "legacy-v1");
  assert.equal(adaptInquiryList([row], "pipeline-v2").rows.length, 0);
  assert.deepEqual(CURRENT_INQUIRY_CONTRACT.openStatuses, ["new", "reviewing", "responded"]);
  assert.deepEqual(inquiryContract("pipeline-v2").openStatuses, ["new", "qualified", "discovery", "proposal"]);
});
test("all legacy statuses keep exact meaning and reject future or unknown status", () => {
  for (const status of Object.keys(LEGACY_INQUIRY_LABELS)) assert.equal(parseInquiryUpdate(form("legacy-v1", { status }), "legacy-v1")?.values.status, status);
  for (const status of ["won", "lost", "qualified", "toString"]) assert.equal(parseInquiryUpdate(form("legacy-v1", { status }), "legacy-v1"), null);
  assert.equal(parseInquiryUpdate(form("pipeline-v2"), "legacy-v1"), null);
  const unexpected = form(); unexpected.set("contactRole", "HR"); assert.equal(parseInquiryUpdate(unexpected, "legacy-v1"), null);
});
test("typed inputs and exact microsecond version survive; invalid and duplicate inputs fail", () => {
  assert.equal(parseInquiryUpdate(form(), "legacy-v1")?.version, version);
  const invalidUpdates: Record<string, string>[] = [{ id: "bad" }, { updated_at: "2026" }, { internalNote: "x".repeat(2001) }];
  for (const update of invalidUpdates) assert.equal(parseInquiryUpdate(form("legacy-v1", update), "legacy-v1"), null);
  const file = form(); file.set("internalNote", new File(["x"], "note.txt")); assert.equal(parseInquiryUpdate(file, "legacy-v1"), null);
  const duplicate = form(); duplicate.append("status", "new"); assert.equal(parseInquiryUpdate(duplicate, "legacy-v1"), null);
});
test("future lost/won evidence rules remain effective", () => {
  const invalidUpdates: Record<string, string>[] = [{ status: "lost" }, { status: "lost", lostReason: "other_explicit" }, { status: "won" }, { status: "won", wonEvidenceType: "paid_pilot", wonEvidenceDate: "2099-01-01" }, { status: "won", wonEvidenceType: "paid_pilot", wonEvidenceDate: "2026-02-30" }];
  for (const update of invalidUpdates) assert.equal(parseInquiryUpdate(form("pipeline-v2", update), "pipeline-v2"), null);
  const won = parseInquiryUpdate(form("pipeline-v2", { status: "won", wonEvidenceType: "paid_pilot", wonEvidenceDate: "2026-01-01" }), "pipeline-v2");
  assert.equal(won?.values.won_evidence_at, "2026-01-01T00:00:00.000Z");
  assert.equal(parseInquiryUpdate(form("pipeline-v2", { status: "lost", lostReason: "other_explicit", lostReasonDetail: "Explicit synthetic reason" }), "pipeline-v2")?.values.lost_reason, "other_explicit");
});
test("readback verifies every submitted field in both schemas and returns no unrelated PII", () => {
  for (const schema of ["legacy-v1", "pipeline-v2"] as const) {
    const parsed = parseInquiryUpdate(form(schema), schema)!; const returned = { ...row, ...parsed.values, handled_by: actor };
    assert.ok(verifyInquiryUpdate(returned, parsed, actor));
    for (const key of Object.keys(parsed.values)) assert.equal(verifyInquiryUpdate({ ...returned, [key]: "wrong" }, parsed, actor), null, key);
    assert.equal(verifyInquiryUpdate(null, parsed, actor), null);
    assert.equal(verifyInquiryUpdate({ ...returned, updated_at: "bad" }, parsed, actor), null);
    assert.equal(Object.hasOwn(verifyInquiryUpdate(returned, parsed, actor)!, "message"), false);
  }
});
test("detail validation preserves current contract and editor omits contact/message payload", () => {
  const detail = adaptInquiryDetail(row, "legacy-v1"); assert.ok(detail.row); assert.equal(detail.row.status, "accepted");
  const editor = inquiryEditorUpdate(detail.row); assert.equal(Object.hasOwn(editor, "message"), false); assert.equal(Object.hasOwn(editor, "email"), false);
  assert.equal(adaptInquiryDetail({ ...row, updated_at: null }, "legacy-v1").row, null);
  assert.equal(adaptInquiryDetail(row, "pipeline-v2").row, null);
});
