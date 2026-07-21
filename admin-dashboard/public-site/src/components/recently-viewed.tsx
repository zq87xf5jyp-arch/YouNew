"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Clock3 } from "lucide-react";
import { localContentRepository, type RecentContentItem } from "@/lib/storage/local-content";

export function RecentlyViewed() {
  const [items, setItems] = useState<RecentContentItem[]>([]);

  useEffect(() => setItems(localContentRepository.recent().slice(0, 5)), []);
  if (items.length === 0) return null;

  return (
    <section className="recently-viewed" aria-labelledby="recent-title">
      <h2 id="recent-title"><Clock3 aria-hidden /> Recently viewed</h2>
      <div>{items.map((item) => <Link href={item.route} key={item.id}><span>{item.kind}</span>{item.title}</Link>)}</div>
    </section>
  );
}

