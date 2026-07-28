import Link from "next/link";
import Image from "next/image";
import { ArrowRight, CheckCircle2, Smartphone } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";
import { links } from "@/lib/site-data";

export const metadata = metadataForPage("YouNew for iPhone", "Current verified information about the YouNew iPhone app and available web alternatives.", "/app");

export default function AppPage() {
  return (
    <PageShell>
      <section className="app-hero section-shell app-download-hero">
        <div>
          <Breadcrumbs items={[{ label: "App" }]} />
          <Smartphone aria-hidden className="hero-line-icon" />
          <h1>YouNew on iPhone</h1>
          <p>The public YouNew App Store listing is available. The exact current store version was not independently verified during this check; the web guide remains available without an install.</p>
          <div className="hero-actions">
            <a className="button button-primary" href={links.appStore} rel="noreferrer" target="_blank">Download on the App Store <ArrowRight aria-hidden /></a>
            <Link className="button button-outline" href="/discover">Use the web guide</Link>
            <Link className="button button-outline" href="/status">Check release status</Link>
          </div>
          <p className="availability-note"><CheckCircle2 aria-hidden /> Public distribution confirmed. Locally tested app version: 1.1 (build 5).</p>
        </div>
        <div className="device-frame app-page-device">
          <Image src="/images/app-home-nl.webp" alt="Current YouNew iPhone home screen in Dutch" width={437} height={946} priority sizes="(max-width: 760px) 72vw, 330px" />
        </div>
      </section>
    </PageShell>
  );
}
