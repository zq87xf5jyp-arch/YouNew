import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="section-shell footer-grid">
        <div className="footer-brand"><Brand /><p className="footer-copy">Guidance, local context and responsible source links for life in the Netherlands.</p><p className="locale-status"><strong>Website language:</strong> English</p><p className="copyright">© 2026 YouNew. All rights reserved.</p></div>
        <div className="footer-column"><h2>Explore</h2><nav className="footer-links" aria-label="Explore links"><Link href="/start">Start<span className="visually-hidden"> with YouNew</span></Link><Link href="/guides">Guides</Link><Link href="/cities">Cities</Link><Link href="/map">Map</Link><Link href="/search">Search</Link></nav></div>
        <div className="footer-column"><h2>Product</h2><nav className="footer-links" aria-label="Product links"><Link href="/app">iPhone app</Link><Link href="/saved">Saved</Link><Link href="/emergency">Emergency</Link><Link href="/status">Status</Link></nav></div>
        <div className="footer-column"><h2>For organizations</h2><nav className="footer-links" aria-label="Organization links"><Link href="/business">Business</Link><Link href="/business/media-kit">Media kit</Link><Link href="/business/partners">Partnership information</Link></nav></div>
        <div className="footer-column"><h2>Help and legal</h2><nav className="footer-links" aria-label="Help and legal links"><Link href="/support">Support</Link><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><a href={`mailto:${links.contactEmail}`}>Contact</a></nav></div>
      </div>
    </footer>
  );
}
