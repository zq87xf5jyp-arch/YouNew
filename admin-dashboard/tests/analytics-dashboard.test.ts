import assert from "node:assert/strict";
import test from "node:test";
import { buildAnalyticsDashboard } from "../src/lib/analytics/dashboard.ts";

test("analytics dashboard reconciles daily totals, platforms and event ranking", () => {
  const dashboard = buildAnalyticsDashboard({
    now: new Date("2026-07-28T12:00:00.000Z"),
    days: 14,
    dailyRows: [
      {
        metric_date: "2026-07-28",
        platform: "Web",
        event_count: 12,
        active_instances: 4,
        session_count: 4,
        key_action_count: 3,
        error_event_count: 1,
        last_ingested_at: "2026-07-28T11:50:00.000Z"
      },
      {
        metric_date: "2026-07-28",
        platform: "iOS",
        event_count: "8",
        active_instances: "2",
        session_count: "2",
        key_action_count: "4",
        error_event_count: "0",
        last_ingested_at: "2026-07-28T11:45:00.000Z"
      },
      {
        metric_date: "2026-07-21",
        platform: "Web",
        event_count: 10,
        active_instances: 3,
        session_count: 3,
        key_action_count: 2,
        error_event_count: 0,
        last_ingested_at: "2026-07-21T10:00:00.000Z"
      }
    ],
    funnelRows: [
      { metric_date: "2026-07-28", platform: "Web", event_name: "page_view", event_count: 9 },
      { metric_date: "2026-07-28", platform: "iOS", event_name: "screen_view", event_count: 8 },
      { metric_date: "2026-07-28", platform: "Web", event_name: "search", event_count: 3 }
    ],
    sourceHealthRows: [
      {
        platform: "Web",
        total_events: 22,
        active_instances: 7,
        sessions: 7,
        first_event_at: "2026-07-21T09:00:00.000Z",
        last_event_at: "2026-07-28T11:49:00.000Z",
        last_ingested_at: "2026-07-28T11:50:00.000Z",
        delayed_events: 0,
        error_events: 1
      }
    ]
  });

  assert.deepEqual(dashboard.totals, {
    events: 30,
    sessions: 9,
    keyActions: 9,
    errors: 1,
    errorRate: 1 / 30
  });
  assert.equal(dashboard.platforms[0].platform, "Web");
  assert.equal(dashboard.platforms[0].events, 22);
  assert.equal(dashboard.topEvents[0].eventName, "page_view");
  assert.equal(dashboard.currentSevenDayEvents, 20);
  assert.equal(dashboard.previousSevenDayEvents, 10);
  assert.equal(dashboard.sevenDayEventChange, 1);
  assert.equal(dashboard.freshness, "fresh");
});

test("analytics dashboard exposes missing and stale data without inventing values", () => {
  const empty = buildAnalyticsDashboard({
    now: new Date("2026-07-28T12:00:00.000Z"),
    dailyRows: [],
    funnelRows: [],
    sourceHealthRows: []
  });
  assert.equal(empty.totals.events, 0);
  assert.equal(empty.totals.sessions, 0);
  assert.equal(empty.sevenDayEventChange, null);
  assert.equal(empty.lastIngestedAt, null);
  assert.equal(empty.freshness, "no-data");

  const stale = buildAnalyticsDashboard({
    now: new Date("2026-07-28T12:00:00.000Z"),
    dailyRows: [{
      metric_date: "2026-07-01",
      platform: "iOS",
      event_count: 1,
      active_instances: 1,
      session_count: 1,
      key_action_count: 0,
      error_event_count: 0,
      last_ingested_at: "2026-07-01T12:00:00.000Z"
    }],
    funnelRows: [],
    sourceHealthRows: []
  });
  assert.equal(stale.freshness, "stale");
});
