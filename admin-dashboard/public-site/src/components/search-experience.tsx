"use client";

import { FormEvent, KeyboardEvent, useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { CalendarCheck2, Check, ChevronDown, FileCheck2, Globe2, MapPin, Search, Share2, SlidersHorizontal, X } from "lucide-react";
import { SaveButton } from "@/components/save-button";
import { track, type AnalyticsEvent } from "@/lib/analytics/client";
import { contentKindLabel, publicWebSummary } from "@/lib/content/presentation";
import { normalizeSearchText, rankSearchDocuments, searchDocumentLocationMatch, type SearchDocument, type SearchFilters } from "@/lib/search/rank";
import { canonicalCityId, cityDisplayName, removeSearchLocation, resolveSearchLocation, selectedLocationContext } from "@/lib/search/geography";
import { matchSearchIntents, privacySafeSearchQuery, taxonomyTopic } from "@/lib/search/taxonomy";
import type { GuideAudienceProfile } from "@/lib/content/types";
import { localContentRepository, removeLegacySearchHistory, sanitizeUserPathProfile, userPathProfiles } from "@/lib/storage/local-content";

type SearchIndex = { schemaVersion: 3; documents: SearchDocument[] };
type Filters = { type: string; city: string; province: string; category: string; profile: string };
type FilterKey = keyof Filters;
type SelectOption = { value: string; label: string };

const emptyFilters: Filters = { type: "", city: "", province: "", category: "", profile: "" };
const popularSearches = ["Register gemeente", "Housing defects", "Student housing", "Emergency", "Amsterdam", "train station"];
const nationalGuideCategoryByIntent: Readonly<Record<string, string>> = {
  housing: "housing", benefits: "housing",
  work: "work", business: "work",
  documents: "documents", government: "documents", integration: "documents",
  healthcare: "healthcare", insurance: "healthcare", emergency: "healthcare",
  education: "education", "language-learning": "education",
  telecom: "telecom", internet: "telecom", "daily-life": "telecom",
  "rules-fines": "rules", transport: "rules"
};
function unique(values: Array<string | null>) { return [...new Set(values.filter((value): value is string => Boolean(value)))].sort(); }
function titleCase(value: string) { return `${value[0]?.toUpperCase() ?? ""}${value.slice(1)}`; }
function humanize(value: string) { return value.replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
function verificationDateLabel(value: string | null | undefined) { return value?.slice(0, 10) || "date not published"; }

function createSearchAnalyticsEvent(
  documents: SearchDocument[],
  query: string,
  filters: Filters
): Extract<AnalyticsEvent, { name: "search" }> {
  const results = rankSearchDocuments(documents, query, {
    filters: {
      type: filters.type as SearchDocument["type"] || undefined,
      cityId: filters.city || undefined,
      provinceId: filters.province || undefined,
      category: filters.category || undefined
    },
    limit: 200,
    preferredProfile: (filters.profile || null) as GuideAudienceProfile | null
  });
  const resultCount = results.length;
  const intentIds = matchSearchIntents(query, normalizeSearchText).map((match) => match.intent);
  const hasLocalContext = Boolean(
    resolveSearchLocation(documents, query, normalizeSearchText) || filters.city || filters.province
  );
  const hasNationalResult = results.some(({ document }) => document.locationScope === "national" || document.nationalFallback);
  return {
    name: "search",
    normalizedQuery: privacySafeSearchQuery(query),
    intentIds,
    filters,
    resultCount,
    zeroResult: resultCount === 0,
    fallbackTier: resultCount === 0 ? "broadened" : hasLocalContext && hasNationalResult ? "national" : "exact"
  };
}

const filterLabels: Readonly<Record<FilterKey, string>> = {
  type: "Type",
  city: "City",
  province: "Province",
  category: "Category",
  profile: "Profile"
};

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
  const [shareState, setShareState] = useState<"idle" | "sharing" | "shared" | "copied" | "error">("idle");
  const [rememberSearches, setRememberSearches] = useState(false);
  const [legacyHistoryWarning, setLegacyHistoryWarning] = useState(false);
  const [showAllResults, setShowAllResults] = useState(false);
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [compactFilters, setCompactFilters] = useState(false);
  const initialUrlSearch = useRef<{ query: string; filters: Filters } | null>(null);
  const initialUrlSearchTracked = useRef(false);
  const lastGeoAnalyticsKey = useRef("");
  const searchStartedAt = useRef(0);
  const firstActionTracked = useRef(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const initialQuery = initialUrlSearch.current?.query ?? localContentRepository.takeSearchHandoff() ?? params.get("q") ?? "";
    const profileParameter = params.get("profile");
    const initialFilters = initialUrlSearch.current?.filters ?? {
      type: params.get("type") ?? "", city: canonicalCityId(params.get("city")) ?? "", province: params.get("province") ?? "",
      category: params.get("category") ?? "",
      profile: profileParameter === null
        ? localContentRepository.profile() ?? ""
        : sanitizeUserPathProfile(profileParameter) ?? ""
    };
    // Legacy incoming links still work in memory; never retain their query text.
    params.delete("q");
    window.history.replaceState(null, "", `${window.location.pathname}${params.size ? `?${params}` : ""}`);
    setLegacyHistoryWarning(!removeLegacySearchHistory());
    const historyEnabled = localContentRepository.searchHistoryEnabled();
    initialUrlSearch.current = { query: initialQuery.trim(), filters: initialFilters };
    if (initialQuery.trim()) searchStartedAt.current = performance.now();
    setQuery(initialQuery); setSubmittedQuery(initialQuery); setFilters(initialFilters); setRememberSearches(historyEnabled); setRecentSearches(historyEnabled ? localContentRepository.recentSearches() : []);
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => { if (!response.ok) throw new Error(String(response.status)); return response.json() as Promise<SearchIndex>; })
      .then((index) => {
        if (index.schemaVersion !== 3) throw new Error("Unsupported search index");
        setDocuments(index.documents);
      })
      .catch(() => setLoadError(true)).finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    const initial = initialUrlSearch.current;
    if (loading || initialUrlSearchTracked.current || !initial?.query || documents.length === 0) return;
    initialUrlSearchTracked.current = true;
    const analyticsEvent = createSearchAnalyticsEvent(documents, initial.query, initial.filters);
    track(analyticsEvent);
  }, [documents, loading]);

  useEffect(() => {
    const media = window.matchMedia("(max-width: 760px)");
    const update = () => setCompactFilters(media.matches);
    update();
    media.addEventListener("change", update);
    return () => media.removeEventListener("change", update);
  }, []);

  const options = useMemo(() => {
    const cityMap = new Map<string, string>();
    const provinceMap = new Map<string, string>();
    for (const document of documents) {
      const cityId = canonicalCityId(document.municipalityId ?? document.cityId);
      if (cityId) {
        const label = cityDisplayName(cityId, document.city ?? document.title);
        const current = cityMap.get(cityId);
        if (!current || document.type === "city") cityMap.set(cityId, label);
      }
      if (document.provinceId) provinceMap.set(document.provinceId, document.province ?? humanize(document.provinceId));
    }
    const asOptions = (map: Map<string, string>): SelectOption[] => [...map].map(([value, label]) => ({ value, label })).sort((left, right) => left.label.localeCompare(right.label));
    return {
      cities: asOptions(cityMap),
      provinces: asOptions(provinceMap),
      categories: unique(documents.flatMap((doc) => [...doc.categories])).map((value) => ({ value, label: humanize(value) }))
    };
  }, [documents]);

  const ranked = useMemo(() => {
    return rankSearchDocuments(documents, submittedQuery, {
      filters: { type: filters.type as SearchDocument["type"] || undefined, cityId: filters.city || undefined, provinceId: filters.province || undefined, category: filters.category || undefined },
      limit: 80,
      preferredProfile: (filters.profile || null) as GuideAudienceProfile | null
    });
  }, [documents, submittedQuery, filters]);

  const detectedLocation = useMemo(
    () => resolveSearchLocation(documents, submittedQuery, normalizeSearchText),
    [documents, submittedQuery]
  );
  const selectedLocation = useMemo(
    () => selectedLocationContext(documents, filters.city || undefined, filters.province || undefined),
    [documents, filters.city, filters.province]
  );
  const effectiveLocation = detectedLocation ?? selectedLocation;

  const recovery = useMemo(() => {
    if (ranked.length > 0 || !submittedQuery) return { results: [], cleared: [] as FilterKey[] };
    const attempts: Array<{ cleared: FilterKey[]; filters: SearchFilters }> = [
      { cleared: ["city", "province"], filters: { type: filters.type as SearchDocument["type"] || undefined, category: filters.category || undefined } },
      { cleared: ["type", "city", "province", "category"], filters: {} }
    ];
    for (const attempt of attempts) {
      const results = rankSearchDocuments(documents, submittedQuery, {
        filters: attempt.filters,
        preferredProfile: (filters.profile || null) as GuideAudienceProfile | null,
        limit: 12
      });
      const geographicallySafeResults = effectiveLocation
        ? results.filter(({ document }) => searchDocumentLocationMatch(document, effectiveLocation) !== "none")
        : results;
      if (geographicallySafeResults.length > 0) return { results: geographicallySafeResults, cleared: attempt.cleared };
    }
    return { results: [], cleared: [] as FilterKey[] };
  }, [documents, effectiveLocation, filters, ranked.length, submittedQuery]);

  const visibleResults = ranked.length > 0 ? ranked : recovery.results;
  const intentMatches = useMemo(() => matchSearchIntents(submittedQuery, normalizeSearchText), [submittedQuery]);
  const primaryIntent = intentMatches[0]?.intent ?? null;
  const primaryNationalCategory = primaryIntent ? nationalGuideCategoryByIntent[primaryIntent] : null;
  const primaryNationalGuide = primaryIntent
    ? documents.find((document) =>
      document.sourceKind === "nationalResourceGuide" &&
      primaryNationalCategory !== null &&
      document.categories.includes(primaryNationalCategory)
    )
    : undefined;
  const municipalityResult = effectiveLocation?.kind === "city"
    ? visibleResults.find(({ document, locationMatch }) => document.type === "municipality" && locationMatch === "exact")
    : undefined;
  const hasVerifiedLocalResult = effectiveLocation?.kind === "city" && visibleResults.some(({ document, locationMatch }) =>
    (locationMatch === "exact" || locationMatch === "service-area") &&
    !["municipality", "province", "category", "page"].includes(document.type)
  );
  const showLocalFallback = Boolean(submittedQuery && primaryIntent && effectiveLocation?.kind === "city" && !hasVerifiedLocalResult);

  useEffect(() => {
    if (loading || detectedLocation?.kind !== "city" || !primaryIntent) return;
    const analyticsKey = [submittedQuery, detectedLocation.canonicalId, primaryIntent, hasVerifiedLocalResult ? "local" : "fallback"].join(":");
    if (lastGeoAnalyticsKey.current === analyticsKey) return;
    lastGeoAnalyticsKey.current = analyticsKey;
    track({ name: "explicit_city_detected", city: detectedLocation.canonicalId, intentId: primaryIntent });
    track({ name: "city_filter_applied", city: detectedLocation.canonicalId, source: "query" });
    if ((filters.city && canonicalCityId(filters.city) !== detectedLocation.canonicalId) || filters.province) {
      track({ name: "city_filter_corrected", city: detectedLocation.canonicalId, source: "query" });
    }
    track(hasVerifiedLocalResult
      ? { name: "local_result_available", city: detectedLocation.canonicalId, intentId: primaryIntent }
      : { name: "national_fallback_shown", city: detectedLocation.canonicalId, intentId: primaryIntent });
  }, [detectedLocation, filters.city, filters.province, hasVerifiedLocalResult, loading, primaryIntent, submittedQuery]);

  const hasActiveFilters = Object.values(filters).some(Boolean);
  const activeProfileLabel = filters.profile ? titleCase(filters.profile) : null;
  const activeFilterChips = (Object.entries(filters) as Array<[FilterKey, string]>)
    .filter((entry): entry is [FilterKey, string] => Boolean(entry[1]))
    .map(([key, value]) => {
      const label = key === "city"
        ? options.cities.find((option) => option.value === value)?.label ?? cityDisplayName(value)
        : key === "province"
          ? options.provinces.find((option) => option.value === value)?.label ?? humanize(value)
          : key === "category"
            ? options.categories.find((option) => option.value === value)?.label ?? humanize(value)
            : titleCase(value);
      return { key, value, label: `${filterLabels[key]}: ${label}` };
    });

  const suggestions = useMemo(() => query.trim().length >= 2
    ? rankSearchDocuments(documents, query, { limit: 6 }).map((result) => result.document)
    : [], [documents, query]);
  const suggestionsVisible = suggestions.length > 0 && query !== submittedQuery && !suggestionsDismissed;

  function recordFirstAction() {
    if (firstActionTracked.current || !primaryIntent || effectiveLocation?.kind !== "city") return;
    firstActionTracked.current = true;
    const elapsed = searchStartedAt.current > 0 ? performance.now() - searchStartedAt.current : 0;
    track({
      name: "time_to_first_action",
      city: effectiveLocation.canonicalId,
      intentId: primaryIntent,
      durationMilliseconds: elapsed
    });
  }

  function filterPath(nextFilters = filters) {
    const params = new URLSearchParams();
    const allowed = {
      type: [...new Set(documents.map((document) => document.type))] as readonly string[],
      city: options.cities.map((option) => option.value),
      province: options.provinces.map((option) => option.value),
      category: options.categories.map((option) => option.value),
      profile: userPathProfiles as readonly string[]
    };
    for (const key of Object.keys(allowed) as FilterKey[]) {
      const value = nextFilters[key];
      if (value && allowed[key].includes(value)) params.set(key, value);
    }
    return `${window.location.pathname}${params.size ? `?${params}` : ""}`;
  }

  function syncUrl(nextFilters = filters) {
    window.history.replaceState(null, "", filterPath(nextFilters));
  }

  function trackSearchSubmission(value: string, nextFilters: Filters, sourceDocuments = documents) {
    const normalizedValue = value.trim();
    if (!normalizedValue) return;
    const analyticsEvent = createSearchAnalyticsEvent(sourceDocuments, normalizedValue, nextFilters);
    track(analyticsEvent);
  }

  function executeSearch(value: string, nextFilters = filters) {
    const normalizedValue = value.trim();
    setQuery(normalizedValue);
    setSubmittedQuery(normalizedValue);
    setFilters(nextFilters);
    setShowAllResults(false);
    setSuggestionIndex(-1);
    setSuggestionsDismissed(true);
    searchStartedAt.current = performance.now();
    firstActionTracked.current = false;
    syncUrl(nextFilters);
    if (normalizedValue) {
      localContentRepository.rememberSearch(normalizedValue);
      setRecentSearches(localContentRepository.recentSearches());
    }
    trackSearchSubmission(normalizedValue, nextFilters);
  }

  function submit(event?: FormEvent) {
    event?.preventDefault();
    executeSearch(query);
  }

  function onKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Escape") { setSuggestionIndex(-1); setSuggestionsDismissed(true); return; }
    if (suggestions.length === 0) return;
    if (event.key === "ArrowDown") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index + 1) % suggestions.length); }
    if (event.key === "ArrowUp") { event.preventDefault(); setSuggestionsDismissed(false); setSuggestionIndex((index) => (index <= 0 ? suggestions.length - 1 : index - 1)); }
    if (event.key === "Enter" && suggestionIndex >= 0) { event.preventDefault(); executeSearch(suggestions[suggestionIndex].title); }
  }

  function setFilter(key: keyof Filters, value: string) {
    if (key === "city") value = canonicalCityId(value) ?? "";
    if (key === "profile") {
      const profile = sanitizeUserPathProfile(value);
      if (profile) localContentRepository.setProfile(profile);
      else localContentRepository.clearProfile();
    }
    const next = { ...filters, [key]: value };
    if (key === "city" && value) track({ name: "city_filter_applied", city: value, source: "filter" });
    setFilters(next);
    setShowAllResults(!submittedQuery && !Object.values(next).some(Boolean));
    syncUrl(next);
    if (submittedQuery) trackSearchSubmission(submittedQuery, next);
  }

  function clearSelectedFilters(keys: readonly FilterKey[]) {
    const next = { ...filters };
    for (const key of keys) next[key] = "";
    if (keys.includes("profile")) localContentRepository.clearProfile();
    setFilters(next);
    setShowAllResults(!submittedQuery && !Object.values(next).some(Boolean));
    syncUrl(next);
    if (submittedQuery) trackSearchSubmission(submittedQuery, next);
  }

  function clearAllFilters() {
    localContentRepository.clearProfile();
    setFilters(emptyFilters);
    setShowAllResults(!submittedQuery);
    syncUrl(emptyFilters);
    if (submittedQuery) trackSearchSubmission(submittedQuery, emptyFilters);
  }

  function clearGeography() {
    const nextFilters = { ...filters, city: "", province: "" };
    const nextQuery = detectedLocation ? removeSearchLocation(submittedQuery, detectedLocation, normalizeSearchText) : submittedQuery;
    if (effectiveLocation?.kind === "city") track({ name: "city_filter_corrected", city: effectiveLocation.canonicalId, source: detectedLocation ? "query" : "filter" });
    executeSearch(nextQuery, nextFilters);
  }

  function contextualResultRoute(document: SearchDocument, locationMatch: string | undefined) {
    if (effectiveLocation?.kind !== "city" || document.type !== "guide" || locationMatch !== "national") return document.route;
    const separator = document.route.includes("?") ? "&" : "?";
    return `${document.route}${separator}city=${encodeURIComponent(effectiveLocation.canonicalId)}`;
  }

  function geographyReason(locationMatch: string | undefined) {
    if (!effectiveLocation) return null;
    if (locationMatch === "exact") return `Matches ${effectiveLocation.label}`;
    if (locationMatch === "service-area") return `Confirmed service area includes ${effectiveLocation.label}`;
    if (locationMatch === "province") return effectiveLocation.provinceId ? `Relevant to ${humanize(effectiveLocation.provinceId)}` : "Provincial coverage";
    if (locationMatch === "online") return `Available online from ${effectiveLocation.label}`;
    if (locationMatch === "national") return `National guidance for ${effectiveLocation.label}`;
    return null;
  }

  function resultTypeLabel(document: SearchDocument) {
    if (document.type === "municipality" || document.type === "province") return "Official source";
    if (document.type === "organization") return "Organization";
    if (document.type === "guide") return "Guide";
    return contentKindLabel(document.type, document.contentDepth);
  }

  async function shareResults() {
    const shareUrl = new URL(filterPath(), window.location.origin).href;
    const pulse = (state: Exclude<typeof shareState, "idle">) => {
      setShareState(state);
      window.setTimeout(() => setShareState("idle"), 1800);
    };
    if (navigator.share) {
      setShareState("sharing");
      try {
        await navigator.share({ title: "YouNew search filters", url: shareUrl });
        pulse("shared");
        return;
      } catch (error) {
        if (error instanceof DOMException && error.name === "AbortError") {
          setShareState("idle");
          return;
        }
      }
    }
    try {
      await navigator.clipboard.writeText(shareUrl);
      pulse("copied");
    } catch {
      pulse("error");
    }
  }

  const filterControls = (
    <div className={`search-filter-bar${filtersOpen ? " is-open" : ""}`} aria-label="Search filters">
      <button
        className="search-filter-toggle"
        type="button"
        aria-expanded={filtersOpen}
        aria-controls="search-filter-fields"
        onClick={() => setFiltersOpen((open) => !open)}
      >
        <span><SlidersHorizontal aria-hidden /> Filters{activeFilterChips.length ? ` (${activeFilterChips.length})` : ""}</span>
        <ChevronDown aria-hidden />
      </button>
      <div className="search-filter-fields" id="search-filter-fields">
        <label>Type<select value={filters.type} onChange={(event) => setFilter("type", event.target.value)}><option value="">All</option><option value="guide">Guides & summaries</option><option value="city">Reviewed city guides</option><option value="municipality">Municipalities</option><option value="province">Provinces</option><option value="organization">Organizations</option><option value="place">Places</option><option value="category">Categories</option><option value="page">Useful pages</option></select></label>
        <label>City<select value={filters.city} onChange={(event) => setFilter("city", event.target.value)}><option value="">All Netherlands</option>{options.cities.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Province<select value={filters.province} onChange={(event) => setFilter("province", event.target.value)}><option value="">All Netherlands</option>{options.provinces.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Category<select value={filters.category} onChange={(event) => setFilter("category", event.target.value)}><option value="">All</option>{options.categories.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Profile<select value={filters.profile} onChange={(event) => setFilter("profile", event.target.value)}><option value="">All</option><option value="tourist">Tourist</option><option value="student">Student</option><option value="expat">Expat</option><option value="refugee">Refugee</option><option value="worker">Worker</option><option value="resident">Resident</option></select></label>
      </div>
    </div>
  );

  const profileContext = activeProfileLabel ? (
    <div className="search-active-context" role="status">
      <div><strong>{activeProfileLabel} profile is a ranking boost</strong><span>It improves the order of relevant results but never hides general published guidance.</span></div>
      <button type="button" onClick={clearAllFilters}>Show all content</button>
    </div>
  ) : null;

  return (
    <div className="search-experience">
      <form className="search-form" role="search" onSubmit={submit}>
        <div className="search-input-wrap">
          <Search aria-hidden /><input id="search-query" role="combobox" aria-label="Search published YouNew content" aria-autocomplete="list" aria-controls="search-suggestions" aria-expanded={suggestionsVisible} aria-activedescendant={suggestionIndex >= 0 ? `search-suggestion-${suggestionIndex}` : undefined} aria-haspopup="listbox" autoComplete="off" placeholder="Try ‘Register gemeente’ or ‘Housing defects’" value={query} onChange={(event) => { setQuery(event.target.value); setSuggestionIndex(-1); setSuggestionsDismissed(false); }} onKeyDown={onKeyDown} />
          {query ? <button type="button" aria-label="Clear search" onClick={() => { setQuery(""); setSubmittedQuery(""); setSuggestionsDismissed(true); syncUrl(filters); }}><X aria-hidden /></button> : null}
        </div>
        <button className="button button-primary" type="submit">Search</button>
        {suggestionsVisible ? (
          <ul className="search-suggestions" id="search-suggestions" role="listbox">
            {suggestions.map((suggestion, index) => <li key={suggestion.id} role="none"><button id={`search-suggestion-${index}`} role="option" aria-selected={index === suggestionIndex} type="button" onMouseDown={(event) => event.preventDefault()} onClick={() => executeSearch(suggestion.title)}><span>{suggestion.type}</span>{suggestion.title}</button></li>)}
          </ul>
        ) : null}
      </form>

      {effectiveLocation?.kind === "city" ? (
        <div className="search-location-context" role="status">
          <MapPin aria-hidden />
          <div>
            <strong>City: {effectiveLocation.label}{detectedLocation ? " — detected in your query" : ""}</strong>
            <span>{detectedLocation && selectedLocation && selectedLocation.canonicalId !== detectedLocation.canonicalId
              ? `${selectedLocation.label} is not used because the city written in your query has priority.`
              : "Local results must match this municipality or publish a confirmed service area."}</span>
          </div>
          <button type="button" onClick={clearGeography}>Clear geography</button>
        </div>
      ) : null}

      {filterControls}
      {activeFilterChips.length ? (
        <div className="search-active-chips" aria-label="Active search filters">
          {activeFilterChips.map((chip) => (
            <button type="button" key={`${chip.key}:${chip.value}`} onClick={() => clearSelectedFilters([chip.key])} aria-label={`Remove ${chip.label}`}>
              {chip.label}<X aria-hidden />
            </button>
          ))}
          <button className="search-clear-all" type="button" onClick={clearAllFilters}>Clear all</button>
        </div>
      ) : null}
      {!compactFilters ? profileContext : null}

      {!submittedQuery && !showAllResults ? (
        <><div className="search-starters"><section><h2>Popular searches</h2><div>{popularSearches.map((value) => <button type="button" key={value} onClick={() => executeSearch(value)}>{value}</button>)}</div></section>{recentSearches.length ? <section><div className="search-starter-heading"><h2>Recent searches</h2><button type="button" onClick={() => { localContentRepository.clearRecentSearches(); setRecentSearches([]); }}>Clear</button></div><div>{recentSearches.map((value) => <button type="button" key={value} onClick={() => executeSearch(value)}>{value}</button>)}</div></section> : null}</div>
        <label className="search-privacy-control"><input type="checkbox" checked={rememberSearches} onChange={(event) => { const enabled = event.target.checked; localContentRepository.setSearchHistoryEnabled(enabled); setRememberSearches(enabled); if (!enabled) setRecentSearches([]); }} /> Keep recent searches in this tab <span>(off by default; cleared on reload)</span></label></>
      ) : null}
      {legacyHistoryWarning ? <p role="alert">Your browser blocked removal of old search history. New queries are not saved to browser storage. You can remove old site data in your browser settings.</p> : null}
      <p className="search-privacy-control">Search text stays in memory. Reloading clears it; shared links include filters only.</p>

      {loading ? <p className="loading-state">Loading the published search index…</p> : null}
      {loadError ? <div className="empty-state"><h2>Search index unavailable</h2><p>Browse <Link href="/discover">published content</Link> or retry when the connection is restored.</p></div> : null}
      {!loading && !loadError && (submittedQuery || hasActiveFilters || showAllResults) ? (
        <section className="search-results" aria-labelledby="results-title">
          <div className="search-results-heading"><div><h2 id="results-title" aria-live="polite">{visibleResults.length} helpful result{visibleResults.length === 1 ? "" : "s"}{submittedQuery ? ` for “${submittedQuery}”` : ""}</h2>{submittedQuery ? <p>Intent, synonyms, spelling variants, national guidance and local relevance all influence the order.</p> : null}</div><button type="button" onClick={shareResults}>{shareState === "copied" || shareState === "shared" ? <Check aria-hidden /> : <Share2 aria-hidden />}{shareState === "copied" ? "Filter link copied" : shareState === "shared" ? "Filters shared" : shareState === "sharing" ? "Opening share…" : shareState === "error" ? "Unable to share" : "Share filters"}</button></div>
          {ranked.length === 0 && recovery.results.length ? (
            <div className="search-recovery-banner" role="status">
              <Globe2 aria-hidden />
              <div>
                <strong>No exact match with every active filter — showing useful broader results.</strong>
                <span>Your query is unchanged. National guidance stays available for every city and profile.</span>
              </div>
              <div className="search-recovery-actions">
                {recovery.cleared.includes("city") || recovery.cleared.includes("province") ? <button type="button" onClick={() => clearSelectedFilters(["city", "province"])}>Search all Netherlands</button> : null}
                {filters.profile ? <button type="button" onClick={() => clearSelectedFilters(["profile"])}>Remove profile boost</button> : null}
                {primaryNationalGuide ? <Link href={primaryNationalGuide.route}>Open national guidance</Link> : null}
              </div>
            </div>
          ) : null}
          {showLocalFallback && effectiveLocation?.kind === "city" ? (
            <aside className="search-local-fallback" aria-label={`Local result availability for ${effectiveLocation.label}`}>
              <Globe2 aria-hidden />
              <div>
                <strong>For {effectiveLocation.label}, we do not yet have a verified local list.</strong>
                <p>We will not fill the page with organizations from another city. Continue with the national route and the responsible municipality.</p>
              </div>
              <div className="search-local-fallback-actions">
                {primaryNationalGuide ? <Link href={contextualResultRoute(primaryNationalGuide, "national")} onClick={recordFirstAction}>Open national guidance</Link> : null}
                {municipalityResult ? <Link href={municipalityResult.document.route} onClick={recordFirstAction}>Open {effectiveLocation.label} municipality</Link> : null}
                {primaryNationalGuide?.officialSourceUrls?.[0] ? (
                  <a href={primaryNationalGuide.officialSourceUrls[0]} rel="noreferrer" target="_blank" onClick={() => {
                    track({ name: "official_source_click", contentId: primaryNationalGuide.id });
                    recordFirstAction();
                  }}>Open responsible official source</a>
                ) : null}
                {!primaryNationalGuide && primaryIntent ? (
                  <Link href={`/categories/${taxonomyTopic(primaryIntent)?.id ?? primaryIntent}/`} onClick={recordFirstAction}>
                    Browse {taxonomyTopic(primaryIntent)?.title ?? humanize(primaryIntent)} guidance
                  </Link>
                ) : null}
                <Link href="/support/" onClick={() => {
                  track({ name: "wrong_geo_result_reported", city: effectiveLocation.canonicalId, intentId: primaryIntent ?? "unknown" });
                  recordFirstAction();
                }}>Report a missing result</Link>
              </div>
            </aside>
          ) : null}
          {visibleResults.length ? (
            <div className="search-result-list">{visibleResults.map(({ document, locationMatch }, index) => {
              const sourceCount = new Set([...(document.officialSourceUrls ?? []), ...(document.officialSourceURLs ?? [])]).size;
              const relevance = geographyReason(locationMatch);
              const scopeLabel = document.locationScope === "national" || document.nationalFallback
                ? "Netherlands"
                : locationMatch === "service-area" && effectiveLocation
                  ? `Service area for ${effectiveLocation.label}`
                : document.city ?? document.province ?? (document.locationScope === "online-service" || document.locationScope === "remote" ? "Online" : "Local");
              return <article key={document.id}><Link href={contextualResultRoute(document, locationMatch)} onClick={() => {
                track({ name: "search_result_opened", contentId: document.id, position: index + 1, normalizedQuery: privacySafeSearchQuery(submittedQuery) });
                recordFirstAction();
              }}><span>{resultTypeLabel(document)} · {scopeLabel}</span><h3>{document.title}</h3><p>{publicWebSummary(document.summary)}</p><div className="search-result-meta"><span><CalendarCheck2 aria-hidden /> Verified {verificationDateLabel(document.verifiedAt)}</span><span><FileCheck2 aria-hidden /> {sourceCount} official source{sourceCount === 1 ? "" : "s"}</span>{relevance ? <span><MapPin aria-hidden /> {relevance}</span> : null}</div></Link><SaveButton item={{ id: document.id, route: document.route, title: document.title, kind: document.type }} compact /></article>;
            })}</div>
          ) : (
            <div className="empty-state search-empty-state">
              <Search aria-hidden />
              <h2>No useful published match yet</h2>
              <p>Try a suggested topic or broaden the active filters. YouNew does not invent a result when no verified guidance is available.</p>
              <div className="search-empty-actions">
                {hasActiveFilters ? <button className="button button-outline" type="button" onClick={clearAllFilters}>Search all Netherlands</button> : null}
                {primaryIntent ? <Link className="button button-outline" href={`/categories/${taxonomyTopic(primaryIntent)?.id ?? primaryIntent}`}>View {taxonomyTopic(primaryIntent)?.title ?? humanize(primaryIntent)}</Link> : null}
                <Link className="button button-outline" href="/guides">Browse guides</Link>
              </div>
              <div className="search-suggested-queries" aria-label="Suggested searches">
                {["rent", "work", "huisarts", "BSN", "Dutch course", "SIM card", "parking fine"].map((value) => <button type="button" key={value} onClick={() => executeSearch(value)}>{value}</button>)}
              </div>
            </div>
          )}
        </section>
      ) : null}
      {compactFilters ? profileContext : null}
    </div>
  );
}
