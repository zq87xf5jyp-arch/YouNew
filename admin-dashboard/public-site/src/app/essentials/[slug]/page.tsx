import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CheckCircle2, ExternalLink, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { NationalGuideActionPanel } from "@/components/national-guide-action-panel";
import { PageShell } from "@/components/page-shell";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { getMunicipalities } from "@/lib/geography";
import { getNationalGuide, getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";
import { metadataForPage } from "@/lib/seo/metadata";
import { serializeJsonLd } from "@/lib/seo/json-ld";

export const dynamicParams = false;

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

const actionCopyByCategory: Readonly<Record<string, Readonly<{ shortAnswer: string; primaryAction: string; warning: string }>>> = {
  housing: {
    shortAnswer: "Start with the national rental rules, then verify the address, contract and responsible municipality.",
    primaryAction: "Select your municipality and open its official housing or registration route.",
    warning: "Do not transfer money before verifying the home, provider and written terms."
  },
  work: {
    shortAnswer: "Dutch employment rules are national; local job support depends on the service and municipality.",
    primaryAction: "Open the national work guidance and use your municipality only for confirmed local support.",
    warning: "Check the written contract form, employer and official employment terms before starting."
  },
  documents: {
    shortAnswer: "Your BSN is normally issued after registration with a Dutch municipality.",
    primaryAction: "Select your municipality and open its official registration page.",
    warning: "DigiD is not a BSN application. Never send identity documents through an unverified form."
  },
  healthcare: {
    shortAnswer: "Use a huisarts for routine primary care; call 112 only for immediate life-threatening danger.",
    primaryAction: "Select your municipality, then use the national care route and confirmed local provider information.",
    warning: "A directory entry does not confirm that a practice accepts new patients."
  },
  education: {
    shortAnswer: "Choose the education level or Dutch-language goal before comparing institutions and requirements.",
    primaryAction: "Open the national education source and use your municipality for verified local learning support.",
    warning: "Admission, fees and recognition rules depend on the exact institution and programme."
  },
  telecom: {
    shortAnswer: "Choose prepaid or a contract, then verify coverage, duration and cancellation with the provider.",
    primaryAction: "Open the independent national consumer source before ordering or sharing identity details.",
    warning: "YouNew does not rank providers or reproduce temporary prices."
  },
  rules: {
    shortAnswer: "The issuer on the official notice determines the payment, objection or appeal route.",
    primaryAction: "Use the national source for CJIB matters or select your municipality for local rules.",
    warning: "Do not pay through an unverified message, QR code or copied link."
  }
};

export default async function NationalGuidePage({ params }: { params: Promise<{ slug: string }> }) {
  const guide = getNationalGuide((await params).slug);
  if (!guide) notFound();
  const verifiedAt = nationalGuidesVerifiedAt();
  const actionCopy = actionCopyByCategory[guide.category] ?? {
    shortAnswer: guide.sections.what,
    primaryAction: guide.sections.steps[0] ?? "Open the responsible official source.",
    warning: "Check the latest official source before acting."
  };
  const municipalities = getMunicipalities()
    .map(({ slug, name, officialWebsite }) => ({ slug, name, officialWebsite }))
    .sort((left, right) => left.name.localeCompare(right.name));
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
          <div className="entity-detail-heading national-guide-hero-grid">
            <div>
              <span className="entity-kind">Verified national starting point</span>
              <h1 id="guide-title">{guide.title}</h1>
              <p id="guide-summary">{guide.summary}</p>
            </div>
            <NationalGuideActionPanel
              guideId={guide.id}
              guideSlug={guide.slug}
              guideTitle={guide.title}
              shortAnswer={actionCopy.shortAnswer}
              primaryAction={actionCopy.primaryAction}
              warning={actionCopy.warning}
              verifiedAt={verifiedAt}
              sourceCount={guide.officialSources.length}
              nationalSourceUrl={guide.officialSources[0].url}
              municipalities={municipalities}
            />
          </div>
        </header>

        <div className="section-shell guide-detail-layout">
          <div className="guide-main-copy">
            <aside className="guide-depth-note" role="note">
              <ShieldCheck aria-hidden />
              <div><strong>How this page is bounded</strong><p>This guide gives a verified route to responsible sources. It does not invent local providers, eligibility, prices or deadlines. Check the exact official source before acting.</p></div>
            </aside>
            <section className="guide-section guide-quick-answer"><p className="section-label">Quick answer</p><h2>What this covers</h2><p>{guide.sections.what}</p><div className="guide-scope-grid"><article><h3>Who this is for</h3><p>{guide.sections.who}</p></article><article><h3>Location</h3><p>{guide.sections.localDifferences}</p></article></div></section>
            <section className="guide-section"><p className="section-label">Step by step</p><h2>What to do</h2><ol className="practical-steps">{guide.sections.steps.map((step, index) => <li key={step}><span className="practical-step-number" aria-hidden>{index + 1}</span><div><p>{step}</p></div></li>)}</ol></section>
            <section className="guide-section"><h2>Documents and evidence</h2><List items={guide.sections.documents} /></section>
            <section className="guide-section"><div className="guide-two-column"><div><h2>Costs</h2><p>{guide.sections.cost}</p></div><div><h2>Timing</h2><p>{guide.sections.timing}</p></div></div></section>
            <section className="guide-section"><div className="guide-two-column"><div><h2>When something goes wrong</h2><List items={guide.sections.problems} /></div><div><h2>Common mistakes</h2><List items={guide.sections.mistakes} /></div></div></section>
            <section id="official-sources" className="guide-section"><p className="section-label">Verification</p><h2>Official sources</h2><div className="guide-source-list">{guide.officialSources.map((source) => <article key={source.url}><ShieldCheck aria-hidden /><div><h3>{source.publisher}</h3><p>{source.title}</p><p>Checked <time dateTime={source.checkedAt}>{source.checkedAt}</time></p><TrackedOfficialSourceLink contentId={guide.id} href={source.url} rel="noreferrer" target="_blank">Open official source <ExternalLink aria-hidden /></TrackedOfficialSourceLink></div></article>)}</div><p className="review-stamp"><CheckCircle2 aria-hidden /> Source set checked on <time dateTime={verifiedAt}>{verifiedAt}</time>. Recheck the linked page for current requirements.</p></section>
          </div>
        </div>
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
      </article>
    </PageShell>
  );
}
