"use client";

import Link from "next/link";
import {
  ArrowLeft,
  ArrowRight,
  BriefcaseBusiness,
  Building2,
  ChevronDown,
  Check,
  Copy,
  GraduationCap,
  HeartPulse,
  Home,
  Landmark,
  MapPin,
  Plane,
  RotateCcw,
  Save,
  Search,
  ShieldCheck,
  Users
} from "lucide-react";
import { type KeyboardEvent, useEffect, useId, useMemo, useRef, useState } from "react";
import { track } from "@/lib/analytics/client";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import {
  buildPlannerActions,
  plannerGoalIds,
  plannerGoals,
  plannerProfileIds,
  type PlannerGoalId,
  type PlannerGuideRoute,
  type PlannerMunicipality,
  type PlannerProfileId
} from "@/lib/planner/definitions";
import { localContentRepository } from "@/lib/storage/local-content";

const profileOptions = [
  { id: "new-resident", title: "New resident", icon: Users },
  { id: "student", title: "Student", icon: GraduationCap },
  { id: "expat", title: "Expat", icon: Building2 },
  { id: "worker", title: "Worker", icon: BriefcaseBusiness },
  { id: "refugee", title: "Refugee", icon: ShieldCheck },
  { id: "tourist", title: "Tourist", icon: Plane },
  { id: "resident", title: "Resident", icon: Home },
  { id: "prefer-not-to-say", title: "Prefer not to say", icon: Users }
] as const satisfies readonly Readonly<{
  id: PlannerProfileId;
  title: string;
  icon: typeof Users;
}>[];

const goalIcons: Record<PlannerGoalId, typeof Landmark> = {
  registration: Landmark,
  "health-insurance": HeartPulse,
  housing: Home,
  study: GraduationCap,
  work: BriefcaseBusiness,
  "taxes-benefits": Building2,
  transport: MapPin,
  "urgent-help": ShieldCheck,
  other: Search
};

type PlannerStep = 1 | 2 | 3 | 4;

function normalizeAreaSearch(value: string) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("en-NL").trim();
}

