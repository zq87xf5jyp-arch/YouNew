import {
  Clock3,
  Database,
  Download,
  Eye,
  Gauge,
  MousePointerClick,
  Search,
  ShieldCheck,
  Users
} from "lucide-react";
import { AnalyticsAutoRefresh } from "@/components/admin/analytics-auto-refresh";
import { AnalyticsTrendChart } from "@/components/admin/analytics-trend-chart";
import {
  AnalyticsFunnelChart,
  AnalyticsHorizontalBars,
  AnalyticsMetricGlossary,
  AnalyticsPeriodPicker,
  AnalyticsSourceMatrix
} from "@/components/admin/analytics-visuals";
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
import {
  buildAnalyticsInsights,
  type AnalyticsAudienceMetricRow,
  type AnalyticsConversionFunnelRow,
  type AnalyticsPageMetricRow,
  type AnalyticsSessionQualityRow,
  type AppStoreMetricRow
} from "@/lib/analytics/insights";
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

function parseDays(value: string | undefined): 7 | 30 | 90 {
  return value === "7" || value === "90" ? Number(value) as 7 | 90 : 30;
}

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

function durationLabel(seconds: number | null | undefined) {
  if (seconds === null || seconds === undefined || !Number.isFinite(seconds)) return "—";
  if (seconds < 60) return `${Math.round(seconds)} сек`;
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = Math.round(seconds % 60);
  return `${minutes} мин ${remainingSeconds} сек`;
}

function eventLabel(event: string) {
  const labels: Record<string, string> = {
    page_view: "Просмотр страницы",
    screen_view: "Просмотр экрана",
    search: "Поиск",
    search_result_opened: "Открытие результата",
    official_source_click: "Переход к официальному источнику",
    official_source_opened: "Открытие официального источника",
    item_saved: "Сохранение материала",
    app_cta_click: "Переход в App Store",
    profile_selected: "Выбор профиля",
    business_mailto_prepared: "Начало бизнес-контакта",
    analytics_consent_granted: "Согласие на аналитику",
    app_error: "Ошибка приложения",
    sync_failed: "Ошибка синхронизации"
  };
  return labels[event] ?? event;
}

