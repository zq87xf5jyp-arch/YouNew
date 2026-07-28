import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRows, defaultCategories } from "@/lib/data";

export default async function CategoriesPage() {
  const rows = await fetchRows("categories", defaultCategories);
  return (
    <>
      <PageHeader title="Категории" description="Управляйте названиями категорий, порядком, иконками, цветами и статусом публикации." />
      <CrudTable title="Основные категории приложения" description="Эти категории повторяют навигацию мобильного приложения YouNew.nl." rows={rows} columns={["priority", "title", "slug", "icon", "color", "status"]} cta="Новая категория" />
    </>
  );
}
