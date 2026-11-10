"use server";

import { revalidatePath } from "next/cache";
import { createHash } from "node:crypto";
import { requireAdmin } from "@/lib/auth";
import {
  canManageGovernancePolicy,
  type AdminRole
} from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canTrustAction, trustRequest, trustPayloadText, validTrustConfirmation, validTrustState, validReviewTask, type TrustAction, type TrustResult, type TrustState, type ReviewTask } from "@/lib/trust-workflow";

function requiredText(formData: FormData, key: string, maximum = 1000) {
  const value = String(formData.get(key) ?? "").trim();
  if (!value || value.length > maximum) throw new Error(`Invalid ${key}.`);
  return value;
}

function requiredInteger(formData: FormData, key: string) {
  const value = Number(formData.get(key));
  if (!Number.isSafeInteger(value) || value < 1) throw new Error(`Invalid ${key}.`);
  return value;
}

function optionalUUID(formData: FormData, key: string) {
  const value = String(formData.get(key) ?? "").trim();
  if (!value) return null;
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value)) {
    throw new Error(`Invalid ${key}.`);
  }
  return value;
}

async function governanceClient(
  allowed: (role: AdminRole) => boolean,
  message: string
) {
  const admin = await requireAdmin();
  if (!allowed(admin.role)) throw new Error(message);
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  return { admin, supabase };
}

function rpcError(error: { message: string; details?: string | null } | null) {
  if (error) throw new Error(error.details ? `${error.message}: ${error.details}` : error.message);
}

const unknown = (): TrustResult => ({ ok: false, kind: "unknown", message: "Подтверждение операции не получено. Результат неизвестен. Сохраните ID запроса и исходные поля; повторите тот же запрос или перечитайте данные. Черновик сохранён." });
function safeError(error: { code?: string; message?: string }): TrustResult {
  if (error.code === "42501") return { ok: false, kind: "forbidden", message: "У текущей роли нет права выполнить это действие." };
  if (error.code === "40001") return { ok: false, kind: "conflict", message: "Версия или исходные данные запроса изменились. Черновик сохранён; перечитайте данные. Не заменяйте ID неопределённой операции, пока не проверен её результат." };
  if (error.code === "22023" || error.code === "23514") return { ok: false, kind: "prerequisite", message: "Сервер отклонил действие: проверьте переход, официальность и свежесть источника, ручную проверку и роль. Необходимые условия не подтверждены." };
  if (error.code === "P0002") return { ok: false, kind: "conflict", message: "Запись или задача больше не найдена. Перечитайте данные; черновик оставлен." };
  return unknown();
}
async function performTrustAction(formData: FormData, action: TrustAction): Promise<TrustResult> {
  const admin = await requireAdmin();
  if (!canTrustAction(admin.role, action)) return { ok: false, kind: "forbidden", message: "Действие недоступно для вашей роли." };
  const request = trustRequest(formData, action, admin.id);
  if (!request) return { ok: false, kind: "invalid", message: "Проверьте ID запроса, исходную версию, переход и заметку (2–1000 символов). Изменения не отправлены." };
  if (!canTrustAction(admin.role, action, request.toState)) return { ok: false, kind: "forbidden", message: "Одобрение review доступно только Owner/Admin/QA." };
  try {
    const supabase = await createSupabaseServerClient();
    if (!supabase) return unknown();
    const response = await supabase.rpc("admin_trust_action", {
      p_action: request.action, p_request_id: request.requestId, p_record_key: request.recordKey,
      p_expected_version: request.expectedVersion, p_task_id: request.taskID,
      p_expected_state: request.expectedState, p_expected_updated_at: request.expectedUpdatedAt,
      p_to_state: request.toState, p_owner_id: request.ownerID, p_reason: request.reason
    }).abortSignal(AbortSignal.timeout(8000));
    if (response.error) return safeError(response.error);
    const fingerprint = createHash("sha256").update(trustPayloadText(request),"utf8").digest("hex");
    if (!validTrustConfirmation(response.data, request, admin.id, fingerprint)) return unknown();
    const { receipt, replayed } = response.data;
    // The receipt attests an operation at resultVersion. Later reads are current
    // observations and can show a newer version or be unavailable independently.
    let current: TrustState | null = null, task: ReviewTask | null = null, readbackAvailable = false;
    try {
      const [stateRead, taskRead] = await Promise.all([
        supabase.from("content_governance_effective").select("*").eq("id", receipt.governanceStateId).abortSignal(AbortSignal.timeout(8000)).maybeSingle(),
        request.taskID ? supabase.from("content_review_tasks").select("*").eq("id", request.taskID).abortSignal(AbortSignal.timeout(8000)).maybeSingle() : Promise.resolve({ data: null, error: null })
      ]);
      if (!stateRead.error && validTrustState(stateRead.data) && stateRead.data.id === receipt.governanceStateId && stateRead.data.record_key === request.recordKey && stateRead.data.version >= receipt.resultVersion
        && !taskRead.error && (request.taskID === null || validReviewTask(taskRead.data) && taskRead.data.id === request.taskID && taskRead.data.governance_state_id === receipt.governanceStateId)) {
        current = stateRead.data; task = taskRead.data; readbackAvailable = true;
      }
    } catch { /* A confirmed operation remains confirmed; current state is unknown. */ }
    try { revalidatePath("/trust"); } catch { /* Receipt remains valid if cache invalidation fails. */ }
    return { ok: true, receipt, replayed, current, task, readbackAvailable };
  } catch { return unknown(); }
}
export async function verifyContentNowAction(formData: FormData): Promise<TrustResult> { return performTrustAction(formData, "verify"); }
export async function approveContentPublicationAction(formData: FormData): Promise<TrustResult> { return performTrustAction(formData, "publish"); }
export async function transitionReviewTaskAction(formData: FormData): Promise<TrustResult> { return performTrustAction(formData, "transition"); }

export async function bulkGovernancePolicyAction(formData: FormData) {
  const { supabase } = await governanceClient(
    canManageGovernancePolicy,
    "Policy override доступен только Owner или Admin."
  );
  const recordKeys = requiredText(formData, "recordKeys", 4000)
    .split(/\r?\n|,/)
    .map((value) => value.trim())
    .filter(Boolean);
  if (recordKeys.length === 0 || recordKeys.length > 200) throw new Error("Invalid recordKeys.");
  const { error } = await supabase.rpc("set_governance_owner_and_interval", {
    p_record_keys: recordKeys,
    p_owner_id: optionalUUID(formData, "ownerID"),
    p_review_interval_days: requiredInteger(formData, "reviewIntervalDays"),
    p_reason: requiredText(formData, "reason", 1000)
  });
  rpcError(error);
  revalidatePath("/trust");
}
