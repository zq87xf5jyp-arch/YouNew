import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter({ locale = "en" }: { locale?: "en" | "nl" }) {
  const isDutch = locale === "nl";
  if (isDutch) return (
    <footer className="site-footer" lang="nl">
      <div className="section-shell footer-grid">
        <div className="footer-brand"><Brand href="/nl/" homeLabel="YouNew startpagina" /><p className="footer-copy">Praktische en controleerbare informatie voor een nieuw leven in Nederland.</p><p className="locale-status"><strong>Taal:</strong> Nederlands</p><p className="copyright">© 2026 YouNew.</p></div>
        <div className="footer-column"><h2>Ontdekken</h2><nav className="footer-links" aria-label="Ontdeklinks"><Link href="/nl/categorieen">Categorieën</Link><Link href="/nl/zoeken">Zoeken</Link><Link href="/nl/organisaties">Organisaties</Link><Link href="/nl/stadsgidsen/amsterdam">Stadsgidsen</Link></nav></div>
        <div className="footer-column"><h2>Hulp</h2><nav className="footer-links" aria-label="Hulplinks"><Link href="/emergency">Noodgeval</Link><Link href="/support">Support</Link><Link href="/status">Inhoudsstatus</Link><Link href="/privacy">Privacy</Link></nav></div>
        <div className="footer-column"><h2>Voor bedrijven</h2><nav className="footer-links" aria-label="Zakelijke links"><Link href="/nl/voor-bedrijven">Overzicht</Link><Link href="/nl/voor-bedrijven/lokaal">Profiel toevoegen of claimen</Link><Link href="/nl/voor-bedrijven/aanmelden">Gratis aanmelden</Link></nav></div>
        <div className="footer-column"><h2>Taal</h2><nav className="footer-links" aria-label="Taalkeuze"><Link href="/" hrefLang="en">English</Link><Link href="/nl/" hrefLang="nl">Nederlands</Link><a href={`mailto:${links.contactEmail}`}>Contact</a></nav></div>
      </div>
    </footer>
  );
  return (
    <footer className="site-footer">
      <div className="section-shell footer-grid">
        <div className="footer-brand"><Brand /><p className="footer-copy">Helping newcomers build a confident life in the Netherlands.</p><p className="locale-status"><strong>Website language:</strong> English</p><p className="copyright">© 2026 YouNew. All rights reserved.</p></div>
        <div className="footer-column"><h2>Explore</h2><nav className="footer-links" aria-label="Explore links"><Link href="/discover">Explore the Netherlands</Link><Link href="/categories/housing">Housing</Link><Link href="/search/?q=work">Work</Link><Link href="/categories/healthcare">Healthcare</Link><Link href="/cities">Cities</Link><Link href="/guides">Guides</Link></nav></div>
        <div className="footer-column"><h2>Help</h2><nav className="footer-links" aria-label="Help links"><Link href="/start">Find my next step</Link><Link href="/search">Search</Link><Link href="/saved">Saved</Link><Link href="/my-younew">My YouNew</Link><Link href="/app">iOS app</Link><Link href="/emergency">Emergency</Link><Link href="/support">Support</Link><Link href="/status">Status</Link></nav></div>
        <div className="footer-column"><h2>Legal</h2><nav className="footer-links" aria-label="Legal links"><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><a href={`mailto:${links.contactEmail}`}>Contact</a></nav></div>
        <div className="footer-column"><h2>Business</h2><nav className="footer-links" aria-label="Business links"><Link href="/for-business">Overview</Link><Link href="/for-business/local">Add or claim a business</Link><Link href="/for-business/pilot">90-day pilot</Link><Link href="/for-business/demo-report">Sample report</Link><Link href="/partners">Partner principles</Link><Link href="/partners/apply">Request pilot</Link></nav></div>
      </div>
    </footer>
  );
}
