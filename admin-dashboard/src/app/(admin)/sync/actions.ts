"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canRequestSync } from "@/lib/authorization";
import { parseSyncReceipt, syncUuid, type SyncResult } from "@/lib/sync-workflow";

const unknown = (): SyncResult => ({ state: "unknown", message: "Результат неизвестен: источник или ответ недоступен. ID сохранён. Проверьте или продолжите этот же запрос; новый пока не создавайте." });
const forbidden = (): SyncResult => ({ state: "forbidden", message: "Нужен подтверждённый вход и одобренная роль Owner/Admin. Запрос не запущен." });
async function deadline<T>(value: Promise<T>, ms: number): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try { return await Promise.race([value, new Promise<never>((_, reject) => { timer = setTimeout(() => reject(new Error("deadline")), ms); })]); }
  finally { if (timer) clearTimeout(timer); }
}
async function context() {
  const client = await createSupabaseServerClient();
  if (!client) return { ok: false as const, result: unknown() };
  const auth = await deadline(client.auth.getUser(), 5000);
  if (auth.error) return { ok: false as const, result: [400, 401, 403].includes(auth.error.status ?? 0) ? forbidden() : unknown() };
  if (!auth.data.user || !syncUuid.test(auth.data.user.id)) return { ok: false as const, result: forbidden() };
  const profile = await client.from("profiles").select("role,is_approved").eq("id", auth.data.user.id).abortSignal(AbortSignal.timeout(5000)).maybeSingle();
  if (profile.error) return { ok: false as const, result: unknown() };
  if (profile.data?.is_approved !== true || (profile.data.role !== "owner" && profile.data.role !== "admin") || !canRequestSync(profile.data.role)) return { ok: false as const, result: forbidden() };
  return { ok: true as const, client };
}
async function read(client: NonNullable<Awaited<ReturnType<typeof createSupabaseServerClient>>>, id: string): Promise<SyncResult> {
  const result = await client.rpc("get_content_sync_request", { p_request_id: id }).abortSignal(AbortSignal.timeout(5000));
  if (result.error) return result.error.code === "42501" ? forbidden() : unknown();
  if (result.data === null) return { state: "missing", message: "Для этого ID ваша задача пока не найдена. Продолжить можно с тем же ID; отсутствие в этом чтении не доказывает, что предыдущий запрос не завершится." };
  const receipt = parseSyncReceipt(result.data, id);
  if (!receipt) return unknown();
  return { state: "confirmed", receipt, message: receipt.status === "succeeded" ? "Подготовка подтверждена записью в базе. Это не публикация: активация остаётся отдельным ручным действием." : "Прочитано сохранённое состояние этой задачи. Новый запрос не создавался." };
}
function requestId(form: FormData): string | null { const id = form.get("request_id"); return typeof id === "string" && syncUuid.test(id) ? id : null; }
export async function readContentSync(form: FormData): Promise<SyncResult> {
  const id = requestId(form); if (!id) return { state: "invalid", message: "Некорректный ID. Запрос не отправлен." };
  try { const auth = await context(); return auth.ok ? await read(auth.client, id) : auth.result; } catch { return unknown(); }
}
export async function requestContentSync(form: FormData): Promise<SyncResult> {
  const id = requestId(form); if (!id) return { state: "invalid", message: "Некорректный ID. Запрос не отправлен." };
  try {
    const auth = await context(); if (!auth.ok) return auth.result;
    const { client } = auth;
    let accepted = false;
    try {
      const created = await client.rpc("request_content_sync", { p_request_id: id }).abortSignal(AbortSignal.timeout(5000));
      if (created.error?.code === "42501") return forbidden();
      if (created.error?.code === "23505") return { state: "invalid", message: "ID занят несовместимой задачей. Новая задача не создана; требуется проверка этого ID." };
      accepted = !created.error && created.data === id;
    } catch { /* Resolve an uncertain create response by this exact owned ID. */ }
    const prior = await read(client, id);
    if (prior.state !== "confirmed") return prior;
    accepted = true;
    if (prior.receipt.status === "succeeded" || prior.receipt.status === "cancelled" || (prior.receipt.status === "failed" && !prior.receipt.retryable)) return prior;
    if (accepted) {
      try { await client.functions.invoke("prepare-content-sync", { body: { jobId: id }, signal: AbortSignal.timeout(45000) }); }
      catch { /* A transport failure is not proof of failed execution. */ }
    }
    const verified = await read(client, id);
    if (verified.state === "confirmed") revalidatePath("/sync");
    return verified;
  } catch { return unknown(); }
}
