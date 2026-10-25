import Link from "next/link";
import { CheckCircle2, CircleAlert, Database, ExternalLink, Gauge, Globe2, Link2, PackageCheck } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { displayMetric, evidenceStateLabel, releaseTruth } from "@/lib/release-truth/static";
import { canAccessPath, type AdminRole } from "@/lib/authorization";
import type { GateResult } from "@/lib/release-truth/types";

const snapshotDate = new Intl.DateTimeFormat("ru-RU", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "Europe/Amsterdam"
}).format(new Date(releaseTruth.generatedAt));

function gateVariant(result: GateResult) {
  if (result === "pass") return "success" as const;
  if (result === "fail") return "destructive" as const;
  return "warning" as const;
}

function gateLabel(result: GateResult) {
  return { pass: "PASS", fail: "FAIL", blocked: "BLOCKED", not_applicable: "N/A" }[result];
}

const evidence = [
  {
    label: "Packaged published",
    value: releaseTruth.publication.packaged.entityCount,
    note: `${evidenceStateLabel(releaseTruth.publication.packaged.state)} · ${releaseTruth.publication.packaged.releaseIDs.join(", ")}`,
    icon: PackageCheck
  },
  {
    label: "Governed inventory",
    value: releaseTruth.publication.inventory.total,
    note: `${releaseTruth.publication.inventory.verified} verified · ${releaseTruth.publication.inventory.outdated} outdated`,
    icon: Database
  },
  {
    label: "Deployed payload",
    value: releaseTruth.publication.deployed.entityCount ?? "—",
    note: `${evidenceStateLabel(releaseTruth.publication.deployed.state)} · metadata attested only`,
    icon: Globe2
  },
  {
    label: "Link health",
    value: displayMetric(releaseTruth.metrics.linkHealth),
    note: `${evidenceStateLabel(releaseTruth.metrics.linkHealth.state)} · fresh network check required`,
    icon: Link2
  }
];

export function ReleaseReadinessOverview({ compact = false, role }: { compact?: boolean; role?: AdminRole }) {
  return (
    <section className="grid gap-6" aria-labelledby="release-readiness-title">
      <Card className="overflow-hidden border-yellow-400/25 bg-[radial-gradient(circle_at_top_right,rgba(250,204,21,.1),transparent_24rem),linear-gradient(145deg,rgba(14,29,53,.96),rgba(3,16,35,.96))]">
        <CardHeader className="gap-3 border-b border-border/80 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <CardTitle id="release-readiness-title" className="flex items-center gap-2 text-xl">
              <Gauge className="size-5 text-cyan-300" />
              Product Release Truth
            </CardTitle>
            <CardDescription className="mt-2 max-w-3xl">
              Один детерминированный snapshot для Dashboard, Trust и Releases. Технический статус не является разрешением на production.
            </CardDescription>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant="warning">{releaseTruth.technicalVerdict}</Badge>
            <Badge variant="destructive">production не разрешён</Badge>
            <span className="text-xs text-muted-foreground">Evidence snapshot: {snapshotDate}</span>
          </div>
        </CardHeader>
        <CardContent className="grid gap-6 pt-5 xl:grid-cols-[270px_1fr]">
          <div className="rounded-xl border border-yellow-400/25 bg-yellow-400/10 p-5">
            <p className="text-3xl font-black tracking-tight text-yellow-200">{releaseTruth.technicalVerdict}</p>
            <p className="mt-2 text-sm font-semibold text-yellow-100">Fail-closed pre-production state</p>
            <p className="mt-3 text-xs leading-relaxed text-muted-foreground">{releaseTruth.verdictReason}</p>
          </div>
          <div className="grid gap-3 sm:grid-cols-2">
            {evidence.map(({ label, value, note, icon: Icon }) => (
              <div key={label} className="rounded-lg border border-border bg-background/35 p-4">
                <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wide text-cyan-200">
                  <Icon className="size-4" />
                  {label}
                </div>
                <p className="mt-3 text-lg font-bold">{value}</p>
                <p className="mt-1 text-xs text-muted-foreground">{note}</p>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {compact ? (
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-yellow-400/20 bg-yellow-400/5 px-4 py-3">
          <p className="text-sm text-muted-foreground">
            {Object.values(releaseTruth.gates).filter((gate) => gate.result === "pass").length} PASS · {Object.values(releaseTruth.gates).filter((gate) => gate.result === "blocked").length} BLOCKED · snapshot {releaseTruth.snapshotID}
          </p>
          {role && canAccessPath(role, "/releases") ? (
            <Link className="inline-flex items-center gap-2 text-sm font-semibold text-cyan-200 hover:text-cyan-100" href="/releases">
              Открыть release evidence <ExternalLink className="size-4" />
            </Link>
          ) : null}
        </div>
      ) : (
        <div className="grid gap-6 xl:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Hard gates</CardTitle>
              <CardDescription>Неизвестное или устаревшее evidence блокирует GO, но не выдаётся за FAIL.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
              {Object.entries(releaseTruth.gates).map(([id, gate]) => (
                <div key={id} className="flex items-start justify-between gap-4 rounded-md border border-border bg-secondary/25 p-3">
                  <span className="flex items-start gap-3 text-sm">
                    {gate.result === "pass"
                      ? <CheckCircle2 className="mt-0.5 size-4 shrink-0 text-emerald-300" />
                      : <CircleAlert className="mt-0.5 size-4 shrink-0 text-yellow-200" />}
                    <span><strong>{id}</strong><span className="mt-1 block text-xs text-muted-foreground">{gate.reason}</span></span>
                  </span>
                  <Badge variant={gateVariant(gate.result)}>{gateLabel(gate.result)}</Badge>
                </div>
              ))}
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle>Evidence limitations</CardTitle>
              <CardDescription>Ограничения являются частью snapshot и не скрываются за общей оценкой.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
              {releaseTruth.limitations.map((item) => (
                <div key={item} className="flex items-start gap-3 rounded-md border border-yellow-400/15 bg-yellow-400/5 p-3 text-sm">
                  <CircleAlert className="mt-0.5 size-4 shrink-0 text-yellow-200" />
                  <span>{item}</span>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>
      )}
    </section>
  );
}
