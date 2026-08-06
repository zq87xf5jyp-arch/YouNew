import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const [page, experience, header, footer, sitemap, homepage, globalCss] = await Promise.all([
  readFile(new URL("src/app/naruto/page.tsx", root), "utf8"),
  readFile(new URL("src/components/naruto-experience.tsx", root), "utf8"),
  readFile(new URL("src/components/site-header.tsx", root), "utf8"),
  readFile(new URL("src/components/site-footer.tsx", root), "utf8"),
  readFile(new URL("src/app/sitemap.ts", root), "utf8"),
  readFile(new URL("src/app/page.tsx", root), "utf8"),
  readFile(new URL("src/app/globals.css", root), "utf8")
]);

test("Naruto is a public, discoverable YouNew route", () => {
  assert.match(page, /metadataForPage\([\s\S]*"Ask Naruto"[\s\S]*"\/naruto"/);
  assert.match(header, /\["Naruto", "\/naruto"\]/);
  assert.match(footer, /href="\/naruto"/);
  assert.match(sitemap, /"\/naruto"/);
  assert.match(homepage, /href="\/naruto\/"/);
});

test("Naruto uses only the released static index and preserves source visibility", () => {
  assert.match(experience, /fetch\("\/data\/search-index\.json"/);
  assert.match(experience, /rankSearchDocuments\(documents, submittedQuery/);
  assert.match(experience, /numberedSteps/);
  assert.match(experience, /officialSourceUrls/);
  assert.match(experience, /target="_blank"/);
  assert.match(experience, /No useful published match yet/);
  assert.match(experience, /does not invent a route/);
  assert.match(experience, /call 112/);
  assert.match(experience, /Do not include identity numbers or medical details/);
  assert.match(experience, /checkedDateLabel\(primary\.document\.verifiedAt\)/);
});

test("Naruto phase one does not transmit questions to a model, account or analytics", () => {
  assert.doesNotMatch(experience, /openai|anthropic|gemini|supabase|fetch\("\/api\//i);
  assert.doesNotMatch(experience, /\btrack\(|localStorage|sessionStorage|navigator\.geolocation/i);
});

test("Naruto reflows its composer and answer surfaces for narrow screens", () => {
  assert.match(globalCss, /@media \(max-width:760px\)[\s\S]*?\.naruto-input-row \{ grid-template-columns:auto minmax\(0,1fr\); \}/);
  assert.match(globalCss, /\.naruto-input-row \.button \{ grid-column:1\/-1; width:100%; \}/);
  assert.match(globalCss, /\.naruto-sources ul,\.naruto-related>div \{ grid-template-columns:1fr; \}/);
  assert.match(globalCss, /@media \(max-width:480px\)[\s\S]*?\.naruto-page-content \{ padding-inline:14px; \}/);
});
