import Link from "next/link";
import { ArrowRight, Building2, FileText, Map, MapPin, Search } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { ProfileSelector } from "@/components/profile-selector";
import { RecentlyViewed } from "@/components/recently-viewed";
import { getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Discover", "Personalize a local starting point and explore released YouNew guides, cities, organizations and places.", "/discover");
export default function DiscoverPage() {
  const content = getPublicContent();
  const featured = [...content.guides.slice(0, 4), ...content.organizations.slice(0, 2), ...content.places.slice(0, 3)];
  const destinations = [
    { title: "Search", text: "Find a specific service, place or topic.", href: "/search", count: content.stats.entities, icon: Search },
    { title: "Guides", text: "Source-backed municipal and housing starting points.", href: "/guides", count: content.stats.guides, icon: FileText },
    { title: "Cities", text: "Governed city pages from released content.", href: "/cities", count: content.stats.cities, icon: Map },
    { title: "Organizations", text: "Healthcare, education and local services.", href: "/organizations", count: content.stats.organizations, icon: Building2 },
    { title: "Places", text: "Places, stations, culture, food and events.", href: "/places", count: content.stats.places, icon: MapPin }
  ];
  return (
    <PageShell>
      <section className="app-hero section-shell discover-hero"><Breadcrumbs items={[{ label: "Discover" }]} /><h1>A practical start, shaped around your situation.</h1><p>Choose a profile for local recommendations, or browse all {content.stats.entities} released records. Your preference stays in this browser.</p></section>
      <div className="section-shell discover-layout">
        <ProfileSelector />
        <section className="destination-grid" aria-label="Discover sections">{destinations.map(({ title, text, href, count, icon: Icon }) => <Link href={href} key={href}><Icon aria-hidden /><div><span>{count} published</span><h2>{title}</h2><p>{text}</p></div><ArrowRight aria-hidden /></Link>)}</section>
        <RecentlyViewed />
        <section className="featured-content" aria-labelledby="featured-title"><div className="listing-heading"><div><h2 id="featured-title">Start with published content</h2><p>Selected from the same production artifact used by the iOS app.</p></div><Link href="/categories">All categories <ArrowRight aria-hidden /></Link></div><EntityListing entities={featured} /></section>
      </div>
    </PageShell>
  );
}
