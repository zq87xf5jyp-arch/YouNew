import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities, getPublicContent } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(listingCopy.guide.title, listingCopy.guide.description, "/guides");

export default function GuidesPage() {
  const guides = getContentEntities("guide");
  const { practicalGuides, summaryGuides } = getPublicContent().stats;
  return (
    <ContentIndexPage
      {...listingCopy.guide}
      entities={guides}
      featuredId="government_service.first-registration-in-amsterdam"
      datasetNote={<><strong>{practicalGuides}</strong> step-by-step guide{practicalGuides === 1 ? "" : "s"} · <strong>{summaryGuides}</strong> verified summar{summaryGuides === 1 ? "y" : "ies"} · source dates shown on every detail page</>}
      context={(
        <aside className="section-shell content-depth-key" aria-label="Guide publication levels">
          <div><strong>{practicalGuides} Step-by-step guides</strong><span>Complete procedures with cited steps, documents, timing and warnings.</span></div>
          <div><strong>{summaryGuides} Verified summaries</strong><span>Source-checked starting points and next actions; not complete procedures.</span></div>
        </aside>
      )}
    />
  );
}
