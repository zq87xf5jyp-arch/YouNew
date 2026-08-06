import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const baselineURL = new URL(
  "../../../DataProject/quality/release-critical-production-search-baseline-2026-08-05.json",
  import.meta.url
);

type ProductionCase = {
  name: string;
  url: string;
  matching_result_count: number;
  heading: string;
  no_result_state_visible: boolean;
  top_result_titles: string[];
  useful_answer_visible: boolean;
};

type ProductionBaseline = {
  schema_version: number;
  environment: string;
  origin: string;
  observed_at: string;
  browser_surface: string;
  browser_engine: string;
  release_decision: string;
  summary: {
    total_cases: number;
    useful_result_cases: number;
    zero_result_cases: number;
    zero_result_blocker_cleared: boolean;
    mobile_viewport_smoke: string;
    safari_smoke: string;
  };
  cases: ProductionCase[];
  limitations: string[];
};

const baseline = JSON.parse(await readFile(baselineURL, "utf8")) as ProductionBaseline;

const expectedJourneyNames = [
  "rent + Den Haag + Worker",
  "housing rent + Den Haag + Worker",
  "work + Leiden",
  "huisarts + Rotterdam",
  "Dutch school + Groningen",
  "BSN + Eindhoven",
  "SIM card + Maastricht",
  "parking fine + Utrecht"
];

test("production baseline records the eight exact required journeys", () => {
  assert.equal(baseline.schema_version, 1);
  assert.equal(baseline.environment, "production");
  assert.equal(baseline.origin, "https://younew.nl");
  assert.match(baseline.observed_at, /^2026-08-05T\d{2}:\d{2}:\d{2}Z$/);
  assert.deepEqual(baseline.cases.map((item) => item.name), expectedJourneyNames);
  assert.equal(new Set(baseline.cases.map((item) => item.url)).size, expectedJourneyNames.length);
  baseline.cases.forEach((item) => assert.equal(new URL(item.url).origin, baseline.origin));
});

test("production summary reconciles with the rendered observations", () => {
  const useful = baseline.cases.filter((item) => item.useful_answer_visible).length;
  const zero = baseline.cases.filter((item) => item.matching_result_count === 0).length;

  assert.equal(baseline.summary.total_cases, baseline.cases.length);
  assert.equal(baseline.summary.useful_result_cases, useful);
  assert.equal(baseline.summary.zero_result_cases, zero);
  assert.equal(baseline.summary.zero_result_blocker_cleared, true);
  assert.equal(baseline.summary.mobile_viewport_smoke, "passed_at_390x844");
  assert.equal(baseline.summary.safari_smoke, "not_verified_automation_timeout");

  for (const item of baseline.cases) {
    assert.ok(item.matching_result_count > 0, `${item.name} count`);
    assert.equal(item.no_result_state_visible, false, `${item.name} no-result state`);
    assert.equal(item.useful_answer_visible, true, `${item.name} useful answer`);
    assert.ok(item.top_result_titles.length > 0, `${item.name} result titles`);
    assert.match(item.heading, /^\d+ matching results? for /, `${item.name} heading`);
  }
});

test("a cleared search blocker does not overstate the full release decision", () => {
  assert.equal(baseline.release_decision, "NO-GO_PENDING_BROWSER_MATRIX_AND_EDITORIAL_REVIEW");
  assert.equal(baseline.summary.zero_result_cases, 0);
  assert.ok(baseline.limitations.some((item) => /Chrome evidence/i.test(item)));
  assert.ok(baseline.limitations.some((item) => /Safari remains unverified/i.test(item)));
  assert.ok(baseline.limitations.some((item) => /human editorial review/i.test(item)));
});
