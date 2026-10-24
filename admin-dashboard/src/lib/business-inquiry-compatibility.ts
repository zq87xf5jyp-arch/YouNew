import {
  adaptBusinessInquiryListRows, adaptBusinessInquiryDetailRow, adaptBusinessInquiryExportRows,
  BUSINESS_INQUIRY_LIST_SELECT, BUSINESS_INQUIRY_DETAIL_SELECT, BUSINESS_INQUIRY_EXPORT_SELECT,
  type BusinessInquiryListRow, type BusinessInquiryIntegrityIssue
} from "./business-inquiry-admin.ts";
import {
  BUSINESS_INQUIRY_STATUS_LABELS, isBusinessInquiryStatus, isBusinessInquiryOfferInterest,
  isBusinessInquiryLostReason, isBusinessInquiryWonEvidenceType, type BusinessInquiryStatus
} from "./business-inquiry-pipeline.ts";

export type InquirySchema = "legacy-v1" | "pipeline-v2";
// Server-owned release choice, matching reviewed deployed metadata. Switching to
// pipeline-v2 requires separate schema/grant validation; never retry a failed write
// under another schema and never take this choice from request input or env.
export const CURRENT_INQUIRY_SCHEMA: InquirySchema = "legacy-v1";
export const LEGACY_INQUIRY_LABELS = {
  new: "новая", reviewing: "на рассмотрении", responded: "ответили",
  accepted: "принята", declined: "отклонена", test: "тестовая", archived: "архив"
} as const;
export type LegacyInquiryStatus = keyof typeof LEGACY_INQUIRY_LABELS;
export type LegacyInquiryListRow = Omit<BusinessInquiryListRow, "status" | "offer_interest" | "status_changed_at"> & { schema: "legacy-v1"; status: LegacyInquiryStatus };
export type CompatibleInquiryListRow = LegacyInquiryListRow | (BusinessInquiryListRow & { schema: "pipeline-v2" });
export type InquiryUpdate = {
  id: string; updated_at: string; admin_notes: string | null; handled_by: string | null;
} & ({ schema: "legacy-v1"; status: LegacyInquiryStatus } | {
  schema: "pipeline-v2"; status: BusinessInquiryStatus; contact_role: string | null;
  offer_interest: string; lost_reason: string | null; lost_reason_detail: string | null;
  won_evidence_type: string | null; won_evidence_at: string | null;
});
export type InquiryActionResult = { ok: true; row: InquiryUpdate } | { ok: false; message: string };
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export const isInquiryId = (value: unknown): value is string => typeof value === "string" && uuid.test(value);
export function isInquiryVersion(value: unknown): value is string {
  return typeof value === "string" && value.length <= 64 && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})$/.test(value) && Number.isFinite(Date.parse(value));
}
export function inquiryLabels(schema: InquirySchema): Readonly<Record<string, string>> {
  return schema === "legacy-v1" ? LEGACY_INQUIRY_LABELS : BUSINESS_INQUIRY_STATUS_LABELS;
}
export function inquiryStatus(schema: InquirySchema, value: unknown): value is LegacyInquiryStatus | BusinessInquiryStatus {
  return typeof value === "string" && (schema === "legacy-v1" ? Object.hasOwn(LEGACY_INQUIRY_LABELS, value) : isBusinessInquiryStatus(value));
}
const legacyList = "id,reference_code,company_name,contact_person,email,inquiry_type,status,source_page,created_at";
const legacyDetail = `${legacyList},phone,website,organization_type,kvk_number,city,province,target_audience,requested_placements,campaign_goal,budget_range,campaign_start,campaign_end,message,consent_at,admin_notes,handled_by,updated_at`;
const legacyExportColumns = ["reference_code", "company_name", "contact_person", "email", "inquiry_type", "status", "source_page", "created_at"];
const pipelineExportColumns = ["reference_code", "company_name", "contact_person", "email", "contact_role", "inquiry_type", "offer_interest", "status", "lost_reason", "won_evidence_type", "won_evidence_at", "status_changed_at", "source_page", "created_at"];
export function inquiryContract(schema: InquirySchema) {
  return schema === "legacy-v1" ? {
    listSelect: legacyList, detailSelect: legacyDetail, exportSelect: legacyList,
    updateSelect: "id,status,admin_notes,handled_by,updated_at", exportColumns: legacyExportColumns,
    openStatuses: ["new", "reviewing", "responded"]
  } : {
    listSelect: BUSINESS_INQUIRY_LIST_SELECT, detailSelect: `${BUSINESS_INQUIRY_DETAIL_SELECT},handled_by,updated_at`,
    exportSelect: BUSINESS_INQUIRY_EXPORT_SELECT,
    updateSelect: "id,status,admin_notes,handled_by,updated_at,contact_role,offer_interest,lost_reason,lost_reason_detail,won_evidence_type,won_evidence_at",
    exportColumns: pipelineExportColumns, openStatuses: ["new", "qualified", "discovery", "proposal"]
  };
}
export const CURRENT_INQUIRY_CONTRACT = inquiryContract(CURRENT_INQUIRY_SCHEMA);
const required = ["id", "reference_code", "company_name", "contact_person", "email", "inquiry_type", "created_at"];
function legacyRows(input: unknown[]) {
  const rows: LegacyInquiryListRow[] = [], issues: BusinessInquiryIntegrityIssue[] = [];
  input.forEach((value, rowIndex) => {
    const row = value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
    const missingFields = required.filter(key => typeof row[key] !== "string" || !(row[key] as string).trim());
    if (!isInquiryId(row.id) && !missingFields.includes("id")) missingFields.push("id");
    if (!inquiryStatus("legacy-v1", row.status)) missingFields.push("status");
    if (!isInquiryVersion(row.created_at) && !missingFields.includes("created_at")) missingFields.push("created_at");
    if (missingFields.length) { issues.push({ rowIndex, missingFields }); return; }
    rows.push({ ...Object.fromEntries(legacyList.split(",").map(key => [key, row[key]])), schema: "legacy-v1" } as LegacyInquiryListRow);
  });
  return { rows, issues };
}
export function adaptInquiryList(input: unknown[], schema: InquirySchema): { rows: CompatibleInquiryListRow[]; issues: BusinessInquiryIntegrityIssue[] } {
  if (schema === "legacy-v1") return legacyRows(input);
  const adapted = adaptBusinessInquiryListRows(input);
  return { ...adapted, rows: adapted.rows.map(row => ({ ...row, schema: "pipeline-v2" })) };
}
export function adaptInquiryExport(input: unknown[], schema: InquirySchema) {
  if (schema === "legacy-v1") return legacyRows(input);
  return adaptBusinessInquiryExportRows(input);
}
export function adaptInquiryDetail(input: unknown, schema: InquirySchema): { row: (Record<string, unknown> & InquiryUpdate) | null; issue: { missingFields: string[] } | null } {
  const candidate = input && typeof input === "object" && !Array.isArray(input) ? input as Record<string, unknown> : {};
  const adapted = schema === "pipeline-v2" ? adaptBusinessInquiryDetailRow(input) : null;
  const missingFields: string[] = adapted?.issue?.missingFields.slice() ?? [];
  for (const key of ["id", "reference_code", "company_name"]) if (typeof candidate[key] !== "string" || !(candidate[key] as string).trim()) missingFields.push(key);
  if (!isInquiryId(candidate.id)) missingFields.push("id");
  if (!inquiryStatus(schema, candidate.status)) missingFields.push("status");
  if (!isInquiryVersion(candidate.updated_at)) missingFields.push("updated_at");
  if (candidate.admin_notes !== null && (typeof candidate.admin_notes !== "string" || candidate.admin_notes.length > 2000)) missingFields.push("admin_notes");
  if (candidate.handled_by !== null && !isInquiryId(candidate.handled_by)) missingFields.push("handled_by");
  if (schema === "pipeline-v2") {
    if (typeof candidate.offer_interest !== "string" || !isBusinessInquiryOfferInterest(candidate.offer_interest)) missingFields.push("offer_interest");
    for (const key of ["contact_role", "lost_reason", "lost_reason_detail", "won_evidence_type", "won_evidence_at"]) if (candidate[key] !== null && typeof candidate[key] !== "string") missingFields.push(key);
  }
  return missingFields.length ? { row: null, issue: { missingFields: [...new Set(missingFields)] } } : { row: { ...candidate, schema } as Record<string, unknown> & InquiryUpdate, issue: null };
}
function validEvidenceDate(value: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value) || value > new Date().toISOString().slice(0, 10)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return Number.isFinite(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
}
export function parseInquiryUpdate(form: FormData, schema: InquirySchema) {
  const names = ["schema", "id", "updated_at", "status", "internalNote", ...(schema === "pipeline-v2" ? ["contactRole", "offerInterest", "lostReason", "lostReasonDetail", "wonEvidenceType", "wonEvidenceDate"] : [])];
  if ([...form.keys()].some(key => !names.includes(key)) || names.some(key => form.getAll(key).length !== 1 || typeof form.get(key) !== "string")) return null;
  if (form.get("schema") !== schema) return null;
  const value = (key: string) => form.get(key) as string;
  const id = value("id"), version = value("updated_at"), status = value("status"), note = value("internalNote");
  if (!isInquiryId(id) || !isInquiryVersion(version) || !inquiryStatus(schema, status) || note.length > 2000) return null;
  const values: Record<string, string | null> = { status, admin_notes: note.trim() || null };
  if (schema === "pipeline-v2") {
    const contactRole = value("contactRole").trim(), offerInterest = value("offerInterest"), lostReason = value("lostReason"), lostReasonDetail = value("lostReasonDetail").trim(), wonEvidenceType = value("wonEvidenceType"), wonEvidenceDate = value("wonEvidenceDate");
    if (contactRole.length > 120 || (contactRole.length > 0 && contactRole.length < 2) || !isBusinessInquiryOfferInterest(offerInterest)) return null;
    if (status === "lost" && (!isBusinessInquiryLostReason(lostReason) || lostReasonDetail.length > 500 || (lostReasonDetail.length > 0 && lostReasonDetail.length < 5) || (lostReason === "other_explicit" && !lostReasonDetail))) return null;
    if (status === "won" && (!isBusinessInquiryWonEvidenceType(wonEvidenceType) || !validEvidenceDate(wonEvidenceDate))) return null;
    Object.assign(values, { contact_role: contactRole || null, offer_interest: offerInterest, lost_reason: status === "lost" ? lostReason : null, lost_reason_detail: status === "lost" ? lostReasonDetail || null : null, won_evidence_type: status === "won" ? wonEvidenceType : null, won_evidence_at: status === "won" ? `${wonEvidenceDate}T00:00:00.000Z` : null });
  }
  return { id, version, schema, values };
}
export function verifyInquiryUpdate(input: unknown, parsed: NonNullable<ReturnType<typeof parseInquiryUpdate>>, actor: string): InquiryUpdate | null {
  if (!input || typeof input !== "object" || Array.isArray(input)) return null;
  const row = input as Record<string, unknown>;
  if (row.id !== parsed.id || row.handled_by !== actor || !isInquiryVersion(row.updated_at)) return null;
  const matches = Object.entries(parsed.values).every(([key, expected]) => key === "won_evidence_at" && expected !== null
    ? typeof row[key] === "string" && Date.parse(row[key]) === Date.parse(expected)
    : row[key] === expected);
  if (!matches) return null;
  // Return only validated submitted fields and the exact new server version.
  return { ...parsed.values, id: parsed.id, schema: parsed.schema, handled_by: actor, updated_at: row.updated_at } as InquiryUpdate;
}

export function inquiryEditorUpdate(row: Record<string, unknown> & InquiryUpdate): InquiryUpdate {
  const fields = inquiryContract(row.schema).updateSelect.split(",");
  return { ...Object.fromEntries(fields.map(key => [key, row[key]])), schema: row.schema } as InquiryUpdate;
}
