import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRows } from "@/lib/data";

const fallbackRows = [
  { user_email: "tester@example.com", message: "На карте сложно управлять зумом", app_screen: "Карта", platform: "iOS", status: "new" },
  { user_email: "", message: "Добавить больше примеров чек-листа по жилью", app_screen: "Жилье", platform: "iOS", status: "planned" },
  { user_email: "student@example.com", message: "Нужны голландские термины простым языком", app_screen: "Библиотека", platform: "iOS", status: "reviewed" }
];

export default async function FeedbackPage() {
  const rows = await fetchRows("feedback", fallbackRows, 100, "created_at");
  return (
    <>
      <PageHeader title="Отзывы пользователей" description="Собирайте обратную связь, классифицируйте запросы и превращайте повторяющиеся проблемы в задачи." />
      <CrudTable title="Входящие отзывы" description="Email пользователя, сообщение, экран приложения, платформа и статус обработки." rows={rows} columns={["user_email", "message", "app_screen", "platform", "status"]} cta="Добавить отзыв" />
    </>
  );
}
