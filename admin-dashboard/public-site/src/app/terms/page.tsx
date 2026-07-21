import { ContentPage } from "@/components/content-page";
import { links } from "@/lib/site-data";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Terms of Use", "Terms governing use of the YouNew website and informational app.", "/terms");

export default function TermsPage() {
  return (
    <ContentPage title="Terms of Use" description="Effective 14 July 2026 · These terms apply to the YouNew.nl website and informational app.">
      <h2>Informational use only</h2>
      <p>
        YouNew provides onboarding and discovery information for people living in or visiting the Netherlands. It does not provide legal, immigration, tax, medical, financial, housing, employment, emergency or government advice, and it is not affiliated with the Dutch government.
      </p>
      <p>
        Rules, deadlines, amounts, eligibility criteria, forms and official procedures can change. Verify important information directly with the responsible institution or a qualified professional.
      </p>

      <h2>AI assistance</h2>
      <p>
        AI-generated explanations may be inaccurate, incomplete or outdated. The assistant is not a lawyer, doctor, tax adviser, immigration consultant, police service or government authority.
      </p>

      <h2>Your responsibility</h2>
      <p>
        You are responsible for decisions, applications, payments, objections, appointments, medical actions, legal actions and communications with institutions. Never send passwords or sensitive personal records through AI or support channels.
      </p>

      <h2>Emergency use</h2>
      <p>
        YouNew is not an emergency service. In the Netherlands, call 112 for immediate danger or a life-threatening emergency.
      </p>

      <h2>External links and availability</h2>
      <p>
        Third-party websites and services are controlled by their owners. YouNew is not responsible for their content, availability, prices or policy changes. Website features and release channels may change, pause or be withdrawn.
      </p>

      <h2>Intellectual property</h2>
      <p>
        YouNew branding, original interface elements and original editorial content may not be copied or redistributed as a competing product without permission. Third-party names, trademarks, images and source material remain the property of their respective owners.
      </p>

      <h2>Contact</h2>
      <p>
        Questions about these terms can be sent to <a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a>.
      </p>
    </ContentPage>
  );
}
