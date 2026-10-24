import type { SearchDocument } from "./rank";

export interface SearchLocationContext {
  readonly kind: "city" | "province";
  readonly canonicalId: string;
  readonly provinceId: string | null;
  readonly label: string;
  readonly matchedAlias: string;
  readonly consumedTokens: readonly string[];
  readonly matchKind: "exact" | "fuzzy" | "selected";
}

const cityIdAliases: Readonly<Record<string, string>> = {
  "den-haag": "s-gravenhage",
  "denhaag": "s-gravenhage",
  "the-hague": "s-gravenhage",
  "s-gravenhage": "s-gravenhage",
  "sgravenhage": "s-gravenhage",
  "den-bosch": "s-hertogenbosch",
  "denbosch": "s-hertogenbosch",
  "s-hertogenbosch": "s-hertogenbosch",
  "shertogenbosch": "s-hertogenbosch"
};

const preferredCityLabels: Readonly<Record<string, string>> = {
  "s-gravenhage": "Den Haag",
  "s-hertogenbosch": "Den Bosch"
};

const fixedAliases: readonly {
  readonly aliases: readonly string[];
  readonly canonicalId: string;
  readonly provinceId: string;
  readonly label: string;
}[] = [
  {
    canonicalId: "s-gravenhage",
    provinceId: "zuid-holland",
    label: "Den Haag",
    aliases: ["Den Haag", "DenHaag", "The Hague", "'s-Gravenhage", "’s-Gravenhage", "s Gravenhage", "s-Gravenhage", "Гаага", "Gaaga"]
  },
  {
    canonicalId: "s-hertogenbosch",
    provinceId: "noord-brabant",
    label: "Den Bosch",
    aliases: ["Den Bosch", "DenBosch", "'s-Hertogenbosch", "’s-Hertogenbosch", "s Hertogenbosch", "s-Hertogenbosch", "Хертогенбос"]
  },
  { canonicalId: "amsterdam", provinceId: "noord-holland", label: "Amsterdam", aliases: ["Amsterdam", "Амстердам"] },
  { canonicalId: "rotterdam", provinceId: "zuid-holland", label: "Rotterdam", aliases: ["Rotterdam", "Роттердам"] },
  { canonicalId: "utrecht", provinceId: "utrecht", label: "Utrecht", aliases: ["Utrecht", "Утрехт"] },
  { canonicalId: "eindhoven", provinceId: "noord-brabant", label: "Eindhoven", aliases: ["Eindhoven", "Эйндховен"] },
  { canonicalId: "groningen", provinceId: "groningen", label: "Groningen", aliases: ["Groningen", "Гронинген"] },
  { canonicalId: "maastricht", provinceId: "limburg", label: "Maastricht", aliases: ["Maastricht", "Маастрихт"] },
  { canonicalId: "leiden", provinceId: "zuid-holland", label: "Leiden", aliases: ["Leiden", "Лейден"] },
  { canonicalId: "tilburg", provinceId: "noord-brabant", label: "Tilburg", aliases: ["Tilburg", "Тилбург"] },
  { canonicalId: "almere", provinceId: "flevoland", label: "Almere", aliases: ["Almere", "Алмере"] },
  { canonicalId: "haarlem", provinceId: "noord-holland", label: "Haarlem", aliases: ["Haarlem", "Харлем"] },
  { canonicalId: "delft", provinceId: "zuid-holland", label: "Delft", aliases: ["Delft", "Делфт"] }
];

