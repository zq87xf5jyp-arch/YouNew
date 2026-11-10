import { Brand } from "@/components/brand";
import { LanguageLink } from "@/components/language-link";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter({ locale = "en" }: { locale?: "en" | "nl" }) {
  const nl = locale === "nl";
  return <footer className="site-footer" lang={locale}><div className="section-shell footer-grid">
    <div className="footer-brand"><Brand href={nl ? "/nl/" : "/"} homeLabel={nl ? "YouNew startpagina" : "YouNew home"} /><p className="footer-copy">{nl ? "Wonen, ontdekken en ondernemen in Nederland. Met bronnen die je kunt controleren." : "Live, explore and do business in the Netherlands. With sources you can check."}</p><p className="copyright">© 2026 YouNew.</p></div>
    <div className="footer-column"><h2>{nl ? "Jouw volgende stap" : "Your next step"}</h2><nav className="footer-links" aria-label={nl ? "Routes" : "Paths"}><Link prefetch={false} href={nl ? "/nl/#live" : "/#live"}>{nl ? "Wonen" : "Live"}</Link><Link prefetch={false} href={nl ? "/nl/#cities-title" : "/#cities-title"}>{nl ? "Ontdekken" : "Explore"}</Link><Link prefetch={false} href={nl ? "/nl/voor-bedrijven/" : "/for-business/"}>{nl ? "Ondernemen" : "Business"}</Link><Link prefetch={false} href={nl ? "/nl/zoeken/" : "/search/"}>{nl ? "Zoeken" : "Search"}</Link><Link prefetch={false} href="/app/">iOS app</Link></nav></div>
    <div className="footer-column"><h2>{nl ? "Hulp & vertrouwen" : "Help & trust"}</h2><nav className="footer-links" aria-label={nl ? "Hulp" : "Help"}><Link prefetch={false} href="/emergency/">{nl ? "Noodgeval (EN)" : "Emergency"}</Link><Link prefetch={false} href="/status/">{nl ? "Inhoudsstatus (EN)" : "Content status"}</Link><Link prefetch={false} href="/support/">{nl ? "Support (EN)" : "Support"}</Link><a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a></nav></div>
    <div className="footer-column"><h2>{nl ? "Taal & voorwaarden" : "Language & legal"}</h2><nav className="footer-links" aria-label={nl ? "Taal en voorwaarden" : "Language and legal"}><LanguageLink locale={locale} expanded /><Link prefetch={false} href="/privacy/">{nl ? "Privacy (EN)" : "Privacy"}</Link><Link prefetch={false} href="/terms/">{nl ? "Voorwaarden (EN)" : "Terms"}</Link><Link prefetch={false} href={nl ? "/nl/voor-bedrijven/aanmelden/" : "/for-business/local/apply/"}>{nl ? "Gratis bedrijfsprofiel" : "Free business profile"}</Link></nav></div>
  </div></footer>;
}
