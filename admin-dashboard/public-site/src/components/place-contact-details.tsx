import type { PublicPlaceDetails } from "@/lib/content/types";

const copy = {
  en: { title: "Address & contact", address: "Address", website: "Official website", email: "Business email", phone: "Business telephone", source: "Source", checked: "Checked", empty: "Contact details have not been confirmed." },
  nl: { title: "Adres en contact", address: "Adres", website: "Officiële website", email: "Zakelijk e-mailadres", phone: "Zakelijk telefoonnummer", source: "Bron", checked: "Gecontroleerd", empty: "Contactgegevens zijn niet bevestigd." }
};

export function PlaceContactDetails({ details, locale = "en", compact = false }: { details?: PublicPlaceDetails | null; locale?: "en" | "nl"; compact?: boolean }) {
  const t = copy[locale];
  if (!details) return compact ? null : <p className="place-contact-empty" lang={locale}>{t.empty}</p>;
  const keys = compact ? ["address", "website"] as const : ["address", "website", "email", "phone"] as const;
  return <section className={`place-contact-details${compact ? " place-contact-compact" : ""}`} aria-label={t.title} lang={locale}>
    {!compact ? <h2>{t.title}</h2> : null}
    <dl>{keys.map(key => {
      const field = details[key]; if (!field) return null;
      const href = key === "website" ? field.value : key === "email" ? `mailto:${field.value}` : key === "phone" ? `tel:${field.value.replace(/[^\d+]/g, "")}` : null;
      return <div key={key}><dt>{t[key]}</dt><dd>{href ? <a href={href} target={key === "website" ? "_blank" : undefined} rel={key === "website" ? "noopener noreferrer" : undefined}>{key === "website" ? new URL(field.value).hostname : field.value}</a> : field.value}
        {!compact ? <small><a href={field.sourceUrl} target="_blank" rel="noopener noreferrer">{t.source}</a> · {t.checked} <time dateTime={field.checkedAt}>{field.checkedAt}</time></small> : null}
      </dd></div>;
    })}</dl>
    {!compact && details.addressNote ? <p lang="en">{details.addressNote}</p> : null}
    {!compact && details.contactNote ? <p lang="en">{details.contactNote}</p> : null}
  </section>;
}
