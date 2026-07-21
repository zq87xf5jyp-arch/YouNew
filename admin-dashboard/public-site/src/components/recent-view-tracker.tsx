"use client";

import { useEffect } from "react";
import { localContentRepository } from "@/lib/storage/local-content";

export function RecentViewTracker({ item }: { item: { id: string; route: string; title: string; kind: string } }) {
  useEffect(() => localContentRepository.rememberViewed(item), [item]);
  return null;
}

