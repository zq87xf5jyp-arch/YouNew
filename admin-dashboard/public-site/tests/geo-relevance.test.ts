import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  normalizeSearchText,
  rankSearchDocuments,
  searchDocumentLocationMatch,
  type SearchDocument
} from "../src/lib/search/rank.ts";
import { canonicalCityId, resolveSearchLocation } from "../src/lib/search/geography.ts";

const index = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
) as { schemaVersion: number; documents: SearchDocument[] };

const cities = [
  { query: "Leiden", id: "leiden" },
  { query: "Amsterdam", id: "amsterdam" },
  { query: "Rotterdam", id: "rotterdam" },
  { query: "Den Haag", id: "s-gravenhage" },
  { query: "Utrecht", id: "utrecht" },
  { query: "Eindhoven", id: "eindhoven" },
  { query: "Groningen", id: "groningen" },
  { query: "Maastricht", id: "maastricht" },
  { query: "Tilburg", id: "tilburg" },
  { query: "Almere", id: "almere" },
  { query: "Haarlem", id: "haarlem" },
  { query: "Delft", id: "delft" }
] as const;

const intents = [
  { query: "BSN", expected: ["national.documents"] },
  { query: "gemeente registration", expected: ["national.documents"] },
  { query: "GP", expected: ["national.healthcare"] },
  { query: "hospital", expected: ["national.healthcare"] },
  { query: "housing", expected: ["national.housing"] },
  { query: "work", expected: ["national.work"] },
  { query: "language school", expected: ["national.education", "category.language-learning"] },
  { query: "debt help", expected: ["category.legal-help"] },
  { query: "legal help", expected: ["category.legal-help"] },
  { query: "veterinarian", expected: ["category.pets"] },
  { query: "DigiD", expected: ["national.documents"] },
  { query: "health insurance", expected: ["national.healthcare"] }
] as const;

const scenarios = cities.flatMap((city) => intents.map((intent) => ({ city, intent })));

test("geo release matrix covers at least 100 city-intent scenarios", () => {
  assert.equal(cities.length, 12);
  assert.equal(intents.length, 12);
  assert.equal(scenarios.length, 144);
});

test("explicit city recognition is at least 95 percent across the 144-scenario matrix", () => {
  let recognized = 0;
  for (const { city, intent } of scenarios) {
    const query = `${intent.query} in ${city.query}`;
    const location = resolveSearchLocation(index.documents, query, normalizeSearchText);
    if (location?.kind === "city" && location.canonicalId === city.id) recognized += 1;
  }
  assert.ok(recognized / scenarios.length >= 0.95, `${recognized}/${scenarios.length} recognized`);
});

test("top five contains no wrong-city organization and keeps a relevant destination", () => {
  for (const { city, intent } of scenarios) {
    const query = `${intent.query} in ${city.query}`;
    const location = resolveSearchLocation(index.documents, query, normalizeSearchText);
    assert.ok(location, query);
    const results = rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.ok(results.length > 0, `${query} returned zero results`);
    const hasExpectedNationalOrCategory = results.some(({ document }) => intent.expected.includes(document.id as never));
    const hasVerifiedLocalDestination = results.some(({ document, locationMatch }) =>
      (locationMatch === "exact" || locationMatch === "service-area") && document.type !== "municipality"
    );
    assert.ok(
      hasExpectedNationalOrCategory || hasVerifiedLocalDestination,
      `${query}: expected ${intent.expected.join(" or ")}; got ${results.map(({ document }) => document.id).join(", ")}`
    );
    for (const result of results) {
      assert.notEqual(searchDocumentLocationMatch(result.document, location), "none", `${query}: ${result.document.id}`);
      if (result.document.type === "organization") {
        assert.ok(
          result.locationMatch === "exact" || result.locationMatch === "service-area" || result.locationMatch === "online" || result.locationMatch === "national",
          `${query}: wrong-city organization ${result.document.id}`
        );
      }
    }
  }
});

test("query city overrides a conflicting saved city", () => {
  for (const city of cities) {
    const conflictingSavedCity = city.id === "amsterdam" ? "rotterdam" : "amsterdam";
    const query = `I need a GP in ${city.query}`;
    const results = rankSearchDocuments(index.documents, query, {
      filters: { cityId: conflictingSavedCity },
      limit: 5
    });
    assert.ok(results.length > 0, query);
    assert.ok(results.every(({ locationMatch }) => locationMatch !== "none"), query);
    assert.ok(
      results.some(({ document, locationMatch }) =>
        document.type === "municipality" &&
        canonicalCityId(document.municipalityId ?? document.cityId ?? document.slug) === city.id &&
        locationMatch === "exact"
      ),
      `${query}: ${results.map(({ document }) => document.id).join(", ")}`
    );
  }
});

