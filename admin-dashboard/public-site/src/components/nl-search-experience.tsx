"use client";



import { FormEvent, useEffect, useMemo, useRef, useState } from "react";
import { publishSearchTask, takeSearchLanguageHandoff } from "@/lib/search/language-handoff";
import { canonicalCityId } from "@/lib/search/geography";
import { localizedCounterpart } from "@/lib/i18n/routes";
import type { GuideAudienceProfile } from "@/lib/content/types";
import { sortSearchResults, type SearchSort } from "@/lib/search/sort";
import Link from "next/link";
import { CalendarCheck2, ChevronDown, Search, ShieldCheck, SlidersHorizontal } from "lucide-react";
import { localContentRepository } from "@/lib/storage/local-content";
import { track } from "@/lib/analytics/client";
import { dutchCategoryLabel } from "@/lib/i18n/nl";
import { privacySafeSearchQuery } from "@/lib/search/taxonomy";
import { rankSearchDocuments, type SearchDocument } from "@/lib/search/rank";

type SearchIndex = { schemaVersion: 3; documents: SearchDocument[] };

function resultRoute(document: SearchDocument) {
  if(document.dutch)return document.dutch.route;
  const translated = localizedCounterpart(document.route);
  if (translated) return translated.nl;
  if (document.type === "organization") return `/nl/organisaties/${document.slug}`;
  if (document.type === "category") return `/nl/categorieen/${document.slug}`;
  if (document.type === "city" && ["amsterdam", "rotterdam", "den-haag", "utrecht", "eindhoven"].includes(document.slug)) return `/nl/stadsgidsen/${document.slug}`;
  return document.route;
}

function resultLabel(document: SearchDocument) {
  const labels: Partial<Record<SearchDocument["type"], string>> = { city: "Stad", guide: "Gids", organization: "Organisatie", place: "Locatie", category: "Categorie", municipality: "Gemeente", province: "Provincie", page: "Pagina" };
  return labels[document.type] ?? "Informatie";
}

function resultDescription(document: SearchDocument) {
  if(document.dutch)return document.dutch.summary;
  const category = document.categories[0] ? dutchCategoryLabel(document.categories[0]) : resultLabel(document);
  const location = document.city ?? document.province ?? "Nederland";
  return `${category} in ${location}. Bekijk de gepubliceerde bron, controledatum en toepasselijke vervolgstappen.`;
}

