import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { ReleaseReadinessOverview } from "@/components/admin/release-readiness-overview";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { evidenceStateLabel, releaseTruth } from "@/lib/release-truth/static";

export default function ReleasesPage() {
  return (
    <>
      <PageHeader
        title="Release Control"
        description="Один deterministic snapshot для product, DATA PROJECT и production evidence. PARTIAL блокирует deployment, но не выдаётся за regression."
      />
      <div className="mb-8">
        <ReleaseReadinessOverview />
      </div>

      <h2 className="mb-4 text-lg font-semibold">Publication layers</h2>
      <div className="grid gap-6 xl:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle>Governed inventory</CardTitle>
            <CardDescription>Planned, QA and published candidate records under Data Project governance.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Records</span><strong>{releaseTruth.publication.inventory.total}</strong></div>
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Verified candidates</span><strong>{releaseTruth.publication.inventory.verified}</strong></div>
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Next release</span><Badge>{releaseTruth.publication.inventory.nextReleaseID ?? "unknown"}</Badge></div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Packaged published</CardTitle>
            <CardDescription>Only records present in the verified governed runtime manifest.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Records</span><strong>{releaseTruth.publication.packaged.entityCount}</strong></div>
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Evidence</span><Badge variant="success">{evidenceStateLabel(releaseTruth.publication.packaged.state)}</Badge></div>
            <p className="break-all font-mono text-xs text-muted-foreground">{releaseTruth.publication.packaged.datasetFingerprint}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Deployed observation</CardTitle>
            <CardDescription>Production evidence is kept separate from packaged and candidate data.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Exact deployed count</span><strong>{releaseTruth.publication.deployed.entityCount ?? "—"}</strong></div>
            <div className="flex items-center justify-between gap-3"><span className="text-sm text-muted-foreground">Evidence</span><Badge variant="warning">{evidenceStateLabel(releaseTruth.publication.deployed.state)}</Badge></div>
            <p className="text-xs text-muted-foreground">Declared metadata count: {releaseTruth.publication.deployed.declaredEntityCount ?? "unknown"}. Full deployed payload is not independently attested.</p>
          </CardContent>
        </Card>
      </div>

      <section className="mt-6">
        <Card>
          <CardHeader>
            <CardTitle>Source evidence</CardTitle>
            <CardDescription>Each source carries its own state and observation time; generated time alone does not prove freshness.</CardDescription>
          </CardHeader>
          <CardContent className="overflow-x-auto">
            <table className="younew-table">
              <thead><tr><th>Source</th><th>State</th><th>Observed</th><th>Scope</th></tr></thead>
              <tbody>
                {releaseTruth.sources.map((source) => (
                  <tr key={source.id}>
                    <td><p className="font-medium text-foreground">{source.id}</p><p className="break-all text-xs">{source.sourceRef}</p></td>
                    <td><Badge variant={source.state === "measured" ? "success" : source.state === "provisional" ? "warning" : "secondary"}>{evidenceStateLabel(source.state)}</Badge></td>
                    <td>{source.observedAt ?? "—"}</td>
                    <td>{source.scope}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </CardContent>
        </Card>
      </section>
    </>
  );
}
