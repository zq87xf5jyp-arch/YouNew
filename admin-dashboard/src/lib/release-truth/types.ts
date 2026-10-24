export type EvidenceState =
  | "measured"
  | "provisional"
  | "not_applicable"
  | "unknown"
  | "unavailable"
  | "stale";

export type TechnicalVerdict = "GO" | "PARTIAL" | "NO_GO";
export type DeploymentAuthorization = "not_granted" | "granted";
export type GateResult = "pass" | "fail" | "blocked" | "not_applicable";

export type EvidenceMetric = {
  kind: "count" | "ratio" | "duration" | "status";
  unit: "count" | "percent" | "days" | "state";
  value: number | string | null;
  numerator: number | null;
  denominator: number | null;
  state: EvidenceState;
  reasonCode: string | null;
  formula: { id: string; version: number };
  sourceIDs: string[];
};

export type EvidenceSource = {
  id: string;
  kind: string;
  sourceRef: string;
  sha256: string | null;
  observedAt: string | null;
  validThrough: string | null;
  state: EvidenceState;
  scope: string;
};

export type ReleaseTruthSnapshot = {
  schemaVersion: 2;
  snapshotID: string;
  snapshotDigest: string;
  generatedAt: string;
  candidateCommit: string;
  sourceTreeState: "clean" | "dirty";
  sourceTreeExclusions: string[];
  technicalVerdict: TechnicalVerdict;
  deploymentAuthorization: DeploymentAuthorization;
  verdictReason: string;
  sources: EvidenceSource[];
  publication: {
    inventory: {
      state: EvidenceState;
      total: number;
      verified: number;
      outdated: number;
      nextReleaseID: string | null;
      nextReleaseStatus: string | null;
    };
    packaged: {
      state: EvidenceState;
      entityCount: number;
      releaseIDs: string[];
      datasetFingerprint: string;
      outputChecksum: string;
    };
    deployed: {
      state: EvidenceState;
      evidenceLevel: "none" | "metadata_attested" | "payload_verified";
      entityCount: number | null;
      declaredEntityCount: number | null;
      datasetFingerprint: string | null;
      observationRef: string;
    };
  };
  metrics: Record<string, EvidenceMetric>;
  gates: Record<string, { result: GateResult; reason: string; sourceIDs: string[] }>;
  limitations: string[];
};

export type SourceResult<T> =
  | { state: "available"; observedAt: string; data: T }
  | { state: "stale"; observedAt: string; validThrough: string; data: T; reason: "source_timestamp_expired" }
  | { state: "unavailable"; observedAt: string; reason: "configuration" | "query" | "invalid_source_timestamp" };

export type GovernanceSummary = {
  denominator: number;
  verified: number;
  review_due_soon: number;
  overdue: number;
  disputed: number;
  source_unavailable: number;
  published: number;
  average_confidence: number | null;
  median_confidence: number | null;
  review_queue: number;
  review_sla_breaches: number;
  generated_at: string;
};

export type ReviewTask = {
  id: string;
  governance_state_id: string;
  owner_id: string | null;
  reason: string;
  severity: "low" | "medium" | "high" | "critical";
  severity_rank: 0 | 1 | 2 | 3;
  state: string;
  sla_due_at: string;
  resolved_at: string | null;
  created_at: string;
  updated_at: string;
};

export type ReviewQueueSnapshot = {
  total: number;
  items: ReviewTask[];
  truncated: boolean;
  nextOffset: number | null;
};

export type GovernanceRisk = {
  record_key: string;
  title: string;
  risk_priority: number;
  effective_verification_status: string;
  criticality: string;
  version: number;
};

export type OperationalTruth = {
  governanceSummary: SourceResult<GovernanceSummary | null>;
  reviewQueue: SourceResult<ReviewQueueSnapshot>;
  reviewSlaBreaches: SourceResult<number>;
  governanceRisks: SourceResult<GovernanceRisk[]>;
};
