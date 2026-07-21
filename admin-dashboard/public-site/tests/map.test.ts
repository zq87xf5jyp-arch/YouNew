import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const siteRoot = new URL("../", import.meta.url);
const content = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8"));
const mapModule = await import(new URL("src/lib/map/coverage.ts", siteRoot).href) as {
  clusterCoverageMapItems: (items: MapFixture[], bounds: MapBounds, collisionDistance?: number) => Array<{ id: string; items: MapFixture[] }>;
  filterCoverageMapItems: (items: MapFixture[], filters: { city: string; category: string; type: string }) => MapFixture[];
  getCoverageMapBounds: (items: MapFixture[], focused: boolean) => MapBounds;
  netherlandsCoverageBounds: MapBounds;
};

type MapBounds = { minLatitude: number; maxLatitude: number; minLongitude: number; maxLongitude: number };
type MapFixture = {
  id: string;
  title: string;
  route: string;
  type: "city" | "organization" | "place";
  cityId: string | null;
  categorySlugs: string[];
  coordinate: { latitude: number; longitude: number };
  verifiedAt: string;
};

const allowedTypes = new Set(["city", "organization", "place"]);
const mapItems: MapFixture[] = content.entities
  .filter((entity: { type: string; status: string; coordinate: unknown }) =>
    allowedTypes.has(entity.type) && entity.status === "published" && Boolean(entity.coordinate)
  )
  .map((entity: {
    id: string; title: string; route: string; type: MapFixture["type"];
    cityId: string | null; categorySlugs: string[]; coordinate: MapFixture["coordinate"];
    verifiedAt: string;
  }) => ({
    id: entity.id, title: entity.title, route: entity.route, type: entity.type,
    cityId: entity.cityId, categorySlugs: entity.categorySlugs, coordinate: entity.coordinate,
    verifiedAt: entity.verifiedAt
  }));

function fixture(id: string, latitude: number, longitude: number): MapFixture {
  return {
    id,
    title: id,
    route: `/places/${id}`,
    type: "place",
    cityId: "amsterdam",
    categorySlugs: ["transport"],
    coordinate: { latitude, longitude },
    verifiedAt: "2026-07-20"
  };
}

test("map input includes only published coordinate-backed cities, organizations and places", () => {
  const expected = content.entities.filter((entity: { type: string; status: string; coordinate: unknown }) =>
    allowedTypes.has(entity.type) && entity.status === "published" && Boolean(entity.coordinate)
  );
  assert.equal(mapItems.length, expected.length);
  assert.ok(mapItems.length > 0);
  assert.ok(mapItems.every((item) => allowedTypes.has(item.type)));
  assert.ok(mapItems.every((item) => Number.isFinite(item.coordinate.latitude) && Number.isFinite(item.coordinate.longitude)));
  assert.ok(mapItems.every((item) => !item.route.startsWith("/guides/")));
});

test("map filters combine city, content type and category", () => {
  const filtered = mapModule.filterCoverageMapItems(mapItems, {
    city: "amsterdam",
    type: "organization",
    category: "healthcare"
  });
  assert.ok(filtered.length > 0);
  assert.ok(filtered.every((item) =>
    item.cityId === "amsterdam" && item.type === "organization" && item.categorySlugs.includes("healthcare")
  ));
});

test("identical coordinates are grouped deterministically", () => {
  const records = [
    fixture("third", 52.3676, 4.9041),
    fixture("first", 52.3676, 4.9041),
    fixture("second", 52.3676, 4.9041),
    fixture("separate", 51.92, 4.48)
  ];
  const bounds = mapModule.getCoverageMapBounds(records, false);
  const forward = mapModule.clusterCoverageMapItems(records, bounds, 1);
  const reversed = mapModule.clusterCoverageMapItems([...records].reverse(), bounds, 1);
  assert.equal(forward.length, 2);
  assert.deepEqual(
    forward.map((cluster) => cluster.items.map((item) => item.id)),
    reversed.map((cluster) => cluster.items.map((item) => item.id))
  );
  assert.deepEqual(forward.find((cluster) => cluster.items.length === 3)?.items.map((item) => item.id), ["first", "second", "third"]);
});

test("the default view uses the fixed national extent and the focused view fits local results", () => {
  assert.deepEqual(mapModule.getCoverageMapBounds(mapItems, false), mapModule.netherlandsCoverageBounds);
  const local = [fixture("one", 52.36, 4.89), fixture("two", 52.38, 4.92)];
  const focused = mapModule.getCoverageMapBounds(local, true);
  assert.ok(focused.minLatitude < 52.36 && focused.maxLatitude > 52.38);
  assert.ok(focused.minLongitude < 4.89 && focused.maxLongitude > 4.92);
});

test("map implementation is dependency-free, has a no-JavaScript list and print rules", async () => {
  const component = await readFile(new URL("src/components/coverage-map.tsx", siteRoot), "utf8");
  const styles = await readFile(new URL("src/app/globals.css", siteRoot), "utf8");
  assert.match(component, /<noscript>/);
  assert.match(component, /complete released-content list/i);
  assert.match(component, /id="map-results"/);
  assert.doesNotMatch(component, /fetch\(|navigator\.geolocation|maplibre|leaflet|openstreetmap/i);
  assert.match(styles, /@media print[\s\S]*\.coverage-map-layout/);
});
