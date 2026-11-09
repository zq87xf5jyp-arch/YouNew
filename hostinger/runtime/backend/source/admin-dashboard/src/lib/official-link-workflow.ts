export type OfficialLinkStatus = "active" | "broken" | "needs review";
export type OfficialLinkRow = {
  id: string;
  title: string;
  url: string;
  source_type: string;
  status: OfficialLinkStatus;
  last_checked_date: string | null;
  notes: string | null;
  updated_at: string;
};

export type OfficialLinkCheck = {
  outcome: "reachable" | "broken" | "unknown";
  httpStatus: number | null;
  finalURL: string | null;
  checkedAt: string;
  attempts: number;
  errorCode: string | null;
};

export type OfficialLinkActionResult =
  | { ok: true; row: OfficialLinkRow; check: OfficialLinkCheck }
  | { ok: false; message: string };

export const MAX_LINK_NOTES_LENGTH = 20000;
export const MAX_EXISTING_LINK_NOTES_LENGTH = 14000;
export const canCheckOfficialLink = (role: string) => role === "owner" || role === "admin";
export const canReadOfficialLinks = (role: string) => ["owner", "admin", "editor"].includes(role);
export const validLinkVersion = (value: unknown): value is string => typeof value === "string"
  && value.length <= 64 && /T.*(?:Z|[+-]\d{2}:\d{2})$/.test(value) && Number.isFinite(Date.parse(value));

export function officialLinkStatus(check: OfficialLinkCheck): OfficialLinkStatus {
  return check.outcome === "reachable" ? "active" : check.outcome === "broken" ? "broken" : "needs review";
}

export function officialLinkCheckLabel(check: OfficialLinkCheck) {
  if (check.outcome === "reachable") return `Получен HTTP ${check.httpStatus}. Доступность URL подтверждена на время проверки.`;
  if (check.outcome === "broken") return `GET вернул HTTP ${check.httpStatus}. Ссылка отмечена как недоступная.`;
  return `Доступность не установлена${check.httpStatus ? ` (HTTP ${check.httpStatus})` : ""}. Требуется проверка.`;
}
