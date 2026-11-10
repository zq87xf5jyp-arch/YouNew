export type AnalyticsPeriodDays = 7 | 30 | 90;
export type AnalyticsPlatform = "Web" | "iOS";
export type AnalyticsPlatformScope = AnalyticsPlatform | "All";
export type AnalyticsDataRecency = "recent" | "quiet" | "stale" | "no-data";

type CountValue = number | string | null;

export type AnalyticsV2DailyMetricRow = {
  metric_date: string;
  platform_scope: string;
  event_count: CountValue;
  active_instances: CountValue;
  session_count: CountValue;
  key_action_count: CountValue;
  error_event_count: CountValue;
  last_event_at: string | null;
  last_ingested_at: string | null;
};

export type AnalyticsV2OverviewRow = {
  period_days: CountValue;
  platform_scope: string;
  period_start_at: string;
  period_end_at: string;
  event_count: CountValue;
  active_instances: CountValue;
  session_count: CountValue;
  page_screen_views: CountValue;
  search_events: CountValue;
  source_open_events: CountValue;
  key_action_events: CountValue;
  error_events: CountValue;
  explicit_city_detected_events: CountValue;
  city_filter_applied_events: CountValue;
  city_filter_corrected_events: CountValue;
  local_result_available_events: CountValue;
  national_fallback_shown_events: CountValue;
  wrong_geo_result_reported_events: CountValue;
  action_panel_cta_events: CountValue;
  action_panel_cta_sessions: CountValue;
  first_result_open_events: CountValue;
  median_time_to_first_action_ms: CountValue;
  last_event_at: string | null;
  last_ingested_at: string | null;
};

export type AnalyticsV2EventMetricRow = {
  period_days: CountValue;
  platform_scope: string;
  event_name: string;
  event_count: CountValue;
  active_instances: CountValue;
  session_count: CountValue;
  last_event_at: string | null;
  last_ingested_at: string | null;
};

export type AnalyticsV2CompleteWeekRow = {
  platform_scope: string;
  current_start_at: string;
  current_end_at: string;
  previous_start_at: string;
  previous_end_at: string;
  current_events: CountValue;
  previous_events: CountValue;
  current_sessions: CountValue;
  previous_sessions: CountValue;
  current_key_actions: CountValue;
  previous_key_actions: CountValue;
};

export type AnalyticsSourceHealthRow = {
  platform: string;
  total_events: CountValue;
  active_instances: CountValue;
  sessions: CountValue;
  first_event_at: string | null;
  last_event_at: string | null;
  last_ingested_at: string | null;
  delayed_events: CountValue;
  error_events: CountValue;
};

export type AnalyticsTrendPoint = {
  date: string;
  events: number;
  sessions: number;
  keyActions: number;
  errors: number;
};

export type AnalyticsPlatformSummary = {
  platform: AnalyticsPlatform;
  events: number;
  sessions: number;
  keyActions: number;
  errors: number;
  hasData: boolean;
};

export type AnalyticsEventSummary = {
  eventName: string;
  events: number;
};

export type AnalyticsScopeLabels = {
  scope: string;
  sessions: string;
  views: string;
  activity: string;
};

export type AnalyticsDashboardData = {
  scope: AnalyticsPlatformScope;
  hasData: boolean;
  labels: AnalyticsScopeLabels;
  trend: AnalyticsTrendPoint[];
  platforms: AnalyticsPlatformSummary[];
  topEvents: AnalyticsEventSummary[];
  otherEventCount: number;
  totals: {
    events: number;
    sessions: number;
    activeInstances: number;
    keyActions: number;
    errors: number;
    errorRate: number;
  };
  effectiveness: {
    pageViews: number;
    searches: number;
    sourceOpens: number;
    pageViewsPerSession: number | null;
    sourceOpensPerSession: number | null;
    keyActionsPerSession: number | null;
    sampleEstablished: boolean;
  };
  geo: {
    explicitCityDetected: number;
    cityFilterApplied: number;
    cityFilterCorrected: number;
    localResultAvailable: number;
    nationalFallbackShown: number;
    wrongGeoResultReported: number;
    firstResultOpened: number;
    actionPanelCta: number;
    actionPanelCtaSessions: number;
    medianTimeToFirstActionMs: number | null;
  };
  comparison: null | {
    currentStartAt: string;
    currentEndAt: string;
    previousStartAt: string;
    previousEndAt: string;
    currentEvents: number;
    previousEvents: number;
    currentSessions: number;
    previousSessions: number;
    currentKeyActions: number;
    previousKeyActions: number;
    sessionChange: number | null;
    eventChange: number | null;
  };
  lastEventAt: string | null;
  lastIngestedAt: string | null;
  delayedEvents: number;
  freshness: AnalyticsDataRecency;
};

const platforms: AnalyticsPlatform[] = ["Web", "iOS"];

