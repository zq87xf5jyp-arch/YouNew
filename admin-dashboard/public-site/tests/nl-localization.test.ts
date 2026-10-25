import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const source = new URL("../src/", import.meta.url);
const routeFiles = [
  "app/nl/page.tsx", "app/nl/categorieen/page.tsx", "app/nl/categorieen/[slug]/page.tsx",
  "app/nl/zoeken/page.tsx", "app/nl/organisaties/page.tsx", "app/nl/organisaties/[slug]/page.tsx",
  "app/nl/voor-bedrijven/page.tsx", "app/nl/voor-bedrijven/lokaal/page.tsx", "app/nl/voor-bedrijven/aanmelden/page.tsx",
  "app/nl/stadsgidsen/[slug]/page.tsx"
];

test("Dutch key routes and locale-aware shell are present", async () => {
  await Promise.all(routeFiles.map((path) => access(new URL(path, source))));
  const [config, shell, header, footer] = await Promise.all([
    readFile(new URL("lib/i18n/config.ts", source), "utf8"),
    readFile(new URL("components/page-shell.tsx", source), "utf8"),
    readFile(new URL("components/site-header.tsx", source), "utf8"),
    readFile(new URL("components/site-footer.tsx", source), "utf8")
  ]);
  assert.match(config, /publishedWebLocales[^=]*= \["en", "nl"\]/);
  assert.match(shell, /locale\?: "en" \| "nl"/);
  assert.match(header, /Voor bedrijven/);
  assert.match(footer, /Praktische en controleerbare informatie/);
});

test("five bilingual city guides use explicit reviewed sources", async () => {
  const cityGuideModule = await import(new URL("content/city-guides.ts", source).href) as { cityGuides: Array<{ slug: string; verifiedAt: string; sourceUrl: string; title: { en: string; nl: string } }> };
  assert.equal(cityGuideModule.cityGuides.length, 5);
  assert.equal(new Set(cityGuideModule.cityGuides.map((guide) => guide.slug)).size, 5);
  for (const guide of cityGuideModule.cityGuides) {
    assert.equal(guide.verifiedAt, "2026-10-23");
    assert.match(guide.sourceUrl, /^https:\/\//);
    assert.ok(guide.title.en && guide.title.nl);
  }
});

test("Dutch Add/Claim keeps server validation, bot field and receipt-gated analytics", async () => {
  const [form, application, edge] = await Promise.all([
    readFile(new URL("components/nl-local-business-application-form.tsx", source), "utf8"),
    readFile(new URL("lib/business/application.ts", source), "utf8"),
    readFile(new URL("../supabase/functions/submit-business-inquiry/validation.ts", root), "utf8")
  ]);
  assert.match(form, /websiteConfirmation/);
  assert.match(form, /businessPremiumInterest/);
  assert.match(form, /Non-binding future Business\/Premium interest/);
  assert.match(form, /offerInterest: businessInterest \? "other" : "founding_partner_page"/);
  assert.match(form, /Deze functies zijn nog niet beschikbaar/);
  assert.match(form, /sourcePage: "\/nl\/voor-bedrijven\/aanmelden\/"/);
  assert.match(form, /await repository\.submit\(input\); setResult\(receipt\); track\(\{ name: "lead_submit" \}\)/);
  assert.match(application, /"\/nl\/voor-bedrijven\/aanmelden\/"/);
  assert.match(edge, /"\/nl\/voor-bedrijven\/aanmelden\/"/);
  assert.doesNotMatch(form, /track\([^\n]*(companyName|contactPerson|email|phone|description|kvkNumber)/);
});

test("hreflang, sitemap and generated-language post-processing cover Dutch pages", async () => {
  const [metadata, sitemap, build, langScript] = await Promise.all([
    readFile(new URL("lib/seo/metadata.ts", source), "utf8"),
    readFile(new URL("app/sitemap.ts", source), "utf8"),
    readFile(new URL("scripts/build.sh", root), "utf8"),
    readFile(new URL("scripts/set-static-document-language.mjs", root), "utf8")
  ]);
  assert.match(metadata, /nl: absolute\(localized\.nl\)/);
  assert.match(sitemap, /\/nl\/stadsgidsen/);
  assert.match(sitemap, /\/nl\/organisaties/);
  assert.match(build, /set-static-document-language\.mjs/);
  assert.match(langScript, /<html lang="nl"/);
});
