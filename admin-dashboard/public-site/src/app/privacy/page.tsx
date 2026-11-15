import siteConfig from "@/config/site-config.json";
import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Privacy Policy", "How YouNew handles local app data, network services, location, support email and external services.", "/privacy");

export default function PrivacyPage() {
  return (
    <ContentPage title="Privacy Policy" description="Updated 26 October 2026 · YouNew is a local-first informational guide for life in the Netherlands.">
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
        When enabled, YouNew sends a random event ID, random browser-tab session IDs, the page path without query parameters, event type, website version, language and timestamp to its own website endpoint. The only action properties sent are search result counts, whether no result was found, the recovery tier and bounded time to the first action. Search phrases, selected profile and location filters, content identifiers, form contents, saved items, precise device location, advertising IDs and cross-site identifiers are not sent. Browser-tab identifiers exist only in session storage and are not used to recognise you across browser sessions or other websites.
      </p>
      <p>
        New website analytics is processed on YouNew&apos;s Hostinger hosting in the Netherlands. The protected store is outside the public website folder and keeps only event types, broad page sections, language, result counts, timings and one-way keyed identifiers for duplicate prevention and daily browser-tab counts. Raw identifiers, full page paths and raw IP addresses are not retained in this store. The private report contains aggregated counts and is available through the authenticated hosting account. Scheduled maintenance removes events after 89 days; the daily recovery snapshot can lag by up to one day. Hosting backups are separate and expire under Hostinger&apos;s backup schedule; restores must run retention maintenance before reporting resumes. Hostinger may process IP addresses in its connection and security logs. Earlier Supabase analytics is not imported or changed by this migration; the historical dashboard still uses its original storage.
      </p>
      {siteConfig.analytics.guideMetricsEnabled ? <p>With renewed consent, guide analytics also stores an allowlisted public guide ID, active visible reading time and one official action per guide, language and browser-tab session per UTC day. Only the browser stores the previous visit date. The server receives an optional yes/no flag for a visit 7–30 days earlier, without a persistent visitor identifier. Withdrawing consent removes this local date and guide-session measurements. Small samples and unavailable return measurements are reported separately.</p> : null}
      <p>
        The iOS app does not currently upload product analytics. It contains no advertising SDK or cross-app tracking. The app privacy controls and App Store privacy information will be updated before iOS analytics is enabled.
      </p>

      <h2>Network services and technical logs</h2>
      <p>
        The Home screen requests current weather through Apple WeatherKit using the coordinates of the selected city in YouNew&apos;s public city catalogue, not your device&apos;s current-location coordinates. Apple Weather processes the city coordinates and technical connection data needed to return the forecast under Apple&apos;s privacy and legal terms. YouNew displays the required Apple Weather mark and provides a direct link to Apple&apos;s weather data-source and legal information.
      </p>
      <p>
        YouNew also loads selected public information and images from Wikimedia Commons and Flickr&apos;s public image delivery service. When an image is displayed, the provider receives the IP address and requested URL needed to deliver it and may keep technical server logs under its own policy. This network information is used only to provide app functionality, not for advertising, marketing, analytics or cross-app tracking. The App Store privacy declaration conservatively identifies these technical logs as Device ID and Other Diagnostic Data, linked to the device and not used for tracking.
      </p>

      <h2>Website and support</h2>
      <p>
        The public website does not require an account and contains no payment flow. When you contact support by email, we receive the address, message and attachments you choose to send. Do not email sensitive identity, medical or financial documents.
      </p>
      <p>
        The web version stores saved items, recently viewed pages, checklist progress and your selected profile in this browser. Optional recent searches are off by default and stay only in the open tab&apos;s memory; they clear on reload and are excluded from local-data exports. The updated search removes its two former persistent-history keys without removing saved items or your profile. Search text is not added to new search URLs or shared links; a legacy incoming query is read into memory and then removed from the current URL. Reloading or reopening a link restores filters, not the phrase. Saved items and recent searches are not sent to YouNew analytics. If analytics is enabled, search-quality events contain only the aggregate result metrics described above. The website stores your analytics accept/decline choice in local storage and, only after acceptance, uses session storage for random identifiers that last for the browser-tab session.
      </p>
      <p>
        The business inquiry form sends the details you enter to a YouNew endpoint on this website. After browser and server validation, new inquiries are stored on YouNew&apos;s Hostinger hosting in the Netherlands, outside the publicly accessible website folder, and receive a confirmation ID. Hostinger stores the hosting backups in Lithuania, within the EU. The record includes the contact and proposal fields, source page, consent time and bounded campaign parameters present in the page URL. The form does not accept uploads. Business inquiries are used to evaluate and respond to the proposal, not as consent for unrelated marketing. Submitting a request does not automatically publish a business profile or send a marketing email.
      </p>
      <p>
        New feedback records are stored in the same protected Hostinger storage and may include an optional email address, feedback type, referenced page, message, consent time, status and confirmation ID. Authorized YouNew administrators review submissions through the protected hosting account; there is no public endpoint for reading submissions. Duplicate retries return the original confirmation ID. The rate limiter stores a salted one-way network fingerprint in counters that expire within an hour and are removed when new submissions are processed. The raw IP address is not copied into submission records. Hostinger may process IP addresses in its technical connection and security logs. Earlier submissions, if any, remain in the previous protected Supabase storage and are not copied by this change.
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
      <p>
        Read the <a href="/terms/">Terms of Use</a> or open <a href="/support/">Support</a> for a correction or product question.
      </p>
    </ContentPage>
  );
}
