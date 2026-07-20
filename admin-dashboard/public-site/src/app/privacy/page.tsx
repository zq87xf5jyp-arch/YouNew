import type { Metadata } from "next";
import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: "How YouNew.nl handles local app data, AI requests, location, support email and external services."
};

export default function PrivacyPage() {
  return (
    <ContentPage title="Privacy Policy" description="Effective 14 July 2026 · YouNew is a local-first informational guide for life in the Netherlands.">
      <h2>Data stored on your device</h2>
      <p>
        YouNew may store your profile choices, selected city, checklist progress, saved items, recent searches, translator history, assistant conversation history, imported document files and document metadata locally on your device.
      </p>
      <p>
        Imported document files remain in app-managed local storage. A privacy export includes document metadata, not the document file contents.
      </p>

      <h2>AI assistance</h2>
      <p>
        When an AI service is configured and you send a question, the question, limited app context and recent conversation messages may be sent to the configured AI proxy to generate a response.
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

      <h2>Website and support</h2>
      <p>
        The public website does not require an account and contains no payment flow. When you contact support by email, we receive the address, message and attachments you choose to send. Do not email sensitive identity, medical or financial documents.
      </p>

      <h2>Your controls</h2>
      <p>
        The app’s Privacy &amp; Data Control screen lets you create a local JSON export and delete app-managed personal data. Removing the app may also remove locally stored app data, subject to the device platform’s backup behavior.
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
