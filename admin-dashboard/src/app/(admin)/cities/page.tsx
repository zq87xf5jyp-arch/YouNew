import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { canonicalCities, canonicalMap } from "@/lib/canonical-admin-data";
import { CityManager } from "@/components/admin/city-manager";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { cityColumns, validCityRow, type CityRow } from "@/lib/cities";

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function CitiesPage() {
  const admin = await requireAdmin();
  const packagedRows = canonicalCities();
  let rows: CityRow[] = [], available = false;
  try {
    const supabase = await createSupabaseServerClient();
    if (supabase) {
      const result = await supabase.from("cities").select(cityColumns).order("name", { ascending: true }).order("id", { ascending: true }).limit(100).abortSignal(AbortSignal.timeout(8000));
      if (!result.error && Array.isArray(result.data) && result.data.every(validCityRow)) { rows = result.data; available = true; }
    }
  } catch { /* Unavailable data is unknown, not a successful empty list. */ }
  return (
    <>
      <PageHeader title="Города" description="Редактируйте название, провинцию, описание, координаты, ссылку муниципалитета, транспортные заметки и статус. Обложка и дополнительные контакты существующей записи сохраняются." />
      <CityManager rows={rows} available={available} canEdit={canEditContent(admin.role)} canPublish={canPublishContent(admin.role)} userId={admin.id} />
      <section className="mt-8 space-y-4">
        <ReadOnlySource state={packagedRows.length ? "data" : "empty"} label="Городские страницы текущего пакета — только просмотр" detail={`Dataset ${canonicalMap.source.contentDatasetFingerprint}; ${packagedRows.length} published city rows. Редактирование базы выше не обновляет этот пакет.`} />
        <CrudTable title="Города в пакете сайта" description="Фактически упакованные городские страницы; муниципалитеты показаны отдельно в разделе Карта." rows={packagedRows} columns={["name", "province", "lat", "lng", "source_id", "status"]} />
      </section>
    </>
  );
}
