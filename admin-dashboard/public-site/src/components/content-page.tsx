import type { ReactNode } from "react";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

export function ContentPage({ title, description, children }: { title: string; description: string; children: ReactNode }) {
  return (
    <main className="min-h-screen bg-site-radial">
      <SiteHeader />
      <section className="section-shell pb-20 pt-32">
        <div className="max-w-3xl">
          <h1 className="text-balance text-4xl font-black leading-tight text-white sm:text-6xl">{title}</h1>
          <p className="mt-5 text-lg leading-8 text-text-muted">{description}</p>
        </div>
        <div className="content-body glass mt-10 max-w-4xl rounded-[28px] p-6 sm:p-8">
          {children}
        </div>
      </section>
      <SiteFooter />
    </main>
  );
}
