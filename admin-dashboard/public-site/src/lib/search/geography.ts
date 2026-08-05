import type { SearchDocument } from "./rank";

export interface SearchLocationContext {
  readonly kind: "city" | "province";
  readonly canonicalId: string;
  readonly provinceId: string | null;
  readonly label: string;
  readonly matchedAlias: string;
  readonly consumedTokens: readonly string[];
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
  { canonicalId: "leiden", provinceId: "zuid-holland", label: "Leiden", aliases: ["Leiden", "Лейден"] }
];

export function canonicalCityId(value: string | null | undefined): string | null {
  if (!value) return null;
  const slug = value.trim().toLocaleLowerCase("en").replace(/^['’]/, "").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  return cityIdAliases[slug] ?? slug;
}

export function cityDisplayName(canonicalId: string, fallback?: string): string {
  return preferredCityLabels[canonicalCityId(canonicalId) ?? canonicalId] ?? fallback ?? canonicalId.replaceAll("-", " ");
}

function phraseMatch(query: string, alias: string) {
  return query === alias || ` ${query} `.includes(` ${alias} `);
}

function documentAliases(document: SearchDocument, normalize: (value: string) => string): string[] {
  const values = [document.title, document.slug, ...(document.synonyms ?? []), ...document.keywords];
  return [...new Set(values
    .map(normalize)
    .filter((value) => value.length >= 2 && value.length <= 64 && value.split(" ").length <= 5))];
}

export function resolveSearchLocation(
  documents: readonly SearchDocument[],
  query: string,
  normalize: (value: string) => string
): SearchLocationContext | null {
  const normalizedQuery = normalize(query);
  if (!normalizedQuery) return null;

  const candidates: SearchLocationContext[] = [];
  for (const entry of fixedAliases) {
    for (const value of entry.aliases) {
      const alias = normalize(value);
      if (phraseMatch(normalizedQuery, alias)) {
        candidates.push({
          kind: "city",
          canonicalId: entry.canonicalId,
          provinceId: entry.provinceId,
          label: entry.label,
          matchedAlias: alias,
          consumedTokens: alias.split(" ")
        });
      }
    }
  }

  for (const document of documents) {
    if (document.type !== "municipality" && document.type !== "city" && document.type !== "province") continue;
    for (const alias of documentAliases(document, normalize)) {
      if (!phraseMatch(normalizedQuery, alias)) continue;
      if (document.type === "province") {
        candidates.push({
          kind: "province",
          canonicalId: document.provinceId ?? document.slug,
          provinceId: document.provinceId ?? document.slug,
          label: document.title,
          matchedAlias: alias,
          consumedTokens: alias.split(" ")
        });
      } else {
        const canonicalId = canonicalCityId(document.municipalityId ?? document.cityId ?? document.slug);
        if (!canonicalId) continue;
        candidates.push({
          kind: "city",
          canonicalId,
          provinceId: document.provinceId,
          label: cityDisplayName(canonicalId, document.title),
          matchedAlias: alias,
          consumedTokens: alias.split(" ")
        });
      }
    }
  }

  return candidates.sort((left, right) =>
    right.matchedAlias.split(" ").length - left.matchedAlias.split(" ").length ||
    right.matchedAlias.length - left.matchedAlias.length ||
    Number(right.kind === "city") - Number(left.kind === "city") ||
    left.canonicalId.localeCompare(right.canonicalId)
  )[0] ?? null;
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
      consumedTokens: []
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
      consumedTokens: []
    };
  }
  return null;
}
