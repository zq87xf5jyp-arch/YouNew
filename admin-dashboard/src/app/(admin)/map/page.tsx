import { MapPin } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { defaultCities, fetchRows } from "@/lib/data";

const fallbackRows = defaultCities.map((city) => ({
  title: city.name,
  type: "city",
  latitude: city.lat,
  longitude: city.lng,
  province: city.province,
  status: "published",
  icon: "MapPin",
  color: "#38bdf8"
}));

export default async function MapPage() {
  const mapRows = await fetchRows("map_points", fallbackRows);
  return (
    <>
      <PageHeader title="Управление картой" description="Управляйте городами, муниципалитетами, больницами, транспортными узлами, государственными точками и пользовательскими объектами." />
      <div className="grid gap-6 xl:grid-cols-[1fr_0.8fr]">
        <CrudTable title="Точки карты" description="Таблица для редактирования данных публичной интерактивной карты." rows={mapRows} columns={["title", "type", "latitude", "longitude", "province", "status"]} cta="Новая точка" />
        <Card>
          <CardHeader>
            <CardTitle>Предпросмотр карты</CardTitle>
            <CardDescription>Место для интеграции Leaflet/MapLibre с маркерами городов.</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="relative aspect-[4/5] overflow-hidden rounded-lg border border-cyan-400/20 bg-[#03162d]">
              <div className="absolute inset-8 rounded-[45%] border border-cyan-500/40 bg-cyan-500/5" />
              {mapRows.map((point, index) => (
                <div
                  key={`${String(point.title)}-${index}`}
                  className="absolute flex -translate-x-1/2 -translate-y-1/2 items-center gap-1 text-xs font-semibold"
                  style={{
                    left: `${28 + (index % 3) * 18 + index * 2}%`,
                    top: `${20 + index * 8}%`
                  }}
                >
                  <span className="grid size-7 place-items-center rounded-full bg-primary text-primary-foreground shadow-orange">
                    <MapPin className="size-4" />
                  </span>
                  <span>{point.title}</span>
                </div>
              ))}
              <div className="absolute bottom-4 left-4 flex gap-2">
                <Badge variant="default">Вы</Badge>
                <Badge variant="info">Города</Badge>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </>
  );
}
