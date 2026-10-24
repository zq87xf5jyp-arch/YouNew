import { PageHeader } from "@/components/admin/page-header";
import { FeedbackManager } from "@/components/admin/feedback-manager";
import { requireAdmin } from "@/lib/auth";
import { canManageFeedback, type FeedbackRow } from "@/lib/feedback";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { fetchRowsResult } from "@/lib/data";


export default async function FeedbackPage() {
  const admin = await requireAdmin();
  if (!canManageFeedback(admin.role)) return <PageHeader title="Отзывы пользователей" description="Обработка обращений доступна владельцу, администратору и QA. Текущая роль не имеет доступа к сообщениям." />;
  const result = await fetchRowsResult<FeedbackRow>("feedback", [], 100, "created_at");
  const genuineCount = result.rows.filter((row) => row.record_origin === "user_submission").length;
  return (
    <>
      <PageHeader title="Отзывы пользователей" description="Проверьте сообщение, сохраните статус и результат обработки. Sample, synthetic и неклассифицированные записи не считаются пользовательскими KPI." />
      <ReadOnlySource
        state={result.state}
        label={result.source === "supabase" ? "Supabase feedback" : result.source === "demo" ? "explicit local demo" : "Supabase feedback unavailable"}
        detail={result.state === "data"
          ? `Успешный ограниченный запрос вернул последние ${result.rows.length} записей.`
          : result.state === "empty"
            ? "Успешный запрос измерил ноль доступных записей."
            : result.state === "forbidden"
              ? "Текущая роль не может читать источник; нулевой KPI не заявляется."
              : result.state === "demo"
                ? "Синтетические записи отделены от операционных KPI."
                : "Источник недоступен; отсутствие строк не интерпретируется как ноль."}
      />
      <p className="text-sm text-muted-foreground">Среди возвращённых записей {genuineCount} явно помечены как user_submission. Это не глобальный total и не число уникальных пользователей.</p>
      <FeedbackManager rows={result.source === "supabase" ? result.rows : []} available={result.source === "supabase"} />
    </>
  );
}
