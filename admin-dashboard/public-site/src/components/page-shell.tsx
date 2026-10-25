import type { ReactNode } from "react";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

export function PageShell({ children, className = "", locale = "en" }: { children: ReactNode; className?: string; locale?: "en" | "nl" }) {
  return (
    <div className={`web-app-page ${className}`.trim()} data-page-shell lang={locale}>
      <a className="skip-link" href="#main-content">{locale === "nl" ? "Ga naar de inhoud" : "Skip to content"}</a>
      <SiteHeader locale={locale} />
      <main id="main-content" className="page-shell-main" tabIndex={-1}>{children}</main>
      <SiteFooter locale={locale} />
    </div>
  );
}
