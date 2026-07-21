import { Brand } from "@/components/brand";
import { SiteHeaderEnhancements } from "@/components/site-header-enhancements";
import Link from "next/link";
import { Menu, Search, X } from "lucide-react";

const navigation = [
  ["Discover", "/discover"],
  ["Guides", "/guides"],
  ["Journeys", "/journeys"],
  ["Map", "/map"],
  ["Cities", "/cities"],
  ["Organizations", "/organizations"],
  ["Business", "/business"]
];

export function SiteHeader() {
  return (
    <header className="site-header" data-site-header>
      <SiteHeaderEnhancements />
      <div className="section-shell header-inner">
        <Brand />
        <nav className="desktop-nav" aria-label="Primary navigation">
          {navigation.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}</Link>)}
        </nav>
        <div className="header-actions">
          <Link className="header-search" href="/search" aria-label="Search YouNew" data-nav-href><Search aria-hidden /> <span>Search</span></Link>
          <Link className="header-cta" href="/app" data-nav-href>Get the app</Link>
          <details className="mobile-menu" data-mobile-menu>
            <summary aria-label="Navigation menu" aria-controls="mobile-navigation"><Menu className="menu-open" aria-hidden /><X className="menu-close" aria-hidden /></summary>
            <nav id="mobile-navigation" aria-label="Mobile navigation">
              <Link href="/search" data-nav-href><Search aria-hidden /> Search</Link>
              {navigation.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}</Link>)}
              <Link href="/saved" data-nav-href>Saved</Link>
              <Link href="/emergency" data-nav-href>Emergency</Link>
              <Link href="/status" data-nav-href>Status</Link>
              <Link href="/support" data-nav-href>Support</Link>
              <Link className="mobile-app-cta" href="/app" data-nav-href>Get the app</Link>
            </nav>
          </details>
        </div>
      </div>
    </header>
  );
}