function MunicipalityCombobox({
  municipalities,
  value,
  onChange
}: {
  municipalities: readonly PlannerMunicipality[];
  value: string;
  onChange: (slug: string) => void;
}) {
  const selectedMunicipality = municipalities.find((municipality) => municipality.slug === value) ?? municipalities[0];
  const [query, setQuery] = useState(selectedMunicipality?.name ?? "");
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(-1);
  const rootRef = useRef<HTMLSpanElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const listId = useId();

  const filteredMunicipalities = useMemo(() => {
    const normalizedQuery = normalizeAreaSearch(query);
    if (!normalizedQuery) return municipalities;
    return municipalities.filter((municipality) => normalizeAreaSearch(municipality.name).includes(normalizedQuery));
  }, [municipalities, query]);

  useEffect(() => {
    setQuery(selectedMunicipality?.name ?? "");
  }, [selectedMunicipality?.name]);

  useEffect(() => {
    function closeOnOutsidePointer(event: PointerEvent) {
      if (rootRef.current?.contains(event.target as Node)) return;
      setOpen(false);
      setActiveIndex(-1);
      setQuery(selectedMunicipality?.name ?? "");
    }
    document.addEventListener("pointerdown", closeOnOutsidePointer);
    return () => document.removeEventListener("pointerdown", closeOnOutsidePointer);
  }, [selectedMunicipality?.name]);

  function chooseMunicipality(municipality: PlannerMunicipality) {
    onChange(municipality.slug);
    setQuery(municipality.name);
    setOpen(false);
    setActiveIndex(-1);
    window.requestAnimationFrame(() => inputRef.current?.focus());
  }

  function onKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Escape") {
      event.preventDefault();
      setOpen(false);
      setActiveIndex(-1);
      setQuery(selectedMunicipality?.name ?? "");
      return;
    }

    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      setOpen(true);
      setActiveIndex((current) => {
        if (filteredMunicipalities.length === 0) return -1;
        if (event.key === "ArrowDown") return current >= filteredMunicipalities.length - 1 ? 0 : current + 1;
        return current <= 0 ? filteredMunicipalities.length - 1 : current - 1;
      });
      return;
    }

    if (event.key === "Home" && open) {
      event.preventDefault();
      setActiveIndex(filteredMunicipalities.length ? 0 : -1);
      return;
    }

    if (event.key === "End" && open) {
      event.preventDefault();
      setActiveIndex(filteredMunicipalities.length - 1);
      return;
    }

    if (event.key === "Enter" && open && activeIndex >= 0) {
      event.preventDefault();
      const municipality = filteredMunicipalities[activeIndex];
      if (municipality) chooseMunicipality(municipality);
    }
  }

  const activeMunicipality = activeIndex >= 0 ? filteredMunicipalities[activeIndex] : undefined;

  useEffect(() => {
    if (!open || !activeMunicipality) return;
    document.getElementById(`${listId}-${activeMunicipality.slug}`)?.scrollIntoView({ block: "nearest" });
  }, [activeMunicipality, listId, open]);

  return (
    <span
      className="planner-combobox"
      onBlur={(event) => {
        if (event.currentTarget.contains(event.relatedTarget as Node | null)) return;
        setOpen(false);
        setActiveIndex(-1);
        setQuery(selectedMunicipality?.name ?? "");
      }}
      ref={rootRef}
    >
      <span className="planner-combobox-control">
        <MapPin aria-hidden />
        <input
          aria-activedescendant={activeMunicipality ? `${listId}-${activeMunicipality.slug}` : undefined}
          aria-autocomplete="list"
          aria-controls={listId}
          aria-expanded={open}
          aria-haspopup="listbox"
          autoComplete="off"
          id="planner-municipality"
          onChange={(event) => {
            setQuery(event.target.value);
            setOpen(true);
            setActiveIndex(0);
          }}
          onClick={() => {
            setOpen(true);
            setActiveIndex(-1);
          }}
          onFocus={(event) => {
            setOpen(true);
            event.currentTarget.select();
          }}
          onKeyDown={onKeyDown}
          ref={inputRef}
          role="combobox"
          spellCheck={false}
          value={query}
        />
        <button
          aria-label={open ? "Hide area options" : "Show area options"}
          onClick={() => {
            if (open) {
              setOpen(false);
              setActiveIndex(-1);
              setQuery(selectedMunicipality?.name ?? "");
              return;
            }
            setOpen(true);
            setActiveIndex(-1);
            window.requestAnimationFrame(() => inputRef.current?.focus());
          }}
          type="button"
        >
          <ChevronDown aria-hidden />
        </button>
      </span>
      {open ? (
        <ul className="planner-combobox-list" id={listId} role="listbox">
          {filteredMunicipalities.length ? filteredMunicipalities.map((municipality, index) => (
            <li
              aria-selected={municipality.slug === value}
              className={index === activeIndex ? "is-active" : ""}
              id={`${listId}-${municipality.slug}`}
              key={municipality.slug}
              onPointerDown={(event) => {
                event.preventDefault();
                chooseMunicipality(municipality);
              }}
              role="option"
            >
              <span>{municipality.name}</span>
              {municipality.slug === value ? <Check aria-hidden /> : null}
            </li>
          )) : (
            <li aria-disabled="true" aria-selected={false} className="is-empty" role="option">No matching area</li>
          )}
        </ul>
      ) : null}
    </span>
  );
}

