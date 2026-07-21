import { MapPinned } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { CoverageMap } from "@/components/coverage-map";
import { PageShell } from "@/components/page-shell";
import { getContentEntities } from "@/lib/content";
import type { CoverageMapEntityType, CoverageMapItem } from "@/lib/map/coverage";
import { metadataForPage } from "@/lib/seo/metadata";

const description = "Explore coordinates for cities, places and organizations in the currently released YouNew dataset, with filters and a complete accessible list.";
const supportedTypes = new Set<CoverageMapEntityType>(["city", "organization", "place"]);

export const metadata = metadataForPage("Published coverage map", description, "/map");

function getPublishedMapItems(): CoverageMapItem[] {
  return getContentEntities().flatMap((entity) => {
    if (entity.status !== "published" || !supportedTypes.has(entity.type as CoverageMapEntityType) || !entity.coordinate) return [];
    return [{
      id: entity.id,
      title: entity.title,
      route: entity.route,
      type: entity.type as CoverageMapEntityType,
      cityId: entity.cityId,
      categorySlugs: entity.categorySlugs,
      coordinate: entity.coordinate,
      verifiedAt: entity.verifiedAt
    }];
  }).sort((left, right) => left.title.localeCompare(right.title));
}

export default function MapPage() {
  const items = getPublishedMapItems();
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero coverage-map-hero">
        <Breadcrumbs items={[{ label: "Map" }]} />
        <MapPinned className="hero-line-icon" aria-hidden />
        <h1>See where released YouNew content is located.</h1>
        <p>{description}</p>
        <div className="dataset-note"><strong>{items.length}</strong> released records with coordinates · no location permission · no third-party map requests</div>
      </section>
      <section className="section-shell app-content-block">
        <CoverageMap items={items} />
      </section>
    </PageShell>
  );
}
