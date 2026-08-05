import Link from "next/link";
import { ArrowRight, Clock3, MapPinned, Search, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import type { ContentEntity } from "@/lib/content";
import { contentKindLabel, publicWebSummary } from "@/lib/content/presentation";
import type { ReactNode } from "react";

const pluralLabels: Record<ContentEntity["type"], string> = {
  city: "cities",
  guide: "guides",
  organization: "organizations",
  place: "places"
};

function featuredFor(entities: readonly ContentEntity[], featuredId?: string) {
  return entities.find((entity) => entity.id === featuredId)
    ?? entities.find((entity) => entity.images.some((image) => image.role === "hero"))
    ?? entities.find((entity) => entity.images.length > 0)
    ?? entities[0]
    ?? null;
}

function categoryHighlights(entities: readonly ContentEntity[]) {
  const counts = new Map<string, number>();
  for (const entity of entities) {
    for (const category of entity.categorySlugs) {
      counts.set(category, (counts.get(category) ?? 0) + 1);
    }
  }
  return [...counts.entries()]
    .map(([slug, count]) => ({ slug, count, title: slug.replaceAll("-", " ") }))
    .sort((left, right) => right.count - left.count || left.title.localeCompare(right.title))
    .slice(0, 4);
}

export function ContentIndexPage({
  title,
  description,
  entities,
  datasetNote,
  context,
  featuredId
}: {
  title: string;
  description: string;
  entities: readonly ContentEntity[];
  datasetNote?: ReactNode;
  context?: ReactNode;
  featuredId?: string;
}) {
  const type = entities[0]?.type;
  const featured = featuredFor(entities, featuredId);
  const featuredImage = featured ? preferredMedia(featured.images, ["hero", "gallery", "thumbnail"]) : null;
  const highlights = categoryHighlights(entities);
  const listingEntities = featured && entities.length > 1
    ? entities.filter((entity) => entity.id !== featured.id)
    : entities;
  const collectionLabel = type ? pluralLabels[type] : "published content";
  const continuationHref = type ? `/search?type=${type}` : "/search";
  const secondaryHref = type === "guide" ? "/journeys" : "/map";
  const secondaryLabel = type === "guide" ? "Open practical journeys" : "Explore the coverage map";

  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero content-index-hero">
        <Breadcrumbs items={[{ label: title }]} />
        <h1>{title}</h1>
        <p>{description}</p>
        <div className="dataset-note">
          {datasetNote ?? <><strong>{entities.length}</strong> published item{entities.length === 1 ? "" : "s"} · English reviewed content · source dates shown on every detail page</>}
        </div>
      </section>

      {featured ? (
        <section className="section-shell content-index-showcase" aria-labelledby="featured-content-title">
          <article className="content-index-featured">
            {featuredImage ? <ContentMedia asset={featuredImage} variant="hero" eager /> : null}
            <div className="content-index-featured-copy">
              <span>{contentKindLabel(featured.type, featured.contentDepth)}</span>
              <h2 id="featured-content-title">{featured.title}</h2>
              <p>{publicWebSummary(featured.summary)}</p>
              <div className="content-index-featured-meta">
                <span><ShieldCheck aria-hidden /> Source checked {featured.verifiedAt}</span>
                <span>{featured.source.publisher}</span>
              </div>
              <div className="content-index-featured-actions">
                <Link className="button button-primary" href={featured.route}>Open published page <ArrowRight aria-hidden /></Link>
                <Link className="button button-outline" href={continuationHref}>Browse all {collectionLabel}</Link>
              </div>
            </div>
          </article>

          <aside className="content-index-topic-rail" aria-label={`Starting points for ${collectionLabel}`}>
            <div><strong>Start by topic</strong><span>Based on the current published dataset.</span></div>
            {highlights.map((highlight, index) => (
              <Link href={`/categories/${highlight.slug}`} key={highlight.slug}>
                <span>{String(index + 1).padStart(2, "0")}</span>
                <div><strong>{highlight.title}</strong><small>{highlight.count} published item{highlight.count === 1 ? "" : "s"}</small></div>
                <ArrowRight aria-hidden />
              </Link>
            ))}
          </aside>
        </section>
      ) : null}

      {context}

      <section className="section-shell content-index-tools" aria-label="Explore published content">
        <div>
          <Search aria-hidden />
          <span><strong>Looking for something specific?</strong><small>Search titles, close spellings, cities and categories.</small></span>
        </div>
        <Link className="button button-outline" href={continuationHref}>Search {collectionLabel}</Link>
        <Link className="text-link" href={secondaryHref}>{secondaryLabel} <ArrowRight aria-hidden /></Link>
      </section>

      {entities.length > 0 ? <section className="section-shell app-content-block content-index-listing">
        <div className="listing-heading">
          <div><span>Published collection</span><h2>Explore all {collectionLabel}</h2><p>Each page shows its source, verification date and related material.</p></div>
        </div>
        <EntityListing entities={listingEntities} viewAllHref={continuationHref} variant="editorial" />
      </section> : null}

      <section className="section-shell content-index-trust" aria-label="How YouNew publishes content">
        <div><ShieldCheck aria-hidden /><span><strong>Source trail</strong><small>Responsible links stay visible on detail pages.</small></span></div>
        <div><Clock3 aria-hidden /><span><strong>Verification dates</strong><small>Users can see when information was last checked.</small></span></div>
        <div><MapPinned aria-hidden /><span><strong>Local context</strong><small>Published city and province relationships remain explicit.</small></span></div>
        <Link href="/status">Read the content status <ArrowRight aria-hidden /></Link>
      </section>
    </PageShell>
  );
}
