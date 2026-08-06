import Link from "next/link";
import Image from "next/image";
import { ArrowRight, CheckCircle2, Smartphone } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { TrackedAppStoreLink } from "@/components/tracked-app-store-link";
import statusSnapshot from "@/config/status.json";
import { metadataForPage } from "@/lib/seo/metadata";
import { links } from "@/lib/site-data";

export const metadata = metadataForPage("YouNew for iPhone", "Current verified information about the YouNew iPhone app and available web alternatives.", "/app");

export default function AppPage() {
  const currentVersionIsTested = statusSnapshot.ios.publicVersion === statusSnapshot.ios.testedVersion;
  return (
    <PageShell>
      <section className="app-hero section-shell app-download-hero">
        <div>
          <Breadcrumbs items={[{ label: "App" }]} />
          <Smartphone aria-hidden className="hero-line-icon" />
          <h1>YouNew on iPhone</h1>
          <p>The public YouNew App Store listing currently serves version {statusSnapshot.ios.publicVersion}. {currentVersionIsTested ? `This is the locally tested version backed by build ${statusSnapshot.ios.testedBuild} release evidence.` : `The locally tested version is ${statusSnapshot.ios.testedVersion} (build ${statusSnapshot.ios.testedBuild}).`} The web guide remains available without an install.</p>
          <div className="hero-actions">
            <TrackedAppStoreLink
              className="button button-primary"
              href={links.appStore}
              location="app_page_hero"
              rel="noreferrer"
              target="_blank"
            >
              Download on the App Store <ArrowRight aria-hidden />
            </TrackedAppStoreLink>
            <Link className="button button-outline" href="/discover">Use the web guide</Link>
            <Link className="button button-outline" href="/status">Check release status</Link>
          </div>
          <p className="availability-note"><CheckCircle2 aria-hidden /> Public distribution confirmed. Locally tested app version: {statusSnapshot.ios.testedVersion} (build {statusSnapshot.ios.testedBuild}).</p>
        </div>
        <div className="device-frame app-page-device">
          <Image src="/images/app-home-nl.webp" alt="Current YouNew iPhone home screen in Dutch" width={437} height={946} priority sizes="(max-width: 760px) 72vw, 330px" />
        </div>
      </section>
    </PageShell>
  );
}
