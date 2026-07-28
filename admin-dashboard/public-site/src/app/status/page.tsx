import { ContentPage } from "@/components/content-page";
import { StatusPanel, type StatusSnapshot } from "@/components/status-panel";
import statusSnapshot from "@/config/status.json";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Service status", "A static, dated status snapshot for the YouNew website, content, iOS app and operational release boundaries.", "/status");

export default function StatusPage() {
  return (
    <ContentPage
      title="YouNew status"
      description="Check the latest verified snapshot for the website, published content, iOS app and operational release boundaries."
    >
      <StatusPanel snapshot={statusSnapshot as StatusSnapshot} />
    </ContentPage>
  );
}
