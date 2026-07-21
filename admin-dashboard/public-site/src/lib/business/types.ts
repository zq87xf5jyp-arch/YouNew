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

export const budgetRangeIds = [
  "under-1000",
  "1000-3000",
  "3000-10000",
  "over-10000",
  "request-discussion"
] as const;

export type BudgetRangeId = (typeof budgetRangeIds)[number];

export interface BusinessApplicationInput {
  readonly companyName: string;
  readonly contactPerson: string;
  readonly email: string;
  readonly phone: string;
  readonly website: string;
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

export interface PartnerApplicationRepository {
  readonly delivery: "mailto" | "api";
  submit(input: BusinessApplicationInput): Promise<PreparedBusinessApplication>;
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
  readonly surface: "home" | "discover" | "city" | "province" | "category" | "guide" | "organization" | "search" | "emergency";
  readonly cityId?: string;
  readonly provinceId?: string;
  readonly categorySlug?: string;
  readonly profileId?: BusinessUserProfileId;
}
