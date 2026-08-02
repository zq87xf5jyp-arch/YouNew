"use client";

import Link from "next/link";
import {
  ArrowRight,
  Bookmark,
  CheckCircle2,
  Clock3,
  Eye,
  ListChecks,
  LockKeyhole,
  MapPin,
  Route,
  Trash2
} from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { ContentMedia } from "@/components/content-media";
import { LocalDataControls } from "@/components/local-data-controls";
import { practicalJourneys } from "@/lib/journeys/definitions";
import { plannerGoals, type PlannerGoalId } from "@/lib/planner/definitions";
import {
  journeyCompletion,
  localContentRepository,
  type JourneyProgressState,
  type RecentContentItem,
  type SavedContentItem,
  type SavedPlannerState
} from "@/lib/storage/local-content";
import type { PublicMediaAsset } from "@/lib/content";

type MunicipalityOption = Readonly<{ slug: string; name: string }>;
type LatestUpdate = Readonly<{
  id: string;
  route: string;
  title: string;
  kind: string;
  updatedLabel: string;
  media: PublicMediaAsset | null;
}>;

const profileLabels: Record<SavedPlannerState["profile"], string> = {
  "new-resident": "New resident",
  student: "Student",
  expat: "Expat",
  worker: "Worker",
  refugee: "Refugee",
  tourist: "Tourist",
  resident: "Resident",
  "prefer-not-to-say": "Prefer not to say"
};

const goalById = new Map<PlannerGoalId, (typeof plannerGoals)[number]>(
  plannerGoals.map((goal) => [goal.id, goal])
);
const availableJourneys = practicalJourneys.filter((journey) => journey.guideIds.length > 0);

