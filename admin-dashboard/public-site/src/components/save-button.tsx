"use client";

import { useEffect, useState } from "react";
import { Bookmark } from "lucide-react";
import { track } from "@/lib/analytics/client";
import { localContentRepository } from "@/lib/storage/local-content";

type SaveButtonProps = {
  item: { id: string; route: string; title: string; kind: string };
  compact?: boolean;
};

export function SaveButton({ item, compact = false }: SaveButtonProps) {
  const [saved, setSaved] = useState(false);
  const [interactive, setInteractive] = useState(false);

  useEffect(() => {
    setSaved(localContentRepository.isSaved(item.id));
    setInteractive(true);
  }, [item.id]);

  function toggleSaved() {
    const stored = localContentRepository.toggleSaved(item);
    setSaved(stored);
    if (stored) track({ name: "item_saved", contentId: item.id });
  }

  return (
    <button
      className={`save-button${saved ? " is-saved" : ""}${compact ? " is-compact" : ""}`}
      type="button"
      disabled={!interactive}
      aria-pressed={saved}
      aria-label={saved ? `Remove ${item.title} from saved items` : `Save ${item.title}`}
      onClick={toggleSaved}
    >
      <Bookmark aria-hidden fill={saved ? "currentColor" : "none"} />
      <span>{saved ? "Saved" : "Save"}</span>
    </button>
  );
}
