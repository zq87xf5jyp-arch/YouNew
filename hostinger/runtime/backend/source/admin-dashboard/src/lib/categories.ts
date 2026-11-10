export const categoryStatuses = {
  draft: "Черновик", research: "Исследование", review: "На проверке", qa: "QA",
  published: "Опубликовано", needs_review: "Требует проверки", archived: "Архив"
} as const;
export type CategoryStatus = keyof typeof categoryStatuses;
export type CategoryRow = {
  id: string; title: string; slug: string; short_description: string | null;
  icon: string | null; color: string | null; priority: number; status: CategoryStatus;
  tags: string[]; author_id: string | null; canonical_category_id: string | null;
  created_at: string; updated_at: string; published_at: string | null;
};
export type CategoryFields = Pick<CategoryRow, "title" | "short_description" | "icon" | "color" | "priority" | "status">;
export type CategoryResult = { ok: true; row: CategoryRow; replayed?: boolean } | { ok: false; message: string };
export const categoryColumns = "id,title,slug,short_description,icon,color,priority,status,tags,author_id,canonical_category_id,created_at,updated_at,published_at";
export const categoryUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export function validCategoryDate(value: unknown): value is string {
  return typeof value === "string" && value.length <= 64 && /^\d{4}-\d{2}-\d{2}T/.test(value) && Number.isFinite(Date.parse(value));
}
export function categoryFields(form: FormData): CategoryFields | null {
  const title = form.get("title"), description = form.get("short_description"), icon = form.get("icon"), color = form.get("color"), priority = form.get("priority"), status = form.get("status");
  if (typeof title !== "string" || !title.trim() || title.trim().length > 160 || typeof description !== "string" || description.length > 1000 || typeof icon !== "string" || (icon.trim() && !/^[A-Za-z][A-Za-z0-9_-]{0,63}$/.test(icon.trim())) || typeof color !== "string" || (color.trim() && !/^#[0-9a-f]{6}$/i.test(color.trim())) || typeof priority !== "string" || !/^\d{1,5}$/.test(priority) || Number(priority) > 10000 || typeof status !== "string" || !Object.hasOwn(categoryStatuses, status)) return null;
  return { title: title.trim(), short_description: description.trim() || null, icon: icon.trim() || null, color: color.trim() || null, priority: Number(priority), status: status as CategoryStatus };
}
export function validCategoryRow(value: unknown): value is CategoryRow {
  if (!value || typeof value !== "object") return false;
  const row = value as CategoryRow;
  return typeof row.id === "string" && categoryUuid.test(row.id) && typeof row.slug === "string" && typeof row.title === "string" && typeof row.status === "string" && Object.hasOwn(categoryStatuses, row.status) && Number.isInteger(row.priority) && [row.short_description, row.icon, row.color].every(v => v === null || typeof v === "string") && Array.isArray(row.tags) && row.tags.every(v => typeof v === "string") && [row.author_id, row.canonical_category_id].every(v => v === null || (typeof v === "string" && categoryUuid.test(v))) && validCategoryDate(row.created_at) && validCategoryDate(row.updated_at) && (row.published_at === null || validCategoryDate(row.published_at));
}
export function categoryFieldsMatch(row: CategoryRow, fields: CategoryFields) {
  return (Object.keys(fields) as Array<keyof CategoryFields>).every(key => row[key] === fields[key]);
}
