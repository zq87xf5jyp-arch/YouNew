import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL("../supabase/migrations/20260819124838_add_analytics_v2_scoped_exact_metrics.sql", import.meta.url),
  "utf8"
);
const analyticsPage = await readFile(
  new URL("../src/app/(admin)/analytics/page.tsx", import.meta.url),
  "utf8"
);
const analyticsModel = await readFile(
  new URL("../src/lib/analytics/dashboard.ts", import.meta.url),
  "utf8"
);

const views = [
  "analytics_v2_daily_metrics",
  "analytics_v2_overview_periods",
  "analytics_v2_event_metrics_periods",
  "analytics_v2_session_quality_periods",
  "analytics_v2_funnel_periods",
  "analytics_v2_complete_week_comparison"
];

test("analytics v2 views are additive security-invoker aggregates with explicit grants", () => {
  assert.match(
    migration,
    /create index if not exists app_events_environment_platform_occurred_at_idx\s+on public\.app_events \(environment, platform, occurred_at desc\)/i
  );
  for (const view of views) {
    assert.match(
      migration,
      new RegExp(`create view public\\.${view}\\s+with \\(security_invoker = true\\)`, "i")
    );
    assert.match(
      migration,
      new RegExp(`revoke all on table public\\.${view} from public, anon, authenticated`, "i")
    );
    assert.match(
      migration,
      new RegExp(`grant select on table public\\.${view} to authenticated`, "i")
    );
  }
  assert.doesNotMatch(migration, /drop\s+(?:table|view)|truncate|delete\s+from|alter\s+table/i);
});

test("analytics v2 periods use explicit UTC boundaries and exact distinct sessions", () => {
  assert.match(migration, /date_trunc\('day', now\(\) at time zone 'UTC'\) at time zone 'UTC'/);
  assert.match(
    migration,
    /count\(distinct session_id\) filter \(where session_id is not null\)::bigint as session_count/
  );
  assert.match(migration, /last seven complete UTC days/i);
  assert.match(migration, /values \(7\), \(30\), \(90\)/);
});

test("geo signals are aggregate-only and Action Panel context stays outside canonical KPIs", () => {
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
    assert.match(migration, new RegExp(eventName));
    assert.match(analyticsModel, new RegExp(eventName));
  }
  assert.match(migration, /Action Panel context is excluded from canonical key actions/i);
  assert.doesNotMatch(
    migration.match(/as key_action_events[\s\S]*?as error_events/)?.[0] ?? "",
    /action_panel_cta_clicked/
  );
  assert.doesNotMatch(
    migration.match(/as source_open_events[\s\S]*?as key_action_events/)?.[0] ?? "",
    /action_panel_cta_clicked/
  );
});

test("Admin URL contract defaults to Web and keeps period and platform controls together", () => {
  assert.match(analyticsModel, /parseAnalyticsPlatformScope[\s\S]*return "Web"/);
  assert.match(analyticsPage, /searchParams: Promise<\{ days\?: string; platform\?: string \}>/);
  assert.match(analyticsPage, /<AnalyticsPeriodPicker days=\{days\} platform=\{platform\}/);
  assert.match(analyticsPage, /<AnalyticsPlatformPicker days=\{days\} platform=\{platform\}/);
  assert.match(analyticsPage, /\.eq\("platform_scope", platform\)/);
  assert.doesNotMatch(analyticsPage, /selectedSessions\s*\?\?/);
});

test("Admin exposes honest freshness, top-event remainder and disabled iOS ingest", () => {
  assert.match(analyticsModel, /"recent" \| "quiet" \| "stale" \| "no-data"/);
  assert.match(analyticsModel, /sortedEvents\.slice\(0, 12\)/);
  assert.match(analyticsModel, /otherEventCount: Math\.max\(0, totals\.events - topEventCount\)/);
  assert.match(analyticsModel, /hasData: Boolean\(overview\)/);
  assert.match(analyticsPage, /selectedDataAvailable = analyticsAvailable && dashboard\.hasData/);
  assert.match(analyticsPage, /iOS ingest отключён/);
  assert.match(analyticsPage, /privacy\/security validation/);
});
