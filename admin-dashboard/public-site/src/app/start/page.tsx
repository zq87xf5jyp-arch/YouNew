import Link from "next/link";
import { ArrowRight, GraduationCap, HeartPulse, Home, ShieldCheck } from "lucide-react";
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

const commonJourneys = [
  {
    title: "New in the Netherlands",
    description: "Registration, housing and municipal basics.",
    href: "/journeys",
    icon: ShieldCheck,
    state: "Published Amsterdam steps"
  },
  {
    title: "International student",
    description: "Housing starting points and available local guidance.",
    href: "/journeys",
    icon: GraduationCap,
    state: "Limited published coverage"
  },
  {
    title: "Looking for housing",
    description: "Review current housing summaries and responsible sources.",
    href: "/journeys",
    icon: Home,
    state: "Published Amsterdam summaries"
  },
  {
    title: "Healthcare setup",
    description: "Use responsible sources while the practical guide is reviewed.",
    href: "/journeys",
    icon: HeartPulse,
    state: "Guide not published yet"
  }
] as const;

export default function StartPage() {
  const content = getPublicContent();
  const municipalities = getMunicipalities().map((municipality) => ({
    slug: municipality.slug,
    name: municipality.name,
    officialWebsite: municipality.officialWebsite
  }));
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
        <p>Choose your situation, location and goal. YouNew will connect you to the best published guidance and responsible source—without filling content gaps with invented instructions.</p>
      </section>

      <section className="section-shell start-planner-section" aria-label="Personal route planner">
        <NextStepPlanner guides={guides} municipalities={municipalities} />
      </section>

      <section className="section-shell common-journeys-section" aria-labelledby="common-journeys-title">
        <div className="common-journeys-heading">
          <div>
            <h2 id="common-journeys-title">Common journeys</h2>
            <p>Continue with a published sequence or see exactly which coverage is still under review.</p>
          </div>
          <Link href="/journeys/">View all journeys <ArrowRight aria-hidden /></Link>
        </div>
        <div className="common-journey-rail">
          {commonJourneys.map(({ title, description, href, icon: Icon, state }) => (
            <Link href={href} key={title}>
              <Icon aria-hidden />
              <span><strong>{title}</strong><small>{description}</small><em>{state}</em></span>
              <ArrowRight aria-hidden />
            </Link>
          ))}
        </div>
        <div className="planner-privacy-strip">
          <ShieldCheck aria-hidden />
          <p><strong>Your choices stay in this browser.</strong> Route selections are not an account record, official task status or iOS sync.</p>
          <Link href="/privacy/">Privacy choices</Link>
        </div>
      </section>
    </PageShell>
  );
}
