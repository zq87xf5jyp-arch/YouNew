import type { ContentEntityType, GuideAudienceProfile } from "../content/types";

export type SearchDocumentType = ContentEntityType | "category" | "page";

export interface SearchDocument {
  readonly id: string;
  readonly type: SearchDocumentType;
  readonly sourceKind: string;
  readonly slug: string;
  readonly route: string;
  readonly title: string;
  readonly summary: string;
  readonly keywords: readonly string[];
  readonly city: string | null;
  readonly cityId: string | null;
  readonly province: string | null;
  readonly provinceId: string | null;
  readonly categories: readonly string[];
  readonly narrowCategory: string | null;
  readonly organization: string | null;
  readonly audienceProfiles: readonly GuideAudienceProfile[];
  readonly numberedSteps?: readonly string[];
  readonly requiredDocuments?: readonly string[];
  readonly checklist?: readonly string[];
  readonly tips?: readonly string[];
  readonly faqAnswers?: readonly string[];
  readonly whenYouNeedIt?: readonly string[];
  readonly tags?: readonly string[];
  readonly synonyms?: readonly string[];
  readonly officialOrganizationNames?: readonly string[];
  readonly terminology?: readonly string[];
  readonly commonQuestions?: readonly string[];
}

export interface SearchFilters {
  readonly type?: SearchDocumentType;
  readonly cityId?: string;
  readonly provinceId?: string;
  readonly category?: string;
}

export interface SearchOptions {
  readonly filters?: SearchFilters;
  readonly limit?: number;
}

export interface RankedSearchResult {
  readonly document: SearchDocument;
  readonly score: number;
  readonly matchedTerms: readonly string[];
}

const legacyProfileCategories: Readonly<Record<GuideAudienceProfile, readonly string[]>> = {
  tourist: ["things-to-do", "culture", "outdoors", "food-drink", "transport"],
  student: ["education", "housing", "transport"],
  expat: ["government", "housing", "healthcare", "transport"],
  refugee: ["government", "housing", "healthcare"],
  worker: ["government", "transport", "healthcare"],
  resident: ["government", "housing", "healthcare", "local-services"]
};

export function searchDocumentMatchesProfile(
  document: SearchDocument,
  profile: unknown
): boolean {
  if (typeof profile !== "string" || !Object.hasOwn(legacyProfileCategories, profile)) return false;
  const knownProfile = profile as GuideAudienceProfile;
  const authoredProfiles = document.audienceProfiles ?? [];
  if (authoredProfiles.length > 0) return authoredProfiles.includes(knownProfile);
  return document.categories.some((category) => legacyProfileCategories[knownProfile].includes(category));
}

export function filterSearchDocumentsByProfile(
  documents: readonly SearchDocument[],
  profile: unknown
): SearchDocument[] {
  if (profile === null || profile === "") return [...documents];
  return documents.filter((document) => searchDocumentMatchesProfile(document, profile));
}

