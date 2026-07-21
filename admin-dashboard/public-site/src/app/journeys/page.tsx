import { Breadcrumbs } from "@/components/breadcrumbs";
import { JourneyExplorer } from "@/components/journey-explorer";
import { PageShell } from "@/components/page-shell";
import { getContentEntityById } from "@/lib/content";
import { practicalJourneys } from "@/lib/journeys/definitions";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Practical journeys",
  "Follow source-checked YouNew guide paths and keep private progress locally in your browser.",
  "/journeys"
);

export default function JourneysPage() {
  const journeys = practicalJourneys.map((journey) => ({
    ...journey,
    guides: journey.guideIds.map(getContentEntityById).filter((guide) => guide?.type === "guide").map((guide) => ({
      id: guide!.id,
      title: guide!.title,
      summary: guide!.summary,
      route: guide!.route,
      verifiedAt: guide!.verifiedAt
    }))
  }));

  return (
    <PageShell className="web-app-page">
      <section className="app-hero section-shell journey-hero">
        <Breadcrumbs items={[{ label: "Discover", href: "/discover" }, { label: "Journeys" }]} />
        <p className="section-label orange">Practical journeys</p>
        <h1>Move through reliable information, one released guide at a time.</h1>
        <p>Choose a path, open the source-backed guides that are available, and mark your reading progress locally. YouNew leaves incomplete journeys visibly closed instead of filling gaps with unreviewed instructions.</p>
      </section>
      <section className="section-shell journey-section" aria-label="YouNew journeys"><JourneyExplorer journeys={journeys} /></section>
    </PageShell>
  );
}
