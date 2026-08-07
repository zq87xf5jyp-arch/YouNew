import Link from "next/link";
import { AlertTriangle, ArrowRight, CheckCircle2, Clock3, Database, Gauge, MapPin, MessageSquare, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { fetchRowsResult } from "@/lib/data";
import coverage from "@/generated/task-coverage.json";
import dataProject from "@/generated/data-project-dashboard.json";
import trustDashboard from "@/generated/trust-dashboard.json";

type FeedbackRow = { id?: string; feedback_type?: string; page_reference?: string; status?: string; created_at?: string };

function stateBadge(state: string) {
  if (state === "established") return <Badge variant="success">Established</Badge>;
  if (state === "partial") return <Badge variant="warning">Partial</Badge>;
  return <Badge variant="destructive">Not established</Badge>;
}

function displayEvidenceMetric(metric: { value: number | null; evidenceState: string }, suffix = "") {
  return metric.value === null ? "Not established" : `${metric.value}${suffix}`;
}

export default async function CoveragePage() {
  const feedbackResult = await fetchRowsResult<FeedbackRow>("feedback", [], 100, "created_at");
  const openFeedback = feedbackResult.rows.filter((item) => !item.status || !["closed", "resolved", "archived"].includes(item.status)).length;
  const metrics = trustDashboard.metrics;
  const generatedAt = new Intl.DateTimeFormat("en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: "Europe/Amsterdam" }).format(new Date(coverage.generatedAt));

  return (
    <>
      <PageHeader
        title="Coverage Dashboard"
        description="Полезность по десяти главным задачам: проверенный ответ, официальный источник, следующий шаг, требования, дата проверки, локальные границы и QA. Количество страниц само по себе не считается покрытием."
        actions={<Badge variant="info">Formula v{coverage.formulaVersion}</Badge>}
      />

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4" aria-label="Coverage summary">
        <Card><CardHeader className="pb-2"><CardDescription>Weighted useful coverage</CardDescription><CardTitle className="text-3xl">{coverage.weightedCoverage ?? "—"}%</CardTitle></CardHeader><CardContent><p className="text-xs text-muted-foreground">Взвешено по важности пользовательских задач.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardDescription>Established task denominators</CardDescription><CardTitle className="text-3xl">{coverage.establishedTaskCount} / {coverage.taskCount}</CardTitle></CardHeader><CardContent><p className="text-xs text-muted-foreground">Неизвестный denominator никогда не превращается в ноль.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardDescription>National guide snapshot</CardDescription><CardTitle className="text-3xl">{coverage.datasetVerifiedAt}</CardTitle></CardHeader><CardContent><p className="text-xs text-muted-foreground">Дата набора, а не гарантия актуальности после неё.</p></CardContent></Card>
        <Card><CardHeader className="pb-2"><CardDescription>Municipality-topic coverage</CardDescription><CardTitle className="text-xl">{displayEvidenceMetric(metrics.municipalityCoverage, "%")}</CardTitle></CardHeader><CardContent><Badge variant="destructive">{metrics.municipalityCoverage.evidenceState.replaceAll("_", " ")}</Badge></CardContent></Card>
      </section>

      <section className="mt-6 grid gap-6 xl:grid-cols-[minmax(0,1.45fr)_minmax(320px,.55fr)]">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Gauge className="size-5 text-cyan-200" />Task-weighted solution coverage</CardTitle>
            <CardDescription>{coverage.formula}</CardDescription>
          </CardHeader>
          <CardContent className="overflow-x-auto">
            <table className="younew-table min-w-[760px]">
              <thead><tr><th>Task</th><th>Weight</th><th>Solutions</th><th>Coverage</th><th>State</th><th>Gap</th></tr></thead>
              <tbody>
                {coverage.tasks.map((task) => (
                  <tr key={task.id}>
                    <td><p className="font-semibold">{task.label}</p><p className="text-xs text-muted-foreground">{task.id}</p></td>
                    <td>{task.weight}%</td>
                    <td>{task.availableSolutions} / {task.requiredSolutions}</td>
                    <td>
                      <div className="flex min-w-36 items-center gap-3">
                        <div className="h-2 flex-1 overflow-hidden rounded-full bg-secondary"><div className="h-full rounded-full bg-cyan-400" style={{ width: `${task.coveragePercent ?? 0}%` }} /></div>
                        <strong className="w-11 text-right text-sm">{task.coveragePercent === null ? "—" : `${task.coveragePercent}%`}</strong>
                      </div>
                    </td>
                    <td>{stateBadge(task.evidenceState)}</td>
                    <td className="max-w-64 text-xs text-muted-foreground">{task.missing.length ? task.missing.join(", ") : "No gap in the current national contract"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </CardContent>
        </Card>

        <div className="space-y-6">
          <Card>
            <CardHeader><CardTitle className="flex items-center gap-2"><ShieldCheck className="size-5 text-cyan-200" />Coverage criteria</CardTitle><CardDescription>Каждый критерий проверяется отдельно.</CardDescription></CardHeader>
            <CardContent className="space-y-2">
              {coverage.criteria.map((criterion) => <div className="flex items-center gap-2 rounded-md border border-border bg-secondary/25 p-3 text-sm" key={criterion.key}><CheckCircle2 className="size-4 text-cyan-200" />{criterion.label}</div>)}
            </CardContent>
          </Card>
          <Card>
            <CardHeader><CardTitle>Evidence boundary</CardTitle></CardHeader>
            <CardContent className="space-y-3 text-sm text-muted-foreground"><p>Источник: <code>{coverage.sourceArtifact}</code>.</p><p>Сформировано: {generatedAt}.</p><p>100% означает полноту текущего контракта национальной страницы, а не полноту всех реальных случаев в стране.</p></CardContent>
          </Card>
        </div>
      </section>

      <section className="mt-6 grid gap-6 xl:grid-cols-2">
        <Card>
          <CardHeader><CardTitle className="flex items-center gap-2"><Database className="size-5 text-cyan-200" />Content lifecycle</CardTitle><CardDescription>Idea → Research → Draft → Fact check → Review → Published → Monitoring → Needs update → Archived.</CardDescription></CardHeader>
          <CardContent className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">Published</p><p className="mt-1 text-2xl font-bold">{dataProject.summary.published}</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">Needs review</p><p className="mt-1 text-2xl font-bold">{dataProject.summary.needs_review}</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">Outdated</p><p className="mt-1 text-2xl font-bold">{dataProject.summary.outdated}</p></div>
            <div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">Blocked</p><p className="mt-1 text-2xl font-bold">{dataProject.summary.blocked}</p></div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle className="flex items-center gap-2"><MessageSquare className="size-5 text-cyan-200" />User feedback loop</CardTitle><CardDescription>Helpful, not helpful, outdated, missing and suggestion reports enter the existing moderated feedback pipeline.</CardDescription></CardHeader>
          <CardContent>
            {feedbackResult.source === "supabase" ? <><p className="text-3xl font-bold">{openFeedback}</p><p className="mt-1 text-sm text-muted-foreground">Open live feedback records from Supabase.</p></> : <div className="rounded-md border border-amber-400/30 bg-amber-400/10 p-4 text-sm text-amber-100"><AlertTriangle className="mb-2 size-5" />Live feedback count is not established in this environment. No demo record is shown as real.</div>}
            <Link className="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-cyan-100" href="/feedback">Open feedback queue <ArrowRight className="size-4" /></Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle className="flex items-center gap-2"><MapPin className="size-5 text-cyan-200" />Local Intelligence</CardTitle><CardDescription>Municipality × task completeness must use an official municipality denominator.</CardDescription></CardHeader>
          <CardContent><p className="text-xl font-bold">{displayEvidenceMetric(metrics.municipalityCoverage, "%")}</p><p className="mt-2 text-sm text-muted-foreground">{metrics.municipalityCoverage.formula}</p><p className="mt-2 text-xs text-muted-foreground">Source: {metrics.municipalityCoverage.sourceArtifact}</p></CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle className="flex items-center gap-2"><Clock3 className="size-5 text-cyan-200" />Time to Useful Action</CardTitle><CardDescription>Target hypothesis, not a measured product claim.</CardDescription></CardHeader>
          <CardContent><div className="grid grid-cols-2 gap-3"><div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">Median target</p><p className="mt-1 text-2xl font-bold">≤ 60 s</p></div><div className="rounded-md border border-border bg-secondary/25 p-3"><p className="text-xs text-muted-foreground">P75 target</p><p className="mt-1 text-2xl font-bold">≤ 120 s</p></div></div><p className="mt-4 text-sm text-amber-100">Measured baseline: Not established until real analytics capture task start and useful-action completion.</p><Link className="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-cyan-100" href="/analytics">Open analytics <ArrowRight className="size-4" /></Link></CardContent>
        </Card>
      </section>
    </>
  );
}
