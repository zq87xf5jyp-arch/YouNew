import type { ContentEntityType, GuideAudienceProfile } from "../content/types";

export type SearchDocumentType = ContentEntityType | "category" | "municipality" | "province" | "page";
export type SearchScope = "national" | "provincial" | "municipal" | "city" | "neighbourhood" | "organization" | "online-service" | "emergency";

export interface SearchDocument {
  readonly id: string;
  readonly type: SearchDocumentType;
  readonly sourceKind: string;
  readonly slug: string;
  readonly route: string;
  readonly title: string;
  readonly summary: string;
  readonly contentDepth?: "summary" | "practical";
  readonly keywords: readonly string[];
  readonly city: string | null;
  readonly cityId: string | null;
  readonly province: string | null;
  readonly provinceId: string | null;
  readonly scope?: SearchScope;
  readonly locationAliases?: readonly string[];
  readonly languages?: readonly string[];
  readonly intentIds?: readonly string[];
  readonly officialSourceURLs?: readonly string[];
  readonly qualityScore?: number;
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
  readonly preferredProfile?: GuideAudienceProfile | null;
}

export interface RankedSearchResult {
  readonly document: SearchDocument;
  readonly score: number;
  readonly matchedTerms: readonly string[];
  readonly matchedIntentIds: readonly string[];
  readonly locationMatch: "exact" | "province" | "national" | "none";
}

interface WeightedSearchField {
  readonly values: readonly string[];
  readonly phrases: readonly string[];
  readonly weight: number;
}

const weightedFieldsByDocument = new WeakMap<SearchDocument, readonly WeightedSearchField[]>();
const locationAliasesByDocument = new WeakMap<SearchDocument, ReadonlySet<string>>();

const legacyProfileCategories: Readonly<Record<GuideAudienceProfile, readonly string[]>> = {
  tourist: ["transport", "safety", "emergency", "shopping", "daily-life", "sim-telecom"],
  student: ["education", "language-learning", "housing", "transport", "work"],
  expat: ["documents", "government", "housing", "healthcare", "work", "banking", "taxes"],
  refugee: ["documents", "government", "housing", "healthcare", "education", "integration", "legal-help"],
  worker: ["work", "documents", "housing", "healthcare", "transport", "taxes", "municipal-services"],
  resident: ["government", "municipal-services", "housing", "healthcare", "family", "children", "daily-life"]
};

export function searchDocumentMatchesProfile(document: SearchDocument, profile: unknown): boolean {
  if (typeof profile !== "string" || !Object.hasOwn(legacyProfileCategories, profile)) return false;
  const knownProfile = profile as GuideAudienceProfile;
  const authoredProfiles = document.audienceProfiles ?? [];
  if (authoredProfiles.length > 0) return authoredProfiles.includes(knownProfile);
  return document.categories.some((category) => legacyProfileCategories[knownProfile].includes(category));
}

/** @deprecated Profiles personalize ranking; they must never hide otherwise useful results. */
export function filterSearchDocumentsByProfile(documents: readonly SearchDocument[], profile: unknown): SearchDocument[] {
  void profile;
  return [...documents];
}

