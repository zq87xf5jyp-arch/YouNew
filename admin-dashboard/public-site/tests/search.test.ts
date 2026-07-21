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
    }
  ) => Array<{ document: SearchDocument; score: number; matchedTerms: readonly string[] }>;
};

const index = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
) as { schemaVersion: number; documents: SearchDocument[] };
const content = JSON.parse(
  await readFile(new URL("../src/generated/public-content.json", import.meta.url), "utf8")
) as { entities: Array<{ id: string; status: string }>; categories: Array<{ id: string }> };

test("search index v2 contains only published entities and derived public routes", () => {
  assert.equal(index.schemaVersion, 2);
  assert.ok(index.documents.length > 0);
  assert.ok(content.entities.every((entity) => entity.status === "published"));
  const entityTypes = new Set(["city", "guide", "organization", "place"]);
  const indexedEntityIds = index.documents.filter((document) => entityTypes.has(document.type)).map((document) => document.id).sort();
  assert.deepEqual(indexedEntityIds, content.entities.map((entity) => entity.id).sort());
  assert.deepEqual(index.documents.filter((document) => document.type === "category").map((document) => document.id).sort(), content.categories.map((category) => category.id).sort());
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

test("profile filtering prefers authored audiences and falls back only when they are absent", () => {
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

  assert.deepEqual(
    rankModule.filterSearchDocumentsByProfile([authored, legacy], "expat").map((document) => document.id),
    [legacy.id],
    "an authored student-only guide must not inherit the legacy government-to-expat fallback"
  );
  assert.deepEqual(
    rankModule.filterSearchDocumentsByProfile([authored, legacy], "student").map((document) => document.id),
    [authored.id],
    "the authored student audience must match while the legacy government summary uses its category fallback"
  );
  assert.equal(rankModule.searchDocumentMatchesProfile(legacy, "not-a-profile"), false);
  assert.deepEqual(rankModule.filterSearchDocumentsByProfile([authored, legacy], "not-a-profile"), []);
});

test("requested quality queries find an honest released destination or a documented gap", () => {
  const expected = new Map<string, string>([
    ["How do I get a BSN?", "government_service.first-registration-in-amsterdam"],
    ["Register gemeente", "government_service.first-registration-in-amsterdam"],
    ["Need a doctor", "category.healthcare"],
    ["Health insurance", "category.healthcare"],
    ["Landlord does not repair", "housing.woon"],
    ["Student housing", "category.housing"],
    ["Emergency", "page.emergency"]
  ]);
  for (const [query, expectedId] of expected) {
    const results = rankModule.rankSearchDocuments(index.documents, query, { limit: 5 });
    assert.equal(results[0]?.document.id, expectedId, `${query}: ${results.map(({ document }) => document.id).join(", ")}`);
  }

  for (const query of ["Lost residence card", "DigiD", "Work contract"]) {
    assert.deepEqual(
      rankModule.rankSearchDocuments(index.documents, query, { limit: 5 }),
      [],
      `${query} must not be redirected to unrelated released content while its practical guide remains draft`
    );
  }
});
