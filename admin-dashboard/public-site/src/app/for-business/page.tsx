import { BusinessDiscovery } from "@/components/business-discovery";
import { metadataForPage } from "@/lib/seo/metadata";
export const metadata = metadataForPage("YouNew for business", "Request a free, reviewed local business profile. Clear information, visible sources and publication after approval.", "/for-business", { locale: "en" });
export default function Page() { return <BusinessDiscovery locale="en" />; }
