import type { RankedSearchResult } from "./rank";
export type SearchSort = "relevance" | "title" | "reviewed";

/** Presentation order only: never adds results or changes governance/geography. */
export function sortSearchResults(results: readonly RankedSearchResult[], sort: SearchSort, locale: "en" | "nl" = "en") {
  if (sort === "relevance") return [...results];
  return [...results].sort((a, b) => {
    if (sort === "title") return a.document.title.localeCompare(b.document.title, locale);
    const date = (value?: string | null) => { const time = value ? Date.parse(value) : NaN; return Number.isFinite(time) ? time : -Infinity; };
    const aDate = date(a.document.verifiedAt); const bDate = date(b.document.verifiedAt);
    return aDate === bDate ? 0 : aDate > bDate ? -1 : 1;
  });
}
