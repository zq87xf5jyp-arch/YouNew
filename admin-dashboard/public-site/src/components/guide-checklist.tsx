"use client";

import Link from "next/link";
import { ArrowRight, ExternalLink, MapPin } from "lucide-react";
import { useEffect, useId, useMemo, useState } from "react";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import type { GuideOfficialSource, GuideSourcedText } from "@/lib/content";
import {
  guideChecklistCompletion,
  localContentRepository,
  type GuideChecklistState
} from "@/lib/storage/local-content";

type NextGuide = Readonly<{ title: string; route: string }>;
type ChecklistItem = GuideSourcedText | string;

export function GuideChecklist({
  guideId,
  items,
  sources = [],
  nextGuide,
  showPersonalisedNextStep = false
}: {
  guideId: string;
  items: readonly ChecklistItem[];
  sources?: readonly GuideOfficialSource[];
  nextGuide?: NextGuide;
  showPersonalisedNextStep?: boolean;
}) {
  const progressId = useId();
  const persistenceNoteId = useId();
  const [states, setStates] = useState<GuideChecklistState>({});
  const [interactive, setInteractive] = useState(false);
  const [notice, setNotice] = useState<{ message: string; failed: boolean } | null>(null);
  const normalizedItems = useMemo(() => items.map((item, index) => typeof item === "string"
    ? { id: `step-${index + 1}`, text: item, sourceIds: [] as readonly string[] }
    : item), [items]);
  const itemIds = useMemo(() => normalizedItems.map((item) => item.id), [normalizedItems]);
  const completion = guideChecklistCompletion(states, guideId, itemIds);

  useEffect(() => {
    setStates(localContentRepository.guideChecklistState());
    setInteractive(true);
  }, []);

  function update(itemId: string, completed: boolean) {
    const stored = localContentRepository.setGuideChecklistItem(guideId, itemId, completed);
    const nextStates = localContentRepository.guideChecklistState();
    if (!stored || nextStates[guideId]?.[itemId] !== completed) {
      setNotice({
        message: "This browser did not allow YouNew to store that reading step.",
        failed: true
      });
      return;
    }
    setStates(nextStates);
    setNotice({
      message: completed ? "Reading step marked on this device." : "Reading step reopened on this device.",
      failed: false
    });
  }

  return (
    <div className="guide-checklist-widget" role="group" aria-labelledby={progressId} aria-describedby={persistenceNoteId}>
      <div className="guide-checklist-progress">
        <label id={progressId}>Reading progress: {completion.completed} of {completion.total}</label>
        <progress aria-labelledby={progressId} max={Math.max(completion.total, 1)} value={completion.completed} />
        <p id={persistenceNoteId}>Stored only in this browser. A checked item means you reviewed it; it does not prove eligibility, submission or official completion.</p>
      </div>
      <ul>
        {normalizedItems.map((item) => {
          const itemId = item.id;
          const inputId = `${guideId}-${itemId}`;
          const completed = states[guideId]?.[itemId] === true;
          const itemSources = item.sourceIds.map((sourceId) => sources.find((source) => source.id === sourceId)).filter(Boolean);
          return (
            <li key={itemId}>
              <label htmlFor={inputId}>
                <input checked={completed} disabled={!interactive} id={inputId} onChange={(event) => update(itemId, event.target.checked)} type="checkbox" />
                <span>{item.text}</span>
              </label>
              {itemSources.length > 0 ? (
                <span className="guide-inline-sources" aria-label="Sources for this checklist item">
                  {itemSources.map((source, index) => source ? <TrackedOfficialSourceLink aria-label={`Source ${index + 1}: ${source.publisher} — ${source.title} (opens in a new tab)`} contentId={source.id} href={source.url} rel="noreferrer" target="_blank" key={source.id}>Source {index + 1}<ExternalLink aria-hidden /></TrackedOfficialSourceLink> : null)}
                </span>
              ) : null}
            </li>
          );
        })}
      </ul>
      <p className="guide-checklist-notice" role={notice?.failed ? "alert" : "status"} aria-live="polite">{notice?.message ?? "You can uncheck any step if you need to review it again."}</p>
      {nextGuide || showPersonalisedNextStep ? (
        <div className="guide-next-step">
          <div><strong>What should I do next?</strong><span>Use your situation and municipality to check the exact route.</span></div>
          <nav aria-label="Next steps from this guide">
            {nextGuide ? <Link href={nextGuide.route}>{nextGuide.title} <ArrowRight aria-hidden /></Link> : null}
            <Link href="/start/"><MapPin aria-hidden /> Personalise my next step</Link>
          </nav>
        </div>
      ) : null}
    </div>
  );
}
