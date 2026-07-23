import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Privacy Policy", "How YouNew handles local app data, network services, location, support email and external services.", "/privacy");

export default function PrivacyPage() {
  return (
    <ContentPage title="Privacy Policy" description="Effective 22 July 2026 · YouNew is a local-first informational guide for life in the Netherlands.">
      <h2>Data stored on your device</h2>
      <p>
        YouNew may store your profile choices, selected city, checklist progress, saved items, recent searches, translator history, assistant conversation history, imported document files and document metadata locally on your device.
      </p>
      <p>
        Imported document files remain in app-managed local storage. A privacy export includes document metadata, not the document file contents.
      </p>

      <h2>AI assistance</h2>
      <p>
        The current App Store release has no remote AI backend configured and uses the deterministic local guide. If a remote AI service is enabled in a future release, the bounded request may contain your question, app locale, scenario and context version, and a fixed set of knowledge-record identifiers. It does not contain documents, precise location, your full profile, saved items or conversation history. This policy and the App Store privacy information will be updated before a remote AI service is enabled.
      </p>
      <p>
        Do not enter BSN numbers, passport numbers, medical records, financial account numbers, passwords or other sensitive personal data into the assistant. AI-generated information may be inaccurate or incomplete; verify important decisions with official institutions.
      </p>

      <h2>Location</h2>
      <p>
        If you grant permission, YouNew uses your approximate current location to show nearby places and support points. The app does not use location for advertising or store it as a long-term profile record.
      </p>

      <h2>Analytics and tracking</h2>
      <p>
        The current release does not include advertising SDKs or cross-app tracking. If product analytics are enabled in a future release, this policy and the App Store privacy information will be updated before those changes are shipped.
      </p>

      <h2>Network services and technical logs</h2>
      <p>
        The Home screen requests current weather from Open-Meteo using the coordinates of the selected city in YouNew&apos;s public city catalogue, not your device&apos;s current-location coordinates. Like other internet services, Open-Meteo receives the connection IP address and requested URL. Its published terms state that technical web-server logs used for maintenance, abuse prevention and troubleshooting may contain IP addresses and requested coordinates and are deleted after 90 days.
      </p>
      <p>
        YouNew also loads selected public information and images from Wikimedia Commons and Flickr&apos;s public image delivery service. When an image is displayed, the provider receives the IP address and requested URL needed to deliver it and may keep technical server logs under its own policy. This network information is used only to provide app functionality, not for advertising, marketing, analytics or cross-app tracking. The App Store privacy declaration conservatively identifies these technical logs as Device ID and Other Diagnostic Data, linked to the device and not used for tracking.
      </p>

      <h2>Website and support</h2>
      <p>
        The public website does not require an account and contains no payment flow. When you contact support by email, we receive the address, message and attachments you choose to send. Do not email sensitive identity, medical or financial documents.
      </p>
      <p>
        The web version stores saved items, recently viewed pages and your selected profile in this browser. Search history is off by default and is stored locally only if you enable “Remember searches on this device”. The website does not send these values to YouNew or an analytics provider.
      </p>
      <p>
        The business inquiry form validates the details in your browser and prepares an email draft; filling it in does not submit anything to YouNew. If you review and send the draft, YouNew receives the contact and proposal details you chose to include through the participating email services. The form does not accept uploads. Business inquiries are used to evaluate and respond to the proposal, not as blanket consent for unrelated marketing.
      </p>

      <h2>Your controls</h2>
      <p>
        The app’s Privacy &amp; Data Control screen lets you create a local JSON export and delete app-managed personal data. Removing the app may also remove locally stored app data, subject to the device platform’s backup behavior.
      </p>
      <p>
        On the website, open <a href="/saved/">Saved items</a> and use “Clear local web data” to remove saved items, recently viewed pages, optional search history and the selected profile from this browser.
      </p>

      <h2>External services</h2>
      <p>
        YouNew links to official institutions, maps, transport providers and other third-party websites. Those services control their own content and privacy practices.
      </p>

      <h2>Contact</h2>
      <p>
        For privacy questions or deletion requests concerning support correspondence, email <a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a>.
      </p>
    </ContentPage>
  );
}
