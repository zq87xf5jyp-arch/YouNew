import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import type { BusinessApplicationInput, SponsoredPlacementRecord } from "../src/lib/business/types";

const applicationModule = (await import(new URL("../src/lib/business/application.ts", import.meta.url).href)) as typeof import("../src/lib/business/application");
const catalogModule = (await import(new URL("../src/lib/business/catalog.ts", import.meta.url).href)) as typeof import("../src/lib/business/catalog");
const typesModule = (await import(new URL("../src/lib/business/types.ts", import.meta.url).href)) as typeof import("../src/lib/business/types");
const sponsoredModule = (await import(new URL("../src/lib/business/sponsored.ts", import.meta.url).href)) as typeof import("../src/lib/business/sponsored");
const mediaKitSource = await readFile(new URL("../src/app/business/media-kit/page.tsx", import.meta.url), "utf8");

const validApplication: BusinessApplicationInput = {
  companyName: "Example Amsterdam BV",
  contactPerson: "Ada Example",
  email: "ada@example.nl",
  phone: "+31 20 123 4567",
  website: "https://example.nl",
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
  websiteConfirmation: ""
};

const activePlacement: SponsoredPlacementRecord = {
  id: "campaign.example-amsterdam",
  advertiserId: "advertiser.example",
  advertiserName: "Example Amsterdam",
  label: "Sponsored",
  title: "A clearly labelled local offer",
  shortDescription: "Example sponsored copy used only for eligibility tests.",
  media: null,
  cta: { label: "Visit advertiser", destinationUrl: "https://example.nl/offer" },
  targeting: {
    cityIds: ["city.amsterdam"],
    provinceIds: ["province.north-holland"],
    categorySlugs: ["integration"],
    profileIds: ["expat"]
  },
  startAt: "2026-09-01T00:00:00.000Z",
  endAt: "2026-09-30T23:59:59.000Z",
  priority: 10,
  status: "active",
  trackingId: "sp-example-amsterdam",
  accessibilityLabel: "Sponsored placement from Example Amsterdam"
};

test("business application validates a complete commercial inquiry", () => {
  assert.deepEqual(applicationModule.validateBusinessApplication(validApplication), { valid: true, errors: {} });
});

test("KvK is conditional and commercial inquiries require eight digits", () => {
  assert.equal(applicationModule.requiresKvkNumber("commercial-business"), true);
  assert.equal(applicationModule.requiresKvkNumber("non-profit"), false);

  const missingKvk = applicationModule.validateBusinessApplication({ ...validApplication, kvkNumber: "" });
  assert.equal(missingKvk.valid, false);
  assert.match(missingKvk.errors.kvkNumber ?? "", /8-digit KvK/);

  const optionalKvk = applicationModule.validateBusinessApplication({
    ...validApplication,
    organizationType: "non-profit",
    kvkNumber: ""
  });
  assert.equal(optionalKvk.valid, true);
});

test("date order, confirmations and honeypot are enforced", () => {
  const result = applicationModule.validateBusinessApplication({
    ...validApplication,
    campaignStart: "2026-10-01",
    campaignEnd: "2026-09-01",
    consentToPrivacy: false,
    confirmAccuracy: false,
    websiteConfirmation: "filled-by-bot"
  });
  assert.equal(result.valid, false);
  assert.ok(result.errors.campaignEnd);
  assert.ok(result.errors.consentToPrivacy);
  assert.ok(result.errors.confirmAccuracy);
  assert.ok(result.errors.form);
});

test("mailto repository prepares a user-controlled draft and never claims submission", async () => {
  const result = await applicationModule.mailtoPartnerApplicationRepository.submit(validApplication);
  assert.equal(applicationModule.mailtoPartnerApplicationRepository.delivery, "mailto");
  assert.equal(result.sent, false);
  assert.equal(result.notice, "Nothing has been sent yet");
  assert.equal(result.recipient, "support@younew.nl");
  assert.match(result.href, /^mailto:support@younew\.nl\?/);
  assert.match(decodeURIComponent(result.href), /Example Amsterdam BV/);
  assert.doesNotMatch(decodeURIComponent(result.href), /websiteConfirmation/);
});

test("one typed advertising catalogue covers every inquiry placement and the mail handoff", () => {
  const catalogueIds = catalogModule.advertisingFormatCatalog.map((format) => format.id);
  assert.equal(new Set(catalogueIds).size, catalogueIds.length);
  assert.deepEqual([...catalogueIds].sort(), [...typesModule.requestedPlacementIds].sort());
  assert.ok(catalogModule.advertisingFormatCatalog.every((format) => format.title.length > 4 && format.description.length > 20));

  const mailto = decodeURIComponent(applicationModule.createBusinessApplicationMailto({
    ...validApplication,
    requestedPlacements: [...typesModule.requestedPlacementIds]
  }));
  for (const format of catalogModule.advertisingFormatCatalog) assert.ok(mailto.includes(format.title));
});

test("media kit labels demonstrations and current reporting limits without publishing a rate card", () => {
  assert.match(mediaKitSource, /DEMO PARTNER CARD · NOT LIVE/);
  assert.match(mediaKitSource, /DEMO REPORT · ILLUSTRATIVE DATA/);
  assert.match(mediaKitSource, /No live advertiser analytics product/);
  assert.match(mediaKitSource, /Request a quote/);
  assert.match(mediaKitSource, /Reasons YouNew may refuse or stop a placement/);
  assert.doesNotMatch(mediaKitSource, /€\s*\d/);
});

test("sponsored placements are globally disabled until real campaigns are configured", () => {
  const context = {
    surface: "city" as const,
    cityId: "city.amsterdam",
    provinceId: "province.north-holland",
    categorySlug: "integration",
    profileId: "expat" as const
  };
  assert.equal(sponsoredModule.SPONSORED_PLACEMENTS_ENABLED, false);
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible(activePlacement, context, { now: new Date("2026-09-15T12:00:00.000Z") }),
    false
  );
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible(activePlacement, context, {
      enabled: true,
      now: new Date("2026-09-15T12:00:00.000Z")
    }),
    true
  );
});

test("targeting, dates, status and emergency safety gate every placement", () => {
  const eligibleOptions = { enabled: true, now: new Date("2026-09-15T12:00:00.000Z") };
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible(activePlacement, {
      surface: "city",
      cityId: "city.rotterdam",
      provinceId: "province.north-holland",
      categorySlug: "integration",
      profileId: "expat"
    }, eligibleOptions),
    false
  );
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible(activePlacement, {
      surface: "emergency",
      cityId: "city.amsterdam",
      provinceId: "province.north-holland",
      categorySlug: "integration",
      profileId: "expat"
    }, eligibleOptions),
    false
  );
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible({ ...activePlacement, status: "paused" }, {
      surface: "city",
      cityId: "city.amsterdam",
      provinceId: "province.north-holland",
      categorySlug: "integration",
      profileId: "expat"
    }, eligibleOptions),
    false
  );
  assert.equal(
    sponsoredModule.isSponsoredPlacementEligible(activePlacement, {
      surface: "city",
      cityId: "city.amsterdam",
      provinceId: "province.north-holland",
      categorySlug: "integration",
      profileId: "expat"
    }, { enabled: true, now: new Date("2026-10-01T00:00:00.000Z") }),
    false
  );
});
