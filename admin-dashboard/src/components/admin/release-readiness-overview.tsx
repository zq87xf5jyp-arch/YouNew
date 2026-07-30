import Link from "next/link";
import {
  CheckCircle2,
  CircleAlert,
  Database,
  ExternalLink,
  Gauge,
  Globe2,
  Smartphone,
  TestTube2
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import readiness from "@/generated/release-readiness.json";

const snapshotDate = new Intl.DateTimeFormat("ru-RU", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "Europe/Amsterdam"
}).format(new Date(readiness.as_of));

const evidence = [
  {
    label: "Public web",
    value: `${readiness.evidence.public_site.static_routes} маршрутов`,
    note: `${readiness.evidence.public_site.tests_passed} теста · predeploy PASS`,
    icon: Globe2
  },
  {
    label: "Admin",
    value: "Build PASS",
    note: `${readiness.evidence.admin.tests_passed} тестов · typecheck PASS`,
    icon: TestTube2
  },
  {
    label: "Supabase",
    value: readiness.evidence.supabase.health,
    note: `${readiness.evidence.supabase.active_edge_functions} Edge Functions · ${readiness.evidence.supabase.remote_migrations} migrations`,
    icon: Database
  },
  {
    label: "iOS Release",
    value: readiness.evidence.ios.release_result,
    note: "Unsigned generic-device build",
    icon: Smartphone
  }
];

export function ReleaseReadinessOverview({ compact = false }: { compact?: boolean }) {
  const readinessPercent = Math.round(readiness.technical_readiness_score * 10);

  return (
    <section className="grid gap-6" aria-labelledby="release-readiness-title">
      <Card className="overflow-hidden border-cyan-400/25 bg-[radial-gradient(circle_at_top_right,rgba(34,211,238,.12),transparent_24rem),linear-gradient(145deg,rgba(14,29,53,.96),rgba(3,16,35,.96))]">
        <CardHeader className="gap-3 border-b border-border/80 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <CardTitle id="release-readiness-title" className="flex items-center gap-2 text-xl">
              <Gauge className="size-5 text-cyan-300" />
              Product Release Readiness
            </CardTitle>
            <CardDescription className="mt-2 max-w-3xl">
              Фактический evidence snapshot. Рабочие поверхности отделены от финального разрешения на релиз.
            </CardDescription>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Badge variant="warning">Release candidate</Badge>
            <span className="text-xs text-muted-foreground">Проверено {snapshotDate}</span>
          </div>
        </CardHeader>
        <CardContent className="grid gap-6 pt-5 xl:grid-cols-[250px_1fr]">
          <div className="rounded-xl border border-orange-400/25 bg-orange-400/10 p-5">
            <p className="text-6xl font-black tracking-tight text-orange-400">
              {readiness.technical_readiness_score}
            </p>
            <p className="mt-1 text-sm font-semibold text-orange-100">technical readiness из 10</p>
            <div className="mt-5 h-2 overflow-hidden rounded-full bg-background/70">
              <div className="h-full rounded-full bg-gradient-to-r from-orange-500 to-cyan-400" style={{ width: `${readinessPercent}%` }} />
            </div>
            <p className="mt-3 text-xs leading-relaxed text-muted-foreground">
              Готово к контролируемой передаче release candidate. Безусловный release: NO-GO.
            </p>
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
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-border bg-secondary/25 px-4 py-3">
          <p className="text-sm text-muted-foreground">
            {readiness.proven.length} подтверждённых поверхностей · {readiness.final_gates.length} открытых release-gates
          </p>
          <Link className="inline-flex items-center gap-2 text-sm font-semibold text-cyan-200 hover:text-cyan-100" href="/releases">
            Открыть полный release control <ExternalLink className="size-4" />
          </Link>
        </div>
      ) : (
        <div className="grid gap-6 xl:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-emerald-300">Уже подтверждено</CardTitle>
              <CardDescription>Evidence, который можно повторно проверить.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
              {readiness.proven.map((item) => (
                <div key={item} className="flex items-start gap-3 rounded-md border border-emerald-400/15 bg-emerald-400/5 p-3 text-sm">
                  <CheckCircle2 className="mt-0.5 size-4 shrink-0 text-emerald-300" />
                  <span>{item}</span>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-amber-300">Финальные release-gates</CardTitle>
              <CardDescription>Пока любой пункт открыт, безусловный релиз не разрешён.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
              {readiness.final_gates.map((gate) => (
                <div key={gate.id} className="flex items-start justify-between gap-4 rounded-md border border-amber-400/15 bg-amber-400/5 p-3">
                  <span className="flex items-start gap-3 text-sm">
                    <CircleAlert className="mt-0.5 size-4 shrink-0 text-amber-300" />
                    {gate.label}
                  </span>
                  <Badge variant="warning">{gate.status.replaceAll("_", " ")}</Badge>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>
      )}
    </section>
  );
}
