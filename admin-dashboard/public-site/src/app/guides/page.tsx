import { ContentIndexPage } from "@/components/content-index-page";
import { NationalGuideDirectory } from "@/components/national-guide-directory";
import { getContentEntities, getPublicContent } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { getNationalGuides } from "@/lib/search/national-guides";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(listingCopy.guide.title, listingCopy.guide.description, "/guides");

export default function GuidesPage() {
  const guides = getContentEntities("guide");
  const { summaryGuides } = getPublicContent().stats;
  const nationalGuides = getNationalGuides();
  return (
    <ContentIndexPage
      {...listingCopy.guide}
      entities={guides}
      featuredId="government_service.first-registration-in-amsterdam"
      datasetNote={<><strong>{nationalGuides.length}</strong> national practical guides · <strong>{summaryGuides}</strong> verified local summar{summaryGuides === 1 ? "y" : "ies"} · source dates shown on every detail page</>}
      preShowcase={<NationalGuideDirectory />}
      context={(
        <aside className="section-shell content-depth-key" aria-label="Guide publication levels">
          <div><strong>{nationalGuides.length} National practical guides</strong><span>Source-checked routes with interactive reading checklists, limits and official next actions.</span></div>
          <div><strong>{summaryGuides} Verified local summaries</strong><span>Municipal and local starting points; not complete procedures unless explicitly labelled.</span></div>
        </aside>
      )}
    />
  );
}
