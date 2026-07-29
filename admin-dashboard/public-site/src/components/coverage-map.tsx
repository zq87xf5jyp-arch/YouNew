/* eslint-disable @next/next/no-img-element */
"use client";

import Link from "next/link";
import {
  Building2,
  ExternalLink,
  List,
  LocateFixed,
  Map as MapIcon,
  MapPin,
  Navigation,
  RotateCcw,
  Search,
  ShieldCheck,
  ZoomIn,
  ZoomOut
} from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import {
  clusterCoverageMapItems,
  coverageMapViewport,
  filterCoverageMapItems,
  humanizeMapSlug,
  netherlandsCoverageBounds,
  projectCoverageCoordinate,
  type CoverageMapCluster,
  type CoverageMapEntityType,
  type CoverageMapFilters,
  type CoverageMapItem
} from "@/lib/map/coverage";
import { optimizedPublicImageUrl } from "@/lib/media/image-url";
import {
  netherlandsProvinceShapes,
  type NetherlandsProvinceShape,
  type ProvinceCoordinate
} from "@/lib/map/netherlands-provinces";

const initialFilters: CoverageMapFilters = {
  city: "all",
  category: "all",
  type: "all",
  query: ""
};
const mapCenter = {
  x: coverageMapViewport.width / 2,
  y: coverageMapViewport.height / 2
};
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
  return `${cluster.items.length} published items at nearby or identical coordinates`;
}

function ItemIcon({ type }: { type: CoverageMapEntityType }) {
  const Icon = type === "city" ? Navigation : type === "organization" ? Building2 : MapPin;
  return <Icon aria-hidden />;
}

function projectProvinceCoordinate([longitude, latitude]: ProvinceCoordinate) {
  return projectCoverageCoordinate({ longitude, latitude }, netherlandsCoverageBounds);
}

function provincePath(shape: NetherlandsProvinceShape): string {
  return shape.polygons
    .flatMap((polygon) => polygon.map((ring) => ring
      .map((coordinate, index) => {
        const point = projectProvinceCoordinate(coordinate);
        return `${index === 0 ? "M" : "L"}${point.x.toFixed(1)} ${point.y.toFixed(1)}`;
      })
      .concat("Z")
      .join(" ")))
    .join(" ");
}

function provinceLabelPoint(shape: NetherlandsProvinceShape) {
  const points = shape.polygons.flatMap((polygon) => polygon[0] ?? []).map(projectProvinceCoordinate);
  if (points.length === 0) return mapCenter;
  const minX = Math.min(...points.map((point) => point.x));
  const maxX = Math.max(...points.map((point) => point.x));
  const minY = Math.min(...points.map((point) => point.y));
  const maxY = Math.max(...points.map((point) => point.y));
  return { x: (minX + maxX) / 2, y: (minY + maxY) / 2 };
}

function mapViewBox(zoom: number, focus: Readonly<{ x: number; y: number }>) {
  const width = coverageMapViewport.width / zoom;
  const height = coverageMapViewport.height / zoom;
  const x = Math.min(coverageMapViewport.width - width, Math.max(0, focus.x - width / 2));
  const y = Math.min(coverageMapViewport.height - height, Math.max(0, focus.y - height / 2));
  return `${x} ${y} ${width} ${height}`;
}

function MapImage({ item }: { item: CoverageMapItem }) {
  if (!item.image) return null;
  return (
    <figure className="coverage-map-selected-media">
      <img alt={item.image.alt} loading="lazy" src={optimizedPublicImageUrl(item.image.url, 720)} />
      {item.image.attribution || item.image.license ? (
        <figcaption>
          {item.image.attribution ? <span>{item.image.attribution}</span> : null}
          {item.image.licenseUrl && item.image.license
            ? <a href={item.image.licenseUrl} rel="noreferrer" target="_blank">{item.image.license}</a>
            : item.image.license ? <span>{item.image.license}</span> : null}
          {item.image.sourcePageUrl ? <a href={item.image.sourcePageUrl} rel="noreferrer" target="_blank">Source</a> : null}
        </figcaption>
      ) : null}
    </figure>
  );
}

