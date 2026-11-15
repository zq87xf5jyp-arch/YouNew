import Link from "next/link";
import Image from "next/image";
import {GuideEngagement} from "@/components/guide-engagement";
import {Breadcrumbs} from "@/components/breadcrumbs";
import {SaveButton} from "@/components/save-button";
import {ShareButton} from "@/components/share-button";
import {ReadingProgress} from "@/components/reading-progress";
import {TrackedOfficialSourceLink} from "@/components/tracked-official-source-link";
import {serializeJsonLd} from "@/lib/seo/json-ld";
import type {PracticalGuide, PracticalGuideDraft, GuideSourcedText} from "@/lib/content/types";
import "@/styles/guide.css";
import "@/styles/editorial.css";

type Guide = PracticalGuide | PracticalGuideDraft;
export type GuideNavigation = {title: string; href: string};

/** Both locales and the isolated review surface use the same semantic renderer. */
export function PracticalGuideArticle({guide, alternate, before, next, media}: {
  guide: Guide; alternate?: GuideNavigation; before?: GuideNavigation; next?: GuideNavigation;
  media?: {url: string; alt: string; attribution: string};
}) {
  const nl = guide.locale === "nl";
  const draft = guide.status === "draft";
  const t = (en: string, dutch: string) => nl ? dutch : en;
  const route = guide.seo.canonicalPath;
  const sources = (item: {sourceIds: readonly string[]}) => <span className="guide-inline-sources" aria-label={t("Sources", "Bronnen")}>{item.sourceIds.map(id => guide.officialSources.find(s => s.id === id)).filter(s => !!s).map(s => <TrackedOfficialSourceLink key={s.id} href={s.url} contentId={guide.id} target="_blank" rel="noreferrer">{s.publisher}</TrackedOfficialSourceLink>)}</span>;
  const list = (items: readonly GuideSourcedText[]) => <ul className="guide-sourced-list">{items.map(item => <li key={item.id}><span>{item.text}</span>{sources(item)}</li>)}</ul>;
  const estimate = (value: Guide["estimatedTime"]) => value.state === "known" ? `${value.value}${value.currency ? ` ${value.currency}` : ""}` : value.state === "varies" ? t("Depends on your situation", "Afhankelijk van je situatie") : value.state === "not_applicable" ? t("Not applicable", "Niet van toepassing") : t("Not confirmed", "Niet bevestigd");
  return <article id="guide-article" className="section-shell editorial-detail guide-detail" lang={guide.locale} data-guide-depth="practical" data-guide-status={guide.status}>
    <ReadingProgress targetId="guide-article"/>
    {!draft ? <GuideEngagement contentId={guide.id}/> : null}
    {draft ? <aside className="safety-note" role="note"><strong>{t("Editorial draft — not published", "Redactioneel concept — niet gepubliceerd")}</strong><p>{t("Facts, language and media still require the owner's editorial approval. This preview is excluded from the public catalogue.", "Feiten, taal en beeld vereisen nog redactionele goedkeuring van de eigenaar. Dit voorbeeld staat niet in de openbare catalogus.")}</p></aside> : null}
    <Breadcrumbs locale={nl ? "nl" : "en"} items={[...(guide.applicability.cityIds.includes('leiden') ? [{label:"Leiden", href:nl?"/nl/leiden/":"/leiden/"}] : []), {label:guide.title}]}/>
    <header><span className="entity-kind">{t("Step-by-step guide", "Stappenplan")}</span><h1>{guide.title}</h1><p className="editorial-summary">{guide.shortSummary.text}</p>{sources(guide.shortSummary)}
      <p>{t("Sources checked", "Bronnen gecontroleerd")} <time dateTime={guide.verifiedAt}>{guide.verifiedAt}</time> · {guide.readingTimeMinutes} min</p>
      <p>{guide.reviewer ? `${t("Reviewed by", "Beoordeeld door")} ${guide.reviewer.name} · ${guide.reviewer.reviewedAt}` : t("Editorial review: pending", "Redactionele beoordeling: in afwachting")}</p>
      <div className="editorial-actions">{!draft ? <><SaveButton item={{id:guide.id,route,title:guide.title,kind:"guide"}}/><ShareButton title={guide.title}/></> : null}{alternate ? <Link href={alternate.href} hrefLang={nl?"en":"nl"}>{alternate.title}</Link> : null}</div>
      {media ? <figure><Image unoptimized src={media.url} alt={media.alt} width="900" height="240" style={{width:"100%",height:"auto"}}/><figcaption>{media.attribution}</figcaption></figure> : null}
    </header>
    <nav className="guide-toc" aria-label={t("On this page", "Op deze pagina")}><ol>{[["before",t("Before you start","Voor je begint")],["steps",t("Steps","Stappen")],["documents",t("Documents, time and cost","Documenten, tijd en kosten")],["faq","FAQ"],["sources",t("Sources and updates","Bronnen en wijzigingen")]].map(([id,title])=><li key={id}><a href={`#${id}`}>{title}</a></li>)}</ol></nav>
    <section id="before" className="guide-section"><h2>{t("Before you start", "Voor je begint")}</h2><h3>{t("Who this is for", "Voor wie")}</h3><p>{guide.whoThisIsFor.text}</p>{sources(guide.whoThisIsFor)}<h3>{t("When you need it", "Wanneer nodig")}</h3><p>{guide.whenYouNeedIt.text}</p>{sources(guide.whenYouNeedIt)}<p>{guide.jurisdiction.note}</p>{sources(guide.jurisdiction)}{list(guide.prerequisites)}
      {before ? <p>{t("Before this", "Eerst")}: <Link href={before.href}>{before.title}</Link></p> : null}
    </section>
    <section id="steps" className="guide-section"><h2>{t("What to do", "Wat je moet doen")}</h2><ol className="practical-steps">{guide.numberedSteps.map(step=><li key={step.id}><span className="practical-step-number" aria-hidden>{step.position}</span><div><h3>{step.title}</h3><p>{step.body}</p>{sources(step)}</div></li>)}</ol></section>
    <section id="documents" className="guide-section"><h2>{t("Documents, time and cost", "Documenten, tijd en kosten")}</h2>{list(guide.requiredDocuments)}<dl className="guide-facts"><div><dt>{t("Time", "Tijd")}</dt><dd>{estimate(guide.estimatedTime)}<p>{guide.estimatedTime.note}</p>{sources(guide.estimatedTime)}</dd></div><div><dt>{t("Cost", "Kosten")}</dt><dd>{estimate(guide.estimatedCost)}<p>{guide.estimatedCost.note}</p>{sources(guide.estimatedCost)}</dd></div></dl></section>
    {guide.sections.map(section=><section className="guide-section" key={section.id}><h2>{section.title}</h2><p>{section.body}</p>{sources(section)}</section>)}
    <section className="guide-section"><h2>{t("Checklist", "Checklist")}</h2>{list(guide.checklist)}</section>
    <section className="guide-section"><h2>{t("Common mistakes", "Veelgemaakte fouten")}</h2>{list(guide.commonMistakes)}<h3>{t("Important", "Let op")}</h3>{list(guide.warnings)}<h3>{t("Practical tips", "Praktische tips")}</h3>{list(guide.tips)}</section>
    <section id="faq" className="guide-section"><h2>{t("Frequently asked questions", "Veelgestelde vragen")}</h2><div className="guide-faq-list">{guide.faqs.map(faq=><details key={faq.id}><summary>{faq.question}</summary><div><p>{faq.answer}</p>{sources(faq)}</div></details>)}</div></section>
    <section id="sources" className="guide-section"><h2>{t("Official sources", "Officiële bronnen")}</h2><ul className="guide-sourced-list">{guide.officialSources.map(source=><li key={source.id}><TrackedOfficialSourceLink href={source.url} contentId={guide.id} target="_blank" rel="noreferrer">{source.publisher}: {source.title}</TrackedOfficialSourceLink><p>{t("Checked", "Gecontroleerd")} <time dateTime={source.checkedAt}>{source.checkedAt}</time></p></li>)}</ul>
      <h3>{t("Change history", "Wijzigingsgeschiedenis")}</h3><p><time dateTime={guide.updatedAt}>{guide.updatedAt}</time> — {t("This sourced version was prepared. Recheck when your circumstances change and before acting.", "Deze onderbouwde versie is voorbereid. Controleer opnieuw bij een veranderde situatie en voordat je handelt.")}</p>
      <p><a href={`mailto:support@younew.nl?subject=${encodeURIComponent(`Correction: ${guide.id} (${guide.locale})`)}`}>{t("Report a correction", "Meld een correctie")}</a></p>
    </section>
    <section className="guide-section"><h2>{t("Continue with the responsible institution", "Ga verder bij de verantwoordelijke instantie")}</h2><ul>{guide.contactOptions.map(contact=><li key={contact.id}>{contact.kind==='url' ? <TrackedOfficialSourceLink href={contact.value} contentId={guide.id} guideAction={!draft} target="_blank" rel="noreferrer">{contact.label}</TrackedOfficialSourceLink> : contact.kind==='phone' || contact.kind==='email' ? <a href={`${contact.kind==='phone'?'tel':'mailto'}:${contact.value}`}>{contact.label}: {contact.value}</a> : <span>{contact.label}: {contact.value}</span>}{sources(contact)}</li>)}</ul>{list(guide.emergencyInformation)}</section>
    <section className="guide-section"><h2>{t("Next step", "Volgende stap")}</h2>{list(guide.nextActions)}{next ? <Link href={next.href}>{next.title}</Link> : null}<p><Link href="/arrival-planner/">{t("Open the arrival planner", "Open de aankomstplanner")}</Link></p></section>
    <aside className="safety-note"><p>{guide.disclaimer}</p>{list(guide.emergencyInformation)}</aside>
    {!draft ? <script type="application/ld+json" dangerouslySetInnerHTML={{__html:serializeJsonLd({"@context":"https://schema.org","@type":"Article",headline:guide.title,description:guide.shortSummary.text,url:`https://younew.nl${route}/`,inLanguage:guide.locale,dateModified:guide.updatedAt,citation:guide.officialSources.map(s=>s.url),publisher:{"@id":"https://younew.nl/#organization"}})}}/> : null}
  </article>;
}
