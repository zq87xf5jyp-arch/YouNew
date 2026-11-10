import canonicalLinksJSON from "@/generated/canonical-official-links.json";
import canonicalMapJSON from "@/generated/canonical-map-points.json";

export type CanonicalMapPoint = (typeof canonicalMapJSON.points)[number];
export type CanonicalOfficialLink = (typeof canonicalLinksJSON.links)[number];

export const canonicalMap = canonicalMapJSON;
export const canonicalOfficialLinks = canonicalLinksJSON;

export function canonicalCategories() {
  return canonicalMap.categories;
}

export function canonicalCities() {
  return canonicalMap.cities;
}
