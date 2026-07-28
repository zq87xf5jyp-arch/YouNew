import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRowsResult } from "@/lib/data";

export default async function FeedbackPage() {
  const result = await fetchRowsResult("feedback", [], 100, "created_at");
  return (
    <>
      <PageHeader title="Отзывы пользователей" description="Собирайте обратную связь, классифицируйте запросы и превращайте повторяющиеся проблемы в задачи." />
      <CrudTable
        title="Входящие отзывы"
        description={result.source === "supabase"
          ? "Подтверждённые записи Supabase: ID, тип, страница, сообщение и статус обработки."
          : "Таблица feedback недоступна. Демо-записи не показываются как реальные отзывы."}
        rows={result.rows}
        columns={["confirmation_code", "feedback_type", "page_reference", "user_email", "message", "status", "created_at"]}
        cta="Обновить список"
      />
    </>
  );
}
