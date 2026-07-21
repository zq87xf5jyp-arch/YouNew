import type { Metadata, Viewport } from "next";
import { MotionEnhancer } from "@/components/motion-enhancer";
import { ServiceWorkerRegister } from "@/components/service-worker-register";
import { StatusBanner } from "@/components/status-banner";
import { serializeJsonLd } from "@/lib/seo/json-ld";
import "./globals.css";

const description = "A practical web and iPhone guide for tourists, students, expats, refugees and new residents in the Netherlands—with local search, city context, saved materials and trusted source links.";

export const metadata: Metadata = {
  metadataBase: new URL("https://younew.nl"),
  title: {
    default: "YouNew — A clearer start in the Netherlands",
    template: "%s | YouNew"
  },
  description,
  keywords: [
    "Netherlands guide",
    "expat Netherlands",
    "living in Netherlands",
    "Dutch transport",
    "BSN",
    "DigiD",
    "Netherlands app",
    "Amsterdam guide",
    "Rotterdam guide",
    "housing Netherlands",
    "healthcare Netherlands",
    "official resources Netherlands",
    "refugee guide Netherlands",
    "international student Netherlands"
  ],
  alternates: { canonical: "https://younew.nl/", languages: { "en": "https://younew.nl/", "x-default": "https://younew.nl/" } },
  openGraph: {
    title: "YouNew — A clearer start in the Netherlands",
    description,
    url: "https://younew.nl",
    siteName: "YouNew",
    images: [
      {
        url: "/images/og-younew.jpg",
        width: 1200,
        height: 630,
        alt: "Leiden canals featured in the YouNew Netherlands guide"
      }
    ],
    locale: "en_US",
    type: "website"
  },
  twitter: {
    card: "summary_large_image",
    title: "YouNew — A clearer start in the Netherlands",
    description,
    images: ["/images/og-younew.jpg"]
  },
  icons: {
    icon: "/icons/favicon.png",
    apple: "/icons/apple-touch-icon.png"
  },
  manifest: "/manifest.webmanifest",
  category: "travel"
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#050c1b"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const structuredData = {
    "@context": "https://schema.org",
    "@graph": [
      { "@type": "Organization", "@id": "https://younew.nl/#organization", name: "YouNew", url: "https://younew.nl/", email: "support@younew.nl" },
      { "@type": "WebSite", "@id": "https://younew.nl/#website", url: "https://younew.nl/", name: "YouNew", inLanguage: "en", publisher: { "@id": "https://younew.nl/#organization" } },
      { "@type": "WebApplication", name: "YouNew web guide", applicationCategory: "TravelApplication", browserRequirements: "Requires a modern web browser; core pages remain readable without JavaScript", description, url: "https://younew.nl/discover/", publisher: { "@id": "https://younew.nl/#organization" } },
      { "@type": "SoftwareApplication", name: "YouNew", operatingSystem: "iOS 17.6 or later", applicationCategory: "TravelApplication", description, url: "https://younew.nl/", publisher: { "@id": "https://younew.nl/#organization" } }
    ]
  };
  return (
    <html lang="en">
      <body>
        {children}
        <StatusBanner />
        <MotionEnhancer />
        <ServiceWorkerRegister />
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
      </body>
    </html>
  );
}
