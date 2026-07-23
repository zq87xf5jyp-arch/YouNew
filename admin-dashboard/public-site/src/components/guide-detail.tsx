import { AlertTriangle, BookOpen, CheckCircle2, CircleHelp, Clock3, ExternalLink, FileText, Flag, Lightbulb, MapPin, ShieldCheck, Users } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { CopyTextButton } from "@/components/copy-text-button";
import { EntityCard } from "@/components/entity-card";
import { GuideChecklist } from "@/components/guide-checklist";
import { PrintButton } from "@/components/print-button";
import { ReadingProgress } from "@/components/reading-progress";
import { RecentViewTracker } from "@/components/recent-view-tracker";
import { SaveButton } from "@/components/save-button";
import { ShareButton } from "@/components/share-button";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import type { ContentEntity, GuideContactOption, GuideSourcedText, PracticalGuide } from "@/lib/content";
import { serializeJsonLd } from "@/lib/seo/json-ld";

function titleCase(value: string) {
  return value.replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function SourceLinks({ item, guide }: { item: { sourceIds: readonly string[] }; guide: PracticalGuide }) {
  const sources = item.sourceIds.map((id) => guide.officialSources.find((source) => source.id === id)).filter(Boolean);
  if (sources.length === 0) return null;
  return (
    <span className="guide-inline-sources" aria-label="Sources for this information">
      {sources.map((source, index) => source ? <a aria-label={`Official source ${index + 1}: ${source.publisher} — ${source.title}`} href={source.url} rel="noreferrer" target="_blank" key={source.id}>Source {index + 1}: {source.publisher}<ExternalLink aria-hidden /></a> : null)}
    </span>
  );
}

function SourcedList({ items, guide }: { items: readonly GuideSourcedText[]; guide: PracticalGuide }) {
  if (items.length === 0) return <p className="guide-explicit-empty">No additional items are listed in the reviewed source set.</p>;
  return <ul className="guide-sourced-list">{items.map((item) => <li key={item.id}><span>{item.text}</span><SourceLinks item={item} guide={guide} /></li>)}</ul>;
}

function ContactValue({ contact }: { contact: GuideContactOption }) {
  if (contact.kind === "url") return <a href={contact.value} rel="noreferrer" target="_blank">{contact.value}<ExternalLink aria-hidden /></a>;
  if (contact.kind === "email") return <a href={`mailto:${contact.value}`}>{contact.value}</a>;
  if (contact.kind === "phone") return <a href={`tel:${contact.value.replace(/[^+\d]/g, "")}`}>{contact.value}</a>;
  return <span>{contact.value}</span>;
}

function FullPracticalGuide({ guide }: { guide: PracticalGuide }) {
  const audience = guide.audienceProfiles.map(titleCase).join(", ");
  const jurisdiction = guide.jurisdiction.level === "municipal"
    ? `${guide.applicability.cityIds.map(titleCase).join(", ")} municipality`
    : guide.jurisdiction.level === "provincial"
      ? guide.applicability.provinceIds.map(titleCase).join(", ")
      : guide.jurisdiction.level === "mixed" ? "National and local rules" : "Netherlands";

  return (
    <>
      <nav className="guide-toc" aria-labelledby="guide-toc-title">
        <strong id="guide-toc-title">On this page</strong>
        <ol>
          <li><a href="#quick-answer">Quick answer</a></li>
          <li><a href="#before-you-start">Before you start</a></li>
          {guide.sections.length > 0 ? <li><a href="#important-context">Important context</a></li> : null}
          <li><a href="#checklist">Your checklist</a></li>
          <li><a href="#steps">Steps</a></li>
          <li><a href="#tips">Practical tips</a></li>
          <li><a href="#warnings">Warnings and mistakes</a></li>
          <li><a href="#faq">FAQ</a></li>
          {guide.emergencyInformation.length > 0 ? <li><a href="#emergency-information">Emergency information</a></li> : null}
          <li><a href="#official-sources">Official sources</a></li>
          {guide.contactOptions.length > 0 ? <li><a href="#contact-options">Contact options</a></li> : null}
          <li><a href="#next-actions">What to do next</a></li>
        </ol>
      </nav>

      <section id="quick-answer" className="guide-section guide-quick-answer" aria-labelledby="quick-answer-title">
        <p className="section-label">Quick answer</p>
        <h2 id="quick-answer-title">The short version</h2>
        <p>{guide.shortSummary.text}</p>
        <SourceLinks item={guide.shortSummary} guide={guide} />
        <div className="guide-scope-grid">
          <article><h3>Who this is for</h3><p>{guide.whoThisIsFor.text}</p><SourceLinks item={guide.whoThisIsFor} guide={guide} /></article>
          <article><h3>When you need it</h3><p>{guide.whenYouNeedIt.text}</p><SourceLinks item={guide.whenYouNeedIt} guide={guide} /></article>
        </div>
        <dl className="guide-facts">
          <div><dt><Users aria-hidden /> For</dt><dd>{audience}</dd></div>
          <div><dt><MapPin aria-hidden /> Jurisdiction</dt><dd>{jurisdiction}{guide.jurisdiction.municipalityDependent ? " · local requirements vary" : ""}{guide.jurisdiction.note ? <small>{guide.jurisdiction.note}</small> : null}<SourceLinks item={guide.jurisdiction} guide={guide} /></dd></div>
          <div><dt><Clock3 aria-hidden /> Estimated time</dt><dd>{guide.estimatedTime.value}<small>{guide.estimatedTime.note}</small><SourceLinks item={guide.estimatedTime} guide={guide} /></dd></div>
          <div><dt>Estimated cost</dt><dd>{guide.estimatedCost.value}{guide.estimatedCost.currency ? ` ${guide.estimatedCost.currency}` : ""}<small>{guide.estimatedCost.note}</small><SourceLinks item={guide.estimatedCost} guide={guide} /></dd></div>
          <div><dt><BookOpen aria-hidden /> Reading time</dt><dd>{guide.readingTimeMinutes} minutes</dd></div>
          <div><dt>Difficulty</dt><dd>{titleCase(guide.difficulty)}</dd></div>
        </dl>
        <div className="guide-tags" role="list" aria-label="Guide topics">{guide.tags.map((tag) => <span role="listitem" key={tag}>{tag}</span>)}</div>
      </section>

      <section id="before-you-start" className="guide-section" aria-labelledby="before-title">
        <h2 id="before-title">Before you start</h2>
        <div className="guide-two-column">
          <div><h3>Prerequisites</h3><SourcedList items={guide.prerequisites} guide={guide} /></div>
          <div><h3>Required documents</h3><SourcedList items={guide.requiredDocuments} guide={guide} /></div>
        </div>
      </section>

      {guide.sections.length > 0 ? (
        <section id="important-context" className="guide-section" aria-labelledby="context-title">
          <h2 id="context-title">Important context</h2>
          {guide.sections.map((section) => <div className="guide-context-block" key={section.id}><h3>{section.title}</h3><p>{section.body}</p><SourceLinks item={section} guide={guide} /></div>)}
        </section>
      ) : null}

      <section id="checklist" className="guide-section" aria-labelledby="checklist-title">
        <p className="section-label">Local progress</p>
        <h2 id="checklist-title">Your checklist</h2>
        <GuideChecklist guideId={guide.id} items={guide.checklist} sources={guide.officialSources} />
      </section>

      <section id="steps" className="guide-section" aria-labelledby="steps-title">
        <p className="section-label">Step by step</p>
        <h2 id="steps-title">What to do</h2>
        <ol className="practical-steps">
          {guide.numberedSteps.map((step) => (
            <li key={step.id}>
              <span className="practical-step-number" aria-hidden>{step.position}</span>
              <div><div className="practical-step-heading"><h3>{step.title}</h3><CopyTextButton label={`Copy step ${step.position}`} value={`${step.position}. ${step.title}\n${step.body}`} /></div><p>{step.body}</p>{step.municipalityDependent ? <p className="municipal-note">Check the exact procedure with your gemeente.</p> : null}<SourceLinks item={step} guide={guide} /></div>
            </li>
          ))}
        </ol>
      </section>

      <section id="tips" className="guide-section" aria-labelledby="tips-title">
        <h2 id="tips-title"><Lightbulb aria-hidden /> Practical tips</h2>
        <SourcedList items={guide.tips} guide={guide} />
      </section>

      <section id="warnings" className="guide-section" aria-labelledby="warnings-title">
        <h2 id="warnings-title">Warnings and common mistakes</h2>
        <div className="guide-two-column">
          <aside className="guide-warning-panel" aria-labelledby="watch-out-title"><h3 id="watch-out-title"><AlertTriangle aria-hidden /> Watch out for</h3><SourcedList items={guide.warnings} guide={guide} /></aside>
          <div><h3>Common mistakes</h3><SourcedList items={guide.commonMistakes} guide={guide} /></div>
        </div>
      </section>

      <section id="faq" className="guide-section" aria-labelledby="faq-title">
        <h2 id="faq-title"><CircleHelp aria-hidden /> Frequently asked questions</h2>
        <div className="guide-faq-list">
          {guide.faqs.map((faq) => <details key={faq.id}><summary>{faq.question}</summary><div><p>{faq.answer}</p><SourceLinks item={faq} guide={guide} /></div></details>)}
        </div>
      </section>

      {guide.emergencyInformation.length > 0 ? (
        <section id="emergency-information" className="guide-section guide-emergency-section" aria-labelledby="emergency-information-title">
          <h2 id="emergency-information-title"><AlertTriangle aria-hidden /> Emergency information</h2>
          <SourcedList items={guide.emergencyInformation} guide={guide} />
        </section>
      ) : null}

      <section id="official-sources" className="guide-section" aria-labelledby="sources-title">
        <p className="section-label">Verification</p>
        <h2 id="sources-title">Official sources</h2>
        <div className="guide-source-list">
          {guide.officialSources.map((source) => <article aria-label={`Official source: ${source.publisher} — ${source.title}`} key={source.id}><ShieldCheck aria-hidden /><div><h3>{source.publisher}</h3><p>{source.title}</p><p>Checked <time dateTime={source.checkedAt}>{source.checkedAt}</time></p><a aria-label={`Open ${source.title} from ${source.publisher} in a new tab`} href={source.url} rel="noreferrer" target="_blank">Open official source <ExternalLink aria-hidden /></a></div></article>)}
        </div>
        <p className="review-stamp"><CheckCircle2 aria-hidden /> Human-reviewed by {guide.reviewer.name}, {guide.reviewer.role}, on <time dateTime={guide.reviewer.reviewedAt}>{guide.reviewer.reviewedAt}</time>. Confidence: {guide.confidenceLevel}. Last verified <time dateTime={guide.verifiedAt}>{guide.verifiedAt}</time>; updated <time dateTime={guide.updatedAt}>{guide.updatedAt}</time>.</p>
      </section>

      {guide.contactOptions.length > 0 ? (
        <section id="contact-options" className="guide-section" aria-labelledby="contacts-title"><h2 id="contacts-title">Contact options</h2><ul className="guide-contact-list">{guide.contactOptions.map((contact) => <li key={contact.id}><strong>{contact.label}</strong><ContactValue contact={contact} /><SourceLinks item={contact} guide={guide} /></li>)}</ul></section>
      ) : null}

      <section id="next-actions" className="guide-section" aria-labelledby="next-actions-title">
        <h2 id="next-actions-title">What to do next</h2>
        <SourcedList items={guide.nextActions} guide={guide} />
      </section>

      <aside className="safety-note" role="note" aria-label="Important guide disclaimer"><strong>Important</strong> {guide.disclaimer}</aside>
    </>
  );
}

function BriefGuide({ entity }: { entity: ContentEntity }) {
  const municipal = Boolean(entity.cityId);
  return (
    <>
      <section className="guide-section guide-quick-answer" id="quick-answer" aria-labelledby="brief-answer-title">
        <p className="section-label">Source-backed summary</p>
        <h2 id="brief-answer-title">What this record confirms</h2>
        <p>{entity.summary}</p>
      </section>
      <aside className="guide-depth-note" role="note" aria-label="Guide publication status">
        <FileText aria-hidden />
        <div><strong>Step-by-step guide not yet released</strong><p>This page is a verified starting point, not a complete procedure. Check the responsible source for current requirements{municipal && entity.cityId ? ` and ${titleCase(entity.cityId)}-specific steps` : ""}.</p></div>
      </aside>
      <section className="guide-section" id="next-actions" aria-labelledby="brief-next-actions-title">
        <h2 id="brief-next-actions-title">What to do next</h2>
        <ol className="next-steps">
          <li><span>1</span><div><strong>Check applicability</strong><p>Confirm that the source covers your municipality and personal situation.</p></div></li>
          <li><span>2</span><div><strong>Read the official page</strong><p>Use the current requirements from the responsible institution before acting.</p></div></li>
          <li><span>3</span><div><strong>Save or share this record</strong><p>Keep the stable YouNew link available while the full practical guide is under editorial review.</p></div></li>
        </ol>
      </section>
    </>
  );
}

export function GuideDetail({ entity, related }: { entity: ContentEntity; related: readonly ContentEntity[] }) {
  const guide = entity.practicalGuide;
  const heroImage = preferredMedia(entity.images, ["hero", "gallery", "thumbnail"]);
  const summary = guide?.shortSummary.text ?? entity.summary;
  const reportSubject = encodeURIComponent(`Outdated information: ${entity.title} (${entity.id})`);
  const reportBody = encodeURIComponent(`Page: https://younew.nl${entity.route}/\nCanonical ID: ${entity.id}\n\nWhat appears outdated or incorrect?\n\nOfficial source to review (if known):\n`);
  const structuredData = guide ? {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "HowTo",
        name: guide.title,
        description: guide.shortSummary.text,
        url: `https://younew.nl${entity.route}/`,
        image: heroImage?.url,
        inLanguage: guide.locale,
        dateModified: guide.updatedAt,
        step: guide.numberedSteps.map((step) => ({ "@type": "HowToStep", position: step.position, name: step.title, text: step.body })),
        citation: guide.officialSources.map((source) => source.url)
      },
      {
        "@type": "FAQPage",
        mainEntity: guide.faqs.map((faq) => ({ "@type": "Question", name: faq.question, acceptedAnswer: { "@type": "Answer", text: faq.answer } }))
      }
    ]
  } : {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: entity.title,
    description: entity.summary,
    url: `https://younew.nl${entity.route}/`,
    inLanguage: "en",
    dateModified: entity.updatedAt,
    isBasedOn: entity.source.url,
    image: heroImage?.url
  };

  return (
    <article id="guide-article" className="guide-detail" data-guide-depth={guide ? "practical" : "summary"} aria-labelledby="guide-title" aria-describedby="guide-summary">
      <RecentViewTracker item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} />
      <ReadingProgress targetId="guide-article" />
      <header className="entity-detail-hero section-shell">
        <Breadcrumbs items={[{ label: "Guides", href: "/guides" }, { label: entity.title }]} />
        <div className="entity-detail-heading">
          <div><span className="entity-kind">{guide ? "Practical guide" : "Verified summary"}</span><h1 id="guide-title">{guide?.title ?? entity.title}</h1><p id="guide-summary">{summary}</p>{guide ? <dl className="guide-hero-metadata" aria-label="Guide details"><div><dt><BookOpen aria-hidden /> Reading time</dt><dd>{guide.readingTimeMinutes} minutes</dd></div><div><dt><ShieldCheck aria-hidden /> Last verified</dt><dd><time dateTime={guide.verifiedAt}>{guide.verifiedAt}</time></dd></div><div><dt>Reviewed by</dt><dd>{guide.reviewer.name}, {guide.reviewer.role}</dd></div></dl> : <dl className="guide-hero-metadata" aria-label="Record verification details"><div><dt><ShieldCheck aria-hidden /> Last verified</dt><dd><time dateTime={entity.verifiedAt}>{entity.verifiedAt}</time></dd></div><div><dt>Source</dt><dd>{entity.source.publisher}</dd></div></dl>}</div>
          <div className="detail-actions guide-actions" role="group" aria-label="Guide actions"><SaveButton item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} /><ShareButton title={entity.title} /><PrintButton /></div>
        </div>
        {heroImage ? <ContentMedia asset={heroImage} variant="hero" eager /> : null}
      </header>

      <div className="section-shell guide-detail-layout">
        <div className="guide-main-copy">{guide ? <FullPracticalGuide guide={guide} /> : <BriefGuide entity={entity} />}</div>
        {!guide ? (
          <aside className="source-card guide-source-card" aria-label={`Source verification: ${entity.source.publisher}`}><ShieldCheck aria-hidden /><p className="source-label">{entity.trust.officialSource ? "Official public source" : "Responsible source"}</p><h2>{entity.source.publisher}</h2><p>{entity.source.title}</p><dl><div><dt>Last verified</dt><dd><time dateTime={entity.verifiedAt}>{entity.verifiedAt}</time></dd></div><div><dt>Jurisdiction</dt><dd>Netherlands{entity.cityId ? ` · ${titleCase(entity.cityId)}` : ""}</dd></div></dl><a className="button button-primary" aria-label={`Open ${entity.source.title} from ${entity.source.publisher} in a new tab`} href={entity.source.url} rel="noreferrer" target="_blank">Open source <ExternalLink aria-hidden /></a></aside>
        ) : null}
      </div>

      <div className="section-shell guide-report-row"><a className="report-link" href={`mailto:support@younew.nl?subject=${reportSubject}&body=${reportBody}`}><Flag aria-hidden /> Report outdated information</a></div>

      {related.length > 0 ? <section className="section-shell related-section" aria-labelledby="related-title"><div className="listing-heading"><div><span>Continue safely</span><h2 id="related-title">Related published content</h2></div></div><div className="entity-grid compact-grid">{related.slice(0, 3).map((item) => <EntityCard entity={item} key={item.id} />)}</div></section> : null}
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
    </article>
  );
}
