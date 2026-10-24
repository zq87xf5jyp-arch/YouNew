import { Brand } from "@/components/brand";
import { SiteHeaderEnhancements } from "@/components/site-header-enhancements";
import { ThemeToggle } from "@/components/theme-toggle";
import Link from "next/link";
import { Bookmark, LifeBuoy, Menu, Search, X } from "lucide-react";

const navigation = [
  ["Explore", "/discover"],
  ["Housing", "/categories/housing"],
  ["Work", "/search/?q=work"],
  ["Healthcare", "/categories/healthcare"],
  ["Services", "/organizations"],
  ["Cities", "/cities"],
  ["Guides", "/guides"],
  ["Business", "/for-business"]
];

const dutchNavigation = [["Ontdekken", "/nl/"], ["Wonen", "/nl/categorieen/housing"], ["Werk", "/nl/zoeken/?q=werk"], ["Zorg", "/nl/categorieen/healthcare"], ["Organisaties", "/nl/organisaties"], ["Categorieën", "/nl/categorieen"], ["Stadsgidsen", "/nl/stadsgidsen/amsterdam"], ["Voor bedrijven", "/nl/voor-bedrijven"]];

export function SiteHeader({ locale = "en" }: { locale?: "en" | "nl" }) {
  const isDutch = locale === "nl";
  const items = isDutch ? dutchNavigation : navigation;
  return (
    <header className="site-header" data-site-header>
      <SiteHeaderEnhancements />
      <div className="section-shell header-inner">
        <Brand href={isDutch ? "/nl/" : "/"} homeLabel={isDutch ? "YouNew startpagina" : "YouNew home"} />
        <nav className="desktop-nav" aria-label={isDutch ? "Hoofdnavigatie" : "Primary navigation"}>
          {items.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}</Link>)}
        </nav>
        <div className="header-actions">
          <Link className="header-search" href={isDutch ? "/nl/zoeken" : "/search"} aria-label={isDutch ? "Zoeken op YouNew" : "Search YouNew"} data-nav-href><Search aria-hidden /> <span>{isDutch ? "Zoeken" : "Search"}</span></Link>
          <Link className="header-emergency" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> <span>{isDutch ? "Noodgeval" : "Emergency"}</span></Link>
          <Link href={isDutch ? "/" : "/nl/"} hrefLang={isDutch ? "en" : "nl"} data-nav-href>{isDutch ? "EN" : "NL"}</Link>
          <ThemeToggle locale={locale} />
          <details className="mobile-menu" data-mobile-menu>
            <summary aria-label={isDutch ? "Navigatiemenu" : "Navigation menu"} aria-controls="mobile-navigation"><Menu className="menu-open" aria-hidden /><X className="menu-close" aria-hidden /></summary>
            <nav id="mobile-navigation" aria-label={isDutch ? "Mobiele navigatie" : "Mobile navigation"}>
              {items.map(([label, href]) => <Link href={href} data-nav-href key={href}>{label}</Link>)}
              <Link href={isDutch ? "/saved" : "/saved"} data-nav-href><Bookmark aria-hidden /> {isDutch ? "Bewaard" : "Saved"}</Link>
              <Link href={isDutch ? "/nl/zoeken" : "/search"} data-nav-href><Search aria-hidden /> {isDutch ? "Zoeken" : "Search"}</Link>
              <Link className="mobile-emergency-link" href="/emergency" data-nav-href><LifeBuoy aria-hidden /> {isDutch ? "Noodgeval" : "Emergency"}</Link>
            </nav>
          </details>
        </div>
      </div>
    </header>
  );
}
