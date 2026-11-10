import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import { validateBusinessInquiryPayload } from "../supabase/functions/submit-business-inquiry/validation.ts";
import { validatePublicFeedbackPayload } from "../supabase/functions/submit-public-feedback/validation.ts";

const businessInquiryHandler = await readFile(
  new URL("../supabase/functions/submit-business-inquiry/index.ts", import.meta.url),
  "utf8"
);

const validPayload = {
  companyName: "Example Amsterdam BV",
  contactPerson: "Ada Example",
  contactRole: "Global Mobility Lead",
  offerInterest: "onboarding_pilot",
  email: "ada@example.nl",
  phone: "+31 20 123 4567",
  website: "https://example.nl",
  inquiryType: "advertising",
  organizationType: "commercial-business",
  kvkNumber: "12345678",
  city: "Amsterdam",
  province: "North Holland",
  targetAudience: ["student", "expat"],
  requestedPlacements: ["sponsored-city-placement"],
  campaignGoal: "Help new residents discover a relevant local service.",
  budgetRange: "1000-3000",
  campaignStart: "2026-09-01",
  campaignEnd: "2026-09-30",
  description: "A transparent placement proposal for a locally available service with clear terms.",
  consentToPrivacy: true,
  confirmAccuracy: true,
  websiteConfirmation: "",
  sourcePage: "/partners/apply/",
  utmSource: "release-test",
  utmMedium: "qa",
  utmCampaign: "2026-07-29",
  utmContent: "",
  utmTerm: ""
};

test("edge validation accepts the complete browser contract", () => {
  assert.deepEqual(validateBusinessInquiryPayload(validPayload), { valid: true, fields: [] });
});

test("edge validation accepts the dedicated local-business review route", () => {
  const localBusinessPayload = {
    ...validPayload,
    contactRole: "",
    offerInterest: "founding_partner_page",
    inquiryType: "partnership",
    requestedPlacements: ["verified-organization-profile"],
    campaignGoal: "Request to claim an existing business profile.",
    budgetRange: "request-discussion",
    campaignStart: "",
    campaignEnd: "",
    sourcePage: "/for-business/local/apply/"
  };
  assert.deepEqual(validateBusinessInquiryPayload(localBusinessPayload), { valid: true, fields: [] });
});

test("edge validation accepts the Dutch local-business review route", () => {
  const dutchPayload = {
    ...validPayload,
    contactRole: "",
    offerInterest: "founding_partner_page",
    inquiryType: "partnership",
    requestedPlacements: ["verified-organization-profile"],
    campaignGoal: "Request to add a new business profile.",
    budgetRange: "request-discussion",
    campaignStart: "",
    campaignEnd: "",
    sourcePage: "/nl/voor-bedrijven/aanmelden/"
  };
  assert.deepEqual(validateBusinessInquiryPayload(dutchPayload), { valid: true, fields: [] });
});

test("Dutch non-binding Business/Premium interest stays inside the validated inquiry contract", () => {
  const interestPayload = {
    ...validPayload,
    contactRole: "",
    offerInterest: "other",
    inquiryType: "partnership",
    requestedPlacements: ["verified-organization-profile"],
    campaignGoal: "Request to add a new business profile. Non-binding future Business/Premium interest: profile-insights.",
    budgetRange: "request-discussion",
    campaignStart: "",
    campaignEnd: "",
    sourcePage: "/nl/voor-bedrijven/aanmelden/"
  };
  assert.deepEqual(validateBusinessInquiryPayload(interestPayload), { valid: true, fields: [] });
});

test("business inquiry handler enforces an actual UTF-8 body limit even without content-length", () => {
  assert.match(businessInquiryHandler, /await request\.text\(\)/);
  assert.match(businessInquiryHandler, /new TextEncoder\(\)\.encode\(rawBody\)\.byteLength > 32_768/);
  assert.match(businessInquiryHandler, /JSON\.parse\(rawBody\)/);
});

test("edge validation requires a reviewed offer and validates the optional contact role", () => {
  const missingOffer = validateBusinessInquiryPayload({ ...validPayload, offerInterest: "" });
  const shortRole = validateBusinessInquiryPayload({ ...validPayload, contactRole: "x" });
  assert.ok(missingOffer.fields.includes("offerInterest"));
  assert.ok(shortRole.fields.includes("contactRole"));
});

test("edge validation rejects bot fields, unknown selections and missing consent", () => {
  const result = validateBusinessInquiryPayload({
    ...validPayload,
    websiteConfirmation: "filled",
    targetAudience: ["unknown"],
    requestedPlacements: ["unknown"],
    consentToPrivacy: false
  });
  assert.equal(result.valid, false);
  assert.deepEqual(new Set(result.fields), new Set(["form", "targetAudience", "requestedPlacements", "consentToPrivacy"]));
});

test("edge validation rejects partial date ranges and invalid source pages", () => {
  const result = validateBusinessInquiryPayload({
    ...validPayload,
    campaignEnd: "",
    sourcePage: "/support/"
  });
  assert.equal(result.valid, false);
  assert.ok(result.fields.includes("campaignEnd"));
  assert.ok(result.fields.includes("sourcePage"));
});

test("public feedback edge validation rejects bot fields and invalid references", () => {
  assert.deepEqual(validatePublicFeedbackPayload({
    email: "",
    feedbackType: "incorrect-information",
    message: "The official instructions on this page should be checked again.",
    pageReference: "/guides/example/",
    consentToPrivacy: true,
    websiteConfirmation: ""
  }), { valid: true, fields: [] });
  const rejected = validatePublicFeedbackPayload({
    email: "not-an-email",
    feedbackType: "unknown",
    message: "short",
    pageReference: "https://example.com/",
    consentToPrivacy: false,
    websiteConfirmation: "bot"
  });
  assert.equal(rejected.valid, false);
  assert.deepEqual(
    new Set(rejected.fields),
    new Set(["form", "email", "feedbackType", "message", "pageReference", "consentToPrivacy"])
  );
});
