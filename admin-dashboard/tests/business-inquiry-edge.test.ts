import assert from "node:assert/strict";
import test from "node:test";

import { validateBusinessInquiryPayload } from "../supabase/functions/submit-business-inquiry/validation.ts";
import { validatePublicFeedbackPayload } from "../supabase/functions/submit-public-feedback/validation.ts";

const validPayload = {
  companyName: "Example Amsterdam BV",
  contactPerson: "Ada Example",
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
  sourcePage: "/business/apply/",
  utmSource: "release-test",
  utmMedium: "qa",
  utmCampaign: "2026-07-29",
  utmContent: "",
  utmTerm: ""
};

test("edge validation accepts the complete browser contract", () => {
  assert.deepEqual(validateBusinessInquiryPayload(validPayload), { valid: true, fields: [] });
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
