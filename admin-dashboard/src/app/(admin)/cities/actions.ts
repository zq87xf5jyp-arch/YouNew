"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { cityColumns, cityDate, cityFields, cityFieldsMatch, cityUuid, validCityRow, type CityFields, type CityResult, type CityRow } from "@/lib/cities";

const unknown = (): CityResult => ({ ok: false, message: "Сохранение не подтверждено. Результат неизвестен; черновик сохранён в форме. Перечитайте список перед повтором. Для создания используйте тот же ID и поля." });
const conflict = (): CityResult => ({ ok: false, message: "Запись изменилась или ID занят другими данными. Черновик оставлен в форме: скопируйте его и обновите список." });
function createdMatch(row: unknown, id: string, slug: string, fields: CityFields): row is CityRow { return validCityRow(row) && row.id === id && row.slug === slug && row.published_at === null && row.cover_image_path === null && JSON.stringify(row.emergency_contacts) === "[]" && JSON.stringify(row.useful_official_links) === "[]" && cityFieldsMatch(row, fields); }
function invalidate() { revalidatePath("/cities"); revalidatePath("/api/public/cities"); }
export async function createCity(form: FormData): Promise<CityResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для создания города." };
  const id = form.get("id"), slug = form.get("slug"), fields = cityFields(form);
  if (typeof id !== "string" || !cityUuid.test(id) || typeof slug !== "string" || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) || slug.length > 80 || !fields || fields.status !== "draft") return { ok: false, message: "Проверьте поля. Новый город создаётся как черновик. Нужны корректные ID и слаг, провинция, пара координат или оба пустых поля, ссылка HTTPS без пароля." };
  const supabase = await createSupabaseServerClient(); if (!supabase) return unknown();
  try {
    const read = () => supabase.from("cities").select(cityColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    const prior = await read(); if (prior.error) return unknown();
    if (prior.data) return createdMatch(prior.data, id, slug, fields) ? { ok: true, row: prior.data, replayed: true } : conflict();
    const saved = await supabase.from("cities").insert({ id, slug, ...fields, emergency_contacts: [], useful_official_links: [], cover_image_path: null, published_at: null }).select(cityColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (!saved.error && createdMatch(saved.data, id, slug, fields)) { invalidate(); return { ok: true, row: saved.data }; }
    const recovered = await read(); if (recovered.error) return unknown();
    if (recovered.data) { if (!createdMatch(recovered.data, id, slug, fields)) return conflict(); invalidate(); return { ok: true, row: recovered.data, replayed: true }; }
    return saved.error?.code === "23505" ? { ok: false, message: "Слаг уже существует. Найдите существующий город или выберите другой слаг. Новая запись не подтверждена." } : unknown();
  } catch { return unknown(); }
}
export async function updateCity(form: FormData): Promise<CityResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для изменения города." };
  const id = form.get("id"), version = form.get("updated_at"), fields = cityFields(form);
  if (typeof id !== "string" || !cityUuid.test(id) || !cityDate(version) || !fields) return { ok: false, message: "Проверьте поля и версию города. Координаты вводятся парой (до 6 знаков после точки); ссылка должна использовать HTTPS без пароля." };
  const supabase = await createSupabaseServerClient(); if (!supabase) return unknown();
  try {
    const before = await supabase.from("cities").select(cityColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (before.error) return unknown(); if (!validCityRow(before.data) || before.data.id !== id || before.data.updated_at !== version) return conflict();
    const row = before.data;
    if ((row.status === "published" || fields.status === "published") && !canPublishContent(admin.role)) return { ok: false, message: "Публикация и изменение опубликованного города доступны только Owner/Admin." };
    const publishedAt = fields.status === "published" && row.status !== "published" ? new Date().toISOString() : row.published_at;
    const saved = await supabase.from("cities").update({ ...fields, published_at: publishedAt }).eq("id", id).eq("updated_at", version).select(cityColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (saved.error) return unknown(); if (!saved.data) return conflict();
    const result = saved.data;
    if (!validCityRow(result) || result.id !== id || result.slug !== row.slug || result.created_at !== row.created_at || result.updated_at === version || !cityFieldsMatch(result, fields) || result.cover_image_path !== row.cover_image_path || JSON.stringify(result.emergency_contacts) !== JSON.stringify(row.emergency_contacts) || JSON.stringify(result.useful_official_links) !== JSON.stringify(row.useful_official_links) || !(result.published_at === publishedAt || (result.published_at && publishedAt && Date.parse(result.published_at) === Date.parse(publishedAt)))) return unknown();
    invalidate(); return { ok: true, row: result };
  } catch { return unknown(); }
}
