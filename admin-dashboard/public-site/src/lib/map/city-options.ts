import { cityDisplayName } from "../search/geography.ts";
import { humanizeMapSlug, type CoverageMapItem } from "./coverage.ts";

/** Keep canonical IDs intact; a venue title is never a city label. */
export function coverageCityOptions(items: readonly Pick<CoverageMapItem, "cityId" | "type" | "title">[]) {
  const labels = new Map<string, { label: string; priority: number }>();
  for (const item of items) {
    if (!item.cityId) continue;
    const priority = item.type === "city" ? 2 : item.type === "municipality" ? 1 : 0;
    const fallback = priority ? item.title : humanizeMapSlug(item.cityId);
    const label = cityDisplayName(item.cityId, fallback);
    const current = labels.get(item.cityId);
    if (!current || priority > current.priority ||
        (priority === current.priority && label.localeCompare(current.label, "nl") < 0)) {
      labels.set(item.cityId, { label, priority });
    }
  }
  return [...labels].map(([id, { label }]) => ({ id, label }))
    .sort((a, b) => a.label.localeCompare(b.label, "nl") || a.id.localeCompare(b.id));
}
