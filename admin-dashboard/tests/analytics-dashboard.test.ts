import assert from "node:assert/strict";
import test from "node:test";
import {
  analyticsDataRecency,
  analyticsEventLabel,
  analyticsScopeLabels,
  buildAnalyticsDashboard,
  parseAnalyticsDays,
  parseAnalyticsPlatformScope,
  type AnalyticsV2OverviewRow
} from "../src/lib/analytics/dashboard.ts";

function overview(
  platformScope: string,
  values: Partial<AnalyticsV2OverviewRow> = {}
): AnalyticsV2OverviewRow {
  return {
    period_days: 7,
    platform_scope: platformScope,
    period_start_at: "2026-08-13T00:00:00.000Z",
    period_end_at: "2026-08-19T12:00:00.000Z",
    event_count: 0,
    active_instances: 0,
    session_count: 0,
    page_screen_views: 0,
    search_events: 0,
    source_open_events: 0,
    key_action_events: 0,
    error_events: 0,
    explicit_city_detected_events: 0,
    city_filter_applied_events: 0,
    city_filter_corrected_events: 0,
    local_result_available_events: 0,
    national_fallback_shown_events: 0,
    wrong_geo_result_reported_events: 0,
    action_panel_cta_events: 0,
    action_panel_cta_sessions: 0,
    first_result_open_events: 0,
    median_time_to_first_action_ms: null,
    last_event_at: null,
    last_ingested_at: null,
    ...values
  };
}

test("analytics URL contract defaults to Web and never falls through to another platform", () => {
  assert.equal(parseAnalyticsDays(undefined), 30);
  assert.equal(parseAnalyticsDays("7"), 7);
  assert.equal(parseAnalyticsDays("invalid"), 30);
  assert.equal(parseAnalyticsPlatformScope(undefined), "Web");
  assert.equal(parseAnalyticsPlatformScope("web"), "Web");
  assert.equal(parseAnalyticsPlatformScope("ios"), "iOS");
  assert.equal(parseAnalyticsPlatformScope("all"), "All");
  assert.equal(parseAnalyticsPlatformScope("android"), "Web");
  assert.equal(analyticsScopeLabels("iOS").views, "Просмотры экранов");
});

