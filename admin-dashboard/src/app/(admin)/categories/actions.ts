"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { categoryColumns, categoryFields, categoryFieldsMatch, categoryUuid, validCategoryDate, validCategoryRow, type CategoryFields, type CategoryResult, type CategoryRow } from "@/lib/categories";

const unknown = (): CategoryResult => ({ ok: false, message: "Сохранение не подтверждено. Результат неизвестен; перечитайте список. Для создания повторите запрос с тем же ID и данными. Черновик оставлен в форме." });
const conflict = (): CategoryResult => ({ ok: false, message: "Запись изменилась или ID занят другими данными. Черновик оставлен в форме: скопируйте его и обновите список." });
function createdRowMatches(row: unknown, id: string, slug: string, fields: CategoryFields, author: string): row is CategoryRow {
  return validCategoryRow(row) && row.id === id && row.slug === slug && row.author_id === author && row.canonical_category_id === null && row.tags.length === 0 && row.published_at === null && categoryFieldsMatch(row, fields);
}
function invalidate() {
  revalidatePath("/categories");
  revalidatePath("/api/public/categories");
}

export async function createCategory(form: FormData): Promise<CategoryResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для создания категории." };
  const id = form.get("id"), slug = form.get("slug"), fields = categoryFields(form);
  if (typeof id !== "string" || !categoryUuid.test(id) || typeof slug !== "string" || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) || slug.length > 80 || !fields || fields.status !== "draft") return { ok: false, message: "Проверьте поля и ID. Новая категория создаётся только как черновик; слаг — до 80 строчных латинских букв, цифр и дефисов." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return unknown();
  try {
    const read = () => supabase.from("categories").select(categoryColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    const prior = await read();
    if (prior.error) return unknown();
    if (prior.data) return createdRowMatches(prior.data, id, slug, fields, admin.id) ? { ok: true, row: prior.data, replayed: true } : conflict();
    const result = await supabase.from("categories").insert({ id, slug, ...fields, author_id: admin.id, tags: [], canonical_category_id: null, published_at: null }).select(categoryColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (!result.error && createdRowMatches(result.data, id, slug, fields, admin.id)) {
      invalidate(); return { ok: true, row: result.data };
    }
    // A timeout may follow a committed INSERT. Recover only this exact ID and
    // metadata, never create a new ID or treat a slug collision as our success.
    const recovered = await read();
    if (recovered.error) return unknown();
    if (recovered.data) {
      if (!createdRowMatches(recovered.data, id, slug, fields, admin.id)) return conflict();
      invalidate(); return { ok: true, row: recovered.data, replayed: true };
    }
    if (result.error?.code === "23505") return { ok: false, message: "Этот слаг уже существует. Выберите другой слаг или найдите существующую категорию; новая запись не подтверждена." };
    return unknown();
  } catch { return unknown(); }
}

export async function updateCategory(form: FormData): Promise<CategoryResult> {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) return { ok: false, message: "Недостаточно прав для изменения категории." };
  const id = form.get("id"), version = form.get("updated_at"), fields = categoryFields(form);
  if (typeof id !== "string" || !categoryUuid.test(id) || !validCategoryDate(version) || !fields) return { ok: false, message: "Проверьте поля и версию категории. Изменения не отправлены." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return unknown();
  try {
    const before = await supabase.from("categories").select(categoryColumns).eq("id", id).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (before.error) return unknown();
    if (!validCategoryRow(before.data) || before.data.id !== id || before.data.updated_at !== version) return conflict();
    const row = before.data;
    if (row.canonical_category_id !== null && fields.status === "published") return { ok: false, message: "Эта запись — исторический псевдоним канонической категории. Публикация псевдонима запрещена; каноническая связь сохранена." };
    if ((row.status === "published" || fields.status === "published") && !canPublishContent(admin.role)) return { ok: false, message: "Публикация и изменение опубликованной категории доступны только Owner/Admin. Непубличный черновик может редактировать Editor." };
    const publishedAt = fields.status === "published" && row.status !== "published" ? new Date().toISOString() : row.published_at;
    const result = await supabase.from("categories").update({ ...fields, published_at: publishedAt }).eq("id", id).eq("updated_at", version).select(categoryColumns).abortSignal(AbortSignal.timeout(8000)).maybeSingle();
    if (result.error) return unknown();
    if (!result.data) return conflict();
    const saved = result.data;
    if (!validCategoryRow(saved)) return unknown();
    const publicationTimeMatches = saved.published_at === publishedAt || (saved.published_at !== null && publishedAt !== null && Date.parse(saved.published_at) === Date.parse(publishedAt));
    if (saved.id !== id || !categoryFieldsMatch(saved, fields) || saved.slug !== row.slug || saved.author_id !== row.author_id || saved.canonical_category_id !== row.canonical_category_id || JSON.stringify(saved.tags) !== JSON.stringify(row.tags) || saved.created_at !== row.created_at || !publicationTimeMatches || saved.updated_at === version) return unknown();
    invalidate(); return { ok: true, row: saved };
  } catch { return unknown(); }
}
