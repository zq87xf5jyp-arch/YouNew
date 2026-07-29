import { AdminUpdates } from "@/components/admin-updates";
import { ContentPage } from "@/components/content-page";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Verified Admin updates",
  "Read manually activated, source-backed updates from the YouNew Admin publication workflow.",
  "/updates"
);

export default function UpdatesPage() {
  return (
    <ContentPage
      title="Verified Admin updates"
      description="This page shows only source-backed articles that passed Admin review and were manually activated by an approved owner or administrator."
    >
      <AdminUpdates />
      <noscript><p>JavaScript is required to retrieve the current verified Admin feed.</p></noscript>
    </ContentPage>
  );
}
