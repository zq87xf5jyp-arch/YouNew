import type { AdminRole } from "@/lib/authorization";

export const trustUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export const reviewStates = ["needs_review", "assigned", "in_review", "approved", "monitoring", "expired", "closed"] as const;
export type ReviewState = typeof reviewStates[number];
export type TrustAction = "transition" | "verify" | "publish";
export type TrustState = {
  id: string; record_key: string; title: string; version: number; updated_at: string;
  review_state: ReviewState; publication_status: string; verification_status: string;
  official_source_url: string | null; source_is_official: boolean; source_opened_at: string | null;
  last_verified_at: string | null; next_review_at: string | null; review_interval_days: number;
  effective_verification_status?: string; effective_confidence_score?: number;
  content_owner_id?: string | null;
};
export type ReviewTask = { id: string; governance_state_id: string; owner_id: string | null; reason: string; severity: string; state: ReviewState; sla_due_at: string; updated_at: string; resolved_at: string | null };
export type TrustRequest = { action: TrustAction; requestId: string; recordKey: string; expectedVersion: number; taskID: string | null; expectedState: ReviewState | null; expectedUpdatedAt: string | null; toState: ReviewState | null; ownerID: string | null; reason: string };
export type TrustReceipt = { id: string; actorId: string; action: TrustAction; requestId: string; recordKey: string; governanceStateId: string; requestFingerprint: string; resultVersion: number; confirmedAt: string };
export type TrustResult = { ok: false; kind: "invalid" | "forbidden" | "conflict" | "prerequisite" | "unknown"; message: string } | { ok: true; receipt: TrustReceipt; replayed: boolean; current: TrustState | null; task: ReviewTask | null; readbackAvailable: boolean };
export function trustTimestamp(value: unknown): value is string {
  return typeof value === "string" && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})$/.test(value) && Number.isFinite(Date.parse(value));
}
export function trustTimeKey(value: string): string {
  const fraction = (value.match(/\.(\d+)/)?.[1] ?? "").padEnd(6,"0");
  return `${Math.floor(Date.parse(value) / 1000)}:${fraction}`;
}
export function sameTrustTime(a: string, b: string) { return trustTimestamp(a) && trustTimestamp(b) && trustTimeKey(a) === trustTimeKey(b); }
function record(value: unknown): value is Record<string, unknown> { return value !== null && typeof value === "object" && !Array.isArray(value); }
export function validTrustState(value: unknown): value is TrustState {
  if (!record(value)) return false;
  return typeof value.id === "string" && trustUuid.test(value.id) && typeof value.record_key === "string" && value.record_key.length > 0 && value.record_key.length <= 240 && typeof value.title === "string"
    && Number.isSafeInteger(value.version) && Number(value.version) > 0 && trustTimestamp(value.updated_at) && reviewStates.includes(value.review_state as ReviewState)
    && ["draft","qa","published","archived"].includes(String(value.publication_status)) && ["unverified","verified","review_due_soon","overdue","source_unavailable","disputed","archived"].includes(String(value.verification_status))
    && (value.official_source_url === null || typeof value.official_source_url === "string") && typeof value.source_is_official === "boolean"
    && ["source_opened_at","last_verified_at","next_review_at"].every(key => value[key] === null || trustTimestamp(value[key]))
    && Number.isSafeInteger(value.review_interval_days) && Number(value.review_interval_days) > 0;
}
export function validReviewTask(value: unknown): value is ReviewTask {
  if (!record(value)) return false;
  return typeof value.id === "string" && trustUuid.test(value.id) && typeof value.governance_state_id === "string" && trustUuid.test(value.governance_state_id)
    && (value.owner_id === null || (typeof value.owner_id === "string" && trustUuid.test(value.owner_id))) && typeof value.reason === "string" && typeof value.severity === "string"
    && reviewStates.includes(value.state as ReviewState) && trustTimestamp(value.sla_due_at) && trustTimestamp(value.updated_at) && (value.resolved_at === null || trustTimestamp(value.resolved_at));
}
export function nextTrustTransition(state: ReviewState): { state: ReviewState; label: string } | null {
  if (state === "needs_review") return { state: "assigned", label: "Назначить себе" };
  if (state === "assigned") return { state: "in_review", label: "Начать проверку" };
  if (state === "in_review") return { state: "approved", label: "Одобрить review" };
  if (state === "monitoring") return { state: "expired", label: "Отметить истечение" };
  if (state === "expired") return { state: "needs_review", label: "Вернуть в очередь" };
  return null;
}
export function canTrustAction(role: AdminRole, action: TrustAction, toState: ReviewState | null = null) {
  if (action === "publish") return role === "owner" || role === "admin";
  if (action === "verify" || toState === "approved") return ["owner","admin","qa"].includes(role);
  return ["owner","admin","qa","editor"].includes(role);
}
export function sourcePrerequisite(state: TrustState, now: number) {
  const opened = state.source_opened_at === null ? NaN : Date.parse(state.source_opened_at);
  return state.source_is_official && state.official_source_url !== null && Number.isFinite(opened) && opened <= now && opened >= now - 7 * 86400000;
}
export function safeOfficialUrl(value: string | null): string | null {
  try { const url = new URL(value ?? ""); return ["http:","https:"].includes(url.protocol) && !url.username && !url.password ? url.href : null; } catch { return null; }
}
export function trustRequest(form: FormData, action: TrustAction, actor: string): TrustRequest | null {
  const text = (key: string) => { const v = form.get(key); return typeof v === "string" ? v.trim() : null; };
  const requestId = text("idempotencyKey"), recordKey = text("recordKey"), version = text("expectedVersion"), reason = text("reason");
  if (!requestId || !trustUuid.test(requestId) || !recordKey || recordKey.length > 240 || !version || !/^[1-9]\d*$/.test(version) || !Number.isSafeInteger(Number(version)) || Number(version) >= 2147483647 || !reason || reason.length < 2 || reason.length > 1000) return null;
  const result: TrustRequest = { action, requestId: requestId.toLowerCase(), recordKey, expectedVersion: Number(version), taskID: null, expectedState: null, expectedUpdatedAt: null, toState: null, ownerID: null, reason };
  if (action === "transition") {
    const taskID = text("taskID"), expectedState = text("expectedState") as ReviewState | null, toState = text("toState") as ReviewState | null, updated = text("expectedUpdatedAt"), suppliedOwner = text("ownerID");
    if (!taskID || !trustUuid.test(taskID) || !expectedState || !toState || nextTrustTransition(expectedState)?.state !== toState || !trustTimestamp(updated)) return null;
    const ownerID = suppliedOwner || (toState === "assigned" ? actor : null);
    if (ownerID !== null && !trustUuid.test(ownerID)) return null;
    Object.assign(result, { taskID: taskID.toLowerCase(), expectedState, expectedUpdatedAt: updated, toState, ownerID: ownerID?.toLowerCase() ?? null });
  }
  return result;
}
export function trustPayloadText(request: TrustRequest) {
  const stamp = request.expectedUpdatedAt === null ? null : new Date(Math.floor(Date.parse(request.expectedUpdatedAt) / 1000) * 1000).toISOString().slice(0,19) + "." + (request.expectedUpdatedAt.match(/\.(\d+)/)?.[1] ?? "").padEnd(6,"0") + "Z";
  // PostgreSQL jsonb array text uses comma+space; primitive JSON serialization
  // preserves Unicode and escapes control characters without interpreting them.
  return "[" + [request.action,request.recordKey,request.expectedVersion,request.taskID,request.expectedState,stamp,request.toState,request.ownerID,request.reason].map(value => JSON.stringify(value)).join(", ") + "]";
}
export function trustRequestForm(request: TrustRequest) {
  const form = new FormData();
  for (const [key,value] of Object.entries({ recordKey: request.recordKey, expectedVersion: String(request.expectedVersion), idempotencyKey: request.requestId, taskID: request.taskID ?? "", expectedState: request.expectedState ?? "", expectedUpdatedAt: request.expectedUpdatedAt ?? "", toState: request.toState ?? "", ownerID: request.ownerID ?? "", reason: request.reason })) form.set(key,value);
  return form;
}
export function restoredTrustIntent(raw: string | null, actor: string, recordKey: string, taskID: string | null): TrustRequest | null {
  if (!raw || raw.length > 6000) return null;
  try {
    const saved: unknown = JSON.parse(raw);
    if (!record(saved) || saved.actor !== actor || !record(saved.request) || typeof saved.request.action !== "string" || !["verify","publish","transition"].includes(saved.request.action)) return null;
    const supplied = saved.request as unknown as TrustRequest;
    if (supplied.recordKey !== recordKey || supplied.taskID !== taskID || (taskID !== null) !== (supplied.action === "transition")) return null;
    const parsed = trustRequest(trustRequestForm(supplied),supplied.action,actor);
    return parsed && Object.keys(parsed).every(key => parsed[key as keyof TrustRequest] === supplied[key as keyof TrustRequest]) ? parsed : null;
  } catch { return null; }
}
export function restoredTrustDraft(raw: string | null, actor: string): { state: TrustState; task: ReviewTask | null } | null {
  if (!raw || raw.length > 6000) return null;
  try {
    const saved: unknown = JSON.parse(raw);
    if (!record(saved) || saved.actor !== actor || !record(saved.observation) || !validTrustState(saved.observation.state)) return null;
    const { state, task } = saved.observation;
    if (task !== null && (!validReviewTask(task) || task.governance_state_id !== state.id)) return null;
    return restoredTrustIntent(raw,actor,state.record_key,task?.id ?? null) ? { state, task: task as ReviewTask | null } : null;
  } catch { return null; }
}
export function validTrustConfirmation(value: unknown, request: TrustRequest, actor: string, expectedFingerprint: string): value is { receipt: TrustReceipt; replayed: boolean; current: { state: TrustState; task: ReviewTask | null } } {
  if (!record(value) || !record(value.receipt) || !record(value.current)) return false;
  const r = value.receipt, s = value.current.state, t = value.current.task;
  return typeof r.id === "string" && trustUuid.test(r.id) && r.actorId === actor && r.action === request.action && r.requestId === request.requestId && r.recordKey === request.recordKey
    && typeof r.governanceStateId === "string" && trustUuid.test(r.governanceStateId) && typeof r.requestFingerprint === "string" && /^[0-9a-f]{64}$/.test(r.requestFingerprint) && r.requestFingerprint === expectedFingerprint
    && r.resultVersion === request.expectedVersion + 1 && trustTimestamp(r.confirmedAt) && typeof value.replayed === "boolean"
    && validTrustState(s) && s.id === r.governanceStateId && s.record_key === request.recordKey && s.version >= Number(r.resultVersion)
    && (request.taskID === null ? t === null : validReviewTask(t) && t.id === request.taskID && t.governance_state_id === s.id);
}
