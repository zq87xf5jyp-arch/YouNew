import { buildPublishedContentArtifact, fingerprintArtifact, type PublishedArticleRecord } from "./artifact.ts";

type Row = Record<string, unknown>;
type Result = { data: unknown; error: { message?: string; code?: string; status?: number } | null };
type Query = PromiseLike<Result> & { select(fields: string): Query; eq(field: string, value: unknown): Query; order(field: string): Query; limit(count: number): Query; maybeSingle(): Query };
export type SyncClient = { auth: { getUser(): Promise<{ data: { user: { id: string } | null }; error: { status?: number } | null }> }; from(table: string): Query; rpc(name: string, args: Row): PromiseLike<Result> };
type Dependencies = { userClient(authorization: string, signal: AbortSignal): SyncClient; serviceClient(signal: AbortSignal): SyncClient; sleep?: (ms: number, signal: AbortSignal) => Promise<void>; deadlineMs?: number };
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const hash = /^[a-f0-9]{64}$/;
const statuses = new Set(["queued", "running", "succeeded", "failed", "cancelled"]);
const object = (value: unknown): Row | null => value !== null && typeof value === "object" && !Array.isArray(value) ? value as Row : null;
function json(status: number, data: Row) { return Response.json(data, { status, headers: { "Cache-Control": "no-store", "X-Content-Type-Options": "nosniff" } }); }
function receipt(value: unknown, id: string): Row | null {
  const row = object(value);
  if (!row || row.id !== id || typeof row.status !== "string" || !statuses.has(row.status) || row.activation !== "manual" || row.productionReplacementAllowed !== false) return null;
  if (row.status === "succeeded" && (typeof row.fingerprint !== "string" || !hash.test(row.fingerprint) || !Number.isSafeInteger(row.recordCount) || Number(row.recordCount) < 0)) return null;
  return row;
}
function sendReceipt(row: Row) { return json(row.status === "succeeded" ? 200 : 202, { jobId: row.id, status: row.status, receipt: row, activation: "manual", durable: true }); }
function safeRows(value: unknown): value is PublishedArticleRecord[] {
  if (!Array.isArray(value) || value.length > 500) return false;
  const ids = new Set<string>(), slugs = new Set<string>();
  return value.every((v) => {
    const x = object(v);
    if (!x || typeof x.id !== "string" || !uuid.test(x.id) || ids.has(x.id) || typeof x.slug !== "string" || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(x.slug) || x.slug.length > 180 || slugs.has(x.slug)) return false;
    ids.add(x.id); slugs.add(x.slug);
    if (typeof x.title !== "string" || !x.title.trim() || x.title.length > 240 || !["en", "nl", "ru", "uk", "pl"].includes(String(x.language))) return false;
    for (const [field, max] of [["short_description", 2000], ["full_content", 100000]] as const) if (x[field] !== null && (typeof x[field] !== "string" || x[field].length > max)) return false;
    for (const field of ["updated_at", "published_at", "verified_date"] as const) if (typeof x[field] !== "string" || !Number.isFinite(Date.parse(x[field]))) return false;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(String(x.verified_date))) return false;
    try { if (typeof x.source_url !== "string" || new URL(x.source_url).protocol !== "https:") return false; } catch { return false; }
    const category = Array.isArray(x.categories) ? object(x.categories[0]) : object(x.categories);
    const slug = category?.slug;
    return slug === undefined || slug === null || (typeof slug === "string" && /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) && slug.length <= 180);
  });
}
async function body(request: Request, signal: AbortSignal) {
  if (Number(request.headers.get("content-length") ?? 0) > 2048) throw new Error("body_limit");
  const reader = request.body?.getReader(); if (!reader) throw new Error("invalid_json");
  const chunks: Uint8Array[] = []; let bytes = 0, cancelled = false;
  const cancel = () => { cancelled = true; void reader.cancel(); };
  signal.addEventListener("abort", cancel, { once: true });
  try {
    if (signal.aborted) throw new Error("deadline");
    while (true) { const next = await reader.read(); if (cancelled) throw new Error("deadline"); if (next.done) break; bytes += next.value.length; if (bytes > 2048) { await reader.cancel(); throw new Error("body_limit"); } chunks.push(next.value); }
    const data = new Uint8Array(bytes); let offset = 0; for (const chunk of chunks) { data.set(chunk, offset); offset += chunk.length; }
    return JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(data));
  } finally { signal.removeEventListener("abort", cancel); reader.releaseLock(); }
}
const defaultSleep = (ms: number, signal: AbortSignal) => new Promise<void>((resolve, reject) => {
  const stop = () => { clearTimeout(timer); reject(new Error("deadline")); };
  const timer = setTimeout(() => { signal.removeEventListener("abort", stop); resolve(); }, ms);
  signal.addEventListener("abort", stop, { once: true }); if (signal.aborted) stop();
});

