"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ExternalLink, MapPin, ShieldCheck } from "lucide-react";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { canonicalCityId } from "@/lib/search/geography";

export type ActionPanelMunicipality = Readonly<{
  slug: string;
  name: string;
  officialWebsite: string | null;
}>;

type NationalGuideActionPanelProps = Readonly<{
  guideId: string;
  guideSlug: string;
  guideTitle: string;
  shortAnswer: string;
  primaryAction: string;
  warning: string;
  verifiedAt: string;
  sourceCount: number;
  nationalSourceUrl: string;
  municipalities: readonly ActionPanelMunicipality[];
}>;

export function NationalGuideActionPanel({
  guideId,
  guideSlug,
  guideTitle,
  shortAnswer,
  primaryAction,
  warning,
  verifiedAt,
  sourceCount,
  nationalSourceUrl,
  municipalities
}: NationalGuideActionPanelProps) {
  const [selectedCityId, setSelectedCityId] = useState("");
  useEffect(() => {
    setSelectedCityId(canonicalCityId(new URLSearchParams(window.location.search).get("city")) ?? "");
  }, []);
  const selectedMunicipality = municipalities.find((municipality) => municipality.slug === selectedCityId) ?? null;
  const selectorId = `municipality-${guideSlug}`;

  return (
    <section className="national-guide-action-panel" aria-labelledby={`${guideSlug}-action-title`}>
      <p className="section-label">Start here</p>
      <span className="national-guide-action-task">{guideTitle}</span>
      <h2 id={`${guideSlug}-action-title`}>Your next official step</h2>
      <p className="national-guide-short-answer"><strong>Short answer:</strong> {shortAnswer}</p>
      <form action={`/essentials/${guideSlug}/`} method="get" className="national-guide-municipality-form">
        <label htmlFor={selectorId}>Choose your municipality or city</label>
        <div>
          <select id={selectorId} name="city" value={selectedCityId} onChange={(event) => setSelectedCityId(event.target.value)}>
            <option value="">Select your municipality</option>
            {municipalities.map((municipality) => <option value={municipality.slug} key={municipality.slug}>{municipality.name}</option>)}
          </select>
          <button type="submit">Use municipality</button>
        </div>
      </form>
      <p className="national-guide-primary-action"><strong>Next action:</strong> {primaryAction}</p>
      <div className="national-guide-action-links">
        {selectedMunicipality?.officialWebsite ? (
          <TrackedOfficialSourceLink
            actionPanelCity={selectedMunicipality.slug}
            contentId={`${guideId}.municipality.${selectedMunicipality.slug}`}
            href={selectedMunicipality.officialWebsite}
            rel="noreferrer"
            target="_blank"
          >
            Open {selectedMunicipality.name} official site <ExternalLink aria-hidden />
          </TrackedOfficialSourceLink>
        ) : selectedMunicipality ? (
          <Link href={`/municipalities/${selectedMunicipality.slug}/`}>Open {selectedMunicipality.name} municipality route</Link>
        ) : null}
        <TrackedOfficialSourceLink
          actionPanelCity={selectedMunicipality?.slug ?? "national"}
          contentId={`${guideId}.national`}
          href={nationalSourceUrl}
          rel="noreferrer"
          target="_blank"
        >
          Open national official source <ExternalLink aria-hidden />
        </TrackedOfficialSourceLink>
      </div>
      <dl className="national-guide-action-meta" aria-label="Action panel verification">
        <div><dt><ShieldCheck aria-hidden /> Last checked</dt><dd><time dateTime={verifiedAt}>{verifiedAt}</time></dd></div>
        <div><dt>Official sources</dt><dd>{sourceCount}</dd></div>
      </dl>
      <p className="national-guide-action-warning"><MapPin aria-hidden /> {warning}</p>
      <p className="national-guide-action-boundary">YouNew provides practical navigation, not individual legal, medical or tax advice.</p>
    </section>
  );
}
