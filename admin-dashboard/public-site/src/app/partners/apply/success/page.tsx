import Link from "next/link";
import { ArrowRight, CheckCircle2 } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Pilot request received",
  "Confirmation that a YouNew pilot request was received for review.",
  "/partners/apply/success",
  { noIndex: true, follow: false }
);

export default function PilotRequestSuccessPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="pilot-state-page section-shell">
        <Breadcrumbs items={[{ label: "For business", href: "/for-business" }, { label: "Request received" }]} />
        <CheckCircle2 aria-hidden />
        <p className="section-label cyan">Secure receipt created</p>
        <h1>Request received.</h1>
        <p>We will review your request and reply using the contact details you provided.</p>
        <aside><strong>No contract or payment was created.</strong><span>Scope, proposal, contract and manual invoice are handled separately after review.</span></aside>
        <Link className="button button-outline" href="/for-business/pilot">Review pilot scope <ArrowRight aria-hidden /></Link>
      </section>
    </PageShell>
  );
}
