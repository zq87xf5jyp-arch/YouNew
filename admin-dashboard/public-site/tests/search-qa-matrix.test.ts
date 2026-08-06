import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import type { GuideAudienceProfile } from "../src/lib/content/types.ts";
import { rankSearchDocuments, type SearchDocument, type SearchOptions } from "../src/lib/search/rank.ts";

interface MatrixQuery {
  readonly value: string;
  readonly language: "en" | "nl" | "ru";
}

interface QueryGroup {
  readonly id: string;
  readonly acceptedCategorySlugs: readonly string[];
  readonly queries: readonly MatrixQuery[];
}

interface SearchQaMatrix {
  readonly schemaVersion: number;
  readonly requiredQueryGroups: readonly QueryGroup[];
  readonly typoCases: ReadonlyArray<{ query: string; acceptedCategorySlugs: readonly string[] }>;
  readonly cityAliasCases: ReadonlyArray<{ expectedDocumentId: string; variants: readonly string[] }>;
}

const index = JSON.parse(
  await readFile(new URL("../public/data/search-index.json", import.meta.url), "utf8")
) as { documents: SearchDocument[] };
const matrix = JSON.parse(
  await readFile(new URL("../src/data/search-qa-matrix.json", import.meta.url), "utf8")
) as SearchQaMatrix;

const municipalities = index.documents.filter((document) => document.type === "municipality");
const provinces = index.documents.filter((document) => document.type === "province");
const profiles: readonly GuideAudienceProfile[] = ["tourist", "student", "expat", "refugee", "worker", "resident"];

function languageCoverageQueries(group: QueryGroup): readonly MatrixQuery[] {
  return (["en", "nl", "ru"] as const).map((language) => {
    const query = group.queries.find((candidate) => candidate.language === language);
    assert.ok(query, `${group.id} has no ${language} coverage query`);
    return query;
  });
}

function assertUsefulResult(
  query: string,
  acceptedCategorySlugs: readonly string[],
  options: SearchOptions,
  context: string
): void {
  const results = rankSearchDocuments(index.documents, query, { ...options, limit: 5 });
  assert.ok(results.length > 0, `${context}: ${query} returned zero results`);
  assert.ok(
    results.some(({ document }) =>
      acceptedCategorySlugs.some((slug) => document.id === `category.${slug}` || document.categories.includes(slug))
    ),
    `${context}: ${query} returned ${results.map(({ document }) => document.id).join(", ")}`
  );
}

test("the saved search QA matrix covers every mandatory language and query group", () => {
  assert.equal(matrix.schemaVersion, 1);
  assert.deepEqual(matrix.requiredQueryGroups.map((group) => group.id), [
    "housing", "work", "healthcare", "documents", "education", "telecom", "rules-and-fines",
    "banking", "family-and-childcare", "pets", "taxes", "benefits", "transport", "immigration"
  ]);
  for (const group of matrix.requiredQueryGroups) {
    assert.deepEqual(new Set(group.queries.map((query) => query.language)), new Set(["en", "nl", "ru"]), group.id);
  }
});

test("every mandatory query has a useful unfiltered result", () => {
  for (const group of matrix.requiredQueryGroups) {
    for (const query of group.queries) assertUsefulResult(query.value, group.acceptedCategorySlugs, {}, group.id);
  }
});

test("every municipality keeps national guidance for each critical category and language", () => {
  for (const municipality of municipalities) {
    assert.ok(municipality.cityId, municipality.id);
    for (const group of matrix.requiredQueryGroups) {
      for (const query of languageCoverageQueries(group)) {
        assertUsefulResult(query.value, group.acceptedCategorySlugs, { filters: { cityId: municipality.cityId ?? undefined } }, municipality.title);
      }
    }
  }
});

test("every province keeps national guidance for each critical category and language", () => {
  for (const province of provinces) {
    assert.ok(province.provinceId, province.id);
    for (const group of matrix.requiredQueryGroups) {
      for (const query of languageCoverageQueries(group)) {
        assertUsefulResult(query.value, group.acceptedCategorySlugs, { filters: { provinceId: province.provinceId ?? undefined } }, province.title);
      }
    }
  }
});

test("every mandatory query survives representative city and province filters", () => {
  for (const group of matrix.requiredQueryGroups) {
    for (const query of group.queries) {
      assertUsefulResult(query.value, group.acceptedCategorySlugs, { filters: { cityId: "den-haag" } }, "city filter");
      assertUsefulResult(query.value, group.acceptedCategorySlugs, { filters: { provinceId: "zuid-holland" } }, "province filter");
    }
  }
});

test("profiles and a city filter never hide any mandatory answer", () => {
  for (const profile of profiles) {
    for (const group of matrix.requiredQueryGroups) {
      for (const query of group.queries) {
        assertUsefulResult(query.value, group.acceptedCategorySlugs, { filters: { cityId: "den-haag" }, preferredProfile: profile }, profile);
      }
    }
  }
});

test("controlled typo tolerance resolves every saved regression case", () => {
  for (const typo of matrix.typoCases) assertUsefulResult(typo.query, typo.acceptedCategorySlugs, {}, "typo");
});

test("official and common city aliases resolve to one municipality", () => {
  for (const aliasCase of matrix.cityAliasCases) {
    for (const variant of aliasCase.variants) {
      const result = rankSearchDocuments(index.documents, variant, { filters: { type: "municipality" }, limit: 1 });
      assert.equal(result[0]?.document.id, aliasCase.expectedDocumentId, variant);
    }
  }
});

test("canonical intent aliases outrank incidental entity titles", () => {
  assert.ok(
    ["category.housing", "national.housing"].includes(rankSearchDocuments(index.documents, "room", { limit: 1 })[0]?.document.id ?? "")
  );
  assert.ok(
    ["category.work", "national.work"].includes(rankSearchDocuments(index.documents, "contract", { limit: 1 })[0]?.document.id ?? "")
  );
  assert.ok(
    ["category.documents", "national.documents"].includes(rankSearchDocuments(index.documents, "registration", { limit: 1 })[0]?.document.id ?? "")
  );
});
