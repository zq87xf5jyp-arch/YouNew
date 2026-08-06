import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

type NationalGuide = {
  id: string;
  slug: string;
  title: string;
  summary: string;
  sections: Record<string, string | string[]>;
  usefulServices?: Array<{
    title: string;
    provider: string;
    url: string;
    checkedAt: string;
    purpose: string;
    kind: string;
    caveat?: string;
  }>;
  officialSources: Array<{ url: string; checkedAt: string }>;
};

const [nationalContent, homepage, guidePage, discoverPage, municipalityPage, updatesPage] = await Promise.all([
  readFile(new URL("../src/content/national-guides.json", import.meta.url), "utf8").then((value) => JSON.parse(value) as { guides: NationalGuide[] }),
  readFile(new URL("../src/app/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/app/guides/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/app/discover/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/app/municipalities/[slug]/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/app/updates/page.tsx", import.meta.url), "utf8")
]);

const expandedIds = [
  "national.utilities-moving",
  "national.consumer-rights",
  "national.debt-legal-help",
  "national.mental-health",
  "national.dental-care",
  "national.medicines",
  "national.pregnancy",
  "national.business-zzp",
  "national.student-housing"
] as const;

test("the public national guide catalogue contains 24 unique source-checked routes", () => {
  assert.equal(nationalContent.guides.length, 24);
  assert.equal(new Set(nationalContent.guides.map((guide) => guide.id)).size, 24);
  assert.equal(new Set(nationalContent.guides.map((guide) => guide.slug)).size, 24);

  for (const id of expandedIds) {
    const guide = nationalContent.guides.find((candidate) => candidate.id === id);
    assert.ok(guide, id);
    assert.ok(guide.title.length > 8, id);
    assert.ok(guide.summary.length > 40, id);
    assert.ok(Object.values(guide.sections).every((section) => Array.isArray(section) ? section.length > 0 : section.length > 0), id);
    assert.ok(guide.officialSources.length >= 2, id);
    assert.ok(guide.officialSources.every((source) => source.url.startsWith("https://") && source.checkedAt === "2026-08-06"), id);
  }
});

test("every national guide provides actionable, labelled and dated service links", () => {
  const allowedKinds = new Set(["public", "non-profit", "support", "directory"]);

  for (const guide of nationalContent.guides) {
    const services = guide.usefulServices ?? [];
    assert.ok(services.length >= 3, `${guide.id}: needs at least three useful services`);
    assert.equal(new Set(services.map((service) => service.url)).size, services.length, `${guide.id}: duplicate service URL`);
    assert.ok(services.every((service) => (
      service.title.length > 12
      && service.provider.length > 1
      && service.url.startsWith("https://")
      && /^\d{4}-\d{2}-\d{2}$/.test(service.checkedAt)
      && service.purpose.length > 30
      && allowedKinds.has(service.kind)
      && (!service.caveat || service.caveat.length > 20)
    )), `${guide.id}: incomplete service metadata`);
  }

  const work = nationalContent.guides.find((guide) => guide.id === "national.work");
  assert.ok(work?.usefulServices?.some((service) => /werk\.nl/.test(service.url)));
  assert.ok(work?.usefulServices?.some((service) => /eures/.test(service.url)));
  const studentHousing = nationalContent.guides.find((guide) => guide.id === "national.student-housing");
  assert.ok(studentHousing?.usefulServices?.some((service) => /room\.nl/.test(service.url)));
  assert.ok(studentHousing?.usefulServices?.some((service) => /rent-check-shared/.test(service.url)));

  const expectedCoverage: Record<string, RegExp[]> = {
    "national.housing": [/huurcommissie/, /juridischloket/],
    "national.documents": [/digid/, /mijn\.overheid/, /ind\.nl/],
    "national.healthcare": [/zorgkaartnederland/, /zorgverzekeringslijn/, /thuisarts/],
    "national.education": [/studyinnl/, /studielink/, /taalhuis/],
    "national.consumer-rights": [/consument\.acm/, /fraudehelpdesk/],
    "national.mental-health": [/113\.nl/, /mindhulplijn/],
    "national.medicines": [/apotheek\.nl/, /lareb/],
    "national.business-zzp": [/business\.gov\.nl/, /belastingdienst/]
  };
  for (const [id, patterns] of Object.entries(expectedCoverage)) {
    const guide = nationalContent.guides.find((candidate) => candidate.id === id);
    assert.ok(guide, id);
    const urls = guide.usefulServices?.map((service) => service.url).join(" ") ?? "";
    for (const pattern of patterns) assert.match(urls, pattern, `${id}: missing ${pattern}`);
  }
});

test("national guidance is reachable from home, Guides, Discover, Updates and every municipality", () => {
  assert.match(homepage, /href: "\/tasks\/housing\/"/);
  assert.match(homepage, /href: "\/tasks\/healthcare\/"/);
  assert.match(homepage, /href: "\/tasks\/work\/"/);
  assert.match(homepage, /href: "\/essentials\/utilities-and-moving-home\/"/);
  assert.match(guidePage, /NationalGuideDirectory/);
  assert.match(discoverPage, /NationalGuideDirectory/);
  for (const id of expandedIds) assert.match(updatesPage, new RegExp(id.replace(".", "\\.")));

  const starterBlock = municipalityPage.slice(
    municipalityPage.indexOf("const nationalStartingPoints"),
    municipalityPage.indexOf("export const dynamicParams")
  );
  assert.equal(starterBlock.match(/title:/g)?.length, 8);
  assert.match(municipalityPage, /Available in every municipality/);
  assert.match(municipalityPage, /national routes above are ready now/i);
});
