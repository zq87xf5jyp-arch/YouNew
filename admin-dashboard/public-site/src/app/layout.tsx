import type { Metadata, Viewport } from "next";
import "./globals.css";

const description =
  "All-in-one guide for living, working and discovering the Netherlands. Find documents, services, transport, housing, healthcare, city guides, maps and official resources in one app.";

export const metadata: Metadata = {
  metadataBase: new URL("https://younew.nl"),
  title: {
    default: "YouNew.nl — Premium Netherlands Guide",
    template: "%s | YouNew.nl"
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
    "official resources Netherlands"
  ],
  openGraph: {
    title: "YouNew.nl — Premium Netherlands Guide",
    description,
    url: "https://younew.nl",
    siteName: "YouNew.nl",
    images: [
      {
        url: "/images/home-leiden-canals.jpg",
        width: 1920,
        height: 1207,
        alt: "YouNew.nl Netherlands guide preview with Leiden canals"
      }
    ],
    locale: "en_US",
    type: "website"
  },
  twitter: {
    card: "summary_large_image",
    title: "YouNew.nl — Premium Netherlands Guide",
    description,
    images: ["/images/home-leiden-canals.jpg"]
  },
  icons: {
    icon: "/icons/favicon.png",
    apple: "/icons/favicon.png"
  }
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#020713"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
