import Link from "next/link";
import type { Metadata } from "next";
import { ArrowLeft } from "lucide-react";
import { PageShell } from "@/components/page-shell";

export const metadata: Metadata = {
  title: "Page not found",
  description: "The requested YouNew page could not be found.",
  alternates: { canonical: null },
  robots: { index: false, follow: true },
  openGraph: {
    title: "Page not found | YouNew",
    description: "The requested YouNew page could not be found.",
    siteName: "YouNew",
    type: "website",
    images: []
  },
  twitter: {
    card: "summary",
    title: "Page not found | YouNew",
    description: "The requested YouNew page could not be found.",
    images: []
  }
};

export default function NotFound() {
  return <PageShell className="content-page"><section className="section-shell content-hero"><p className="section-label orange">404</p><h1>That page isn’t here.</h1><p>The link may be outdated. Search the published guide or return to YouNew.</p><div className="hero-actions"><Link className="button button-primary" href="/"><ArrowLeft aria-hidden /> Back to YouNew</Link><Link className="button button-outline" href="/search">Search content</Link></div></section></PageShell>;
}
