import type {
  BusinessApplicationInput,
  BusinessApplicationValidation,
  OrganizationType,
  PartnerApplicationRepository,
  PreparedBusinessApplication
} from "./types";
// The explicit extension keeps this shared runtime catalogue resolvable by the
// repository's direct Node TypeScript test runner as well as the Next.js build.
import { advertisingFormatCatalog, advertisingFormatLabel } from "./catalog.ts";

const organizationTypes: readonly OrganizationType[] = [
  "commercial-business",
  "sole-trader",
  "advertising-agency",
  "non-profit",
  "public-organization",
  "education",
  "healthcare",
  "other"
];
const userProfileIds = ["tourist", "student", "expat", "refugee", "worker", "resident"] as const;
const requestedPlacementIds = advertisingFormatCatalog.map((format) => format.id);
const budgetRangeIds = ["under-1000", "1000-3000", "3000-10000", "over-10000", "request-discussion"] as const;

export const BUSINESS_APPLICATION_EMAIL = "support@younew.nl" as const;
export const NOTHING_SENT_NOTICE = "Nothing has been sent yet" as const;

const kvkRequiredTypes = new Set<OrganizationType>([
  "commercial-business",
  "sole-trader",
  "advertising-agency"
]);

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function requiresKvkNumber(organizationType: BusinessApplicationInput["organizationType"]): boolean {
  return organizationType !== "" && kvkRequiredTypes.has(organizationType);
}

function isSafeWebsite(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "https:" || url.protocol === "http:";
  } catch {
    return false;
  }
}

function hasOnlyKnownValues<T extends string>(values: readonly string[], allowed: readonly T[]): values is readonly T[] {
  const allowedValues = new Set<string>(allowed);
  return values.every((value) => allowedValues.has(value));
}

export function validateBusinessApplication(input: BusinessApplicationInput): BusinessApplicationValidation {
  const errors: BusinessApplicationValidation["errors"] = {};

  if (input.websiteConfirmation.trim()) {
    errors.form = "This application could not be prepared. Please contact support@younew.nl directly.";
  }
  if (input.companyName.trim().length < 2) errors.companyName = "Enter the company or organization name.";
  else if (input.companyName.trim().length > 120) errors.companyName = "Keep the organization name under 120 characters.";
  if (input.contactPerson.trim().length < 2) errors.contactPerson = "Enter a contact person.";
  else if (input.contactPerson.trim().length > 120) errors.contactPerson = "Keep the contact name under 120 characters.";
  if (!emailPattern.test(input.email.trim())) errors.email = "Enter a valid email address.";
  else if (input.email.trim().length > 254) errors.email = "Keep the email address under 254 characters.";
  if (input.phone.trim() && input.phone.trim().length < 6) errors.phone = "Enter a valid phone number or leave it blank.";
  else if (input.phone.trim().length > 40) errors.phone = "Keep the phone number under 40 characters.";
  if (!isSafeWebsite(input.website.trim())) errors.website = "Enter a complete website URL beginning with https:// or http://.";
  else if (input.website.trim().length > 300) errors.website = "Keep the website URL under 300 characters.";
  if (!organizationTypes.includes(input.organizationType as OrganizationType)) {
    errors.organizationType = "Select an organization type.";
  }
  if (requiresKvkNumber(input.organizationType) && input.kvkNumber.replace(/\D/g, "").length !== 8) {
    errors.kvkNumber = "Enter the 8-digit KvK number for this organization type.";
  } else if (input.kvkNumber.trim() && input.kvkNumber.replace(/\D/g, "").length !== 8) {
    errors.kvkNumber = "A KvK number must contain 8 digits.";
  }
  if (input.city.trim().length < 2) errors.city = "Enter the primary city for this request.";
  else if (input.city.trim().length > 100) errors.city = "Keep the city under 100 characters.";
  if (input.province.trim().length < 2) errors.province = "Select a province.";
  if (!input.targetAudience.length) errors.targetAudience = "Select at least one target audience.";
  else if (!hasOnlyKnownValues(input.targetAudience, userProfileIds)) errors.targetAudience = "Select only supported audience profiles.";
  if (!input.requestedPlacements.length) errors.requestedPlacements = "Select at least one requested placement.";
  else if (!hasOnlyKnownValues(input.requestedPlacements, requestedPlacementIds)) errors.requestedPlacements = "Select only supported placement types.";
  if (input.campaignGoal.trim().length < 10) errors.campaignGoal = "Describe the campaign goal in at least 10 characters.";
  else if (input.campaignGoal.trim().length > 240) errors.campaignGoal = "Keep the campaign goal under 240 characters.";
  if (!budgetRangeIds.includes(input.budgetRange as (typeof budgetRangeIds)[number])) errors.budgetRange = "Select a budget range.";
  if ((input.campaignStart && !input.campaignEnd) || (!input.campaignStart && input.campaignEnd)) {
    errors.campaignEnd = "Provide both campaign dates or leave both blank.";
  } else if (input.campaignStart && input.campaignEnd && input.campaignEnd < input.campaignStart) {
    errors.campaignEnd = "The campaign end date must be on or after the start date.";
  }
  if (input.description.trim().length < 30) errors.description = "Provide at least 30 characters of useful context.";
  if (input.description.trim().length > 600) errors.description = "Keep the description under 600 characters for the email handoff.";
  if (!input.consentToPrivacy) errors.consentToPrivacy = "Consent to the Privacy Policy is required.";
  if (!input.confirmAccuracy) errors.confirmAccuracy = "Confirm that the submitted information is accurate.";

  return { valid: Object.keys(errors).length === 0, errors };
}

