import { Activity, Database, Gauge, ShieldCheck, Users } from "lucide-react";
import { AnalyticsAutoRefresh } from "@/components/admin/analytics-auto-refresh";
import { AnalyticsTrendChart } from "@/components/admin/analytics-trend-chart";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { StatCard } from "@/components/admin/stat-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  buildAnalyticsDashboard,
  type AnalyticsDailyMetricRow,
  type AnalyticsFunnelMetricRow,
  type AnalyticsSourceHealthRow
} from "@/lib/analytics/dashboard";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";
export const revalidate = 0;

const integerFormatter = new Intl.NumberFormat("ru-RU");
const percentFormatter = new Intl.NumberFormat("ru-RU", {
  style: "percent",
  maximumFractionDigits: 1
});

function freshnessLabel(freshness: ReturnType<typeof buildAnalyticsDashboard>["freshness"]) {
  switch (freshness) {
    case "fresh": return "свежие";
    case "delayed": return "задержка";
    case "stale": return "устарели";
    case "no-data": return "нет данных";
  }
}

function freshnessVariant(freshness: ReturnType<typeof buildAnalyticsDashboard>["freshness"]) {
  switch (freshness) {
    case "fresh": return "success" as const;
    case "delayed": return "warning" as const;
    case "stale": return "destructive" as const;
    case "no-data": return "warning" as const;
  }
}

export default async function AnalyticsPage() {
  const supabase = await createSupabaseServerClient();
  const now = new Date();
  const since = new Date(now);
  since.setUTCDate(since.getUTCDate() - 29);
  const sinceDate = since.toISOString().slice(0, 10);
  const [dailyResult, funnelResult, healthResult] = supabase
    ? await Promise.all([
        supabase
          .from("analytics_daily_metrics")
          .select("metric_date,platform,event_count,active_instances,session_count,key_action_count,error_event_count,last_ingested_at")
          .gte("metric_date", sinceDate)
          .order("metric_date", { ascending: true }),
        supabase
          .from("analytics_event_funnel_daily")
          .select("metric_date,platform,event_name,event_count")
          .gte("metric_date", sinceDate),
        supabase
          .from("analytics_source_health")
          .select("platform,total_events,active_instances,sessions,first_event_at,last_event_at,last_ingested_at,delayed_events,error_events")
      ])
    : [
        { data: null, error: new Error("not configured") },
        { data: null, error: new Error("not configured") },
        { data: null, error: new Error("not configured") }
      ];

  const dashboard = buildAnalyticsDashboard({
    dailyRows: (dailyResult.data ?? []) as AnalyticsDailyMetricRow[],
    funnelRows: (funnelResult.data ?? []) as AnalyticsFunnelMetricRow[],
    sourceHealthRows: (healthResult.data ?? []) as AnalyticsSourceHealthRow[],
    now
  });
  const connected = Boolean(supabase)
    && !dailyResult.error
    && !funnelResult.error
    && !healthResult.error;
  const lastIngested = dashboard.lastIngestedAt
    ? new Date(dashboard.lastIngestedAt).toLocaleString("ru-RU", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "Europe/Amsterdam"
      })
    : "не зафиксировано";
  const platformRows = dashboard.platforms.map((platform) => ({
    platform: platform.platform,
    events: platform.events,
    sessions: platform.sessions,
    key_actions: platform.keyActions,
    errors: platform.errors
  }));
  const eventRows = dashboard.topEvents.map((event) => ({
    event: event.eventName,
    count: event.events
  }));
  const changeNote = dashboard.sevenDayEventChange === null
    ? "Нет сопоставимого предыдущего 7-дневного периода"
    : `${percentFormatter.format(dashboard.sevenDayEventChange)} к предыдущим 7 дням`;

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <PageHeader
          title="Аналитика"
          description="Privacy-safe посещаемость сайта и приложения из production-агрегатов Supabase — без рекламных идентификаторов, поискового текста и выдуманных показателей."
        />
        <AnalyticsAutoRefresh />
      </div>
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Сессии за 30 дней"
          value={integerFormatter.format(dashboard.totals.sessions)}
          note="Посещения, не уникальные люди"
          icon={Users}
          tone="success"
        />
        <StatCard
          label="События за 30 дней"
          value={integerFormatter.format(dashboard.totals.events)}
          note={changeNote}
          icon={Activity}
          tone="info"
        />
        <StatCard
          label="Ключевые действия"
          value={integerFormatter.format(dashboard.totals.keyActions)}
          note="Открытия источников, сохранения и завершённые шаги"
          icon={Gauge}
          tone="success"
        />
        <StatCard
          label="Доля ошибок"
          value={percentFormatter.format(dashboard.totals.errorRate)}
          note={`${integerFormatter.format(dashboard.totals.errors)} error-событий из ${integerFormatter.format(dashboard.totals.events)}`}
          icon={Database}
          tone={dashboard.totals.errors > 0 ? "warning" : "success"}
        />
      </section>
      <div className="mt-6 grid gap-6">
        <Card>
          <CardHeader className="flex-row flex-wrap items-center gap-3">
            <ShieldCheck className="text-cyan-200" />
            <div>
              <CardTitle>Состояние сбора</CardTitle>
              <CardDescription>Агрегаты читаются только одобренными owner/admin согласно RLS.</CardDescription>
            </div>
            <div className="ml-auto flex flex-wrap gap-2">
              <Badge variant={connected ? "success" : "destructive"}>{connected ? "подключено" : "ошибка источника"}</Badge>
              <Badge variant={freshnessVariant(dashboard.freshness)}>{freshnessLabel(dashboard.freshness)}</Badge>
            </div>
          </CardHeader>
          <CardContent className="grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
            <p>Последняя принятая запись: <strong className="text-foreground">{lastIngested}</strong> (Europe/Amsterdam).</p>
            <p>Сырые события, свободные поисковые запросы и чувствительные пользовательские данные в дисплее не отображаются.</p>
          </CardContent>
        </Card>
        <AnalyticsTrendChart points={dashboard.trend} />
        <div className="grid gap-6 xl:grid-cols-2">
          <CrudTable
            title="Платформы"
            description="Согласованные 30-дневные агрегаты Website/iOS."
            rows={platformRows}
            columns={["platform", "events", "sessions", "key_actions", "errors"]}
          />
          <CrudTable
            title="Основные события"
            description="До 12 типов событий по убыванию объёма."
            rows={eventRows}
            columns={["event", "count"]}
          />
        </div>
      </div>
    </>
  );
}
