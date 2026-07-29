import { Activity, BookOpen, Bug, Building2, CircleAlert, ClipboardList, Database, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { StatCard } from "@/components/admin/stat-card";
import { CrudTable } from "@/components/admin/crud-table";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { defaultCategories, defaultCities, fetchRowsResult, sampleArticles, sampleBugs } from "@/lib/data";
import dataProject from "@/generated/data-project-dashboard.json";

export default async function DashboardPage() {
  const [articleResult, categoryResult, cityResult, bugResult] = await Promise.all([
    fetchRowsResult("articles", sampleArticles),
    fetchRowsResult("categories", defaultCategories),
    fetchRowsResult("cities", defaultCities),
    fetchRowsResult("bugs", sampleBugs)
  ]);
  const articles = articleResult.rows;
  const categories = categoryResult.rows;
  const cities = cityResult.rows;
  const bugs = bugResult.rows;
  const openBugs = bugs.filter((bug) => String(bug.status) !== "closed").length;
  const productSource = [articleResult, categoryResult, cityResult, bugResult].every((result) => result.source === "supabase")
    ? "Supabase"
    : [articleResult, categoryResult, cityResult, bugResult].some((result) => result.source === "demo")
      ? "явное локальное демо"
      : "NOT VERIFIED";

  return (
    <>
      <PageHeader
        title="Панель управления"
        description="Состояние PRODUCT и DATA PROJECT: покрытие, качество, источники, релизы, ошибки и публичные выгрузки для мобильного приложения."
      />
      <section>
        <div className="mb-4 flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold">DATA PROJECT</h2>
            <p className="text-sm text-muted-foreground">Только управляемые записи DATA PROJECT. Legacy runtime не засчитывается до аудита и миграции.</p>
          </div>
          <div className="text-right text-xs text-muted-foreground">
            <p>Runtime: {dataProject.runtime_release.release_id}</p>
            <p>Следующий релиз: {dataProject.next_release?.id ?? "не запланирован"}</p>
          </div>
        </div>
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <StatCard label="Published" value={dataProject.summary.published} note={`${dataProject.summary.records} записей под управлением`} icon={Database} tone="success" />
          <StatCard label="Verified" value={dataProject.summary.verified} note={`${dataProject.summary.needs_review} требуют проверки`} icon={ShieldCheck} tone="success" />
          <StatCard label="Outdated" value={dataProject.summary.outdated} note={`${dataProject.summary.blocked} заблокировано`} icon={CircleAlert} tone={dataProject.summary.outdated ? "warning" : "info"} />
          <StatCard label="Quality Score" value={`${dataProject.summary.quality_score}%`} note="По полноте, источникам, медиа, поиску и AI" icon={Activity} tone="info" />
        </div>
      </section>
      <section className="mt-6 grid gap-6 xl:grid-cols-[1fr_1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Coverage Dashboard</CardTitle>
            <CardDescription>Опубликованное покрытие относительно долгосрочных целей.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3">
            {dataProject.coverage.map((item) => (
              <div key={item.key} className="grid grid-cols-[1fr_auto] gap-3 rounded-md border border-border bg-secondary/25 p-3">
                <div>
                  <div className="flex items-center justify-between gap-3 text-sm">
                    <span className="font-medium">{item.label}</span>
                    <span className="text-muted-foreground">{item.current} / {item.target}</span>
                  </div>
                  <div className="mt-2 h-1.5 rounded-full bg-secondary">
                    <div className="h-1.5 rounded-full bg-cyan-400" style={{ width: `${Math.min(item.coverage_percent, 100)}%` }} />
                  </div>
                </div>
                <span className="w-14 text-right text-sm font-semibold text-cyan-100">{item.coverage_percent}%</span>
              </div>
            ))}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Quality Score по Work Package</CardTitle>
            <CardDescription>Ноль означает, что пакет ещё не имеет управляемых записей.</CardDescription>
          </CardHeader>
          <CardContent className="max-h-[620px] space-y-2 overflow-y-auto">
            {dataProject.work_packages.map((item) => (
              <div key={item.id} className="flex items-center justify-between gap-4 rounded-md border border-border bg-secondary/25 p-3">
                <div>
                  <p className="text-sm font-medium">{item.id} · {item.name}</p>
                  <p className="text-xs text-muted-foreground">{item.published} published · {item.needs_review} review · {item.outdated} outdated · {item.blocked} blocked</p>
                </div>
                <span className="text-sm font-semibold text-orange-100">{item.quality_score}%</span>
              </div>
            ))}
          </CardContent>
        </Card>
      </section>
      <section className="mt-6">
        <Card>
          <CardHeader>
            <CardTitle>Data Health</CardTitle>
            <CardDescription>
              Ночная проверка ссылок, событий, фотографий, дубликатов, источников, координат и AI summary. Последний link check: {dataProject.data_health.link_check.reachable} доступно из {dataProject.data_health.link_check.total}; {dataProject.data_health.link_check.access_restricted} ограничили автоматическую проверку.
            </CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            {Object.entries(dataProject.data_health.issues).map(([key, value]) => (
              <div key={key} className="rounded-md border border-border bg-secondary/25 p-3">
                <p className="text-xs uppercase tracking-wide text-muted-foreground">{key.replaceAll("_", " ")}</p>
                <p className="mt-1 text-2xl font-bold">{value}</p>
              </div>
            ))}
          </CardContent>
        </Card>
      </section>
      <div className="my-8 border-t border-border" />
      <h2 className="mb-4 text-lg font-semibold">PRODUCT</h2>
      <p className="mb-4 text-sm text-muted-foreground">Источник административных показателей: {productSource}.</p>
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Статьи" value={articleResult.source === "unavailable" ? "—" : articles.length} note={`Источник: ${productSource}`} icon={BookOpen} />
        <StatCard label="Категории" value={categoryResult.source === "unavailable" ? "—" : categories.length} note={`Источник: ${productSource}`} icon={ClipboardList} tone="success" />
        <StatCard label="Города" value={cityResult.source === "unavailable" ? "—" : cities.length} note={`Источник: ${productSource}`} icon={Building2} />
        <StatCard label="Открытые ошибки" value={bugResult.source === "unavailable" ? "—" : openBugs} note={`Источник: ${productSource}`} icon={Bug} tone="destructive" />
      </section>
      <section className="mt-6">
        <CrudTable title="Недавно обновленный контент" description="Последние подтверждённые изменения материалов приложения." rows={articles} columns={["title", "category", "language", "status"]} />
      </section>
    </>
  );
}
