import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRows } from "@/lib/data";

const fallbackRows = [
  { user_id: "demo-owner", action: "публикация", entity_type: "статья", entity_id: "municipality-registration", created_at: "2026-06-20T10:00:00Z" },
  { user_id: "demo-owner", action: "ссылка проверена", entity_type: "официальная ссылка", entity_id: "government-nl", created_at: "2026-06-20T11:00:00Z" },
  { user_id: "demo-qa", action: "создана ошибка", entity_type: "ошибка", entity_id: "transport-overflow", created_at: "2026-06-20T12:00:00Z" }
];

export default async function AuditLogPage() {
  const rows = await fetchRows("audit_logs", fallbackRows, 100, "created_at");
  return (
    <>
      <PageHeader title="Журнал действий" description="Каждое действие администратора сохраняет пользователя, объект, старые/новые значения и время изменения." />
      <CrudTable title="Последние действия" description="Журнал безопасности только для просмотра владельцем или администратором." rows={rows} columns={["user_id", "action", "entity_type", "entity_id", "created_at"]} cta="Экспорт журнала" />
    </>
  );
}
