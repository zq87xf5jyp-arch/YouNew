"use client";

import Link from "next/link";
import {
  ArrowRight,
  BriefcaseBusiness,
  Building2,
  Check,
  GraduationCap,
  HeartPulse,
  Home,
  Landmark,
  MapPin,
  Plane,
  RotateCcw,
  Save,
  ShieldCheck,
  Users
} from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";
import { track } from "@/lib/analytics/client";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import {
  buildPlannerActions,
  plannerGoals,
  type PlannerGoalId,
  type PlannerGuideRoute,
  type PlannerMunicipality,
  type PlannerProfileId
} from "@/lib/planner/definitions";
import { localContentRepository } from "@/lib/storage/local-content";

const profileOptions = [
  { id: "new-resident", title: "New resident", icon: Users },
  { id: "student", title: "Student", icon: GraduationCap },
  { id: "worker", title: "Worker", icon: BriefcaseBusiness },
  { id: "refugee", title: "Refugee", icon: ShieldCheck },
  { id: "tourist", title: "Tourist", icon: Plane },
  { id: "resident", title: "Resident", icon: Home }
] as const satisfies readonly Readonly<{
  id: PlannerProfileId;
  title: string;
  icon: typeof Users;
}>[];

const goalIcons: Record<PlannerGoalId, typeof Landmark> = {
  registration: Landmark,
  "health-insurance": HeartPulse,
  housing: Home,
  work: BriefcaseBusiness,
  "taxes-benefits": Building2,
  transport: MapPin,
  "urgent-help": ShieldCheck
};

