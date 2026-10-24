import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { fetchRowsResult } from "@/lib/data";

const fallbackRows = [
  { user_id: "demo-owner", action: "публикация", entity_type: "статья", entity_id: "municipality-registration", created_at: "2026-06-20T10:00:00Z" },
  { user_id: "demo-owner", action: "ссылка проверена", entity_type: "официальная ссылка", entity_id: "government-nl", created_at: "2026-06-20T11:00:00Z" },
  { user_id: "demo-qa", action: "создана ошибка", entity_type: "ошибка", entity_id: "transport-overflow", created_at: "2026-06-20T12:00:00Z" }
];

export default async function AuditLogPage() {
  const result = await fetchRowsResult("audit_logs", fallbackRows, 100, "created_at");
  return (
    <>
      <PageHeader title="Журнал действий" description="Только просмотр. Экран показывает возвращённые audit rows и не заявляет полноту, если источник недоступен." />
      <ReadOnlySource
        state={result.state}
        label={result.source === "supabase" ? "Supabase audit_logs" : result.source === "demo" ? "explicit local demo" : "Supabase unavailable"}
        detail={result.state === "data" ? `${result.rows.length} latest rows returned; this page is not an export or completeness proof.` : result.state === "empty" ? "Successful authenticated query returned zero rows." : result.state === "forbidden" ? "The authenticated identity is not permitted to read the audit source." : result.source === "demo" ? "Synthetic audit rows are labelled demo." : "No audit-log completeness claim is made."}
      />
      <CrudTable title="Последние действия" description="Read-only bounded query (up to 100 rows)." rows={result.rows} columns={["user_id", "action", "entity_type", "entity_id", "created_at"]} />
    </>
  );
}
