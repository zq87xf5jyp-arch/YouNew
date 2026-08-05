import { ArrowLeft, CircleAlert, ExternalLink, FileText, Languages, Link2 } from "lucide-react";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import reviewSnapshot from "@/generated/localization-review.json";
import {
  categoryLabels,
  dimensionLabels,
  type LocalizationReviewSnapshot
} from "@/lib/localization-review";

const snapshot = reviewSnapshot as LocalizationReviewSnapshot;

export function generateStaticParams() {
  return snapshot.review_packets.map((packet) => ({ packetId: packet.packet_id }));
}

export default async function LocalizationReviewPacketPage({
  params
}: {
  params: Promise<{ packetId: string }>;
}) {
  const { packetId } = await params;
  const packet = snapshot.review_packets.find((candidate) => candidate.packet_id === packetId);

  if (!packet) notFound();

  return (
    <>
      <PageHeader
        title={`${packet.target_title} · ${packet.locale.toUpperCase()}`}
        description={`Read-only human-review packet for ${packet.source_title}. English evidence text and the machine-assisted target draft are shown side by side.`}
      />

      <section className="grid gap-6" aria-labelledby="packet-status">
        <Link className="inline-flex min-h-11 w-fit items-center gap-2 rounded-md border border-border px-3 text-sm font-semibold text-cyan-100" href="/localization-review">
          <ArrowLeft className="size-4" /> Back to review matrix
        </Link>

        <Card className="border-amber-400/30 bg-amber-400/5">
          <CardHeader className="gap-3 lg:flex-row lg:items-start lg:justify-between">
            <div>
              <CardTitle id="packet-status" className="flex items-center gap-2 text-xl">
                <CircleAlert className="size-5 text-amber-300" /> Human review not started
              </CardTitle>
              <CardDescription className="mt-2 max-w-3xl">
                This packet is inspection material only. It cannot assign a reviewer, create evidence or authorize publication.
              </CardDescription>
            </div>
            <div className="flex flex-wrap gap-2">
              <Badge variant="info">{packet.locale.toUpperCase()}</Badge>
              <Badge variant="warning">{categoryLabels[packet.review_category] ?? packet.review_category}</Badge>
              <Badge variant="destructive">NO-GO</Badge>
            </div>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-2">
              {snapshot.review_dimensions.map((dimension) => (
                <Badge key={dimension} variant="warning">{dimensionLabels[dimension] ?? dimension.replaceAll("_", " ")}</Badge>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Languages className="size-5 text-cyan-300" /> Search-surface copy</CardTitle>
            <CardDescription>Review the title, summary, discovery terms, common questions and controlled terminology together.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-5">
            <div className="grid gap-4 lg:grid-cols-2">
              <article className="rounded-lg border border-border bg-background/35 p-4">
                <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">English source</p>
                <h2 className="mt-2 text-lg font-semibold text-foreground">{packet.source_title}</h2>
                <p className="mt-3 text-sm leading-6">{packet.search_surface.source_summary}</p>
              </article>
              <article className="rounded-lg border border-cyan-300/20 bg-cyan-300/5 p-4">
                <p className="text-xs font-semibold uppercase tracking-wide text-cyan-200">{packet.locale.toUpperCase()} draft</p>
                <h2 className="mt-2 text-lg font-semibold text-foreground">{packet.target_title}</h2>
                <p className="mt-3 text-sm leading-6">{packet.search_surface.target_summary}</p>
              </article>
            </div>

            <div className="grid gap-4 lg:grid-cols-2">
              <article className="rounded-lg border border-border p-4">
                <h3 className="font-semibold text-foreground">Discovery terms</h3>
                <p className="mt-3 text-xs font-semibold uppercase tracking-wide text-muted-foreground">English</p>
                <p className="mt-2 text-sm leading-6">{packet.search_surface.source_synonyms.join(" · ")}</p>
                <p className="mt-4 text-xs font-semibold uppercase tracking-wide text-cyan-200">{packet.locale.toUpperCase()}</p>
                <p className="mt-2 text-sm leading-6">{packet.search_surface.target_synonyms.join(" · ")}</p>
              </article>
              <article className="rounded-lg border border-border p-4">
                <h3 className="font-semibold text-foreground">Common questions</h3>
                <ul className="mt-3 grid gap-2 text-sm">
                  {packet.search_surface.source_common_questions.map((question) => <li key={`source-${question}`}>EN · {question}</li>)}
                  {packet.search_surface.target_common_questions.map((question) => <li key={`target-${question}`} className="text-cyan-100">{packet.locale.toUpperCase()} · {question}</li>)}
                </ul>
              </article>
            </div>

            <div>
              <h3 className="font-semibold text-foreground">Controlled terminology</h3>
              <div className="mt-3 grid gap-3 lg:grid-cols-2">
                {packet.search_surface.terminology.map((term) => (
                  <article key={`${term.source}:${term.target}`} className="rounded-lg border border-border p-4">
                    <p className="font-medium text-foreground">{term.source} → {term.target}</p>
                    <p className="mt-2 text-sm leading-6 text-muted-foreground">{term.note}</p>
                  </article>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><FileText className="size-5 text-cyan-300" /> Full-body source comparison</CardTitle>
            <CardDescription>{packet.fields.length} translated fields. Source IDs stay visible so a reviewer can reopen the supporting official evidence.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-4">
            {packet.fields.map((field) => (
              <article key={field.path} className="overflow-hidden rounded-lg border border-border">
                <div className="border-b border-border bg-muted/20 px-4 py-3">
                  <p className="break-all font-mono text-xs text-cyan-200">{field.path}</p>
                </div>
                <div className="grid gap-px bg-border lg:grid-cols-2">
                  <div className="bg-background p-4">
                    <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">English source</p>
                    <p className="mt-2 text-sm leading-6 text-foreground">{field.source_text}</p>
                  </div>
                  <div className="bg-background p-4">
                    <p className="text-xs font-semibold uppercase tracking-wide text-cyan-200">{packet.locale.toUpperCase()} draft</p>
                    <p className="mt-2 text-sm leading-6 text-foreground">{field.target_text}</p>
                  </div>
                </div>
                <div className="flex flex-wrap gap-2 border-t border-border px-4 py-3">
                  {field.source_ids.length > 0
                    ? field.source_ids.map((sourceId) => <Badge key={sourceId} variant="secondary">{sourceId}</Badge>)
                    : <span className="text-xs text-muted-foreground">Editorial field · no direct source ID</span>}
                </div>
              </article>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Link2 className="size-5 text-cyan-300" /> Official source register</CardTitle>
            <CardDescription>Open every source during human review. Stored checked dates are evidence history, not a guarantee that the page is unchanged.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3 lg:grid-cols-2">
            {packet.official_sources.map((source) => (
              <article key={source.id} className="rounded-lg border border-border p-4">
                <p className="text-xs font-semibold text-cyan-200">{source.id}</p>
                <h3 className="mt-2 font-semibold text-foreground">{source.title}</h3>
                <p className="mt-1 text-sm text-muted-foreground">{source.publisher} · checked {source.checked_at} · {source.status.replaceAll("_", " ")}</p>
                <a className="mt-3 inline-flex min-h-11 items-center gap-2 text-sm font-semibold text-cyan-100" href={source.url} rel="noreferrer" target="_blank">
                  Open official source <ExternalLink className="size-4" />
                </a>
              </article>
            ))}
          </CardContent>
        </Card>
      </section>
    </>
  );
}
