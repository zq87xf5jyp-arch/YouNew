import assert from "node:assert/strict";
import test from "node:test";
import { buildLaunchScorecard } from "../src/lib/analytics/launch-scorecard.ts";

test("launch scorecard exposes measured values and never fabricates unavailable KPIs", () => {
  const metrics = buildLaunchScorecard({
    analyticsAvailable: true,
    eventRows: [
      { event_name: "lead_start", event_count: 3 },
      { event_name: "page_view", event_count: 20 }
    ],
    pageRows: [
      { screen: "/organizations/example/", page_views: 4 },
      { screen: "/nl/organisaties/voorbeeld/", page_views: "2" },
      { screen: "/organizations/", page_views: 10 },
      { screen: "/city-guides/amsterdam/", page_views: 8 }
    ],
    businessStoreAvailable: true,
    savedApplications: 2
  });

  assert.equal(metrics.find((metric) => metric.id === "company_page_views")?.value, 6);
  assert.equal(metrics.find((metric) => metric.id === "applications_started")?.value, 3);
  assert.equal(metrics.find((metric) => metric.id === "applications_saved")?.value, 2);
  for (const id of ["organic_visitors", "repeat_visits", "registered_companies", "confirmed_partners", "actual_revenue"]) {
    const metric = metrics.find((item) => item.id === id);
    assert.equal(metric?.value, null, id);
    assert.equal(metric?.status, "unavailable", id);
  }
});

test("missing sources render unavailable instead of false zeroes", () => {
  const metrics = buildLaunchScorecard({
    analyticsAvailable: false,
    eventRows: [],
    pageRows: [],
    businessStoreAvailable: false,
    savedApplications: null
  });

  for (const id of ["company_page_views", "applications_started", "applications_saved"]) {
    const metric = metrics.find((item) => item.id === id);
    assert.equal(metric?.value, null, id);
    assert.equal(metric?.status, "unavailable", id);
  }
});

test("connected empty sources preserve measured zero", () => {
  const metrics = buildLaunchScorecard({
    analyticsAvailable: true,
    eventRows: [],
    pageRows: [],
    businessStoreAvailable: true,
    savedApplications: 0
  });
  for (const id of ["company_page_views", "applications_started", "applications_saved"]) {
    const metric = metrics.find((item) => item.id === id);
    assert.equal(metric?.value, 0, id);
    assert.equal(metric?.status, "measured-zero", id);
  }
});
