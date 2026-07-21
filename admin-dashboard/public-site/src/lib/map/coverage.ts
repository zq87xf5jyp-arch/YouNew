export type CoverageMapEntityType = "city" | "organization" | "place";

export interface CoverageMapItem {
  readonly id: string;
  readonly title: string;
  readonly route: string;
  readonly type: CoverageMapEntityType;
  readonly cityId: string | null;
  readonly categorySlugs: readonly string[];
  readonly coordinate: Readonly<{ latitude: number; longitude: number }>;
  readonly verifiedAt: string;
}

export interface CoverageMapFilters {
  readonly city: string;
  readonly category: string;
  readonly type: "all" | CoverageMapEntityType;
}

export interface CoverageMapBounds {
  readonly minLatitude: number;
  readonly maxLatitude: number;
  readonly minLongitude: number;
  readonly maxLongitude: number;
}

export interface CoverageMapCluster {
  readonly id: string;
  readonly x: number;
  readonly y: number;
  readonly items: readonly CoverageMapItem[];
}

export const coverageMapViewport = {
  width: 720,
  height: 760,
  padding: 44
} as const;

// A fixed national extent keeps the default view honest: it shows where the
// released dataset has coverage without implying that every Dutch region is covered.
export const netherlandsCoverageBounds: CoverageMapBounds = {
  minLatitude: 50.70,
  maxLatitude: 53.62,
  minLongitude: 3.15,
  maxLongitude: 7.28
};

export function filterCoverageMapItems(
  items: readonly CoverageMapItem[],
  filters: CoverageMapFilters
): CoverageMapItem[] {
  return items.filter((item) => (
    (filters.city === "all" || item.cityId === filters.city) &&
    (filters.category === "all" || item.categorySlugs.includes(filters.category)) &&
    (filters.type === "all" || item.type === filters.type)
  ));
}

export function getCoverageMapBounds(
  items: readonly CoverageMapItem[],
  focusOnResults: boolean
): CoverageMapBounds {
  if (!focusOnResults || items.length === 0) return netherlandsCoverageBounds;

  const latitudes = items.map((item) => item.coordinate.latitude);
  const longitudes = items.map((item) => item.coordinate.longitude);
  const minLatitude = Math.min(...latitudes);
  const maxLatitude = Math.max(...latitudes);
  const minLongitude = Math.min(...longitudes);
  const maxLongitude = Math.max(...longitudes);
  const latitudeSpan = Math.max(maxLatitude - minLatitude, 0.045);
  const longitudeSpan = Math.max(maxLongitude - minLongitude, 0.06);
  const latitudeMiddle = (minLatitude + maxLatitude) / 2;
  const longitudeMiddle = (minLongitude + maxLongitude) / 2;

  return {
    minLatitude: latitudeMiddle - latitudeSpan * 0.64,
    maxLatitude: latitudeMiddle + latitudeSpan * 0.64,
    minLongitude: longitudeMiddle - longitudeSpan * 0.64,
    maxLongitude: longitudeMiddle + longitudeSpan * 0.64
  };
}

export function projectCoverageCoordinate(
  coordinate: CoverageMapItem["coordinate"],
  bounds: CoverageMapBounds
): { x: number; y: number } {
  const { width, height, padding } = coverageMapViewport;
  const longitudeSpan = Math.max(bounds.maxLongitude - bounds.minLongitude, Number.EPSILON);
  const latitudeSpan = Math.max(bounds.maxLatitude - bounds.minLatitude, Number.EPSILON);
  const xRatio = (coordinate.longitude - bounds.minLongitude) / longitudeSpan;
  const yRatio = (bounds.maxLatitude - coordinate.latitude) / latitudeSpan;

  return {
    x: padding + Math.min(1, Math.max(0, xRatio)) * (width - padding * 2),
    y: padding + Math.min(1, Math.max(0, yRatio)) * (height - padding * 2)
  };
}

export function clusterCoverageMapItems(
  items: readonly CoverageMapItem[],
  bounds: CoverageMapBounds,
  collisionDistance = 28
): CoverageMapCluster[] {
  const clusters: Array<{
    id: string;
    x: number;
    y: number;
    items: CoverageMapItem[];
  }> = [];

  for (const item of [...items].sort((left, right) => left.id.localeCompare(right.id))) {
    const point = projectCoverageCoordinate(item.coordinate, bounds);
    const match = clusters
      .map((cluster) => ({
        cluster,
        distance: Math.hypot(cluster.x - point.x, cluster.y - point.y)
      }))
      .filter(({ distance }) => distance <= collisionDistance)
      .sort((left, right) => left.distance - right.distance || left.cluster.id.localeCompare(right.cluster.id))[0]?.cluster;

    if (!match) {
      clusters.push({ id: item.id, x: point.x, y: point.y, items: [item] });
      continue;
    }

    match.items.push(item);
    match.x = match.items.reduce((sum, member) => sum + projectCoverageCoordinate(member.coordinate, bounds).x, 0) / match.items.length;
    match.y = match.items.reduce((sum, member) => sum + projectCoverageCoordinate(member.coordinate, bounds).y, 0) / match.items.length;
    match.id = match.items.map((member) => member.id).sort().join("+");
  }

  return clusters
    .map((cluster) => ({ ...cluster, items: [...cluster.items].sort((left, right) => left.title.localeCompare(right.title)) }))
    .sort((left, right) => left.y - right.y || left.x - right.x || left.id.localeCompare(right.id));
}

export function humanizeMapSlug(value: string): string {
  return value
    .split("-")
    .filter(Boolean)
    .map((word) => `${word.charAt(0).toUpperCase()}${word.slice(1)}`)
    .join(" ");
}
