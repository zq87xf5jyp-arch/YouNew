"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { bugColumns, bugFields, bugFieldsMatch, bugUuid, bugVersionKey, canManageBugs, sameBugVersion, validBugRow, type BugFields, type BugResult, type BugRow } from "@/lib/bugs";

const unknown = (): BugResult => ({ ok: false, message: "Сохранение не подтверждено. Результат неизвестен; перечитайте список. При создании повторите запрос с тем же ID и исходными данными. Черновик оставлен в форме." });
const conflict = (): BugResult => ({ ok: false, message: "Запись изменилась или ID занят другими данными. Черновик оставлен в форме: скопируйте его и перечитайте список." });
function createdRowMatches(row: unknown, id: string, actor: string, fields: BugFields): row is BugRow {
  return validBugRow(row) && row.id === id && row.created_by === actor && row.assigned_to === null && row.linked_screenshot_id === null && bugFieldsMatch(row, fields);
}
function invalidate() { revalidatePath("/bugs"); revalidatePath("/dashboard"); }

export async function createBug(form: FormData): Promise<BugResult> {
  const admin = await requireAdmin();
  if (!canManageBugs(admin.role)) return { ok: false, message: "Создание ошибок доступно только Owner/Admin/QA." };
  const suppliedId = form.get("id"), fields = bugFields(form);
  if (typeof suppliedId !== "string" || !bugUuid.test(suppliedId) || !bugUuid.test(admin.id) || !fields || fields.status !== "open") return { ok: false, message: "Проверьте поля и ID. Новая ошибка создаётся со статусом «Открыта»." };
  const id = suppliedId.toLowerCase();
  try {
    const supabase = await createSupabaseServerClient();
    if (!supabase) return unknown();
    const read = () => supabase.from("bugs").select(bugColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    const prior = await read();
    if (prior.error) return unknown();
    if (prior.data) {
      if (!createdRowMatches(prior.data, id, admin.id, fields)) return conflict();
      invalidate(); return { ok: true, row: prior.data, replayed: true };
    }
    // A transport failure can follow a committed INSERT. Attempt only an exact
    // same-ID readback; never issue a second INSERT inside this request.
    try {
      const result = await supabase.from("bugs").insert({ id, ...fields, status: "open", created_by: admin.id, assigned_to: null, linked_screenshot_id: null }).select(bugColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
      if (!result.error && createdRowMatches(result.data, id, admin.id, fields)) { invalidate(); return { ok: true, row: result.data }; }
    } catch { /* Recover below without trusting a missing INSERT response. */ }
    const recovered = await read();
    if (recovered.error) return unknown();
    if (recovered.data) {
      if (!createdRowMatches(recovered.data, id, admin.id, fields)) return conflict();
      invalidate(); return { ok: true, row: recovered.data, replayed: true };
    }
    return unknown();
  } catch { return unknown(); }
}

export async function updateBug(form: FormData): Promise<BugResult> {
  const admin = await requireAdmin();
  if (!canManageBugs(admin.role)) return { ok: false, message: "Изменение ошибок доступно только Owner/Admin/QA." };
  const suppliedId = form.get("id"), version = form.get("updated_at"), fields = bugFields(form);
  if (typeof suppliedId !== "string" || !bugUuid.test(suppliedId) || !bugVersionKey(version) || !fields) return { ok: false, message: "Проверьте поля и версию ошибки. Изменения не отправлены." };
  const id = suppliedId.toLowerCase();
  try {
    const supabase = await createSupabaseServerClient();
    if (!supabase) return unknown();
    const before = await supabase.from("bugs").select(bugColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (before.error) return unknown();
    if (!validBugRow(before.data) || before.data.id !== id || !sameBugVersion(before.data.updated_at, version)) return conflict();
    const row = before.data;
    const result = await supabase.from("bugs").update(fields).eq("id", id).eq("updated_at", row.updated_at).select(bugColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (result.error) return unknown();
    if (!result.data) return conflict();
    const saved = result.data;
    if (!validBugRow(saved) || saved.id !== id || !bugFieldsMatch(saved, fields) || !sameBugVersion(saved.created_at, row.created_at) || saved.created_by !== row.created_by || saved.assigned_to !== row.assigned_to || saved.linked_screenshot_id !== row.linked_screenshot_id || sameBugVersion(saved.updated_at, row.updated_at)) return unknown();
    invalidate(); return { ok: true, row: saved };
  } catch { return unknown(); }
}
