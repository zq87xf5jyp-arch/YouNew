import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="section-shell footer-grid">
        <div><Brand /><p className="footer-copy">A practical web and iPhone guide for tourists, students, expats, refugees and new residents in the Netherlands.</p><div className="locale-status" aria-label="Language availability"><strong>Web:</strong> English reviewed · Nederlands, Русский, Українська and Polski pending content review</div></div>
        <div className="footer-column"><h2>Explore</h2><nav className="footer-links" aria-label="Explore links"><Link href="/discover">Discover</Link><Link href="/search">Search</Link><Link href="/guides">Guides</Link><Link href="/journeys">Journeys</Link><Link href="/map">Map</Link><Link href="/cities">Cities</Link><Link href="/provinces">Provinces</Link><Link href="/organizations">Organizations</Link></nav></div>
        <div className="footer-column"><h2>Product</h2><nav className="footer-links" aria-label="Product links"><Link href="/app">iPhone app</Link><Link href="/saved">Saved items</Link><Link href="/emergency">Emergency</Link><Link href="/status">Service status</Link><Link href="/business">Business</Link><Link href="/business/media-kit">Business media kit</Link></nav></div>
        <div className="footer-column"><h2>Help and legal</h2><nav className="footer-links" aria-label="Help and legal links"><Link href="/privacy">Privacy Policy</Link><Link href="/terms">Terms of Use</Link><Link href="/support">Support</Link><a href={`mailto:${links.contactEmail}`}>{links.contactEmail}</a></nav><p className="copyright">© 2026 YouNew. All rights reserved.</p></div>
      </div>
    </footer>
  );
}
