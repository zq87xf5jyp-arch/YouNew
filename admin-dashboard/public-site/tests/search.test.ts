import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import type { SearchDocument } from "../src/lib/search/rank";

const rankModule = (await import(new URL("../src/lib/search/rank.ts", import.meta.url).href)) as {
  boundedEditDistance: (left: string, right: string, maximum: number) => number;
  filterSearchDocumentsByProfile: (
    documents: readonly SearchDocument[],
    profile: unknown
  ) => SearchDocument[];
  searchDocumentMatchesProfile: (document: SearchDocument, profile: unknown) => boolean;
  normalizeSearchText: (value: string) => string;
  rankSearchDocuments: (
    documents: readonly SearchDocument[],
    query: string,
    options?: {
      filters?: { type?: SearchDocument["type"]; cityId?: string; provinceId?: string; category?: string };
      limit?: number;
      preferredProfile?: import("../src/lib/content/types").GuideAudienceProfile | null;
    }
  ) => Array<{ document: SearchDocument; score: number; matchedTerms: readonly string[]; matchedIntentIds: readonly string[]; locationMatch: "exact" | "province" | "national" | "none" }>;
};

const index = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
) as { schemaVersion: number; documents: SearchDocument[] };
const content = JSON.parse(
  await readFile(new URL("../src/generated/public-content.json", import.meta.url), "utf8")
) as { entities: Array<{ id: string; status: string }>; categories: Array<{ id: string }> };
const geography = JSON.parse(
  await readFile(new URL("../src/generated/netherlands-geography.json", import.meta.url), "utf8")
) as { municipalities: Array<{ code: string }>; provinces: Array<{ code: string }> };

test("search index v3 contains governed entities, full life taxonomy and official geography", () => {
  assert.equal(index.schemaVersion, 3);
  assert.ok(index.documents.length > 0);
  assert.ok(content.entities.every((entity) => entity.status === "published"));
  const entityTypes = new Set(["city", "guide", "organization", "place"]);
  const indexedEntityIds = index.documents.filter((document) => entityTypes.has(document.type)).map((document) => document.id).sort();
  assert.deepEqual(indexedEntityIds, content.entities.map((entity) => entity.id).sort());
  assert.deepEqual(index.documents.filter((document) => document.type === "category").map((document) => document.id).sort(), content.categories.map((category) => category.id).sort());
  assert.equal(index.documents.filter((document) => document.type === "municipality").length, geography.municipalities.length);
  assert.equal(index.documents.filter((document) => document.type === "province").length, geography.provinces.length);
  assert.equal(index.documents.filter((document) => document.type === "category" && document.scope === "national").length, 33);
});

test("official settlement names resolve to their municipality page", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Giethoorn");
  assert.ok(results.length > 0);
  assert.equal(results[0].document.type, "municipality");
  assert.equal(results[0].document.route, "/municipalities/steenwijkerland");
});

test("search normalizes accents and ranks exact titles first", () => {
  assert.equal(rankModule.normalizeSearchText("  Fryslân & Café  "), "fryslan cafe");
  const results = rankModule.rankSearchDocuments(index.documents, "Amsterdam");
  assert.ok(results.length > 0);
  assert.equal(results[0].document.title, "Amsterdam");
});

test("search tolerates a useful typo without returning the whole index", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Rijksmusem");
  assert.ok(results.length > 0);
  assert.match(results[0].document.title, /Rijksmuseum/i);
  assert.ok(results.length < index.documents.length);
});

test("search filters are applied before ranking", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "Amsterdam", {
    filters: { type: "guide", category: "government" }
  });
  assert.ok(results.length > 0);
  assert.ok(results.every(({ document }) => document.type === "guide" && document.categories.includes("government")));
});

test("search is deterministic and bounded", () => {
  const first = rankModule.rankSearchDocuments(index.documents, "housing Amsterdam", { limit: 3 });
  const second = rankModule.rankSearchDocuments([...index.documents].reverse(), "housing Amsterdam", { limit: 3 });
  assert.deepEqual(
    first.map(({ document }) => document.id),
    second.map(({ document }) => document.id)
  );
  assert.ok(first.length <= 3);
  assert.equal(rankModule.rankSearchDocuments(index.documents, "   ").length, 40);
  assert.equal(rankModule.boundedEditDistance("museum", "musem", 1), 1);
});