export default async function AnalyticsPage({
  searchParams
}: {
  searchParams: Promise<{ days?: string }>;
}) {
  const params = await searchParams;
  const days = parseDays(params.days);
  const supabase = await createSupabaseServerClient();
  const now = new Date();
  const since = new Date(now);
  since.setUTCDate(since.getUTCDate() - (days - 1));
  const sinceDate = since.toISOString().slice(0, 10);
  const sinceTimestamp = `${sinceDate}T00:00:00.000Z`;

  const [
    dailyResult,
    funnelResult,
    healthResult,
    searchGapsResult,
    searchTasksResult,
    pageMetricsResult,
    audienceResult,
    sessionQualityResult,
    conversionFunnelResult,
    appStoreResult,
    appStoreSyncResult,
    businessResult
  ] = supabase
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
          .limit(30),
        supabase
          .from("analytics_page_metrics_periods")
          .select("platform,screen,page_views,sessions,active_instances,key_actions,last_event_at")
          .eq("period_days", days)
          .order("page_views", { ascending: false })
          .limit(100),
        supabase
          .from("analytics_audience_metrics_periods")
          .select("platform,dimension,value,events,sessions,active_instances,last_event_at")
          .eq("period_days", days),
        supabase
          .from("analytics_session_quality_periods")
          .select("platform,sessions,engaged_sessions,average_duration_seconds_capped,median_duration_seconds,last_seen_at")
          .eq("period_days", days),
        supabase
          .from("analytics_conversion_funnel_periods")
          .select("platform,funnel_step,events,sessions,last_event_at")
          .eq("period_days", days),
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
          .gte("created_at", sinceTimestamp)
      ])
    : Array.from({ length: 12 }, () => ({ data: null, count: null, error: new Error("not configured") }));

  const dashboard = buildAnalyticsDashboard({
    dailyRows: (dailyResult.data ?? []) as AnalyticsDailyMetricRow[],
    funnelRows: (funnelResult.data ?? []) as AnalyticsFunnelMetricRow[],
    sourceHealthRows: (healthResult.data ?? []) as AnalyticsSourceHealthRow[],
    now,
    days
  });
  const insights = buildAnalyticsInsights({
    pageRows: (pageMetricsResult.data ?? []) as AnalyticsPageMetricRow[],
    audienceRows: (audienceResult.data ?? []) as AnalyticsAudienceMetricRow[],
    sessionRows: (sessionQualityResult.data ?? []) as AnalyticsSessionQualityRow[],
    funnelRows: (conversionFunnelResult.data ?? []) as AnalyticsConversionFunnelRow[],
    appStoreRows: (appStoreResult.data ?? []) as AppStoreMetricRow[]
  });
  const coreResults = [dailyResult, funnelResult, healthResult, pageMetricsResult, audienceResult, sessionQualityResult, conversionFunnelResult];
  const webConnected = Boolean(supabase) && coreResults.every((result) => !result.error);
  const searchConnected = Boolean(supabase) && !searchGapsResult.error && !searchTasksResult.error;
  const webSessions = insights.sessions.find((row) => row.platform.toLowerCase() === "web") ?? insights.sessions[0];
  const sessionsDifference = webSessions ? webSessions.sessions - dashboard.totals.sessions : 0;
  const appStoreIntent = insights.funnel.find((row) => row.step === "app_store_intent");
  const searches = insights.funnel.find((row) => row.step === "search");
  const iOSPlatform = dashboard.platforms.find((row) => row.platform.toLowerCase() === "ios");
  const lastIngested = dashboard.lastIngestedAt
    ? new Date(dashboard.lastIngestedAt).toLocaleString("ru-RU", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "Europe/Amsterdam"
      })
    : "не зафиксировано";
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
        : appStoreSyncState?.status === "empty"
          ? "empty" as const
          : "missing" as const;
  const platformRows = dashboard.platforms.map((platform) => ({
    platform: platform.platform,
    events: platform.events,
    sessions: platform.sessions,
    key_actions: platform.keyActions,
    errors: platform.errors
  }));
  const eventRows = dashboard.topEvents.map((event) => ({
    event: eventLabel(event.eventName),
    count: event.events
  }));
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
  const changeNote = dashboard.sevenDayEventChange === null
    ? "Нет сопоставимого предыдущего 7-дневного периода"
    : `${percentFormatter.format(dashboard.sevenDayEventChange)} к предыдущим 7 дням`;
  const appStoreDownloadsLabel = insights.appStore.firstTimeDownloads === null
    ? (appStoreSyncState?.status === "empty" ? "нет подтверждённых" : "—")
    : integerFormatter.format(insights.appStore.firstTimeDownloads);

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <PageHeader
          title="Аналитика"
          description="Посещения сайта, действия, качество сессий, бизнес-воронка и App Store — по отдельным проверяемым источникам без PII и выдуманных показателей."
        />
        <div className="flex flex-wrap items-center gap-3">
          <AnalyticsPeriodPicker days={days} />
          <AnalyticsAutoRefresh />
        </div>
      </div>

      <section className="mt-5 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        <StatCard
          label={`Сессии за ${days} дней`}
          value={integerFormatter.format(dashboard.totals.sessions)}
          note="Анонимные посещения, не уникальные люди"
          icon={Users}
          tone={dashboard.totals.sessions > 0 ? "success" : "warning"}
        />
        <StatCard
          label="Просмотры страниц"
          value={integerFormatter.format(dashboard.effectiveness.pageViews)}
          note={dashboard.effectiveness.pageViewsPerSession === null
            ? "На сессию: нет подтверждённых данных"
            : `${ratioFormatter.format(dashboard.effectiveness.pageViewsPerSession)} на сессию`}
          icon={Eye}
          tone="info"
        />
        <StatCard
          label="Вовлечённые сессии"
          value={webSessions?.engagementRate === null || webSessions?.engagementRate === undefined
            ? "—"
            : percentFormatter.format(webSessions.engagementRate)}
          note="Длительность ≥ 10 секунд; диагностический порог"
          icon={Gauge}
          tone={webSessions ? "success" : "warning"}
        />
        <StatCard
          label="Медианная длительность"
          value={durationLabel(webSessions?.medianDurationSeconds)}
          note={webSessions ? `Среднее с ограничением 30 мин: ${durationLabel(webSessions.averageDurationSecondsCapped)}` : "Нет подтверждённых сессий"}
          icon={Clock3}
          tone={webSessions ? "info" : "warning"}
        />
        <StatCard
          label="Поиски"
          value={integerFormatter.format(searches?.events ?? 0)}
          note={`${integerFormatter.format(searches?.sessions ?? 0)} сессий использовали поиск`}
          icon={Search}
          tone={(searches?.events ?? 0) > 0 ? "success" : "warning"}
        />
        <StatCard
          label="Ключевые действия"
          value={integerFormatter.format(dashboard.totals.keyActions)}
          note={dashboard.effectiveness.keyActionsPerSession === null
            ? "На сессию: нет подтверждённых данных"
            : `${ratioFormatter.format(dashboard.effectiveness.keyActionsPerSession)} на сессию`}
          icon={MousePointerClick}
          tone="success"
        />
        <StatCard
          label="Переходы в App Store"
          value={integerFormatter.format(appStoreIntent?.events ?? 0)}
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
              <CardDescription>Защищённые агрегаты доступны только одобренным owner/admin согласно RLS.</CardDescription>
            </div>
            <div className="ml-auto flex flex-wrap gap-2">
              <Badge variant={webConnected ? "success" : "destructive"}>{webConnected ? "Web подключён" : "ошибка Web-источника"}</Badge>
              <Badge variant={searchConnected ? "success" : "warning"}>{searchConnected ? "поиск подключён" : "поиск недоступен"}</Badge>
              <Badge variant={freshnessVariant(dashboard.freshness)}>{freshnessLabel(dashboard.freshness)}</Badge>
              <Badge variant={dashboard.effectiveness.sampleEstablished ? "success" : "warning"}>
                {dashboard.effectiveness.sampleEstablished ? "выборка ≥ 20 сессий" : "выборка < 20 сессий"}
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
            <p>Последняя принятая Web-запись: <strong className="text-foreground">{lastIngested}</strong> (Europe/Amsterdam).</p>
            <p>Всего событий: <strong className="text-foreground">{integerFormatter.format(dashboard.totals.events)}</strong>; изменение: {changeNote}.</p>
            <p>Сырые события, свободные запросы, email, IP, рекламные ID и точная геолокация в dashboard не выводятся.</p>
            <p>Сессии по событиям: {dashboard.totals.sessions}; сессии в session-агрегате: {webSessions?.sessions ?? "—"}. {sessionsDifference === 0 ? "Показатели согласованы." : `Расхождение ${Math.abs(sessionsDifference)} — отмечено как контроль качества.`}</p>
          </CardContent>
        </Card>

        <AnalyticsSourceMatrix
          sources={[
            {
              id: "web",
              title: "Посещения younew.nl",
              detail: webConnected
                ? `${dashboard.totals.events} событий и ${dashboard.totals.sessions} сессий за выбранный период; последняя запись ${lastIngested}.`
                : "Защищённые Supabase-агрегаты не удалось прочитать.",
              status: webConnected ? (dashboard.totals.sessions > 0 ? "connected" : "empty") : "error",
              kind: "web"
            },
            {
              id: "ios",
              title: "Использование iOS-приложения",
              detail: iOSPlatform
                ? `${iOSPlatform.events} событий и ${iOSPlatform.sessions} сессий iOS.`
                : "iOS production-события в Supabase не поступали. Это отсутствие подтверждённых данных, а не отказ приложения.",
              status: iOSPlatform ? "connected" : "empty",
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
                : `${businessResult.count ?? 0} подтверждённых заявок за выбранный период.`,
              status: businessResult.error ? "error" : (businessResult.count ?? 0) > 0 ? "connected" : "empty",
              kind: "database"
            },
            {
              id: "quality",
              title: "Согласованность сессий",
              detail: sessionsDifference === 0
                ? "Сессионный агрегат согласован с distinct session_id событий."
                : `Session-агрегат отличается от distinct session_id событий на ${Math.abs(sessionsDifference)}. До устранения обе цифры показываются явно.`,
              status: sessionsDifference === 0 ? "connected" : "attention",
              kind: "quality"
            },
            {
              id: "errors",
              title: "Ошибки и crashes",
              detail: `${dashboard.totals.errors} продуктовых error-событий. Отдельный crash-monitoring iOS/Sentry пока не является подтверждённым источником.`,
              status: dashboard.totals.errors > 0 ? "attention" : "missing",
              kind: "quality"
            }
          ]}
        />

        <AnalyticsTrendChart points={dashboard.trend} days={days} />

        <div className="grid gap-6 xl:grid-cols-2">
          <AnalyticsFunnelChart rows={insights.funnel} />
          <AnalyticsHorizontalBars
            title="Самые посещаемые страницы"
            description={`Top-10 путей за ${days} дней; query-параметры не сохраняются.`}
            rows={insights.pages.slice(0, 10).map((page) => ({
              label: page.screen,
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
              label: row.value,
              value: row.sessions,
              detail: percentFormatter.format(row.share)
            }))}
          />
          <AnalyticsHorizontalBars
            title="Города"
            description="Только выбранный город в продукте и только при 3+ сессиях; точная геолокация не собирается."
            rows={(insights.audience.city ?? []).slice(0, 8).map((row) => ({
              label: row.value,
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
            title={`Страницы — ${days} дней`}
            description="Просмотры, сессии, ключевые действия и глубина просмотра."
            rows={pageRows}
            columns={["screen", "platform", "views", "sessions", "key_actions", "conversion"]}
          />
          <CrudTable
            title="Основные события"
            description={`Типы production-событий за ${days} дней по убыванию объёма.`}
            rows={eventRows}
            columns={["event", "count"]}
          />
        </div>

        <Card>
          <CardHeader className="flex-row items-start gap-3">
            <Search className="mt-1 text-cyan-200" />
            <div>
              <CardTitle>Качество поиска</CardTitle>
              <CardDescription>Только контролируемые нормализованные термины; свободный текст, email, телефоны и длинные идентификаторы отбрасываются до отправки.</CardDescription>
            </div>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            Нулевые ответы группируются по запросу и активным фильтрам. После 3 повторений сигнал становится открытой задачей; после 10 — критической.
          </CardContent>
        </Card>

        <div className="grid gap-6 xl:grid-cols-2">
          <CrudTable
            title="Поисковые разрывы — 30 дней"
            description="Нули, среднее число результатов и переходы по результатам. Этот источник использует фиксированное 30-дневное окно."
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

        <CrudTable
          title="Платформы"
          description={`Согласованные агрегаты Website/iOS за ${days} дней.`}
          rows={platformRows}
          columns={["platform", "events", "sessions", "key_actions", "errors"]}
        />

        <AnalyticsMetricGlossary />
      </div>
    </>
  );
}
