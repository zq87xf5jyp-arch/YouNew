import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { canonicalCategories, canonicalMap } from "@/lib/canonical-admin-data";
import { PageHeader } from "@/components/admin/page-header";
import { CategoryManager } from "@/components/admin/category-manager";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { categoryColumns, validCategoryRow, type CategoryRow } from "@/lib/categories";

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function CategoriesPage() {
  const admin = await requireAdmin();
  const packagedRows = canonicalCategories();
  let rows: CategoryRow[] = [], available = false;
  try {
    const supabase = await createSupabaseServerClient();
    if (supabase) {
      const result = await supabase.from("categories").select(categoryColumns).order("priority", { ascending: true }).order("id", { ascending: true }).limit(100).abortSignal(AbortSignal.timeout(8000));
      if (!result.error && Array.isArray(result.data) && result.data.every(validCategoryRow)) { rows = result.data; available = true; }
    }
  } catch { /* A missing source is unknown, never an empty-success list. */ }
  return <>
    <PageHeader title="Категории" description="Категории базы Admin: название, описание, порядок, иконка, цвет и статус. Слаг и канонические связи существующей записи сохраняются." />
    <CategoryManager rows={rows} available={available} canEdit={canEditContent(admin.role)} canPublish={canPublishContent(admin.role)} userId={admin.id} />
    <section className="mt-8 space-y-4">
      <h2 className="text-xl font-semibold">Опубликованный packaged dataset — отдельно от базы Admin</h2>
      <ReadOnlySource state={packagedRows.length ? "data" : "empty"} label="packaged public content" detail={`Dataset ${canonicalMap.source.contentDatasetFingerprint}; ${packagedRows.length} published category rows. This projection is not changed by the Admin database editor.`} />
      <CrudTable title="Категории публичного контента" description="Только просмотр канонического packaged dataset. Пустые категории остаются видимыми как опубликованная навигационная таксономия." rows={packagedRows} columns={["priority", "title", "slug", "entity_count", "source_id", "status"]} />
    </section>
  </>;
}
