import type {
  ContentGovernanceEnvelope,
  GovernanceVerificationStatus
} from "./types";

const DAY_MS = 86_400_000;

function instant(value: string | null): number | null {
  if (!value) return null;
  const parsed = Date.parse(value);
  return Number.isFinite(parsed) ? parsed : null;
}

export function reviewDueLeadDays(reviewIntervalDays: number | null): number {
  const interval = Number.isInteger(reviewIntervalDays) && (reviewIntervalDays ?? 0) > 0
    ? reviewIntervalDays as number
    : 90;
  return Math.max(1, Math.min(14, Math.floor(interval * 0.25)));
}

export function effectiveGovernanceStatus(
  envelope: ContentGovernanceEnvelope | null,
  evaluatedAt = new Date()
): GovernanceVerificationStatus {
  if (!envelope) return "unverified";
  if (envelope.publicationStatus === "archived" || envelope.verificationStatus === "archived") return "archived";
  if (envelope.verificationStatus === "disputed") return "disputed";
  if (envelope.verificationStatus === "source_unavailable") return "source_unavailable";

  const verifiedAt = instant(envelope.lastVerifiedAt);
  if (
    envelope.verificationStatus === "unverified" ||
    !envelope.officialSourceURL?.startsWith("https://") ||
    verifiedAt === null
  ) return "unverified";

  const now = evaluatedAt.getTime();
  const validityStart = instant(envelope.validityStart);
  const validityEnd = instant(envelope.validityEnd);
  const nextReviewAt = instant(envelope.nextReviewAt);
  if (validityStart !== null && now < validityStart) return "unverified";
  if (
    envelope.verificationStatus === "overdue" ||
    (validityEnd !== null && now > validityEnd) ||
    (nextReviewAt !== null && now > nextReviewAt)
  ) return "overdue";
  if (envelope.verificationStatus === "review_due_soon") return "review_due_soon";
  if (
    nextReviewAt !== null &&
    now >= nextReviewAt - reviewDueLeadDays(envelope.reviewIntervalDays) * DAY_MS
  ) return "review_due_soon";
  return "verified";
}

export function hasValidConfidenceEvidence(envelope: ContentGovernanceEnvelope): boolean {
  const breakdown = envelope.confidenceBreakdown;
  const validComponents =
    [0, 40].includes(breakdown.officialSource) &&
    [0, 20].includes(breakdown.humanReviewer) &&
    [0, 15].includes(breakdown.independentReview) &&
    [0, 10].includes(breakdown.freshness) &&
    [0, 15].includes(breakdown.jurisdictionApplicability);
  const total =
    breakdown.officialSource +
    breakdown.humanReviewer +
    breakdown.independentReview +
    breakdown.freshness +
    breakdown.jurisdictionApplicability;
  return validComponents && envelope.confidenceScoreVersion === 1 && total === envelope.confidenceScore;
}

export function governanceDisclosure(envelope: ContentGovernanceEnvelope | null, evaluatedAt = new Date()) {
  const effectiveStatus = effectiveGovernanceStatus(envelope, evaluatedAt);
  if (!envelope) {
    return {
      effectiveStatus,
      tone: "warning" as const,
      label: "Record-level verification not established",
      explanation: "This legacy public record predates the governed record envelope. Use the official source before acting."
    };
  }
  if (!hasValidConfidenceEvidence(envelope)) {
    return {
      effectiveStatus,
      tone: "warning" as const,
      label: "Confidence evidence is inconsistent",
      explanation: "The evidence coverage index cannot be reproduced. Treat this record as degraded."
    };
  }
  const degraded = effectiveStatus !== "verified";
  return {
    effectiveStatus,
    tone: degraded ? "warning" as const : "success" as const,
    label: degraded ? `Verification status: ${effectiveStatus.replaceAll("_", " ")}` : "Governance verification current",
    explanation: degraded
      ? "Open the official source and confirm the current municipality rules before acting."
      : "The official source, human review, freshness and jurisdiction evidence are current under the recorded policy version."
  };
}
