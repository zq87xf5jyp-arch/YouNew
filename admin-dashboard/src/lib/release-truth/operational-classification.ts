import type {
  GovernanceRisk,
  GovernanceSummary,
  OperationalTruth,
  ReviewQueueSnapshot,
  ReviewTask,
  SourceResult
} from "./types.ts";

export type OperationalQueryFailure = { message?: string } | null;
export type OperationalQueryResult<T> = { data: T; error: OperationalQueryFailure; count?: number | null };

function unavailable<T>(
  observedAt: string,
  reason: "configuration" | "query" | "invalid_source_timestamp"
): SourceResult<T> {
  return { state: "unavailable", observedAt, reason };
}

export function unavailableOperationalTruth(observedAt: string): OperationalTruth {
  return {
    governanceSummary: unavailable(observedAt, "configuration"),
    reviewQueue: unavailable(observedAt, "configuration"),
    reviewSlaBreaches: unavailable(observedAt, "configuration"),
    governanceRisks: unavailable(observedAt, "configuration")
  };
}

export function classifyGovernanceSummary(
  data: GovernanceSummary | null,
  error: OperationalQueryFailure,
  queriedAt: string,
  maximumAgeMS = 24 * 60 * 60 * 1000
): SourceResult<GovernanceSummary | null> {
  if (error) return unavailable(queriedAt, "query");
  if (!data) return { state: "available", observedAt: queriedAt, data: null };
  const generatedAt = Date.parse(data.generated_at);
  const queryTime = Date.parse(queriedAt);
  if (!Number.isFinite(generatedAt) || !Number.isFinite(queryTime)) {
    return unavailable(queriedAt, "invalid_source_timestamp");
  }
  const validThrough = new Date(generatedAt + maximumAgeMS).toISOString();
  if (queryTime > generatedAt + maximumAgeMS) {
    return {
      state: "stale",
      observedAt: new Date(generatedAt).toISOString(),
      validThrough,
      data,
      reason: "source_timestamp_expired"
    };
  }
  return { state: "available", observedAt: new Date(generatedAt).toISOString(), data };
}

export function assembleOperationalTruth(
  summaryResult: OperationalQueryResult<GovernanceSummary | null>,
  queueResult: OperationalQueryResult<ReviewTask[] | null>,
  riskResult: OperationalQueryResult<GovernanceRisk[] | null>,
  slaBreachResult: OperationalQueryResult<null>,
  observedAt: string,
  offset = 0
): OperationalTruth {
  const governanceSummary = classifyGovernanceSummary(summaryResult.data, summaryResult.error, observedAt);

  let reviewQueue: SourceResult<ReviewQueueSnapshot>;
  if (queueResult.error) {
    reviewQueue = unavailable(observedAt, "query");
  } else {
    // The security-invoker view is ordered before offset pagination in the DB.
    // Re-sorting a page here would make ordering globally incorrect.
    const items = [...(queueResult.data ?? [])] as ReviewTask[];
    const total = queueResult.count ?? items.length;
    reviewQueue = {
      state: "available",
      observedAt,
      data: {
        total,
        items,
        truncated: offset + items.length < total,
        nextOffset: offset + items.length < total ? offset + items.length : null
      }
    };
  }

  const reviewSlaBreaches: SourceResult<number> = slaBreachResult.error
    ? unavailable(observedAt, "query")
    : { state: "available", observedAt, data: slaBreachResult.count ?? 0 };

  const governanceRisks: SourceResult<GovernanceRisk[]> = riskResult.error
    ? unavailable(observedAt, "query")
    : { state: "available", observedAt, data: riskResult.data ?? [] };

  return { governanceSummary, reviewQueue, reviewSlaBreaches, governanceRisks };
}
