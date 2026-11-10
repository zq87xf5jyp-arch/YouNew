import {
  BadgeCheck,
  Building2,
  CircleDollarSign,
  Clock3,
  Database,
  Download,
  Eye,
  Gauge,
  MousePointerClick,
  Repeat2,
  Search,
  ShieldCheck,
  UserCheck,
  Users
} from "lucide-react";
import { AnalyticsAutoRefresh } from "@/components/admin/analytics-auto-refresh";
import { AnalyticsTrendChart } from "@/components/admin/analytics-trend-chart";
import {
  AnalyticsFunnelChart,
  AnalyticsHorizontalBars,
  AnalyticsMetricGlossary,
  AnalyticsPeriodPicker,
  AnalyticsPlatformPicker,
  AnalyticsSourceMatrix
} from "@/components/admin/analytics-visuals";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { StatCard } from "@/components/admin/stat-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  analyticsEventLabel,
  buildAnalyticsDashboard,
  parseAnalyticsDays,
  parseAnalyticsPlatformScope,
  type AnalyticsDataRecency,
  type AnalyticsSourceHealthRow,
  type AnalyticsV2CompleteWeekRow,
  type AnalyticsV2DailyMetricRow,
  type AnalyticsV2EventMetricRow,
  type AnalyticsV2OverviewRow
} from "@/lib/analytics/dashboard";
import {
  buildAnalyticsInsights,
  type AnalyticsAudienceMetricRow,
  type AnalyticsConversionFunnelRow,
  type AnalyticsPageMetricRow,
  type AnalyticsSessionQualityRow,
  type AppStoreMetricRow
} from "@/lib/analytics/insights";
import { buildLaunchScorecard } from "@/lib/analytics/launch-scorecard";
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
const leadEventLabels: Record<string, string> = {
  lead_start: "Начало заполнения заявки",
  lead_submit: "Получен безопасный номер заявки",
  pilot_request: "Получен запрос на 90-дневный пилот"
};

function freshnessLabel(freshness: AnalyticsDataRecency) {
  switch (freshness) {
    case "recent": return "недавняя запись ≤ 6ч";
    case "quiet": return "нет новых событий 6–24ч";
    case "stale": return "нет новых событий > 24ч";
    case "no-data": return "данных нет";
  }
}

function freshnessVariant(freshness: AnalyticsDataRecency) {
  switch (freshness) {
    case "recent": return "success" as const;
    case "quiet": return "warning" as const;
    case "stale": return "destructive" as const;
    case "no-data": return "warning" as const;
  }
}

function durationLabel(seconds: number | null | undefined) {
  if (seconds === null || seconds === undefined || !Number.isFinite(seconds)) return "—";
  if (seconds < 60) return `${Math.round(seconds)} сек`;
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = Math.round(seconds % 60);
  return `${minutes} мин ${remainingSeconds} сек`;
}

