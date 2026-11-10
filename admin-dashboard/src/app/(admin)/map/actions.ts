"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { mapPointColumns, mapPointFields, mapPointFieldsMatch, mapPointUuid, validMapPointDate, validMapPointRow, type MapPointFields, type MapPointResult, type MapPointRow } from "@/lib/map-points";

const unknown = (): MapPointResult => ({ ok: false, message: "Сохранение не подтверждено. Результат неизвестен; перечитайте список. При создании повторите запрос с тем же ID и исходными данными. Черновик оставлен в форме." });
const conflict = (): MapPointResult => ({ ok: false, message: "Запись изменилась или ID занят другими данными. Черновик оставлен в форме: скопируйте его и перечитайте список." });
function createdRowMatches(row: unknown, id: string, fields: MapPointFields): row is MapPointRow {
  return validMapPointRow(row) && row.id === id && mapPointFieldsMatch(row, fields);
}
function invalidate() { revalidatePath("/map"); revalidatePath("/api/public/map-points"); }

export async function createMapPoint(form: FormData): Promise<MapPointResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для создания точки." };
  const id = form.get("id"), fields = mapPointFields(form);
  if (typeof id !== "string" || !mapPointUuid.test(id) || !fields || fields.status !== "draft") return { ok: false, message: "Проверьте поля и ID. Новая точка создаётся только как черновик. Координаты: широта −90…90, долгота −180…180, не более 6 знаков после точки." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return unknown();
  try {
    const read = () => supabase.from("map_points").select(mapPointColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    const prior = await read();
    if (prior.error) return unknown();
    if (prior.data) {
      if (!createdRowMatches(prior.data, id, fields)) return conflict();
      invalidate(); return { ok: true, row: prior.data, replayed: true };
    }
    const result = await supabase.from("map_points").insert({ id, ...fields }).select(mapPointColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (!result.error && createdRowMatches(result.data, id, fields)) { invalidate(); return { ok: true, row: result.data }; }
    // An uncertain reply can follow a committed INSERT. Recover only this exact
    // UUID and every submitted field; equal titles/coordinates are not identity.
    const recovered = await read();
    if (recovered.error) return unknown();
    if (recovered.data) {
      if (!createdRowMatches(recovered.data, id, fields)) return conflict();
      invalidate(); return { ok: true, row: recovered.data, replayed: true };
    }
    return unknown();
  } catch { return unknown(); }
}

export async function updateMapPoint(form: FormData): Promise<MapPointResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для изменения точки." };
  const id = form.get("id"), version = form.get("updated_at"), fields = mapPointFields(form);
  if (typeof id !== "string" || !mapPointUuid.test(id) || !validMapPointDate(version) || !fields) return { ok: false, message: "Проверьте поля, координаты и версию точки. Изменения не отправлены." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return unknown();
  try {
    const before = await supabase.from("map_points").select(mapPointColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (before.error) return unknown();
    if (!validMapPointRow(before.data) || before.data.id !== id || before.data.updated_at !== version) return conflict();
    const row = before.data;
    if ((row.status === "published" || fields.status === "published") && !canPublishContent(admin.role)) return { ok: false, message: "Публикация и изменение опубликованной точки доступны только Owner/Admin. Editor может изменять непубличные записи." };
    const result = await supabase.from("map_points").update(fields).eq("id", id).eq("updated_at", version).select(mapPointColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (result.error) return unknown();
    if (!result.data) return conflict();
    const saved = result.data;
    if (!validMapPointRow(saved) || saved.id !== id || !mapPointFieldsMatch(saved, fields) || saved.created_at !== row.created_at || saved.updated_at === version) return unknown();
    invalidate(); return { ok: true, row: saved };
  } catch { return unknown(); }
}
