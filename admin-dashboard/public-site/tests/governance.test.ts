import assert from "node:assert/strict";
import test from "node:test";
import {
  effectiveGovernanceStatus,
  governanceDisclosure,
  hasValidConfidenceEvidence,
  reviewDueLeadDays
} from "../src/lib/content/governance.ts";
import type { ContentGovernanceEnvelope } from "../src/lib/content/types.ts";

const evaluatedAt = new Date("2026-07-30T12:00:00Z");

function envelope(
  overrides: Partial<ContentGovernanceEnvelope> = {}
): ContentGovernanceEnvelope {
  return {
    id: "fixture",
    title: "Fixture",
    contentType: "guide",
    jurisdiction: {
      countryCode: "NL",
      level: "national",
      municipalityDependent: false,
      applicabilityVerified: true,
      provinceCode: null,
      provinceName: null,
      municipalityCode: null,
      municipalityName: null
    },
    officialSourceURL: "https://example.nl/source",
    sourceTitle: "Official source",
    sourcePublisher: "Official publisher",
    lastVerifiedAt: "2026-07-29T12:00:00Z",
    nextReviewAt: "2026-10-27T12:00:00Z",
    reviewIntervalDays: 90,
    contentOwner: "owner",
    reviewedBy: "reviewer-a",
    verificationStatus: "verified",
    confidenceLevel: "high",
    validityStart: null,
    validityEnd: null,
    changeNotes: null,
    version: 1,
    updatedAt: "2026-07-29T12:00:00Z",
    publicationStatus: "published",
    reviewState: "monitoring",
    criticality: "critical",
    contentOrigin: "government_publication",
    originReference: "https://example.nl/source",
    originCapturedAt: "2026-07-29T12:00:00Z",
    originArtifactDigest: `sha256:${"a".repeat(64)}`,
    confidenceScore: 100,
    confidenceScoreVersion: 1,
    confidenceBreakdown: {
      officialSource: 40,
      humanReviewer: 20,
      independentReview: 15,
      freshness: 10,
      jurisdictionApplicability: 15
    },
    ...overrides
  };
}

test("effective status follows fail-closed precedence and due-soon boundaries", () => {
  assert.equal(effectiveGovernanceStatus(envelope({ publicationStatus: "archived" }), evaluatedAt), "archived");
  assert.equal(effectiveGovernanceStatus(envelope({ verificationStatus: "disputed" }), evaluatedAt), "disputed");
  assert.equal(effectiveGovernanceStatus(envelope({ officialSourceURL: null }), evaluatedAt), "unverified");
  assert.equal(effectiveGovernanceStatus(envelope({ nextReviewAt: "2026-08-05T12:00:00Z" }), evaluatedAt), "review_due_soon");
  assert.equal(effectiveGovernanceStatus(envelope({ nextReviewAt: "2026-07-29T12:00:00Z" }), evaluatedAt), "overdue");
  assert.equal(reviewDueLeadDays(2), 1);
  assert.equal(reviewDueLeadDays(90), 14);
});

test("confidence is a reproducible evidence index", () => {
  assert.equal(hasValidConfidenceEvidence(envelope()), true);
  assert.equal(hasValidConfidenceEvidence(envelope({ confidenceScore: 99 })), false);
});

test("missing governance is displayed as not established", () => {
  const disclosure = governanceDisclosure(null, evaluatedAt);
  assert.equal(disclosure.effectiveStatus, "unverified");
  assert.match(disclosure.label, /not established/i);
});
