import { serializeJsonLd } from "@/lib/seo/json-ld";
import Link from "next/link";
import { ChevronRight, Home } from "lucide-react";

export type BreadcrumbItem = { label: string; href?: string };

export function Breadcrumbs({ items, locale = "en" }: { items: BreadcrumbItem[]; locale?: "en" | "nl" }) {
  return (
    <nav className="breadcrumbs" aria-label={locale === "nl" ? "Kruimelpad" : "Breadcrumb"}>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd({
        "@context": "https://schema.org", "@type": "BreadcrumbList",
        itemListElement: [{ label: locale === "nl" ? "Start" : "Home", href: locale === "nl" ? "/nl/" : "/" }, ...items].map((item, index) => ({
          "@type": "ListItem", position: index + 1, name: item.label,
          ...(item.href ? { item: `https://younew.nl${item.href.replace(/\/$/, "")}/` } : {})
        }))
      }) }} />
      <ol>
        <li><Link href={locale === "nl" ? "/nl/" : "/"} aria-label={locale === "nl" ? "Start" : "Home"}><Home aria-hidden /></Link></li>
        {items.map((item, index) => (
          <li key={`${item.label}-${index}`}>
            <ChevronRight aria-hidden />
            {item.href ? <Link href={item.href}>{item.label}</Link> : <span aria-current="page">{item.label}</span>}
          </li>
        ))}
      </ol>
    </nav>
  );
}