export function normalizeSearchText(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("und")
    .replace(/[’‘`´]/g, "'")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

function tokens(value: string): string[] {
  return [...new Set(normalizeSearchText(value).split(/\s+/u).filter(Boolean))];
}

function normalizedPhrases(values: readonly string[]): string[] {
  return values.map(normalizeSearchText).filter(Boolean);
}

const queryStopWords = new Set([
  "a", "an", "and", "are", "can", "do", "does", "for", "get", "how", "i", "in", "is", "my", "need", "of", "the", "to", "what", "where",
  "de", "een", "en", "hoe", "ik", "in", "is", "met", "naar", "of", "voor", "waar",
  "в", "где", "для", "как", "мне", "на", "нужен", "нужно", "и"
]);

function semanticQueryTokens(value: string, filters: SearchFilters): string[] {
  const selectedLocationTokens = new Set([
    ...tokens(filters.cityId ?? ""),
    ...tokens(filters.provinceId ?? "")
  ]);
  const all = tokens(value).filter((token) => !selectedLocationTokens.has(token));
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
  if (queryToken.length >= 3 && candidate.startsWith(queryToken)) return weight * 0.72;
  if (candidate.length >= 3 && queryToken.startsWith(candidate) && candidate.length / queryToken.length >= 0.8) return weight * 0.64;

  if (queryToken.length >= 5 && candidate.length >= 5) {
    const maximumDistance = queryToken.length >= 8 ? 2 : 1;
    const distance = boundedEditDistance(queryToken, candidate, maximumDistance);
    if (distance <= maximumDistance) return weight * (distance === 1 ? 0.5 : 0.34);
  }
  return 0;
}

function normalizedPhraseMatch(normalizedValue: string, normalizedQuery: string): boolean {
  const haystack = ` ${normalizedValue} `;
  const needle = ` ${normalizedQuery} `;
  return needle.trim().length > 0 && haystack.includes(needle);
}

function phraseScore(normalizedValues: readonly string[], query: string, weight: number): number {
  return normalizedValues.reduce((best, normalizedValue) => {
    if (normalizedValue === query) return Math.max(best, weight * 3.2);
    if (normalizedPhraseMatch(normalizedValue, query)) return Math.max(best, weight * 1.6);
    return best;
  }, 0);
}

function inferredScope(document: SearchDocument): SearchScope {
  return document.scope ?? (document.cityId ? "municipal" : document.provinceId ? "provincial" : "national");
}

function locationAliases(document: SearchDocument): ReadonlySet<string> {
  const cached = locationAliasesByDocument.get(document);
  if (cached) return cached;
  const aliases = new Set([
    normalizeSearchText(document.cityId ?? ""),
    normalizeSearchText(document.city ?? ""),
    ...(document.locationAliases ?? []).map(normalizeSearchText)
  ].filter(Boolean));
  locationAliasesByDocument.set(document, aliases);
  return aliases;
}

function weightedFields(document: SearchDocument): readonly WeightedSearchField[] {
  const cached = weightedFieldsByDocument.get(document);
  if (cached) return cached;

  const fields: readonly WeightedSearchField[] = [
    { values: tokens(document.title), phrases: normalizedPhrases([document.title]), weight: 30 },
    // A centralized taxonomy alias represents a canonical user intent. For a
    // category hub it must outrank an incidental title match (for example,
    // `room` should lead to Housing, not a venue named “The White Room”).
    { values: (document.synonyms ?? []).flatMap(tokens), phrases: normalizedPhrases(document.synonyms ?? []), weight: document.type === "category" ? 36 : 24 },
    { values: (document.terminology ?? []).flatMap(tokens), phrases: normalizedPhrases(document.terminology ?? []), weight: 20 },
    { values: document.keywords.flatMap(tokens), phrases: normalizedPhrases(document.keywords), weight: 18 },
    { values: (document.commonQuestions ?? []).flatMap(tokens), phrases: normalizedPhrases(document.commonQuestions ?? []), weight: 17 },
    { values: (document.numberedSteps ?? []).flatMap(tokens), phrases: normalizedPhrases(document.numberedSteps ?? []), weight: 15 },
    { values: (document.requiredDocuments ?? []).flatMap(tokens), phrases: normalizedPhrases(document.requiredDocuments ?? []), weight: 15 },
    { values: (document.checklist ?? []).flatMap(tokens), phrases: normalizedPhrases(document.checklist ?? []), weight: 15 },
    { values: (document.faqAnswers ?? []).flatMap(tokens), phrases: normalizedPhrases(document.faqAnswers ?? []), weight: 14 },
    { values: (document.whenYouNeedIt ?? []).flatMap(tokens), phrases: normalizedPhrases(document.whenYouNeedIt ?? []), weight: 13 },
    { values: (document.tips ?? []).flatMap(tokens), phrases: normalizedPhrases(document.tips ?? []), weight: 12 },
    { values: (document.officialOrganizationNames ?? []).flatMap(tokens), phrases: normalizedPhrases(document.officialOrganizationNames ?? []), weight: 14 },
    { values: (document.tags ?? []).flatMap(tokens), phrases: normalizedPhrases(document.tags ?? []), weight: 12 },
    { values: document.categories.flatMap(tokens), phrases: normalizedPhrases(document.categories), weight: 11 },
    { values: tokens(document.organization ?? ""), phrases: normalizedPhrases([document.organization ?? ""]), weight: 10 },
    { values: tokens(document.summary), phrases: normalizedPhrases([document.summary]), weight: 5 }
  ];
  weightedFieldsByDocument.set(document, fields);
  return fields;
}

function locationMatch(document: SearchDocument, filters: SearchFilters): RankedSearchResult["locationMatch"] | null {
  const scope = inferredScope(document);
  if (filters.cityId) {
    const selected = normalizeSearchText(filters.cityId);
    if (locationAliases(document).has(selected)) return "exact";
    if (scope === "national" || scope === "online-service" || scope === "emergency") return "national";
    return null;
  }
  if (filters.provinceId) {
    if (normalizeSearchText(document.provinceId ?? "") === normalizeSearchText(filters.provinceId)) return "province";
    if (scope === "national" || scope === "online-service" || scope === "emergency") return "national";
    return null;
  }
  return "none";
}

function matchesNonLocationFilters(document: SearchDocument, filters: SearchFilters): boolean {
  if (filters.type && document.type !== filters.type) return false;
  if (filters.category && !document.categories.includes(filters.category)) return false;
  return true;
}

function browseScore(document: SearchDocument, options: SearchOptions, match: RankedSearchResult["locationMatch"]): number {
  return (searchDocumentMatchesProfile(document, options.preferredProfile) ? 10 : 0)
    // The dedicated emergency route contains the immediate-action contract and
    // must stay ahead of the broader taxonomy hub for an exact emergency query.
    + (document.id === "page.emergency" ? 48 : 0)
    + (match === "exact" ? 16 : match === "province" ? 11 : match === "national" ? 4 : 0)
    + Math.max(0, Math.min(document.qualityScore ?? 0.5, 1)) * 6;
}

export function rankSearchDocuments(documents: readonly SearchDocument[], query: string, options: SearchOptions = {}): RankedSearchResult[] {
  const queryText = normalizeSearchText(query);
  const limit = Math.max(1, Math.min(options.limit ?? 40, 200));
  const filters = options.filters ?? {};
  const queryTokens = semanticQueryTokens(queryText, filters);
  const candidates = documents.flatMap((document) => {
    if (!matchesNonLocationFilters(document, filters)) return [];
    const match = locationMatch(document, filters);
    return match ? [{ document, match }] : [];
  });

  if (!queryText || queryTokens.length === 0) {
    return candidates
      .map(({ document, match }) => ({
        document,
        score: browseScore(document, options, match),
        matchedTerms: [] as string[],
        matchedIntentIds: [] as string[],
        locationMatch: match
      }))
      .sort((left, right) => right.score - left.score || left.document.title.localeCompare(right.document.title) || left.document.id.localeCompare(right.document.id))
      .slice(0, limit);
  }

  const results: RankedSearchResult[] = [];

  for (const { document, match } of candidates) {
    const documentFields = weightedFields(document);

    let score = documentFields.reduce(
      (best, field) => Math.max(best, phraseScore(field.phrases, queryText, field.weight)),
      0
    );
    const matchedTerms: string[] = [];

    for (const queryToken of queryTokens) {
      let best = 0;
      for (const field of documentFields) {
        for (const candidate of field.values) best = Math.max(best, tokenScore(queryToken, candidate, field.weight));
      }
      if (best > 0) {
        score += best;
        matchedTerms.push(queryToken);
      }
    }

    const minimumCoverage = queryTokens.length <= 2 ? queryTokens.length : Math.ceil(queryTokens.length * 0.6);
    if (score > 0 && matchedTerms.length >= minimumCoverage) {
      const matchedIntentIds = document.intentIds ?? [];
      const total = score + browseScore(document, options, match) + (matchedIntentIds.length > 0 ? 3 : 0);
      results.push({ document, score: Math.round(total * 100) / 100, matchedTerms, matchedIntentIds, locationMatch: match });
    }
  }

  return results
    .sort((left, right) => right.score - left.score || left.document.title.localeCompare(right.document.title) || left.document.id.localeCompare(right.document.id))
    .slice(0, limit);
}
