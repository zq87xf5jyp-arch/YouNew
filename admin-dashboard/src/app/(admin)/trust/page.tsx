import { randomUUID } from "node:crypto";
import { AlertTriangle, Database, Gauge, ListChecks, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { requireAdmin } from "@/lib/auth";
import {
  canPublishContent,
  canVerifyContent,
  canWorkReviewQueue
} from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import trustDashboard from "@/generated/trust-dashboard.json";
import {
  approveContentPublicationAction,
  transitionReviewTaskAction,
  verifyContentNowAction
} from "./actions";

type TrustMetric = {
  value: number | null;
  numerator: number | null;
  denominator: number | null;
  formula: string;
  formulaVersion: number;
  sourceArtifact: string;
  generatedAt: string;
  evidenceState: string;
};

type Row = Record<string, unknown>;

function displayMetric(metric: TrustMetric, suffix = "") {
  return metric.value === null ? "Not established" : `${metric.value}${suffix}`;
}

function metricVariant(metric: TrustMetric) {
  return metric.evidenceState === "established"
    ? "info" as const
    : metric.evidenceState === "provisional"
      ? "warning" as const
      : "destructive" as const;
}

function MetricCard({ title, metric, suffix = "" }: { title: string; metric: TrustMetric; suffix?: string }) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-3">
          <CardTitle className="text-base">{title}</CardTitle>
          <Badge variant={metricVariant(metric)}>{metric.evidenceState.replaceAll("_", " ")}</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-2xl font-bold">{displayMetric(metric, suffix)}</p>
        <p className="mt-2 text-xs text-muted-foreground">
          {metric.numerator ?? "—"} / {metric.denominator ?? "—"} · formula v{metric.formulaVersion}
        </p>
        <details className="mt-3 text-xs text-muted-foreground">
          <summary className="cursor-pointer text-cyan-100">Why am I seeing this?</summary>
          <p className="mt-2">{metric.formula}</p>
          <p className="mt-1 break-all">Source: {metric.sourceArtifact}</p>
          <p className="mt-1">Generated: {metric.generatedAt}</p>
        </details>
      </CardContent>
    </Card>
  );
}

function nextTransition(state: string) {
  if (state === "needs_review") return ["assigned", "Назначить себе"] as const;
  if (state === "assigned") return ["in_review", "Начать проверку"] as const;
  if (state === "in_review") return ["approved", "Одобрить review"] as const;
  if (state === "approved") return ["closed", "Закрыть задачу"] as const;
  if (state === "expired") return ["needs_review", "Вернуть в очередь"] as const;
  return null;
}

