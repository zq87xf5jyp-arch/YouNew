import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { defaultCities, fetchRows } from "@/lib/data";

export default async function CitiesPage() {
  const rows = await fetchRows("cities", defaultCities);
  return (
    <>
      <PageHeader title="Гиды по городам" description="Управляйте страницами городов, провинциями, официальными ссылками, муниципалитетами, транспортными заметками, экстренными контактами и обложками." />
      <CrudTable title="Приоритетные города" description="Amsterdam, Rotterdam, The Hague, Utrecht, Leiden, Eindhoven, Groningen и Maastricht." rows={rows} columns={["name", "province", "lat", "lng", "status"]} cta="Новый город" />
    </>
  );
}
