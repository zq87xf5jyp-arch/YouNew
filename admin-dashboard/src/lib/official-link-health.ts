export const OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS = 24;
export const OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_MS =
  OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_HOURS * 60 * 60 * 1000;

// Link health is operational release evidence, so it uses the same 24-hour
// horizon as the Admin operational truth. Dates before 2000 are rejected as
// sentinel/legacy values rather than being presented as real observations.
const EARLIEST_PLAUSIBLE_OBSERVATION_MS = Date.UTC(2000, 0, 1);
const EXPLICIT_TIMEZONE_ISO =
  /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?(Z|([+-])(\d{2}):(\d{2}))$/;

export type OfficialLinkMeasuredHealth = "reachable" | "redirected" | "broken";
export type OfficialLinkObservationFreshness = "fresh" | "stale" | "unmeasured";
export type OfficialLinkObservationReason =
  | "fresh_observation"
  | "expired_observation"
  | "unknown_health"
  | "missing_timestamp"
  | "invalid_timestamp"
  | "sentinel_timestamp"
  | "future_timestamp"
  | "invalid_reference_timestamp";

export type OfficialLinkObservation = {
  freshness: OfficialLinkObservationFreshness;
  observedHealth: OfficialLinkMeasuredHealth | null;
  checkedAt: string | null;
  validThrough: string | null;
  countsTowardCoverage: boolean;
  reason: OfficialLinkObservationReason;
};

type OfficialLinkObservationInput = {
  link_health_state?: unknown;
  checked_at?: unknown;
};

function isMeasuredHealth(value: unknown): value is OfficialLinkMeasuredHealth {
  return value === "reachable" || value === "redirected" || value === "broken";
}

function parseExplicitTimezoneISO(value: string): number | null {
  const match = EXPLICIT_TIMEZONE_ISO.exec(value);
  if (!match) return null;
  const parsedMS = Date.parse(value);
  if (!Number.isFinite(parsedMS)) return null;

  const [, year, month, day, hour, minute, second, zone, offsetSign, offsetHour, offsetMinute] = match;
  const offsetMinutes = zone === "Z"
    ? 0
    : (offsetSign === "+" ? 1 : -1) * (Number(offsetHour) * 60 + Number(offsetMinute));
  const representedLocalTime = new Date(parsedMS + offsetMinutes * 60 * 1000);
  const components = [
    representedLocalTime.getUTCFullYear(),
    representedLocalTime.getUTCMonth() + 1,
    representedLocalTime.getUTCDate(),
    representedLocalTime.getUTCHours(),
    representedLocalTime.getUTCMinutes(),
    representedLocalTime.getUTCSeconds()
  ];
  const declaredComponents = [year, month, day, hour, minute, second].map(Number);
  return components.every((component, index) => component === declaredComponents[index]) ? parsedMS : null;
}

function unmeasured(reason: Exclude<OfficialLinkObservationReason, "fresh_observation" | "expired_observation">): OfficialLinkObservation {
  return {
    freshness: "unmeasured",
    observedHealth: null,
    checkedAt: null,
    validThrough: null,
    countsTowardCoverage: false,
    reason
  };
}

export function classifyOfficialLinkObservation(
  input: OfficialLinkObservationInput | null | undefined,
  referenceTimestamp: string
): OfficialLinkObservation {
  const referenceMS = Date.parse(referenceTimestamp);
  if (!Number.isFinite(referenceMS)) return unmeasured("invalid_reference_timestamp");
  if (!isMeasuredHealth(input?.link_health_state)) return unmeasured("unknown_health");
  if (typeof input.checked_at !== "string" || input.checked_at.length === 0) {
    return unmeasured("missing_timestamp");
  }
  const checkedAtMS = parseExplicitTimezoneISO(input.checked_at);
  if (checkedAtMS === null) return unmeasured("invalid_timestamp");
  if (checkedAtMS < EARLIEST_PLAUSIBLE_OBSERVATION_MS) return unmeasured("sentinel_timestamp");
  if (checkedAtMS > referenceMS) return unmeasured("future_timestamp");

  const checkedAt = new Date(checkedAtMS).toISOString();
  const validThroughMS = checkedAtMS + OFFICIAL_LINK_HEALTH_FRESHNESS_WINDOW_MS;
  const validThrough = new Date(validThroughMS).toISOString();
  if (referenceMS > validThroughMS) {
    return {
      freshness: "stale",
      observedHealth: input.link_health_state,
      checkedAt,
      validThrough,
      countsTowardCoverage: false,
      reason: "expired_observation"
    };
  }

  return {
    freshness: "fresh",
    observedHealth: input.link_health_state,
    checkedAt,
    validThrough,
    countsTowardCoverage: true,
    reason: "fresh_observation"
  };
}