export default async function TrustPage() {
  const admin = await requireAdmin();
  const supabase = await createSupabaseServerClient();
  const unavailable = { data: null, error: { message: "unavailable" } };
  const [summaryResult, stateResult, taskResult, riskResult] = supabase
    ? await Promise.all([
        supabase.from("content_governance_health_summary").select("*").maybeSingle(),
        supabase.from("content_governance_effective").select("*").order("updated_at", { ascending: false }).limit(50),
        supabase.from("content_review_tasks").select("*").is("resolved_at", null).order("sla_due_at", { ascending: true }).limit(50),
        supabase.from("content_governance_top_risks").select("*").limit(25)
      ])
    : [unavailable, unavailable, unavailable, unavailable];
  const operationalAvailable = !summaryResult.error && !stateResult.error && !taskResult.error && !riskResult.error;
  const states = (stateResult.data ?? []) as Row[];
  const tasks = (taskResult.data ?? []) as Row[];
  const operationalRisks = (riskResult.data ?? []) as Row[];
  const summary = summaryResult.data as Row | null;
  const dimensions = trustDashboard.readiness.dimensions as Record<string, TrustMetric>;
  const metrics = trustDashboard.metrics as Record<string, TrustMetric>;
  const hardGates = trustDashboard.readiness.hardGates as Record<string, boolean>;
  const passedHardGates = Object.values(hardGates).filter(Boolean).length;

  return (
    <>
      <PageHeader
        title="Trust Dashboard & Human Review Queue"
        description="Evidence-aware governance: status, freshness, provenance, review workflow, coverage and release authority. Confidence is an evidence coverage index, not a probability."
      />

      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 rounded-lg border border-red-400/30 bg-red-400/10 p-4">
        <div className="flex items-start gap-3">
          <AlertTriangle className="mt-0.5 size-5 text-red-200" aria-hidden />
          <div>
            <p className="font-semibold text-red-100">Release authority: {trustDashboard.currentReleaseAuthority}</p>
            <p className="mt-1 max-w-4xl text-sm text-muted-foreground">{trustDashboard.releaseAuthorityReason}</p>
          </div>
        </div>
        <Badge variant={passedHardGates === Object.keys(hardGates).length ? "info" : "destructive"}>
          Hard gates: {passedHardGates} / {Object.keys(hardGates).length}
        </Badge>
      </div>

      <section aria-labelledby="readiness-title">
        <div className="mb-4 flex items-center gap-2">
          <Gauge className="size-5 text-cyan-200" aria-hidden />
          <h2 id="readiness-title" className="text-lg font-semibold">Production Readiness Scorecard</h2>
        </div>
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {Object.entries(dimensions).map(([key, value]) => (
            <MetricCard key={key} title={key[0].toUpperCase() + key.slice(1)} metric={value} suffix="%" />
          ))}
        </div>
      </section>

      <section className="mt-8" aria-labelledby="trust-metrics-title">
        <div className="mb-4 flex items-center gap-2">
          <ShieldCheck className="size-5 text-cyan-200" aria-hidden />
          <h2 id="trust-metrics-title" className="text-lg font-semibold">Trust & Knowledge metrics</h2>
        </div>
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <MetricCard title="Verified coverage" metric={metrics.verified} suffix="%" />
          <MetricCard title="Governed public coverage" metric={metrics.governedPublicCoverage} suffix="%" />
          <MetricCard title="Pilot Amsterdam × topics" metric={metrics.pilotMunicipalityCoverage} suffix="%" />
          <MetricCard title="National municipality coverage" metric={metrics.municipalityCoverage} suffix="%" />
          <MetricCard title="AI retrieval coverage" metric={metrics.aiCoverage} suffix="%" />
          <MetricCard title="Median confidence" metric={metrics.medianConfidence} />
          <MetricCard title="Source Trust Score" metric={metrics.sourceTrustScore} />
          <MetricCard title="Semantic duplicate candidates" metric={metrics.semanticDuplicateCandidates} />
        </div>
      </section>

      <section className="mt-8 grid gap-6 xl:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Database className="size-5" />Operational Content Health</CardTitle>
            <CardDescription>
              {operationalAvailable
                ? "Live read through Supabase RLS."
                : "Not established: additive migration is not applied/available. Repository evidence remains visible without pretending the queue is empty."}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {operationalAvailable && summary ? (
              <dl className="grid gap-3 sm:grid-cols-2">
                {Object.entries(summary).map(([key, value]) => (
                  <div key={key} className="rounded-md border border-border bg-secondary/25 p-3">
                    <dt className="text-xs uppercase tracking-wide text-muted-foreground">{key.replaceAll("_", " ")}</dt>
                    <dd className="mt-1 text-lg font-semibold">{String(value ?? "—")}</dd>
                  </div>
                ))}
              </dl>
            ) : (
              <div className="rounded-md border border-amber-400/30 bg-amber-400/10 p-4 text-sm text-amber-100">
                Review queue, SLA and live confidence cannot be inferred from repository files.
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
            {(operationalAvailable ? operationalRisks : trustDashboard.topRiskAreas).map((risk, index) => (
              <div key={`${String((risk as Row).record_key ?? (risk as Row).recordID ?? index)}`} className="rounded-md border border-border bg-secondary/25 p-3">
                <div className="flex items-center justify-between gap-3">
                  <p className="font-medium">{String((risk as Row).title ?? (risk as Row).type ?? "Risk")}</p>
                  <Badge variant="destructive">P{String((risk as Row).risk_priority ?? (risk as Row).priority ?? "—")}</Badge>
                </div>
                <p className="mt-1 text-xs text-muted-foreground">{String((risk as Row).record_key ?? (risk as Row).recordID ?? "")}</p>
              </div>
            ))}
          </CardContent>
        </Card>
      </section>

      <section className="mt-8" aria-labelledby="review-queue-title">
        <Card>
          <CardHeader>
            <CardTitle id="review-queue-title" className="flex items-center gap-2"><ListChecks className="size-5" />Human Review Queue</CardTitle>
            <CardDescription>Immutable transitions: Needs review → Assigned → In review → Approved → explicit publication event → Monitoring.</CardDescription>
          </CardHeader>
          <CardContent>
            {!operationalAvailable ? (
              <p className="text-sm text-muted-foreground">Queue is not established until the reviewed migration is applied separately.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="younew-table">
                  <thead><tr><th>Reason</th><th>Severity</th><th>State</th><th>SLA</th><th>Action</th></tr></thead>
                  <tbody>
                    {tasks.map((task) => {
                      const transition = nextTransition(String(task.state));
                      return (
                        <tr key={String(task.id)}>
                          <td>{String(task.reason)}</td>
                          <td><Badge variant={task.severity === "critical" ? "destructive" : "warning"}>{String(task.severity)}</Badge></td>
                          <td>{String(task.state)}</td>
                          <td>{String(task.sla_due_at)}</td>
                          <td>
                            {transition && canWorkReviewQueue(admin.role) ? (
                              <form action={transitionReviewTaskAction}>
                                <input type="hidden" name="taskID" value={String(task.id)} />
                                <input type="hidden" name="expectedState" value={String(task.state)} />
                                <input type="hidden" name="toState" value={transition[0]} />
                                <input type="hidden" name="idempotencyKey" value={randomUUID()} />
                                <input type="hidden" name="reason" value={`Admin workflow: ${transition[1]}`} />
                                <Button type="submit" size="sm" variant="outline">{transition[1]}</Button>
                              </form>
                            ) : <span className="text-xs text-muted-foreground">No transition</span>}
                          </td>
                        </tr>
                      );
                    })}
                    {tasks.length === 0 && <tr><td colSpan={5} className="py-8 text-center text-muted-foreground">No open review tasks.</td></tr>}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      </section>

      <section className="mt-8" aria-labelledby="content-health-title">
        <Card>
          <CardHeader>
            <CardTitle id="content-health-title">Governed records</CardTitle>
            <CardDescription>Verified now is separate from ordinary text editing and uses optimistic version checks.</CardDescription>
          </CardHeader>
          <CardContent>
            {!operationalAvailable ? (
              <p className="text-sm text-muted-foreground">No live operational records are claimed.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="younew-table">
                  <thead><tr><th>Record</th><th>Verification</th><th>Review</th><th>Confidence</th><th>Actions</th></tr></thead>
                  <tbody>
                    {states.map((state) => (
                      <tr key={String(state.id)}>
                        <td><p className="font-medium">{String(state.title)}</p><p className="text-xs text-muted-foreground">{String(state.record_key)}</p></td>
                        <td>{String(state.effective_verification_status)}</td>
                        <td>{String(state.review_state)}</td>
                        <td>{String(state.effective_confidence_score)} / 100</td>
                        <td>
                          <div className="flex flex-wrap gap-2">
                            {canVerifyContent(admin.role) ? (
                              <form action={verifyContentNowAction} className="flex gap-2">
                                <input type="hidden" name="recordKey" value={String(state.record_key)} />
                                <input type="hidden" name="expectedVersion" value={String(state.version)} />
                                <input type="hidden" name="idempotencyKey" value={randomUUID()} />
                                <Input name="reason" required aria-label={`Verification note for ${String(state.title)}`} placeholder="Evidence note" className="h-9 w-40" />
                                <Button type="submit" size="sm" variant="outline">Verified now</Button>
                              </form>
                            ) : null}
                            {canPublishContent(admin.role) && state.review_state === "approved" ? (
                              <form action={approveContentPublicationAction}>
                                <input type="hidden" name="recordKey" value={String(state.record_key)} />
                                <input type="hidden" name="expectedVersion" value={String(state.version)} />
                                <input type="hidden" name="idempotencyKey" value={randomUUID()} />
                                <input type="hidden" name="reason" value="Explicit human operational publication approval." />
                                <Button type="submit" size="sm">Approve operational status</Button>
                              </form>
                            ) : null}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      </section>
    </>
  );
}