test("dashboard uses exact period totals instead of summing daily distinct sessions", () => {
  const eventRows = Array.from({ length: 14 }, (_, index) => ({
    period_days: 7,
    platform_scope: "Web",
    event_name: index === 0 ? "action_panel_cta_clicked" : `event_${index}`,
    event_count: 1,
    active_instances: 1,
    session_count: 1,
    last_event_at: null,
    last_ingested_at: null
  }));
  const dashboard = buildAnalyticsDashboard({
    now: new Date("2026-08-19T12:00:00.000Z"),
    days: 7,
    scope: "Web",
    dailyRows: [
      {
        metric_date: "2026-08-18",
        platform_scope: "Web",
        event_count: 7,
        active_instances: 1,
        session_count: 1,
        key_action_count: 1,
        error_event_count: 0,
        last_event_at: "2026-08-18T23:59:00.000Z",
        last_ingested_at: "2026-08-18T23:59:01.000Z"
      },
      {
        metric_date: "2026-08-19",
        platform_scope: "Web",
        event_count: 7,
        active_instances: 1,
        session_count: 1,
        key_action_count: 0,
        error_event_count: 0,
        last_event_at: "2026-08-19T11:50:00.000Z",
        last_ingested_at: "2026-08-19T11:51:00.000Z"
      }
    ],
    overviewRows: [
      overview("Web", {
        event_count: 14,
        active_instances: 1,
        session_count: 1,
        page_screen_views: 5,
        search_events: 2,
        source_open_events: 1,
        key_action_events: 1,
        action_panel_cta_events: 1,
        action_panel_cta_sessions: 1,
        first_result_open_events: 1,
        median_time_to_first_action_ms: 850
      }),
      overview("iOS", { event_count: 3, session_count: 2 }),
      overview("All", { event_count: 17, session_count: 3 })
    ],
    eventRows,
    sourceHealthRows: [
      {
        platform: "Web",
        total_events: 14,
        active_instances: 1,
        sessions: 1,
        first_event_at: "2026-08-18T10:00:00.000Z",
        last_event_at: "2026-08-19T11:50:00.000Z",
        last_ingested_at: "2026-08-19T11:51:00.000Z",
        delayed_events: 2,
        error_events: 0
      },
      {
        platform: "iOS",
        total_events: 3,
        active_instances: 2,
        sessions: 2,
        first_event_at: "2026-08-18T10:00:00.000Z",
        last_event_at: "2026-08-19T11:55:00.000Z",
        last_ingested_at: "2026-08-19T11:56:00.000Z",
        delayed_events: 0,
        error_events: 0
      }
    ],
    comparisonRows: [{
      platform_scope: "Web",
      current_start_at: "2026-08-12T00:00:00.000Z",
      current_end_at: "2026-08-19T00:00:00.000Z",
      previous_start_at: "2026-08-05T00:00:00.000Z",
      previous_end_at: "2026-08-12T00:00:00.000Z",
      current_events: 20,
      previous_events: 10,
      current_sessions: 6,
      previous_sessions: 4,
      current_key_actions: 3,
      previous_key_actions: 2
    }]
  });

  assert.equal(dashboard.totals.sessions, 1);
  assert.equal(dashboard.hasData, true);
  assert.equal(dashboard.trend.reduce((sum, point) => sum + point.sessions, 0), 2);
  assert.equal(dashboard.totals.keyActions, 1, "Action Panel context is not counted twice");
  assert.equal(dashboard.geo.actionPanelCta, 1);
  assert.equal(dashboard.topEvents.length, 12);
  assert.equal(dashboard.otherEventCount, 2);
  assert.equal(
    dashboard.topEvents.reduce((sum, event) => sum + event.events, 0) + dashboard.otherEventCount,
    dashboard.totals.events
  );
  assert.equal(dashboard.comparison?.sessionChange, 0.5);
  assert.equal(dashboard.freshness, "recent");
  assert.equal(dashboard.lastIngestedAt, "2026-08-19T11:51:00.000Z", "Web never inherits fresher iOS data");
  assert.equal(dashboard.platforms.find((row) => row.platform === "iOS")?.sessions, 2);
});

test("missing Web data does not fall back to available iOS totals or freshness", () => {
  const dashboard = buildAnalyticsDashboard({
    now: new Date("2026-08-19T12:00:00.000Z"),
    days: 7,
    scope: "Web",
    dailyRows: [],
    overviewRows: [overview("iOS", { event_count: 9, session_count: 3 })],
    eventRows: [],
    comparisonRows: [],
    sourceHealthRows: [{
      platform: "iOS",
      total_events: 9,
      active_instances: 3,
      sessions: 3,
      first_event_at: "2026-08-19T10:00:00.000Z",
      last_event_at: "2026-08-19T11:00:00.000Z",
      last_ingested_at: "2026-08-19T11:01:00.000Z",
      delayed_events: 0,
      error_events: 0
    }]
  });
  assert.equal(dashboard.totals.events, 0);
  assert.equal(dashboard.totals.sessions, 0);
  assert.equal(dashboard.hasData, false);
  assert.equal(dashboard.lastIngestedAt, null);
  assert.equal(dashboard.freshness, "no-data");
});

test("freshness semantics separate recent traffic, quiet periods and stale data", () => {
  const now = new Date("2026-08-19T12:00:00.000Z");
  assert.equal(analyticsDataRecency("2026-08-19T06:00:00.000Z", now), "recent");
  assert.equal(analyticsDataRecency("2026-08-19T05:59:59.999Z", now), "quiet");
  assert.equal(analyticsDataRecency("2026-08-18T12:00:00.000Z", now), "quiet");
  assert.equal(analyticsDataRecency("2026-08-18T11:59:59.999Z", now), "stale");
  assert.equal(analyticsDataRecency(null, now), "no-data");
});

test("all geo and Action Panel event names have explicit Admin labels", () => {
  for (const eventName of [
    "explicit_city_detected",
    "city_filter_applied",
    "city_filter_corrected",
    "local_result_available",
    "national_fallback_shown",
    "wrong_geo_result_reported",
    "action_panel_cta_clicked",
    "time_to_first_action"
  ]) {
    assert.notEqual(analyticsEventLabel(eventName), eventName);
  }
});
