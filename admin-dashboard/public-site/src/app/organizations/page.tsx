import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Organizations", listingCopy.organization.description, "/organizations");
export default function OrganizationsPage() { return <ContentIndexPage {...listingCopy.organization} entities={getContentEntities("organization")} />; }
