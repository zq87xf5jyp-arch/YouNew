import type { ContentEntityType, GuideAudienceProfile } from "../content/types";
import { canonicalCityId, resolveSearchLocation, selectedLocationContext } from "./geography.ts";
import { matchSearchIntents, taxonomyTopic } from "./taxonomy.ts";

export type SearchDocumentType = ContentEntityType | "category" | "municipality" | "province" | "page";
export type SearchLocationScope = "national" | "province" | "municipality" | "city" | "neighbourhood" | "organization" | "emergency" | "online-service";
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
  readonly municipalityId?: string | null;
  readonly locationScope?: SearchLocationScope;
  readonly country?: "NL";
  readonly categories: readonly string[];
  readonly intents?: readonly string[];
  readonly languages?: readonly ("en" | "nl" | "ru")[];
  readonly nationalFallback?: boolean;
  readonly scope?: SearchScope;
  readonly locationAliases?: readonly string[];
  readonly intentIds?: readonly string[];
  readonly officialSourceURLs?: readonly string[];
  readonly qualityScore?: number;
  readonly verifiedAt?: string | null;
  readonly officialSourceUrls?: readonly string[];
  readonly relatedOrganizationIds?: readonly string[];
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
  readonly matchedIntentIds?: readonly string[];
  readonly locationMatch?: "exact" | "province" | "national" | "none";
}

interface WeightedSearchField {
  readonly values: readonly string[];
  readonly weight: number;
}

const weightedFieldsByDocument = new WeakMap<SearchDocument, readonly WeightedSearchField[]>();

const legacyProfileCategories: Readonly<Record<GuideAudienceProfile, readonly string[]>> = {
  tourist: ["transport", "safety", "emergency", "shopping", "daily-life", "sim-telecom"],
  student: ["education", "language-learning", "housing", "transport", "work"],
  expat: ["documents", "government", "housing", "healthcare", "work", "banking", "taxes"],
  refugee: ["documents", "government", "housing", "healthcare", "education", "integration", "legal-help"],
  worker: ["work", "documents", "housing", "healthcare", "transport", "taxes", "municipal-services"],
  resident: ["government", "municipal-services", "housing", "healthcare", "family", "children", "daily-life"]
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
  void profile;
  return [...documents];
}

