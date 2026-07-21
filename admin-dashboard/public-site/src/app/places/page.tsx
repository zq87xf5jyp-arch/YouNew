import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Places", listingCopy.place.description, "/places");
export default function PlacesPage() { return <ContentIndexPage {...listingCopy.place} entities={getContentEntities("place")} />; }
