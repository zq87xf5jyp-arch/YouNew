import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const SOURCE_URL =
  "https://api.pdok.nl/kadaster/brk-bestuurlijke-gebieden/ogc/v1/collections/provinciegebied/items?f=json&limit=20";
const OUTPUT_PATH = resolve("src/lib/map/netherlands-provinces.ts");
const SIMPLIFY_TOLERANCE = 0.0065;

function squaredDistance(left, right) {
  const x = left[0] - right[0];
  const y = left[1] - right[1];
  return x * x + y * y;
}

function squaredSegmentDistance(point, start, end) {
  let x = start[0];
  let y = start[1];
  let dx = end[0] - x;
  let dy = end[1] - y;

  if (dx !== 0 || dy !== 0) {
    const projection = ((point[0] - x) * dx + (point[1] - y) * dy) / (dx * dx + dy * dy);
    if (projection > 1) {
      x = end[0];
      y = end[1];
    } else if (projection > 0) {
      x += dx * projection;
      y += dy * projection;
    }
  }

  dx = point[0] - x;
  dy = point[1] - y;
  return dx * dx + dy * dy;
}

function simplifyRadial(points, squaredTolerance) {
  let previous = points[0];
  const simplified = [previous];

  for (let index = 1; index < points.length; index += 1) {
    const point = points[index];
    if (squaredDistance(point, previous) > squaredTolerance) {
      simplified.push(point);
      previous = point;
    }
  }

  if (previous !== points.at(-1)) simplified.push(points.at(-1));
  return simplified;
}

function simplifyDouglasPeucker(points, squaredTolerance) {
  const markers = new Uint8Array(points.length);
  const stack = [0, points.length - 1];
  markers[0] = 1;
  markers[points.length - 1] = 1;

  while (stack.length) {
    const last = stack.pop();
    const first = stack.pop();
    let maxDistance = 0;
    let index = 0;

    for (let cursor = first + 1; cursor < last; cursor += 1) {
      const distance = squaredSegmentDistance(points[cursor], points[first], points[last]);
      if (distance > maxDistance) {
        index = cursor;
        maxDistance = distance;
      }
    }

    if (maxDistance > squaredTolerance) {
      markers[index] = 1;
      stack.push(first, index, index, last);
    }
  }

  return points.filter((_, index) => markers[index]);
}

function simplifyRing(ring) {
  if (ring.length <= 4) return ring;
  const wasClosed = squaredDistance(ring[0], ring.at(-1)) < Number.EPSILON;
  const openRing = wasClosed ? ring.slice(0, -1) : ring;
  const squaredTolerance = SIMPLIFY_TOLERANCE * SIMPLIFY_TOLERANCE;
  const radial = simplifyRadial(openRing, squaredTolerance);
  const simplified = simplifyDouglasPeucker(radial, squaredTolerance);
  if (simplified.length < 3) return [];
  const rounded = simplified.map(([longitude, latitude]) => [
    Number(longitude.toFixed(5)),
    Number(latitude.toFixed(5))
  ]);
  return [...rounded, rounded[0]];
}

function ringArea(ring) {
  let area = 0;
  for (let index = 0; index < ring.length - 1; index += 1) {
    area += ring[index][0] * ring[index + 1][1] - ring[index + 1][0] * ring[index][1];
  }
  return Math.abs(area / 2);
}

function simplifyGeometry(geometry) {
  const polygons = geometry.type === "Polygon" ? [geometry.coordinates] : geometry.coordinates;
  return polygons
    .map((polygon) => polygon.map(simplifyRing).filter((ring) => ring.length >= 4))
    .filter((polygon) => polygon.length > 0 && ringArea(polygon[0]) > 0.00001);
}

const response = await fetch(SOURCE_URL, {
  headers: { Accept: "application/geo+json, application/json" }
});
if (!response.ok) throw new Error(`PDOK geometry request failed: ${response.status}`);

const collection = await response.json();
const shapes = collection.features
  .map((feature) => ({
    id: feature.properties.identificatie,
    name: feature.properties.naam,
    polygons: simplifyGeometry(feature.geometry)
  }))
  .sort((left, right) => left.name.localeCompare(right.name));

const generated = `// Generated from PDOK Bestuurlijke Gebieden 2026 (${SOURCE_URL}).
// Source: Kadaster/PDOK, CC BY 4.0. Regenerate with pnpm exec node scripts/generate-map-geometry.mjs.
export type ProvinceCoordinate = readonly [longitude: number, latitude: number];
export type NetherlandsProvinceShape = Readonly<{
  id: string;
  name: string;
  polygons: readonly (readonly (readonly ProvinceCoordinate[])[])[];
}>;

export const netherlandsProvinceShapes = ${JSON.stringify(shapes)} as const satisfies readonly NetherlandsProvinceShape[];
`;

await writeFile(OUTPUT_PATH, generated);
console.log(`Wrote ${shapes.length} province shapes to ${OUTPUT_PATH}`);
