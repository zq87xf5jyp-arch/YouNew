import { Brand } from "@/components/brand";
import { SiteHeaderEnhancements } from "@/components/site-header-enhancements";
import { ThemeToggle } from "@/components/theme-toggle";
import Link from "next/link";
import { Bookmark, LifeBuoy, Menu, Search, X } from "lucide-react";

const navigation = [
  ["Start", "/start"],
  ["Guides", "/guides"],
  ["Cities", "/cities"],
  ["Map", "/map"]
];

export function SiteHeader() {
  return (
    <header className="site-header" data-site-header>
      <SiteHeaderEnhancements />
      <div className="section-shell header-inner">
        <Brand />
        <nav className="desktop-nav" aria-label="Primary navigation">
          {navigation.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}{label === "Start" ? <span className="visually-hidden"> with YouNew</span> : null}</Link>)}
        </nav>
        <div className="header-actions">
          <Link className="header-utility-link" href="/saved" aria-label="Saved items" data-nav-href><Bookmark aria-hidden /> <span>Saved</span></Link>
          <Link className="header-search" href="/search" aria-label="Search YouNew" data-nav-href><Search aria-hidden /> <span>Search</span></Link>
          <Link className="header-emergency" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> <span>Emergency</span></Link>
          <ThemeToggle />
          <details className="mobile-menu" data-mobile-menu>
            <summary aria-label="Navigation menu" aria-controls="mobile-navigation"><Menu className="menu-open" aria-hidden /><X className="menu-close" aria-hidden /></summary>
            <nav id="mobile-navigation" aria-label="Mobile navigation">
              {navigation.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}{label === "Start" ? <span className="visually-hidden"> with YouNew</span> : null}</Link>)}
              <Link href="/saved" data-nav-href><Bookmark aria-hidden /> Saved</Link>
              <Link href="/search" data-nav-href><Search aria-hidden /> Search</Link>
              <Link className="mobile-emergency-link" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> Emergency</Link>
            </nav>
          </details>
        </div>
      </div>
    </header>
  );
}
