import Link from "next/link";
import {
  ArrowRight,
  CheckCircle2,
  Database,
  Gauge,
  Globe2,
  LayoutDashboard,
  Workflow
} from "lucide-react";
import { systemEvidence } from "@/config/system-evidence";

const surfaceIcons = {
  workspace: Workflow,
  admin: LayoutDashboard,
  supabase: Database,
  product: Globe2
} as const;

const verifiedDate = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "UTC"
}).format(new Date(`${systemEvidence.asOf}T00:00:00Z`));

export function SystemEvidence({ compact = false }: { compact?: boolean }) {
  const metrics = [
    [systemEvidence.metrics.publishedRecords, "published records"],
    [systemEvidence.metrics.staticRoutes, "static routes"],
    [systemEvidence.metrics.indexableUrls, "indexable URLs"],
    [systemEvidence.metrics.passingWebAdminAiTests, "passing web, Admin and AI tests"]
  ] as const;

  return (
    <section
      className={`system-evidence${compact ? " system-evidence-compact" : ""}`}
      aria-labelledby={compact ? "homepage-system-title" : "status-system-title"}
      data-reveal={compact ? "" : undefined}
    >
      <div className="system-evidence-heading">
        <div>
          <p className="section-label cyan">Product system</p>
          <h2 id={compact ? "homepage-system-title" : "status-system-title"}>
            One connected product, from operations to the next step.
          </h2>
          <p>
            YouNew connects its public website and iPhone experience to governed content,
            operational control and a visible source trail.
          </p>
        </div>
        <aside>
          <Gauge aria-hidden />
          <span>
            <strong>{systemEvidence.posture}</strong>
            Verified {verifiedDate}
          </span>
        </aside>
      </div>

      <div className="system-evidence-body">
        <ol className="system-flow" aria-label="YouNew system flow">
          {systemEvidence.surfaces.map((surface) => {
            const Icon = surfaceIcons[surface.id];
            return (
              <li key={surface.id}>
                <Icon aria-hidden />
                <span>
                  <strong>{surface.title}</strong>
                  <small>{surface.description}</small>
                </span>
                <ArrowRight aria-hidden />
              </li>
            );
          })}
        </ol>

        <div className="system-proof">
          <dl>
            {metrics.map(([value, label]) => (
              <div key={label}>
                <dt>{value}</dt>
                <dd>{label}</dd>
              </div>
            ))}
          </dl>
          <p>
            <CheckCircle2 aria-hidden />
            Evidence is dated and scoped. Product availability is kept separate from final
            release authority.
          </p>
          {compact ? (
            <Link href="/status">
              View the verified system status <ArrowRight aria-hidden />
            </Link>
          ) : null}
        </div>
      </div>

      {compact ? null : (
        <div className="system-release-boundary">
          <strong>Release boundary</strong>
          <p>
            The public web product and App Store listing are available. The current source
            package remains a controlled release candidate until its final signed iOS,
            executable test, backup-and-restore and authenticated Admin E2E gates are closed.
          </p>
        </div>
      )}
    </section>
  );
}
