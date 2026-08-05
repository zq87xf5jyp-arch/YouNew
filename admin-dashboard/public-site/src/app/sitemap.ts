import type { MetadataRoute } from "next";
import { getPublicContent } from "@/lib/content";
import { getGeographyProvinces, getMunicipalities } from "@/lib/geography";
import { getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const content = getPublicContent();
  const updated = new Date(content.generatedAt);
  const staticPaths = [
    "", "/start", "/discover", "/guides", "/journeys", "/map", "/categories", "/cities", "/municipalities", "/provinces", "/places", "/organizations", "/updates",
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
  const aggregateEntries: MetadataRoute.Sitemap = [...content.categories, ...getGeographyProvinces()].map((entry) => ({
    url: `https://younew.nl${entry.route}/`,
    lastModified: updated,
    changeFrequency: "weekly",
    priority: 0.75
  }));
  const municipalityEntries: MetadataRoute.Sitemap = getMunicipalities().map((municipality) => ({
    url: `https://younew.nl/municipalities/${municipality.slug}/`,
    lastModified: municipality.sourceCheckedAt ? new Date(`${municipality.sourceCheckedAt}T00:00:00Z`) : updated,
    changeFrequency: "monthly",
    priority: 0.68
  }));
  const nationalGuideEntries: MetadataRoute.Sitemap = getNationalGuides().map((guide) => ({
    url: `https://younew.nl/essentials/${guide.slug}/`,
    lastModified: new Date(`${nationalGuidesVerifiedAt()}T00:00:00Z`),
    changeFrequency: "monthly",
    priority: 0.85
  }));
  return [...staticEntries, ...nationalGuideEntries, ...aggregateEntries, ...municipalityEntries, ...entityEntries];
}