const eventLabels: Record<string, string> = {
  page_view: "Просмотр страницы",
  screen_view: "Просмотр экрана",
  search: "Поиск Web",
  search_submitted: "Поиск iOS",
  search_result_opened: "Открытие результата",
  official_source_click: "Переход к официальному источнику",
  official_source_opened: "Открытие официального источника",
  item_saved: "Сохранение материала",
  guide_step_completed: "Завершение шага гайда",
  app_cta_click: "Переход в App Store",
  profile_selected: "Выбор профиля",
  business_mailto_prepared: "Начало бизнес-контакта",
  lead_start: "Начало заполнения заявки",
  lead_submit: "Получен безопасный номер заявки",
  pilot_request: "Получен запрос на 90-дневный пилот",
  analytics_consent_granted: "Согласие на аналитику",
  analytics_consent_revoked: "Отзыв согласия на аналитику",
  explicit_city_detected: "Город распознан в запросе",
  city_filter_applied: "Фильтр города применён",
  city_filter_corrected: "Город исправлен пользователем",
  local_result_available: "Доступен локальный результат",
  national_fallback_shown: "Показан национальный fallback",
  wrong_geo_result_reported: "Жалоба на неверную географию",
  action_panel_cta_clicked: "CTA в Action Panel",
  time_to_first_action: "Время до первого действия",
  app_error: "Ошибка приложения",
  sync_failed: "Ошибка синхронизации"
};

export function parseAnalyticsDays(value: string | undefined): AnalyticsPeriodDays {
  return value === "7" || value === "90" ? Number(value) as 7 | 90 : 30;
}

export function parseAnalyticsPlatformScope(value: string | undefined): AnalyticsPlatformScope {
  if (value === "ios") return "iOS";
  if (value === "all") return "All";
  return "Web";
}

export function analyticsPlatformQueryValue(scope: AnalyticsPlatformScope): "web" | "ios" | "all" {
  if (scope === "iOS") return "ios";
  if (scope === "All") return "all";
  return "web";
}

export function analyticsScopeLabels(scope: AnalyticsPlatformScope): AnalyticsScopeLabels {
  if (scope === "iOS") {
    return {
      scope: "iOS",
      sessions: "iOS-сессии",
      views: "Просмотры экранов",
      activity: "активность iOS"
    };
  }
  if (scope === "All") {
    return {
      scope: "Web + iOS",
      sessions: "Сессии Web + iOS",
      views: "Просмотры страниц и экранов",
      activity: "активность Web + iOS"
    };
  }
  return {
    scope: "Web",
    sessions: "Web-сессии",
    views: "Просмотры страниц",
    activity: "активность Web"
  };
}

export function analyticsEventLabel(eventName: string) {
  return eventLabels[eventName] ?? eventName;
}

function count(value: CountValue | undefined) {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? Math.trunc(parsed) : 0;
}

function optionalNumber(value: CountValue | undefined) {
  if (value === null || value === undefined) return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : null;
}

function ratio(current: number, previous: number) {
  return previous > 0 ? (current - previous) / previous : null;
}

function utcDateKey(date: Date) {
  return date.toISOString().slice(0, 10);
}

function addUtcDays(date: Date, days: number) {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}

function maximumTimestamp(values: Array<string | null | undefined>) {
  return values.reduce<string | null>((latest, value) => {
    if (!value || !Number.isFinite(Date.parse(value))) return latest;
    if (!latest || Date.parse(value) > Date.parse(latest)) return value;
    return latest;
  }, null);
}

export function analyticsDataRecency(lastIngestedAt: string | null, now: Date): AnalyticsDataRecency {
  if (!lastIngestedAt || !Number.isFinite(Date.parse(lastIngestedAt))) return "no-data";
  const age = Math.max(0, now.getTime() - Date.parse(lastIngestedAt));
  if (age <= 6 * 60 * 60 * 1_000) return "recent";
  if (age <= 24 * 60 * 60 * 1_000) return "quiet";
  return "stale";
}

function selectedSourceHealth(rows: AnalyticsSourceHealthRow[], scope: AnalyticsPlatformScope) {
  const selectedRows = scope === "All"
    ? rows.filter((row) => platforms.includes(row.platform as AnalyticsPlatform))
    : rows.filter((row) => row.platform === scope);
  return {
    lastEventAt: maximumTimestamp(selectedRows.map((row) => row.last_event_at)),
    lastIngestedAt: maximumTimestamp(selectedRows.map((row) => row.last_ingested_at)),
    delayedEvents: selectedRows.reduce((sum, row) => sum + count(row.delayed_events), 0)
  };
}

