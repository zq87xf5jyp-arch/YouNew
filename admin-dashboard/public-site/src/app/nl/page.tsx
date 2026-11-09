import type { Metadata } from "next";
import { DiscoveryHome } from "@/components/discovery-home";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata: Metadata = metadataForPage(
  "YouNew — Wegwijs in Nederland",
  "Vind betrouwbare informatie over wonen, werk, documenten, zorg en lokale organisaties in Nederland.",
  "/nl",
  { locale: "nl" }
);

export default function DutchHomePage() { return <DiscoveryHome locale="nl" />; }
