import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Privacy Policy", "How YouNew handles local app data, network services, location, support email and external services.", "/privacy");

export default function PrivacyPage() {
  return (
    <ContentPage title="Privacy Policy" description="Effective 28 July 2026 · YouNew is a local-first informational guide for life in the Netherlands.">
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
        The website offers optional first-party product analytics. Analytics stays off until you actively choose “Allow anonymous analytics”; declining does not restrict the website. You can reopen “Privacy choices” on any page and withdraw permission at any time. Global Privacy Control and browser Do Not Track signals are treated as a decline when you have not already saved a choice.
      </p>
      <p>
        When enabled, YouNew sends a random event ID, random browser-tab session IDs, the page path without query parameters, event type, website version, language, timestamp and a small allowlisted set of action results such as result count or content identifier. YouNew does not send search text, form contents, saved items, selected profile data, precise location, advertising IDs or a cross-site identifier. The browser-tab identifiers are stored only in session storage and are not used to recognise you across browser sessions or other websites.
      </p>
      <p>
        Analytics events are sent directly to YouNew&apos;s EU-hosted Supabase project, are available only to approved administrators, and are removed after 90 days. Dashboard reporting uses aggregated counts for sessions, page and product events, key actions, platforms, errors and source freshness. Supabase and the network providers involved in delivering the HTTPS request may process technical connection data such as the IP address in their infrastructure logs; YouNew does not copy the raw IP address into the analytics event record.
      </p>
      <p>
        The iOS app does not currently upload product analytics. It contains no advertising SDK or cross-app tracking. The app privacy controls and App Store privacy information will be updated before iOS analytics is enabled.
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
        The web version stores saved items, recently viewed pages and your selected profile in this browser. Search history is off by default and is stored locally only if you enable “Remember searches on this device”. These values and search text are not sent to YouNew analytics. The website stores your analytics accept/decline choice in local storage and, only after acceptance, uses session storage for random identifiers that last for the browser-tab session.
      </p>
      <p>
        The business inquiry form sends the details you enter to a protected YouNew endpoint. After browser and server validation, the inquiry is stored in YouNew&apos;s EU-hosted Supabase project and receives a confirmation ID. It includes the contact and proposal fields, source page, consent time and any campaign parameters present in the page URL. The form does not accept uploads. Business inquiries are used to evaluate and respond to the proposal, not as consent for unrelated marketing.
      </p>
      <p>
        The feedback form may store an optional email address, feedback type, referenced page, message, consent time, status and confirmation ID in the same Supabase project. YouNew administrators can review these submissions. The rate limiter stores only a salted one-way network fingerprint for a short abuse-prevention window; it does not store the raw IP address in the submission record. Audit events record submission type and state, not the message or contact details.
      </p>
      <p>
        Business inquiries and feedback are retained while they are needed for review, follow-up, security and legal accountability. Automated deletion is not currently enabled; records are reviewed and removed manually when no longer needed. You may request access or deletion by email. Legal retention duties may require YouNew to keep limited records for longer.
      </p>

      <h2>Your controls</h2>
      <p>
        The app’s Privacy &amp; Data Control screen lets you create a local JSON export and delete app-managed personal data. Removing the app may also remove locally stored app data, subject to the device platform’s backup behavior.
      </p>
      <p>
        On the website, open <a href="/saved/">Saved items</a> and use “Clear local web data” to remove saved items, recently viewed pages, optional search history and the selected profile from this browser.
      </p>
      <p>
        Use “Privacy choices” on any website page to decline future analytics. Withdrawing permission clears the analytics session identifiers from the current tab. Already collected events remain only for the stated retention period because they do not contain an account identifier that can reliably be linked back to a particular visitor.
      </p>

      <h2>External services</h2>
      <p>
        YouNew links to official institutions, maps, transport providers and other third-party websites. Those services control their own content and privacy practices.
      </p>

      <h2>Contact</h2>
      <p>
        For privacy questions, access requests or deletion requests concerning support, business inquiry or feedback records, email <a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a>. Include the confirmation ID when available.
      </p>
    </ContentPage>
  );
}
