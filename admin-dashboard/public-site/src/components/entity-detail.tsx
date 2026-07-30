import Link from "next/link";
import { ArrowRight, ExternalLink, Flag, MapPinned, MapPin, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityCard } from "@/components/entity-card";
import { RecentViewTracker } from "@/components/recent-view-tracker";
import { SaveButton } from "@/components/save-button";
import { ShareButton } from "@/components/share-button";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { GovernanceDisclosure } from "@/components/governance-disclosure";
import type { ContentEntity } from "@/lib/content";
import { contentKindLabel, publicWebSummary } from "@/lib/content/presentation";
import { serializeJsonLd } from "@/lib/seo/json-ld";

const labels = { city: "Cities", guide: "Guides", organization: "Organizations", place: "Places" } as const;
const roots = { city: "/cities", guide: "/guides", organization: "/organizations", place: "/places" } as const;

export function EntityDetail({ entity, related }: { entity: ContentEntity; related: readonly ContentEntity[] }) {
  const reportSubject = encodeURIComponent(`Outdated information: ${entity.title} (${entity.id})`);
  const reportBody = encodeURIComponent(`Page: https://younew.nl${entity.route}/\nCanonical ID: ${entity.id}\n\nWhat appears outdated or incorrect?\n\nOfficial source to review (if known):\n`);
  const location = [entity.cityId?.replaceAll("-", " "), entity.provinceId?.replaceAll("-", " ")].filter(Boolean).join(", ");
  const sourceLabel = entity.trust.officialSource ? "Official public source" : "First-party or responsible source";
  const disclaimer = entity.categorySlugs.some((category) => category === "healthcare")
    ? "General information only; this page is not medical advice. Use the official source and a qualified professional for decisions."
    : entity.categorySlugs.some((category) => category === "housing" || category === "government")
      ? "General information only; procedures and requirements can change. Verify the current steps with the responsible institution."
      : "Details such as access, schedules and availability can change. Verify current information with the source before travelling or acting.";
  const heroImage = preferredMedia(entity.images, ["hero", "gallery", "thumbnail"]);
  const galleryImages = entity.images.filter((image) => image.id !== heroImage?.id).slice(0, 3);
  const summary = publicWebSummary(entity.summary);
  const localCityId = entity.type === "city" ? entity.slug : entity.cityId;
  const localPeers = localCityId ? related.filter((item) => item.cityId === localCityId) : related;
  const topicGroups = [...localPeers.reduce((groups, item) => {
    for (const category of item.categorySlugs) {
      const current = groups.get(category) ?? [];
      current.push(item);
      groups.set(category, current);
    }
    return groups;
  }, new Map<string, ContentEntity[]>()).entries()]
    .map(([slug, items]) => ({ slug, items }))
    .sort((left, right) => right.items.length - left.items.length || left.slug.localeCompare(right.slug));

  const structuredData = {
    "@context": "https://schema.org",
    "@type": entity.type === "organization" ? "Organization" : entity.type === "place" ? "Place" : "Article",
    name: entity.title,
    headline: entity.title,
    description: summary,
    url: `https://younew.nl${entity.route}/`,
    inLanguage: "en",
    dateModified: entity.updatedAt,
    isBasedOn: entity.source.url,
    image: heroImage?.url
  };

  return (
    <>
      <RecentViewTracker item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} />
      <section className="entity-detail-hero section-shell">
        <Breadcrumbs items={[{ label: labels[entity.type], href: roots[entity.type] }, { label: entity.title }]} />
        <div className="entity-detail-heading">
          <div>
            <span className="entity-kind">{contentKindLabel(entity.type, entity.contentDepth)}</span>
            <h1>{entity.title}</h1>
            <p>{summary}</p>
          </div>
          <div className="detail-actions"><SaveButton item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} /><ShareButton title={entity.title} /></div>
        </div>
        {location ? <p className="detail-location"><MapPin aria-hidden /> {location}</p> : null}
        {heroImage ? <ContentMedia asset={heroImage} variant="hero" eager /> : null}
      </section>

      <div className="section-shell entity-detail-layout">
        <article className="entity-main-copy">
          <GovernanceDisclosure entity={entity} />
          <h2>What this page covers</h2>
          <p>{summary}</p>
          <div className="topic-links" aria-label="Related categories">
            {entity.categorySlugs.map((category) => <Link href={`/categories/${category}`} key={category}>{category.replaceAll("-", " ")}</Link>)}
          </div>
          <dl className="content-facts" aria-label="Published record details">
            <div><dt>Content type</dt><dd>{entity.type}</dd></div>
            <div><dt>Category</dt><dd>{entity.categorySlugs.map((category) => category.replaceAll("-", " ")).join(", ")}</dd></div>
            {entity.cityId ? <div><dt>City</dt><dd>{entity.cityId.replaceAll("-", " ")}</dd></div> : null}
            {entity.provinceId ? <div><dt>Province</dt><dd>{entity.provinceId.replaceAll("-", " ")}</dd></div> : null}
            <div><dt>Available photos</dt><dd>{entity.images.length}</dd></div>
            <div><dt>Dataset release</dt><dd>{entity.releaseId}</dd></div>
          </dl>
          {entity.coordinate ? (
            <div className="detail-map-callout">
              <MapPinned aria-hidden />
              <div><strong>See this record in published coverage</strong><p>The map uses the stored YouNew coordinate and does not request your location.</p></div>
              <Link href={`/map?${localCityId ? `city=${localCityId}` : `q=${encodeURIComponent(entity.title)}`}`}>Open map <ArrowRight aria-hidden /></Link>
            </div>
          ) : null}
          {galleryImages.length > 0 ? (
            <section className="entity-media-section" aria-labelledby="entity-media-title">
              <h2 id="entity-media-title">Photos from the app dataset</h2>
              <div className="entity-media-gallery">{galleryImages.map((image) => <ContentMedia asset={image} variant="gallery" key={image.id} />)}</div>
            </section>
          ) : null}
          <h2>What to do next</h2>
          <ol className="next-steps">
            <li><span>1</span><div><strong>Read the source context</strong><p>Confirm that this information matches your city and situation.</p></div></li>
            <li><span>2</span><div><strong>Open the responsible source</strong><p>Check current requirements, access or service details before acting.</p></div></li>
            <li><span>3</span><div><strong>Save or share the page</strong><p>Keep the canonical YouNew ID available for later app/web synchronization.</p></div></li>
          </ol>
          <aside className="safety-note"><strong>Important</strong> {disclaimer}</aside>
        </article>

        <aside className="source-card">
          <ShieldCheck aria-hidden />
          <p className="source-label">{sourceLabel}</p>
          <h2>{entity.source.publisher}</h2>
          <p>{entity.source.title}</p>
          <dl>
            <div><dt>Last verified</dt><dd><time dateTime={entity.verifiedAt}>{entity.verifiedAt}</time></dd></div>
            <div><dt>Content release</dt><dd>{entity.releaseId}</dd></div>
            <div><dt>Jurisdiction</dt><dd>Netherlands{entity.cityId ? ` · ${entity.cityId.replaceAll("-", " ")}` : ""}</dd></div>
          </dl>
          <a className="button button-primary" href={entity.source.url} rel="noreferrer" target="_blank">Open source <ExternalLink aria-hidden /></a>
          <a className="report-link" href={`mailto:support@younew.nl?subject=${reportSubject}&body=${reportBody}`}><Flag aria-hidden /> Report outdated information</a>
        </aside>
      </div>

      {entity.type === "city" && topicGroups.length > 0 ? (
        <section className="section-shell city-topic-directory" aria-labelledby="city-topics-title">
          <div className="listing-heading">
            <div><span>Published local directory</span><h2 id="city-topics-title">Explore {entity.title} by topic</h2><p>These links reflect current YouNew coverage and do not imply a complete city directory.</p></div>
            <Link href={`/map?city=${entity.slug}`}>Open the city map <ArrowRight aria-hidden /></Link>
          </div>
          <div className="city-topic-grid">
            {topicGroups.slice(0, 8).map((group) => (
              <Link href={`/search?city=${entity.slug}&category=${group.slug}`} key={group.slug}>
                <span>{group.items.length}</span>
                <strong>{group.slug.replaceAll("-", " ")}</strong>
                <small>{group.items.slice(0, 2).map((item) => item.title).join(" · ")}</small>
                <ArrowRight aria-hidden />
              </Link>
            ))}
          </div>
        </section>
      ) : null}

      {related.length > 0 ? (
        <section className="section-shell related-section" aria-labelledby="related-title">
          <div className="listing-heading"><div><span>Continue exploring</span><h2 id="related-title">{localCityId ? `More published in ${localCityId.replaceAll("-", " ")}` : "Related published content"}</h2><p>Selected from shared city and category relationships in the governed dataset.</p></div></div>
          <div className="entity-grid compact-grid">{related.slice(0, 6).map((item) => <EntityCard entity={item} key={item.id} />)}</div>
        </section>
      ) : null}
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
    </>
  );
}
