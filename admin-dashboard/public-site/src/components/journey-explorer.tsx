"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { CheckCircle2, Circle, Clock3, LockKeyhole } from "lucide-react";
import { journeyCompletion, localContentRepository, type JourneyProgressState } from "@/lib/storage/local-content";
import type { JourneyStepState, PracticalJourneyDefinition } from "@/lib/journeys/definitions";

type JourneyGuide = { id: string; title: string; summary: string; route: string; verifiedAt: string };
type JourneyView = PracticalJourneyDefinition & { guides: readonly JourneyGuide[] };

const stateLabels: Record<JourneyStepState, string> = {
  "not-started": "Not started",
  "in-progress": "In progress",
  completed: "Completed"
};

const stateIcons = {
  "not-started": Circle,
  "in-progress": Clock3,
  completed: CheckCircle2
} as const;

export function JourneyExplorer({ journeys }: { journeys: readonly JourneyView[] }) {
  const [states, setStates] = useState<JourneyProgressState>({});
  const [storageNotice, setStorageNotice] = useState<{ message: string; failed: boolean } | null>(null);

  useEffect(() => setStates(localContentRepository.journeyProgress()), []);
  const { availableJourneys, unreleasedJourneys } = useMemo(() => ({
    availableJourneys: journeys.filter((journey) => journey.guides.length > 0),
    unreleasedJourneys: journeys.filter((journey) => journey.guides.length === 0)
  }), [journeys]);

  function update(journeyId: string, guideId: string, guideTitle: string, state: JourneyStepState) {
    const saved = localContentRepository.setJourneyStepState(journeyId, guideId, state);
    if (!saved) {
      setStorageNotice({
        message: `Progress for ${guideTitle} could not be stored on this device. The guide remains available.`,
        failed: true
      });
      return;
    }
    const nextStates = localContentRepository.journeyProgress();
    if (nextStates[journeyId]?.[guideId] !== state) {
      setStorageNotice({
        message: `Progress for ${guideTitle} could not be confirmed in this browser.`,
        failed: true
      });
      return;
    }
    setStates(nextStates);
    setStorageNotice({
      message: `${guideTitle} marked ${stateLabels[state].toLowerCase()}. Progress is stored only in this browser.`,
      failed: false
    });
  }

  function reset(journey: JourneyView) {
    const resetSaved = localContentRepository.resetJourney(journey.id, journey.guides.map((guide) => guide.id));
    if (!resetSaved) {
      setStorageNotice({
        message: `Progress for ${journey.title} could not be reset in this browser.`,
        failed: true
      });
      return;
    }

    const nextStates = localContentRepository.journeyProgress();
    const resetConfirmed = journey.guides.every((guide) => (nextStates[journey.id]?.[guide.id] ?? "not-started") === "not-started");
    if (!resetConfirmed) {
      setStorageNotice({
        message: `The reset for ${journey.title} could not be confirmed in this browser.`,
        failed: true
      });
      return;
    }

    setStates(nextStates);
    setStorageNotice({
      message: `${journey.title} progress was reset to not started in this browser.`,
      failed: false
    });
  }

  function journeyCard(journey: JourneyView) {
    const completion = journeyCompletion(states, journey.id, journey.guides.map((guide) => guide.id));
    const hasProgress = journey.guides.some((guide) => (states[journey.id]?.[guide.id] ?? "not-started") !== "not-started");
    return (
      <section className="journey-card" id={journey.id} key={journey.id} aria-labelledby={`${journey.id}-title`}>
        <header>
          <div><span>{journey.audience}</span><h3 id={`${journey.id}-title`}>{journey.title}</h3><p>{journey.description}</p></div>
          {journey.guides.length > 0 ? <strong aria-label={`${completion.completed} of ${completion.total} completed`}>{completion.completed}/{completion.total}</strong> : <LockKeyhole aria-label="No released guide steps" />}
        </header>
        <p className="journey-coverage-note">{journey.coverageNote}</p>
        {journey.guides.length > 0 ? (
          <>
            <ol className="journey-steps">
              {journey.guides.map((guide, index) => {
                const state = states[journey.id]?.[guide.id] ?? "not-started";
                const Icon = stateIcons[state];
                return (
                  <li key={guide.id} data-state={state}>
                    <div className="journey-step-heading"><span className="journey-order">{index + 1}</span><Icon aria-hidden /><div><Link href={guide.route}>{guide.title}</Link><small>Source checked {guide.verifiedAt}</small></div></div>
                    <p>{guide.summary}</p>
                    <label htmlFor={`${journey.id}-${guide.id}-state`}>Reading status
                      <select id={`${journey.id}-${guide.id}-state`} value={state} onChange={(event) => update(journey.id, guide.id, guide.title, event.target.value as JourneyStepState)}>
                        {Object.entries(stateLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}
                      </select>
                    </label>
                  </li>
                );
              })}
            </ol>
            <footer className="journey-reset-row">
              <button className="button button-ghost journey-reset-button" type="button" disabled={!hasProgress} onClick={() => reset(journey)}>
                Reset journey progress
              </button>
            </footer>
          </>
        ) : <div className="journey-unavailable"><p>YouNew is keeping this sequence closed until its component guides pass the production publication gate.</p><Link href="/search">Search released content</Link></div>}
      </section>
    );
  }

  return (
    <div className="journey-explorer">
      <div className="journey-privacy-note">
        <strong>{availableJourneys.length} of {journeys.length} journeys currently have released guide steps.</strong>
        <p>Progress stays only in this browser. It is not an official task status, account record or iOS sync.</p>
      </div>
      {storageNotice ? <p className="journey-storage-notice" role={storageNotice.failed ? "alert" : "status"}>{storageNotice.message}</p> : null}
      {availableJourneys.length > 0 ? (
        <section className="journey-group" aria-labelledby="available-journeys-title">
          <div className="journey-group-heading">
            <h2 id="available-journeys-title">Available journeys</h2>
            <p>These journeys contain released guides you can open and track locally.</p>
          </div>
          <div className="journey-grid">{availableJourneys.map(journeyCard)}</div>
        </section>
      ) : null}
      {unreleasedJourneys.length > 0 ? (
        <section className="journey-group journey-group-unreleased" aria-labelledby="unreleased-journeys-title">
          <div className="journey-group-heading">
            <h2 id="unreleased-journeys-title">Not released yet</h2>
            <p>These routes remain closed until their guides pass the publication gate.</p>
          </div>
          <div className="journey-grid">{unreleasedJourneys.map(journeyCard)}</div>
        </section>
      ) : null}
    </div>
  );
}
