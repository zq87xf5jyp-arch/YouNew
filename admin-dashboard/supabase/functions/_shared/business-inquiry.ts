const organizationTypes = new Set([
  "commercial-business",
  "sole-trader",
  "advertising-agency",
  "non-profit",
  "public-organization",
  "education",
  "healthcare",
  "other"
]);

const commercialOrganizationTypes = new Set([
  "commercial-business",
  "sole-trader",
  "advertising-agency"
]);

const audienceTypes = new Set(["tourist", "student", "expat", "refugee", "worker", "resident"]);

const placementTypes = new Set([
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
]);

const budgetRanges = new Set([
  "under-1000",
  "1000-3000",
  "3000-10000",
  "over-10000",
  "request-discussion"
]);

const provinces = new Set([
  "Drenthe",
  "Flevoland",
  "Friesland",
  "Gelderland",
  "Groningen",
  "Limburg",
  "North Brabant",
  "North Holland",
  "Overijssel",
  "South Holland",
  "Utrecht",
  "Zeeland"
]);

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const datePattern = /^\d{4}-\d{2}-\d{2}$/;

export type ValidatedBusinessInquiry = {
  companyName: string;
  contactPerson: string;
  email: string;
  phone: string;
  website: string;
  organizationType: string;
  kvkNumber: string;
  city: string;
  province: string;
  targetAudience: string[];
  requestedPlacements: string[];
  campaignGoal: string;
  budgetRange: string;
  campaignStart: string;
  campaignEnd: string;
  description: string;
  consentToPrivacy: true;
  confirmAccuracy: true;
  websiteConfirmation: "";
};

export type BusinessInquiryValidationResult =
  | { valid: true; value: ValidatedBusinessInquiry }
  | { valid: false; errors: Record<string, string> };

function record(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function text(input: Record<string, unknown>, key: string): string {
  return typeof input[key] === "string" ? input[key].trim() : "";
}

function stringList(input: Record<string, unknown>, key: string): string[] {
  const value = input[key];
  if (!Array.isArray(value) || !value.every((item) => typeof item === "string")) return [];
  return [...new Set(value.map((item) => item.trim()).filter(Boolean))];
}

function hasKnownValues(values: readonly string[], allowed: ReadonlySet<string>): boolean {
  return values.every((value) => allowed.has(value));
}

function validWebsite(value: string): boolean {
  try {
    const url = new URL(value);
    return (url.protocol === "https:" || url.protocol === "http:") && Boolean(url.hostname);
  } catch {
    return false;
  }
}

export function validateBusinessInquiryPayload(value: unknown): BusinessInquiryValidationResult {
  const input = record(value);
  if (!input) return { valid: false, errors: { form: "Expected a JSON object." } };

  const companyName = text(input, "companyName");
  const contactPerson = text(input, "contactPerson");
  const email = text(input, "email").toLowerCase();
  const phone = text(input, "phone");
  const website = text(input, "website");
  const organizationType = text(input, "organizationType");
  const kvkNumber = text(input, "kvkNumber").replace(/\D/g, "");
  const city = text(input, "city");
  const province = text(input, "province");
  const targetAudience = stringList(input, "targetAudience");
  const requestedPlacements = stringList(input, "requestedPlacements");
  const campaignGoal = text(input, "campaignGoal");
  const budgetRange = text(input, "budgetRange");
  const campaignStart = text(input, "campaignStart");
  const campaignEnd = text(input, "campaignEnd");
  const description = text(input, "description");
  const websiteConfirmation = text(input, "websiteConfirmation");
  const consentToPrivacy = input.consentToPrivacy === true;
  const confirmAccuracy = input.confirmAccuracy === true;
  const errors: Record<string, string> = {};

  if (websiteConfirmation) errors.form = "Automated submission rejected.";
  if (companyName.length < 2 || companyName.length > 120) errors.companyName = "Invalid organization name.";
  if (contactPerson.length < 2 || contactPerson.length > 120) errors.contactPerson = "Invalid contact name.";
  if (!emailPattern.test(email) || email.length > 254) errors.email = "Invalid email address.";
  if (phone && (phone.length < 6 || phone.length > 40)) errors.phone = "Invalid phone number.";
  if (!validWebsite(website) || website.length > 300) errors.website = "Invalid website URL.";
  if (!organizationTypes.has(organizationType)) errors.organizationType = "Invalid organization type.";
  if ((commercialOrganizationTypes.has(organizationType) && kvkNumber.length !== 8)
    || (kvkNumber && kvkNumber.length !== 8)) errors.kvkNumber = "Invalid KvK number.";
  if (city.length < 2 || city.length > 100) errors.city = "Invalid city.";
  if (!provinces.has(province)) errors.province = "Invalid province.";
  if (!targetAudience.length || !hasKnownValues(targetAudience, audienceTypes)) {
    errors.targetAudience = "Invalid target audience.";
  }
  if (!requestedPlacements.length || !hasKnownValues(requestedPlacements, placementTypes)) {
    errors.requestedPlacements = "Invalid requested placement.";
  }
  if (campaignGoal.length < 10 || campaignGoal.length > 240) errors.campaignGoal = "Invalid campaign goal.";
  if (!budgetRanges.has(budgetRange)) errors.budgetRange = "Invalid budget range.";
  if (Boolean(campaignStart) !== Boolean(campaignEnd)
    || (campaignStart && (!datePattern.test(campaignStart) || !datePattern.test(campaignEnd)))
    || (campaignStart && campaignEnd < campaignStart)) errors.campaignEnd = "Invalid campaign dates.";
  if (description.length < 30 || description.length > 600) errors.description = "Invalid description.";
  if (!consentToPrivacy) errors.consentToPrivacy = "Privacy consent is required.";
  if (!confirmAccuracy) errors.confirmAccuracy = "Accuracy confirmation is required.";

  if (Object.keys(errors).length) return { valid: false, errors };

  return {
    valid: true,
    value: {
      companyName,
      contactPerson,
      email,
      phone,
      website,
      organizationType,
      kvkNumber,
      city,
      province,
      targetAudience,
      requestedPlacements,
      campaignGoal,
      budgetRange,
      campaignStart,
      campaignEnd,
      description,
      consentToPrivacy: true,
      confirmAccuracy: true,
      websiteConfirmation: ""
    }
  };
}
