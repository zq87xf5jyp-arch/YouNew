import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const publicDashboard = JSON.parse(
  await readFile(new URL("../src/generated/trust-dashboard.json", import.meta.url), "utf8"),
);
const adminDashboard = JSON.parse(
  await readFile(new URL("../../src/generated/trust-dashboard.json", import.meta.url), "utf8"),
);

test("public and admin trust surfaces use the same generated evidence", () => {
  assert.deepEqual(publicDashboard, adminDashboard);
});

test("the public trust summary preserves hard release authority", () => {
  assert.equal(publicDashboard.currentReleaseAuthority, "NO_GO");
  assert.equal(publicDashboard.readiness.status, "NO_GO");
  assert.deepEqual(publicDashboard.readiness.hardGates, {
    contentGovernance: false,
    ai: false,
    userOutcome: false,
  });
  assert.equal(publicDashboard.readiness.overall.evidenceState, "not_established");
  assert.equal(publicDashboard.readiness.overall.value, null);
});

test("record confidence remains separate from the provisional source score", () => {
  assert.equal(
    publicDashboard.metrics.sourceTrustScore.formula,
    "separate publisher/source reliability score; not record confidence",
  );
  assert.equal(publicDashboard.metrics.sourceTrustScore.evidenceState, "provisional");
  assert.match(publicDashboard.metrics.averageConfidence.formula, /not probability/i);
});