export function buildAnalyticsDashboard({
  dailyRows,
  overviewRows,
  eventRows,
  sourceHealthRows,
  comparisonRows,
  now,
  days = 30,
  scope = "Web"
}: {
  dailyRows: AnalyticsV2DailyMetricRow[];
  overviewRows: AnalyticsV2OverviewRow[];
  eventRows: AnalyticsV2EventMetricRow[];
  sourceHealthRows: AnalyticsSourceHealthRow[];
  comparisonRows: AnalyticsV2CompleteWeekRow[];
  now: Date;
  days?: AnalyticsPeriodDays;
  scope?: AnalyticsPlatformScope;
}): AnalyticsDashboardData {
  const endDate = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const startDate = addUtcDays(endDate, -(days - 1));
  const trendByDate = new Map<string, AnalyticsTrendPoint>();
  for (let offset = 0; offset < days; offset += 1) {
    const date = utcDateKey(addUtcDays(startDate, offset));
    trendByDate.set(date, { date, events: 0, sessions: 0, keyActions: 0, errors: 0 });
  }

  for (const row of dailyRows) {
    if (row.platform_scope !== scope) continue;
    const point = trendByDate.get(row.metric_date);
    if (!point) continue;
    point.events = count(row.event_count);
    point.sessions = count(row.session_count);
    point.keyActions = count(row.key_action_count);
    point.errors = count(row.error_event_count);
  }

  const overview = overviewRows.find(
    (row) => row.platform_scope === scope && count(row.period_days) === days
  );
  const totals = {
    events: count(overview?.event_count),
    sessions: count(overview?.session_count),
    activeInstances: count(overview?.active_instances),
    keyActions: count(overview?.key_action_events),
    errors: count(overview?.error_events),
    errorRate: 0
  };
  totals.errorRate = totals.events > 0 ? totals.errors / totals.events : 0;

  const pageViews = count(overview?.page_screen_views);
  const sourceOpens = count(overview?.source_open_events);
  const effectiveness = {
    pageViews,
    searches: count(overview?.search_events),
    sourceOpens,
    pageViewsPerSession: totals.sessions > 0 ? pageViews / totals.sessions : null,
    sourceOpensPerSession: totals.sessions > 0 ? sourceOpens / totals.sessions : null,
    keyActionsPerSession: totals.sessions > 0 ? totals.keyActions / totals.sessions : null,
    sampleEstablished: totals.sessions >= 20
  };

  const sortedEvents = eventRows
    .filter((row) => row.platform_scope === scope && count(row.period_days) === days)
    .map((row) => ({ eventName: row.event_name, events: count(row.event_count) }))
    .sort((left, right) => right.events - left.events || left.eventName.localeCompare(right.eventName));
  const topEvents = sortedEvents.slice(0, 12);
  const topEventCount = topEvents.reduce((sum, event) => sum + event.events, 0);

  const comparisonRow = comparisonRows.find((row) => row.platform_scope === scope);
  const comparison = comparisonRow ? (() => {
    const currentEvents = count(comparisonRow.current_events);
    const previousEvents = count(comparisonRow.previous_events);
    const currentSessions = count(comparisonRow.current_sessions);
    const previousSessions = count(comparisonRow.previous_sessions);
    return {
      currentStartAt: comparisonRow.current_start_at,
      currentEndAt: comparisonRow.current_end_at,
      previousStartAt: comparisonRow.previous_start_at,
      previousEndAt: comparisonRow.previous_end_at,
      currentEvents,
      previousEvents,
      currentSessions,
      previousSessions,
      currentKeyActions: count(comparisonRow.current_key_actions),
      previousKeyActions: count(comparisonRow.previous_key_actions),
      sessionChange: ratio(currentSessions, previousSessions),
      eventChange: ratio(currentEvents, previousEvents)
    };
  })() : null;

  const sourceHealth = selectedSourceHealth(sourceHealthRows, scope);
  return {
    scope,
    hasData: Boolean(overview),
    labels: analyticsScopeLabels(scope),
    trend: [...trendByDate.values()],
    platforms: platforms.map((platform) => {
      const row = overviewRows.find(
        (candidate) => candidate.platform_scope === platform && count(candidate.period_days) === days
      );
      return {
        platform,
        events: count(row?.event_count),
        sessions: count(row?.session_count),
        keyActions: count(row?.key_action_events),
        errors: count(row?.error_events),
        hasData: Boolean(row)
      };
    }),
    topEvents,
    otherEventCount: Math.max(0, totals.events - topEventCount),
    totals,
    effectiveness,
    geo: {
      explicitCityDetected: count(overview?.explicit_city_detected_events),
      cityFilterApplied: count(overview?.city_filter_applied_events),
      cityFilterCorrected: count(overview?.city_filter_corrected_events),
      localResultAvailable: count(overview?.local_result_available_events),
      nationalFallbackShown: count(overview?.national_fallback_shown_events),
      wrongGeoResultReported: count(overview?.wrong_geo_result_reported_events),
      firstResultOpened: count(overview?.first_result_open_events),
      actionPanelCta: count(overview?.action_panel_cta_events),
      actionPanelCtaSessions: count(overview?.action_panel_cta_sessions),
      medianTimeToFirstActionMs: optionalNumber(overview?.median_time_to_first_action_ms)
    },
    comparison,
    lastEventAt: sourceHealth.lastEventAt,
    lastIngestedAt: sourceHealth.lastIngestedAt,
    delayedEvents: sourceHealth.delayedEvents,
    freshness: analyticsDataRecency(sourceHealth.lastIngestedAt, now)
  };
}
