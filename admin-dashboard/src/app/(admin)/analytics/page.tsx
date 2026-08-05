import { Activity, Database, Gauge, Search, ShieldCheck, Users } from "lucide-react";
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
const ratioFormatter = new Intl.NumberFormat("ru-RU", {
  minimumFractionDigits: 0,
  maximumFractionDigits: 2
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
  const [dailyResult, funnelResult, healthResult, searchGapsResult, searchTasksResult] = supabase
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
          .select("platform,total_events,active_instances,sessions,first_event_at,last_event_at,last_ingested_at,delayed_events,error_events"),
        supabase
          .from("analytics_search_gaps")
          .select("normalized_query_safe,intent_ids,filter_city,filter_category,filter_profile,search_count,zero_result_count,average_result_count,result_open_count,result_open_rate,last_searched_at")
          .order("zero_result_count", { ascending: false })
          .order("search_count", { ascending: false })
          .limit(30),
        supabase
          .from("search_improvement_tasks")
          .select("normalized_query_safe,intent_ids,filter_city,filter_category,filter_profile,occurrence_count,status,priority,last_seen_at")
          .in("status", ["observed", "open", "in_progress"])
          .order("occurrence_count", { ascending: false })
          .limit(30)
      ])
    : [
        { data: null, error: new Error("not configured") },
        { data: null, error: new Error("not configured") },
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
    && !healthResult.error
    && !searchGapsResult.error
    && !searchTasksResult.error;
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
  const searchGapRows = (searchGapsResult.data ?? []).map((row) => ({
    query: row.normalized_query_safe,
    intent: row.intent_ids,
    city: row.filter_city,
    category: row.filter_category,
    profile: row.filter_profile,
    searches: row.search_count,
    zero_results: row.zero_result_count,
    avg_results: row.average_result_count,
    result_opens: row.result_open_count,
    open_rate: percentFormatter.format(Number(row.result_open_rate ?? 0)),
    last_seen: row.last_searched_at
  }));
  const searchTaskRows = (searchTasksResult.data ?? []).map((row) => ({
    query: row.normalized_query_safe,
    intent: row.intent_ids,
    city: row.filter_city,
    category: row.filter_category,
    profile: row.filter_profile,
    occurrences: row.occurrence_count,
    status: row.status,
    priority: row.priority,
    last_seen: row.last_seen_at
  }));
  const changeNote = dashboard.sevenDayEventChange === null
    ? "Нет сопоставимого предыдущего 7-дневного периода"
    : `${percentFormatter.format(dashboard.sevenDayEventChange)} к предыдущим 7 дням`;

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <PageHeader
          title="Аналитика"
          description="Эффективность production-сайта и приложения по privacy-safe агрегатам Supabase. Hostinger analytics не используется: домен younew.nl обслуживается через Sites."
        />
        <AnalyticsAutoRefresh />
      </div>
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        <StatCard
          label="Сессии за 30 дней"
          value={integerFormatter.format(dashboard.totals.sessions)}
          note="Посещения, не уникальные люди"
          icon={Users}
          tone="success"
        />
        <StatCard
          label="Просмотры страниц"
          value={integerFormatter.format(dashboard.effectiveness.pageViews)}
          note={dashboard.effectiveness.pageViewsPerSession === null
            ? "На сессию: not established"
            : `${ratioFormatter.format(dashboard.effectiveness.pageViewsPerSession)} на сессию`}
          icon={Activity}
          tone="info"
        />
        <StatCard
          label="Открытия источников"
          value={integerFormatter.format(dashboard.effectiveness.sourceOpens)}
          note={dashboard.effectiveness.sourceOpensPerSession === null
            ? "На сессию: not established"
            : `${ratioFormatter.format(dashboard.effectiveness.sourceOpensPerSession)} на сессию`}
          icon={Gauge}
          tone="success"
        />
        <StatCard
          label="Ключевые действия"
          value={integerFormatter.format(dashboard.totals.keyActions)}
          note={dashboard.effectiveness.keyActionsPerSession === null
            ? "На сессию: not established"
            : `${ratioFormatter.format(dashboard.effectiveness.keyActionsPerSession)} на сессию`}
          icon={Gauge}
          tone="success"
        />
        <StatCard
          label="Все события"
          value={integerFormatter.format(dashboard.totals.events)}
          note={changeNote}
          icon={Activity}
          tone="info"
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
              <Badge variant={dashboard.effectiveness.sampleEstablished ? "success" : "warning"}>
                {dashboard.effectiveness.sampleEstablished ? "выборка установлена" : "выборка < 20 сессий"}
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
            <p>Последняя принятая запись: <strong className="text-foreground">{lastIngested}</strong> (Europe/Amsterdam).</p>
            <p>Источник: production-агрегаты Supabase. Hostinger считает запросы отдельной неподключённой копии и не является источником посещаемости younew.nl.</p>
            <p>Сырые события, свободные поисковые запросы и чувствительные пользовательские данные в дисплее не отображаются.</p>
            <p>Показатели на сессию диагностические: они не доказывают ценность или причинный эффект без достаточной выборки и исследования пользователей.</p>
          </CardContent>
        </Card>
        <AnalyticsTrendChart points={dashboard.trend} />
        <Card>
          <CardHeader className="flex-row items-start gap-3">
            <Search className="mt-1 text-cyan-200" />
            <div>
              <CardTitle>Качество поиска</CardTitle>
              <CardDescription>Только контролируемые нормализованные термины; свободный текст, email, телефоны и длинные идентификаторы отбрасываются до отправки.</CardDescription>
            </div>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            Нулевые ответы группируются по запросу и активным фильтрам. После 3 повторений сигнал автоматически становится открытой задачей; после 10 — критической.
          </CardContent>
        </Card>
        <div className="grid gap-6 xl:grid-cols-2">
          <CrudTable
            title="Поисковые разрывы — 30 дней"
            description="Нули, среднее число результатов и переходы по результатам."
            rows={searchGapRows}
            columns={["query", "intent", "city", "category", "profile", "searches", "zero_results", "avg_results", "result_opens", "open_rate", "last_seen"]}
          />
          <CrudTable
            title="Автоматические задачи поиска"
            description="Повторяющиеся privacy-safe zero-result комбинации."
            rows={searchTaskRows}
            columns={["query", "intent", "city", "category", "profile", "occurrences", "status", "priority", "last_seen"]}
          />
        </div>
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
