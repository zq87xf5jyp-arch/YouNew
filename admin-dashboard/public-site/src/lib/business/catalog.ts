import type { RequestedPlacementId } from "./types";

export interface AdvertisingFormatDefinition {
  readonly id: RequestedPlacementId;
  readonly title: string;
  readonly description: string;
}

/**
 * One shared, typed catalogue for public format descriptions, the inquiry form
 * and the email handoff. Availability is always subject to manual review and a
 * written quote; this is not an inventory or pricing feed.
 */
export const advertisingFormatCatalog = [
  {
    id: "featured-local-partner",
    title: "Featured local partner",
    description: "A clearly marked local partner presentation in an agreed, relevant context."
  },
  {
    id: "sponsored-listing",
    title: "Sponsored listing",
    description: "A labelled organization or place listing with a disclosed commercial relationship."
  },
  {
    id: "sponsored-city-placement",
    title: "Sponsored city placement",
    description: "A labelled placement on an eligible published city page."
  },
  {
    id: "sponsored-category-placement",
    title: "Sponsored category placement",
    description: "A labelled placement on an eligible published topic page."
  },
  {
    id: "featured-offer",
    title: "Featured offer",
    description: "A time-bound offer with clear terms, advertiser identity and destination."
  },
  {
    id: "verified-organization-profile",
    title: "Verified organization profile",
    description: "A profile request subject to identity, relevance and claim verification; payment never makes an organization official."
  },
  {
    id: "local-deal",
    title: "Local deal",
    description: "A clearly disclosed local promotion whose eligibility, terms and end date are visible."
  },
  {
    id: "campaign-banner",
    title: "Campaign banner",
    description: "A distinct promotional unit that does not imitate navigation or official advice."
  },
  {
    id: "content-partnership",
    title: "Content partnership",
    description: "A reviewed collaboration with authorship, sponsorship and source disclosure."
  },
  {
    id: "referral-affiliate",
    title: "Referral or affiliate placement",
    description: "A placement considered only with transparent commercial marking."
  }
] as const satisfies readonly AdvertisingFormatDefinition[];

const labelsById = new Map<RequestedPlacementId, string>(
  advertisingFormatCatalog.map((format) => [format.id, format.title])
);

export function advertisingFormatLabel(id: RequestedPlacementId): string {
  return labelsById.get(id) ?? id.replaceAll("-", " ");
}
