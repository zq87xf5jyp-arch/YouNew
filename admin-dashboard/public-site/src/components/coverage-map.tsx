"use client";

import Link from "next/link";
import { Building2, ExternalLink, MapPin, Navigation, RotateCcw, ShieldCheck } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import {
  clusterCoverageMapItems,
  coverageMapViewport,
  filterCoverageMapItems,
  getCoverageMapBounds,
  humanizeMapSlug,
  type CoverageMapCluster,
  type CoverageMapEntityType,
  type CoverageMapFilters,
  type CoverageMapItem
} from "@/lib/map/coverage";

const initialFilters: CoverageMapFilters = { city: "all", category: "all", type: "all" };
const typeLabels: Record<CoverageMapEntityType, string> = {
  city: "City",
  organization: "Organization",
  place: "Place"
};

function markerType(cluster: CoverageMapCluster): CoverageMapEntityType | "mixed" {
  const types = new Set(cluster.items.map((item) => item.type));
  return types.size === 1 ? cluster.items[0].type : "mixed";
}

function clusterLabel(cluster: CoverageMapCluster): string {
  if (cluster.items.length === 1) return `${cluster.items[0].title}, ${typeLabels[cluster.items[0].type]}`;
  return `${cluster.items.length} released items at nearby or identical coordinates`;
}

function ItemIcon({ type }: { type: CoverageMapEntityType }) {
  const Icon = type === "city" ? Navigation : type === "organization" ? Building2 : MapPin;
  return <Icon aria-hidden />;
}