test("filters can browse published content without a text query", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "", {
    filters: { type: "place", provinceId: "noord-holland" },
    limit: 80
  });
  assert.ok(results.length > 0);
  assert.ok(results.every(({ document }) => document.type === "place" && document.provinceId === "noord-holland"));
});

test("practical-guide search fields participate in ranking", () => {
  const fixture: SearchDocument = {
    id: "guide.search-field-fixture",
    type: "guide",
    sourceKind: "knowledgeTopic",
    slug: "search-field-fixture",
    route: "/guides/search-field-fixture",
    title: "Verified procedural fixture",
    summary: "A test-only document for exercising the pure ranking function.",
    keywords: [],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    categories: ["government"],
    narrowCategory: "government",
    organization: null,
    audienceProfiles: ["expat"],
    numberedSteps: ["Activate the account with the official letter"],
    requiredDocuments: ["Valid passport"],
    checklist: ["Bring your identity document to the appointment"],
    tips: ["Keep the confirmation letter"],
    faqAnswers: ["Can I reschedule? Use the official appointment portal."],
    whenYouNeedIt: ["Use this process after moving to the Netherlands"],
    tags: ["registration workflow"],
    synonyms: ["digital identity"],
    officialOrganizationNames: ["Official test institution"],
    terminology: ["voorbeeldterm"],
    commonQuestions: ["Where is my activation letter?"]
  };

  for (const query of ["activation letter", "valid passport", "identity document appointment", "confirmation letter", "reschedule appointment", "after moving", "registration workflow", "digital identity", "test institution", "voorbeeldterm"]) {
    assert.equal(rankModule.rankSearchDocuments([fixture], query)[0]?.document.id, fixture.id, query);
  }
});

test("profile matching can personalize ranking without becoming a hard filter", () => {
  const base: SearchDocument = {
    id: "guide.profile-fixture",
    type: "guide",
    sourceKind: "knowledgeTopic",
    slug: "profile-fixture",
    route: "/guides/profile-fixture",
    title: "Profile fixture",
    summary: "Test-only profile filtering fixture.",
    keywords: [],
    city: null,
    cityId: null,
    province: null,
    provinceId: null,
    categories: ["government"],
    narrowCategory: "government",
    organization: null,
    audienceProfiles: ["student"]
  };
  const authored = { ...base, id: "guide.authored-student" };
  const legacy = { ...base, id: "guide.legacy-summary", audienceProfiles: [] };

  assert.deepEqual(rankModule.filterSearchDocumentsByProfile([authored, legacy], "expat").map((document) => document.id), [authored.id, legacy.id]);
  assert.deepEqual(rankModule.filterSearchDocumentsByProfile([authored, legacy], "student").map((document) => document.id), [authored.id, legacy.id]);
  assert.equal(rankModule.searchDocumentMatchesProfile(legacy, "not-a-profile"), false);
  assert.deepEqual(rankModule.filterSearchDocumentsByProfile([authored, legacy], "not-a-profile").map((document) => document.id), [authored.id, legacy.id]);
});

test("a preferred profile personalizes ranking without hiding exact published answers", () => {
  const results = rankModule.rankSearchDocuments(index.documents, "BSN", {
    preferredProfile: "tourist",
    limit: 5
  });

  assert.equal(results[0]?.document.id, "category.documents");
  assert.ok(
    results.every(({ matchedTerms }) => matchedTerms.includes("bsn")),
    "profile preference must not introduce unrelated results"
  );
});

test("requested quality queries find an honest released destination", () => {
  const expected = new Map<string, string>([
    ["How do I get a BSN?", "category.documents"],
    ["Register gemeente", "category.municipal-services"],
    ["Landlord does not repair", "category.housing"],
    ["Student housing", "category.housing"],
    ["Emergency", "page.emergency"]
  ]);
  for (const [query, expectedId] of expected) {
    const results = rankModule.rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.equal(results[0]?.document.id, expectedId, `${query}: ${results.map(({ document }) => document.id).join(", ")}`);
  }

  for (const [query, expectedId] of [
    ["Lost residence card", "category.documents"],
    ["DigiD", "category.documents"],
    ["Work contract", "category.work"],
    ["Need a doctor", "category.healthcare"],
    ["Health insurance", "category.healthcare"]
  ]) {
    assert.equal(rankModule.rankSearchDocuments(index.documents, query, { limit: 5 })[0]?.document.id, expectedId, query);
  }
});

