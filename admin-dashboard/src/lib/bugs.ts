export const bugStatuses = { open: "Открыта", "in progress": "В работе", fixed: "Исправлена", verified: "Проверена", closed: "Закрыта" } as const;
export const bugSeverities = { low: "Низкая", medium: "Средняя", high: "Высокая", critical: "Критическая" } as const;
export const bugPriorities = { low: "Низкий", medium: "Средний", high: "Высокий", urgent: "Срочный" } as const;
export const bugPlatforms = ["iOS", "Android", "Web", "Backend", "Admin"] as const;
export type BugStatus = keyof typeof bugStatuses;
export type BugSeverity = keyof typeof bugSeverities;
export type BugPriority = keyof typeof bugPriorities;
export type BugPlatform = typeof bugPlatforms[number];
export const bugTextLimits = { title: 160, app_screen: 160, description: 4000, steps_to_reproduce: 4000, expected_result: 4000, actual_result: 4000 } as const;
export type BugFields = { title: string; description: string | null; severity: BugSeverity; priority: BugPriority; status: BugStatus; platform: BugPlatform; app_screen: string | null; steps_to_reproduce: string | null; expected_result: string | null; actual_result: string | null };
export type BugRow = BugFields & { id: string; linked_screenshot_id: string | null; assigned_to: string | null; created_by: string | null; created_at: string; updated_at: string };
export type BugResult = { ok: true; row: BugRow; replayed?: boolean } | { ok: false; message: string };
export const bugColumns = "id,title,description,severity,priority,status,platform,app_screen,linked_screenshot_id,steps_to_reproduce,expected_result,actual_result,assigned_to,created_by,created_at,updated_at";
export const bugUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export function canManageBugs(role: unknown) { return role === "owner" || role === "admin" || role === "qa"; }
// Retain PostgreSQL microseconds while normalizing equivalent UTC-offset spellings.
export function bugVersionKey(value: unknown): string | null {
  if (typeof value !== "string" || value.length > 64) return null;
  const match = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.(\d{1,6}))?(Z|[+-]\d{2}:\d{2})$/.exec(value);
  if (!match) return null;
  const millis = Date.parse(match[1] + match[3]);
  return Number.isFinite(millis) ? new Date(millis).toISOString().slice(0, 19) + "." + (match[2] ?? "").padEnd(6, "0") + "Z" : null;
}
export function sameBugVersion(a: unknown, b: unknown) { const key = bugVersionKey(a); return key !== null && key === bugVersionKey(b); }
export function bugFields(form: FormData): BugFields | null {
  const text: Record<string, string | null> = {};
  for (const [key, limit] of Object.entries(bugTextLimits)) {
    const value = form.get(key);
    if (typeof value !== "string" || value.length > limit) return null;
    text[key] = value.trim() || null;
  }
  const severity = form.get("severity"), priority = form.get("priority"), status = form.get("status"), platform = form.get("platform");
  if (!text.title || typeof severity !== "string" || !Object.hasOwn(bugSeverities, severity) || typeof priority !== "string" || !Object.hasOwn(bugPriorities, priority) || typeof status !== "string" || !Object.hasOwn(bugStatuses, status) || typeof platform !== "string" || !bugPlatforms.some(p => p === platform)) return null;
  return { title: text.title, description: text.description, app_screen: text.app_screen, steps_to_reproduce: text.steps_to_reproduce, expected_result: text.expected_result, actual_result: text.actual_result, severity: severity as BugSeverity, priority: priority as BugPriority, status: status as BugStatus, platform: platform as BugPlatform };
}
export function validBugRow(value: unknown): value is BugRow {
  if (!value || typeof value !== "object") return false;
  const row = value as BugRow;
  return typeof row.id === "string" && bugUuid.test(row.id) && typeof row.title === "string" && typeof row.severity === "string" && Object.hasOwn(bugSeverities, row.severity) && typeof row.priority === "string" && Object.hasOwn(bugPriorities, row.priority) && typeof row.status === "string" && Object.hasOwn(bugStatuses, row.status) && bugPlatforms.some(p => p === row.platform) && [row.description, row.app_screen, row.steps_to_reproduce, row.expected_result, row.actual_result].every(v => v === null || typeof v === "string") && [row.linked_screenshot_id, row.assigned_to, row.created_by].every(v => v === null || (typeof v === "string" && bugUuid.test(v))) && bugVersionKey(row.created_at) !== null && bugVersionKey(row.updated_at) !== null;
}
export function bugFieldsMatch(row: BugRow, fields: BugFields) { return (Object.keys(fields) as Array<keyof BugFields>).every(key => row[key] === fields[key]); }
export function bugReadErrorState(error: unknown): "forbidden" | "unavailable" { const code = error && typeof error === "object" && "code" in error ? String(error.code) : ""; return ["42501", "PGRST301", "PGRST302"].includes(code) ? "forbidden" : "unavailable"; }
