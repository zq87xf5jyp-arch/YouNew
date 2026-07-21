import type { ReactNode } from "react";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

export function PageShell({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`web-app-page ${className}`.trim()} data-page-shell>
      <a className="skip-link" href="#main-content">Skip to content</a>
      <SiteHeader />
      <main id="main-content" className="page-shell-main" tabIndex={-1}>{children}</main>
      <SiteFooter />
    </div>
  );
}
