"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { Bookmark, Trash2 } from "lucide-react";
import { localContentRepository, type SavedContentItem } from "@/lib/storage/local-content";

export function SavedItems() {
  const [items, setItems] = useState<SavedContentItem[] | null>(null);
  const [announcement, setAnnouncement] = useState<{ message: string; failed: boolean } | null>(null);
  const removeButtons = useRef(new Map<string, HTMLButtonElement>());
  const emptyStateTitle = useRef<HTMLHeadingElement>(null);

  function refresh() {
    setItems(localContentRepository.saved());
  }

  useEffect(() => {
    refresh();
    const listener = () => refresh();
    window.addEventListener("younew:storage", listener);
    return () => window.removeEventListener("younew:storage", listener);
  }, []);

  function remove(item: SavedContentItem, index: number) {
    const currentItems = items ?? [];
    const focusTargetId = currentItems[index + 1]?.id ?? currentItems[index - 1]?.id;
    const savedAfterToggle = localContentRepository.toggleSaved(item);
    const nextItems = localContentRepository.saved();
    const removed = !savedAfterToggle && !nextItems.some((savedItem) => savedItem.id === item.id);

    setItems(nextItems);
    if (!removed) {
      setAnnouncement({ message: `${item.title} could not be removed from saved items on this device.`, failed: true });
      return;
    }

    setAnnouncement({ message: `${item.title} was removed from saved items.`, failed: false });
    window.requestAnimationFrame(() => {
      if (focusTargetId) removeButtons.current.get(focusTargetId)?.focus();
      else emptyStateTitle.current?.focus();
    });
  }

  if (items === null) return (
    <div className="loading-state">
      <p role="status">Loading saved items…</p>
      <noscript><p>Saved items are stored in this browser and require JavaScript to be read on this page.</p></noscript>
    </div>
  );
  if (items.length === 0) {
    return (
      <div className="empty-state">
        <Bookmark aria-hidden />
        <h2 ref={emptyStateTitle} tabIndex={-1}>Nothing saved yet</h2>
        {announcement ? <p role={announcement.failed ? "alert" : "status"}>{announcement.message}</p> : null}
        <p>Save a guide, organization or place and its shortcut will be stored in this browser.</p>
        <Link className="button button-primary" href="/discover">Explore published content</Link>
      </div>
    );
  }

  return (
    <div className="saved-items-region">
      {announcement ? <p role={announcement.failed ? "alert" : "status"}>{announcement.message}</p> : null}
      <div className="saved-list">
      {items.map((item, index) => (
        <article key={item.id}>
          <Link href={item.route}><span>{item.kind}</span><h2>{item.title}</h2></Link>
          <button
            ref={(button) => {
              if (button) removeButtons.current.set(item.id, button);
              else removeButtons.current.delete(item.id);
            }}
            type="button"
            onClick={() => remove(item, index)}
            aria-label={`Remove ${item.title} from saved items`}
          >
            <Trash2 aria-hidden /> Remove
          </button>
        </article>
      ))}
      </div>
    </div>
  );
}
