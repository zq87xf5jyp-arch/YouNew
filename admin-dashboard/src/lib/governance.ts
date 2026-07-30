export const VERIFICATION_STATUSES = [
  "unverified",
  "verified",
  "review_due_soon",
  "overdue",
  "source_unavailable",
  "disputed",
  "archived"
] as const;

export type VerificationStatus = (typeof VERIFICATION_STATUSES)[number];
export type PublicationStatus = "draft" | "qa" | "published" | "archived";
export type ReviewState =
  | "needs_review"
  | "assigned"
  | "in_review"
  | "approved"
  | "monitoring"
  | "expired"
  | "closed";
export type EvidenceState = "established" | "not_established";

export interface GovernanceJurisdiction {
  countryCode: "NL";
  level: "national" | "provincial" | "municipal" | "mixed";
  municipalityDependent: boolean;
  applicabilityVerified: boolean;
  provinceCode: string | null;
  provinceName: string | null;
  municipalityCode: string | null;
  municipalityName: string | null;
}

export interface GovernanceRecord {
  id?: string;
  recordKey?: string;
  publicationStatus: PublicationStatus;
  verificationStatus: VerificationStatus;
  officialSourceURL?: string | null;
  sourceIsOfficial?: boolean;
  sourceOpenedAt?: string | null;
  lastVerifiedAt?: string | null;
  nextReviewAt?: string | null;
  reviewIntervalDays?: number | null;
  reviewedBy?: string | null;
  secondReviewedBy?: string | null;
  validityStart?: string | null;
  validityEnd?: string | null;
  jurisdiction?: Partial<GovernanceJurisdiction> | null;
}

export interface ConfidenceBreakdown {
  officialSource: 0 | 40;
  humanReviewer: 0 | 20;
  independentReview: 0 | 15;
  freshness: 0 | 10;
  jurisdictionApplicability: 0 | 15;
}

export interface ReadinessMetric {
  value: number | null;
  evidenceState: EvidenceState;
  numerator: number | null;
  denominator: number | null;
  formulaVersion: number;
  sourceArtifact: string;
  generatedAt: string;
}

export interface ReadinessScorecard {
  trust: ReadinessMetric;
  knowledge: ReadinessMetric;
  ai: ReadinessMetric;
  ux: ReadinessMetric;
  governance: ReadinessMetric;
  research: ReadinessMetric;
  hardGates: {
    contentGovernance: boolean;
    ai: boolean;
    userOutcome: boolean;
  };
}

function parseInstant(value: string | null | undefined): Date | null {
  if (!value) return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.valueOf()) ? null : parsed;
}

export function reviewDueLeadDays(reviewIntervalDays: number | null | undefined): number {
  const interval = Number.isFinite(reviewIntervalDays)
    ? Math.max(1, Math.trunc(reviewIntervalDays ?? 90))
    : 90;
  return Math.max(1, Math.min(14, Math.trunc(interval * 0.25)));
}

export function effectiveVerificationStatus(
  record: GovernanceRecord,
  evaluatedAt = new Date()
): VerificationStatus {
  if (record.publicationStatus === "archived" || record.verificationStatus === "archived") return "archived";
  if (record.verificationStatus === "disputed") return "disputed";
  if (record.verificationStatus === "source_unavailable") return "source_unavailable";

  const verifiedAt = parseInstant(record.lastVerifiedAt);
  if (
    record.verificationStatus === "unverified"
    || !record.officialSourceURL?.startsWith("https://")
    || !verifiedAt
  ) return "unverified";

  const validityStart = parseInstant(record.validityStart);
  const validityEnd = parseInstant(record.validityEnd);
  const nextReviewAt = parseInstant(record.nextReviewAt);
  if (validityStart && evaluatedAt < validityStart) return "unverified";
  if (
    record.verificationStatus === "overdue"
    || (validityEnd && evaluatedAt > validityEnd)
    || (nextReviewAt && evaluatedAt > nextReviewAt)
  ) return "overdue";
  if (record.verificationStatus === "review_due_soon") return "review_due_soon";
  if (nextReviewAt) {
    const leadMilliseconds = reviewDueLeadDays(record.reviewIntervalDays) * 86_400_000;
    if (evaluatedAt.valueOf() >= nextReviewAt.valueOf() - leadMilliseconds) return "review_due_soon";
  }
  return "verified";
}

export function confidenceBreakdown(
  record: GovernanceRecord,
  evaluatedAt = new Date()
): ConfidenceBreakdown {
  const status = effectiveVerificationStatus(record, evaluatedAt);
  return {
    officialSource: record.sourceIsOfficial && parseInstant(record.sourceOpenedAt) ? 40 : 0,
    humanReviewer: record.reviewedBy ? 20 : 0,
    independentReview:
      record.secondReviewedBy && record.secondReviewedBy !== record.reviewedBy ? 15 : 0,
    freshness: status === "verified" || status === "review_due_soon" ? 10 : 0,
    jurisdictionApplicability: record.jurisdiction?.applicabilityVerified === true ? 15 : 0
  };
}

export function confidenceScore(breakdown: ConfidenceBreakdown): number {
  return Object.values(breakdown).reduce<number>((sum, value) => sum + value, 0);
}

export function aiEligibility(record: GovernanceRecord, evaluatedAt = new Date()) {
  const status = effectiveVerificationStatus(record, evaluatedAt);
  if (["archived", "disputed", "source_unavailable", "unverified"].includes(status)) return "excluded" as const;
  if (status === "overdue") return "secondary_only" as const;
  return "primary" as const;
}

export function establishedMinimum(metrics: ReadinessMetric[]): ReadinessMetric {
  const template = metrics[0];
  if (!template || metrics.some((metric) => metric.evidenceState !== "established" || metric.value === null)) {
    return {
      value: null,
      evidenceState: "not_established",
      numerator: null,
      denominator: null,
      formulaVersion: template?.formulaVersion ?? 1,
      sourceArtifact: template?.sourceArtifact ?? "not_established",
      generatedAt: template?.generatedAt ?? new Date(0).toISOString()
    };
  }
  return {
    ...template,
    value: Math.min(...metrics.map((metric) => metric.value as number)),
    numerator: null,
    denominator: null
  };
}

export function overallReadiness(scorecard: ReadinessScorecard) {
  const dimensions = [
    scorecard.trust,
    scorecard.knowledge,
    scorecard.ai,
    scorecard.ux,
    scorecard.governance,
    scorecard.research
  ];
  const score = establishedMinimum(dimensions);
  const hardGatesPassed = Object.values(scorecard.hardGates).every(Boolean);
  return {
    ...score,
    releaseAuthority:
      score.evidenceState === "established"
      && (score.value ?? 0) >= 80
      && hardGatesPassed
        ? "GO"
        : "NO_GO",
    hardGatesPassed
  } as const;
}
