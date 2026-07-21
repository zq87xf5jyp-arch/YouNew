import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Source-backed guides", listingCopy.guide.description, "/guides");
export default function GuidesPage() { return <ContentIndexPage {...listingCopy.guide} entities={getContentEntities("guide")} />; }