function readable(value: string): string {
  return value.replaceAll("-", " ");
}

export function createBusinessApplicationMailto(input: BusinessApplicationInput): string {
  const subject = `YouNew business inquiry — ${input.companyName.trim()}`;
  const lines = [
    "YouNew business inquiry",
    "",
    `Company / organization: ${input.companyName.trim()}`,
    `Contact person: ${input.contactPerson.trim()}`,
    `Email: ${input.email.trim().toLowerCase()}`,
    `Phone: ${input.phone.trim() || "Not provided"}`,
    `Website: ${input.website.trim()}`,
    `Organization type: ${readable(input.organizationType)}`,
    `KvK number: ${input.kvkNumber.trim() || "Not provided"}`,
    `City: ${input.city.trim()}`,
    `Province: ${input.province.trim()}`,
    `Target audience: ${input.targetAudience.map(readable).join(", ")}`,
    `Requested placement: ${input.requestedPlacements.map(advertisingFormatLabel).join(", ")}`,
    `Campaign goal: ${input.campaignGoal.trim()}`,
    `Budget range: ${readable(input.budgetRange)}`,
    `Campaign dates: ${input.campaignStart && input.campaignEnd ? `${input.campaignStart} to ${input.campaignEnd}` : "To be discussed"}`,
    "",
    "Description:",
    input.description.trim(),
    "",
    "Privacy Policy consent: confirmed",
    "Information accuracy: confirmed",
    "",
    "This draft was prepared on younew.nl. It is sent only when the sender confirms it in their email application."
  ];

  return `mailto:${BUSINESS_APPLICATION_EMAIL}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(lines.join("\n"))}`;
}

export const mailtoPartnerApplicationRepository: PartnerApplicationRepository = {
  delivery: "mailto",
  async submit(input): Promise<PreparedBusinessApplication> {
    const validation = validateBusinessApplication(input);
    if (!validation.valid) throw new Error("The business application contains invalid fields.");
    return {
      kind: "user-email-handoff",
      sent: false,
      notice: NOTHING_SENT_NOTICE,
      href: createBusinessApplicationMailto(input),
      recipient: BUSINESS_APPLICATION_EMAIL
    };
  }
};