export function normalizeSearchText(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[’‘`´]/g, "'")
    .toLocaleLowerCase("und")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

function tokens(value: string): string[] {
  return [...new Set(normalizeSearchText(value).split(/\s+/).filter(Boolean))];
}

const queryStopWords = new Set([
  "a", "an", "and", "are", "can", "do", "does", "for", "get", "how", "i", "in", "is", "my", "need", "not", "of", "the", "to", "what", "where",
  "de", "een", "en", "heb", "het", "hoe", "ik", "in", "is", "nodig", "van", "waar",
  "в", "где", "для", "как", "мне", "мой", "нужно", "получить", "что"
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
  if (queryToken.length >= 6 && candidate.includes(queryToken)) return weight * 0.48;

  if (queryToken.length >= 4 && candidate.length >= 4) {
    const maximumDistance = queryToken.length >= 7 ? 2 : 1;
    if (queryToken[0] !== candidate[0]) return 0;
    const distance = boundedEditDistance(queryToken, candidate, maximumDistance);
    if (distance <= maximumDistance) return weight * (distance === 1 ? 0.5 : 0.34);
  }
  return 0;
}

function matchesExplicitLocation(
  document: SearchDocument,
  location: ReturnType<typeof selectedLocationContext>
): boolean {
  if (!location) return true;
  const scope = documentScope(document);
  if (scope === "national" || scope === "emergency" || scope === "online-service" || document.nationalFallback) return true;

  if (location.kind === "province") {
    const documentProvince = document.provinceId ?? (document.type === "province" ? document.slug : null);
    return documentProvince === location.provinceId;
  }

  const documentCity = canonicalCityId(
    document.municipalityId ?? document.cityId ?? (document.type === "municipality" || document.type === "city" ? document.slug : null)
  );
  if (documentCity === location.canonicalId) return true;
  return scope === "province" && Boolean(location.provinceId) && document.provinceId === location.provinceId;
}

function matchesHardFilters(
  document: SearchDocument,
  filters: SearchFilters,
  explicitLocation: ReturnType<typeof selectedLocationContext>
): boolean {
  if (filters.type && document.type !== filters.type) return false;
  if (filters.category && !document.categories.includes(filters.category)) return false;
  return matchesExplicitLocation(document, explicitLocation);
}

function documentScope(document: SearchDocument): SearchLocationScope {
  if (document.locationScope) return document.locationScope;
  if (document.scope === "provincial") return "province";
  if (document.scope === "municipal") return "municipality";
  if (document.scope) return document.scope;
  if (document.type === "municipality") return "municipality";
  if (document.type === "province") return "province";
  if (document.type === "organization") return "organization";
  if (document.cityId) return "city";
  if (document.provinceId) return "province";
  return "national";
}

function locationScore(
  document: SearchDocument,
  location: ReturnType<typeof selectedLocationContext>,
  fromExplicitFilter: boolean
): number {
  if (!location) return 0;
  const scope = documentScope(document);
  if (scope === "national" || scope === "emergency" || scope === "online-service" || document.nationalFallback) {
    return fromExplicitFilter ? 22 : 12;
  }

  if (location.kind === "province") {
    if (document.provinceId === location.provinceId) return 28;
    return fromExplicitFilter ? -48 : scope === "organization" ? -12 : -22;
  }

  const documentCity = canonicalCityId(document.municipalityId ?? document.cityId ?? (document.type === "municipality" ? document.slug : null));
  if (documentCity === location.canonicalId) return 36;
  if (location.provinceId && document.provinceId === location.provinceId) return 16;
  return fromExplicitFilter ? -64 : scope === "organization" ? -12 : -24;
}

function freshnessScore(value: string | null | undefined): number {
  if (!value) return 0;
  const timestamp = Date.parse(value);
  if (Number.isNaN(timestamp)) return 0;
  const ageDays = Math.max(0, (Date.now() - timestamp) / 86_400_000);
  if (ageDays <= 45) return 4;
  if (ageDays <= 180) return 2;
  return 0;
}

function qualityScore(document: SearchDocument): number {
  const value = document.qualityScore;
  return typeof value === "number" && Number.isFinite(value) ? Math.max(-5, Math.min(8, (value - 50) / 10)) : 0;
}

function usefulnessScore(document: SearchDocument): number {
  // A canonical category is a useful discovery surface, but a released guide is
  // the actionable answer users asked for. Keep this deliberately smaller than
  // an unmatched query token so a broad guide cannot displace a category that
  // is the only exact destination (for example, "student housing").
  const guideBoost = document.type === "guide" ? 10 : 0;
  const practicalBoost = document.contentDepth === "practical" ? 5 : 0;
  const sourceBoost = ((document.officialSourceUrls?.length ?? 0) + (document.officialSourceURLs?.length ?? 0)) > 0 ? 2 : 0;
  return guideBoost + practicalBoost + sourceBoost;
}

function weightedFields(document: SearchDocument): readonly WeightedSearchField[] {
  const cached = weightedFieldsByDocument.get(document);
  if (cached) return cached;
  const fields: readonly WeightedSearchField[] = [
    { values: tokens(document.title), weight: 28 },
    { values: [...(document.intents ?? []), ...(document.intentIds ?? [])].flatMap(tokens), weight: 25 },
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
    { values: tokens(document.summary), weight: 4 },
    { values: [...(document.officialSourceUrls ?? []), ...(document.officialSourceURLs ?? [])].flatMap(tokens), weight: 3 }
  ];
  weightedFieldsByDocument.set(document, fields);
  return fields;
}

export function rankSearchDocuments(
  documents: readonly SearchDocument[],
  query: string,
  options: SearchOptions = {}
): RankedSearchResult[] {
  const queryText = normalizeSearchText(query);
  const explicitLocation = selectedLocationContext(documents, options.filters?.cityId, options.filters?.provinceId);
  const inferredLocation = explicitLocation ? null : resolveSearchLocation(documents, queryText, normalizeSearchText);
  const location = explicitLocation ?? inferredLocation;
  const allQueryTokens = semanticQueryTokens(queryText);
  const nonLocationTokens = inferredLocation
    ? allQueryTokens.filter((token) => !inferredLocation.consumedTokens.includes(token))
    : allQueryTokens;
  const queryTokens = nonLocationTokens.length > 0 ? nonLocationTokens : allQueryTokens;
  const intentMatches = matchSearchIntents(queryText, normalizeSearchText);
  const limit = Math.max(1, Math.min(options.limit ?? 40, 200));
  const filters = options.filters ?? {};
  if (!queryText || queryTokens.length === 0) {
    return documents
      .filter((document) => matchesHardFilters(document, filters, explicitLocation))
      .sort(
        (left, right) =>
          locationScore(right, location, Boolean(explicitLocation)) - locationScore(left, location, Boolean(explicitLocation)) ||
          Number(searchDocumentMatchesProfile(right, options.preferredProfile)) -
            Number(searchDocumentMatchesProfile(left, options.preferredProfile)) ||
          left.title.localeCompare(right.title) || left.id.localeCompare(right.id)
      )
      .slice(0, limit)
      .map((document) => ({ document, score: 0, matchedTerms: [] }));
  }

  const results: RankedSearchResult[] = [];

  for (const document of documents) {
    if (!matchesHardFilters(document, filters, explicitLocation)) continue;

    const titleText = normalizeSearchText(document.title);
    const documentFields = weightedFields(document);

    const paddedTitle = ` ${titleText} `;
    const titleStartsWithPhrase = titleText.startsWith(`${queryText} `);
    const titleContainsPhrase = paddedTitle.includes(` ${queryText} `);
    const categoryLanding = document.type === "category";
    let score = titleText === queryText
      ? (categoryLanding ? 72 : 180)
      : titleStartsWithPhrase
        ? (categoryLanding ? 52 : 90)
        : titleContainsPhrase
          ? (categoryLanding ? 40 : 58)
          : 0;
    const matchedTerms: string[] = [];

    for (const queryToken of queryTokens) {
      let best = 0;
      for (const field of documentFields) {
        for (const candidate of field.values) best = Math.max(best, tokenScore(queryToken, candidate, field.weight));
      }
      if (best > 0) {
        score += best;
        matchedTerms.push(queryToken);
      } else {
        score -= 5;
      }
    }

    const documentIntents = new Set([...(document.intents ?? []), ...(document.intentIds ?? []), ...document.categories]);
    let intentScore = 0;
    for (const match of intentMatches) {
      if (documentIntents.has(match.intent)) {
        intentScore = Math.max(intentScore, match.exact ? 126 : 104);
        for (const token of semanticQueryTokens(match.alias)) if (!matchedTerms.includes(token)) matchedTerms.push(token);
      } else {
        const topic = taxonomyTopic(match.intent);
        if (topic?.relatedIntents.some((intent) => documentIntents.has(intent))) intentScore = Math.max(intentScore, 18);
      }
    }
    score += intentScore;

    const minimumCoverage = queryTokens.length <= 2 ? queryTokens.length : Math.ceil(queryTokens.length * 0.6);
    const intentMatched = intentScore >= 100;
    if (score > 0 && (matchedTerms.length >= minimumCoverage || intentMatched)) {
      const profileBoost = searchDocumentMatchesProfile(document, options.preferredProfile) ? 12 : 0;
      const geoBoost = locationScore(document, location, Boolean(explicitLocation));
      const verificationBoost = freshnessScore(document.verifiedAt);
      const contentQualityBoost = qualityScore(document);
      const answerUsefulnessBoost = usefulnessScore(document);
      const finalScore = Math.round((score + profileBoost + geoBoost + verificationBoost + contentQualityBoost + answerUsefulnessBoost) * 100) / 100;
      if (finalScore >= 12) {
        results.push({
          document,
          score: finalScore,
          matchedTerms: [...new Set(matchedTerms)]
        });
      }
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