export function normalizeSearchText(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

function tokens(value: string): string[] {
  return [...new Set(normalizeSearchText(value).split(/\s+/).filter(Boolean))];
}

const queryStopWords = new Set([
  "a", "an", "and", "are", "can", "do", "does", "for", "get", "how", "i", "in", "is", "my", "need", "not", "of", "the", "to", "what", "where"
]);

function semanticQueryTokens(value: string): string[] {
  const all = tokens(value);
  const meaningful = all.filter((token) => !queryStopWords.has(token));
  return meaningful.length > 0 ? meaningful : all;
}

export function boundedEditDistance(left: string, right: string, maximum: number): number {
  if (left === right) return 0;
  if (Math.abs(left.length - right.length) > maximum) return maximum + 1;

  let previous = Array.from({ length: right.length + 1 }, (_, index) => index);
  for (let leftIndex = 1; leftIndex <= left.length; leftIndex += 1) {
    const current = [leftIndex];
    let rowMinimum = current[0];
    for (let rightIndex = 1; rightIndex <= right.length; rightIndex += 1) {
      const substitution = previous[rightIndex - 1] + (left[leftIndex - 1] === right[rightIndex - 1] ? 0 : 1);
      const value = Math.min(previous[rightIndex] + 1, current[rightIndex - 1] + 1, substitution);
      current.push(value);
      rowMinimum = Math.min(rowMinimum, value);
    }
    if (rowMinimum > maximum) return maximum + 1;
    previous = current;
  }
  return previous[right.length];
}

function tokenScore(queryToken: string, candidate: string, weight: number): number {
  if (queryToken === candidate) return weight;
  if (candidate.startsWith(queryToken)) return weight * 0.72;
  if (queryToken.startsWith(candidate) && candidate.length / queryToken.length >= 0.8) return weight * 0.64;
  if (candidate.includes(queryToken)) return weight * 0.56;

  if (queryToken.length >= 4 && candidate.length >= 4) {
    const maximumDistance = queryToken.length >= 8 ? 2 : 1;
    const distance = boundedEditDistance(queryToken, candidate, maximumDistance);
    if (distance <= maximumDistance) return weight * (distance === 1 ? 0.5 : 0.34);
  }
  return 0;
}

function matchesFilters(document: SearchDocument, filters: SearchFilters): boolean {
  if (filters.type && document.type !== filters.type) return false;
  if (filters.cityId && document.cityId !== filters.cityId) return false;
  if (filters.provinceId && document.provinceId !== filters.provinceId) return false;
  if (filters.category && !document.categories.includes(filters.category)) return false;
  return true;
}

export function rankSearchDocuments(
  documents: readonly SearchDocument[],
  query: string,
  options: SearchOptions = {}
): RankedSearchResult[] {
  const queryText = normalizeSearchText(query);
  const queryTokens = semanticQueryTokens(queryText);
  const limit = Math.max(1, Math.min(options.limit ?? 40, 200));
  const filters = options.filters ?? {};
  if (!queryText || queryTokens.length === 0) {
    return documents
      .filter((document) => matchesFilters(document, filters))
      .sort(
        (left, right) =>
          left.title.localeCompare(right.title) || left.id.localeCompare(right.id)
      )
      .slice(0, limit)
      .map((document) => ({ document, score: 0, matchedTerms: [] }));
  }

  const results: RankedSearchResult[] = [];

  for (const document of documents) {
    if (!matchesFilters(document, filters)) continue;

    const titleText = normalizeSearchText(document.title);
    const weightedFields = [
      { values: tokens(document.title), weight: 28 },
      { values: (document.synonyms ?? []).flatMap(tokens), weight: 22 },
      { values: (document.terminology ?? []).flatMap(tokens), weight: 19 },
      { values: document.keywords.flatMap(tokens), weight: 18 },
      { values: (document.numberedSteps ?? []).flatMap(tokens), weight: 17 },
      { values: (document.officialOrganizationNames ?? []).flatMap(tokens), weight: 16 },
      { values: (document.requiredDocuments ?? []).flatMap(tokens), weight: 15 },
      { values: (document.checklist ?? []).flatMap(tokens), weight: 15 },
      { values: (document.faqAnswers ?? []).flatMap(tokens), weight: 14 },
      { values: (document.commonQuestions ?? []).flatMap(tokens), weight: 14 },
      { values: (document.whenYouNeedIt ?? []).flatMap(tokens), weight: 13 },
      { values: (document.tips ?? []).flatMap(tokens), weight: 12 },
      { values: (document.tags ?? []).flatMap(tokens), weight: 12 },
      { values: tokens(document.organization ?? ""), weight: 14 },
      { values: tokens(document.city ?? ""), weight: 12 },
      { values: tokens(document.province ?? ""), weight: 10 },
      { values: document.categories.flatMap(tokens), weight: 10 },
      { values: tokens(document.narrowCategory ?? ""), weight: 9 },
      { values: tokens(document.summary), weight: 4 }
    ];

    let score = titleText === queryText ? 180 : titleText.startsWith(queryText) ? 90 : titleText.includes(queryText) ? 58 : 0;
    const matchedTerms = [];

    for (const queryToken of queryTokens) {
      let best = 0;
      for (const field of weightedFields) {
        for (const candidate of field.values) best = Math.max(best, tokenScore(queryToken, candidate, field.weight));
      }
      if (best > 0) {
        score += best;
        matchedTerms.push(queryToken);
      } else {
        score -= 5;
      }
    }

    const minimumCoverage = queryTokens.length <= 2 ? queryTokens.length : Math.ceil(queryTokens.length * 0.6);
    if (score > 0 && matchedTerms.length >= minimumCoverage) {
      results.push({ document, score: Math.round(score * 100) / 100, matchedTerms });
    }
  }

  return results
    .sort(
      (left, right) =>
        right.score - left.score ||
        left.document.title.localeCompare(right.document.title) ||
        left.document.id.localeCompare(right.document.id)
    )
    .slice(0, limit);
}
