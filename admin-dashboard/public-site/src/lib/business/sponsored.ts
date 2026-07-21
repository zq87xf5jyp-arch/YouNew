import type { SponsoredPlacementContext, SponsoredPlacementRecord } from "./types";

export const SPONSORED_PLACEMENTS_ENABLED = false;

function targetsValue(values: readonly string[], currentValue: string | undefined): boolean {
  return values.length === 0 || (currentValue !== undefined && values.includes(currentValue));
}

function hasSafeDestination(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "https:" || url.protocol === "http:";
  } catch {
    return false;
  }
}

export function isSponsoredPlacementEligible(
  placement: SponsoredPlacementRecord,
  context: SponsoredPlacementContext,
  options: Readonly<{ enabled?: boolean; now?: Date }> = {}
): boolean {
  const enabled = options.enabled ?? SPONSORED_PLACEMENTS_ENABLED;
  if (!enabled || context.surface === "emergency" || placement.status !== "active") return false;
  if (!placement.id || !placement.advertiserId || !placement.advertiserName || !placement.trackingId) return false;
  if (!placement.accessibilityLabel || placement.label !== "Sponsored" || !hasSafeDestination(placement.cta.destinationUrl)) return false;

  const now = options.now ?? new Date();
  const startsAt = new Date(placement.startAt);
  const endsAt = new Date(placement.endAt);
  if (Number.isNaN(startsAt.valueOf()) || Number.isNaN(endsAt.valueOf()) || endsAt < startsAt) return false;
  if (now < startsAt || now > endsAt) return false;

  return (
    targetsValue(placement.targeting.cityIds, context.cityId) &&
    targetsValue(placement.targeting.provinceIds, context.provinceId) &&
    targetsValue(placement.targeting.categorySlugs, context.categorySlug) &&
    targetsValue(placement.targeting.profileIds, context.profileId)
  );
}
