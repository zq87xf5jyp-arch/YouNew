export type AnalyticsPageMetricRow = {
  platform: string;
  screen: string;
  page_views: number | string | null;
  sessions: number | string | null;
  active_instances: number | string | null;
  key_actions: number | string | null;
  last_event_at: string | null;
};

export type AnalyticsAudienceMetricRow = {
  platform: string;
  dimension: "language" | "city" | "app_version" | string;
  value: string;
  events: number | string | null;
  sessions: number | string | null;
  active_instances: number | string | null;
  last_event_at: string | null;
};

export type AnalyticsSessionQualityRow = {
  platform: string;
  sessions: number | string | null;
  engaged_sessions: number | string | null;
  average_duration_seconds_capped: number | string | null;
  median_duration_seconds: number | string | null;
  last_seen_at: string | null;
};

export type AnalyticsConversionFunnelRow = {
  platform: string;
  funnel_step: string;
  events: number | string | null;
  sessions: number | string | null;
  last_event_at: string | null;
};

export type AppStoreMetricRow = {
  metric_date: string;
  territory: string;
  first_time_downloads: number | string | null;
  redownloads: number | string | null;
  updates: number | string | null;
  impressions: number | string | null;
  product_page_views: number | string | null;
  installations: number | string | null;
  app_sessions: number | string | null;
  crashes: number | string | null;
  synced_at: string | null;
};

export type AnalyticsInsights = {
  pages: Array<{
    screen: string;
    platform: string;
    pageViews: number;
    sessions: number;
    keyActions: number;
    viewsPerSession: number | null;
  }>;
  audience: Record<string, Array<{
    value: string;
    platform: string;
    events: number;
    sessions: number;
    share: number;
  }>>;
  sessions: Array<{
    platform: string;
    sessions: number;
    engagedSessions: number;
    engagementRate: number | null;
    averageDurationSecondsCapped: number | null;
    medianDurationSeconds: number | null;
    lastSeenAt: string | null;
  }>;
  funnel: Array<{
    step: string;
    label: string;
    sessions: number;
    events: number;
    rateFromVisits: number | null;
  }>;
  appStore: {
    sourceConnected: boolean;
    firstTimeDownloads: number | null;
    redownloads: number | null;
    updates: number | null;
    impressions: number | null;
    productPageViews: number | null;
    installations: number | null;
    appSessions: number | null;
    crashes: number | null;
    lastSyncedAt: string | null;
  };
};

const funnelOrder = [
  "visit",
  "search",
  "result_open",
  "source_open",
  "save",
  "app_store_intent",
  "business_intent"
] as const;

const funnelLabels: Record<string, string> = {
  visit: "Посетили сайт / экран",
  search: "Выполнили поиск",
  result_open: "Открыли результат",
  source_open: "Перешли к официальному источнику",
  save: "Сохранили материал",
  app_store_intent: "Перешли в App Store",
  business_intent: "Начали бизнес-контакт"
};

function count(value: number | string | null | undefined) {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? Math.trunc(parsed) : 0;
}

function optionalCount(rows: AppStoreMetricRow[], key: keyof AppStoreMetricRow) {
  const values = rows
    .map((row) => row[key])
    .filter((value): value is number | string => value !== null && value !== undefined);
  if (values.length === 0) return null;
  return values.reduce<number>((sum, value) => sum + count(value), 0);
}

function maximumTimestamp(values: Array<string | null | undefined>) {
  return values.reduce<string | null>((latest, value) => {
    if (!value || !Number.isFinite(Date.parse(value))) return latest;
    if (!latest || Date.parse(value) > Date.parse(latest)) return value;
    return latest;
  }, null);
}

export function buildAnalyticsInsights({
  pageRows,
  audienceRows,
  sessionRows,
  funnelRows,
  appStoreRows,
  privacyMinimumSessions = 3
}: {
  pageRows: AnalyticsPageMetricRow[];
  audienceRows: AnalyticsAudienceMetricRow[];
  sessionRows: AnalyticsSessionQualityRow[];
  funnelRows: AnalyticsConversionFunnelRow[];
  appStoreRows: AppStoreMetricRow[];
  privacyMinimumSessions?: number;
}): AnalyticsInsights {
  const pages = pageRows
    .map((row) => {
      const sessions = count(row.sessions);
      const pageViews = count(row.page_views);
      return {
        screen: row.screen,
        platform: row.platform,
        pageViews,
        sessions,
        keyActions: count(row.key_actions),
        viewsPerSession: sessions > 0 ? pageViews / sessions : null
      };
    })
    .filter((row) => row.pageViews > 0)
    .sort((left, right) => right.pageViews - left.pageViews || left.screen.localeCompare(right.screen))
    .slice(0, 20);

  const audience: AnalyticsInsights["audience"] = {};
  for (const row of audienceRows) {
    const sessions = count(row.sessions);
    if (sessions < privacyMinimumSessions) continue;
    const values = audience[row.dimension] ?? [];
    values.push({
      value: row.value,
      platform: row.platform,
      events: count(row.events),
      sessions,
      share: 0
    });
    audience[row.dimension] = values;
  }
  for (const values of Object.values(audience)) {
    const total = values.reduce((sum, row) => sum + row.sessions, 0);
    for (const row of values) row.share = total > 0 ? row.sessions / total : 0;
    values.sort((left, right) => right.sessions - left.sessions || left.value.localeCompare(right.value));
  }

  const sessions = sessionRows.map((row) => {
    const sessionCount = count(row.sessions);
    const engagedSessions = count(row.engaged_sessions);
    const average = Number(row.average_duration_seconds_capped);
    const median = Number(row.median_duration_seconds);
    return {
      platform: row.platform,
      sessions: sessionCount,
      engagedSessions,
      engagementRate: sessionCount > 0 ? engagedSessions / sessionCount : null,
      averageDurationSecondsCapped: Number.isFinite(average) ? average : null,
      medianDurationSeconds: Number.isFinite(median) ? median : null,
      lastSeenAt: row.last_seen_at
    };
  }).sort((left, right) => right.sessions - left.sessions);

  const funnelMap = new Map<string, { sessions: number; events: number }>();
  for (const row of funnelRows) {
    const current = funnelMap.get(row.funnel_step) ?? { sessions: 0, events: 0 };
    current.sessions += count(row.sessions);
    current.events += count(row.events);
    funnelMap.set(row.funnel_step, current);
  }
  const visitSessions = funnelMap.get("visit")?.sessions ?? 0;
  const funnel = funnelOrder.map((step) => {
    const current = funnelMap.get(step) ?? { sessions: 0, events: 0 };
    return {
      step,
      label: funnelLabels[step],
      sessions: current.sessions,
      events: current.events,
      rateFromVisits: visitSessions > 0 ? current.sessions / visitSessions : null
    };
  });

  return {
    pages,
    audience,
    sessions,
    funnel,
    appStore: {
      sourceConnected: appStoreRows.length > 0,
      firstTimeDownloads: optionalCount(appStoreRows, "first_time_downloads"),
      redownloads: optionalCount(appStoreRows, "redownloads"),
      updates: optionalCount(appStoreRows, "updates"),
      impressions: optionalCount(appStoreRows, "impressions"),
      productPageViews: optionalCount(appStoreRows, "product_page_views"),
      installations: optionalCount(appStoreRows, "installations"),
      appSessions: optionalCount(appStoreRows, "app_sessions"),
      crashes: optionalCount(appStoreRows, "crashes"),
      lastSyncedAt: maximumTimestamp(appStoreRows.map((row) => row.synced_at))
    }
  };
}
