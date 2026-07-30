import type { AdvertisingSurfaceId, RequestedPlacementId, SponsoredPlacementContext } from "./types";

export interface AdvertisingFormatDefinition {
  readonly id: RequestedPlacementId;
  readonly title: string;
  readonly description: string;
}

export interface AdvertisingSurfaceDefinition {
  readonly id: AdvertisingSurfaceId;
  readonly title: string;
  readonly surface: SponsoredPlacementContext["surface"];
  readonly routePattern: string;
  readonly position: string;
  readonly rationale: string;
  readonly formatIds: readonly RequestedPlacementId[];
  readonly inventoryState: "reserved-not-live";
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

/**
 * Stable, reviewable placement contract. These entries identify where a
 * sponsored unit may be integrated after a campaign has passed review. They do
 * not create empty ad boxes and they are not evidence of live inventory.
 */
export const advertisingSurfaceCatalog = [
  {
    id: "home-after-introduction",
    title: "Homepage context break",
    surface: "home",
    routePattern: "/",
    position: "After the introductory coverage block and before practical features.",
    rationale: "Keeps the first product explanation organic and gives promotion a separate visual band.",
    formatIds: ["featured-local-partner", "campaign-banner"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "discover-after-organic-results",
    title: "Discover results follow-up",
    surface: "discover",
    routePattern: "/discover/",
    position: "After the first organic result group; never inserted inside result ranking.",
    rationale: "Preserves the meaning and ordering of editorial discovery results.",
    formatIds: ["sponsored-listing", "featured-offer", "local-deal"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "city-after-overview",
    title: "City guide context",
    surface: "city",
    routePattern: "/cities/[city]/",
    position: "After the city overview and topic directory, before related material.",
    rationale: "Places a local promotion beside relevant context without presenting it as city guidance.",
    formatIds: ["sponsored-city-placement", "featured-local-partner", "local-deal"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "municipality-after-official-facts",
    title: "Municipality services follow-up",
    surface: "municipality",
    routePattern: "/municipalities/[municipality]/",
    position: "After official municipality facts; never inside the responsible-authority contact card.",
    rationale: "Maintains a hard boundary between government contact details and paid services.",
    formatIds: ["sponsored-city-placement", "featured-local-partner"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "province-after-municipality-directory",
    title: "Province directory follow-up",
    surface: "province",
    routePattern: "/provinces/[province]/",
    position: "After the complete municipality directory and before editorial YouNew records.",
    rationale: "Provides regional context without interrupting the official administrative list.",
    formatIds: ["featured-local-partner", "campaign-banner"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "category-after-featured-content",
    title: "Category context placement",
    surface: "category",
    routePattern: "/categories/[category]/",
    position: "After featured organic content and before the complete category list.",
    rationale: "Keeps sponsorship distinct from editorial selection and ranking.",
    formatIds: ["sponsored-category-placement", "featured-offer", "local-deal"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "guide-after-next-actions",
    title: "Guide completion placement",
    surface: "guide",
    routePattern: "/guides/[guide]/",
    position: "After next actions, warnings and responsible-source links.",
    rationale: "Never interrupts procedural steps, documents, safety advice or official verification.",
    formatIds: ["content-partnership", "referral-affiliate"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "organization-after-source-facts",
    title: "Organization page follow-up",
    surface: "organization",
    routePattern: "/organizations/[organization]/",
    position: "After responsible-source facts and before related organizations.",
    rationale: "A paid profile cannot replace or imitate the source-checked organization record.",
    formatIds: ["verified-organization-profile", "sponsored-listing"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "search-after-organic-results",
    title: "Search results follow-up",
    surface: "search",
    routePattern: "/search/",
    position: "After the organic results group with an independent Sponsored heading.",
    rationale: "Paid content never changes relevance scores or suggestion order.",
    formatIds: ["sponsored-listing", "campaign-banner"],
    inventoryState: "reserved-not-live"
  },
  {
    id: "map-after-selected-record",
    title: "Map selection follow-up",
    surface: "map",
    routePattern: "/map/",
    position: "Below the selected location record; never rendered as a map marker.",
    rationale: "Prevents payment from changing geography, clustering or published marker prominence.",
    formatIds: ["local-deal", "featured-offer", "sponsored-listing"],
    inventoryState: "reserved-not-live"
  }
] as const satisfies readonly AdvertisingSurfaceDefinition[];

export const advertisingExcludedSurfaces = [
  {
    routePattern: "/emergency/",
    reason: "Emergency instructions and ordering must remain entirely commercial-free."
  },
  {
    routePattern: "/privacy/, /terms/, /support/, /status/",
    reason: "Legal, support and service-status information must not be confused with promotion."
  },
  {
    routePattern: "Official-source cards and municipal contact blocks",
    reason: "A commercial message may never look like a government or responsible-source endorsement."
  }
] as const;

const labelsById = new Map<RequestedPlacementId, string>(
  advertisingFormatCatalog.map((format) => [format.id, format.title])
);

export function advertisingFormatLabel(id: RequestedPlacementId): string {
  return labelsById.get(id) ?? id.replaceAll("-", " ");
}