export function CoverageMap({ items }: { items: readonly CoverageMapItem[] }) {
  const [filters, setFilters] = useState<CoverageMapFilters>(initialFilters);
  const [queryReady, setQueryReady] = useState(false);
  const [activeClusterId, setActiveClusterId] = useState<string | null>(null);
  const [zoom, setZoom] = useState(1);
  const [focus, setFocus] = useState(mapCenter);
  const [viewMode, setViewMode] = useState<"map" | "list">("map");

  const options = useMemo(() => ({
    cities: [...new Set(items.map((item) => item.cityId).filter((value): value is string => Boolean(value)))].sort(),
    categories: [...new Set(items.flatMap((item) => [...item.categorySlugs]))].sort()
  }), [items]);

  const provinceGeometry = useMemo(() => netherlandsProvinceShapes.map((shape) => ({
    id: shape.id,
    name: shape.name,
    path: provincePath(shape),
    label: provinceLabelPoint(shape)
  })), []);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const city = params.get("city") ?? "all";
    const category = params.get("category") ?? "all";
    const type = params.get("type") ?? "all";
    setFilters({
      city: city === "all" || options.cities.includes(city) ? city : "all",
      category: category === "all" || options.categories.includes(category) ? category : "all",
      type: type === "city" || type === "organization" || type === "place" ? type : "all",
      query: params.get("q") ?? ""
    });
    setQueryReady(true);
  }, [options]);

  useEffect(() => {
    if (!queryReady) return;
    const params = new URLSearchParams();
    if (filters.city !== "all") params.set("city", filters.city);
    if (filters.category !== "all") params.set("category", filters.category);
    if (filters.type !== "all") params.set("type", filters.type);
    if (filters.query.trim()) params.set("q", filters.query.trim());
    window.history.replaceState(null, "", `${window.location.pathname}${params.size ? `?${params}` : ""}`);
    setActiveClusterId(null);
  }, [filters, queryReady]);

  const filteredItems = useMemo(() => filterCoverageMapItems(items, filters), [filters, items]);
  const clusters = useMemo(
    () => clusterCoverageMapItems(filteredItems, netherlandsCoverageBounds, 28 / zoom),
    [filteredItems, zoom]
  );
  const activeCluster = clusters.find((cluster) => cluster.id === activeClusterId) ?? null;
  const activeItem = activeCluster?.items[0] ?? null;
  const hasFilters = filters.city !== "all"
    || filters.category !== "all"
    || filters.type !== "all"
    || Boolean(filters.query.trim());
  const cityLabels = useMemo(
    () => filteredItems
      .filter((item) => item.type === "city")
      .map((item) => ({ ...item, point: projectCoverageCoordinate(item.coordinate, netherlandsCoverageBounds) })),
    [filteredItems]
  );

  function updateFilter<Key extends keyof CoverageMapFilters>(key: Key, value: CoverageMapFilters[Key]) {
    setFilters((current) => ({ ...current, [key]: value }));
  }

  function resetMapView() {
    setZoom(1);
    setFocus(mapCenter);
  }

  function activateCluster(cluster: CoverageMapCluster) {
    setActiveClusterId(cluster.id);
    setFocus({ x: cluster.x, y: cluster.y });
    setZoom((current) => Math.max(current, 1.7));
  }

  function updateZoom(next: number) {
    setZoom(Math.min(2.8, Math.max(1, Number(next.toFixed(2)))));
  }

  return (
    <div className="coverage-map-experience">
      <form className="coverage-map-filters" onSubmit={(event) => event.preventDefault()} aria-label="Map filters">
        <div className="coverage-map-filter-heading">
          <strong>Filter published coverage</strong>
          <span>Selections are kept in the page URL.</span>
        </div>
        <label>
          City
          <select disabled={!queryReady} value={filters.city} onChange={(event) => updateFilter("city", event.target.value)}>
            <option value="all">All published cities</option>
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
            <option value="all">All published categories</option>
            {options.categories.map((category) => <option value={category} key={category}>{humanizeMapSlug(category)}</option>)}
          </select>
        </label>
        <label className="coverage-map-search">
          Search map
          <span><Search aria-hidden /><input disabled={!queryReady} type="search" value={filters.query} onChange={(event) => updateFilter("query", event.target.value)} placeholder="City, place or organization" /></span>
        </label>
        <button className="coverage-map-reset" type="button" disabled={!queryReady || !hasFilters} onClick={() => setFilters(initialFilters)}>
          <RotateCcw aria-hidden /> Reset
        </button>
        <output className="coverage-map-filter-result" aria-live="polite">
          <span>Results</span><strong>{filteredItems.length}</strong>
        </output>
        <noscript><p className="coverage-map-noscript">Map filters and marker previews require JavaScript. The complete published-content list remains available below.</p></noscript>
      </form>

      <div className="coverage-map-layout">
        <section className="coverage-map-canvas" aria-labelledby="coverage-map-title">
          <div className="coverage-map-heading">
            <div>
              <h2 id="coverage-map-title">Published YouNew coverage</h2>
              <p>Geographic overview based on the official 2026 province boundaries.</p>
            </div>
            <div className="coverage-map-view-switch" aria-label="Coverage view">
              <button className={viewMode === "map" ? "is-active" : ""} type="button" aria-pressed={viewMode === "map"} onClick={() => setViewMode("map")}><MapIcon aria-hidden /> Map</button>
              <button className={viewMode === "list" ? "is-active" : ""} type="button" aria-pressed={viewMode === "list"} onClick={() => setViewMode("list")}><List aria-hidden /> List</button>
            </div>
          </div>

          {viewMode === "map" && filteredItems.length ? (
            <div className="coverage-map-stage">
              <svg
                className="coverage-map-svg"
                viewBox={mapViewBox(zoom, focus)}
                role="group"
                aria-roledescription="geographic coverage map"
                aria-labelledby="coverage-map-svg-title coverage-map-svg-description"
              >
                <title id="coverage-map-svg-title">Published YouNew city, place and organization coordinates in the Netherlands</title>
                <desc id="coverage-map-svg-description">Select a marker to preview its published items. Nearby and identical coordinates are grouped. Province boundaries come from PDOK.</desc>
                <rect className="coverage-map-water" x="0" y="0" width={coverageMapViewport.width} height={coverageMapViewport.height} />
                <g className="coverage-map-provinces" aria-hidden>
                  {provinceGeometry.map((province) => (
                    <path d={province.path} data-province={province.name} fillRule="evenodd" key={province.id} />
                  ))}
                  {provinceGeometry.map((province) => (
                    <text x={province.label.x} y={province.label.y} textAnchor="middle" key={`${province.id}-label`}>{province.name}</text>
                  ))}
                </g>
                {cityLabels.map((city) => (
                  <text className="coverage-map-city-label" x={city.point.x + 13} y={city.point.y - 11} key={`${city.id}-label`}>{city.title}</text>
                ))}
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
                      transform={`translate(${cluster.x} ${cluster.y}) scale(${1 / zoom})`}
                    >
                      <circle className="coverage-map-marker-hit" r="25" />
                      <circle className="coverage-map-marker-dot" r={count > 1 ? Math.min(19, 12 + Math.log2(count) * 1.6) : 9} />
                      {count > 1 ? <text y="4" textAnchor="middle">{count}</text> : null}
                    </g>
                  );
                })}
              </svg>
              <div className="coverage-map-zoom-controls" aria-label="Map zoom controls">
                <button type="button" aria-label="Zoom in" disabled={zoom >= 2.8} onClick={() => updateZoom(zoom + 0.35)}><ZoomIn aria-hidden /></button>
                <button type="button" aria-label="Zoom out" disabled={zoom <= 1} onClick={() => updateZoom(zoom - 0.35)}><ZoomOut aria-hidden /></button>
                <button type="button" aria-label="Reset map position and zoom" disabled={zoom === 1 && focus.x === mapCenter.x && focus.y === mapCenter.y} onClick={resetMapView}><LocateFixed aria-hidden /></button>
              </div>
            </div>
          ) : viewMode === "list" && filteredItems.length ? (
            <ol className="coverage-map-canvas-list">
              {filteredItems.slice(0, 18).map((item) => (
                <li key={item.id}>
                  <Link href={item.route}>
                    {item.image ? <img alt="" loading="lazy" src={optimizedPublicImageUrl(item.image.url, 360)} /> : <span className="coverage-map-list-icon"><ItemIcon type={item.type} /></span>}
                    <span><small>{typeLabels[item.type]}{item.cityId ? ` · ${humanizeMapSlug(item.cityId)}` : ""}</small><strong>{item.title}</strong></span>
                    <ExternalLink aria-hidden />
                  </Link>
                </li>
              ))}
            </ol>
          ) : (
            <div className="coverage-map-empty"><MapPin aria-hidden /><p>No published items match these filters.</p><button className="button button-outline" type="button" onClick={() => setFilters(initialFilters)}>Clear filters</button></div>
          )}

          <div className="coverage-map-legend" aria-label="Map legend">
            <span><i className="legend-city" /> City</span>
            <span><i className="legend-organization" /> Organization</span>
            <span><i className="legend-place" /> Place</span>
            <span><i className="legend-cluster" /> Grouped point</span>
          </div>
          <p className="coverage-map-method">Markers use coordinates from published YouNew content. Province geometry is derived from <a href="https://www.pdok.nl/introductie/-/article/bestuurlijke-gebieden" rel="noreferrer" target="_blank">Kadaster/PDOK Bestuurlijke Gebieden 2026</a> (CC BY 4.0). Empty areas show current editorial coverage, not the absence of services.</p>
        </section>

        <aside className="coverage-map-selection" id="map-selection" aria-live="polite">
          {activeCluster && activeItem ? (
            <>
              {activeCluster.items.length === 1 ? <MapImage item={activeItem} /> : null}
              <p className="coverage-map-selection-label">Selected point</p>
              <h2>{activeCluster.items.length === 1 ? activeItem.title : `${activeCluster.items.length} nearby records`}</h2>
              {activeCluster.items.length === 1 ? (
                <>
                  <p>{activeItem.summary}</p>
                  <dl className="coverage-map-selected-facts">
                    <div><dt>Type</dt><dd>{typeLabels[activeItem.type]}</dd></div>
                    {activeItem.cityId ? <div><dt>City</dt><dd>{humanizeMapSlug(activeItem.cityId)}</dd></div> : null}
                    <div><dt>Source</dt><dd>{activeItem.sourcePublisher}</dd></div>
                    <div><dt>Checked</dt><dd>{activeItem.verifiedAt}</dd></div>
                  </dl>
                  <Link className="button button-primary coverage-map-open-record" href={activeItem.route}>Open record <ExternalLink aria-hidden /></Link>
                </>
              ) : (
                <>
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
              )}
            </>
          ) : (
            <div className="coverage-map-selection-empty">
              <MapPin aria-hidden />
              <h2>Select a marker</h2>
              <p>Choose a cluster or individual point to see its image, source information and published record.</p>
              <p>The complete list below remains the primary accessible fallback.</p>
            </div>
          )}
        </aside>
      </div>

      <section className="coverage-map-results" id="map-results" aria-labelledby="map-results-title">
        <div className="coverage-map-results-heading">
          <div><h2 id="map-results-title">Published content list</h2><p>Every visible item has a published detail page and a source-check date.</p></div>
          <strong>{filteredItems.length} result{filteredItems.length === 1 ? "" : "s"}</strong>
        </div>
        {filteredItems.length ? (
          <ol>
            {filteredItems.map((item) => (
              <li key={item.id}>
                <Link href={item.route}>
                  {item.image ? <img alt="" loading="lazy" src={optimizedPublicImageUrl(item.image.url, 220)} /> : <ItemIcon type={item.type} />}
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
          <div className="coverage-map-empty"><MapPin aria-hidden /><p>No published items match these filters.</p><button className="button button-outline" type="button" onClick={() => setFilters(initialFilters)}>Clear filters</button></div>
        )}
      </section>
    </div>
  );
}
