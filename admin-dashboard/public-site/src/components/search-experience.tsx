"use client";

import { FormEvent, KeyboardEvent, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { Check, ChevronDown, Search, Share2, SlidersHorizontal, X } from "lucide-react";
import { SaveButton } from "@/components/save-button";
import { track } from "@/lib/analytics/client";
import { contentKindLabel, publicWebSummary } from "@/lib/content/presentation";
import { rankSearchDocuments, type SearchDocument } from "@/lib/search/rank";
import { privacySafeSearchQuery } from "@/lib/search/taxonomy";
import type { GuideAudienceProfile } from "@/lib/content/types";
import { localContentRepository, sanitizeUserPathProfile } from "@/lib/storage/local-content";

type SearchIndex = { schemaVersion: 3; documents: SearchDocument[] };
type Filters = { type: string; city: string; province: string; category: string; profile: string };
type Option = { value: string; label: string };

const emptyFilters: Filters = { type: "", city: "", province: "", category: "", profile: "" };
const popularSearches = ["Rent a home", "Work contract", "Find a GP", "Get a BSN", "SIM card", "Parking fine"];
const filterLabels: Record<keyof Filters, string> = { type: "Type", city: "City", province: "Province", category: "Category", profile: "Profile" };

function titleCase(value: string) { return value.split("-").map((part) => `${part[0]?.toUpperCase() ?? ""}${part.slice(1)}`).join(" "); }
function optionLabel(options: readonly Option[], value: string) { return options.find((option) => option.value === value)?.label ?? titleCase(value); }

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
  const [showAllResults, setShowAllResults] = useState(false);
  const [filtersOpen, setFiltersOpen] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const initialQuery = params.get("q") ?? "";
    const profileParameter = params.get("profile");
    const initialFilters = {
      type: params.get("type") ?? "", city: params.get("city") ?? "", province: params.get("province") ?? "",
      category: params.get("category") ?? "",
      profile: profileParameter === null ? localContentRepository.profile() ?? "" : sanitizeUserPathProfile(profileParameter) ?? ""
    };
    const historyEnabled = localContentRepository.searchHistoryEnabled();
    setQuery(initialQuery);
    setSubmittedQuery(initialQuery);
    setFilters(initialFilters);
    setFiltersOpen(window.matchMedia("(min-width: 761px)").matches);
    setRememberSearches(historyEnabled);
    setRecentSearches(historyEnabled ? localContentRepository.recentSearches() : []);
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => { if (!response.ok) throw new Error(String(response.status)); return response.json() as Promise<SearchIndex>; })
      .then((index) => { if (index.schemaVersion !== 3) throw new Error("Unsupported search index"); setDocuments(index.documents); })
      .catch(() => setLoadError(true)).finally(() => setLoading(false));
  }, []);

  const options = useMemo(() => {
    const cities = new Map<string, string>();
    const provinces = new Map<string, string>();
    const categories = new Map<string, string>();
    for (const document of documents) {
      if (document.cityId && document.cityId !== "s-gravenhage") cities.set(document.cityId, document.city ?? titleCase(document.cityId));
      if (document.id.startsWith("municipality.") && document.cityId === "s-gravenhage") cities.set("den-haag", "Den Haag (The Hague)");
      if (document.provinceId) provinces.set(document.provinceId, document.province ?? titleCase(document.provinceId));
      for (const category of document.categories) categories.set(category, titleCase(category));
    }
    const sorted = (values: Map<string, string>): Option[] => [...values].map(([value, label]) => ({ value, label })).sort((left, right) => left.label.localeCompare(right.label));
    return { cities: sorted(cities), provinces: sorted(provinces), categories: sorted(categories) };
  }, [documents]);

  const rankingOptions = useMemo(() => ({
    filters: {
      type: filters.type as SearchDocument["type"] || undefined,
      cityId: filters.city || undefined,
      provinceId: filters.province || undefined,
      category: filters.category || undefined
    },
    preferredProfile: (filters.profile || null) as GuideAudienceProfile | null,
    limit: 80
  }), [filters]);

  const ranked = useMemo(() => rankSearchDocuments(documents, submittedQuery, rankingOptions), [documents, submittedQuery, rankingOptions]);
  const recoveryResults = useMemo(() => ranked.length === 0 && submittedQuery && (filters.city || filters.province || filters.category)
    ? rankSearchDocuments(documents, submittedQuery, {
      filters: { type: filters.type as SearchDocument["type"] || undefined },
      preferredProfile: (filters.profile || null) as GuideAudienceProfile | null,
      limit: 6
    })
    : [], [documents, submittedQuery, filters, ranked.length]);

  const hasActiveFilters = Object.values(filters).some(Boolean);
  const activeFilterEntries = (Object.entries(filters) as Array<[keyof Filters, string]>).filter(([, value]) => Boolean(value));
  const suggestions = useMemo(() => query.trim().length >= 2
    ? rankSearchDocuments(documents, query, { preferredProfile: (filters.profile || null) as GuideAudienceProfile | null, limit: 6 }).map((result) => result.document)
    : [], [documents, query, filters.profile]);
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
    setSubmittedQuery(value);
    setShowAllResults(false);
    setSuggestionIndex(-1);
    syncUrl(value, filters);
    if (value) {
      localContentRepository.rememberSearch(value);
      setRecentSearches(localContentRepository.recentSearches());
    }
    const results = rankSearchDocuments(documents, value, { ...rankingOptions, limit: 200 });
    track({
      name: "search",
      normalizedQuery: privacySafeSearchQuery(value),
      intentIds: [...new Set(results.slice(0, 10).flatMap((result) => result.matchedIntentIds))].slice(0, 8),
      filters,
      resultCount: results.length,
      zeroResult: results.length === 0,
      fallbackTier: results.some((result) => result.locationMatch === "national") ? "national" : "exact"
    });
  }

  function onKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Escape") { setSuggestionIndex(-1); setSuggestionsDismissed(true); return; }
    if (suggestions.length === 0) return;
    if (event.key === "ArrowDown") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index + 1) % suggestions.length); }
    if (event.key === "ArrowUp") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index <= 0 ? suggestions.length - 1 : index - 1)); }
    if (event.key === "Enter" && suggestionIndex >= 0) { event.preventDefault(); const title = suggestions[suggestionIndex].title; setQuery(title); setSubmittedQuery(title); setSuggestionIndex(-1); syncUrl(title, filters); }
  }

  function setFilter(key: keyof Filters, value: string) {
    if (key === "profile") {
      const profile = sanitizeUserPathProfile(value);
      if (profile) localContentRepository.setProfile(profile); else localContentRepository.clearProfile();
    }
    const next = { ...filters, [key]: value };
    setFilters(next);
    setShowAllResults(!submittedQuery && !Object.values(next).some(Boolean));
    syncUrl(submittedQuery, next);
  }

  function clearAllFilters() {
    setFilters(emptyFilters);
    setShowAllResults(!submittedQuery);
    localContentRepository.clearProfile();
    syncUrl(submittedQuery, emptyFilters);
  }

  async function shareResults() {
    try {
      if (navigator.share) await navigator.share({ title: `YouNew search: ${submittedQuery}`, url: window.location.href });
      else { await navigator.clipboard.writeText(window.location.href); setShareState("copied"); window.setTimeout(() => setShareState("idle"), 1800); }
    } catch { setShareState("idle"); }
  }

  function activeFilterLabel(key: keyof Filters, value: string) {
    if (key === "city") return optionLabel(options.cities, value);
    if (key === "province") return optionLabel(options.provinces, value);
    if (key === "category") return optionLabel(options.categories, value);
    return titleCase(value);
  }

  return (
    <div className="search-experience">
      <form className="search-form" role="search" onSubmit={submit}>
        <div className="search-input-wrap">
          <Search aria-hidden /><input id="search-query" role="combobox" aria-label="Search published YouNew content" aria-autocomplete="list" aria-controls="search-suggestions" aria-expanded={suggestionsVisible} aria-activedescendant={suggestionIndex >= 0 ? `search-suggestion-${suggestionIndex}` : undefined} aria-haspopup="listbox" autoComplete="off" placeholder="Try ‘Rent a home’ or ‘Find a GP’" value={query} onChange={(event) => { setQuery(event.target.value); setSuggestionIndex(-1); setSuggestionsDismissed(false); }} onKeyDown={onKeyDown} />
          {query ? <button type="button" aria-label="Clear search" onClick={() => { setQuery(""); setSubmittedQuery(""); setSuggestionsDismissed(true); syncUrl("", filters); }}><X aria-hidden /></button> : null}
        </div>
        <button className="button button-primary" type="submit">Search</button>
        {suggestionsVisible ? (
          <ul className="search-suggestions" id="search-suggestions" role="listbox">
            {suggestions.map((suggestion, index) => <li key={suggestion.id} role="none"><button id={`search-suggestion-${index}`} role="option" aria-selected={index === suggestionIndex} type="button" onMouseDown={(event) => event.preventDefault()} onClick={() => { setQuery(suggestion.title); setSubmittedQuery(suggestion.title); setSuggestionIndex(-1); setSuggestionsDismissed(true); syncUrl(suggestion.title, filters); }}><span>{suggestion.type}</span>{suggestion.title}</button></li>)}
          </ul>
        ) : null}
      </form>

      <button className="search-filter-toggle" type="button" aria-controls="search-filter-panel" aria-expanded={filtersOpen} onClick={() => setFiltersOpen((open) => !open)}>
        <span><SlidersHorizontal aria-hidden /> Filters{activeFilterEntries.length ? ` (${activeFilterEntries.length})` : ""}</span><ChevronDown aria-hidden />
      </button>
      <div className="search-filter-bar" id="search-filter-panel" hidden={!filtersOpen} aria-label="Search filters">
        <label>Type<select value={filters.type} onChange={(event) => setFilter("type", event.target.value)}><option value="">All</option><option value="guide">Guides & summaries</option><option value="city">Reviewed city guides</option><option value="municipality">Municipalities</option><option value="province">Provinces</option><option value="organization">Organizations</option><option value="place">Places</option><option value="category">Life domains</option><option value="page">Useful pages</option></select></label>
        <label>City or municipality<select value={filters.city} onChange={(event) => setFilter("city", event.target.value)}><option value="">All Netherlands</option>{options.cities.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Province<select value={filters.province} onChange={(event) => setFilter("province", event.target.value)}><option value="">All Netherlands</option>{options.provinces.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Domain<select value={filters.category} onChange={(event) => setFilter("category", event.target.value)}><option value="">All domains</option>{options.categories.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Profile boost<select value={filters.profile} onChange={(event) => setFilter("profile", event.target.value)}><option value="">None</option><option value="tourist">Tourist</option><option value="student">Student</option><option value="expat">Expat</option><option value="refugee">Refugee</option><option value="worker">Worker</option><option value="resident">Resident</option></select></label>
      </div>
      {activeFilterEntries.length ? (
        <div className="search-active-filters" aria-label="Active filters">
          {activeFilterEntries.map(([key, value]) => <button key={key} type="button" onClick={() => setFilter(key, "")} aria-label={`Remove ${filterLabels[key]} filter`}><span>{filterLabels[key]}: {activeFilterLabel(key, value)}</span><X aria-hidden /></button>)}
          <button className="search-clear-filters" type="button" onClick={clearAllFilters}>Clear all</button>
        </div>
      ) : null}
      {filters.profile ? (
        <div className="search-active-context" role="status">
          <div><strong>{titleCase(filters.profile)} profile boosts relevant results</strong><span>It changes ordering only. Other useful national and local content remains available.</span></div>
          <button type="button" onClick={() => setFilter("profile", "")}>Remove boost</button>
        </div>
      ) : null}

      {!submittedQuery && !showAllResults ? (
        <><div className="search-starters"><section><h2>Popular searches</h2><div>{popularSearches.map((value) => <button type="button" key={value} onClick={() => { setQuery(value); setSubmittedQuery(value); syncUrl(value, filters); }}>{value}</button>)}</div></section>{recentSearches.length ? <section><div className="search-starter-heading"><h2>Recent searches</h2><button type="button" onClick={() => { localContentRepository.clearRecentSearches(); setRecentSearches([]); }}>Clear</button></div><div>{recentSearches.map((value) => <button type="button" key={value} onClick={() => { setQuery(value); setSubmittedQuery(value); syncUrl(value, filters); }}>{value}</button>)}</div></section> : null}</div>
        <label className="search-privacy-control"><input type="checkbox" checked={rememberSearches} onChange={(event) => { const enabled = event.target.checked; localContentRepository.setSearchHistoryEnabled(enabled); setRememberSearches(enabled); if (!enabled) setRecentSearches([]); }} /> Remember searches on this device <span>(off by default)</span></label></>
      ) : null}

      {loading ? <p className="loading-state">Loading the published search index…</p> : null}
      {loadError ? <div className="empty-state"><h2>Search index unavailable</h2><p>Browse <Link href="/discover">published content</Link> or retry when the connection is restored.</p></div> : null}
      {!loading && !loadError && (submittedQuery || hasActiveFilters || showAllResults) ? (
        <section className="search-results" aria-labelledby="results-title">
          <div className="search-results-heading"><div><h2 id="results-title" aria-live="polite">{ranked.length} matching result{ranked.length === 1 ? "" : "s"}{submittedQuery ? ` for “${submittedQuery}”` : ""}</h2>{submittedQuery ? <p>Profiles boost ranking; a city filter keeps relevant national guidance visible.</p> : null}</div><button type="button" onClick={shareResults}>{shareState === "copied" ? <Check aria-hidden /> : <Share2 aria-hidden />}{shareState === "copied" ? "Link copied" : "Share results"}</button></div>
          {ranked.length ? <div className="search-result-list">{ranked.map(({ document, locationMatch }, index) => <article key={document.id}><Link href={document.route} onClick={() => track({ name: "search_result_opened", contentId: document.id, position: index + 1, normalizedQuery: privacySafeSearchQuery(submittedQuery) })}><span>{contentKindLabel(document.type, document.contentDepth)}{document.city ? ` · ${document.city}` : locationMatch === "national" && filters.city ? " · National guidance" : ""}</span><h3>{document.title}</h3><p>{publicWebSummary(document.summary)}</p>{locationMatch === "national" && filters.city ? <small>Applies nationally; verify municipality-specific steps.</small> : null}</Link><SaveButton item={{ id: document.id, route: document.route, title: document.title, kind: document.type }} compact /></article>)}</div> : (
            <div className="empty-state search-recovery"><Search aria-hidden /><h2>No useful published result matched</h2><p>Keep the query and broaden one constraint, or start from a verified life domain.</p>
              <div>{filters.city ? <button className="button button-outline" type="button" onClick={() => setFilter("city", "")}>Search all Netherlands</button> : null}{filters.profile ? <button className="button button-outline" type="button" onClick={() => setFilter("profile", "")}>Remove profile boost</button> : null}<Link className="button button-outline" href="/categories">Browse life domains</Link><button className="button button-outline" type="button" onClick={clearAllFilters}>Clear all filters</button></div>
              {recoveryResults.length ? <section aria-labelledby="broader-results-title"><h3 id="broader-results-title">Useful results outside the selected scope</h3>{recoveryResults.map(({ document }) => <Link href={document.route} key={document.id}>{document.title}</Link>)}</section> : null}
            </div>
          )}
        </section>
      ) : null}
    </div>
  );
}
