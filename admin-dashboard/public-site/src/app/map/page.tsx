import { MapPinned } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { CoverageMap } from "@/components/coverage-map";
import { PageShell } from "@/components/page-shell";
import { getContentEntities } from "@/lib/content";
import { publicWebSummary } from "@/lib/content/presentation";
import { getMunicipalities } from "@/lib/geography";
import type { CoverageMapEntityType, CoverageMapItem } from "@/lib/map/coverage";
import { metadataForPage } from "@/lib/seo/metadata";

const description = "Explore published YouNew content together with all 342 official Dutch municipalities, using source-backed filters and a complete accessible list.";
const supportedTypes = new Set<CoverageMapEntityType>(["city", "organization", "place"]);

export const metadata = metadataForPage("Published coverage map", description, "/map");

function getPublishedMapItems(): CoverageMapItem[] {
  return getContentEntities().flatMap((entity) => {
    if (entity.status !== "published" || !supportedTypes.has(entity.type as CoverageMapEntityType) || !entity.coordinate) return [];
    return [{
      id: entity.id,
      title: entity.title,
      summary: publicWebSummary(entity.summary),
      route: entity.route,
      type: entity.type as CoverageMapEntityType,
      cityId: entity.cityId,
      provinceId: entity.provinceId,
      categorySlugs: entity.categorySlugs,
      coordinate: entity.coordinate,
      verifiedAt: entity.verifiedAt,
      sourcePublisher: entity.source.publisher,
      image: entity.images.find((image) => image.role === "thumbnail")
        ?? entity.images.find((image) => image.role === "hero")
        ?? entity.images[0]
        ?? null
    }];
  }).sort((left, right) => left.title.localeCompare(right.title));
}

function getMunicipalityMapItems(): CoverageMapItem[] {
  return getMunicipalities().flatMap((municipality) => municipality.coordinate ? [{
    id: `municipality.${municipality.code.toLocaleLowerCase("en")}`,
    title: municipality.name,
    summary: `Official 2026 municipality directory entry in ${municipality.provinceName}, with ${municipality.settlements.length} BAG settlement${municipality.settlements.length === 1 ? "" : "s"}.`,
    route: `/municipalities/${municipality.slug}`,
    type: "municipality" as const,
    cityId: municipality.slug,
    provinceId: municipality.provinceSlug,
    categorySlugs: [],
    coordinate: municipality.coordinate,
    verifiedAt: municipality.sourceCheckedAt ?? "2026-01-01",
    sourcePublisher: "CBS · Kadaster/PDOK · Register of Government Organisations",
    image: null
  }] : []);
}

export default function MapPage() {
  const publishedItems = getPublishedMapItems();
  const municipalityItems = getMunicipalityMapItems();
  const items = [...publishedItems, ...municipalityItems];
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero coverage-map-hero">
        <Breadcrumbs items={[{ label: "Map" }]} />
        <MapPinned className="hero-line-icon" aria-hidden />
        <h1>See where published YouNew content is located.</h1>
        <p>{description}</p>
        <div className="dataset-note"><strong>{publishedItems.length}</strong> published content items · <strong>{municipalityItems.length}</strong> municipalities · no location permission or third-party map requests</div>
      </section>
      <section className="section-shell app-content-block">
        <CoverageMap items={items} />
      </section>
    </PageShell>
  );
}
