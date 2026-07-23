import { ExternalLink } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { Button } from "@/components/ui/button";
import { fetchRows } from "@/lib/data";

const fallbackRows = [
  { title: "Government.nl", url: "https://www.government.nl", source_type: "government", status: "active", last_checked_date: "2026-06-20" },
  { title: "Муниципалитет Amsterdam", url: "https://www.amsterdam.nl", source_type: "municipality", status: "active", last_checked_date: "2026-06-20" },
  { title: "Планировщик NS", url: "https://www.ns.nl", source_type: "transport", status: "needs review", last_checked_date: "2026-06-12" }
];

export default async function LinksPage() {
  const rows = await fetchRows("official_links", fallbackRows);
  return (
    <>
      <PageHeader title="Официальные ссылки" description="Храните, проверяйте и вручную отмечайте ссылки правительства, муниципалитетов, транспорта, здравоохранения и образования." actions={<Button><ExternalLink data-icon="inline-start" />Отметить проверенными</Button>} />
      <CrudTable title="Каталог официальных источников" description="Ручное отслеживание статуса. Серверную проверку ссылок можно подключить отдельной задачей." rows={rows} columns={["title", "url", "source_type", "status", "last_checked_date"]} cta="Новая ссылка" />
    </>
  );
}
