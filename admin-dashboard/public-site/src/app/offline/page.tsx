import Link from "next/link";
import { ContentPage } from "@/components/content-page";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("You are offline", "YouNew could not reach the network. Previously opened guides may still be available.", "/offline", { noIndex: true });

export default function OfflinePage() {
  return (
    <ContentPage
      title="You are offline"
      description="YouNew cannot reach the network right now. Previously opened guides may still be available on this device."
    >
      <section className="offline-guidance" aria-labelledby="offline-next">
        <h2 id="offline-next">What you can do</h2>
        <ul>
          <li>Check your Wi-Fi or mobile data connection, then try again.</li>
          <li>Use your browser history to reopen a guide you viewed earlier.</li>
          <li>Keep this page open and retry when your connection returns.</li>
        </ul>
        <p>
          <Link className="button button-primary" href="/">
            Try YouNew again
          </Link>
        </p>
      </section>

      <section className="offline-emergency-note" aria-labelledby="offline-emergency">
        <h2 id="offline-emergency">Emergency information</h2>
        <p>
          Emergency pages are intentionally not stored for offline use because that information can change. Reconnect for the
          latest published guidance. For an immediate life-threatening emergency in the Netherlands, call <strong>112</strong>.
        </p>
      </section>
    </ContentPage>
  );
}
