import { Activity, BookOpen, Bug, Building2, CircleAlert, ClipboardList, Database, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { StatCard } from "@/components/admin/stat-card";
import { CrudTable } from "@/components/admin/crud-table";
import { ReleaseReadinessOverview } from "@/components/admin/release-readiness-overview";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { defaultCategories, defaultCities, fetchRowsResult, sampleArticles, sampleBugs } from "@/lib/data";
import { displayMetric, evidenceStateLabel, releaseTruth } from "@/lib/release-truth/static";
import { requireAdmin } from "@/lib/auth";
import { canManageBugs } from "@/lib/bugs";

export default async function DashboardPage() {
  const admin = await requireAdmin();
  const mayReadBugs = canManageBugs(admin.role);
  const [articleResult, categoryResult, cityResult, bugResult] = await Promise.all([
    fetchRowsResult("articles", sampleArticles),
    fetchRowsResult("categories", defaultCategories),
    fetchRowsResult("cities", defaultCities),
    mayReadBugs ? fetchRowsResult("bugs", sampleBugs) : Promise.resolve(null)
  ]);
  const articles = articleResult.rows;
  const categories = categoryResult.rows;
  const cities = cityResult.rows;
  const openBugs = bugResult?.rows.filter((bug) => String(bug.status) !== "closed").length ?? null;
  const readableResults = [articleResult, categoryResult, cityResult, ...(bugResult ? [bugResult] : [])];
  const productSource = readableResults.every((result) => result.source === "supabase")
    ? "Supabase"
    : readableResults.some((result) => result.source === "demo")
      ? "явное локальное демо"
      : "NOT VERIFIED";

  return (
    <>
      <PageHeader
        title="Панель управления"
        description="Единый release truth, packaged publication и отдельно помеченное оперативное состояние. Неизвестные данные не превращаются в нули."
      />
      <div className="mb-8">
        <ReleaseReadinessOverview compact role={admin.role} />
      </div>

      <section>
        <div className="mb-4 flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold">DATA PROJECT truth</h2>
            <p className="text-sm text-muted-foreground">Packaged published отделено от candidate inventory и deployed evidence.</p>
          </div>
          <div className="text-right text-xs text-muted-foreground">
            <p>Snapshot: {releaseTruth.snapshotID}</p>
            <p>Следующий data release: {releaseTruth.publication.inventory.nextReleaseID ?? "не установлен"}</p>
          </div>
        </div>
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <StatCard label="Packaged published" value={releaseTruth.publication.packaged.entityCount} note={`${evidenceStateLabel(releaseTruth.publication.packaged.state)} · ${releaseTruth.publication.packaged.releaseIDs.length} releases`} icon={Database} tone="success" />
          <StatCard label="Governed inventory" value={releaseTruth.publication.inventory.total} note={`${releaseTruth.publication.inventory.verified} verified candidate records`} icon={ShieldCheck} tone="info" />
          <StatCard label="Packaged coverage" value={displayMetric(releaseTruth.metrics.packagedCoverage)} note="packaged published / governed inventory" icon={Activity} tone="info" />
          <StatCard label="Link health" value={displayMetric(releaseTruth.metrics.linkHealth)} note={`${evidenceStateLabel(releaseTruth.metrics.linkHealth.state)} · network check required`} icon={CircleAlert} tone="warning" />
        </div>
      </section>

      <section className="mt-6">
        <Card>
          <CardHeader>
            <CardTitle>Evidence semantics</CardTitle>
            <CardDescription>Ноль показывается только после успешного измерения; N/A, unknown, stale и provisional имеют отдельные состояния.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs uppercase text-muted-foreground">Packaged fingerprint</p><p className="mt-1 break-all font-mono text-xs">{releaseTruth.publication.packaged.datasetFingerprint}</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs uppercase text-muted-foreground">Deployed coverage</p><p className="mt-1 font-semibold">{evidenceStateLabel(releaseTruth.publication.deployed.state)}</p><p className="mt-1 text-xs text-muted-foreground">Metadata attested; exact payload count is not claimed.</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs uppercase text-muted-foreground">Candidate CI</p><p className="mt-1 font-semibold">unknown</p><p className="mt-1 text-xs text-muted-foreground">Exact-commit CI manifest is not attached.</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs uppercase text-muted-foreground">Production authority</p><p className="mt-1 font-semibold">not granted</p><p className="mt-1 text-xs text-muted-foreground">Technical status never grants deployment.</p></div>
          </CardContent>
        </Card>
      </section>

      <div className="my-8 border-t border-border" />
      <h2 className="mb-4 text-lg font-semibold">PRODUCT operational data</h2>
      <p className="mb-4 text-sm text-muted-foreground">Источник административных показателей: {productSource}. Они не изменяют build-time release verdict.</p>
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Статьи" value={articleResult.source === "unavailable" ? "—" : articles.length} note={`Источник: ${productSource}`} icon={BookOpen} />
        <StatCard label="Категории" value={categoryResult.source === "unavailable" ? "—" : categories.length} note={`Источник: ${productSource}`} icon={ClipboardList} tone="success" />
        <StatCard label="Города" value={cityResult.source === "unavailable" ? "—" : cities.length} note={`Источник: ${productSource}`} icon={Building2} />
        <StatCard label="Открытые ошибки" value={!bugResult || bugResult.source === "unavailable" ? "—" : openBugs ?? "—"} note={!bugResult ? "Недоступно для вашей роли; количество неизвестно" : bugResult.source === "unavailable" ? "Источник недоступен; количество неизвестно" : bugResult.source === "demo" ? "Локальное демо" : "Supabase: выборка до 50 записей"} icon={Bug} tone="destructive" />
      </section>
      <section className="mt-6">
        <CrudTable title="Недавно обновлённый контент" description="Read-only operational projection. Пустой результат при недоступном Supabase не считается нулём production-контента." rows={articles} columns={["title", "category", "language", "status"]} />
      </section>
    </>
  );
}