export function canonicalCityId(value: string | null | undefined): string | null {
  if (!value) return null;
  const slug = value.trim().toLocaleLowerCase("en").replace(/^['’]/, "").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  return cityIdAliases[slug] ?? slug;
}

export function cityDisplayName(canonicalId: string, fallback?: string): string {
  return preferredCityLabels[canonicalCityId(canonicalId) ?? canonicalId] ?? fallback ?? canonicalId.replaceAll("-", " ");
}

function boundedEditDistance(left: string, right: string, maximum: number): number {
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

function documentAliases(document: SearchDocument, normalize: (value: string) => string): string[] {
  const values = [document.title, document.slug, ...(document.locationAliases ?? []), ...(document.synonyms ?? []), ...document.keywords];
  return [...new Set(values
    .map(normalize)
    .filter((value) => value.length >= 2 && value.length <= 64 && value.split(" ").length <= 5))];
}

type LocationAliasEntry = Readonly<{
  alias: string;
  kind: "city" | "province";
  canonicalId: string;
  provinceId: string | null;
  label: string;
  allowFuzzy: boolean;
}>;

type LocationAliasIndex = Readonly<{
  entries: readonly LocationAliasEntry[];
  fuzzyByFirstCharacter: ReadonlyMap<string, readonly LocationAliasEntry[]>;
}>;

const locationAliasIndexCache = new WeakMap<readonly SearchDocument[], LocationAliasIndex>();

function locationAliasIndex(documents: readonly SearchDocument[], normalize: (value: string) => string): LocationAliasIndex {
  const cached = locationAliasIndexCache.get(documents);
  if (cached) return cached;
  const entries = new Map<string, LocationAliasEntry>();
  const add = (entry: LocationAliasEntry) => entries.set(`${entry.kind}:${entry.canonicalId}:${entry.alias}`, entry);

  for (const fixed of fixedAliases) {
    for (const value of fixed.aliases) {
      const alias = normalize(value);
      add({ alias, kind: "city", canonicalId: fixed.canonicalId, provinceId: fixed.provinceId, label: fixed.label, allowFuzzy: !alias.includes(" ") && alias.length >= 5 });
    }
  }

  for (const document of documents) {
    if (document.type !== "municipality" && document.type !== "city" && document.type !== "province") continue;
    const kind = document.type === "province" ? "province" : "city";
    const canonicalId = kind === "province"
      ? document.provinceId ?? document.slug
      : canonicalCityId(document.municipalityId ?? document.cityId ?? document.slug);
    if (!canonicalId) continue;
    const primaryAliases = new Set([document.title, document.slug, ...(document.locationAliases ?? [])].map(normalize));
    for (const alias of documentAliases(document, normalize)) {
      add({
        alias,
        kind,
        canonicalId,
        provinceId: kind === "province" ? document.provinceId ?? document.slug : document.provinceId,
        label: kind === "province" ? document.title : cityDisplayName(canonicalId, document.title),
        allowFuzzy: primaryAliases.has(alias) && !alias.includes(" ") && alias.length >= 5
      });
    }
  }

  const indexedEntries = [...entries.values()];
  const fuzzyByFirstCharacter = new Map<string, LocationAliasEntry[]>();
  for (const entry of indexedEntries) {
    if (!entry.allowFuzzy) continue;
    const bucket = fuzzyByFirstCharacter.get(entry.alias[0]) ?? [];
    bucket.push(entry);
    fuzzyByFirstCharacter.set(entry.alias[0], bucket);
  }
  const index = { entries: indexedEntries, fuzzyByFirstCharacter };
  locationAliasIndexCache.set(documents, index);
  return index;
}

function rankLocationCandidates(candidates: SearchLocationContext[]): SearchLocationContext | null {
  return candidates.sort((left, right) =>
    right.matchedAlias.split(" ").length - left.matchedAlias.split(" ").length ||
    right.matchedAlias.length - left.matchedAlias.length ||
    Number(right.kind === "city") - Number(left.kind === "city") ||
    left.canonicalId.localeCompare(right.canonicalId)
  )[0] ?? null;
}

export function resolveSearchLocation(
  documents: readonly SearchDocument[],
  query: string,
  normalize: (value: string) => string
): SearchLocationContext | null {
  const normalizedQuery = normalize(query);
  if (!normalizedQuery) return null;

  const index = locationAliasIndex(documents, normalize);
  const exactCandidates = index.entries.flatMap((entry): SearchLocationContext[] =>
    normalizedQuery === entry.alias || ` ${normalizedQuery} `.includes(` ${entry.alias} `)
      ? [{ ...entry, matchedAlias: entry.alias, consumedTokens: entry.alias.split(" "), matchKind: "exact" }]
      : []
  );
  if (exactCandidates.length > 0) return rankLocationCandidates(exactCandidates);

  const fuzzyCandidates: SearchLocationContext[] = [];
  for (const token of normalizedQuery.split(" ")) {
    if (token.length < 5) continue;
    for (const entry of index.fuzzyByFirstCharacter.get(token[0]) ?? []) {
      const maximumDistance = entry.alias.length >= 6 ? 2 : 1;
      if (Math.abs(token.length - entry.alias.length) > maximumDistance) continue;
      if (boundedEditDistance(token, entry.alias, maximumDistance) <= maximumDistance) {
        fuzzyCandidates.push({ ...entry, matchedAlias: entry.alias, consumedTokens: [token], matchKind: "fuzzy" });
      }
    }
  }
  return rankLocationCandidates(fuzzyCandidates);
}

export function selectedLocationContext(
  documents: readonly SearchDocument[],
  cityId?: string,
  provinceId?: string
): SearchLocationContext | null {
  if (cityId) {
    const canonicalId = canonicalCityId(cityId);
    const document = documents.find((candidate) =>
      (candidate.type === "municipality" || candidate.type === "city") &&
      canonicalCityId(candidate.municipalityId ?? candidate.cityId ?? candidate.slug) === canonicalId
    );
    return canonicalId ? {
      kind: "city",
      canonicalId,
      provinceId: document?.provinceId ?? provinceId ?? null,
      label: cityDisplayName(canonicalId, document?.title),
      matchedAlias: "",
      consumedTokens: [],
      matchKind: "selected"
    } : null;
  }
  if (provinceId) {
    const document = documents.find((candidate) => candidate.type === "province" && candidate.provinceId === provinceId);
    return {
      kind: "province",
      canonicalId: provinceId,
      provinceId,
      label: document?.title ?? provinceId.replaceAll("-", " "),
      matchedAlias: "",
      consumedTokens: [],
      matchKind: "selected"
    };
  }
  return null;
}

export function removeSearchLocation(
  query: string,
  location: SearchLocationContext,
  normalize: (value: string) => string
): string {
  const normalizedQuery = normalize(query);
  if (!normalizedQuery || location.consumedTokens.length === 0) return normalizedQuery;
  const consumedPhrase = location.consumedTokens.join(" ");
  return ` ${normalizedQuery} `.replace(` ${consumedPhrase} `, " ").replace(/\s+/g, " ").trim();
}