export function CoverageMap({ items }: { items: readonly CoverageMapItem[] }) {
  const [filters, setFilters] = useState<CoverageMapFilters>(initialFilters);
  const [queryReady, setQueryReady] = useState(false);
  const [activeClusterId, setActiveClusterId] = useState<string | null>(null);

  const options = useMemo(() => ({
    cities: [...new Set(items.map((item) => item.cityId).filter((value): value is string => Boolean(value)))].sort(),
    categories: [...new Set(items.flatMap((item) => [...item.categorySlugs]))].sort()
  }), [items]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const city = params.get("city") ?? "all";
    const category = params.get("category") ?? "all";
    const type = params.get("type") ?? "all";
    setFilters({
      city: city === "all" || options.cities.includes(city) ? city : "all",
      category: category === "all" || options.categories.includes(category) ? category : "all",
      type: type === "city" || type === "organization" || type === "place" ? type : "all"
    });
    setQueryReady(true);
  }, [options]);

  useEffect(() => {
    if (!queryReady) return;
    const params = new URLSearchParams();
    if (filters.city !== "all") params.set("city", filters.city);
    if (filters.category !== "all") params.set("category", filters.category);
    if (filters.type !== "all") params.set("type", filters.type);
    window.history.replaceState(null, "", `${window.location.pathname}${params.size ? `?${params}` : ""}`);
    setActiveClusterId(null);
  }, [filters, queryReady]);

  const filteredItems = useMemo(() => filterCoverageMapItems(items, filters), [filters, items]);
  const filteredCityCount = useMemo(() => new Set(filteredItems.map((item) => item.cityId).filter(Boolean)).size, [filteredItems]);
  const focusOnResults = filters.city !== "all" || ((filters.type !== "all" || filters.category !== "all") && filteredCityCount === 1);
  const bounds = useMemo(
    () => getCoverageMapBounds(filteredItems, focusOnResults),
    [filteredItems, focusOnResults]
  );
  const clusters = useMemo(() => clusterCoverageMapItems(filteredItems, bounds), [bounds, filteredItems]);
  const activeCluster = clusters.find((cluster) => cluster.id === activeClusterId) ?? null;
  const hasFilters = filters.city !== "all" || filters.category !== "all" || filters.type !== "all";

  function updateFilter<Key extends keyof CoverageMapFilters>(key: Key, value: CoverageMapFilters[Key]) {
    setFilters((current) => ({ ...current, [key]: value }));
  }

  function activateCluster(cluster: CoverageMapCluster) {
    setActiveClusterId(cluster.id);
  }

  return (
    <div className="coverage-map-experience">
      <form className="coverage-map-filters" onSubmit={(event) => event.preventDefault()} aria-label="Map filters">
        <div>
          <strong>Filter released coverage</strong>
          <span>Selections are kept in the page URL.</span>
        </div>
        <label>
          City
          <select disabled={!queryReady} value={filters.city} onChange={(event) => updateFilter("city", event.target.value)}>
            <option value="all">All released cities</option>
            {options.cities.map((city) => <option value={city} key={city}>{humanizeMapSlug(city)}</option>)}
          </select>
        </label>
        <label>
          Content type
          <select disabled={!queryReady} value={filters.type} onChange={(event) => updateFilter("type", event.target.value as CoverageMapFilters["type"])}>
            <option value="all">Cities, organizations and places</option>
            <option value="city">Cities</option>
            <option value="organization">Organizations</option>
            <option value="place">Places</option>
          </select>
        </label>
        <label>
          Category
          <select disabled={!queryReady} value={filters.category} onChange={(event) => updateFilter("category", event.target.value)}>
            <option value="all">All released categories</option>
            {options.categories.map((category) => <option value={category} key={category}>{humanizeMapSlug(category)}</option>)}
          </select>
        </label>
        <button className="coverage-map-reset" type="button" disabled={!queryReady || !hasFilters} onClick={() => setFilters(initialFilters)}>
          <RotateCcw aria-hidden /> Reset
        </button>
        <noscript><p className="coverage-map-noscript">Map filters and marker previews require JavaScript. The complete released-content list remains available below.</p></noscript>
      </form>

      <div className="coverage-map-layout">
        <section className="coverage-map-canvas" aria-labelledby="coverage-map-title">
          <div className="coverage-map-heading">
            <div>
              <h2 id="coverage-map-title">Published YouNew coverage</h2>
              <p>Coordinate overview, not a navigation map.</p>
            </div>
            <strong aria-live="polite">{filteredItems.length} item{filteredItems.length === 1 ? "" : "s"}</strong>
          </div>
          {filteredItems.length ? (
            <svg
              className="coverage-map-svg"
              viewBox={`0 0 ${coverageMapViewport.width} ${coverageMapViewport.height}`}
              role="group"
              aria-roledescription="coordinate map"
              aria-labelledby="coverage-map-svg-title coverage-map-svg-description"
            >
              <title id="coverage-map-svg-title">Released YouNew city, place and organization coordinates</title>
              <desc id="coverage-map-svg-description">Select a marker to preview its released records. Nearby and identical coordinates are grouped.</desc>
              <rect className="coverage-map-water" x="1" y="1" width="718" height="758" rx="28" />
              {[1, 2, 3, 4].map((line) => (
                <g className="coverage-map-gridline" key={line} aria-hidden>
                  <line x1={line * 144} x2={line * 144} y1="24" y2="736" />
                  <line x1="24" x2="696" y1={line * 152} y2={line * 152} />
                </g>
              ))}
              <text className="coverage-map-direction" x="360" y="30" textAnchor="middle">N</text>
              <text className="coverage-map-direction" x="360" y="744" textAnchor="middle">S</text>
              <text className="coverage-map-direction" x="25" y="382" textAnchor="middle">W</text>
              <text className="coverage-map-direction" x="695" y="382" textAnchor="middle">E</text>
              {clusters.map((cluster) => {
                const count = cluster.items.length;
                const type = markerType(cluster);
                const isActive = cluster.id === activeClusterId;
                return (
                  <g
                    className={`coverage-map-marker coverage-map-marker-${type}${isActive ? " is-active" : ""}`}
                    key={cluster.id}
                    role={queryReady ? "button" : undefined}
                    tabIndex={queryReady ? 0 : undefined}
                    aria-label={clusterLabel(cluster)}
                    aria-pressed={queryReady ? isActive : undefined}
                    onClick={() => activateCluster(cluster)}
                    onKeyDown={(event) => {
                      if (event.key === "Enter" || event.key === " ") {
                        event.preventDefault();
                        activateCluster(cluster);
                      }
                    }}
                    transform={`translate(${cluster.x} ${cluster.y})`}
                  >
                    <circle className="coverage-map-marker-hit" r="24" />
                    <circle className="coverage-map-marker-dot" r={count > 1 ? Math.min(19, 12 + Math.log2(count) * 1.6) : 9} />
                    {count > 1 ? <text y="4" textAnchor="middle">{count}</text> : null}
                  </g>
                );
              })}
            </svg>
          ) : (
            <div className="coverage-map-empty"><MapPin aria-hidden /><p>No released records match these filters.</p></div>
          )}
          <div className="coverage-map-legend" aria-label="Map legend">
            <span><i className="legend-city" /> City</span>
            <span><i className="legend-organization" /> Organization</span>
            <span><i className="legend-place" /> Place</span>
            <span><i className="legend-cluster" /> Grouped point</span>
          </div>
          <p className="coverage-map-method">Markers use coordinates from the released YouNew dataset. The empty areas reflect current content coverage; they do not mean services or places are absent.</p>
        </section>

        <aside className="coverage-map-selection" id="map-selection" aria-live="polite">
          {activeCluster ? (
            <>
              <p className="coverage-map-selection-label">Selected point</p>
              <h2>{activeCluster.items.length === 1 ? activeCluster.items[0].title : `${activeCluster.items.length} nearby records`}</h2>
              <div className="coverage-map-preview-list">
                {activeCluster.items.slice(0, 6).map((item) => (
                  <Link href={item.route} key={item.id}>
                    <ItemIcon type={item.type} />
                    <span><small>{typeLabels[item.type]}{item.cityId ? ` · ${humanizeMapSlug(item.cityId)}` : ""}</small><strong>{item.title}</strong></span>
                    <ExternalLink aria-hidden />
                  </Link>
                ))}
              </div>
              {activeCluster.items.length > 6 ? <p>{activeCluster.items.length - 6} more record{activeCluster.items.length - 6 === 1 ? " is" : "s are"} included in the accessible list below.</p> : null}
              <a className="text-link coverage-map-jump" href="#map-results">See the complete filtered list</a>
            </>
          ) : (
            <div className="coverage-map-selection-empty">
              <MapPin aria-hidden />
              <h2>Select a marker</h2>
              <p>A marker can represent one record or a group of records with nearby or identical coordinates.</p>
              <p>The complete list below is always the primary accessible fallback.</p>
            </div>
          )}
        </aside>
      </div>

      <section className="coverage-map-results" id="map-results" aria-labelledby="map-results-title">
        <div className="coverage-map-results-heading">
          <div><h2 id="map-results-title">Released content list</h2><p>Every visible record has a released detail page and a source-check date.</p></div>
          <strong>{filteredItems.length} result{filteredItems.length === 1 ? "" : "s"}</strong>
        </div>
        {filteredItems.length ? (
          <ol>
            {filteredItems.map((item) => (
              <li key={item.id}>
                <Link href={item.route}>
                  <ItemIcon type={item.type} />
                  <span>
                    <small>{typeLabels[item.type]}{item.cityId ? ` · ${humanizeMapSlug(item.cityId)}` : ""}</small>
                    <strong>{item.title}</strong>
                    <em><ShieldCheck aria-hidden /> Source checked {item.verifiedAt}</em>
                  </span>
                  <ExternalLink aria-hidden />
                </Link>
              </li>
            ))}
          </ol>
        ) : (
          <div className="coverage-map-empty"><MapPin aria-hidden /><p>No released records match these filters.</p><button className="button button-outline" type="button" onClick={() => setFilters(initialFilters)}>Clear filters</button></div>
        )}
      </section>
    </div>
  );
}