test("critical city and profile combinations keep national answers visible", () => {
  const cases: Array<[string, string, import("../src/lib/content/types").GuideAudienceProfile | null, string]> = [
    ["rent", "den-haag", "worker", "category.housing"],
    ["housing rent", "den-haag", "worker", "category.housing"],
    ["work", "leiden", null, "category.work"],
    ["huisarts", "rotterdam", null, "category.healthcare"],
    ["Dutch school", "groningen", null, "category.education"],
    ["BSN", "eindhoven", null, "category.documents"],
    ["SIM card", "maastricht", null, "category.sim-telecom"],
    ["parking fine", "utrecht", null, "category.fines"]
  ];
  for (const [query, cityId, profile, expectedId] of cases) {
    const results = rankModule.rankSearchDocuments(index.documents, query, { filters: { cityId }, preferredProfile: profile, limit: 5 });
    assert.equal(results[0]?.document.id, expectedId, `${query} + ${cityId} + ${profile ?? "no profile"}`);
    assert.equal(results[0]?.locationMatch, "national");
  }
});

test("all supported profiles keep every critical answer visible", () => {
  const profiles: import("../src/lib/content/types").GuideAudienceProfile[] = ["tourist", "student", "expat", "refugee", "worker", "resident"];
  const cases = [
    ["rent", "den-haag"], ["work", "leiden"], ["huisarts", "rotterdam"], ["Dutch school", "groningen"],
    ["BSN", "eindhoven"], ["SIM card", "maastricht"], ["parking fine", "utrecht"]
  ];
  for (const profile of profiles) {
    for (const [query, cityId] of cases) {
      const results = rankModule.rankSearchDocuments(index.documents, query, { filters: { cityId }, preferredProfile: profile, limit: 5 });
      assert.ok(results.length > 0, `${query} + ${cityId} + ${profile}`);
      assert.ok(results.some((result) => result.locationMatch === "national" || result.locationMatch === "exact"));
    }
  }
});

test("national guidance survives every municipality and province filter", () => {
  for (const municipality of index.documents.filter((document) => document.type === "municipality")) {
    const results = rankModule.rankSearchDocuments(index.documents, "BSN", { filters: { cityId: municipality.cityId ?? undefined }, limit: 5 });
    assert.ok(results.some(({ document }) => document.id === "category.documents"), municipality.title);
  }
  for (const province of index.documents.filter((document) => document.type === "province")) {
    const results = rankModule.rankSearchDocuments(index.documents, "BSN", { filters: { provinceId: province.provinceId ?? undefined }, limit: 5 });
    assert.ok(results.some(({ document }) => document.id === "category.documents"), province.title);
  }
});

test("multilingual aliases work and short tokens do not match unrelated place-name substrings", () => {
  assert.equal(rankModule.rankSearchDocuments(index.documents, "аренда", { filters: { cityId: "den-haag" } })[0]?.document.id, "category.housing");
  assert.equal(rankModule.rankSearchDocuments(index.documents, "huurwoning", { filters: { cityId: "utrecht" } })[0]?.document.id, "category.housing");
  const rentResults = rankModule.rankSearchDocuments(index.documents, "rent", { limit: 20 });
  assert.equal(rentResults.some(({ document }) => /drenthe|terneuzen|nijmegen/i.test(`${document.id} ${document.title}`)), false);
});

test("every official municipality and province remains directly searchable", () => {
  for (const document of index.documents.filter((candidate) => candidate.type === "municipality" || candidate.type === "province")) {
    assert.equal(rankModule.rankSearchDocuments(index.documents, document.title, { filters: { type: document.type }, limit: 1 })[0]?.document.id, document.id, document.title);
  }
});

test("search UI suggests only queries with a released destination", async () => {
  const source = await readFile(new URL("../src/components/search-experience.tsx", import.meta.url), "utf8");
  assert.match(source, /placeholder="[^"]*Rent a home[^"]*Find a GP[^"]*"/);
  assert.match(source, /Profile boost/);
  assert.doesNotMatch(source, /filterSearchDocumentsByProfile/);
  assert.match(source, /submittedQuery \|\| hasActiveFilters \|\| showAllResults/);
  assert.match(source, /setShowAllResults\(!submittedQuery && !Object\.values\(next\)\.some\(Boolean\)\)/);
});
