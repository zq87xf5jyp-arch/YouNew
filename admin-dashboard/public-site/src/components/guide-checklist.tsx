"use client";

import { useEffect, useId, useMemo, useState } from "react";
import { ExternalLink } from "lucide-react";
import type { GuideOfficialSource, GuideSourcedText } from "@/lib/content";
import { guideChecklistCompletion, localContentRepository, type GuideChecklistState } from "@/lib/storage/local-content";

export function GuideChecklist({
  guideId,
  items,
  sources
}: {
  guideId: string;
  items: readonly GuideSourcedText[];
  sources: readonly GuideOfficialSource[];
}) {
  const [states, setStates] = useState<GuideChecklistState>({});
  const [interactive, setInteractive] = useState(false);
  const [notice, setNotice] = useState("");
  const progressId = useId();
  const persistenceNoteId = useId();

  useEffect(() => {
    setStates(localContentRepository.guideChecklistState());
    setInteractive(true);
  }, []);

  const completion = useMemo(
    () => guideChecklistCompletion(states, guideId, items.map((item) => item.id)),
    [guideId, items, states]
  );

  function update(itemId: string, completed: boolean) {
    const saved = localContentRepository.setGuideChecklistItem(guideId, itemId, completed);
    setStates(localContentRepository.guideChecklistState());
    setNotice(saved ? "Checklist saved on this device." : "This browser could not save the checklist change.");
  }

  return (
    <div className="guide-checklist-widget" role="group" aria-labelledby="checklist-title" aria-describedby={persistenceNoteId}>
      <div className="guide-checklist-progress">
        <label htmlFor={progressId}>{completion.completed} of {completion.total} completed</label>
        <progress id={progressId} value={completion.completed} max={Math.max(completion.total, 1)} aria-valuetext={`${completion.completed} of ${completion.total} checklist items completed`} />
        <p id={persistenceNoteId}>Progress stays in this browser. It is not synced to the YouNew app or an account.</p>
      </div>
      <ul>
        {items.map((item) => {
          const checked = states[guideId]?.[item.id] === true;
          const itemSources = item.sourceIds.map((sourceId) => sources.find((source) => source.id === sourceId)).filter(Boolean);
          return (
            <li key={item.id}>
              <label>
                <input type="checkbox" disabled={!interactive} checked={checked} onChange={(event) => update(item.id, event.target.checked)} />
                <span>{item.text}</span>
              </label>
              {itemSources.length > 0 ? (
                <span className="guide-inline-sources" aria-label="Sources for this checklist item">
                  {itemSources.map((source, index) => source ? <a aria-label={`Source ${index + 1}: ${source.publisher} — ${source.title} (opens in a new tab)`} href={source.url} rel="noreferrer" target="_blank" key={source.id}>Source {index + 1}<ExternalLink aria-hidden /></a> : null)}
                </span>
              ) : null}
            </li>
          );
        })}
      </ul>
      <p className="guide-checklist-notice" role="status" aria-live="polite">{notice}</p>
    </div>
  );
}
