import Link from "next/link";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { NextStepPlanner } from "@/components/next-step-planner";
import { PageShell } from "@/components/page-shell";
import { getPublicContent } from "@/lib/content";
import { getMunicipalities } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Find your next step in the Netherlands",
  "Choose your situation, municipality and priorities to build an honest route through published YouNew guidance and responsible sources.",
  "/start"
);

export default function StartPage() {
  const content = getPublicContent();
  const municipalities = [{
    slug: "national",
    name: "National guidance",
    officialWebsite: "https://www.government.nl/"
  }, ...getMunicipalities().map((municipality) => ({
    slug: municipality.slug,
    name: municipality.name,
    officialWebsite: municipality.officialWebsite
  }))];
  const guides = content.guides.map((guide) => ({
    id: guide.id,
    route: guide.route,
    title: guide.title,
    contentDepth: guide.contentDepth
  }));

  return (
    <PageShell className="start-page">
      <section className="start-hero section-shell" aria-labelledby="start-title">
        <Breadcrumbs items={[{ label: "Start" }]} />
        <h1 id="start-title">Find your next step in the Netherlands.</h1>
        <p>Choose one task, your situation and an area. YouNew will show the strongest published route and responsible source available. No account, email or precise location is needed.</p>
      </section>

      <section className="section-shell start-planner-section" aria-label="Personal route planner">
        <NextStepPlanner guides={guides} municipalities={municipalities} />
      </section>
      <section className="business-section section-shell" aria-labelledby="optional-arrival-planner">
        <p className="section-label cyan">Optional planning tool</p>
        <h2 className="mb-4 text-3xl font-semibold tracking-tight" id="optional-arrival-planner">Keep an editable plan of your own.</h2>
        <p>Arrival Planner is a ready-made HTML template you edit yourself, with JSON save and restore, calendar export and printing. The guidance and route above stay free.</p>
        <p>€14.99 is a test amount only; no real charge. Real sales are not open, and the final sales price and tax treatment are not set. The planned product has no subscription or automatic renewal.</p>
        <Link className="button button-outline" href="/arrival-planner/">Explore the optional Arrival Planner</Link>
      </section>
    </PageShell>
  );
}
