export type AnalyticsDailyMetricRow = {
  metric_date: string;
  platform: string;
  event_count: number | string | null;
  active_instances: number | string | null;
  session_count: number | string | null;
  key_action_count: number | string | null;
  error_event_count: number | string | null;
  last_ingested_at: string | null;
};

export type AnalyticsFunnelMetricRow = {
  metric_date: string;
  platform: string;
  event_name: string;
  event_count: number | string | null;
};

export type AnalyticsSourceHealthRow = {
  platform: string;
  total_events: number | string | null;
  active_instances: number | string | null;
  sessions: number | string | null;
  first_event_at: string | null;
  last_event_at: string | null;
  last_ingested_at: string | null;
  delayed_events: number | string | null;
  error_events: number | string | null;
};

export type AnalyticsTrendPoint = {
  date: string;
  events: number;
  sessions: number;
  keyActions: number;
  errors: number;
};

export type AnalyticsPlatformSummary = {
  platform: string;
  events: number;
  sessions: number;
  keyActions: number;
  errors: number;
};

export type AnalyticsEventSummary = {
  eventName: string;
  events: number;
};

export type AnalyticsDashboardData = {
  trend: AnalyticsTrendPoint[];
  platforms: AnalyticsPlatformSummary[];
  topEvents: AnalyticsEventSummary[];
  totals: {
    events: number;
    sessions: number;
    keyActions: number;
    errors: number;
    errorRate: number;
  };
  effectiveness: {
    pageViews: number;
    sourceOpens: number;
    pageViewsPerSession: number | null;
    sourceOpensPerSession: number | null;
    keyActionsPerSession: number | null;
    sampleEstablished: boolean;
  };
  currentSevenDayEvents: number;
  previousSevenDayEvents: number;
  sevenDayEventChange: number | null;
  lastIngestedAt: string | null;
  freshness: "fresh" | "delayed" | "stale" | "no-data";
};

function count(value: number | string | null | undefined) {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? Math.trunc(parsed) : 0;
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

export function buildAnalyticsDashboard({
  dailyRows,
  funnelRows,
  sourceHealthRows,
  now,
  days = 30
}: {
  dailyRows: AnalyticsDailyMetricRow[];
  funnelRows: AnalyticsFunnelMetricRow[];
  sourceHealthRows: AnalyticsSourceHealthRow[];
  now: Date;
  days?: number;
}): AnalyticsDashboardData {
  const endDate = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const startDate = addUtcDays(endDate, -(Math.max(1, days) - 1));
  const trendByDate = new Map<string, AnalyticsTrendPoint>();

  for (let offset = 0; offset < Math.max(1, days); offset += 1) {
    const date = utcDateKey(addUtcDays(startDate, offset));
    trendByDate.set(date, { date, events: 0, sessions: 0, keyActions: 0, errors: 0 });
  }

  const platforms = new Map<string, AnalyticsPlatformSummary>();
  for (const row of dailyRows) {
    const point = trendByDate.get(row.metric_date);
    if (!point) continue;
    const events = count(row.event_count);
    const sessions = count(row.session_count);
    const keyActions = count(row.key_action_count);
    const errors = count(row.error_event_count);
    point.events += events;
    point.sessions += sessions;
    point.keyActions += keyActions;
    point.errors += errors;

    const platform = row.platform || "Unknown";
    const summary = platforms.get(platform) ?? {
      platform,
      events: 0,
      sessions: 0,
      keyActions: 0,
      errors: 0
    };
    summary.events += events;
    summary.sessions += sessions;
    summary.keyActions += keyActions;
    summary.errors += errors;
    platforms.set(platform, summary);
  }

  const topEvents = new Map<string, number>();
  for (const row of funnelRows) {
    if (!trendByDate.has(row.metric_date)) continue;
    topEvents.set(row.event_name, (topEvents.get(row.event_name) ?? 0) + count(row.event_count));
  }

  const trend = [...trendByDate.values()];
  const totals = trend.reduce(
    (summary, point) => ({
      events: summary.events + point.events,
      sessions: summary.sessions + point.sessions,
      keyActions: summary.keyActions + point.keyActions,
      errors: summary.errors + point.errors,
      errorRate: 0
    }),
    { events: 0, sessions: 0, keyActions: 0, errors: 0, errorRate: 0 }
  );
  totals.errorRate = totals.events > 0 ? totals.errors / totals.events : 0;
  const pageViews = (topEvents.get("page_view") ?? 0) + (topEvents.get("screen_view") ?? 0);
  const sourceOpens = (topEvents.get("official_source_click") ?? 0)
    + (topEvents.get("official_source_opened") ?? 0);
  const effectiveness = {
    pageViews,
    sourceOpens,
    pageViewsPerSession: totals.sessions > 0 ? pageViews / totals.sessions : null,
    sourceOpensPerSession: totals.sessions > 0 ? sourceOpens / totals.sessions : null,
    keyActionsPerSession: totals.sessions > 0 ? totals.keyActions / totals.sessions : null,
    sampleEstablished: totals.sessions >= 20
  };

  const currentSevenDayEvents = trend.slice(-7).reduce((sum, point) => sum + point.events, 0);
  const previousSevenDayEvents = trend.slice(-14, -7).reduce((sum, point) => sum + point.events, 0);
  const sevenDayEventChange = previousSevenDayEvents > 0
    ? (currentSevenDayEvents - previousSevenDayEvents) / previousSevenDayEvents
    : null;

  const lastIngestedAt = maximumTimestamp([
    ...dailyRows.map((row) => row.last_ingested_at),
    ...sourceHealthRows.map((row) => row.last_ingested_at)
  ]);
  const freshnessAge = lastIngestedAt ? now.getTime() - Date.parse(lastIngestedAt) : null;
  const freshness = freshnessAge === null
    ? "no-data"
    : freshnessAge <= 6 * 60 * 60 * 1_000
      ? "fresh"
      : freshnessAge <= 24 * 60 * 60 * 1_000
        ? "delayed"
        : "stale";

  return {
    trend,
    platforms: [...platforms.values()].sort((left, right) => right.events - left.events),
    topEvents: [...topEvents.entries()]
      .map(([eventName, events]) => ({ eventName, events }))
      .sort((left, right) => right.events - left.events || left.eventName.localeCompare(right.eventName))
      .slice(0, 12),
    totals,
    effectiveness,
    currentSevenDayEvents,
    previousSevenDayEvents,
    sevenDayEventChange,
    lastIngestedAt,
    freshness
  };
}
