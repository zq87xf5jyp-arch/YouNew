import { Breadcrumbs } from "@/components/breadcrumbs";
import { MyYouNewDashboard } from "@/components/my-younew-dashboard";
import { PageShell } from "@/components/page-shell";
import { preferredMedia } from "@/components/content-media";
import { getPublicContent } from "@/lib/content";
import { getMunicipalities } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "My YouNew",
  "Continue your saved route, materials and reading progress stored locally in this browser.",
  "/my-younew",
  { noIndex: true, follow: true }
);

const dateFormatter = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "short",
  year: "numeric",
  timeZone: "UTC"
});

export default function MyYouNewPage() {
  const content = getPublicContent();
  const latestUpdates = [...content.entities]
    .filter((entity) => entity.images.length > 0)
    .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt) || left.title.localeCompare(right.title))
    .slice(0, 3)
    .map((entity) => ({
      id: entity.id,
      route: entity.route,
      title: entity.title,
      kind: entity.type,
      updatedLabel: dateFormatter.format(new Date(`${entity.updatedAt}T00:00:00Z`)),
      media: preferredMedia(entity.images, ["thumbnail", "hero", "gallery"])
    }));

  return (
    <PageShell className="my-younew-page">
      <section className="app-hero section-shell my-younew-hero">
        <Breadcrumbs items={[{ label: "My YouNew" }]} />
        <h1>Continue where you left off.</h1>
        <p>Your route, saved materials and reading progress stay on this device.</p>
      </section>
      <main className="section-shell my-younew-main">
        <MyYouNewDashboard
          municipalities={getMunicipalities().map((municipality) => ({ slug: municipality.slug, name: municipality.name }))}
          latestUpdates={latestUpdates}
        />
      </main>
    </PageShell>
  );
}
