import { ArrowUpRight, Languages, MapPinned, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { getNationalGuides } from "@/lib/search/national-guides";
import type { LifeDomain } from "@/lib/search/taxonomy";

export function LifeDomainGuide({ domain }: { domain: LifeDomain }) {
  const guideCategory = domain.slug === "sim-telecom" ? "telecom" : domain.slug;
  const nationalGuide = getNationalGuides().find((guide) => guide.category === guideCategory);
  return (
    <section className="section-shell life-domain-guide" aria-labelledby="life-domain-start-title">
      <div className="life-domain-start">
        <div className="listing-heading">
          <div><span>Practical starting point</span><h2 id="life-domain-start-title">Start with the right route</h2><p>General orientation only. The linked authority remains responsible for current rules and individual decisions.</p></div>
        </div>
        <ol>
          {domain.startHere.map((step, index) => <li key={step}><span>{index + 1}</span><p>{step}</p></li>)}
        </ol>
      </div>

      <aside className="life-domain-sources" aria-label="Official starting sources">
        <div><ShieldCheck aria-hidden /><span><strong>Official starting sources</strong><small>Open the responsible source before acting.</small></span></div>
        {nationalGuide ? <Link href={`/essentials/${nationalGuide.slug}/`}>Open the full national guide<ArrowUpRight aria-hidden /></Link> : null}
        {domain.officialSources.map((source) => (
          <a data-analytics-official-source-id={`category.${domain.slug}`} href={source.url} key={source.url} rel="noreferrer" target="_blank">
            {source.name}<ArrowUpRight aria-hidden />
          </a>
        ))}
        <div className="life-domain-meta"><Languages aria-hidden /><span>Search aliases: English, Nederlands, Русский</span></div>
        <div className="life-domain-meta"><MapPinned aria-hidden /><span>National guidance stays visible with a city filter.</span></div>
      </aside>
    </section>
  );
}
