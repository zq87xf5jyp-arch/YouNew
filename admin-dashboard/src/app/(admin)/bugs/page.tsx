import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { fetchRows, sampleBugs } from "@/lib/data";

const statuses = ["open", "in progress", "fixed", "verified", "closed"];
const statusLabels: Record<string, string> = {
  open: "открыта",
  "in progress": "в работе",
  fixed: "исправлена",
  verified: "проверена",
  closed: "закрыта"
};

export default async function BugsPage() {
  const bugs = await fetchRows("bugs", sampleBugs);
  return (
    <>
      <PageHeader title="Трекер ошибок" description="Отслеживайте серьезность, платформу, связанные скриншоты, шаги воспроизведения, ожидаемый/фактический результат и проверку перед релизом." />
      <div className="grid gap-6">
        <CrudTable title="Таблица ошибок" description="Фильтруйте по серьезности, платформе, статусу и экрану приложения." rows={bugs} columns={["title", "severity", "priority", "status", "platform", "app_screen"]} cta="Новая ошибка" />
        <Card>
          <CardHeader>
            <CardTitle>Канбан по статусам</CardTitle>
            <CardDescription>Короткий вид для подготовки релиза.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-4 lg:grid-cols-5">
            {statuses.map((status) => (
              <div key={status} className="min-h-44 rounded-lg border border-border bg-secondary/25 p-3">
                <div className="mb-3 flex items-center justify-between">
                  <p className="text-sm font-semibold capitalize">{statusLabels[status]}</p>
                  <Badge variant="secondary">{bugs.filter((bug) => String(bug.status) === status).length}</Badge>
                </div>
                <div className="flex flex-col gap-2">
                  {bugs.filter((bug) => String(bug.status) === status).map((bug) => (
                    <div key={String(bug.title)} className="rounded-md border border-border bg-card p-3 text-sm">
                      <p className="font-medium">{String(bug.title)}</p>
                      <p className="mt-1 text-xs text-muted-foreground">{String(bug.platform)} · {String(bug.app_screen)}</p>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
