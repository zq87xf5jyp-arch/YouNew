export const organizationTypes = [
  "commercial-business",
  "sole-trader",
  "advertising-agency",
  "non-profit",
  "public-organization",
  "education",
  "healthcare",
  "other"
] as const;

export type OrganizationType = (typeof organizationTypes)[number];

export const userProfileIds = ["tourist", "student", "expat", "refugee", "worker", "resident"] as const;
export type BusinessUserProfileId = (typeof userProfileIds)[number];

export const requestedPlacementIds = [
  "featured-local-partner",
  "sponsored-listing",
  "sponsored-city-placement",
  "sponsored-category-placement",
  "featured-offer",
  "verified-organization-profile",
  "local-deal",
  "campaign-banner",
  "content-partnership",
  "referral-affiliate"
] as const;

export type RequestedPlacementId = (typeof requestedPlacementIds)[number];

export const advertisingSurfaceIds = [
  "home-after-introduction",
  "discover-after-organic-results",
  "city-after-overview",
  "municipality-after-official-facts",
  "province-after-municipality-directory",
  "category-after-featured-content",
  "guide-after-next-actions",
  "organization-after-source-facts",
  "search-after-organic-results",
  "map-after-selected-record"
] as const;

export type AdvertisingSurfaceId = (typeof advertisingSurfaceIds)[number];

export const budgetRangeIds = [
  "under-1000",
  "1000-3000",
  "3000-10000",
  "over-10000",
  "request-discussion"
] as const;

export type BudgetRangeId = (typeof budgetRangeIds)[number];

export const inquiryTypeIds = ["advertising", "partnership", "media", "public-interest", "other"] as const;
export type InquiryTypeId = (typeof inquiryTypeIds)[number];

export interface BusinessApplicationInput {
  readonly companyName: string;
  readonly contactPerson: string;
  readonly email: string;
  readonly phone: string;
  readonly website: string;
  readonly inquiryType: InquiryTypeId | "";
  readonly organizationType: OrganizationType | "";
  readonly kvkNumber: string;
  readonly city: string;
  readonly province: string;
  readonly targetAudience: readonly BusinessUserProfileId[];
  readonly requestedPlacements: readonly RequestedPlacementId[];
  readonly campaignGoal: string;
  readonly budgetRange: BudgetRangeId | "";
  readonly campaignStart: string;
  readonly campaignEnd: string;
  readonly description: string;
  readonly consentToPrivacy: boolean;
  readonly confirmAccuracy: boolean;
  readonly websiteConfirmation: string;
  readonly sourcePage: string;
  readonly utmSource: string;
  readonly utmMedium: string;
  readonly utmCampaign: string;
  readonly utmContent: string;
  readonly utmTerm: string;
}

export type BusinessApplicationField = keyof BusinessApplicationInput | "form";

export interface BusinessApplicationValidation {
  readonly valid: boolean;
  readonly errors: Partial<Record<BusinessApplicationField, string>>;
}

export interface PreparedBusinessApplication {
  readonly kind: "user-email-handoff";
  readonly sent: false;
  readonly notice: "Nothing has been sent yet";
  readonly href: string;
  readonly recipient: "support@younew.nl";
}

export interface SubmittedBusinessApplication {
  readonly kind: "server-submission";
  readonly sent: true;
  readonly confirmationId: string;
  readonly createdAt: string;
}

export type BusinessApplicationResult = PreparedBusinessApplication | SubmittedBusinessApplication;

export interface PartnerApplicationRepository {
  readonly delivery: "mailto" | "api";
  submit(input: BusinessApplicationInput): Promise<BusinessApplicationResult>;
}

export type SponsoredPlacementStatus = "draft" | "review" | "active" | "paused" | "expired" | "archived";

export interface SponsoredPlacementRecord {
  readonly id: string;
  readonly advertiserId: string;
  readonly advertiserName: string;
  readonly label: "Sponsored";
  readonly title: string;
  readonly shortDescription: string;
  readonly media: Readonly<{
    src: string;
    alt: string;
    width: number;
    height: number;
  }> | null;
  readonly cta: Readonly<{
    label: string;
    destinationUrl: string;
  }>;
  readonly targeting: Readonly<{
    cityIds: readonly string[];
    provinceIds: readonly string[];
    categorySlugs: readonly string[];
    profileIds: readonly BusinessUserProfileId[];
  }>;
  readonly startAt: string;
  readonly endAt: string;
  readonly priority: number;
  readonly status: SponsoredPlacementStatus;
  readonly trackingId: string;
  readonly accessibilityLabel: string;
}

export interface SponsoredPlacementContext {
  readonly surface: "home" | "discover" | "city" | "municipality" | "province" | "category" | "guide" | "organization" | "search" | "map" | "emergency";
  readonly cityId?: string;
  readonly provinceId?: string;
  readonly categorySlug?: string;
  readonly profileId?: BusinessUserProfileId;
}
