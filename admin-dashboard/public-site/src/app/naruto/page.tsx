import { Sparkles } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { NarutoExperience } from "@/components/naruto-experience";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Ask Naruto",
  "Find a clear next step from published YouNew guidance and responsible official sources in the Netherlands.",
  "/naruto"
);

export default function NarutoPage() {
  return (
    <PageShell className="naruto-page">
      <section className="app-hero section-shell naruto-hero">
        <Breadcrumbs items={[{ label: "Naruto" }]} />
        <div className="naruto-hero-title"><Sparkles aria-hidden /><h1>Ask Naruto</h1></div>
        <p>Get a clear next step from published YouNew guidance and responsible official sources.</p>
      </section>
      <section className="section-shell naruto-page-content"><NarutoExperience /></section>
    </PageShell>
  );
}
