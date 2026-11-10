import { Database, ListChecks } from "lucide-react";
import Link from "next/link";
import { PageHeader } from "@/components/admin/page-header";
import { ReleaseReadinessOverview } from "@/components/admin/release-readiness-overview";
import { TrustWorkflow } from "@/components/admin/trust-workflow";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { requireAdmin } from "@/lib/auth";
import { loadOperationalTruth } from "@/lib/release-truth/operational";
import type { OperationalTruth } from "@/lib/release-truth/types";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { validTrustState, validReviewTask, type TrustState, type ReviewTask } from "@/lib/trust-workflow";

export default async function TrustPage({
  searchParams
}: {
  searchParams: Promise<{ offset?: string; recordsOffset?: string }>;
}) {
  const admin = await requireAdmin();
  const params = await searchParams;
  const requestedOffset = Number(params.offset ?? "0"), requestedRecordsOffset = Number(params.recordsOffset ?? "0");
  const offset = Number.isSafeInteger(requestedOffset) && requestedOffset >= 0 ? Math.min(requestedOffset,1000000) : 0;
  const recordsOffset = Number.isSafeInteger(requestedRecordsOffset) && requestedRecordsOffset >= 0 ? Math.min(requestedRecordsOffset,1000000) : 0;
  const supabase = await createSupabaseServerClient().catch(() => null);
  const unavailable = { data: null, error: { message: "unavailable" }, count: null };
  const safe = async <T,>(query: PromiseLike<T>): Promise<T | typeof unavailable> => { try { return await query; } catch { return unavailable; } };
  const queryFailure = { state: "unavailable", observedAt: new Date().toISOString(), reason: "query" } as const;
  const operationalUnavailable: OperationalTruth = { governanceSummary: queryFailure, reviewQueue: queryFailure, reviewSlaBreaches: queryFailure, governanceRisks: queryFailure };
  // Keep canonical source timestamp/SLA classification. Its review view is not
  // the source of actionable forms: the deployed task table is read separately.
  const [operational, stateResult, taskResult] = await Promise.all([
    loadOperationalTruth(offset, 50).catch(() => operationalUnavailable),
    supabase
      ? safe(supabase.from("content_governance_effective").select("*", { count: "exact" }).order("updated_at", { ascending: false }).order("id", { ascending: true }).range(recordsOffset,recordsOffset+49).abortSignal(AbortSignal.timeout(8000)))
      : unavailable,
    supabase
      ? safe(supabase.from("content_review_tasks").select("*", { count: "exact" }).is("resolved_at",null).order("sla_due_at", { ascending: true }).order("id", { ascending: true }).range(offset,offset+49).abortSignal(AbortSignal.timeout(8000)))
      : unavailable
  ]);
  const statesAvailable = !stateResult.error && Array.isArray(stateResult.data) && stateResult.data.every(validTrustState);
  const tasksRead = !taskResult.error && Array.isArray(taskResult.data) && taskResult.data.every(validReviewTask);
  const states: TrustState[] = statesAvailable ? stateResult.data as TrustState[] : [];
  const tasks: ReviewTask[] = tasksRead ? taskResult.data as ReviewTask[] : [];
  const taskIDs = [...new Set(tasks.map(task => task.governance_state_id))];
  const related = supabase && taskIDs.length ? await safe(supabase.from("content_governance_effective").select("*").in("id",taskIDs).limit(50).abortSignal(AbortSignal.timeout(8000))) : { data: [], error: null };
  const relatedAvailable = !related.error && Array.isArray(related.data) && related.data.every(validTrustState) && taskIDs.every(id => related.data?.some((state: TrustState) => state.id === id));
  const tasksAvailable = tasksRead && relatedAvailable;
  const taskStates: TrustState[] = relatedAvailable ? related.data as TrustState[] : [];
  const operationalRisks = operational.governanceRisks.state !== "unavailable" ? operational.governanceRisks.data : [];
  const summary = operational.governanceSummary.state !== "unavailable" ? operational.governanceSummary.data : null;
  const observedAt = new Date().toISOString();

  return (
    <>
      <PageHeader
        title="Trust Dashboard & Human Review Queue"
        description="Build-time release truth и live operational governance показаны раздельно. Недоступная очередь не считается пустой. Publication здесь не выпускает сайт или приложение."
      />
      <div className="mb-8"><ReleaseReadinessOverview compact role={admin.role} /></div>

      <section className="mt-8 grid gap-6 xl:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Database className="size-5" />Operational Content Health</CardTitle>
            <CardDescription>
              {operational.governanceSummary.state === "available"
                ? "Live read through Supabase RLS. Source timestamp is within the 24-hour freshness window."
                : operational.governanceSummary.state === "stale"
                  ? `Stale snapshot: observed ${operational.governanceSummary.observedAt}; valid through ${operational.governanceSummary.validThrough}.`
                : "Unavailable: live governance summary could not be read. Repository evidence remains visible without pretending the values are zero."}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {operational.governanceSummary.state !== "unavailable" && summary ? (
              <dl className="grid gap-3 sm:grid-cols-2">
                {Object.entries(summary).map(([key, value]) => (
                  <div key={key} className="rounded-md border border-border bg-secondary/25 p-3">
                    <dt className="text-xs uppercase tracking-wide text-muted-foreground">{key.replaceAll("_", " ")}</dt>
                    <dd className="mt-1 text-lg font-semibold">{String(value ?? "—")}</dd>
                  </div>
                ))}
              </dl>
            ) : operational.governanceSummary.state === "unavailable" ? (
              <div className="rounded-md border border-amber-400/30 bg-amber-400/10 p-4 text-sm text-amber-100">
                Review queue, SLA and live confidence cannot be inferred from repository files.
              </div>
            ) : (
              <div className="rounded-md border border-border bg-secondary/25 p-4 text-sm text-muted-foreground">
                Measured query result: no governance summary row.
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top Risk Areas</CardTitle>
            <CardDescription>Priority is categorical; no arbitrary average can hide a critical failure.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            {operationalRisks.map((risk, index) => (
              <div key={`${risk.record_key ?? index}`} className="rounded-md border border-border bg-secondary/25 p-3">
                <div className="flex items-center justify-between gap-3">
                  <p className="font-medium">{risk.title}</p>
                  <Badge variant="destructive">P{risk.risk_priority}</Badge>
                </div>
                <p className="mt-1 text-xs text-muted-foreground">{risk.record_key}</p>
              </div>
            ))}
            {operational.governanceRisks.state === "unavailable" ? <p className="text-sm text-muted-foreground">Risk query unavailable; no empty-risk claim is made.</p> : null}
            {operational.governanceRisks.state === "available" && operationalRisks.length === 0 ? <p className="text-sm text-muted-foreground">Measured: no current risk rows.</p> : null}
          </CardContent>
        </Card>
      </section>

      <section className="mt-8" aria-labelledby="review-sla-title">
        <Card>
          <CardHeader>
            <CardTitle id="review-sla-title" className="flex items-center gap-2"><ListChecks className="size-5" />Review SLA evidence</CardTitle>
            <CardDescription>Exact SLA count comes from the canonical operational source, independently of the task page below.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2 text-sm">
            {operational.reviewSlaBreaches.state === "available"
              ? <p>Exact SLA breaches: {operational.reviewSlaBreaches.data} · read {operational.reviewSlaBreaches.observedAt}.</p>
              : <p>SLA breach count unavailable; no zero or page-derived count is claimed.</p>}
            {operational.reviewQueue.state === "unavailable"
              ? <p className="text-xs text-muted-foreground">Canonical review queue source unavailable. Task forms below use independently validated content_review_tasks rows; source failure is not an empty-queue result.</p>
              : <p className="text-xs text-muted-foreground">Canonical review queue source: {operational.reviewQueue.data.total} open tasks · read {operational.reviewQueue.observedAt}. This source metadata is separate from the current actionable task page.</p>}
          </CardContent>
        </Card>
      </section>

      <TrustWorkflow states={states} tasks={tasks} taskStates={taskStates} statesAvailable={statesAvailable} tasksAvailable={tasksAvailable} role={admin.role} userId={admin.id} observedAt={observedAt} stateTotal={statesAvailable ? stateResult.count ?? null : null} taskTotal={tasksAvailable ? taskResult.count ?? null : null} />
      <nav className="mt-4 flex flex-wrap gap-3" aria-label="Trust pagination">
        {offset > 0 ? <Button asChild size="sm" variant="outline"><Link href={`/trust?offset=${Math.max(0,offset-50)}&recordsOffset=${recordsOffset}`}>Предыдущие 50 задач</Link></Button> : null}
        {tasksAvailable && taskResult.count !== null && taskResult.count !== undefined && offset+50 < taskResult.count ? <Button asChild size="sm" variant="outline"><Link href={`/trust?offset=${offset+50}&recordsOffset=${recordsOffset}`}>Следующие 50 задач</Link></Button> : null}
        {recordsOffset > 0 ? <Button asChild size="sm" variant="outline"><Link href={`/trust?offset=${offset}&recordsOffset=${Math.max(0,recordsOffset-50)}`}>Предыдущие 50 записей</Link></Button> : null}
        {statesAvailable && stateResult.count !== null && stateResult.count !== undefined && recordsOffset+50 < stateResult.count ? <Button asChild size="sm" variant="outline"><Link href={`/trust?offset=${offset}&recordsOffset=${recordsOffset+50}`}>Следующие 50 записей</Link></Button> : null}
      </nav>
    </>
  );
}
