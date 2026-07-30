import { ContentPage } from "@/components/content-page";
import { KnowledgeTrustSummary } from "@/components/knowledge-trust-summary";
import { StatusPanel, type StatusSnapshot } from "@/components/status-panel";
import { SystemEvidence } from "@/components/system-evidence";
import statusSnapshot from "@/config/status.json";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Service and system status", "A dated, evidence-based snapshot for the YouNew website, published content, connected product system and iOS distribution.", "/status");

export default function StatusPage() {
  return (
    <ContentPage
      title="YouNew status"
      description="Check the latest verified snapshot for the website, published content and iOS application distribution."
    >
      <StatusPanel snapshot={statusSnapshot as StatusSnapshot} />
      <KnowledgeTrustSummary />
      <SystemEvidence />
    </ContentPage>
  );
}
