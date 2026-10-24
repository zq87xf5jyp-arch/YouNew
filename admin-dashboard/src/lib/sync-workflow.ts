export const syncUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export type SyncStatus = "queued" | "running" | "succeeded" | "failed" | "cancelled";
export type SyncReceipt = {
  id: string; status: SyncStatus; createdAt: string; completedAt: string | null;
  fingerprint: string | null; recordCount: number; errorCode: string | null;
  attemptCount: number | null; attemptAt: string | null; leaseExpiresAt: string | null;
  nextRetryAt: string | null; retryAfterMs: number; retryable: boolean; executionKnown: boolean;
  activation: "manual"; productionReplacementAllowed: false;
};
export type SyncResult = { state: "confirmed"; message: string; receipt: SyncReceipt } | { state: "unknown" | "missing" | "forbidden" | "invalid"; message: string };
const object = (v: unknown): Record<string, unknown> | null => v !== null && typeof v === "object" && !Array.isArray(v) ? v as Record<string, unknown> : null;
const date = (v: unknown) => typeof v === "string" && Number.isFinite(Date.parse(v));
const count = (v: unknown): v is number => typeof v === "number" && Number.isSafeInteger(v) && v >= 0;
export function parseSyncReceipt(value: unknown, id: string): SyncReceipt | null {
  const v = object(value);
  if (!v || v.id !== id || !syncUuid.test(id) || !["queued", "running", "succeeded", "failed", "cancelled"].includes(String(v.status)) || !date(v.createdAt)) return null;
  for (const field of ["completedAt", "attemptAt", "leaseExpiresAt", "nextRetryAt"]) if (v[field] !== null && !date(v[field])) return null;
  if (v.fingerprint !== null && (typeof v.fingerprint !== "string" || !/^[a-f0-9]{64}$/.test(v.fingerprint))) return null;
  if (!count(v.recordCount) || (v.errorCode !== null && (typeof v.errorCode !== "string" || v.errorCode.length > 180))) return null;
  if (v.attemptCount !== null && (!count(v.attemptCount) || v.attemptCount > 3)) return null;
  if (!count(v.retryAfterMs) || typeof v.retryable !== "boolean" || typeof v.executionKnown !== "boolean" || v.activation !== "manual" || v.productionReplacementAllowed !== false) return null;
  if (v.status === "succeeded" && (v.fingerprint === null || v.completedAt === null)) return null;
  if (v.executionKnown && (v.attemptCount === null || v.attemptAt === null)) return null;
  return v as unknown as SyncReceipt;
}
export function canStartNextSync(receipt: SyncReceipt | null): boolean {
  return receipt !== null && (receipt.status === "succeeded" || receipt.status === "cancelled" || (receipt.status === "failed" && !receipt.retryable));
}
export function syncStorageKey(userId: string) { return `younew.admin.sync.request.v1:${userId}`; }
export function parseStoredSyncId(value: string | null): string | null {
  if (!value) return null;
  try { const v = object(JSON.parse(value)); return v?.version === 1 && typeof v.id === "string" && syncUuid.test(v.id) ? v.id : null; } catch { return null; }
}
export function formatSyncTime(value: string | null) {
  if (!value || !date(value)) return "неизвестно";
  return new Intl.DateTimeFormat("ru-RU", { dateStyle: "short", timeStyle: "medium", timeZone: "Europe/Amsterdam" }).format(new Date(value));
}