export default async function AnalyticsPage({
  searchParams
}: {
  searchParams: Promise<{ days?: string; platform?: string }>;
}) {
  const params = await searchParams;
  const days = parseAnalyticsDays(params.days);
  const platform = parseAnalyticsPlatformScope(params.platform);
  const supabase = await createSupabaseServerClient();
  const now = new Date();
  const since = new Date(now);
  since.setUTCDate(since.getUTCDate() - (days - 1));
  const sinceDate = since.toISOString().slice(0, 10);
  const sinceTimestamp = `${sinceDate}T00:00:00.000Z`;

  const [
    overviewResult,
    dailyResult,
    eventMetricsResult,
    healthResult,
    searchGapsResult,
    searchTasksResult,
    pageMetricsResult,
    audienceResult,
    sessionQualityResult,
    conversionFunnelResult,
    leadFunnelResult,
    appStoreResult,
    appStoreSyncResult,
    businessResult,
    comparisonResult
  ] = supabase
    ? await (() => {
        let pageMetricsQuery = supabase
          .from("analytics_page_metrics_periods")
          .select("platform,screen,page_views,sessions,active_instances,key_actions,last_event_at")
          .eq("period_days", days)
          .order("page_views", { ascending: false })
          .limit(100);
        let audienceQuery = supabase
          .from("analytics_audience_metrics_periods")
          .select("platform,dimension,value,events,sessions,active_instances,last_event_at")
          .eq("period_days", days);
        let leadFunnelQuery = supabase
          .from("analytics_lead_funnel_periods")
          .select("platform,funnel_step,events,sessions,last_event_at")
          .eq("period_days", days);
        if (platform !== "All") {
          pageMetricsQuery = pageMetricsQuery.eq("platform", platform);
          audienceQuery = audienceQuery.eq("platform", platform);
          leadFunnelQuery = leadFunnelQuery.eq("platform", platform);
        }
        return Promise.all([
          supabase
            .from("analytics_v2_overview_periods")
            .select("period_days,platform_scope,period_start_at,period_end_at,event_count,active_instances,session_count,page_screen_views,search_events,source_open_events,key_action_events,error_events,explicit_city_detected_events,city_filter_applied_events,city_filter_corrected_events,local_result_available_events,national_fallback_shown_events,wrong_geo_result_reported_events,action_panel_cta_events,action_panel_cta_sessions,first_result_open_events,median_time_to_first_action_ms,last_event_at,last_ingested_at")
            .eq("period_days", days),
          supabase
            .from("analytics_v2_daily_metrics")
            .select("metric_date,platform_scope,event_count,active_instances,session_count,key_action_count,error_event_count,last_event_at,last_ingested_at")
            .eq("platform_scope", platform)
            .gte("metric_date", sinceDate)
            .order("metric_date", { ascending: true }),
          supabase
            .from("analytics_v2_event_metrics_periods")
            .select("period_days,platform_scope,event_name,event_count,active_instances,session_count,last_event_at,last_ingested_at")
            .eq("period_days", days)
            .eq("platform_scope", platform)
            .order("event_count", { ascending: false }),
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
            .limit(30),
          pageMetricsQuery,
          audienceQuery,
          supabase
            .from("analytics_v2_session_quality_periods")
            .select("platform_scope,session_count,matched_session_count,missing_session_count,platform_mismatch_count,engaged_session_count,average_duration_seconds_capped,median_duration_seconds,last_seen_at")
            .eq("period_days", days)
            .eq("platform_scope", platform),
          supabase
            .from("analytics_v2_funnel_periods")
            .select("platform_scope,funnel_step,events,sessions,last_event_at")
            .eq("period_days", days)
            .eq("platform_scope", platform),
          leadFunnelQuery,
          supabase
            .from("app_store_metrics_daily")
            .select("metric_date,territory,first_time_downloads,redownloads,updates,impressions,product_page_views,installations,app_sessions,crashes,synced_at")
            .gte("metric_date", sinceDate),
          supabase
            .from("analytics_source_sync_state")
            .select("status,last_attempt_at,last_success_at,latest_data_at,detail")
            .eq("source", "app_store_connect")
            .maybeSingle(),
          supabase
            .from("business_inquiries")
            .select("id", { count: "exact", head: true })
            .gte("created_at", sinceTimestamp),
          supabase
            .from("analytics_v2_complete_week_comparison")
            .select("platform_scope,current_start_at,current_end_at,previous_start_at,previous_end_at,current_events,previous_events,current_sessions,previous_sessions,current_key_actions,previous_key_actions")
            .eq("platform_scope", platform)
        ]);
      })()
    : Array.from({ length: 15 }, () => ({ data: null, count: null, error: new Error("not configured") }));

  const dashboard = buildAnalyticsDashboard({
    dailyRows: (dailyResult.data ?? []) as AnalyticsV2DailyMetricRow[],
    overviewRows: (overviewResult.data ?? []) as AnalyticsV2OverviewRow[],
    eventRows: (eventMetricsResult.data ?? []) as AnalyticsV2EventMetricRow[],
    sourceHealthRows: (healthResult.data ?? []) as AnalyticsSourceHealthRow[],
    comparisonRows: (comparisonResult.data ?? []) as AnalyticsV2CompleteWeekRow[],
    now,
    days,
    scope: platform
  });
  const insights = buildAnalyticsInsights({
    pageRows: (pageMetricsResult.data ?? []) as AnalyticsPageMetricRow[],
    audienceRows: (audienceResult.data ?? []) as AnalyticsAudienceMetricRow[],
    sessionRows: (sessionQualityResult.data ?? []) as AnalyticsSessionQualityRow[],
    funnelRows: (conversionFunnelResult.data ?? []) as AnalyticsConversionFunnelRow[],
    appStoreRows: (appStoreResult.data ?? []) as AppStoreMetricRow[]
  });
  const coreResults = [overviewResult, dailyResult, eventMetricsResult, sessionQualityResult, conversionFunnelResult, comparisonResult];
  const analyticsAvailable = Boolean(supabase) && coreResults.every((result) => !result.error);
  const healthAvailable = Boolean(supabase) && !healthResult.error;
  const searchConnected = Boolean(supabase) && !searchGapsResult.error && !searchTasksResult.error;
  const selectedSessions = insights.sessions.find((row) => row.platformScope === platform);
  const appStoreIntent = insights.funnel.find((row) => row.step === "app_store_intent");
  const searches = insights.funnel.find((row) => row.step === "search");
  const webPlatform = dashboard.platforms.find((row) => row.platform === "Web");
  const iOSPlatform = dashboard.platforms.find((row) => row.platform === "iOS");
  const lastIngested = dashboard.lastIngestedAt
    ? new Date(dashboard.lastIngestedAt).toLocaleString("ru-RU", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "Europe/Amsterdam"
      })
    : "не зафиксировано";
  const lastActivity = dashboard.lastEventAt
    ? new Date(dashboard.lastEventAt).toLocaleString("ru-RU", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "Europe/Amsterdam"
      })
    : "не зафиксирована";
  const appStoreSynced = insights.appStore.lastSyncedAt
    ? new Date(insights.appStore.lastSyncedAt).toLocaleString("ru-RU", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "Europe/Amsterdam"
      })
    : null;
  const appStoreSyncState = appStoreSyncResult.data as null | {
    status: "success" | "empty" | "error";
    last_attempt_at: string;
    last_success_at: string | null;
    latest_data_at: string | null;
    detail: string;
  };
  const appStoreSourceStatus = appStoreSyncResult.error
    ? "error" as const
    : appStoreSyncState?.status === "error"
      ? "error" as const
      : insights.appStore.sourceConnected
        ? "connected" as const
        : appStoreSyncState?.status === "success"
          ? "connected" as const
        : appStoreSyncState?.status === "empty"
          ? "empty" as const
          : "missing" as const;
  const platformRows = dashboard.platforms.map((platform) => ({
    platform: platform.platform,
    data_status: platform.hasData ? "available" : "no data",
    events: platform.hasData ? platform.events : "—",
    sessions: platform.hasData ? platform.sessions : "—",
    key_actions: platform.hasData ? platform.keyActions : "—",
    errors: platform.hasData ? platform.errors : "—"
  }));
  const eventRows = [
    ...dashboard.topEvents.map((event) => ({
      event: analyticsEventLabel(event.eventName),
      count: event.events
    })),
    ...(dashboard.otherEventCount > 0
      ? [{ event: "Остальные события", count: dashboard.otherEventCount }]
      : [])
  ];
  const pageRows = insights.pages.map((page) => ({
    screen: page.screen,
    platform: page.platform,
    views: page.pageViews,
    sessions: page.sessions,
    key_actions: page.keyActions,
    conversion: page.viewsPerSession === null ? "—" : `${ratioFormatter.format(page.viewsPerSession)} просмотра/сессию`
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
  const leadFunnelRows = (leadFunnelResult.data ?? []).map((row) => ({
    step: leadEventLabels[String(row.funnel_step)] ?? analyticsEventLabel(String(row.funnel_step)),
    platform: String(row.platform),
    events: Number(row.events ?? 0),
    sessions: Number(row.sessions ?? 0),
    last_event: row.last_event_at
  }));
  const changeNote = dashboard.comparison?.sessionChange === null || dashboard.comparison?.sessionChange === undefined
    ? "нет сопоставимой базы"
    : `${percentFormatter.format(dashboard.comparison.sessionChange)} по сессиям`;
  const comparisonWindow = dashboard.comparison
    ? `UTC [${dashboard.comparison.currentStartAt.slice(0, 10)}, ${dashboard.comparison.currentEndAt.slice(0, 10)}) vs [${dashboard.comparison.previousStartAt.slice(0, 10)}, ${dashboard.comparison.previousEndAt.slice(0, 10)})`
    : "7 полных UTC-дней vs предыдущие 7";
  const selectedDataAvailable = analyticsAvailable && dashboard.hasData;
  const metricValue = (value: number) => selectedDataAvailable ? integerFormatter.format(value) : "—";
  const sessionQualityAttention = Boolean(
    selectedSessions
    && (selectedSessions.missingSessions > 0 || selectedSessions.platformMismatchSessions > 0)
  );
  const appStoreDownloadsLabel = insights.appStore.firstTimeDownloads === null
    ? (appStoreSyncState?.status === "empty" ? "нет подтверждённых" : "—")
    : integerFormatter.format(insights.appStore.firstTimeDownloads);
  const geoRows = [
    { label: "Город распознан", value: dashboard.geo.explicitCityDetected },
    { label: "Фильтр города применён", value: dashboard.geo.cityFilterApplied },
    { label: "Город исправлен", value: dashboard.geo.cityFilterCorrected },
    { label: "Локальный результат", value: dashboard.geo.localResultAvailable },
    { label: "Национальный fallback", value: dashboard.geo.nationalFallbackShown },
    { label: "Жалоба на geo", value: dashboard.geo.wrongGeoResultReported },
    { label: "Первый результат открыт", value: dashboard.geo.firstResultOpened },
    { label: "CTA Action Panel", value: dashboard.geo.actionPanelCta }
  ];
  const launchMetrics = buildLaunchScorecard({
    analyticsAvailable,
    eventRows: (eventMetricsResult.data ?? []) as AnalyticsV2EventMetricRow[],
    pageRows: (pageMetricsResult.data ?? []) as AnalyticsPageMetricRow[],
    businessStoreAvailable: Boolean(supabase) && !businessResult.error,
    savedApplications: businessResult.count
  });
  const launchMetricValue = (metric: (typeof launchMetrics)[number]) => {
    if (metric.value === null) return "—";
    if (metric.unit === "eur") return new Intl.NumberFormat("nl-NL", { style: "currency", currency: "EUR" }).format(metric.value);
    return integerFormatter.format(metric.value);
  };
  const launchMetricIcon = (id: (typeof launchMetrics)[number]["id"]) => {
    if (id === "organic_visitors") return Search;
    if (id === "company_page_views") return Building2;
    if (id === "repeat_visits") return Repeat2;
    if (id === "applications_started") return MousePointerClick;
    if (id === "applications_saved") return BadgeCheck;
    if (id === "registered_companies") return UserCheck;
    if (id === "confirmed_partners") return ShieldCheck;
    return CircleDollarSign;
  };

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <PageHeader
          title="Аналитика"
          description="Посещения сайта, действия, качество сессий, бизнес-воронка и App Store — по отдельным проверяемым источникам без PII и выдуманных показателей."
        />
        <div className="flex flex-wrap items-center gap-3">
          <AnalyticsPlatformPicker days={days} platform={platform} />
          <AnalyticsPeriodPicker days={days} platform={platform} />
          <AnalyticsAutoRefresh />
        </div>
      </div>

      <section className="mt-5 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        <StatCard
          label={`${dashboard.labels.sessions} за ${days} дней`}
          value={metricValue(dashboard.totals.sessions)}
          note={selectedDataAvailable
            ? "Distinct session_id за весь период; не уникальные люди"
            : `Нет подтверждённых данных ${dashboard.labels.scope}`}
          icon={Users}
          tone={selectedDataAvailable ? "success" : "warning"}
        />
        <StatCard
          label={dashboard.labels.views}
          value={metricValue(dashboard.effectiveness.pageViews)}
          note={dashboard.effectiveness.pageViewsPerSession === null
            ? "На сессию: нет подтверждённых данных"
            : `${ratioFormatter.format(dashboard.effectiveness.pageViewsPerSession)} на сессию`}
          icon={Eye}
          tone="info"
        />
        <StatCard
          label="Вовлечённые сессии"
          value={selectedSessions?.engagementRate === null || selectedSessions?.engagementRate === undefined
            ? "—"
            : percentFormatter.format(selectedSessions.engagementRate)}
          note={selectedSessions
            ? `Длительность ≥ 10 сек среди ${selectedSessions.qualityEligibleSessions} platform-matched rows; coverage ${percentFormatter.format(selectedSessions.sessionRowCoverage ?? 0)}`
            : "Нет matched session rows"}
          icon={Gauge}
          tone={selectedSessions ? "success" : "warning"}
        />
        <StatCard
          label="Медианная длительность"
          value={durationLabel(selectedSessions?.medianDurationSeconds)}
          note={selectedSessions ? `Среднее с ограничением 30 мин: ${durationLabel(selectedSessions.averageDurationSecondsCapped)}` : "Нет подтверждённых сессий"}
          icon={Clock3}
          tone={selectedSessions ? "info" : "warning"}
        />
        <StatCard
          label="Поиски"
          value={selectedDataAvailable ? integerFormatter.format(searches?.events ?? 0) : "—"}
          note={selectedDataAvailable
            ? `${integerFormatter.format(searches?.sessions ?? 0)} сессий использовали поиск`
            : `Нет подтверждённых данных ${dashboard.labels.scope}`}
          icon={Search}
          tone={selectedDataAvailable && (searches?.events ?? 0) > 0 ? "success" : "warning"}
        />
        <StatCard
          label="Ключевые действия"
          value={metricValue(dashboard.totals.keyActions)}
          note={dashboard.effectiveness.keyActionsPerSession === null
            ? "На сессию: нет подтверждённых данных"
            : `${ratioFormatter.format(dashboard.effectiveness.keyActionsPerSession)} на сессию`}
          icon={MousePointerClick}
          tone={selectedDataAvailable ? "success" : "warning"}
        />
        <StatCard
          label="Переходы в App Store"
          value={selectedDataAvailable ? integerFormatter.format(appStoreIntent?.events ?? 0) : "—"}
          note="Клики по CTA; это не фактические загрузки"
          icon={MousePointerClick}
          tone={(appStoreIntent?.events ?? 0) > 0 ? "success" : "warning"}
        />
        <StatCard
          label="Первые загрузки App Store"
          value={appStoreDownloadsLabel}
          note={insights.appStore.sourceConnected
            ? `App Store Connect · синхронизация ${appStoreSynced ?? "не зафиксирована"}`
            : appStoreSyncState?.status === "empty"
              ? "Источник проверен: подтверждённых загрузок за период нет"
              : "Источник App Store Connect не синхронизирован; значение не равно нулю"}
          icon={Download}
          tone={appStoreSourceStatus === "connected" || appStoreSourceStatus === "empty" ? "success" : "warning"}
        />
        <StatCard
          label="Доля ошибок"
          value={selectedDataAvailable ? percentFormatter.format(dashboard.totals.errorRate) : "—"}
          note={selectedDataAvailable
            ? `${integerFormatter.format(dashboard.totals.errors)} error-событий из ${integerFormatter.format(dashboard.totals.events)}`
            : analyticsAvailable ? "Нет данных в выбранном scope" : "Агрегат недоступен"}
          icon={Database}
          tone={dashboard.totals.errors > 0 ? "warning" : "success"}
        />
      </section>

      <Card className="mt-6">
        <CardHeader className="flex-row flex-wrap items-start gap-3">
          <Gauge className="mt-1 text-cyan-200" />
          <div>
            <CardTitle>Launch KPI · без демонстрационных данных</CardTitle>
            <CardDescription>
              Значение «—» означает, что надёжный production-источник ещё не подключён. Ноль показывается только когда источник доступен и действительно пуст.
            </CardDescription>
          </div>
          <Badge className="ml-auto" variant={launchMetrics.every((metric) => metric.status !== "unavailable") ? "success" : "warning"}>
            {launchMetrics.filter((metric) => metric.status !== "unavailable").length}/{launchMetrics.length} KPI измеряются
          </Badge>
        </CardHeader>
        <CardContent>
          <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4" aria-label="Launch KPI scorecard">
            {launchMetrics.map((metric) => (
              <StatCard
                key={metric.id}
                label={metric.label}
                value={launchMetricValue(metric)}
                note={metric.evidence}
                icon={launchMetricIcon(metric.id)}
                tone={metric.status === "unavailable" ? "warning" : metric.status === "measured" ? "success" : "info"}
              />
            ))}
          </section>
        </CardContent>
      </Card>

      <div className="mt-6 grid gap-6">
        <Card>
          <CardHeader className="flex-row flex-wrap items-center gap-3">
            <ShieldCheck className="text-cyan-200" />
            <div>
              <CardTitle>Состояние сбора</CardTitle>
              <CardDescription>Защищённые агрегаты доступны только одобренным owner/admin согласно RLS.</CardDescription>
            </div>
            <div className="ml-auto flex flex-wrap gap-2">
              <Badge variant={analyticsAvailable ? "success" : "destructive"}>{analyticsAvailable ? `агрегаты ${dashboard.labels.scope} доступны` : "ошибка чтения агрегатов"}</Badge>
              <Badge variant={platform === "iOS" ? "warning" : searchConnected ? "success" : "warning"}>
                {platform === "iOS" ? "search-quality только Web" : searchConnected ? "поиск подключён" : "поиск недоступен"}
              </Badge>
              <Badge variant={healthAvailable ? freshnessVariant(dashboard.freshness) : "destructive"}>
                {healthAvailable ? freshnessLabel(dashboard.freshness) : "freshness недоступна"}
              </Badge>
              <Badge variant={dashboard.effectiveness.sampleEstablished ? "success" : "warning"}>
                {dashboard.effectiveness.sampleEstablished ? "выборка ≥ 20 сессий" : "выборка < 20 сессий"}
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
            <p>Последняя {dashboard.labels.activity}: <strong className="text-foreground">{lastActivity}</strong>; принятая запись: <strong className="text-foreground">{lastIngested}</strong> (Europe/Amsterdam).</p>
            <p>События телеметрии: <strong className="text-foreground">{metricValue(dashboard.totals.events)}</strong>; {changeNote}. Окна сравнения: {comparisonWindow}.</p>
            <p>Сырые события, свободные запросы, email, IP, рекламные ID и точная геолокация в dashboard не выводятся.</p>
            <p>Distinct sessions: {metricValue(dashboard.totals.sessions)}; matched session rows: {selectedSessions?.matchedSessions ?? "—"}; missing: {selectedSessions?.missingSessions ?? "—"}; platform mismatch: {selectedSessions?.platformMismatchSessions ?? "—"}. Доставка &gt;15 мин: {dashboard.delayedEvents}.</p>
          </CardContent>
        </Card>

        <AnalyticsSourceMatrix
          sources={[
            {
              id: "web",
              title: "Посещения younew.nl",
              detail: analyticsAvailable
                ? `${webPlatform?.events ?? 0} событий и ${webPlatform?.sessions ?? 0} exact-period сессий Web.`
                : "Защищённые Supabase-агрегаты не удалось прочитать.",
              status: analyticsAvailable ? (webPlatform?.hasData ? "connected" : "empty") : "error",
              kind: "web"
            },
            {
              id: "ios",
              title: "Использование iOS-приложения",
              detail: iOSPlatform?.hasData
                ? `${iOSPlatform.events} событий и ${iOSPlatform.sessions} сессий iOS.`
                : "iOS ingest отключён до отдельной privacy/security-проверки. Это no-data, а не сбой приложения.",
              status: analyticsAvailable ? (iOSPlatform?.hasData ? "connected" : "empty") : "error",
              kind: "database"
            },
            {
              id: "app-store",
              title: "Загрузки и установки App Store",
              detail: insights.appStore.sourceConnected
                ? `Первая загрузка: ${insights.appStore.firstTimeDownloads ?? "нет в отчёте"}; повторные: ${insights.appStore.redownloads ?? "нет в отчёте"}; обновления: ${insights.appStore.updates ?? "нет в отчёте"}.`
                : appStoreSyncState?.status === "empty"
                  ? "Ежедневный отчёт проверен; подтверждённых загрузок за доступный период нет. Web-клики не используются как замена."
                  : appStoreSyncState?.status === "error"
                    ? `Последняя синхронизация завершилась ошибкой: ${appStoreSyncState.detail}`
                    : "Для фактических загрузок нужен ежедневный отчёт App Store Connect. Web-клики намеренно не используются как замена.",
              status: appStoreSourceStatus,
              kind: "app-store"
            },
            {
              id: "business",
              title: "Бизнес-результаты",
              detail: businessResult.error
                ? "Агрегат business_inquiries недоступен."
                : `${businessResult.count ?? 0} полученных заявок за выбранный период.`,
              status: businessResult.error ? "error" : (businessResult.count ?? 0) > 0 ? "connected" : "empty",
              kind: "database"
            },
            {
              id: "quality",
              title: "Согласованность сессий",
              detail: sessionQualityAttention
                ? `${selectedSessions?.missingSessions ?? 0} session rows отсутствуюют; ${selectedSessions?.platformMismatchSessions ?? 0} имеют platform mismatch.`
                : dashboard.hasData
                  ? "Exact-period session denominator согласован; matched session rows используются только для duration quality."
                  : `Для ${dashboard.labels.scope} нет event-period denominator; session quality не вычисляется.`,
              status: !analyticsAvailable ? "error" : !dashboard.hasData ? "empty" : sessionQualityAttention ? "attention" : "connected",
              kind: "quality"
            },
            {
              id: "errors",
              title: "Ошибки и crashes",
              detail: dashboard.hasData
                ? `${dashboard.totals.errors} продуктовых error-событий. Отдельный crash-monitoring iOS/Sentry пока не является подтверждённым источником.`
                : `Для ${dashboard.labels.scope} нет product telemetry; нулевой error rate не заявляется.`,
              status: !analyticsAvailable ? "error" : !dashboard.hasData ? "empty" : dashboard.totals.errors > 0 ? "attention" : "missing",
              kind: "quality"
            }
          ]}
        />

        <AnalyticsTrendChart points={dashboard.trend} days={days} scopeLabel={dashboard.labels.scope} />

        <Card>
          <CardHeader>
            <CardTitle>Geo relevance и Action Panel · {dashboard.labels.scope}</CardTitle>
            <CardDescription>
              Только агрегированные consent-gated сигналы; city, intent, identifiers и event properties не выводятся.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
              {geoRows.map((row) => (
                <div className="rounded-xl border border-border/70 bg-background/35 p-4" key={row.label}>
                  <dt className="text-xs text-muted-foreground">{row.label}</dt>
                  <dd className="mt-1 text-xl font-semibold tabular-nums">{metricValue(row.value)}</dd>
                </div>
              ))}
            </dl>
            <p className="mt-4 text-sm text-muted-foreground">
              Медиана до первого действия: <strong className="text-foreground">{durationLabel(
                dashboard.geo.medianTimeToFirstActionMs === null
                  ? null
                  : dashboard.geo.medianTimeToFirstActionMs / 1_000
              )}</strong>. Action Panel CTA — contextual event; тот же клик уже считается как official-source key action и не добавляется в KPI второй раз.
            </p>
          </CardContent>
        </Card>

        <div className="grid gap-6 xl:grid-cols-2">
          <AnalyticsFunnelChart rows={insights.funnel} />
          <AnalyticsHorizontalBars
            title="Самые посещаемые страницы"
            description={`Top-10 путей за ${days} дней; query-параметры не сохраняются.`}
            rows={insights.pages.slice(0, 10).map((page) => ({
              label: platform === "All" ? `${page.platform} · ${page.screen}` : page.screen,
              value: page.pageViews,
              detail: `${page.sessions} сессий`
            }))}
            valueLabel="просмотров"
          />
        </div>

        <div className="grid gap-6 xl:grid-cols-3">
          <AnalyticsHorizontalBars
            title="Языки"
            description="Только группы с 3+ сессиями; это язык интерфейса, не гражданство."
            rows={(insights.audience.language ?? []).slice(0, 8).map((row) => ({
              label: platform === "All" ? `${row.platform} · ${row.value}` : row.value,
              value: row.sessions,
              detail: percentFormatter.format(row.share)
            }))}
          />
          <AnalyticsHorizontalBars
            title="Города"
            description="Только выбранный город в продукте и только при 3+ сессиях; точная геолокация не собирается."
            rows={(insights.audience.city ?? []).slice(0, 8).map((row) => ({
              label: platform === "All" ? `${row.platform} · ${row.value}` : row.value,
              value: row.sessions,
              detail: percentFormatter.format(row.share)
            }))}
          />
          <AnalyticsHorizontalBars
            title="Версии продукта"
            description="Версия Web/iOS из телеметрии, группы с 3+ сессиями."
            rows={(insights.audience.app_version ?? []).slice(0, 8).map((row) => ({
              label: `${row.platform} · ${row.value}`,
              value: row.sessions,
              detail: percentFormatter.format(row.share)
            }))}
          />
        </div>

        <div className="grid gap-6 xl:grid-cols-2">
          <CrudTable
            title={`Воронка заявок — ${days} дней`}
            description="Consented receipt-return events, not unique leads. Отправка считается только после возврата безопасного номера заявки; это не платёж."
            rows={leadFunnelRows}
            columns={["step", "platform", "events", "sessions", "last_event"]}
          />
          <CrudTable
            title={`Страницы — ${days} дней`}
            description="Просмотры, сессии, ключевые действия и глубина просмотра."
            rows={pageRows}
            columns={["screen", "platform", "views", "sessions", "key_actions", "conversion"]}
          />
          <CrudTable
            title="Основные события"
            description={`Top-12 и строка «Остальные» сходятся с total telemetry events за ${days} дней.`}
            rows={eventRows}
            columns={["event", "count"]}
          />
        </div>

        {platform !== "iOS" ? (
          <>
            <Card>
              <CardHeader className="flex-row items-start gap-3">
                <Search className="mt-1 text-cyan-200" />
                <div>
                  <CardTitle>Качество поиска Web</CardTitle>
                  <CardDescription>Только контролируемые нормализованные термины; свободный текст, email, телефоны и длинные идентификаторы отбрасываются до отправки.</CardDescription>
                </div>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                Этот source принадлежит Web и не выдаётся за iOS analytics. После 3 повторений zero-result сигнал становится задачей; после 10 — критической.
              </CardContent>
            </Card>
            <div className="grid gap-6 xl:grid-cols-2">
              <CrudTable
                title="Поисковые разрывы Web — 30 дней"
                description="Нули, средннее число результатов и переходы по результатам; фиксированное 30-дневное окно."
                rows={searchGapRows}
                columns={["query", "intent", "city", "category", "profile", "searches", "zero_results", "avg_results", "result_opens", "open_rate", "last_seen"]}
              />
              <CrudTable
                title="Автоматические задачи поиска Web"
                description="Повторяющиеся privacy-safe zero-result комбинации."
                rows={searchTaskRows}
                columns={["query", "intent", "city", "category", "profile", "occurrences", "status", "priority", "last_seen"]}
              />
            </div>
          </>
        ) : (
          <Card>
            <CardHeader><CardTitle>Search quality iOS не подключена</CardTitle></CardHeader>
            <CardContent className="text-sm text-muted-foreground">
              Web search-gap данны не показаны как iOS. Mobile ingest остаётся выключенным до privacy/security validation.
            </CardContent>
          </Card>
        )}

        <CrudTable
          title="Платформы"
          description={`Exact distinct period aggregates по Web и iOS за ${days} дней; строки не суммируют daily sessions.`}
          rows={platformRows}
          columns={["platform", "data_status", "events", "sessions", "key_actions", "errors"]}
        />

        <AnalyticsMetricGlossary />
      </div>
    </>
  );
}
