import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  classifyOfficialLinkObservation,
  OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS,
  OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_MS
} from "../src/lib/official-link-health.ts";

const referenceTimestamp = "2026-08-19T12:00:00.000Z";

test("official-link health uses the documented 24-hour operational freshness window", () => {
  assert.equal(OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS, 24);
  assert.equal(OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_MS, 86_400_000);

  const boundary = classifyOfficialLinkObservation({
    link_health_state: "reachable",
    checked_at: "2026-08-18T12:00:00.000Z"
  }, referenceTimestamp);
  assert.deepEqual(boundary, {
    freshness: "fresh",
    observedHealth: "reachable",
    checkedAt: "2026-08-18T12:00:00.000Z",
    validThrough: referenceTimestamp,
    countsTowardCoverage: true,
    reason: "fresh_observation"
  });

  const expired = classifyOfficialLinkObservation({
    link_health_state: "broken",
    checked_at: "2026-08-18T11:59:59.999Z"
  }, referenceTimestamp);
  assert.equal(expired.freshness, "stale");
  assert.equal(expired.observedHealth, "broken");
  assert.equal(expired.countsTowardCoverage, false);
  assert.equal(expired.reason, "expired_observation");

  const explicitOffset = classifyOfficialLinkObservation({
    link_health_state: "redirected",
    checked_at: "2026-08-19T13:00:00+02:00"
  }, referenceTimestamp);
  assert.equal(explicitOffset.freshness, "fresh");
  assert.equal(explicitOffset.checkedAt, "2026-08-19T11:00:00.000Z");
});

test("unknown health and missing timestamps are never measured", () => {
  for (const input of [
    { link_health_state: "unknown", checked_at: "2026-08-19T11:00:00.000Z" },
    { link_health_state: null, checked_at: "2026-08-19T11:00:00.000Z" },
    { link_health_state: "reachable", checked_at: null },
    null
  ]) {
    const result = classifyOfficialLinkObservation(input, referenceTimestamp);
    assert.equal(result.freshness, "unmeasured");
    assert.equal(result.countsTowardCoverage, false);
    assert.equal(result.checkedAt, null);
  }
});

test("invalid, epoch sentinel and future timestamps cannot upgrade coverage", () => {
  const cases = [
    ["not-a-date", "invalid_timestamp"],
    ["2026-08-19T11:00:00", "invalid_timestamp"],
    ["2026-02-30T11:00:00.000Z", "invalid_timestamp"],
    ["1970-01-01T00:00:00.000Z", "sentinel_timestamp"],
    ["1999-12-31T23:59:59.999Z", "sentinel_timestamp"],
    ["2026-08-19T12:00:00.001Z", "future_timestamp"]
  ] as const;

  for (const [checkedAt, reason] of cases) {
    const result = classifyOfficialLinkObservation({
      link_health_state: "redirected",
      checked_at: checkedAt
    }, referenceTimestamp);
    assert.equal(result.freshness, "unmeasured", checkedAt);
    assert.equal(result.countsTowardCoverage, false, checkedAt);
    assert.equal(result.reason, reason, checkedAt);
  }
});

test("Admin Links derives coverage only from classified canonical joins and labels stale/unmeasured states", async () => {
  const page = await readFile(new URL("../src/app/(admin)/links/page.tsx", import.meta.url), "utf8");
  assert.match(page, /canonicalOfficialLinks\.links\.map/);
  assert.match(page, /classifyOfficialLinkObservation\(operation, operational\.observedAt\)/);
  assert.match(page, /freshRows = classifiedRows\.filter\(\(row\) => row\.observation\.countsTowardCoverage\)/);
  assert.match(page, /staleRows = classifiedRows\.filter/);
  assert.match(page, /"\u041d\u0435 \u0438\u0437\u043c\u0435\u0440\u0435\u043d\u043e"/);
  assert.match(page, /Invalid, epoch, future and stale timestamps never contribute to coverage/);
  assert.doesNotMatch(page, /checkedRows = operational\.rows\.filter/);
});
