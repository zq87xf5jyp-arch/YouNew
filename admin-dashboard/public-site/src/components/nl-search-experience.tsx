"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { CalendarCheck2, Search, ShieldCheck } from "lucide-react";
import { track } from "@/lib/analytics/client";
import { dutchCategoryLabel } from "@/lib/i18n/nl";
import { privacySafeSearchQuery } from "@/lib/search/taxonomy";
import { rankSearchDocuments, type SearchDocument } from "@/lib/search/rank";

type SearchIndex = { schemaVersion: 3; documents: SearchDocument[] };

function resultRoute(document: SearchDocument) {
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
  const category = document.categories[0] ? dutchCategoryLabel(document.categories[0]) : resultLabel(document);
  const location = document.city ?? document.province ?? "Nederland";
  return `${category} in ${location}. Bekijk de gepubliceerde bron, controledatum en toepasselijke vervolgstappen.`;
}

export function NlSearchExperience() {
  const [documents, setDocuments] = useState<SearchDocument[]>([]);
  const [query, setQuery] = useState("");
  const [submitted, setSubmitted] = useState("");
  const [type, setType] = useState("");
  const [city, setCity] = useState("");
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const initial = new URLSearchParams(window.location.search).get("q")?.trim() ?? "";
    setQuery(initial); setSubmitted(initial);
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => { if (!response.ok) throw new Error(String(response.status)); return response.json() as Promise<SearchIndex>; })
      .then((index) => { if (index.schemaVersion !== 3) throw new Error("Unsupported index"); setDocuments(index.documents); })
      .catch(() => setFailed(true)).finally(() => setLoading(false));
  }, []);

  const cities = useMemo(() => {
    const byId = new Map<string, string>();
    for (const document of documents) {
      if (document.cityId && document.city) byId.set(document.cityId, document.city);
    }
    return [...byId.entries()]
      .map(([value, label]) => ({ value, label }))
      .sort((a, b) => a.label.localeCompare(b.label, "nl"));
  }, [documents]);
  const results = useMemo(() => rankSearchDocuments(documents, submitted, {
    filters: { type: type as SearchDocument["type"] || undefined, cityId: city || undefined },
    limit: 50
  }), [city, documents, submitted, type]);

  function submit(event: FormEvent) {
    event.preventDefault();
    const value = query.trim();
    setSubmitted(value);
    const params = new URLSearchParams();
    if (value) params.set("q", value);
    window.history.replaceState(null, "", `/nl/zoeken/${params.size ? `?${params}` : ""}`);
    const submittedResults = rankSearchDocuments(documents, value, { filters: { type: type as SearchDocument["type"] || undefined, cityId: city || undefined }, limit: 50 });
    track({ name: "search", normalizedQuery: privacySafeSearchQuery(value), intentIds: [], filters: { type, city, province: "", category: "", profile: "" }, resultCount: submittedResults.length, zeroResult: submittedResults.length === 0, fallbackTier: submittedResults.length ? "exact" : "broadened" });
  }

  return <div className="search-experience" lang="nl">
    <form className="search-form" role="search" onSubmit={submit}>
      <label className="visually-hidden" htmlFor="nl-search-query">Zoek op onderwerp, organisatie of plaats</label>
      <div className="search-input-wrap"><Search aria-hidden /><input id="nl-search-query" aria-label="Zoek op onderwerp, organisatie of plaats" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Bijvoorbeeld: huisarts, BSN of restaurant" /></div>
      <button className="button button-primary" type="submit">Zoeken</button>
    </form>
    <div className="search-filter-bar is-open" aria-label="Zoekfilters">
      <div className="search-filter-fields">
        <label>Type<select value={type} onChange={(event) => setType(event.target.value)}><option value="">Alle typen</option><option value="guide">Gidsen</option><option value="organization">Organisaties</option><option value="place">Locaties</option><option value="municipality">Gemeenten</option></select></label>
        <label>Stad<select value={city} onChange={(event) => setCity(event.target.value)}><option value="">Heel Nederland</option>{cities.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}</select></label>
      </div>
    </div>
    {loading ? <p role="status">Zoekindex laden…</p> : failed ? <div className="empty-state"><h2>Zoeken is tijdelijk niet beschikbaar</h2><p>De index kon niet worden geladen. Probeer het later opnieuw.</p></div> : <section aria-labelledby="nl-results-title"><div className="search-results-heading"><div><h2 id="nl-results-title">{results.length} {results.length === 1 ? "resultaat" : "resultaten"}{submitted ? ` voor ‘${submitted}’` : ""}</h2><p>De zoekopdracht blijft in je browser; YouNew stuurt geen zoekprofiel naar een externe zoekdienst.</p></div></div>{results.length ? <div className="search-result-list">{results.map(({ document }, index) => <article key={document.id}><Link href={resultRoute(document)} onClick={() => track({ name: "search_result_opened", contentId: document.id, position: index + 1, normalizedQuery: privacySafeSearchQuery(submitted) })}><span>{resultLabel(document)} · {document.city ?? document.province ?? "Nederland"}</span><h3>{document.title}</h3><p>{resultDescription(document)}</p><div className="search-result-meta"><span><CalendarCheck2 aria-hidden /> Gecontroleerd {document.verifiedAt?.slice(0, 10) ?? "datum niet gepubliceerd"}</span><span><ShieldCheck aria-hidden /> Bron zichtbaar op detailpagina</span></div></Link></article>)}</div> : <div className="empty-state"><Search aria-hidden /><h2>Nog geen passend gepubliceerd resultaat</h2><p>Probeer een algemener onderwerp. YouNew maakt geen resultaat wanneer er geen gecontroleerde informatie beschikbaar is.</p><Link className="button button-outline" href="/nl/categorieen/">Bekijk categorieën</Link></div>}</section>}
  </div>;
}
