import Link from "next/link";
import { ArrowRight, ShieldCheck } from "lucide-react";
import { getNationalGuides, nationalGuidesVerifiedAt, type NationalGuide } from "@/lib/search/national-guides";

const groups = [
  {
    id: "arrival-home",
    title: "Arrival and home",
    description: "Residence, registration, housing, utilities, banking and transport.",
    guideIds: [
      "national.immigration",
      "national.documents",
      "national.housing",
      "national.utilities-moving",
      "national.banking",
      "national.transport"
    ]
  },
  {
    id: "work-money-rights",
    title: "Work, money and rights",
    description: "Employment, self-employment, tax, allowances, consumer problems and legal help.",
    guideIds: [
      "national.work",
      "national.business-zzp",
      "national.taxes",
      "national.benefits",
      "national.consumer-rights",
      "national.debt-legal-help"
    ]
  },
  {
    id: "health-family",
    title: "Health and family",
    description: "Healthcare, mental health, dentistry, medicines, childcare and pregnancy.",
    guideIds: [
      "national.healthcare",
      "national.mental-health",
      "national.dental-care",
      "national.medicines",
      "national.family-childcare",
      "national.pregnancy"
    ]
  },
  {
    id: "daily-life-safety",
    title: "Daily life and safety",
    description: "Education, connectivity, rules, discrimination support and pets.",
    guideIds: [
      "national.education",
      "national.telecom",
      "national.rules-fines",
      "national.lgbtiq-support",
      "national.pets"
    ]
  }
] as const;

function guideMap(guides: readonly NationalGuide[]) {
  return new Map(guides.map((guide) => [guide.id, guide]));
}

export function NationalGuideDirectory() {
  const guides = getNationalGuides();
  const byId = guideMap(guides);
  const verifiedAt = nationalGuidesVerifiedAt();

  return (
    <section className="section-shell national-guide-directory" aria-labelledby="national-guides-title">
      <header>
        <div>
          <h2 id="national-guides-title">National practical guides</h2>
          <p>Start with a source-checked route that works across the Netherlands, then add municipality details where they exist.</p>
        </div>
        <span><ShieldCheck aria-hidden /> {guides.length} guides · sources checked {verifiedAt}</span>
      </header>
      <div className="national-guide-groups">
        {groups.map((group) => (
          <section aria-labelledby={`national-guide-group-${group.id}`} key={group.id}>
            <div>
              <h3 id={`national-guide-group-${group.id}`}>{group.title}</h3>
              <p>{group.description}</p>
            </div>
            <nav aria-label={`${group.title} guides`}>
              {group.guideIds.flatMap((guideId) => {
                const guide = byId.get(guideId);
                return guide ? [
                  <Link href={`/essentials/${guide.slug}/`} key={guide.id}>
                    <span><strong>{guide.title}</strong><small>{guide.summary}</small></span>
                    <ArrowRight aria-hidden />
                  </Link>
                ] : [];
              })}
            </nav>
          </section>
        ))}
      </div>
    </section>
  );
}
