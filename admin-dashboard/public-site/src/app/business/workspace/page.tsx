import { Breadcrumbs } from "@/components/breadcrumbs";
import { BusinessWorkspace } from "@/components/business-workspace";
import { KnowledgeTrustSummary } from "@/components/knowledge-trust-summary";
import { PageShell } from "@/components/page-shell";
import { advertisingFormatCatalog, advertisingSurfaceCatalog } from "@/lib/business/catalog";
import { getNetherlandsGeography } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "YouNew Business workspace",
  "Prepare a reviewed YouNew business profile and advertising placement inquiry in a local, transparent workspace preview.",
  "/business/workspace",
  { noIndex: true, follow: true }
);

export default function BusinessWorkspacePage() {
  const geography = getNetherlandsGeography();

  return (
    <PageShell className="business-page business-workspace-page">
      <div className="business-workspace-breadcrumbs section-shell">
        <Breadcrumbs items={[
          { label: "Business", href: "/business" },
          { label: "Workspace" }
        ]} />
      </div>
      <BusinessWorkspace
        catalogFacts={{
          formats: advertisingFormatCatalog.length,
          surfaces: advertisingSurfaceCatalog.length,
          municipalities: geography.stats.municipalities,
          provinces: geography.stats.provinces
        }}
      />
      <div className="business-workspace-trust section-shell">
        <KnowledgeTrustSummary compact />
      </div>
    </PageShell>
  );
}
