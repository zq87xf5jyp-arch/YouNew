import { LanguageLink } from "@/components/language-link";
import { Brand } from "@/components/brand";
import { SiteHeaderEnhancements } from "@/components/site-header-enhancements";
import { ThemeToggle } from "@/components/theme-toggle";
import Link from "next/link";
import { Bookmark, LifeBuoy, Menu, Search, X } from "lucide-react";

const navigation = [["Live", "/#live"], ["Explore", "/#cities-title"], ["Business", "/for-business"]];
const dutchNavigation = [["Wonen", "/nl/#live"], ["Ontdekken", "/nl/#cities-title"], ["Ondernemen", "/nl/voor-bedrijven"]];

export function SiteHeader({ locale = "en" }: { locale?: "en" | "nl" }) {
  const isDutch = locale === "nl";
  const items = isDutch ? dutchNavigation : navigation;
  return (
    <header className="site-header" data-site-header>
      <SiteHeaderEnhancements />
      <div className="section-shell header-inner">
        <Brand href={isDutch ? "/nl/" : "/"} homeLabel={isDutch ? "YouNew startpagina" : "YouNew home"} />
        <nav className="desktop-nav" aria-label={isDutch ? "Hoofdnavigatie" : "Primary navigation"}>
          {items.map(([label, href]) => <Link prefetch={false} href={href} data-nav-href key={href}>{label}</Link>)}
        </nav>
        <div className="header-actions">
          <Link prefetch={false} className="header-search" href={isDutch ? "/nl/zoeken" : "/search"} aria-label={isDutch ? "Zoeken op YouNew" : "Search YouNew"} data-nav-href><Search aria-hidden /> <span>{isDutch ? "Zoeken" : "Search"}</span></Link>
          <Link prefetch={false} className="header-emergency" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> <span>{isDutch ? "Noodgeval" : "Emergency"}</span></Link>
          <div className="header-preferences">
            <LanguageLink locale={locale} />
            <ThemeToggle locale={locale} />
          </div>
          <details className="mobile-menu" data-mobile-menu>
            <summary aria-label={isDutch ? "Navigatiemenu" : "Navigation menu"} aria-controls="mobile-navigation"><Menu className="menu-open" aria-hidden /><X className="menu-close" aria-hidden /></summary>
            <nav id="mobile-navigation" aria-label={isDutch ? "Mobiele navigatie" : "Mobile navigation"}>
              {items.map(([label, href]) => <Link prefetch={false} href={href} data-nav-href key={href}>{label}</Link>)}
              <Link prefetch={false} href={isDutch ? "/saved" : "/saved"} data-nav-href><Bookmark aria-hidden /> {isDutch ? "Bewaard" : "Saved"}</Link>
              <Link prefetch={false} href={isDutch ? "/nl/zoeken" : "/search"} data-nav-href><Search aria-hidden /> {isDutch ? "Zoeken" : "Search"}</Link>
              <Link prefetch={false} className="mobile-emergency-link" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> {isDutch ? "Noodgeval" : "Emergency"}</Link>
              <div className="mobile-menu-preferences">
                <LanguageLink locale={locale} expanded />
                <div><span>{isDutch ? "Thema" : "Theme"}</span><ThemeToggle locale={locale} /></div>
              </div>
            </nav>
          </details>
        </div>
      </div>
    </header>
  );
}
