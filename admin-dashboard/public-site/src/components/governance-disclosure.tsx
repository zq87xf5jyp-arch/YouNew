import { AlertTriangle, BadgeCheck, Info } from "lucide-react";
import { governanceDisclosure, hasValidConfidenceEvidence } from "@/lib/content";
import type { ContentEntity } from "@/lib/content";

export function GovernanceDisclosure({ entity }: { entity: ContentEntity }) {
  const disclosure = governanceDisclosure(entity.governance);
  const governance = entity.governance;
  const jurisdiction = governance
    ? governance.jurisdiction.municipalityName
      ?? governance.jurisdiction.provinceName
      ?? (governance.jurisdiction.level === "national" ? "Netherlands" : governance.jurisdiction.level)
    : entity.cityId?.replaceAll("-", " ") ?? "Netherlands";

  return (
    <section
      className={`governance-disclosure governance-disclosure-${disclosure.tone}`}
      aria-labelledby={`governance-${entity.id}`}
    >
      <div className="governance-disclosure-heading">
        {disclosure.tone === "success" ? <BadgeCheck aria-hidden /> : <AlertTriangle aria-hidden />}
        <div>
          <p>Content governance</p>
          <h2 id={`governance-${entity.id}`}>{disclosure.label}</h2>
        </div>
      </div>
      <p>{disclosure.explanation}</p>
      <dl>
        <div><dt>Effective status</dt><dd>{disclosure.effectiveStatus.replaceAll("_", " ")}</dd></div>
        <div><dt>Source</dt><dd>{governance?.sourcePublisher ?? entity.source.publisher}</dd></div>
        <div><dt>Checked</dt><dd>{governance?.lastVerifiedAt ?? "Governed verification date not established"}</dd></div>
        <div><dt>Jurisdiction</dt><dd>{jurisdiction}</dd></div>
        <div>
          <dt>Confidence evidence</dt>
          <dd>
            {governance && hasValidConfidenceEvidence(governance)
              ? `${governance.confidenceScore}/100 · formula v${governance.confidenceScoreVersion}`
              : "not established"}
          </dd>
        </div>
      </dl>
      <details>
        <summary><Info aria-hidden /> Why am I seeing this?</summary>
        <p>
          This record is shown from the published DataProject projection. Its status is derived from source,
          freshness and jurisdiction evidence; the numeric index does not override a failed governance gate.
        </p>
      </details>
    </section>
  );
}
