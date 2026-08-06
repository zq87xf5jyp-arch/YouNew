import { Breadcrumbs } from "@/components/breadcrumbs";
import { JourneyExplorer } from "@/components/journey-explorer";
import { PageShell } from "@/components/page-shell";
import { getContentEntityById, type PublicMediaAsset } from "@/lib/content";
import { practicalJourneys } from "@/lib/journeys/definitions";
import { getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Practical journeys",
  "Follow source-checked YouNew guide paths and keep private progress locally in your browser.",
  "/journeys"
);

export default function JourneysPage() {
  const nationalGuideById = new Map(getNationalGuides().map((guide) => [guide.id, guide]));
  const nationalVerifiedAt = nationalGuidesVerifiedAt();
  const journeys = practicalJourneys.map((journey) => ({
    ...journey,
    guides: journey.guideIds.reduce<Array<{
      id: string;
      title: string;
      summary: string;
      route: string;
      verifiedAt: string;
      image: PublicMediaAsset | null;
    }>>((guides, guideId) => {
      const nationalGuide = nationalGuideById.get(guideId);
      if (nationalGuide) {
        guides.push({
          id: nationalGuide.id,
          title: nationalGuide.title,
          summary: nationalGuide.summary,
          route: `/essentials/${nationalGuide.slug}/`,
          verifiedAt: nationalVerifiedAt,
          image: null
        });
        return guides;
      }
      const guide = getContentEntityById(guideId);
      if (guide?.type === "guide") guides.push({
          id: guide.id,
          title: guide.title,
          summary: guide.summary,
          route: guide.route,
          verifiedAt: guide.verifiedAt,
          image: guide.images.find((image) => image.role === "hero") ?? guide.images[0] ?? null
        });
      return guides;
    }, [])
  }));

  return (
    <PageShell className="web-app-page">
      <section className="app-hero section-shell journey-hero">
        <Breadcrumbs items={[{ label: "Discover", href: "/discover" }, { label: "Journeys" }]} />
        <p className="section-label orange">Practical journeys</p>
        <h1>Move through national guidance, one verified starting point at a time.</h1>
        <p>Choose a situation, follow a suggested reading order, and keep private progress in this browser. Exact requirements can still vary by municipality and personal circumstances.</p>
      </section>
      <section className="section-shell journey-section" aria-label="YouNew journeys"><JourneyExplorer journeys={journeys} /></section>
    </PageShell>
  );
}
