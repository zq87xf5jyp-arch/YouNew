import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { SavedItems } from "@/components/saved-items";
import { LocalDataControls } from "@/components/local-data-controls";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Saved items", "Guides, organizations and places saved locally in your YouNew web guide.", "/saved", { noIndex: true, follow: true });

export default function SavedPage() {
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero">
        <Breadcrumbs items={[{ label: "Saved" }]} />
        <h1>Saved on this device</h1>
        <p>No account is required. Saved items stay in this browser and are not sent to YouNew.</p>
      </section>
      <section className="section-shell app-content-block"><SavedItems /><LocalDataControls /></section>
    </PageShell>
  );
}