function relativeLabel(value: string) {
  const elapsed = Date.now() - Date.parse(value);
  if (!Number.isFinite(elapsed) || elapsed < 0) return "Recently";
  const minutes = Math.floor(elapsed / 60_000);
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} h ago`;
  const days = Math.floor(hours / 24);
  return days === 1 ? "Yesterday" : `${Math.min(days, 99)} days ago`;
}

export function MyYouNewDashboard({
  municipalities,
  latestUpdates
}: {
  municipalities: readonly MunicipalityOption[];
  latestUpdates: readonly LatestUpdate[];
}) {
  const [route, setRoute] = useState<SavedPlannerState | null>(null);
  const [savedItems, setSavedItems] = useState<SavedContentItem[]>([]);
  const [recentItems, setRecentItems] = useState<RecentContentItem[]>([]);
  const [journeyStates, setJourneyStates] = useState<JourneyProgressState>({});
  const [ready, setReady] = useState(false);
  const [notice, setNotice] = useState("");

  function refresh() {
    setRoute(localContentRepository.plannerRoute());
    setSavedItems(localContentRepository.saved());
    setRecentItems(localContentRepository.recent());
    setJourneyStates(localContentRepository.journeyProgress());
    setReady(true);
  }

  useEffect(() => {
    refresh();
    window.addEventListener("younew:storage", refresh);
    return () => window.removeEventListener("younew:storage", refresh);
  }, []);

  const municipalityName = route
    ? municipalities.find((municipality) => municipality.slug === route.municipalitySlug)?.name ?? route.municipalitySlug
    : "";
  const routeGoals = route?.goalIds
    .map((goalId) => goalById.get(goalId))
    .filter((goal) => goal !== undefined) ?? [];
  const journeySummaries = useMemo(() => availableJourneys.map((journey) => ({
    ...journey,
    completion: journeyCompletion(journeyStates, journey.id, journey.guideIds),
    hasProgress: journey.guideIds.some((guideId) => (journeyStates[journey.id]?.[guideId] ?? "not-started") !== "not-started")
  })), [journeyStates]);
  const activeJourney = journeySummaries.find((journey) => journey.hasProgress) ?? journeySummaries[0];
  const allJourneySteps = availableJourneys.reduce((total, journey) => total + journey.guideIds.length, 0);
  const completedJourneySteps = availableJourneys.reduce(
    (total, journey) => total + journeyCompletion(journeyStates, journey.id, journey.guideIds).completed,
    0
  );

  function removeSaved(item: SavedContentItem) {
    const stillSaved = localContentRepository.toggleSaved(item);
    refresh();
    setNotice(stillSaved
      ? `${item.title} could not be removed from this browser.`
      : `${item.title} was removed from saved materials.`);
  }

  if (!ready) {
    return <div className="my-dashboard-loading" role="status">Loading local YouNew progress…</div>;
  }

  return (
    <div className="my-dashboard">
      <section className="my-dashboard-primary" aria-label="Your saved route and local activity">
        <article className="my-route-panel">
          <header>
            <div><Route aria-hidden /><h2>Your next step</h2></div>
            {route ? <span>{profileLabels[route.profile]}</span> : null}
          </header>
          {route ? (
            <>
              <div className="my-route-context">
                <span><MapPin aria-hidden /><small>Location</small><strong>{municipalityName}</strong></span>
                <span><ListChecks aria-hidden /><small>Your goals</small><strong>{routeGoals.length} selected</strong></span>
              </div>
              <div className="my-route-goals">
                {routeGoals.map((goal) => <span key={goal.id}>{goal.title}</span>)}
              </div>
              <ol className="my-route-actions">
                {routeGoals.map((goal, index) => (
                  <li key={goal.id}>
                    <span>{index + 1}</span>
                    <div><strong>Continue {goal.title.toLowerCase()}</strong><small>Open the saved route for its published or responsible-source destination.</small></div>
                    <ArrowRight aria-hidden />
                  </li>
                ))}
              </ol>
              <div className="my-panel-actions">
                <Link className="button button-primary" href="/start">Resume route <ArrowRight aria-hidden /></Link>
                <Link className="button button-outline" href="/start">Change route</Link>
              </div>
            </>
          ) : (
            <div className="my-empty-panel">
              <Route aria-hidden />
              <h3>No route saved yet</h3>
              <p>Build a local route from your situation, municipality and up to three priorities.</p>
              <Link className="button button-primary" href="/start">Build my route <ArrowRight aria-hidden /></Link>
            </div>
          )}
        </article>

        <aside className="my-device-panel">
          <h2>This device</h2>
          <Link href="/saved"><Bookmark aria-hidden /><span><strong>Saved materials</strong><small>{savedItems.length} items</small></span><ArrowRight aria-hidden /></Link>
          <Link href="/journeys"><CheckCircle2 aria-hidden /><span><strong>Journey progress</strong><small>{completedJourneySteps} of {allJourneySteps} published steps</small></span><ArrowRight aria-hidden /></Link>
          <a href="#recently-viewed"><Eye aria-hidden /><span><strong>Recently viewed</strong><small>{recentItems.length} items</small></span><ArrowRight aria-hidden /></a>
          <div className="my-device-privacy"><LockKeyhole aria-hidden /><p><strong>Not synced to an account.</strong> Your web progress stays in this browser.</p><Link href="/privacy">Learn more</Link></div>
        </aside>
      </section>

      {activeJourney ? (
        <section className="my-journey-continue" aria-labelledby="my-journey-title">
          <header><h2 id="my-journey-title">Continue a journey</h2><Link href="/journeys">View all journeys <ArrowRight aria-hidden /></Link></header>
          <div>
            <span className="my-journey-count">{activeJourney.completion.completed}<small>of {activeJourney.completion.total}</small></span>
            <span><strong>{activeJourney.title}</strong><small>{activeJourney.description}</small></span>
            <span className="my-journey-progress"><small>Progress</small><progress max={activeJourney.completion.total} value={activeJourney.completion.completed} /></span>
            <Link className="button button-outline" href={`/journeys/#${activeJourney.id}`}>{activeJourney.hasProgress ? "Resume" : "Start"} <ArrowRight aria-hidden /></Link>
          </div>
        </section>
      ) : null}

      {notice ? <p className="my-dashboard-notice" role="status">{notice}</p> : null}

      <section className="my-dashboard-columns">
        <section aria-labelledby="saved-for-later-title">
          <header><h2 id="saved-for-later-title"><Bookmark aria-hidden /> Saved for later</h2><Link href="/saved">View all</Link></header>
          {savedItems.length > 0 ? (
            <ul>{savedItems.slice(0, 4).map((item) => (
              <li key={item.id}>
                <Link href={item.route}><span>{item.kind}</span><strong>{item.title}</strong></Link>
                <button type="button" onClick={() => removeSaved(item)} aria-label={`Remove ${item.title} from saved materials`}><Trash2 aria-hidden /></button>
              </li>
            ))}</ul>
          ) : <div className="my-column-empty"><p>No saved materials yet.</p><Link href="/discover">Explore published content</Link></div>}
        </section>

        <section id="recently-viewed" aria-labelledby="my-recent-title">
          <header><h2 id="my-recent-title"><Clock3 aria-hidden /> Recently viewed</h2><Link href="/discover">Explore</Link></header>
          {recentItems.length > 0 ? (
            <ul>{recentItems.slice(0, 5).map((item) => (
              <li key={item.id}><Link href={item.route}><span>{item.kind}</span><strong>{item.title}</strong><small>{relativeLabel(item.viewedAt)}</small></Link></li>
            ))}</ul>
          ) : <div className="my-column-empty"><p>Pages you open will appear here.</p><Link href="/search">Search YouNew</Link></div>}
        </section>

        <section className="my-latest-updates" aria-labelledby="my-updates-title">
          <header><h2 id="my-updates-title"><Eye aria-hidden /> Latest reviewed updates</h2><Link href="/updates">View all</Link></header>
          {latestUpdates[0] ? (
            <Link className="my-update-lead" href={latestUpdates[0].route}>
              {latestUpdates[0].media ? <ContentMedia asset={latestUpdates[0].media} variant="card" /> : null}
              <span><small>{latestUpdates[0].kind} · {latestUpdates[0].updatedLabel}</small><strong>{latestUpdates[0].title}</strong><em>Open published record <ArrowRight aria-hidden /></em></span>
            </Link>
          ) : null}
          <div className="my-update-list">{latestUpdates.slice(1, 3).map((update) => (
            <Link href={update.route} key={update.id}><span><strong>{update.title}</strong><small>{update.kind} · {update.updatedLabel}</small></span><ArrowRight aria-hidden /></Link>
          ))}</div>
        </section>
      </section>

      <LocalDataControls />
    </div>
  );
}
