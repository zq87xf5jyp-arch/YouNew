import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CheckCircle2, ExternalLink, MapPin, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { GuideChecklist } from "@/components/guide-checklist";
import { PageShell } from "@/components/page-shell";
import { PublicFeedbackForm } from "@/components/public-feedback-form";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { getNationalGuide, getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";
import { metadataForPage } from "@/lib/seo/metadata";
import { serializeJsonLd } from "@/lib/seo/json-ld";

export const dynamicParams = false;

const nextGuideById: Readonly<Record<string, string>> = {
  "national.immigration": "national.documents",
  "national.documents": "national.housing",
  "national.housing": "national.healthcare",
  "national.healthcare": "national.work",
  "national.work": "national.taxes",
  "national.taxes": "national.benefits",
  "national.benefits": "national.banking",
  "national.banking": "national.transport",
  "national.transport": "national.telecom",
  "national.telecom": "national.education",
  "national.education": "national.family-childcare",
  "national.family-childcare": "national.pets",
  "national.pets": "national.rules-fines",
  "national.rules-fines": "national.lgbtiq-support"
};

export function generateStaticParams() {
  return getNationalGuides().map(({ slug }) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const guide = getNationalGuide((await params).slug);
  return guide ? metadataForPage(guide.title, guide.summary, `/essentials/${guide.slug}`) : {};
}

function List({ items }: { items: readonly string[] }) {
  return <ul className="guide-sourced-list">{items.map((item) => <li key={item}>{item}</li>)}</ul>;
}

export default async function NationalGuidePage({ params }: { params: Promise<{ slug: string }> }) {
  const guide = getNationalGuide((await params).slug);
  if (!guide) notFound();
  const verifiedAt = nationalGuidesVerifiedAt();
  const nextGuide = getNationalGuides().find((candidate) => candidate.id === nextGuideById[guide.id]);
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: guide.title,
    description: guide.summary,
    url: `https://younew.nl/essentials/${guide.slug}/`,
    inLanguage: guide.languages,
    dateModified: verifiedAt,
    areaServed: "NL",
    citation: guide.officialSources.map((source) => source.url)
  };

  return (
    <PageShell>
      <article className="guide-detail national-guide" aria-labelledby="guide-title" aria-describedby="guide-summary">
        <header className="entity-detail-hero section-shell">
          <Breadcrumbs items={[{ label: "Search", href: "/search" }, { label: "National guidance" }, { label: guide.title }]} />
          <div className="entity-detail-heading">
            <div>
              <span className="entity-kind">Verified national starting point</span>
              <h1 id="guide-title">{guide.title}</h1>
              <p id="guide-summary">{guide.summary}</p>
              <dl className="guide-hero-metadata" aria-label="Guide scope and verification">
                <div><dt><MapPin aria-hidden /> Scope</dt><dd>All Netherlands</dd></div>
                <div><dt><ShieldCheck aria-hidden /> Sources checked</dt><dd><time dateTime={verifiedAt}>{verifiedAt}</time></dd></div>
              </dl>
            </div>
          </div>
        </header>

        <div className="section-shell guide-detail-layout">
          <div className="guide-main-copy">
            <aside className="guide-depth-note" role="note">
              <ShieldCheck aria-hidden />
              <div><strong>How this page is bounded</strong><p>This guide gives a verified route to responsible sources. It does not invent local providers, eligibility, prices or deadlines. Check the exact official source before acting.</p></div>
            </aside>
            <section className="guide-section guide-quick-answer"><p className="section-label">Quick answer</p><h2>What this covers</h2><p>{guide.sections.what}</p><div className="guide-scope-grid"><article><h3>Who this is for</h3><p>{guide.sections.who}</p></article><article><h3>Location</h3><p>{guide.sections.localDifferences}</p></article></div></section>
            <section className="guide-section"><p className="section-label">Step by step</p><h2>What to do</h2><GuideChecklist guideId={guide.id} items={guide.sections.steps} nextGuide={nextGuide ? { title: nextGuide.title, route: `/essentials/${nextGuide.slug}/` } : undefined} showPersonalisedNextStep /></section>
            <section className="guide-section"><h2>Documents and evidence</h2><List items={guide.sections.documents} /></section>
            <section className="guide-section"><div className="guide-two-column"><div><h2>Costs</h2><p>{guide.sections.cost}</p></div><div><h2>Timing</h2><p>{guide.sections.timing}</p></div></div></section>
            <section className="guide-section"><div className="guide-two-column"><div><h2>When something goes wrong</h2><List items={guide.sections.problems} /></div><div><h2>Common mistakes</h2><List items={guide.sections.mistakes} /></div></div></section>
            <section id="official-sources" className="guide-section"><p className="section-label">Verification</p><h2>Official sources</h2><div className="guide-source-list">{guide.officialSources.map((source) => <article key={source.url}><ShieldCheck aria-hidden /><div><h3>{source.publisher}</h3><p>{source.title}</p><p>Checked <time dateTime={source.checkedAt}>{source.checkedAt}</time></p><TrackedOfficialSourceLink contentId={guide.id} href={source.url} rel="noreferrer" target="_blank">Open official source <ExternalLink aria-hidden /></TrackedOfficialSourceLink></div></article>)}</div><p className="review-stamp"><CheckCircle2 aria-hidden /> Source set checked on <time dateTime={verifiedAt}>{verifiedAt}</time>. Recheck the linked page for current requirements.</p></section>
            <section className="guide-section guide-feedback-section" aria-labelledby="guide-feedback-title">
              <p className="section-label">Improve this instruction</p>
              <h2 id="guide-feedback-title">Is something incorrect, unclear or missing?</h2>
              <p>Send a page-specific report for editorial review. Reports do not change the published guide automatically.</p>
              <details className="guide-feedback-panel">
                <summary>Send feedback about this guide</summary>
                <div><PublicFeedbackForm compact defaultPageReference={`/essentials/${guide.slug}/`} initialFeedbackType="suggestion" /></div>
              </details>
            </section>
          </div>
        </div>
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
      </article>
    </PageShell>
  );
}
