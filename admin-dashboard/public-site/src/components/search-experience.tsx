"use client";

import { FormEvent, KeyboardEvent, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { Check, Search, Share2, SlidersHorizontal, X } from "lucide-react";
import { SaveButton } from "@/components/save-button";
import { track } from "@/lib/analytics/client";
import { filterSearchDocumentsByProfile, rankSearchDocuments, type SearchDocument } from "@/lib/search/rank";
import type { GuideAudienceProfile } from "@/lib/content/types";
import { localContentRepository, sanitizeUserPathProfile } from "@/lib/storage/local-content";

type SearchIndex = { schemaVersion: 2; documents: SearchDocument[] };
type Filters = { type: string; city: string; province: string; category: string; profile: string };

const emptyFilters: Filters = { type: "", city: "", province: "", category: "", profile: "" };
const popularSearches = ["Register gemeente", "Need a doctor", "Student housing", "Emergency", "Amsterdam", "train station"];
function unique(values: Array<string | null>) { return [...new Set(values.filter((value): value is string => Boolean(value)))].sort(); }

export function SearchExperience() {
  const [documents, setDocuments] = useState<SearchDocument[]>([]);
  const [query, setQuery] = useState("");
  const [submittedQuery, setSubmittedQuery] = useState("");
  const [filters, setFilters] = useState<Filters>(emptyFilters);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const [suggestionIndex, setSuggestionIndex] = useState(-1);
  const [suggestionsDismissed, setSuggestionsDismissed] = useState(false);
  const [shareState, setShareState] = useState<"idle" | "copied">("idle");
  const [rememberSearches, setRememberSearches] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const initialQuery = params.get("q") ?? "";
    const profileParameter = params.get("profile");
    const initialFilters = {
      type: params.get("type") ?? "", city: params.get("city") ?? "", province: params.get("province") ?? "",
      category: params.get("category") ?? "",
      profile: profileParameter === null
        ? localContentRepository.profile() ?? ""
        : sanitizeUserPathProfile(profileParameter) ?? ""
    };
    const historyEnabled = localContentRepository.searchHistoryEnabled();
    setQuery(initialQuery); setSubmittedQuery(initialQuery); setFilters(initialFilters); setRememberSearches(historyEnabled); setRecentSearches(historyEnabled ? localContentRepository.recentSearches() : []);
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => { if (!response.ok) throw new Error(String(response.status)); return response.json() as Promise<SearchIndex>; })
      .then((index) => { if (index.schemaVersion !== 2) throw new Error("Unsupported search index"); setDocuments(index.documents); })
      .catch(() => setLoadError(true)).finally(() => setLoading(false));
  }, []);

  const options = useMemo(() => ({
    cities: unique(documents.map((doc) => doc.cityId)), provinces: unique(documents.map((doc) => doc.provinceId)),
    categories: unique(documents.flatMap((doc) => [...doc.categories]))
  }), [documents]);

  const ranked = useMemo(() => {
    const eligibleDocuments = filterSearchDocumentsByProfile(
      documents,
      (filters.profile || null) as GuideAudienceProfile | null
    );
    return rankSearchDocuments(eligibleDocuments, submittedQuery, {
      filters: { type: filters.type as SearchDocument["type"] || undefined, cityId: filters.city || undefined, provinceId: filters.province || undefined, category: filters.category || undefined },
      limit: 80
    });
  }, [documents, submittedQuery, filters]);

  const hasActiveFilters = Object.values(filters).some(Boolean);

  const suggestions = useMemo(() => query.trim().length >= 2
    ? rankSearchDocuments(documents, query, { limit: 6 }).map((result) => result.document)
    : [], [documents, query]);
  const suggestionsVisible = suggestions.length > 0 && query !== submittedQuery && !suggestionsDismissed;

  function syncUrl(nextQuery = submittedQuery, nextFilters = filters) {
    const params = new URLSearchParams();
    if (nextQuery) params.set("q", nextQuery);
    Object.entries(nextFilters).forEach(([key, value]) => { if (value) params.set(key, value); });
    window.history.replaceState(null, "", `${window.location.pathname}${params.size ? `?${params}` : ""}`);
  }

  function submit(event?: FormEvent) {
    event?.preventDefault();
    const value = query.trim();
    setSubmittedQuery(value); setSuggestionIndex(-1); syncUrl(value, filters);
    if (value) { localContentRepository.rememberSearch(value); setRecentSearches(localContentRepository.recentSearches()); }
    const count = value ? rankSearchDocuments(documents, value, { limit: 200 }).length : 0;
    track({ name: "search", resultCount: count, hasResults: count > 0 });
  }

  function onKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Escape") { setSuggestionIndex(-1); setSuggestionsDismissed(true); return; }
    if (suggestions.length === 0) return;
    if (event.key === "ArrowDown") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index + 1) % suggestions.length); }
    if (event.key === "ArrowUp") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index <= 0 ? suggestions.length - 1 : index - 1)); }
    if (event.key === "Enter" && suggestionIndex >= 0) { event.preventDefault(); const title = suggestions[suggestionIndex].title; setQuery(title); setSubmittedQuery(title); setSuggestionIndex(-1); syncUrl(title, filters); }
  }

  function setFilter(key: keyof Filters, value: string) {
    const next = { ...filters, [key]: value }; setFilters(next); syncUrl(submittedQuery, next);
  }

  async function shareResults() {
    try {
      if (navigator.share) await navigator.share({ title: `YouNew search: ${submittedQuery}`, url: window.location.href });
      else { await navigator.clipboard.writeText(window.location.href); setShareState("copied"); window.setTimeout(() => setShareState("idle"), 1800); }
    } catch { setShareState("idle"); }
  }

  return (
    <div className="search-experience">
      <form className="search-form" role="search" onSubmit={submit}>
        <div className="search-input-wrap">
          <Search aria-hidden /><input id="search-query" role="combobox" aria-label="Search published YouNew content" aria-autocomplete="list" aria-controls="search-suggestions" aria-expanded={suggestionsVisible} aria-activedescendant={suggestionIndex >= 0 ? `search-suggestion-${suggestionIndex}` : undefined} aria-haspopup="listbox" autoComplete="off" placeholder="Try ‘Register gemeente’ or ‘Need a doctor’" value={query} onChange={(event) => { setQuery(event.target.value); setSuggestionIndex(-1); setSuggestionsDismissed(false); }} onKeyDown={onKeyDown} />
          {query ? <button type="button" aria-label="Clear search" onClick={() => { setQuery(""); setSubmittedQuery(""); setSuggestionsDismissed(true); syncUrl("", filters); }}><X aria-hidden /></button> : null}
        </div>
        <button className="button button-primary" type="submit">Search</button>
        {suggestionsVisible ? (
          <ul className="search-suggestions" id="search-suggestions" role="listbox">
            {suggestions.map((suggestion, index) => <li key={suggestion.id} role="none"><button id={`search-suggestion-${index}`} role="option" aria-selected={index === suggestionIndex} type="button" onMouseDown={(event) => event.preventDefault()} onClick={() => { setQuery(suggestion.title); setSubmittedQuery(suggestion.title); setSuggestionIndex(-1); setSuggestionsDismissed(true); syncUrl(suggestion.title, filters); }}><span>{suggestion.type}</span>{suggestion.title}</button></li>)}
          </ul>
        ) : null}
      </form>

      <div className="search-filter-bar" aria-label="Search filters">
        <span><SlidersHorizontal aria-hidden /> Filters</span>
        <label>Type<select value={filters.type} onChange={(event) => setFilter("type", event.target.value)}><option value="">All</option><option value="guide">Guides</option><option value="city">Cities</option><option value="organization">Organizations</option><option value="place">Places</option><option value="category">Categories</option><option value="page">Useful pages</option></select></label>
        <label>City<select value={filters.city} onChange={(event) => setFilter("city", event.target.value)}><option value="">All</option>{options.cities.map((value) => <option value={value} key={value}>{value.replaceAll("-", " ")}</option>)}</select></label>
        <label>Province<select value={filters.province} onChange={(event) => setFilter("province", event.target.value)}><option value="">All</option>{options.provinces.map((value) => <option value={value} key={value}>{value.replaceAll("-", " ")}</option>)}</select></label>
        <label>Category<select value={filters.category} onChange={(event) => setFilter("category", event.target.value)}><option value="">All</option>{options.categories.map((value) => <option value={value} key={value}>{value.replaceAll("-", " ")}</option>)}</select></label>
        <label>Profile<select value={filters.profile} onChange={(event) => setFilter("profile", event.target.value)}><option value="">All</option><option value="tourist">Tourist</option><option value="student">Student</option><option value="expat">Expat</option><option value="refugee">Refugee</option><option value="worker">Worker</option><option value="resident">Resident</option></select></label>
      </div>

      {!submittedQuery ? (
        <><div className="search-starters"><section><h2>Popular searches</h2><div>{popularSearches.map((value) => <button type="button" key={value} onClick={() => { setQuery(value); setSubmittedQuery(value); syncUrl(value, filters); }}>{value}</button>)}</div></section>{recentSearches.length ? <section><div className="search-starter-heading"><h2>Recent searches</h2><button type="button" onClick={() => { localContentRepository.clearRecentSearches(); setRecentSearches([]); }}>Clear</button></div><div>{recentSearches.map((value) => <button type="button" key={value} onClick={() => { setQuery(value); setSubmittedQuery(value); syncUrl(value, filters); }}>{value}</button>)}</div></section> : null}</div>
        <label className="search-privacy-control"><input type="checkbox" checked={rememberSearches} onChange={(event) => { const enabled = event.target.checked; localContentRepository.setSearchHistoryEnabled(enabled); setRememberSearches(enabled); if (!enabled) setRecentSearches([]); }} /> Remember searches on this device <span>(off by default)</span></label></>
      ) : null}

      {loading ? <p className="loading-state">Loading the published search index…</p> : null}
      {loadError ? <div className="empty-state"><h2>Search index unavailable</h2><p>Browse <Link href="/discover">published content</Link> or retry when the connection is restored.</p></div> : null}
      {!loading && !loadError && (submittedQuery || hasActiveFilters) ? (
        <section className="search-results" aria-labelledby="results-title">
          <div className="search-results-heading"><h2 id="results-title" aria-live="polite">{ranked.length} matching result{ranked.length === 1 ? "" : "s"}{submittedQuery ? ` for “${submittedQuery}”` : ""}</h2><button type="button" onClick={shareResults}>{shareState === "copied" ? <Check aria-hidden /> : <Share2 aria-hidden />}{shareState === "copied" ? "Link copied" : "Share results"}</button></div>
          {ranked.length ? <div className="search-result-list">{ranked.map(({ document }) => <article key={document.id}><Link href={document.route}><span>{document.type}{document.city ? ` · ${document.city}` : ""}</span><h3>{document.title}</h3><p>{document.summary}</p></Link><SaveButton item={{ id: document.id, route: document.route, title: document.title, kind: document.type }} compact /></article>)}</div> : <div className="empty-state"><Search aria-hidden /><h2>No published match</h2><p>Try a shorter term, clear one of the filters, or browse categories. Search only includes released and source-checked content.</p><button className="button button-outline" type="button" onClick={() => { setFilters(emptyFilters); syncUrl(submittedQuery, emptyFilters); }}>Clear filters</button></div>}
        </section>
      ) : null}
    </div>
  );
}
