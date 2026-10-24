import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const appRoot = new URL("../src/app/", import.meta.url);
const [forBusiness, pilot, demoReport, partners, apply, success, form, sitemap, header, footer] = await Promise.all([
  readFile(new URL("for-business/page.tsx", appRoot), "utf8"),
  readFile(new URL("for-business/pilot/page.tsx", appRoot), "utf8"),
  readFile(new URL("for-business/demo-report/page.tsx", appRoot), "utf8"),
  readFile(new URL("partners/page.tsx", appRoot), "utf8"),
  readFile(new URL("partners/apply/page.tsx", appRoot), "utf8"),
  readFile(new URL("partners/apply/success/page.tsx", appRoot), "utf8"),
  readFile(new URL("../components/pilot-request-form.tsx", appRoot), "utf8"),
  readFile(new URL("sitemap.ts", appRoot), "utf8"),
  readFile(new URL("../components/site-header.tsx", appRoot), "utf8"),
  readFile(new URL("../components/site-footer.tsx", appRoot), "utf8")
]);
const legacyPages = await Promise.all([
  "business/page.tsx",
  "business/workspace/page.tsx",
  "business/pricing/page.tsx",
  "business/media-kit/page.tsx",
  "business/advertise/page.tsx",
  "business/partners/page.tsx",
  "business/apply/page.tsx"
].map((path) => readFile(new URL(path, appRoot), "utf8")));

test("the canonical business page routes local businesses and employers without merging their offers", () => {
  assert.match(forBusiness, /For local businesses, employers and relocation teams/);
  assert.match(forBusiness, /Build a useful, trusted presence for newcomers\./);
  assert.match(forBusiness, /Add or claim a business/);
  assert.match(forBusiness, /Explore employee pilot/);
  assert.match(forBusiness, /Free reviewed request · add or claim/);
  assert.match(forBusiness, /90-day pilot · €1,500 excl\. VAT/);
  assert.match(forBusiness, /Commercial activity never buys official status or organic ranking\./);
});

test("the pilot page fixes the approved scope and honest founding price", () => {
  assert.match(pilot, /A 90-day onboarding pilot built around real employee questions\./);
  assert.match(pilot, /Launch a focused onboarding hub with 10 verified practical routes, one selected region and consent-based usage reporting\./);
  assert.match(pilot, /Founding pilot — €1,500 excl\. VAT/);
  assert.match(pilot, /Available for the first three accepted pilots\. Final scope is confirmed before contract\./);
  assert.match(pilot, />Request pilot\s/);
  assert.match(pilot, /90-day content-maintenance period/);
  assert.match(pilot, /manual invoice/i);
  assert.doesNotMatch(pilot, /countdown|limited time|existing clients|guaranteed outcomes|guaranteed ROI/i);
});

test("the sample report is visibly illustrative and contains no invented customer proof", () => {
  assert.match(demoReport, /Sample report/);
  assert.match(demoReport, /illustrative/i);
  assert.match(demoReport, /synthetic/i);
  assert.match(demoReport, /not a customer result/i);
  assert.match(demoReport, /Official-source verification/);
});

test("partner and application routes use the approved disclosure and state copy", () => {
  assert.match(partners, /Useful partners, clearly identified\./);
  assert.match(partners, /Paid placement never changes YouNew’s factual guidance, emergency information or editorial conclusions\. Partnerships and sponsored content are always labelled\./);
  assert.match(apply, /Tell us what your team needs\./);
  assert.match(apply, /We will review the request and prepare a scoped pilot proposal\. Submitting this form does not create a contract\./);
  assert.match(form, /Send pilot request/);
  assert.match(form, /We couldn’t send your request\./);
  assert.match(form, /Your request was not completed\. Please check the fields and try again\./);
  assert.match(success, /Request received\./);
  assert.match(success, /We will review your request and reply using the contact details you provided\./);
});

test("the pilot form records offer, role, canonical source and receipt-gated analytics", () => {
  assert.match(form, /offerInterest:\s*"onboarding_pilot"/);
  assert.match(form, /contactRole:/);
  assert.match(form, /sourcePage:\s*currentUrl\.pathname/);
  assert.match(form, /const submission = await repository\.submit\(application\)[\s\S]+track\(\{ name: "lead_submit" \}\)[\s\S]+track\(\{ name: "pilot_request" \}\)[\s\S]+window\.location\.assign\("\/partners\/apply\/success\/"\)/);
  assert.match(form, /consent-based usage analytics/i);
  assert.doesNotMatch(form, /checkout|card number|payment details/i);
});

test("navigation and sitemap expose only the approved canonical commercial routes", () => {
  const navigation = `${sitemap}\n${header}\n${footer}`;
  for (const route of [
    "/for-business",
    "/for-business/local",
    "/for-business/pilot",
    "/for-business/demo-report",
    "/partners",
    "/partners/apply"
  ]) assert.match(navigation, new RegExp(route.replaceAll("/", "\\/")));
  assert.match(success, /\/partners\/apply\/success/);
  assert.doesNotMatch(sitemap, /"\/business(?:\/|"|,)/);
});

test("transactional and worker-redirected commercial pages are not indexable", () => {
  assert.match(success, /\{ noIndex: true, follow: false \}/);
  for (const legacyPage of legacyPages) {
    assert.match(legacyPage, /\{ noIndex: true, follow: true \}/);
  }
});
