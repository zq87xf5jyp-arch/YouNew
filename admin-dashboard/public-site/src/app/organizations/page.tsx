import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { listingCopy } from "@/lib/content/page-helpers";
import { metadataForPage } from "@/lib/seo/metadata";

const organizations = getContentEntities("organization");
export const metadata = metadataForPage("Organizations", listingCopy.organization.description, "/organizations", { noIndex: organizations.length === 0, follow: true });
export default function OrganizationsPage() { return <ContentIndexPage {...listingCopy.organization} entities={organizations} featuredId="healthcare.amsterdam-umc-location-vumc" />; }
