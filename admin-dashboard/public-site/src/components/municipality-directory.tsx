"use client";

import Link from "next/link";
import { ArrowRight, Building2, MapPin, Search, X } from "lucide-react";
import { useDeferredValue, useEffect, useMemo, useState } from "react";
import type { NetherlandsMunicipality } from "@/lib/geography";

function normalize(value: string) {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLocaleLowerCase("en")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

export function MunicipalityDirectory({
  municipalities,
  initialProvince = "all"
}: {
  municipalities: readonly NetherlandsMunicipality[];
  initialProvince?: string;
}) {
  const [query, setQuery] = useState("");
  const [province, setProvince] = useState(initialProvince);
  const [queryReady, setQueryReady] = useState(false);
  const deferredQuery = useDeferredValue(query);
  const provinceOptions = useMemo(
    () => [...new Map(municipalities.map((municipality) => [municipality.provinceSlug, municipality.provinceName])).entries()]
      .map(([slug, name]) => ({ slug, name }))
      .sort((left, right) => left.name.localeCompare(right.name, "nl")),
    [municipalities]
  );
  const filtered = useMemo(() => {
    const normalizedQuery = normalize(deferredQuery);
    return municipalities.filter((municipality) => {
      if (province !== "all" && municipality.provinceSlug !== province) return false;
      if (!normalizedQuery) return true;
      return [
        municipality.name,
        municipality.provinceName,
        municipality.administrativeSeat ?? "",
        ...municipality.settlements.map((settlement) => settlement.name)
      ].some((value) => normalize(value).includes(normalizedQuery));
    });
  }, [deferredQuery, municipalities, province]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const provinceParameter = params.get("province");
    const queryParameter = params.get("q");
    if (provinceParameter && provinceOptions.some((option) => option.slug === provinceParameter)) setProvince(provinceParameter);
    if (queryParameter) setQuery(queryParameter);
    setQueryReady(true);
  }, [provinceOptions]);

  useEffect(() => {
    if (!queryReady) return;
    const params = new URLSearchParams();
    if (province !== "all") params.set("province", province);
    if (query.trim()) params.set("q", query.trim());
    window.history.replaceState(null, "", `${window.location.pathname}${params.size ? `?${params}` : ""}`);
  }, [province, query, queryReady]);

  return (
    <div className="municipality-directory">
      <form className="municipality-directory-controls" role="search" onSubmit={(event) => event.preventDefault()}>
        <label className="municipality-search">
          <span>Find a municipality or settlement</span>
          <div><Search aria-hidden /><input type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Amsterdam, Giethoorn, Maastricht…" />{query ? <button type="button" aria-label="Clear municipality search" onClick={() => setQuery("")}><X aria-hidden /></button> : null}</div>
        </label>
        <label>
          <span>Province</span>
          <select value={province} onChange={(event) => setProvince(event.target.value)}>
            <option value="all">All 12 provinces</option>
            {provinceOptions.map((option) => <option value={option.slug} key={option.slug}>{option.name}</option>)}
          </select>
        </label>
        <output aria-live="polite"><strong>{filtered.length}</strong><span>municipalities</span></output>
      </form>

      {filtered.length ? (
        <ol className="municipality-directory-list">
          {filtered.map((municipality) => (
            <li key={municipality.code}>
              <Link href={`/municipalities/${municipality.slug}`}>
                <span className="municipality-directory-icon"><Building2 aria-hidden /></span>
                <span className="municipality-directory-copy">
                  <small>{municipality.code} · {municipality.provinceName}</small>
                  <strong>{municipality.name}</strong>
                  <span>
                    {municipality.administrativeSeat ? <em><MapPin aria-hidden /> {municipality.administrativeSeat}</em> : null}
                    <em>{municipality.settlements.length} official settlement{municipality.settlements.length === 1 ? "" : "s"}</em>
                  </span>
                  {municipality.settlements.length ? <p>{municipality.settlements.slice(0, 4).map((settlement) => settlement.name).join(" · ")}{municipality.settlements.length > 4 ? ` · +${municipality.settlements.length - 4}` : ""}</p> : null}
                </span>
                <ArrowRight aria-hidden />
              </Link>
            </li>
          ))}
        </ol>
      ) : (
        <div className="municipality-directory-empty">
          <Search aria-hidden />
          <h2>No municipality or settlement found</h2>
          <p>Try a shorter place name or clear the province filter.</p>
          <button className="button button-outline" type="button" onClick={() => { setQuery(""); setProvince("all"); }}>Clear filters</button>
        </div>
      )}
    </div>
  );
}
