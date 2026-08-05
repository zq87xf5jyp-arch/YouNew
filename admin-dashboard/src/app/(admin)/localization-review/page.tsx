import { CircleAlert, FileCheck2, Languages, LockKeyhole, Rows3 } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import reviewSnapshot from "@/generated/localization-review.json";
import {
  categoryLabels,
  dimensionLabels,
  guideLabels,
  summarizeLocalizationReview,
  type LocalizationReviewSnapshot
} from "@/lib/localization-review";

const snapshot = reviewSnapshot as LocalizationReviewSnapshot;
const summary = summarizeLocalizationReview(snapshot);

const stats = [
  { label: "Machine drafts", value: summary.drafts, note: `${summary.fieldCount} translated fields`, icon: Languages },
  { label: "Human-reviewed", value: `${summary.reviewed}/${summary.drafts}`, note: "Registered reviewers only", icon: FileCheck2 },
  { label: "Publication eligible", value: `${summary.eligible}/${summary.drafts}`, note: "All four gates required", icon: LockKeyhole },
  { label: "Required checks", value: summary.requiredChecks, note: `${snapshot.review_dimensions.length} per guide-locale`, icon: Rows3 }
];

export default function LocalizationReviewPage() {
  return (
    <>
      <PageHeader
        title="Localization Review"
        description="Read-only evidence snapshot for the 8 release-critical guides in Dutch and Russian. Machine-assisted drafts are never treated as human approval."
      />

      <section className="grid gap-6" aria-labelledby="localization-release-status">
        <Card className="overflow-hidden border-amber-400/30 bg-[radial-gradient(circle_at_top_right,rgba(251,191,36,.12),transparent_24rem),linear-gradient(145deg,rgba(14,29,53,.96),rgba(3,16,35,.96))]">
          <CardHeader className="gap-3 border-b border-border/80 lg:flex-row lg:items-start lg:justify-between">
            <div>
              <CardTitle id="localization-release-status" className="flex items-center gap-2 text-xl">
                <CircleAlert className="size-5 text-amber-300" />
                Localization publication gate
              </CardTitle>
              <CardDescription className="mt-2 max-w-3xl">
                Publication remains blocked until every guide-locale pair has a registered human reviewer and passed, hashed evidence for all required dimensions.
              </CardDescription>
            </div>
            <Badge variant="destructive" className="w-fit text-sm">{summary.releaseStatus}</Badge>
          </CardHeader>
          <CardContent className="grid gap-3 pt-5 sm:grid-cols-2 xl:grid-cols-4">
            {stats.map(({ label, value, note, icon: Icon }) => (
              <div key={label} className="rounded-lg border border-border bg-background/35 p-4">
                <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wide text-cyan-200">
                  <Icon className="size-4" />
                  {label}
                </div>
                <p className="mt-3 text-2xl font-black">{value}</p>
                <p className="mt-1 text-xs text-muted-foreground">{note}</p>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Required human review dimensions</CardTitle>
            <CardDescription>No automated reviewer may satisfy these gates.</CardDescription>
          </CardHeader>
          <CardContent className="flex flex-wrap gap-2">
            {snapshot.review_dimensions.map((dimension) => (
              <Badge key={dimension} variant="warning">{dimensionLabels[dimension] ?? dimension.replaceAll("_", " ")}</Badge>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Guide-locale review matrix</CardTitle>
            <CardDescription>
              Reviewer, evidence and timestamp fields remain empty until the operational registries contain verifiable human review records.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="younew-table min-w-[960px]">
                <thead>
                  <tr><th>Guide</th><th>Locale</th><th>Domain</th><th>Fields</th><th>Review</th><th>Reviewer</th><th>Evidence</th><th>Publish</th></tr>
                </thead>
                <tbody>
                  {snapshot.records.map((record) => (
                    <tr key={`${record.source_guide_id}:${record.locale}`}>
                      <td>
                        <p className="font-medium text-foreground">{guideLabels[record.source_guide_id] ?? record.source_guide_id}</p>
                        <p className="mt-1 text-xs">{record.source_guide_id}</p>
                      </td>
                      <td><Badge variant="info">{record.locale.toUpperCase()}</Badge></td>
                      <td>{categoryLabels[record.review_category] ?? record.review_category}</td>
                      <td>{record.translated_field_count}</td>
                      <td><Badge variant={record.review_status === "passed" ? "success" : "warning"}>{record.review_status.replaceAll("_", " ")}</Badge></td>
                      <td>{record.reviewer_id ?? "Not assigned"}</td>
                      <td>{record.evidence_registry_entry_id ?? "Missing"}</td>
                      <td><Badge variant={record.publication_eligible ? "success" : "destructive"}>{record.publication_eligible ? "Eligible" : "Blocked"}</Badge></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>

        <p className="break-all text-xs text-muted-foreground">
          Snapshot source: {snapshot.admin_snapshot.source} · SHA-256 {snapshot.admin_snapshot.source_sha256}
        </p>
      </section>
    </>
  );
}
