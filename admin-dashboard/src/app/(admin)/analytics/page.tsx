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

type SearchIntentMetricRow = {
  metric_date: string;
  language: string;
  intent_id: string;
  search_count: number;
  zero_result_count: number;
  opened_result_count: number;
  last_search_at: string;
};

type SearchZeroFilterRow = {
  language: string;
  intent_id: string;
  type_filter: string | null;
  city_id: string | null;
  province_id: string | null;
  category_id: string | null;
  profile_id: string | null;
  location_scope: string;
  zero_result_count: number;
  last_zero_at: string;
};

type SearchLowClickRow = {
  language: string;
  intent_id: string;
  search_count: number;
  opened_result_count: number;
  open_rate_percent: number;
};

type SearchImprovementTaskRow = {
  id: string;
  status: string;
  language: string;
  intent_id: string;
  type_filter: string | null;
  city_id: string | null;
  province_id: string | null;
  category_id: string | null;
  profile_id: string | null;
  location_scope: string;
  zero_event_count: number;
  first_observed_at: string;
  last_observed_at: string;
};

export default async function AnalyticsPage() {
  const supabase = await createSupabaseServerClient();
  const now = new Date();
  const since = new Date(now);
  since.setUTCDate(since.getUTCDate() - 29);
  const sinceDate = since.toISOString().slice(0, 10);
  const [dailyResult, funnelResult, healthResult, searchIntentResult, searchZeroResult, searchLowClickResult, searchTaskResult] = supabase
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
          .from("analytics_search_intent_daily")
          .select("metric_date,language,intent_id,search_count,zero_result_count,opened_result_count,last_search_at")
          .gte("metric_date", sinceDate)
          .order("metric_date", { ascending: false })
          .limit(1000),
        supabase
          .from("analytics_search_zero_filters")
          .select("language,intent_id,type_filter,city_id,province_id,category_id,profile_id,location_scope,zero_result_count,last_zero_at")
          .order("zero_result_count", { ascending: false })
          .limit(100),
        supabase
          .from("analytics_search_low_click_intents")
          .select("language,intent_id,search_count,opened_result_count,open_rate_percent")
          .order("open_rate_percent", { ascending: true })
          .limit(100),
        supabase
          .from("search_improvement_tasks")
          .select("id,status,language,intent_id,type_filter,city_id,province_id,category_id,profile_id,location_scope,zero_event_count,first_observed_at,last_observed_at")
          .in("status", ["open", "in_progress"])
          .order("last_observed_at", { ascending: false })
          .limit(100)
      ])
    : [
        { data: null, error: new Error("not configured") },
        { data: null, error: new Error("not configured") },
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
    && !healthResult.error;
  const searchAnalyticsConnected = Boolean(supabase)
    && !searchIntentResult.error
    && !searchZeroResult.error
    && !searchLowClickResult.error
    && !searchTaskResult.error;
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
  const searchIntentTotals = new Map<string, {
    language: string;
    intent: string;
    searches: number;
    zeroResults: number;
    openedResults: number;
  }>();
  for (const row of (searchIntentResult.data ?? []) as SearchIntentMetricRow[]) {
    const key = `${row.language}:${row.intent_id}`;
    const current = searchIntentTotals.get(key) ?? {
      language: row.language,
      intent: row.intent_id,
      searches: 0,
      zeroResults: 0,
      openedResults: 0
    };
    current.searches += Number(row.search_count);
    current.zeroResults += Number(row.zero_result_count);
    current.openedResults += Number(row.opened_result_count);
    searchIntentTotals.set(key, current);
  }
  const searchIntentRows = [...searchIntentTotals.values()]
    .sort((left, right) => right.searches - left.searches)
    .slice(0, 20)
    .map((row) => ({
      language: row.language,
      intent: row.intent,
      searches: row.searches,
      zero_rate: row.searches ? percentFormatter.format(row.zeroResults / row.searches) : "0%",
      open_rate: row.searches ? percentFormatter.format(row.openedResults / row.searches) : "0%"
    }));
  const zeroFilterRows = ((searchZeroResult.data ?? []) as SearchZeroFilterRow[]).map((row) => ({
    language: row.language,
    intent: row.intent_id,
    scope: row.location_scope,
    filters: [row.type_filter, row.city_id, row.province_id, row.category_id, row.profile_id].filter(Boolean).join(" · ") || "без фильтров",
    zeros: row.zero_result_count,
    last_zero: new Date(row.last_zero_at).toLocaleString("ru-RU", { timeZone: "Europe/Amsterdam" })
  }));
  const lowClickRows = ((searchLowClickResult.data ?? []) as SearchLowClickRow[]).map((row) => ({
    language: row.language,
    intent: row.intent_id,
    searches: row.search_count,
    opened: row.opened_result_count,
    open_rate: `${row.open_rate_percent}%`
  }));
  const taskRows = ((searchTaskResult.data ?? []) as SearchImprovementTaskRow[]).map((row) => ({
    status: row.status,
    language: row.language,
    intent: row.intent_id,
    scope: row.location_scope,
    filters: [row.type_filter, row.city_id, row.province_id, row.category_id, row.profile_id].filter(Boolean).join(" · ") || "без фильтров",
    zeros_7d: row.zero_event_count,
    last_seen: new Date(row.last_observed_at).toLocaleString("ru-RU", { timeZone: "Europe/Amsterdam" })
  }));

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
          <CardHeader className="flex-row flex-wrap items-center gap-3">
            <Search className="text-cyan-200" />
            <div>
              <CardTitle>Качество поиска</CardTitle>
              <CardDescription>Только канонические intents, диапазоны и фильтры — свободный текст запросов не отправляется и не хранится.</CardDescription>
            </div>
            <Badge className="ml-auto" variant={searchAnalyticsConnected ? "success" : "warning"}>
              {searchAnalyticsConnected ? "privacy-safe источник подключён" : "ожидается миграция источника"}
            </Badge>
          </CardHeader>
          <CardContent className="grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
            <p>Нулевой результат создаёт задачу только после трёх эквивалентных сигналов за 7 дней.</p>
            <p>Открытие результата связывается случайным search_id; идентификатор не содержит текст запроса или пользователя.</p>
          </CardContent>
        </Card>
        <div className="grid gap-6 xl:grid-cols-2">
          <CrudTable
            title="Популярные поисковые intents"
            description="30 дней · это категории намерений, а не сохранённые поисковые фразы."
            rows={searchIntentRows}
            columns={["language", "intent", "searches", "zero_rate", "open_rate"]}
          />
          <CrudTable
            title="Повторяющиеся нулевые результаты"
            description="Показываются только группы с минимум тремя событиями."
            rows={zeroFilterRows}
            columns={["language", "intent", "scope", "filters", "zeros", "last_zero"]}
          />
          <CrudTable
            title="Низкое открытие результатов"
            description="Группы с минимум тремя поисками и опубликованными результатами."
            rows={lowClickRows}
            columns={["language", "intent", "searches", "opened", "open_rate"]}
          />
          <CrudTable
            title="Автоматические content-gap задачи"
            description="Открытые и выполняемые задачи, созданные повторяемыми zero-result сигналами."
            rows={taskRows}
            columns={["status", "language", "intent", "scope", "filters", "zeros_7d", "last_seen"]}
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
