import Link from "next/link";
import { ArrowRight, CalendarDays, Info, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { PageShell } from "@/components/page-shell";
import statusSnapshot from "@/config/status.json";
import { getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Updates",
  "Dated YouNew product, content and catalogue updates backed by the current published dataset.",
  "/updates"
);

const publicDate = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "UTC"
});

function humanDate(value: string) {
  return publicDate.format(new Date(`${value}T00:00:00Z`));
}

export default function UpdatesPage() {
  const content = getPublicContent();
  const amsterdamEntities = content.entities.filter((entity) => entity.releaseId === "amsterdam-v0.1.4");
  const releaseDate = amsterdamEntities.reduce(
    (latestDate, entity) => entity.updatedAt > latestDate ? entity.updatedAt : latestDate,
    content.generatedAt.slice(0, 10)
  );
  const latest = amsterdamEntities
    .filter((entity) => entity.updatedAt === releaseDate && entity.images.length > 0)
    .slice(0, 8);

  return (
    <PageShell>
      <section className="app-hero section-shell updates-hero">
        <Breadcrumbs items={[{ label: "Updates" }]} />
        <CalendarDays className="hero-line-icon" aria-hidden />
        <h1>What is new in YouNew.</h1>
        <p>Dated product and catalogue changes from the published YouNew dataset. This is an editorial changelog, not a live breaking-news feed.</p>
        <div className="updates-facts">
          <div><strong>{content.stats.entities}</strong><span>published records</span></div>
          <div><strong>{content.publishedReleaseIds.length}</strong><span>accepted releases</span></div>
          <div><strong>{humanDate(statusSnapshot.content.asOf)}</strong><span>content snapshot checked</span></div>
        </div>
      </section>

      <main className="section-shell updates-layout">
        <section className="updates-release" aria-labelledby="release-title">
          <header>
            <time dateTime={releaseDate}><CalendarDays aria-hidden /> {humanDate(releaseDate)}</time>
            <h2 id="release-title">Amsterdam catalogue refreshed</h2>
            <p>Current places and organizations from release <code>amsterdam-v0.1.4</code> are available in the public catalogue.</p>
          </header>
          <div className="updates-media-rail">
            {latest.map((entity) => {
              const media = preferredMedia(entity.images, ["thumbnail", "hero", "gallery"]);
              return (
                <Link href={entity.route} key={entity.id}>
                  {media ? <ContentMedia asset={media} variant="card" /> : null}
                  <span>{entity.type}</span>
                  <h3>{entity.title}</h3>
                  <strong>Open record <ArrowRight aria-hidden /></strong>
                </Link>
              );
            })}
          </div>
          <Link className="updates-more" href="/discover">Explore all published content <ArrowRight aria-hidden /></Link>
        </section>

        <section className="updates-note" aria-labelledby="status-update-title">
          <Info aria-hidden />
          <div>
            <time dateTime={statusSnapshot.checkedAt}>{humanDate(statusSnapshot.checkedAt)}</time>
            <h2 id="status-update-title">Website, content and App Store availability checked</h2>
            <p>{statusSnapshot.website.summary} {statusSnapshot.ios.summary}</p>
            <Link href="/status">Read the dated status snapshot <ArrowRight aria-hidden /></Link>
          </div>
        </section>

        <aside className="updates-policy">
          <ShieldCheck aria-hidden />
          <div><h2>How updates are selected</h2><p>Only published records from accepted production releases appear here. Mutable details such as prices, ratings and opening hours remain with the responsible source.</p></div>
        </aside>
      </main>
    </PageShell>
  );
}
