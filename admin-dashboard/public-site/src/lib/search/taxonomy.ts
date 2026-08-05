import taxonomy from "@/data/life-domain-taxonomy.json";
import { normalizeSearchText } from "./rank";

export type LifeDomain = {
  slug: string;
  title: string;
  summary: string;
  aliases: Record<"en" | "nl" | "ru", string[]>;
  intents: Array<{ id: string; terms: string[] }>;
  profiles: string[];
  startHere: string[];
  officialSources: Array<{ name: string; url: string }>;
};

export const lifeDomains = taxonomy as LifeDomain[];

export function getLifeDomain(slug: string): LifeDomain | undefined {
  return lifeDomains.find((domain) => domain.slug === slug);
}

const controlledTerms = new Set(
  lifeDomains.flatMap((domain) => [
    domain.slug,
    domain.title,
    ...Object.values(domain.aliases).flat(),
    ...domain.intents.flatMap((intent) => intent.terms)
  ]).flatMap((value) => normalizeSearchText(value).split(/\s+/u).filter(Boolean))
);

export function privacySafeSearchQuery(query: string): string {
  const normalized = normalizeSearchText(query);
  if (!normalized) return "";
  const queryTokens = normalized.split(/\s+/u);
  const containsDirectIdentifier = /@|https?:|\b\d{5,}\b|\b\+?\d[\d\s().-]{7,}\d\b/u.test(query);
  if (containsDirectIdentifier || queryTokens.length > 8 || normalized.length > 80) return "[redacted]";
  return queryTokens.every((token) => controlledTerms.has(token))
    ? normalized
    : "[unmapped]";
}