export function NextStepPlanner({
  municipalities,
  guides
}: {
  municipalities: readonly PlannerMunicipality[];
  guides: readonly PlannerGuideRoute[];
}) {
  const defaultMunicipality = municipalities.find((municipality) => municipality.slug === "amsterdam") ?? municipalities[0];
  const [profile, setProfile] = useState<PlannerProfileId>("new-resident");
  const [municipalitySlug, setMunicipalitySlug] = useState(defaultMunicipality?.slug ?? "");
  const [goalIds, setGoalIds] = useState<readonly PlannerGoalId[]>(["registration"]);
  const [submitted, setSubmitted] = useState(true);
  const [saved, setSaved] = useState(false);
  const [storageNotice, setStorageNotice] = useState("");
  const resultRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const parsed = localContentRepository.plannerRoute();
    if (!parsed) return;
    if (!municipalities.some((municipality) => municipality.slug === parsed.municipalitySlug)) return;
    setProfile(parsed.profile);
    setMunicipalitySlug(parsed.municipalitySlug);
    setGoalIds(parsed.goalIds);
    setSubmitted(true);
    setSaved(true);
  }, [municipalities]);

  const municipality = useMemo(
    () => municipalities.find((candidate) => candidate.slug === municipalitySlug) ?? defaultMunicipality,
    [defaultMunicipality, municipalities, municipalitySlug]
  );

  const actions = useMemo(
    () => municipality
      ? buildPlannerActions({ profile, municipality, goalIds, guides })
      : [],
    [goalIds, guides, municipality, profile]
  );

  function toggleGoal(goalId: PlannerGoalId) {
    setSaved(false);
    setSubmitted(false);
    setGoalIds((current) => {
      if (current.includes(goalId)) return current.filter((id) => id !== goalId);
      if (current.length >= 3) return current;
      return [...current, goalId];
    });
  }

  function buildRoute() {
    if (!municipality || goalIds.length === 0) return;
    setSubmitted(true);
    setSaved(false);
    setStorageNotice("");
    window.requestAnimationFrame(() => resultRef.current?.focus());
  }

  function saveRoute() {
    if (!municipality || goalIds.length === 0) return;
    const stored = localContentRepository.setPlannerRoute({
      profile,
      municipalitySlug: municipality.slug,
      goalIds: [...goalIds]
    });
    if (stored) {
      setSaved(true);
      setStorageNotice("Route saved on this device.");
      track({ name: "item_saved", contentId: "planner_route" });
    } else {
      setSaved(false);
      setStorageNotice("This browser did not allow YouNew to save the route.");
    }
  }

  function resetRoute() {
    setProfile("new-resident");
    setMunicipalitySlug(defaultMunicipality?.slug ?? "");
    setGoalIds(["registration"]);
    setSubmitted(false);
    setSaved(false);
    setStorageNotice("");
    localContentRepository.clearPlannerRoute();
  }

  return (
    <div className="next-step-planner">
      <section className="planner-builder" aria-label="Build a practical route">
        <fieldset className="planner-step planner-profile-step">
          <legend><span>1</span> Your situation</legend>
          <div className="planner-profile-options">
            {profileOptions.map(({ id, title, icon: Icon }) => (
              <label className={profile === id ? "is-selected" : ""} key={id}>
                <input
                  checked={profile === id}
                  name="planner-profile"
                  onChange={() => {
                    setProfile(id);
                    setSubmitted(false);
                    setSaved(false);
                  }}
                  type="radio"
                  value={id}
                />
                <Icon aria-hidden />
                <span>{title}</span>
                {profile === id ? <Check aria-hidden /> : null}
              </label>
            ))}
          </div>
        </fieldset>

        <fieldset className="planner-step planner-location-step">
          <legend><span>2</span> Where are you?</legend>
          <label htmlFor="planner-municipality">
            Select your municipality or city
            <span className="planner-select-wrap">
              <MapPin aria-hidden />
              <select
                id="planner-municipality"
                onChange={(event) => {
                  setMunicipalitySlug(event.target.value);
                  setSubmitted(false);
                  setSaved(false);
                }}
                value={municipalitySlug}
              >
                {municipalities.map((item) => <option key={item.slug} value={item.slug}>{item.name}</option>)}
              </select>
            </span>
          </label>
        </fieldset>

        <fieldset className="planner-step planner-goal-step">
          <legend><span>3</span> What do you need?</legend>
          <p>Choose up to 3</p>
          <div className="planner-goal-options">
            {plannerGoals.map((goal) => {
              const Icon = goalIcons[goal.id];
              const selected = goalIds.includes(goal.id);
              const disabled = !selected && goalIds.length >= 3;
              return (
                <label className={selected ? "is-selected" : ""} key={goal.id}>
                  <input
                    checked={selected}
                    disabled={disabled}
                    onChange={() => toggleGoal(goal.id)}
                    type="checkbox"
                    value={goal.id}
                  />
                  <Icon aria-hidden />
                  <span>{goal.title}</span>
                  {selected ? <Check aria-hidden /> : null}
                </label>
              );
            })}
          </div>
        </fieldset>

        <div className="planner-submit">
          <button className="button button-primary" disabled={goalIds.length === 0} onClick={buildRoute} type="button">
            Build my route <ArrowRight aria-hidden />
          </button>
          <p>{goalIds.length}/3 priorities selected</p>
        </div>
      </section>

      <section
        aria-live="polite"
        className={`planner-result ${submitted ? "is-ready" : ""}`}
        ref={resultRef}
        tabIndex={-1}
      >
        <div className="planner-result-heading">
          <div>
            <span>Recommended route</span>
            <h2>{submitted ? `${municipality?.name}: what to do next` : "Build a route to see the next actions"}</h2>
          </div>
          {submitted ? (
            <button onClick={resetRoute} type="button"><RotateCcw aria-hidden /> Reset</button>
          ) : null}
        </div>

        {submitted ? (
          <>
            <ol className="planner-actions">
              {actions.map((action, index) => (
                <li key={action.id}>
                  <span>{index + 1}</span>
                  <div>
                    <small>{action.status}</small>
                    <h3>{action.title}</h3>
                    <p>{action.description}</p>
                    {action.external ? (
                      <TrackedOfficialSourceLink contentId={action.id} href={action.href} rel="noreferrer" target="_blank">Open source <ArrowRight aria-hidden /></TrackedOfficialSourceLink>
                    ) : (
                      <Link href={action.href}>Open route <ArrowRight aria-hidden /></Link>
                    )}
                  </div>
                </li>
              ))}
            </ol>
            <div className="planner-save-row">
              <button className="button button-outline" onClick={saveRoute} type="button">
                {saved ? <Check aria-hidden /> : <Save aria-hidden />}
                {saved ? "Route saved" : "Save this route"}
              </button>
              <p>{storageNotice || "Saved routes stay only in this browser."}</p>
            </div>
          </>
        ) : (
          <div className="planner-result-empty">
            <Landmark aria-hidden />
            <p>YouNew will use only published guides, directory records and responsible sources. Missing coverage is labelled instead of being invented.</p>
          </div>
        )}
      </section>
    </div>
  );
}
