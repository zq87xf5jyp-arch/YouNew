import assert from "node:assert/strict";
import test from "node:test";
import { buildAnalyticsInsights } from "../src/lib/analytics/insights.ts";

test("analytics insights build a privacy-safe visual model", () => {
  const insights = buildAnalyticsInsights({
    pageRows: [
      { platform: "Web", screen: "/", page_views: 12, sessions: 6, active_instances: 6, key_actions: 1, last_event_at: null },
      { platform: "Web", screen: "/search/", page_views: 8, sessions: 4, active_instances: 4, key_actions: 2, last_event_at: null }
    ],
    audienceRows: [
      { platform: "Web", dimension: "language", value: "en", events: 18, sessions: 6, active_instances: 6, last_event_at: null },
      { platform: "Web", dimension: "language", value: "ru", events: 2, sessions: 1, active_instances: 1, last_event_at: null }
    ],
    sessionRows: [
      {
        platform_scope: "Web",
        session_count: 6,
        matched_session_count: 5,
        missing_session_count: 1,
        platform_mismatch_count: 0,
        engaged_session_count: 4,
        average_duration_seconds_capped: 61.2,
        median_duration_seconds: 22,
        last_seen_at: "2026-08-05T20:00:00Z"
      }
    ],
    funnelRows: [
      { platform_scope: "Web", funnel_step: "visit", events: 20, sessions: 6, last_event_at: null },
      { platform_scope: "Web", funnel_step: "search", events: 8, sessions: 3, last_event_at: null },
      { platform_scope: "Web", funnel_step: "app_store_intent", events: 1, sessions: 1, last_event_at: null }
    ],
    appStoreRows: []
  });

  assert.equal(insights.pages[0].screen, "/");
  assert.equal(insights.pages[0].viewsPerSession, 2);
  assert.deepEqual(insights.audience.language.map((row) => row.value), ["en"]);
  assert.equal(insights.sessions[0].engagementRate, 4 / 5);
  assert.equal(insights.sessions[0].qualityEligibleSessions, 5);
  assert.equal(insights.sessions[0].sessionRowCoverage, 5 / 6);
  assert.equal(insights.sessions[0].missingSessions, 1);
  assert.equal(insights.funnel.find((row) => row.step === "search")?.rateFromVisits, 0.5);
  assert.equal(insights.funnel.find((row) => row.step === "app_store_intent")?.sessions, 1);
  assert.equal(insights.appStore.sourceConnected, false);
  assert.equal(insights.appStore.firstTimeDownloads, null);
});

test("platform-mismatched session rows never contaminate duration engagement", () => {
  const insights = buildAnalyticsInsights({
    pageRows: [],
    audienceRows: [],
    sessionRows: [{
      platform_scope: "iOS",
      session_count: 2,
      matched_session_count: 2,
      missing_session_count: 0,
      platform_mismatch_count: 1,
      engaged_session_count: 1,
      average_duration_seconds_capped: 30,
      median_duration_seconds: 30,
      last_seen_at: null
    }],
    funnelRows: [],
    appStoreRows: []
  });

  assert.equal(insights.sessions[0].qualityEligibleSessions, 1);
  assert.equal(insights.sessions[0].engagementRate, 1);
});

test("App Store aggregates remain distinct from CTA intent", () => {
  const insights = buildAnalyticsInsights({
    pageRows: [],
    audienceRows: [],
    sessionRows: [],
    funnelRows: [
      { platform_scope: "Web", funnel_step: "visit", events: 10, sessions: 8, last_event_at: null },
      { platform_scope: "Web", funnel_step: "app_store_intent", events: 3, sessions: 2, last_event_at: null }
    ],
    appStoreRows: [
      {
        metric_date: "2026-08-04",
        territory: "NL",
        first_time_downloads: 5,
        redownloads: 2,
        updates: 7,
        impressions: null,
        product_page_views: null,
        installations: null,
        app_sessions: null,
        crashes: null,
        synced_at: "2026-08-05T10:00:00Z"
      }
    ]
  });

  assert.equal(insights.funnel.find((row) => row.step === "app_store_intent")?.events, 3);
  assert.equal(insights.appStore.firstTimeDownloads, 5);
  assert.equal(insights.appStore.redownloads, 2);
  assert.equal(insights.appStore.sourceConnected, true);
});

test("audience shares are calculated inside each platform scope", () => {
  const insights = buildAnalyticsInsights({
    pageRows: [],
    audienceRows: [
      { platform: "Web", dimension: "language", value: "en", events: 10, sessions: 8, active_instances: 8, last_event_at: null },
      { platform: "Web", dimension: "language", value: "nl", events: 4, sessions: 4, active_instances: 4, last_event_at: null },
      { platform: "iOS", dimension: "language", value: "en", events: 7, sessions: 7, active_instances: 7, last_event_at: null }
    ],
    sessionRows: [],
    funnelRows: [],
    appStoreRows: []
  });

  const webEnglish = insights.audience.language.find((row) => row.platform === "Web" && row.value === "en");
  const iosEnglish = insights.audience.language.find((row) => row.platform === "iOS" && row.value === "en");
  assert.equal(webEnglish?.share, 8 / 12);
  assert.equal(iosEnglish?.share, 1);
});
