import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Cities", listingCopy.city.description, "/cities");
export default function CitiesPage() { return <ContentIndexPage {...listingCopy.city} entities={getContentEntities("city")} />; }
