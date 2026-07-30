import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  aiEligibility,
  confidenceBreakdown,
  confidenceScore,
  effectiveVerificationStatus,
  overallReadiness,
  type GovernanceRecord,
  type ReadinessMetric
} from "../src/lib/governance.ts";

test("TypeScript effective status matches the shared golden fixtures", async () => {
  const fixture = JSON.parse(
    await readFile(
      new URL("../../DataProject/quality/governance-policy-fixtures.json", import.meta.url),
      "utf8"
    )
  ) as { evaluatedAt: string; cases: Array<{ id: string; record: GovernanceRecord; expectedStatus: string }> };
  for (const scenario of fixture.cases) {
    assert.equal(
      effectiveVerificationStatus(scenario.record, new Date(fixture.evaluatedAt)),
      scenario.expectedStatus,
      scenario.id
    );
  }
});

test("confidence is derived evidence coverage and cannot use an input score claim", () => {
  const record: GovernanceRecord = {
    publicationStatus: "published",
    verificationStatus: "verified",
    officialSourceURL: "https://www.amsterdam.nl/en/civil-affairs/",
    sourceIsOfficial: true,
    sourceOpenedAt: "2026-07-30T09:00:00Z",
    lastVerifiedAt: "2026-07-30T09:00:00Z",
    nextReviewAt: "2026-10-28T09:00:00Z",
    reviewIntervalDays: 90,
    reviewedBy: "reviewer-a",
    secondReviewedBy: "reviewer-b",
    jurisdiction: { applicabilityVerified: true }
  };
  const breakdown = confidenceBreakdown(record, new Date("2026-07-30T12:00:00Z"));
  assert.deepEqual(breakdown, {
    officialSource: 40,
    humanReviewer: 20,
    independentReview: 15,
    freshness: 10,
    jurisdictionApplicability: 15
  });
  assert.equal(confidenceScore(breakdown), 100);
  assert.equal(aiEligibility(record, new Date("2026-07-30T12:00:00Z")), "primary");
});

test("missing evidence or any hard-gate failure keeps readiness NO-GO", () => {
  const established = (value: number): ReadinessMetric => ({
    value,
    evidenceState: "established",
    numerator: value,
    denominator: 100,
    formulaVersion: 1,
    sourceArtifact: "fixture",
    generatedAt: "2026-07-30T12:00:00Z"
  });
  const base = {
    trust: established(99),
    knowledge: established(96),
    ai: established(98),
    ux: established(90),
    governance: established(97),
    research: established(85),
    hardGates: { contentGovernance: true, ai: true, userOutcome: false }
  };
  assert.deepEqual(overallReadiness(base), {
    ...established(85),
    numerator: null,
    denominator: null,
    releaseAuthority: "NO_GO",
    hardGatesPassed: false
  });

  const notEstablished = {
    ...base,
    hardGates: { contentGovernance: true, ai: true, userOutcome: true },
    research: { ...established(0), value: null, evidenceState: "not_established" as const }
  };
  assert.equal(overallReadiness(notEstablished).value, null);
  assert.equal(overallReadiness(notEstablished).releaseAuthority, "NO_GO");
});
