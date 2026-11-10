import {
  isBusinessInquiryStatus,
  type BusinessInquiryStatus
} from "./business-inquiry-pipeline.ts";

export const BUSINESS_INQUIRY_LIST_SELECT = [
  "id",
  "reference_code",
  "company_name",
  "contact_person",
  "email",
  "inquiry_type",
  "status",
  "offer_interest",
  "status_changed_at",
  "source_page",
  "created_at"
].join(",");

export const BUSINESS_INQUIRY_DETAIL_SELECT = [
  "id",
  "reference_code",
  "company_name",
  "contact_person",
  "email",
  "phone",
  "website",
  "contact_role",
  "inquiry_type",
  "offer_interest",
  "organization_type",
  "kvk_number",
  "city",
  "province",
  "target_audience",
  "requested_placements",
  "campaign_goal",
  "budget_range",
  "campaign_start",
  "campaign_end",
  "message",
  "source_page",
  "legacy_status",
  "lost_reason",
  "lost_reason_detail",
  "won_evidence_type",
  "won_evidence_at",
  "status_changed_at",
  "consent_at",
  "created_at",
  "status",
  "admin_notes"
].join(",");

export const BUSINESS_INQUIRY_EXPORT_SELECT = [
  "id",
  "reference_code",
  "company_name",
  "contact_person",
  "email",
  "contact_role",
  "inquiry_type",
  "offer_interest",
  "status",
  "lost_reason",
  "won_evidence_type",
  "won_evidence_at",
  "status_changed_at",
  "source_page",
  "created_at"
].join(",");

export type BusinessInquiryListRow = {
  id: string;
  reference_code: string;
  company_name: string;
  contact_person: string;
  email: string;
  inquiry_type: string;
  status: BusinessInquiryStatus;
  offer_interest: string;
  status_changed_at: string;
  source_page: string;
  created_at: string;
};

export type BusinessInquiryIntegrityIssue = {
  rowIndex: number;
  missingFields: string[];
};

export type BusinessInquiryDetailRow = Record<string, unknown> & {
  id: string;
  reference_code: string;
  company_name: string;
  status: BusinessInquiryStatus;
};

export type BusinessInquiryDetailIntegrityIssue = {
  missingFields: string[];
};

export type BusinessInquiryExportRow = Record<string, unknown> & {
  id: string;
  reference_code: string;
  company_name: string;
  contact_person: string;
  email: string;
  inquiry_type: string;
  status: BusinessInquiryStatus;
  created_at: string;
};

const requiredTextFields = [
  "id",
  "reference_code",
  "company_name",
  "contact_person",
  "email",
  "inquiry_type",
  "created_at"
] as const;

function recordValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "string" ? value.trim() : "";
}

export function adaptBusinessInquiryListRows(input: unknown[]): {
  rows: BusinessInquiryListRow[];
  issues: BusinessInquiryIntegrityIssue[];
} {
  const rows: BusinessInquiryListRow[] = [];
  const issues: BusinessInquiryIntegrityIssue[] = [];

  input.forEach((candidate, rowIndex) => {
    if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
      issues.push({ rowIndex, missingFields: [...requiredTextFields, "status"] });
      return;
    }
    const row = candidate as Record<string, unknown>;
    const missingFields: string[] = requiredTextFields.filter((key) => !recordValue(row, key));
    const status = recordValue(row, "status");
    if (!isBusinessInquiryStatus(status)) missingFields.push("status");
    const createdAt = recordValue(row, "created_at");
    if (createdAt && Number.isNaN(Date.parse(createdAt))) missingFields.push("created_at");

    if (missingFields.length > 0) {
      issues.push({ rowIndex, missingFields: [...new Set(missingFields)] });
      return;
    }

    rows.push({
      id: recordValue(row, "id"),
      reference_code: recordValue(row, "reference_code"),
      company_name: recordValue(row, "company_name"),
      contact_person: recordValue(row, "contact_person"),
      email: recordValue(row, "email"),
      inquiry_type: recordValue(row, "inquiry_type"),
      status: status as BusinessInquiryStatus,
      offer_interest: recordValue(row, "offer_interest") || "not_specified",
      status_changed_at: recordValue(row, "status_changed_at"),
      source_page: recordValue(row, "source_page"),
      created_at: createdAt
    });
  });

  return { rows, issues };
}

export function adaptBusinessInquiryExportRows(input: unknown[]): {
  rows: BusinessInquiryExportRow[];
  issues: BusinessInquiryIntegrityIssue[];
} {
  const rows: BusinessInquiryExportRow[] = [];
  const issues: BusinessInquiryIntegrityIssue[] = [];
  input.forEach((candidate, rowIndex) => {
    if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
      issues.push({ rowIndex, missingFields: [...requiredTextFields, "status"] });
      return;
    }
    const row = candidate as Record<string, unknown>;
    const missingFields: string[] = requiredTextFields.filter((key) => !recordValue(row, key));
    const status = recordValue(row, "status");
    if (!isBusinessInquiryStatus(status)) missingFields.push("status");
    for (const dateField of ["created_at", "status_changed_at", "won_evidence_at"] as const) {
      const value = recordValue(row, dateField);
      if ((dateField === "created_at" || value) && Number.isNaN(Date.parse(value))) missingFields.push(dateField);
    }
    if (missingFields.length > 0) {
      issues.push({ rowIndex, missingFields: [...new Set(missingFields)] });
      return;
    }
    rows.push({
      ...row,
      id: recordValue(row, "id"),
      reference_code: recordValue(row, "reference_code"),
      company_name: recordValue(row, "company_name"),
      contact_person: recordValue(row, "contact_person"),
      email: recordValue(row, "email"),
      inquiry_type: recordValue(row, "inquiry_type"),
      status: status as BusinessInquiryStatus,
      created_at: recordValue(row, "created_at")
    });
  });
  return { rows, issues };
}

export function adaptBusinessInquiryDetailRow(input: unknown): {
  row: BusinessInquiryDetailRow | null;
  issue: BusinessInquiryDetailIntegrityIssue | null;
} {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    return {
      row: null,
      issue: { missingFields: ["id", "reference_code", "company_name", "status"] }
    };
  }

  const candidate = input as Record<string, unknown>;
  const missingFields = ["id", "reference_code", "company_name"]
    .filter((key) => !recordValue(candidate, key));
  const status = recordValue(candidate, "status");
  if (!isBusinessInquiryStatus(status)) missingFields.push("status");
  if (missingFields.length > 0) {
    return { row: null, issue: { missingFields: [...new Set(missingFields)] } };
  }

  return {
    row: {
      ...candidate,
      id: recordValue(candidate, "id"),
      reference_code: recordValue(candidate, "reference_code"),
      company_name: recordValue(candidate, "company_name"),
      status: status as BusinessInquiryStatus
    },
    issue: null
  };
}
