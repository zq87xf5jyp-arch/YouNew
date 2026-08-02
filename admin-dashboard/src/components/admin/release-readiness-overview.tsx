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
    value: `Version ${readiness.evidence.public_site.sites_version} LIVE`,
    note: `${readiness.evidence.public_site.html_files} HTML · ${readiness.evidence.public_site.tests_passed} тестов`,
    icon: Globe2
  },
  {
    label: "Admin",
    value: "Deployment LIVE",
    note: `${readiness.evidence.admin.tests_passed} тестов · CSP enforced`,
    icon: TestTube2
  },
  {
    label: "Supabase",
    value: "Recovery PASS",
    note: `${readiness.evidence.supabase.remote_migrations} migrations · isolated restore`,
    icon: Database
  },
  {
    label: "iOS Release",
    value: readiness.evidence.ios.release_status_label,
    note: readiness.evidence.ios.release_note,
    icon: Smartphone
  }
];

export function ReleaseReadinessOverview({ compact = false }: { compact?: boolean }) {
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
            <Badge variant="success">GO LIVE завершён</Badge>
            <span className="text-xs text-muted-foreground">Проверено {snapshotDate}</span>
          </div>
        </CardHeader>
        <CardContent className="grid gap-6 pt-5 xl:grid-cols-[250px_1fr]">
          <div className="rounded-xl border border-orange-400/25 bg-orange-400/10 p-5">
            <p className="text-3xl font-black tracking-tight text-orange-400">{readiness.release_status_label}</p>
            <p className="mt-2 text-sm font-semibold text-orange-100">Draft PR #{readiness.release_identity.draft_pr}</p>
            <p className="mt-3 text-xs leading-relaxed text-muted-foreground">
              {readiness.release_summary}
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
            {readiness.proven.length} подтверждённых контролей · {readiness.remaining_items.length} remaining items
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
              <CardTitle className="text-amber-300">Оставшиеся hardening items</CardTitle>
              <CardDescription>Product release завершён; эти пункты не являются release blockers.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3">
              {readiness.remaining_items.map((gate) => (
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
