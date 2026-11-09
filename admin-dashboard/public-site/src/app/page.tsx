import type { Metadata } from "next";
import { DiscoveryHome } from "@/components/discovery-home";

export const metadata: Metadata = {
  title: { absolute: "YouNew — Your guide to life in the Netherlands" },
  description: "Find housing, work, documents, healthcare, schools and trusted services in the Netherlands—with clear next steps and official sources.",
  alternates: { canonical: "https://younew.nl/", languages: { en: "https://younew.nl/", nl: "https://younew.nl/nl/", "x-default": "https://younew.nl/" } }
};

export default function HomePage() { return <DiscoveryHome locale="en" />; }
