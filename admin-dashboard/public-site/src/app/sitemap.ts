import type { MetadataRoute } from "next";
import { getPublicContent } from "@/lib/content";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const updated = new Date("2026-07-20T00:00:00Z");
  const content = getPublicContent();
  const staticPaths = [
    "", "/discover", "/guides", "/journeys", "/map", "/categories", "/cities", "/provinces", "/places", "/organizations",
    "/emergency", "/status", "/app", "/business", "/business/advertise", "/business/partners", "/business/pricing",
    "/business/apply", "/business/media-kit", "/privacy", "/terms", "/support"
  ];
  const staticEntries: MetadataRoute.Sitemap = staticPaths.map((path) => ({
    url: path ? `https://younew.nl${path}/` : "https://younew.nl/",
    lastModified: updated,
    changeFrequency: path === "" ? "weekly" : "monthly",
    priority: path === "" ? 1 : 0.7
  }));
  const entityEntries: MetadataRoute.Sitemap = content.entities.map((entity) => ({
    url: `https://younew.nl${entity.route}/`,
    lastModified: new Date(`${entity.updatedAt}T00:00:00Z`),
    changeFrequency: "monthly",
    priority: entity.type === "city" || entity.type === "guide" ? 0.8 : 0.65
  }));
  const aggregateEntries: MetadataRoute.Sitemap = [...content.categories, ...content.provinces].map((entry) => ({
    url: `https://younew.nl${entry.route}/`,
    lastModified: updated,
    changeFrequency: "weekly",
    priority: 0.75
  }));
  return [...staticEntries, ...aggregateEntries, ...entityEntries];
}