test("Leiden aliases and a useful typo resolve deterministically", () => {
  for (const query of ["GP Leiden", "GP Leidne", "huisarts Лейден", "huisarts в Лейдене"]) {
    const location = resolveSearchLocation(index.documents, query, normalizeSearchText);
    assert.equal(location?.canonicalId, "leiden", query);
    const results = rankSearchDocuments(index.documents, query, { filters: { cityId: "amsterdam" }, limit: 5 });
    assert.equal(results[0]?.document.id, "national.healthcare", query);
    assert.ok(results.some(({ document }) => document.id === "municipality.gm0546"), query);
    assert.ok(results.every(({ document }) => canonicalCityId(document.cityId ?? document.municipalityId) !== "amsterdam"), query);
  }
});

test("unscoped queries never acquire a hidden Amsterdam default", () => {
  for (const query of ["GP", "gemeente registration", "housing", "work", "language school"]) {
    const results = rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.equal(resolveSearchLocation(index.documents, query, normalizeSearchText), null, query);
    assert.ok(
      results.every(({ document }) => !(document.type === "organization" && canonicalCityId(document.cityId ?? document.municipalityId) === "amsterdam")),
      `${query}: ${results.map(({ document }) => document.id).join(", ")}`
    );
  }
});

test("explicit service areas and remote services are admissible without weakening city isolation", () => {
  const fixture = (id: string, locationScope: SearchDocument["locationScope"], serviceAreaCityIds: string[] = []): SearchDocument => ({
    id,
    type: "organization",
    sourceKind: "knowledgeTopic",
    slug: id,
    route: `/organizations/${id}`,
    title: "GP support",
    summary: "Synthetic service coverage fixture.",
    keywords: ["GP", "huisarts"],
    city: "Amsterdam",
    cityId: "amsterdam",
    municipalityId: "amsterdam",
    province: "Noord-Holland",
    provinceId: "noord-holland",
    categories: ["healthcare"],
    narrowCategory: "healthcare",
    organization: "Synthetic fixture",
    audienceProfiles: [],
    locationScope,
    serviceAreaCityIds
  });
  const localService = fixture("service-area", "service-area", ["leiden"]);
  const wrongCity = fixture("wrong-city", "organization");
  const remote = fixture("remote", "remote");
  const national = fixture("national", "national");
  const results = rankSearchDocuments([localService, wrongCity, remote, national], "GP Leiden", { limit: 5 });
  assert.deepEqual(results.map(({ document }) => document.id).sort(), ["national", "remote", "service-area"]);
});

test("emergency remains available for a city and partner status cannot alter factual ranking", async () => {
  const results = rankSearchDocuments(index.documents, "emergency in Leiden", { limit: 5 });
  assert.ok(results.some(({ document }) => document.id === "page.emergency" || document.id === "category.emergency"));
  assert.ok(results.every(({ locationMatch }) => locationMatch !== "none"));
  const rankSource = await readFile(new URL("../src/lib/search/rank.ts", import.meta.url), "utf8");
  assert.doesNotMatch(rankSource, /sponsor(?:ed)?Status|partnerStatus|commercialStatus/);
});

test("search UI exposes geo reason, verification metadata and an honest local fallback", async () => {
  const source = await readFile(new URL("../src/components/search-experience.tsx", import.meta.url), "utf8");
  assert.match(source, /For \{effectiveLocation\.label\}, we do not yet have a verified local list\./);
  assert.match(source, /Confirmed service area includes/);
  assert.match(source, /National guidance for/);
  assert.match(source, /official source/);
  assert.match(source, /Verified/);
  assert.match(source, /aria-expanded=\{filtersOpen\}/);
  assert.match(source, /nationalGuideCategoryByIntent/);
  assert.doesNotMatch(source, /sourceKind === "nationalResourceGuide" && document\.intents\?\.includes\(primaryIntent\)/);
});

test("P0 national guides render the action panel before detailed content", async () => {
  const [guidePage, panel] = await Promise.all([
    readFile(new URL("../src/app/essentials/[slug]/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/national-guide-action-panel.tsx", import.meta.url), "utf8")
  ]);
  assert.ok(guidePage.indexOf("<NationalGuideActionPanel") < guidePage.indexOf("guide-depth-note"));
  assert.match(panel, /Choose your municipality/);
  assert.match(panel, /Next action/);
  assert.match(panel, /Official sources/);
  assert.match(panel, /Last checked/);
  assert.match(panel, /practical navigation, not individual legal, medical or tax advice/);
});

test("homepage uses the same explicit theme switch and a shorter hero without a redesign", async () => {
  const styles = await readFile(new URL("../src/app/globals.css", import.meta.url), "utf8");
  assert.match(styles, /\.product-vision-home \.theme-toggle \{ display:grid; \}/);
  assert.match(styles, /html\[data-theme="dark"\] \.product-vision-home/);
  assert.match(styles, /\.vision-hero-grid,\.vision-hero-media \.content-media \{ min-height:570px; \}/);
});
