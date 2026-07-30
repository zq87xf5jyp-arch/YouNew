import Link from "next/link";
import { ArrowRight, Database, ShieldAlert, ShieldCheck } from "lucide-react";
import trustDashboard from "@/generated/trust-dashboard.json";

type TrustMetric = {
  value: number | null;
  numerator: number | null;
  denominator: number | null;
  evidenceState: string;
};

function metricValue(metric: TrustMetric, suffix = "") {
  return metric.value === null ? "Not established" : `${metric.value}${suffix}`;
}

export function KnowledgeTrustSummary({ compact = false }: { compact?: boolean }) {
  const governedPublic = trustDashboard.metrics.governedPublicCoverage as TrustMetric;
  const pilotCoverage = trustDashboard.metrics.pilotMunicipalityCoverage as TrustMetric;
  const sourceTrust = trustDashboard.metrics.sourceTrustScore as TrustMetric;
  const hardGates = trustDashboard.readiness.hardGates;
  const passedGates = Object.values(hardGates).filter(Boolean).length;
  const totalGates = Object.keys(hardGates).length;

  return (
    <section
      className={`knowledge-trust-summary${compact ? " is-compact" : ""}`}
      aria-labelledby={compact ? "workspace-trust-title" : "business-trust-title"}
    >
      <div className="knowledge-trust-heading">
        <div>
          <ShieldCheck aria-hidden />
          <h2 id={compact ? "workspace-trust-title" : "business-trust-title"}>
            Knowledge trust stays independent from commercial activity.
          </h2>
        </div>
        <p>
          Advertising cannot override official-source ranking, verification status,
          municipality applicability or a failed release gate.
        </p>
      </div>

      <dl className="knowledge-trust-metrics" aria-label="Current governed knowledge evidence">
        <div>
          <dt>Governed public coverage</dt>
          <dd>{metricValue(governedPublic, "%")}</dd>
          <small>{governedPublic.numerator ?? "—"} / {governedPublic.denominator ?? "—"} records</small>
        </div>
        <div>
          <dt>Amsterdam pilot coverage</dt>
          <dd>{metricValue(pilotCoverage, "%")}</dd>
          <small>{pilotCoverage.numerator ?? "—"} / {pilotCoverage.denominator ?? "—"} required topics</small>
        </div>
        <div>
          <dt>Source Trust Score</dt>
          <dd>{metricValue(sourceTrust)}</dd>
          <small>{sourceTrust.evidenceState}</small>
        </div>
        <div>
          <dt>Hard release gates</dt>
          <dd>{passedGates} / {totalGates}</dd>
          <small>Content, AI and user outcomes</small>
        </div>
      </dl>

      <aside className="knowledge-trust-decision">
        {trustDashboard.currentReleaseAuthority === "NO_GO"
          ? <ShieldAlert aria-hidden />
          : <Database aria-hidden />}
        <p>
          <strong>Knowledge candidate: {trustDashboard.currentReleaseAuthority}</strong>
          <span>{trustDashboard.releaseAuthorityReason}</span>
        </p>
        <Link href="/status/">System evidence <ArrowRight aria-hidden /></Link>
      </aside>
    </section>
  );
}