export function createSyncHandler(dependencies: Dependencies) {
  return async (request: Request): Promise<Response> => {
    if (request.method !== "POST") return json(405, { error: "method_not_allowed" });
    const authorization = request.headers.get("authorization");
    if (!authorization?.startsWith("Bearer ")) return json(401, { error: "unauthorized" });
    const signal = AbortSignal.timeout(Math.min(dependencies.deadlineMs ?? 40000, 40000));
    let value: unknown;
    try { value = await body(request, signal); } catch { return json(400, { error: "invalid_json_or_body_limit" }); }
    const jobId = object(value)?.jobId;
    if (typeof jobId !== "string" || !uuid.test(jobId)) return json(400, { error: "invalid_job" });
    const unknown = () => json(503, { error: "sync_result_unknown", jobId, durable: false });
    const user = dependencies.userClient(authorization, signal), service = dependencies.serviceClient(signal);
    let actorId: string;
    try {
      const auth = await user.auth.getUser();
      if (auth.error) return json(auth.error.status === 400 || auth.error.status === 401 || auth.error.status === 403 ? 401 : 503, { error: "authentication_unavailable_or_invalid" });
      if (!auth.data.user || !uuid.test(auth.data.user.id)) return json(401, { error: "unauthorized" });
      actorId = auth.data.user.id;
      const profile = await service.from("profiles").select("role,is_approved").eq("id", actorId).maybeSingle();
      if (profile.error) return json(503, { error: "authorization_source_unavailable" });
      const p = object(profile.data);
      if (p?.is_approved !== true || (p.role !== "owner" && p.role !== "admin")) return json(403, { error: "forbidden" });
    } catch { return unknown(); }
    async function read() {
      try { const result = await user.rpc("get_content_sync_request", { p_request_id: jobId }); return result.error ? null : receipt(result.data, jobId as string); } catch { return null; }
    }
    for (let invocationAttempt = 0; invocationAttempt < 3 && !signal.aborted; invocationAttempt++) {
      let claimed: Row | null;
      try {
        const result = await service.rpc("claim_content_sync_candidate", { p_job_id: jobId, p_actor_id: actorId });
        if (result.error) return result.error.code === "42501" ? json(403, { error: "forbidden" }) : result.error.code === "P0002" ? json(404, { error: "job_not_found" }) : unknown();
        claimed = object(result.data);
      } catch { return unknown(); }
      const current = receipt(claimed?.receipt, jobId);
      if (!claimed || !current) return unknown();
      if (claimed.claimed !== true) return sendReceipt(current);
      const token = claimed.leaseToken;
      if (typeof token !== "string" || !uuid.test(token)) return unknown();
      let failure = "source_read_failed", finalizationStarted = false;
      let fingerprint: string | null = null, count: number | null = null;
      try {
        const source = await service.from("articles").select("id,title,slug,short_description,full_content,language,source_url,verified_date,updated_at,published_at,category_id,categories(slug)").eq("status", "published").order("id").limit(501);
        if (source.error) throw new Error("source_read_failed");
        if (Array.isArray(source.data) && source.data.length > 500) { failure = "source_limit_exceeded"; throw new Error(failure); }
        if (!safeRows(source.data)) { failure = "source_invalid"; throw new Error(failure); }
        const artifact = buildPublishedContentArtifact(source.data), serialized = JSON.stringify(artifact);
        if (new TextEncoder().encode(serialized).length > 2097152) { failure = "source_limit_exceeded"; throw new Error(failure); }
        fingerprint = await fingerprintArtifact(artifact); count = artifact.recordCount;
        failure = "candidate_write_failed"; finalizationStarted = true;
        const result = await service.rpc("finalize_content_sync_candidate", { p_job_id: jobId, p_actor_id: actorId, p_lease_token: token, p_artifact_json: serialized, p_fingerprint: fingerprint });
        const saved = result.error ? null : receipt(result.data, jobId);
        if (saved?.status === "succeeded" && saved.fingerprint === fingerprint && saved.recordCount === count) return sendReceipt(saved);
        if (result.error?.message === "sync_artifact_conflict") failure = "sync_artifact_conflict";
        throw new Error(failure);
      } catch {
        if (finalizationStarted) {
          const recovered = await read();
          // Unknown commit -> no failure mutation; a read must settle it first.
          if (!recovered) return unknown();
          if (recovered.status === "succeeded") return recovered.fingerprint === fingerprint && recovered.recordCount === count ? sendReceipt(recovered) : unknown();
        }
        if (signal.aborted) return unknown();
        let failed: Row | null;
        try {
          const result = await service.rpc("fail_content_sync_candidate", { p_job_id: jobId, p_actor_id: actorId, p_lease_token: token, p_error_code: failure });
          failed = result.error ? await read() : receipt(result.data, jobId);
        } catch { failed = await read(); }
        if (!failed) return unknown();
        if (failed.status === "succeeded") return sendReceipt(failed);
        if (failed.status !== "failed" || failed.retryable !== true || invocationAttempt === 2) return sendReceipt(failed);
        const retryMs = failed.retryAfterMs;
        if (!Number.isSafeInteger(retryMs) || Number(retryMs) < 0 || Number(retryMs) > 3000) return sendReceipt(failed);
        try { await (dependencies.sleep ?? defaultSleep)(Number(retryMs) + 10, signal); } catch { return sendReceipt(failed); }
      }
    }
    return unknown();
  };
}
