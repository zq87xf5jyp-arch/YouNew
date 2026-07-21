import Link from "next/link";
import { ChevronRight, Home } from "lucide-react";

export type BreadcrumbItem = { label: string; href?: string };

export function Breadcrumbs({ items }: { items: BreadcrumbItem[] }) {
  return (
    <nav className="breadcrumbs" aria-label="Breadcrumb">
      <ol>
        <li><Link href="/" aria-label="Home"><Home aria-hidden /></Link></li>
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

