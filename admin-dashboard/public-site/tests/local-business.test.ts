import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const appRoot = new URL("../src/app/", import.meta.url);
const [landing, applyPage, form, application, edgeValidation, sitemap, homepage, footer, entityDetail] = await Promise.all([
  readFile(new URL("for-business/local/page.tsx", appRoot), "utf8"),
  readFile(new URL("for-business/local/apply/page.tsx", appRoot), "utf8"),
  readFile(new URL("../components/local-business-application-form.tsx", appRoot), "utf8"),
  readFile(new URL("../lib/business/application.ts", appRoot), "utf8"),
  readFile(new URL("../../../supabase/functions/submit-business-inquiry/validation.ts", appRoot), "utf8"),
  readFile(new URL("sitemap.ts", appRoot), "utf8"),
  readFile(new URL("page.tsx", appRoot), "utf8"),
  readFile(new URL("../components/site-footer.tsx", appRoot), "utf8"),
  readFile(new URL("../components/entity-detail.tsx", appRoot), "utf8")
]);

test("local-business acquisition has a discoverable canonical path", () => {
  for (const source of [sitemap, homepage, footer]) assert.match(source, /\/for-business\/local/);
  assert.match(landing, /Help newcomers find and understand your business\./);
  assert.match(landing, /Add or claim your business/);
  assert.match(applyPage, /Add or claim a business profile/);
});

test("the tier ladder is explicit about current and unavailable capabilities", () => {
  assert.match(landing, /Free/);
  assert.match(landing, /€0/);
  assert.match(landing, /Business/);
  assert.match(landing, /Premium/);
  assert.match(landing, /Planned · not for sale/);
  assert.match(landing, /Price not set/);
  assert.match(landing, /No campaign inventory, placement or reporting result is promised/);
  assert.doesNotMatch(landing, /guaranteed (?:traffic|leads|customers|revenue|ROI)/i);
});

test("the local-business form uses the protected inquiry contract and receipt-gated analytics", () => {
  assert.match(form, /offerInterest: "founding_partner_page"/);
  assert.match(form, /requestedPlacements: \["verified-organization-profile"\]/);
  assert.match(form, /sourcePage: "\/for-business\/local\/apply\/"/);
  assert.match(form, /track\(\{ name: "lead_start" \}\)/);
  assert.match(form, /const submission = await repository\.submit\(application\)[\s\S]+track\(\{ name: "lead_submit" \}\)/);
  assert.doesNotMatch(form, /track\([^\n]*(companyName|contactPerson|email|phone|description|kvkNumber)/);
  assert.match(application, /"\/for-business\/local\/apply\/"/);
  assert.match(edgeValidation, /"\/for-business\/local\/apply\/"/);
});

test("profile requests and legacy records use honest status language", () => {
  assert.match(form, /Review first, no automatic publication/);
  assert.match(form, /does not publish a profile, verify ownership, start a paid plan or create a contract/);
  assert.match(entityDetail, /<dt>Source checked<\/dt>/);
  assert.doesNotMatch(entityDetail, /<dt>Last verified<\/dt>/);
});
