import Link from "next/link";
import { ArrowRight, ShieldAlert, ShieldCheck } from "lucide-react";
import releaseTruth from "@/generated/release-truth-public.json";

function metricValue(metric: { value: number | string | null; state: string; unit: string }) {
  if (metric.state === "not_applicable") return "N/A";
  if (metric.state !== "measured") return "—";
  return `${metric.value}${metric.unit === "percent" ? "%" : ""}`;
}

export function KnowledgeTrustSummary({ compact = false }: { compact?: boolean }) {
  const passedGates = Object.values(releaseTruth.gates).filter((result) => result === "pass").length;
  const totalGates = Object.keys(releaseTruth.gates).length;

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
          municipality applicability or a blocked release gate.
        </p>
      </div>

      <dl className="knowledge-trust-metrics" aria-label="Current governed knowledge evidence">
        <div>
          <dt>Packaged coverage</dt>
          <dd>{metricValue(releaseTruth.publication.packagedCoverage)}</dd>
          <small>{releaseTruth.publication.packagedPublishedRecords} / {releaseTruth.publication.inventoryRecords} governed records</small>
        </div>
        <div>
          <dt>Packaged published</dt>
          <dd>{releaseTruth.publication.packagedPublishedRecords}</dd>
          <small>measured build-time artifact</small>
        </div>
        <div>
          <dt>Link health</dt>
          <dd>{metricValue(releaseTruth.linkHealth)}</dd>
          <small>{releaseTruth.linkHealth.state} · network check required</small>
        </div>
        <div>
          <dt>Hard release gates</dt>
          <dd>{passedGates} / {totalGates}</dd>
          <small>Unknown evidence cannot pass</small>
        </div>
      </dl>

      <aside className="knowledge-trust-decision">
        <ShieldAlert aria-hidden />
        <p>
          <strong>Technical release status: {releaseTruth.technicalVerdict}</strong>
          <span>{releaseTruth.verdictReason}</span>
        </p>
        <Link href="/status/">System evidence <ArrowRight aria-hidden /></Link>
      </aside>
    </section>
  );
}
