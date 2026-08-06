import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="section-shell footer-grid">
        <div className="footer-brand"><Brand /><p className="footer-copy">Helping newcomers build a confident life in the Netherlands.</p><p className="locale-status"><strong>Website language:</strong> English</p><p className="copyright">© 2026 YouNew. All rights reserved.</p></div>
        <div className="footer-column"><h2>Explore</h2><nav className="footer-links" aria-label="Explore links"><Link href="/discover">Explore the Netherlands</Link><Link href="/categories/housing">Housing</Link><Link href="/search/?q=work">Work</Link><Link href="/categories/healthcare">Healthcare</Link><Link href="/cities">Cities</Link><Link href="/guides">Guides</Link></nav></div>
        <div className="footer-column"><h2>Help</h2><nav className="footer-links" aria-label="Help links"><Link href="/start">Find my next step</Link><Link href="/naruto">Ask Naruto</Link><Link href="/search">Search</Link><Link href="/saved">Saved</Link><Link href="/my-younew">My YouNew</Link><Link href="/app">iOS app</Link><Link href="/emergency">Emergency</Link><Link href="/support">Support</Link><Link href="/status">Status</Link></nav></div>
        <div className="footer-column"><h2>Legal</h2><nav className="footer-links" aria-label="Legal links"><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><a href={`mailto:${links.contactEmail}`}>Contact</a></nav></div>
        <div className="footer-column"><h2>Business</h2><nav className="footer-links" aria-label="Business links"><Link href="/business">Overview</Link><Link href="/business/advertise">Advertising standards</Link><Link href="/business/partners">Partnerships</Link><Link href="/business/media-kit">Media kit</Link></nav></div>
      </div>
    </footer>
  );
}
