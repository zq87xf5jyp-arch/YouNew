import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";
import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer footer-minimal">
      <div className="section-shell footer-minimal-grid">
        <div className="footer-brand"><Brand /><p className="footer-copy">Practical routes for building a confident life in the Netherlands.</p><p className="copyright">© 2026 YouNew. English interface.</p></div>
        <nav className="footer-minimal-links" aria-label="Footer navigation">
          <Link href="/discover">Explore</Link>
          <Link href="/guides">Guides</Link>
          <Link href="/cities">Cities</Link>
          <Link href="/naruto">Naruto</Link>
          <Link href="/about">About</Link>
          <Link href="/status">Status</Link>
          <Link href="/support">Support</Link>
          <Link href="/business">Business</Link>
          <Link href="/privacy">Privacy</Link>
          <Link href="/terms">Terms</Link>
          <a href={`mailto:${links.contactEmail}`}>Contact</a>
        </nav>
      </div>
    </footer>
  );
}
