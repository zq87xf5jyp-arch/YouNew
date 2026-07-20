import type { Metadata } from "next";
import { Mail, MessageCircle } from "lucide-react";
import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";

export const metadata: Metadata = {
  title: "Support",
  description: "Contact YouNew.nl support, report incorrect information or ask a privacy question."
};

export default function SupportPage() {
  return (
    <ContentPage title="Support" description="Get product help, report incorrect information or follow release updates.">
      <h2>Contact support</h2>
      <p>
        Email <a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a> with your question, feedback or correction request.
      </p>
      <div className="not-prose mt-6 grid gap-3 sm:grid-cols-2">
        <a href={`mailto:${links.contactEmail}`} className="inline-flex items-center justify-center gap-2 rounded-full bg-orange-brand px-5 py-4 text-sm font-extrabold text-white">
          <Mail className="size-4" aria-hidden />
          Email support
        </a>
        <a href={links.telegram} className="inline-flex items-center justify-center gap-2 rounded-full border border-white/12 bg-white/[0.07] px-5 py-4 text-sm font-extrabold text-white">
          <MessageCircle className="size-4" aria-hidden />
          Follow updates
        </a>
      </div>
      <h2>Report incorrect information</h2>
      <p>
        Include the page or topic, what appears incorrect, and the official source that should be checked.
      </p>
      <h2>What to include</h2>
      <p>
        Include the app version, device type, language, city, the screen or page involved and the steps that led to the issue. Do not include BSN numbers, passwords, passport scans, medical files or financial records.
      </p>
      <h2>Response expectations</h2>
      <p>
        Support email is not monitored as an emergency channel. For immediate danger in the Netherlands, call 112. For official procedures, contact the responsible organization directly.
      </p>
      <h2>Important note</h2>
      <p>
        YouNew.nl is an informational guide. For urgent, legal, medical, financial or immigration matters, verify with official services or qualified professionals.
      </p>
    </ContentPage>
  );
}
