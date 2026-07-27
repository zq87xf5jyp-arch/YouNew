/* eslint-disable @next/next/no-img-element */
import Link from "next/link";
import { ExternalLink, Flag, MapPin, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityCard } from "@/components/entity-card";
import { RecentViewTracker } from "@/components/recent-view-tracker";
import { SaveButton } from "@/components/save-button";
import { ShareButton } from "@/components/share-button";
import type { ContentEntity } from "@/lib/content";
import { cardMediaForEntity } from "@/lib/content/card-media";
import { serializeJsonLd } from "@/lib/seo/json-ld";

const labels = { city: "Cities", guide: "Guides", organization: "Organizations", place: "Places" } as const;
const roots = { city: "/cities", guide: "/guides", organization: "/organizations", place: "/places" } as const;
const nextSteps = {
  city: [
    ["Explore the published city coverage", "Use the related categories and records below to find places, services and practical information already released for this city."],
    ["Check the municipality source", "Confirm current local services, contact routes and municipal information on the responsible city website."],
    ["Continue with the map or search", "Use YouNew’s map and search to narrow the published records to the topic you need."]
  ],
  organization: [
    ["Confirm the service scope", "Read the source page to check whether the organization serves your situation, location or eligibility requirements."],
    ["Check the current contact route", "Opening hours, appointment rules and contact channels can change, so verify them before visiting or applying."],
    ["Review related YouNew records", "Use the linked categories and related content to understand the surrounding topic before acting."]
  ],
  place: [
    ["Check current visitor information", "Confirm opening hours, access conditions, reservations and temporary changes on the responsible source page."],
    ["Plan the location", "Use the published city and province context together with the current route information from the provider."],
    ["Save useful context", "Keep this page and the related records ready while planning your visit."]
  ],
  guide: [
    ["Check applicability", "Confirm that the information covers your municipality and personal situation."],
    ["Read the responsible source", "Use the current requirements from the responsible institution before acting."],
    ["Keep the verified route", "Save or share this record so you can return to the source and related information."]
  ]
} as const;

export function EntityDetail({ entity, related }: { entity: ContentEntity; related: readonly ContentEntity[] }) {
  const reportSubject = encodeURIComponent(`Outdated information: ${entity.title} (${entity.id})`);
  const reportBody = encodeURIComponent(`Page: https://younew.nl${entity.route}/\nCanonical ID: ${entity.id}\n\nWhat appears outdated or incorrect?\n\nOfficial source to review (if known):\n`);
  const location = [entity.cityId?.replaceAll("-", " "), entity.provinceId?.replaceAll("-", " ")].filter(Boolean).join(", ");
  const primaryImage = cardMediaForEntity(entity);
  const sourceLabel = entity.trust.officialSource ? "Official public source" : "First-party or responsible source";
  const disclaimer = entity.categorySlugs.some((category) => category === "healthcare")
    ? "General information only; this page is not medical advice. Use the official source and a qualified professional for decisions."
    : entity.categorySlugs.some((category) => category === "housing" || category === "government")
      ? "General information only; procedures and requirements can change. Verify the current steps with the responsible institution."
      : "Details such as access, schedules and availability can change. Verify current information with the source before travelling or acting.";

  const structuredData = {
    "@context": "https://schema.org",
    "@type": entity.type === "organization" ? "Organization" : entity.type === "place" ? "Place" : "Article",
    name: entity.title,
    headline: entity.title,
    description: entity.summary,
    url: `https://younew.nl${entity.route}/`,
    inLanguage: "en",
    dateModified: entity.updatedAt,
    isBasedOn: entity.source.url
  };

  return (
    <>
      <RecentViewTracker item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} />
      <section className="entity-detail-hero section-shell">
        <Breadcrumbs items={[{ label: labels[entity.type], href: roots[entity.type] }, { label: entity.title }]} />
        <div className="entity-detail-heading">
          <div>
            <span className="entity-kind">{entity.type}</span>
            <h1>{entity.title}</h1>
            <p>{entity.summary}</p>
          </div>
          <div className="detail-actions"><SaveButton item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} /><ShareButton title={entity.title} /></div>
        </div>
        {location ? <p className="detail-location"><MapPin aria-hidden /> {location}</p> : null}
        {primaryImage ? (
          <figure className="entity-detail-media">
            <img src={primaryImage.src} alt={primaryImage.alt} loading="eager" decoding="async" />
            <figcaption><a href={primaryImage.sourceUrl} rel="noreferrer" target="_blank">Photo: {primaryImage.credit}</a><span> · </span><a href={primaryImage.licenseUrl} rel="noreferrer" target="_blank">{primaryImage.license}</a></figcaption>
          </figure>
        ) : null}
      </section>

      <div className="section-shell entity-detail-layout">
        <article className="entity-main-copy">
          <h2>Published overview</h2>
          <p>{entity.summary}</p>
          <dl className="detail-facts" aria-label={`${entity.title} published facts`}>
            <div><dt>Record type</dt><dd>{entity.type}</dd></div>
            <div><dt>Coverage</dt><dd>{location || "Netherlands"}</dd></div>
            <div><dt>Responsible source</dt><dd>{entity.source.publisher}</dd></div>
            <div><dt>Last verified</dt><dd><time dateTime={entity.verifiedAt}>{entity.verifiedAt}</time></dd></div>
            <div><dt>Content status</dt><dd>Published · source checked</dd></div>
            <div><dt>Related records</dt><dd>{related.length}</dd></div>
          </dl>
          <h2>Topics connected to this record</h2>
          <p>Use these published categories to continue with information that shares the same reviewed topic or location context.</p>
          <div className="topic-links" aria-label="Related categories">
            {entity.categorySlugs.map((category) => <Link href={`/categories/${category}`} key={category}>{category.replaceAll("-", " ")}</Link>)}
          </div>
          <h2>What to do next</h2>
          <ol className="next-steps">
            {nextSteps[entity.type].map(([title, description], index) => (
              <li key={title}><span>{index + 1}</span><div><strong>{title}</strong><p>{description}</p></div></li>
            ))}
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

      {related.length > 0 ? (
        <section className="section-shell related-section" aria-labelledby="related-title">
          <div className="listing-heading"><div><span>Continue exploring</span><h2 id="related-title">Related published content</h2></div></div>
          <div className="entity-grid compact-grid">{related.slice(0, 3).map((item) => <EntityCard entity={item} key={item.id} />)}</div>
        </section>
      ) : null}
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
    </>
  );
}
