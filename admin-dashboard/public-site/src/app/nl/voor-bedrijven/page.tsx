import { BusinessDiscovery } from "@/components/business-discovery";
import { metadataForPage } from "@/lib/seo/metadata";
export const metadata = metadataForPage("YouNew voor bedrijven", "Vraag een gratis, gecontroleerd bedrijfsprofiel aan. Duidelijke informatie, zichtbare bronnen en publicatie na goedkeuring.", "/nl/voor-bedrijven", { locale: "nl" });
export default function Page() { return <BusinessDiscovery locale="nl" />; }