export function NextStepPlanner({
  municipalities,
  guides
}: {
  municipalities: readonly PlannerMunicipality[];
  guides: readonly PlannerGuideRoute[];
}) {
  const defaultMunicipality = municipalities.find((municipality) => municipality.slug === "national") ?? municipalities[0];
  const [step, setStep] = useState<PlannerStep>(1);
  const [profile, setProfile] = useState<PlannerProfileId>("prefer-not-to-say");
  const [municipalitySlug, setMunicipalitySlug] = useState(defaultMunicipality?.slug ?? "national");
  const [goalId, setGoalId] = useState<PlannerGoalId | null>(null);
  const [saved, setSaved] = useState(false);
  const [notice, setNotice] = useState("");
  const resultRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const directGoal = params.get("task");
    const directProfile = params.get("profile");
    const directArea = params.get("area");
    const validGoal = plannerGoalIds.find((id) => id === directGoal);
    const validProfile = plannerProfileIds.find((id) => id === directProfile);
    const validArea = municipalities.find((municipality) => municipality.slug === directArea);

    if (validGoal && validProfile && validArea) {
      setGoalId(validGoal);
      setProfile(validProfile);
      setMunicipalitySlug(validArea.slug);
      setStep(4);
      return;
    }

    const stored = localContentRepository.plannerRoute();
    if (!stored) return;
    const storedArea = municipalities.find((municipality) => municipality.slug === stored.municipalitySlug);
    if (!storedArea || stored.goalIds.length !== 1) return;
    setGoalId(stored.goalIds[0]);
    setProfile(stored.profile);
    setMunicipalitySlug(storedArea.slug);
    setSaved(true);
    setNotice("A saved route is ready to review or change.");
  }, [municipalities]);

  const municipality = useMemo(
    () => municipalities.find((candidate) => candidate.slug === municipalitySlug) ?? defaultMunicipality,
    [defaultMunicipality, municipalities, municipalitySlug]
  );

  const selectedGoal = plannerGoals.find((goal) => goal.id === goalId);
  const selectedProfile = profileOptions.find((option) => option.id === profile);
  const actions = useMemo(
    () => municipality && goalId ? buildPlannerActions({ profile, municipality, goalIds: [goalId], guides }) : [],
    [goalId, guides, municipality, profile]
  );

  function goBack() {
    setNotice("");
    setStep((current) => Math.max(1, current - 1) as PlannerStep);
  }

  function resetRoute() {
    setStep(1);
    setProfile("prefer-not-to-say");
    setMunicipalitySlug(defaultMunicipality?.slug ?? "national");
    setGoalId(null);
    setSaved(false);
    setNotice("");
    localContentRepository.clearPlannerRoute();
    window.history.replaceState(null, "", window.location.pathname);
  }

  function buildRoute() {
    if (!goalId || !municipality) return;
    const params = new URLSearchParams({ task: goalId, profile, area: municipality.slug });
    window.history.replaceState(null, "", `${window.location.pathname}?${params.toString()}`);
    setStep(4);
    setSaved(false);
    setNotice("");
    window.requestAnimationFrame(() => resultRef.current?.focus());
  }

  function saveRoute() {
    if (!goalId || !municipality) return;
    const stored = localContentRepository.setPlannerRoute({
      profile,
      municipalitySlug: municipality.slug,
      goalIds: [goalId]
    });
    setSaved(stored);
    setNotice(stored ? "Saved on this device/browser." : "This browser did not allow YouNew to save the route.");
    if (stored) track({ name: "item_saved", contentId: "planner_route" });
  }

  async function copyRoute() {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setNotice("Direct link copied.");
    } catch {
      setNotice("The direct link is in the address bar and can be copied there.");
    }
  }

  return (
    <div className="next-step-planner is-guided">
      <section className="planner-builder" aria-label="Find a practical route">
        <div className="planner-progress" aria-label={`Step ${step} of 4`}>
          {[1, 2, 3, 4].map((number) => <span className={number <= step ? "is-current" : ""} key={number}><i aria-hidden />{number === 4 ? "Result" : `Step ${number}`}</span>)}
        </div>

        {step === 1 ? (
          <fieldset className="planner-step planner-goal-step">
            <legend><span>1</span> What do you need help with?</legend>
            <p>Choose one task. You can change it later.</p>
            <div className="planner-goal-options">
              {plannerGoals.map((goal) => {
                const Icon = goalIcons[goal.id];
                return (
                  <label className={goalId === goal.id ? "is-selected" : ""} key={goal.id}>
                    <input checked={goalId === goal.id} name="planner-goal" onChange={() => { setGoalId(goal.id); setSaved(false); }} type="radio" value={goal.id} />
                    <Icon aria-hidden /><span>{goal.title}</span>{goalId === goal.id ? <Check aria-hidden /> : null}
                  </label>
                );
              })}
            </div>
            <div className="planner-navigation"><button className="button button-primary" disabled={!goalId} onClick={() => setStep(2)} type="button">Next: your situation <ArrowRight aria-hidden /></button></div>
          </fieldset>
        ) : null}

        {step === 2 ? (
          <fieldset className="planner-step planner-profile-step">
            <legend><span>2</span> Which situation fits best?</legend>
            <p>This is a browsing preference, not a legal classification.</p>
            <div className="planner-profile-options">
              {profileOptions.map(({ id, title, icon: Icon }) => (
                <label className={profile === id ? "is-selected" : ""} key={id}>
                  <input checked={profile === id} name="planner-profile" onChange={() => { setProfile(id); setSaved(false); }} type="radio" value={id} />
                  <Icon aria-hidden /><span>{title}</span>{profile === id ? <Check aria-hidden /> : null}
                </label>
              ))}
            </div>
            <div className="planner-navigation"><button className="button button-ghost" onClick={goBack} type="button"><ArrowLeft aria-hidden /> Back</button><button className="button button-primary" onClick={() => setStep(3)} type="button">Next: area <ArrowRight aria-hidden /></button></div>
          </fieldset>
        ) : null}

        {step === 3 ? (
          <fieldset className="planner-step planner-location-step">
            <legend><span>3</span> Which area should we use?</legend>
            <p>Choose national guidance or a municipality. YouNew does not ask for precise location.</p>
            <div className="planner-area-field">
              <label htmlFor="planner-municipality">Area</label>
              <MunicipalityCombobox
                municipalities={municipalities}
                onChange={(slug) => {
                  setMunicipalitySlug(slug);
                  setSaved(false);
                }}
                value={municipalitySlug}
              />
            </div>
            <div className="planner-navigation"><button className="button button-ghost" onClick={goBack} type="button"><ArrowLeft aria-hidden /> Back</button><button className="button button-primary" onClick={buildRoute} type="button">Show my route <ArrowRight aria-hidden /></button></div>
          </fieldset>
        ) : null}

        {step === 4 ? (
          <div className="planner-selection-summary">
            <span><strong>Task</strong>{selectedGoal?.title}</span>
            <span><strong>Situation</strong>{selectedProfile?.title}</span>
            <span><strong>Area</strong>{municipality?.name}</span>
            <div className="planner-navigation"><button className="button button-ghost" onClick={goBack} type="button"><ArrowLeft aria-hidden /> Back</button><button className="button button-outline" onClick={resetRoute} type="button"><RotateCcw aria-hidden /> Reset</button></div>
          </div>
        ) : null}
      </section>

      <section aria-live="polite" className={`planner-result ${step === 4 ? "is-ready" : ""}`} ref={resultRef} tabIndex={-1}>
        <div className="planner-result-heading"><div><span>Recommended route</span><h2>{step === 4 ? `${municipality?.name}: what to do next` : "Complete the three steps to see a route"}</h2></div></div>
        {step === 4 ? (
          <>
            {actions.length > 0 ? (
              <ol className="planner-actions">
                {actions.map((action, index) => (
                  <li key={action.id}><span>{index + 1}</span><div><small>{action.status}</small><h3>{action.title}</h3><p>{action.description}</p>{action.external ? <TrackedOfficialSourceLink contentId={action.id} href={action.href} rel="noreferrer" target="_blank">Open source <ArrowRight aria-hidden /></TrackedOfficialSourceLink> : <Link href={action.href}>Open route <ArrowRight aria-hidden /></Link>}</div></li>
                ))}
              </ol>
            ) : (
              <div className="planner-result-empty"><Landmark aria-hidden /><p>No complete YouNew route is published for this choice yet. Search the published catalogue or check the responsible institution.</p><Link href="/search">Search published guidance <ArrowRight aria-hidden /></Link></div>
            )}
            <div className="planner-save-row"><button className="button button-outline" onClick={saveRoute} type="button">{saved ? <Check aria-hidden /> : <Save aria-hidden />}{saved ? "Route saved" : "Save this route"}</button><button className="button button-ghost" onClick={copyRoute} type="button"><Copy aria-hidden /> Copy direct link</button><p role="status">{notice || "Saving is optional and stays in this browser."}</p></div>
          </>
        ) : (
          <div className="planner-result-empty"><Landmark aria-hidden /><p>YouNew uses published guides, directory pages and responsible sources. Missing coverage is labelled instead of being invented.</p></div>
        )}
      </section>
    </div>
  );
}
