import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

type NationalGuide = {
  id: string;
  slug: string;
  title: string;
  summary: string;
  sections: Record<string, string | string[]>;
  usefulServices?: Array<{ url: string; checkedAt: string; purpose: string; kind: string }>;
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

test("work and student housing provide actionable, labelled service links", () => {
  for (const id of ["national.work", "national.student-housing"]) {
    const guide = nationalContent.guides.find((candidate) => candidate.id === id);
    assert.ok(guide, id);
    assert.ok((guide.usefulServices?.length ?? 0) >= 5, id);
    assert.ok(guide.usefulServices?.every((service) => service.url.startsWith("https://") && service.checkedAt === "2026-08-06" && service.purpose.length > 30), id);
  }
  const work = nationalContent.guides.find((guide) => guide.id === "national.work");
  assert.ok(work?.usefulServices?.some((service) => /werk\.nl/.test(service.url)));
  assert.ok(work?.usefulServices?.some((service) => /eures/.test(service.url)));
  const studentHousing = nationalContent.guides.find((guide) => guide.id === "national.student-housing");
  assert.ok(studentHousing?.usefulServices?.some((service) => /room\.nl/.test(service.url)));
  assert.ok(studentHousing?.usefulServices?.some((service) => /rent-check-shared/.test(service.url)));
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
