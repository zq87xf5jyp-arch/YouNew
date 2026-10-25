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
  platform_scope: string;
  session_count: number | string | null;
  matched_session_count: number | string | null;
  missing_session_count: number | string | null;
  platform_mismatch_count: number | string | null;
  engaged_session_count: number | string | null;
  average_duration_seconds_capped: number | string | null;
  median_duration_seconds: number | string | null;
  last_seen_at: string | null;
};

export type AnalyticsConversionFunnelRow = {
  platform_scope: string;
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
    platformScope: string;
    sessions: number;
    matchedSessions: number;
    qualityEligibleSessions: number;
    missingSessions: number;
    platformMismatchSessions: number;
    engagedSessions: number;
    engagementRate: number | null;
    sessionRowCoverage: number | null;
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
    const totalsByPlatform = new Map<string, number>();
    for (const row of values) {
      totalsByPlatform.set(row.platform, (totalsByPlatform.get(row.platform) ?? 0) + row.sessions);
    }
    for (const row of values) {
      const total = totalsByPlatform.get(row.platform) ?? 0;
      row.share = total > 0 ? row.sessions / total : 0;
    }
    values.sort((left, right) => right.sessions - left.sessions || left.value.localeCompare(right.value));
  }

  const sessions = sessionRows.map((row) => {
    const sessionCount = count(row.session_count);
    const matchedSessions = count(row.matched_session_count);
    const platformMismatchSessions = count(row.platform_mismatch_count);
    const qualityEligibleSessions = Math.max(0, matchedSessions - platformMismatchSessions);
    const engagedSessions = count(row.engaged_session_count);
    const average = Number(row.average_duration_seconds_capped);
    const median = Number(row.median_duration_seconds);
    return {
      platformScope: row.platform_scope,
      sessions: sessionCount,
      matchedSessions,
      qualityEligibleSessions,
      missingSessions: count(row.missing_session_count),
      platformMismatchSessions,
      engagedSessions,
      engagementRate: qualityEligibleSessions > 0 ? engagedSessions / qualityEligibleSessions : null,
      sessionRowCoverage: sessionCount > 0 ? matchedSessions / sessionCount : null,
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
