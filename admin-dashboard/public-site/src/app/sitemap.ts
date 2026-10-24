import type { MetadataRoute } from "next";
import { getPublicContent } from "@/lib/content";
import { getGeographyProvinces, getMunicipalities } from "@/lib/geography";
import { getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";
import { cityGuides } from "@/content/city-guides";
import { getLifeDomain } from "@/lib/search/taxonomy";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const content = getPublicContent();
  const updated = new Date(content.generatedAt);
  const staticPaths = [
    "", "/start", "/discover", "/guides", "/journeys", "/map", "/categories", "/cities", "/municipalities", "/provinces", "/places", "/updates",
    "/emergency", "/status", "/app", "/for-business", "/for-business/local", "/for-business/pilot", "/for-business/demo-report",
    "/partners", "/partners/apply", "/privacy", "/terms", "/support", "/arrival-planner"
  ].concat(content.organizations.length ? ["/organizations"] : []);
  const staticEntries: MetadataRoute.Sitemap = staticPaths.map((path) => ({
    url: path ? `https://younew.nl${path}/` : "https://younew.nl/",
    lastModified: updated,
    changeFrequency: path === "" ? "weekly" : "monthly",
    priority: path === "" ? 1 : 0.7
  }));
  const entityEntries: MetadataRoute.Sitemap = content.entities.filter((entity) => entity.indexable).map((entity) => ({
    url: `https://younew.nl${entity.route}/`,
    lastModified: new Date(`${entity.updatedAt}T00:00:00Z`),
    changeFrequency: "monthly",
    priority: entity.type === "city" || entity.type === "guide" ? 0.8 : 0.65
  }));
  const indexableCategories = content.categories.filter((category) => category.entityCount > 0 || getLifeDomain(category.slug));
  const aggregateEntries: MetadataRoute.Sitemap = [...indexableCategories, ...getGeographyProvinces()].map((entry) => ({
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
  const dutchStaticPaths = ["/nl", "/nl/zoeken", "/nl/categorieen", "/nl/voor-bedrijven", "/nl/voor-bedrijven/lokaal"]
    .concat(content.organizations.length ? ["/nl/organisaties"] : []);
  const dutchStaticEntries: MetadataRoute.Sitemap = dutchStaticPaths.map((path) => ({
    url: `https://younew.nl${path}/`, lastModified: updated, changeFrequency: "weekly", priority: path === "/nl" ? 0.9 : 0.75
  }));
  const dutchCategoryEntries: MetadataRoute.Sitemap = indexableCategories.map((category) => ({
    url: `https://younew.nl/nl/categorieen/${category.slug}/`, lastModified: updated, changeFrequency: "weekly", priority: 0.72
  }));
  const dutchOrganizationEntries: MetadataRoute.Sitemap = content.organizations.map((entity) => ({
    url: `https://younew.nl/nl/organisaties/${entity.slug}/`, lastModified: new Date(`${entity.updatedAt}T00:00:00Z`), changeFrequency: "monthly", priority: 0.65
  }));
  const cityGuideEntries: MetadataRoute.Sitemap = cityGuides.flatMap((guide) => ([
    { url: `https://younew.nl/city-guides/${guide.slug}/`, lastModified: new Date(`${guide.verifiedAt}T00:00:00Z`), changeFrequency: "monthly" as const, priority: 0.85 },
    { url: `https://younew.nl/nl/stadsgidsen/${guide.slug}/`, lastModified: new Date(`${guide.verifiedAt}T00:00:00Z`), changeFrequency: "monthly" as const, priority: 0.85 }
  ]));
  return [...staticEntries, ...dutchStaticEntries, ...cityGuideEntries, ...dutchCategoryEntries, ...dutchOrganizationEntries, ...nationalGuideEntries, ...aggregateEntries, ...municipalityEntries, ...entityEntries];
}
