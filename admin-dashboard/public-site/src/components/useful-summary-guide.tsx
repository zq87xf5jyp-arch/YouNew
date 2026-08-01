import { AlertTriangle, ChevronDown, Clock3, Euro, ExternalLink, FileCheck2, IdCard, MapPin, RefreshCcw, ShieldCheck, Users } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { SaveButton } from "@/components/save-button";
import { ShareButton } from "@/components/share-button";
import type { ContentEntity } from "@/lib/content";
import type { CuratedSummaryFact, CuratedSummaryGuide } from "@/lib/content/curated-summary-guides";
import styles from "./useful-summary-guide.module.css";

const factIcons = { who: Users, bring: IdCard, timing: Clock3, cost: Euro } satisfies Record<CuratedSummaryFact["id"], typeof Users>;

function readableDate(value: string) {
  return new Intl.DateTimeFormat("en-GB", { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" }).format(new Date(`${value}T00:00:00Z`));
}

export function UsefulSummaryGuide({ entity, summary }: { entity: ContentEntity; summary: CuratedSummaryGuide }) {
  return (
    <div className={styles.page}>
      <header className={styles.hero}>
        <div className={styles.shell}>
          <Breadcrumbs items={[{ label: "Guides", href: "/guides" }, { label: summary.title }]} />
          <p className={styles.context}><ShieldCheck aria-hidden /> {summary.context}</p>
          <h1 id="guide-title">{summary.title}</h1>
          <p className={styles.answer} id="guide-summary">{summary.answer}</p>
          <div className={styles.facts} aria-label="Key application facts">
            {summary.facts.map((fact) => {
              const Icon = factIcons[fact.id];
              return (
                <details className={styles.fact} key={fact.id}>
                  <summary><span className={styles.factIcon}><Icon aria-hidden /></span><strong>{fact.label}</strong><span className={styles.factValue}>{fact.value}</span><ChevronDown className={styles.chevron} aria-hidden /></summary>
                  <p>{fact.detail}</p>
                </details>
              );
            })}
          </div>
          <a className={styles.primaryAction} href={summary.sourceUrl} rel="noreferrer" target="_blank" aria-label={`${summary.primaryActionLabel} — opens the official City of Amsterdam website in a new tab`}>
            {summary.primaryActionLabel}<ExternalLink aria-hidden />
          </a>
          <p className={styles.trustLine}><ShieldCheck aria-hidden /><span>Checked <time dateTime={summary.checkedAt}>{readableDate(summary.checkedAt)}</time></span><span aria-hidden>·</span><span>Official {summary.sourcePublisher} source</span></p>
          <div className={styles.actions} role="group" aria-label="Guide actions">
            <SaveButton item={{ id: entity.id, route: entity.route, title: summary.title, kind: entity.type }} />
            <ShareButton title={summary.title} />
          </div>
        </div>
      </header>
      <div className={styles.content}>
        <div className={styles.shell}>
          <section className={styles.section} aria-labelledby="steps-title">
            <p className={styles.eyebrow}>Practical route</p><h2 id="steps-title">Steps</h2>
            <p className={styles.sectionIntro}>Follow the route that matches your application. Confirm the current requirements on Amsterdam.nl before you go.</p>
            <ol className={styles.steps}>{summary.steps.map((step, index) => <li key={step.id}><span className={styles.stepNumber} aria-hidden>{index + 1}</span><details open={index === 0}><summary><strong>{step.title}</strong><ChevronDown aria-hidden /></summary><p>{step.body}</p></details></li>)}</ol>
          </section>
          <section className={styles.section} aria-labelledby="situations-title">
            <p className={styles.eyebrow}>Different situation</p><h2 id="situations-title">Exchange, loss or theft</h2>
            <div className={styles.situationList}>{summary.otherSituations.map((situation, index) => <article key={situation.id}>{index === 0 ? <RefreshCcw aria-hidden /> : <AlertTriangle aria-hidden />}<div><h3>{situation.title}</h3><p>{situation.body}</p></div></article>)}</div>
          </section>
          <section className={styles.section} aria-labelledby="faq-title">
            <p className={styles.eyebrow}>Quick answers</p><h2 id="faq-title">Frequently asked questions</h2>
            <div className={styles.faqList}>{summary.faq.map((item) => <details key={item.id}><summary><strong>{item.title}</strong><ChevronDown aria-hidden /></summary><p>{item.body}</p></details>)}</div>
          </section>
          <section className={`${styles.section} ${styles.sourceSection}`} aria-labelledby="official-source-title">
            <FileCheck2 aria-hidden /><div><p className={styles.eyebrow}>Official source</p><h2 id="official-source-title">{summary.sourcePublisher}</h2><p>{summary.sourceTitle}. Fees, requirements and processing times can change, so use the official page before acting.</p><a href={summary.sourceUrl} rel="noreferrer" target="_blank">Open official source <ExternalLink aria-hidden /></a></div>
          </section>
          <p className={styles.localityNote}><MapPin aria-hidden /> This summary applies to the municipality of Amsterdam.</p>
        </div>
      </div>
    </div>
  );
}