export function NlSearchExperience() {
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [sort, setSort] = useState<SearchSort>("relevance");
  const [category, setCategory] = useState("");
  const [suggestionIndex, setSuggestionIndex] = useState(-1);
  const [suggestionsOpen, setSuggestionsOpen] = useState(false);
  const initialized = useRef(false);
  const suggestionList = useRef<HTMLUListElement>(null);
  const [documents, setDocuments] = useState<SearchDocument[]>([]);
  const [query, setQuery] = useState("");
  const [submitted, setSubmitted] = useState("");
  const [carriedFilters, setCarriedFilters] = useState({ province: "", profile: "" });
  const [type, setType] = useState("");
  const [city, setCity] = useState("");
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    if (!initialized.current) {
    const task = takeSearchLanguageHandoff();
    if (task) { setType(task.type); setCity(task.city); setCategory(task.category); setSort(task.sort); setCarriedFilters({ province: task.province, profile: task.profile }); }
    const initial = task?.query ?? localContentRepository.takeSearchHandoff() ?? new URLSearchParams(window.location.search).get("q")?.trim() ?? "";
    window.history.replaceState(null, "", "/nl/zoeken/");
    setQuery(initial); setSubmitted(initial); initialized.current = true;
    }
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => { if (!response.ok) throw new Error(String(response.status)); return response.json() as Promise<SearchIndex>; })
      .then((index) => { if (index.schemaVersion !== 3) throw new Error("Unsupported index"); setDocuments(index.documents); })
      .catch(() => setFailed(true)).finally(() => setLoading(false));
  }, []);

  useEffect(() => { publishSearchTask({ query, type, city, category, ...carriedFilters, sort }); }, [query, type, city, category, carriedFilters, sort]);
  useEffect(() => () => publishSearchTask(null), []);

  const cities = useMemo(() => {
    const byId = new Map<string, string>();
    for (const document of documents) {
      const id = canonicalCityId(document.municipalityId ?? document.cityId);
      if (id && document.city) byId.set(id, document.city);
    }
    return [...byId.entries()]
      .map(([value, label]) => ({ value, label }))
      .sort((a, b) => a.label.localeCompare(b.label, "nl"));
  }, [documents]);
  const categories = useMemo(() => [...new Set(documents.flatMap((document) => [...document.categories]))].sort(), [documents]);
  const suggestions = useMemo(() => query.trim().length >= 2 ? rankSearchDocuments(documents, query, { limit: 6 }).map((item) => item.document) : [], [documents, query]);
  const suggestionsVisible = suggestionsOpen && suggestions.length > 0;
  useEffect(() => { if (suggestionIndex >= 0) suggestionList.current?.querySelector<HTMLElement>('[aria-selected="true"]')?.scrollIntoView({ block: "nearest" }); }, [suggestionIndex]);
  const results = useMemo(() => sortSearchResults(rankSearchDocuments(documents, submitted, {
    filters: { type: type as SearchDocument["type"] || undefined, cityId: city || undefined, category: category || undefined, provinceId: carriedFilters.province || undefined },
    preferredProfile: (carriedFilters.profile || null) as GuideAudienceProfile | null,
    limit: 50
  }), sort, "nl"), [category, city, documents, submitted, type, sort, carriedFilters]);

  function submit(event: FormEvent) {
    event.preventDefault();
    executeSearch(query);
  }

  function executeSearch(phrase: string) {
    const value = phrase.trim();
    setSubmitted(value); setQuery(value); setSuggestionsOpen(false); setSuggestionIndex(-1);
    window.history.replaceState(null, "", "/nl/zoeken/");
    const submittedResults = rankSearchDocuments(documents, value, { filters: { type: type as SearchDocument["type"] || undefined, cityId: city || undefined, category: category || undefined }, limit: 50 });
    track({ name: "search", normalizedQuery: privacySafeSearchQuery(value), intentIds: [], filters: { type, city, province: "", category, profile: "" }, resultCount: submittedResults.length, zeroResult: submittedResults.length === 0, fallbackTier: submittedResults.length ? "exact" : "broadened" });
  }

  return <div className="search-experience" lang="nl">
    <form className="search-form" role="search" onSubmit={submit}>
      <label className="visually-hidden" htmlFor="nl-search-query">Zoek op onderwerp, organisatie of plaats</label>
      <div className="search-input-wrap"><Search aria-hidden /><input id="nl-search-query" type="search" enterKeyHint="search" autoComplete="off" role="combobox" aria-autocomplete="list" aria-controls="nl-search-suggestions" aria-expanded={suggestionsVisible} aria-activedescendant={suggestionsVisible && suggestionIndex >= 0 ? `nl-suggestion-${suggestionIndex}` : undefined} aria-label="Zoek op onderwerp, organisatie of plaats" value={query} onChange={(event) => { setQuery(event.target.value); setSuggestionIndex(-1); setSuggestionsOpen(true); }} onKeyDown={(event) => {
        if (event.key === "Escape") { setSuggestionsOpen(false); setSuggestionIndex(-1); }
        if (!suggestions.length) return;
        if (event.key === "ArrowDown") { event.preventDefault(); setSuggestionsOpen(true); setSuggestionIndex((index) => (index + 1) % suggestions.length); }
        if (event.key === "ArrowUp") { event.preventDefault(); setSuggestionsOpen(true); setSuggestionIndex((index) => index <= 0 ? suggestions.length - 1 : index - 1); }
        if (event.key === "Enter" && suggestionsVisible && suggestionIndex >= 0) { event.preventDefault(); executeSearch(suggestions[suggestionIndex].title); }
      }} placeholder="Bijvoorbeeld: huisarts, BSN of restaurant" /></div>
      <button className="button button-primary" type="submit">Zoeken</button>
      {suggestionsVisible ? <ul ref={suggestionList} className="search-suggestions" id="nl-search-suggestions" role="listbox" aria-label="Zoeksuggesties">{suggestions.map((item, index) => <li role="none" key={item.id}><button type="button" role="option" id={`nl-suggestion-${index}`} aria-selected={index === suggestionIndex} onMouseDown={(event) => event.preventDefault()} onClick={() => executeSearch(item.title)}><span>{resultLabel(item)}</span>{item.title}</button></li>)}</ul> : null}
    </form>
    <div className={`search-filter-bar${filtersOpen ? " is-open" : ""}`} aria-label="Zoekfilters">
      <button className="search-filter-toggle" type="button" aria-expanded={filtersOpen} aria-controls="nl-search-filter-fields" onClick={() => setFiltersOpen((open) => !open)}><span><SlidersHorizontal aria-hidden /> Filters{[type, city, category, carriedFilters.province, carriedFilters.profile].filter(Boolean).length ? ` (${[type, city, category, carriedFilters.province, carriedFilters.profile].filter(Boolean).length})` : ""}</span><ChevronDown aria-hidden /></button>
      <div className="search-filter-fields" id="nl-search-filter-fields">
        <label>Type<select value={type} onChange={(event) => setType(event.target.value)}><option value="">Alle typen</option><option value="guide">Gidsen</option><option value="organization">Organisaties</option><option value="place">Locaties</option><option value="municipality">Gemeenten</option><option value="city">Stadsgidsen</option><option value="province">Provincies</option><option value="category">Categorieën</option><option value="page">Pagina’s</option></select></label>
        <label>Stad<select value={city} onChange={(event) => setCity(event.target.value)}><option value="">Heel Nederland</option>{cities.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
        <label>Categorie<select value={category} onChange={(event) => setCategory(event.target.value)}><option value="">Alle categorieën</option>{categories.map((item) => <option key={item} value={item}>{dutchCategoryLabel(item)}</option>)}</select></label>
      </div>
    </div>
    {type || city || category || carriedFilters.province || carriedFilters.profile ? <div className="search-active-chips" aria-label="Actieve zoekfilters">{carriedFilters.province || carriedFilters.profile ? <span>{[carriedFilters.province, carriedFilters.profile].filter(Boolean).join(" · ")}</span> : null}<button type="button" className="search-clear-all" onClick={() => { setType(""); setCity(""); setCategory(""); setCarriedFilters({ province: "", profile: "" }); }}>Wis filters</button></div> : null}
    <div className="search-sort"><label>Sorteren<select value={sort} onChange={(event) => setSort(event.target.value as SearchSort)}><option value="relevance">Meest relevant</option><option value="title">Naam A–Z</option><option value="reviewed">Recent gecontroleerd</option></select></label></div>
    {loading ? <p role="status">Resultaten laden…</p> : failed ? <div className="empty-state"><h2>Zoeken is tijdelijk niet beschikbaar</h2><p>De resultaten konden niet worden geladen. Probeer het later opnieuw of bekijk de beschikbare categorieën.</p><Link href="/nl/categorieen/">Bekijk categorieën</Link></div> : <section aria-labelledby="nl-results-title"><div className="search-results-heading"><div><h2 id="nl-results-title" aria-live="polite">{results.length} {results.length === 1 ? "resultaat" : "resultaten"}{submitted ? ` voor ‘${submitted}’` : ""}</h2><p>Je zoektekst blijft in het geheugen van dit tabblad. Vernieuwen wist de tekst.</p></div></div>{results.length ? <div className="search-result-list">{results.map(({ document }, index) => <article key={document.id}><Link href={resultRoute(document)} onClick={() => track({ name: "search_result_opened", contentId: document.id, position: index + 1, normalizedQuery: privacySafeSearchQuery(submitted) })}><span>{resultLabel(document)} · {document.city ?? document.province ?? "Nederland"}</span><h3>{document.type === "category" ? dutchCategoryLabel(document.slug) : document.dutch?.title ?? document.title}{!resultRoute(document).startsWith("/nl/") ? <small> (EN)</small> : null}</h3><p>{resultDescription(document)}</p><div className="search-result-meta"><span><CalendarCheck2 aria-hidden /> Gecontroleerd {document.verifiedAt?.slice(0, 10) ?? "datum niet gepubliceerd"}</span><span><ShieldCheck aria-hidden /> Bron zichtbaar op detailpagina</span></div></Link></article>)}</div> : <div className="empty-state"><Search aria-hidden /><h2>Nog geen passend gepubliceerd resultaat</h2><p>Probeer een algemener onderwerp. YouNew maakt geen resultaat wanneer er geen gecontroleerde informatie beschikbaar is.</p><Link className="button button-outline" href="/nl/categorieen/">Bekijk categorieën</Link><Link className="discovery-text-link" href="/municipalities/">Vind de officiële gemeente (EN)</Link></div>}</section>}
  </div>;
}
