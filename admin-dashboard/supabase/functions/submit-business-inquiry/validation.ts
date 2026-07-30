const organizationTypes = new Set([
  "commercial-business",
  "sole-trader",
  "advertising-agency",
  "non-profit",
  "public-organization",
  "education",
  "healthcare",
  "other",
]);
const kvkRequiredTypes = new Set([
  "commercial-business",
  "sole-trader",
  "advertising-agency",
]);
const inquiryTypes = new Set([
  "advertising",
  "partnership",
  "media",
  "public-interest",
  "other",
]);
const audienceIds = new Set([
  "tourist",
  "student",
  "expat",
  "refugee",
  "worker",
  "resident",
]);
const placementIds = new Set([
  "featured-local-partner",
  "sponsored-listing",
  "sponsored-city-placement",
  "sponsored-category-placement",
  "featured-offer",
  "verified-organization-profile",
  "local-deal",
  "campaign-banner",
  "content-partnership",
  "referral-affiliate",
]);
const budgetRanges = new Set([
  "under-1000",
  "1000-3000",
  "3000-10000",
  "over-10000",
  "request-discussion",
]);
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

type UnknownRecord = Record<string, unknown>;

export type BusinessInquiryValidation = {
  valid: boolean;
  fields: string[];
};

function isObject(value: unknown): value is UnknownRecord {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function validText(value: unknown, minimum: number, maximum: number) {
  const normalized = text(value);
  return normalized.length >= minimum && normalized.length <= maximum;
}

function validUrl(value: unknown) {
  try {
    const parsed = new URL(text(value));
    return (parsed.protocol === "https:" || parsed.protocol === "http:") &&
      parsed.href.length <= 300;
  } catch {
    return false;
  }
}

function knownArray(value: unknown, allowed: Set<string>, maximum: number) {
  return Array.isArray(value) &&
    value.length >= 1 &&
    value.length <= maximum &&
    new Set(value).size === value.length &&
    value.every((item) => typeof item === "string" && allowed.has(item));
}

export function validateBusinessInquiryPayload(
  value: unknown,
): BusinessInquiryValidation {
  if (!isObject(value)) return { valid: false, fields: ["form"] };
  const fields: string[] = [];

  if (text(value.websiteConfirmation)) fields.push("form");
  if (!validText(value.companyName, 2, 120)) fields.push("companyName");
  if (!validText(value.contactPerson, 2, 120)) fields.push("contactPerson");
  if (!emailPattern.test(text(value.email)) || text(value.email).length > 254) {
    fields.push("email");
  }
  if (text(value.phone) && !validText(value.phone, 6, 40)) fields.push("phone");
  if (!validUrl(value.website)) fields.push("website");
  if (!inquiryTypes.has(text(value.inquiryType))) fields.push("inquiryType");
  if (!organizationTypes.has(text(value.organizationType))) {
    fields.push("organizationType");
  }
  if (
    (kvkRequiredTypes.has(text(value.organizationType)) &&
      !/^[0-9]{8}$/.test(text(value.kvkNumber))) ||
    (text(value.kvkNumber) && !/^[0-9]{8}$/.test(text(value.kvkNumber)))
  ) fields.push("kvkNumber");
  if (!validText(value.city, 2, 100)) fields.push("city");
  if (!validText(value.province, 2, 100)) fields.push("province");
  if (!knownArray(value.targetAudience, audienceIds, 6)) {
    fields.push("targetAudience");
  }
  if (!knownArray(value.requestedPlacements, placementIds, 10)) {
    fields.push("requestedPlacements");
  }
  if (!validText(value.campaignGoal, 10, 240)) fields.push("campaignGoal");
  if (!budgetRanges.has(text(value.budgetRange))) fields.push("budgetRange");

  const campaignStart = text(value.campaignStart);
  const campaignEnd = text(value.campaignEnd);
  if (
    (campaignStart && !campaignEnd) || (!campaignStart && campaignEnd) ||
    (campaignStart && campaignEnd && campaignEnd < campaignStart)
  ) {
    fields.push("campaignEnd");
  }
  if (!validText(value.description, 30, 600)) fields.push("description");
  if (value.consentToPrivacy !== true) fields.push("consentToPrivacy");
  if (value.confirmAccuracy !== true) fields.push("confirmAccuracy");
  if (!/^\/business(?:\/|$)/.test(text(value.sourcePage))) {
    fields.push("sourcePage");
  }

  return { valid: fields.length === 0, fields };
}
