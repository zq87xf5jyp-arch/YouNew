import { MapPointManager } from "@/components/admin/map-point-manager";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { mapPointColumns, validMapPointRow, type MapPointRow } from "@/lib/map-points";

import { Database, MapPin } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { canonicalMap } from "@/lib/canonical-admin-data";

function CanonicalMapProjection() {
  const visibleRows = canonicalMap.points.slice(0, 100);
  return (
    <>
      <PageHeader
        title="Канонические точки карты"
        description="Только просмотр. Источник совпадает с публичным map API: packaged governed content и официальный реестр 342 муниципалитетов. Legacy map_points не считается publication authority."
      />
      <ReadOnlySource
        state={canonicalMap.points.length ? "data" : "empty"}
        label="packaged governed content + official municipality registry"
        detail={`${canonicalMap.counts.total} canonical rows · fingerprint ${canonicalMap.datasetFingerprint}`}
      />
      <div className="mb-6 grid gap-4 md:grid-cols-3">
        <Card><CardHeader className="pb-2"><CardTitle className="flex items-center gap-2 text-base"><MapPin className="size-4" />Всего точек</CardTitle></CardHeader><CardContent><p className="text-3xl font-bold">{canonicalMap.counts.total}</p><p className="text-xs text-muted-foreground">Уникальны по source_kind + source_id; одинаковые координаты разрешены.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-base">Published content</CardTitle></CardHeader><CardContent><p className="text-3xl font-bold">{canonicalMap.counts.contentEntities}</p><p className="text-xs text-muted-foreground">Только опубликованные city, organization и place с координатами.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-base">Муниципалитеты</CardTitle></CardHeader><CardContent><p className="text-3xl font-bold">{canonicalMap.counts.municipalities}</p><p className="text-xs text-muted-foreground">Официальный registry snapshot · geography effective {canonicalMap.source.geographyEffectiveDate}.</p></CardContent></Card>
      </div>
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="flex items-center gap-2"><Database className="size-4" />Dataset identity <Badge variant="success">measured</Badge></CardTitle>
          <CardDescription>Этот fingerprint возвращается в ETag `/api/public/map-points`.</CardDescription>
        </CardHeader>
        <CardContent><p className="break-all font-mono text-xs text-muted-foreground">{canonicalMap.datasetFingerprint}</p></CardContent>
      </Card>
      <CrudTable
        title="Первые 100 канонических точек"
        description={`Показано ${visibleRows.length} из ${canonicalMap.counts.total}. Полный набор доступен через read-only public map API.`}
        rows={visibleRows}
        columns={["title", "type", "latitude", "longitude", "province", "source_kind", "source_id", "status"]}
      />
    </>
  );
}

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function MapPage() {
  const admin = await requireAdmin();
  let rows: MapPointRow[] = [], available = false;
  try {
    const supabase = await createSupabaseServerClient();
    if (supabase) {
      const result = await supabase.from("map_points").select(mapPointColumns).order("updated_at", { ascending: false }).order("id", { ascending: true }).limit(100).abortSignal(AbortSignal.timeout(8000));
      if (!result.error && Array.isArray(result.data) && result.data.every(validMapPointRow)) { rows = result.data; available = true; }
    }
  } catch { /* A missing source is unknown, not an empty successful list. */ }
  return <>
    <PageHeader title="Операционные точки базы Admin" description="Записи базы Admin: координаты, описание, источник и статус. Местоположение пользователя не запрашивается. Совпадающие координаты не означают дубликат." />
    <MapPointManager rows={rows} available={available} canEdit={canEditContent(admin.role)} canPublish={canPublishContent(admin.role)} userId={admin.id} apiMode="packaged" />
    <CanonicalMapProjection />
  </>;
}
