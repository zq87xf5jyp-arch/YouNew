import { ArrowRight, CircleAlert, FileCheck2, Languages, ListChecks, LockKeyhole, Rows3 } from "lucide-react";
import Link from "next/link";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import reviewSnapshot from "@/generated/localization-review.json";
import {
  categoryLabels,
  dimensionLabels,
  guideLabels,
  reviewPacketHref,
  summarizeLocalizationReview,
  type LocalizationReviewSnapshot
} from "@/lib/localization-review";

const snapshot = reviewSnapshot as LocalizationReviewSnapshot;
const summary = summarizeLocalizationReview(snapshot);
const packetsByPair = new Map(snapshot.review_packets.map((packet) => [`${packet.source_guide_id}:${packet.locale}`, packet]));

const stats = [
  { label: "Machine drafts", value: summary.drafts, note: `${summary.fieldCount} translated fields`, icon: Languages },
  { label: "Review packets", value: snapshot.admin_snapshot.review_packet_count, note: "English and target side by side", icon: Rows3 },
  { label: "Human-reviewed", value: `${summary.reviewed}/${summary.drafts}`, note: "Registered reviewers only", icon: FileCheck2 },
  { label: "Publication eligible", value: `${summary.eligible}/${summary.drafts}`, note: "All four gates required", icon: LockKeyhole },
  { label: "Required checks", value: summary.requiredChecks, note: `${snapshot.review_dimensions.length} per guide-locale`, icon: ListChecks }
];

export default function LocalizationReviewPage() {
  return (
    <>
      <PageHeader
        title="Localization Review"
        description="Read-only evidence snapshot for the 8 release-critical guides in Dutch and Russian. Machine-assisted drafts are never treated as human approval."
      />

      <section className="grid min-w-0 gap-6" aria-labelledby="localization-release-status">
        <Card className="min-w-0 overflow-hidden border-amber-400/30 bg-[radial-gradient(circle_at_top_right,rgba(251,191,36,.12),transparent_24rem),linear-gradient(145deg,rgba(14,29,53,.96),rgba(3,16,35,.96))]">
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
          <CardContent className="grid gap-3 pt-5 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-5">
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

        <Card className="min-w-0">
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

        <Card className="min-w-0">
          <CardHeader>
            <CardTitle>Guide-locale review matrix</CardTitle>
            <CardDescription>
              Reviewer, evidence and timestamp fields remain empty until the operational registries contain verifiable human review records.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid gap-3 md:hidden">
              {snapshot.records.map((record) => {
                const packet = packetsByPair.get(`${record.source_guide_id}:${record.locale}`);
                return (
                  <article key={`${record.source_guide_id}:${record.locale}`} className="rounded-lg border border-border bg-background/35 p-4">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-semibold text-foreground">{guideLabels[record.source_guide_id] ?? record.source_guide_id}</p>
                        <p className="mt-1 text-xs text-muted-foreground">{categoryLabels[record.review_category] ?? record.review_category} · {record.translated_field_count} fields</p>
                      </div>
                      <Badge variant="info">{record.locale.toUpperCase()}</Badge>
                    </div>
                    <div className="mt-4 flex flex-wrap gap-2">
                      <Badge variant={record.review_status === "passed" ? "success" : "warning"}>{record.review_status.replaceAll("_", " ")}</Badge>
                      <Badge variant={record.publication_eligible ? "success" : "destructive"}>{record.publication_eligible ? "Eligible" : "Blocked"}</Badge>
                    </div>
                    {packet ? (
                      <Link className="mt-4 inline-flex min-h-11 items-center gap-2 rounded-md border border-cyan-300/30 px-3 text-sm font-semibold text-cyan-100" href={reviewPacketHref(packet.packet_id)}>
                        Inspect source and translation <ArrowRight className="size-4" />
                      </Link>
                    ) : null}
                  </article>
                );
              })}
            </div>

            <div className="hidden max-w-full overflow-x-auto md:block">
              <table className="younew-table min-w-[1040px]">
                <thead>
                  <tr><th>Guide</th><th>Locale</th><th>Domain</th><th>Fields</th><th>Review</th><th>Reviewer</th><th>Evidence</th><th>Publish</th><th>Packet</th></tr>
                </thead>
                <tbody>
                  {snapshot.records.map((record) => {
                    const packet = packetsByPair.get(`${record.source_guide_id}:${record.locale}`);
                    return (
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
                        <td>{packet ? <Link className="font-semibold text-cyan-200 hover:text-cyan-100" href={reviewPacketHref(packet.packet_id)}>Open packet</Link> : "Missing"}</td>
                      </tr>
                    );
                  })}
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
