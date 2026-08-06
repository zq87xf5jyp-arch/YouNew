"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Building2, BriefcaseBusiness, GraduationCap, Home, Plane, RotateCcw, Users } from "lucide-react";
import { track } from "@/lib/analytics/client";
import type { PlannerGoalId, PlannerProfileId } from "@/lib/planner/definitions";
import { localContentRepository, type UserPathProfile } from "@/lib/storage/local-content";

type HomepageMunicipality = Readonly<{ slug: string; name: string }>;

const profiles = [
  {
    id: "tourist",
    plannerProfile: "tourist",
    label: "Tourist",
    description: "Transport, short-stay rules and urgent-help routes for a visit.",
    icon: Plane,
    tasks: [{ id: "transport", label: "Plan transport" }, { id: "urgent-help", label: "Prepare urgent help" }]
  },
  {
    id: "student",
    plannerProfile: "student",
    label: "Student",
    description: "Study, registration, housing and everyday setup.",
    icon: GraduationCap,
    tasks: [{ id: "study", label: "Start studying" }, { id: "housing", label: "Find housing" }]
  },
  {
    id: "expat",
    plannerProfile: "expat",
    label: "Expat",
    description: "Registration, housing, work and responsible local services.",
    icon: Building2,
    tasks: [{ id: "registration", label: "Start registration" }, { id: "work", label: "Start work" }]
  },
  {
    id: "refugee",
    plannerProfile: "refugee",
    label: "Refugee",
    description: "Status-aware starting points, safety and published support.",
    icon: Users,
    tasks: [{ id: "registration", label: "Check registration" }, { id: "urgent-help", label: "Open urgent help" }]
  },
  {
    id: "worker",
    plannerProfile: "worker",
    label: "Worker",
    description: "Employment, tax, banking, insurance and benefits.",
    icon: BriefcaseBusiness,
    tasks: [{ id: "work", label: "Start work" }, { id: "taxes-benefits", label: "Check taxes & benefits" }]
  },
  {
    id: "resident",
    plannerProfile: "resident",
    label: "Resident",
    description: "Healthcare, housing and recurring tasks for daily life.",
    icon: Home,
    tasks: [{ id: "health-insurance", label: "Arrange healthcare" }, { id: "housing", label: "Review housing" }]
  }
] as const satisfies readonly Readonly<{
  id: UserPathProfile;
  plannerProfile: PlannerProfileId;
  label: string;
  description: string;
  icon: typeof Plane;
  tasks: readonly Readonly<{ id: PlannerGoalId; label: string }>[];
}>[];

function plannerHref(profile: PlannerProfileId, task: PlannerGoalId, area: string) {
  const params = new URLSearchParams({ task, profile, area });
  return `/start/?${params.toString()}`;
}

export function HomepageProfileSelector({ municipalities }: { municipalities: readonly HomepageMunicipality[] }) {
  const [selected, setSelected] = useState<UserPathProfile | null>(null);
  const [municipalitySlug, setMunicipalitySlug] = useState("national");

  useEffect(() => {
    const stored = localContentRepository.profile();
    setSelected(profiles.some((profile) => profile.id === stored) ? stored : null);
  }, []);

  const active = profiles.find((profile) => profile.id === selected);
  const municipality = municipalities.find((candidate) => candidate.slug === municipalitySlug) ?? municipalities[0];

  function choose(profile: UserPathProfile) {
    setSelected(profile);
    localContentRepository.setProfile(profile);
    track({ name: "profile_selected" });
  }

  function clear() {
    setSelected(null);
    localContentRepository.clearProfile();
  }

  return (
    <div className="uf-profile-picker">
      <div className="uf-profile-grid">
        {profiles.map(({ id, label, description, icon: Icon }) => (
          <button aria-pressed={selected === id} className={selected === id ? "is-selected" : ""} data-home-profile={id} key={id} onClick={() => choose(id)} type="button">
            <Icon aria-hidden />
            <span><strong>{label}</strong>{description}</span>
          </button>
        ))}
      </div>
      <div className="uf-profile-result" aria-live="polite" data-home-profile-result>
        <div data-home-profile-copy hidden={!active}>
          <strong data-home-profile-title>{active ? `Starting points for ${active.label.toLowerCase()}s` : "Situation starting points"}</strong>
          <span>The situation preference is saved only in this browser. National results always remain available.</span>
          <label className="uf-profile-location" htmlFor="homepage-municipality">
            Add local context
            <select data-home-municipality id="homepage-municipality" value={municipalitySlug} onChange={(event) => setMunicipalitySlug(event.target.value)}>
              {municipalities.map((candidate) => <option key={candidate.slug} value={candidate.slug}>{candidate.name}</option>)}
            </select>
          </label>
        </div>
        <nav aria-label={active ? `${active.label} suggestions${municipality ? ` for ${municipality.name}` : ""}` : "Situation suggestions"} data-home-profile-links hidden={!active}>
          {active?.tasks.map((task) => <Link href={plannerHref(active.plannerProfile, task.id, municipality?.slug ?? "national")} key={task.id}>{task.label} <ArrowIcon /></Link>)}
        </nav>
        <button data-home-profile-clear hidden={!active} onClick={clear} type="button"><RotateCcw aria-hidden /> Clear choice</button>
        <p data-home-profile-empty hidden={Boolean(active)}>Choose your situation to see relevant starting tasks. This does not hide the rest of YouNew.</p>
      </div>
      <p className="uf-profile-note">These are browsing preferences, not legal, medical or immigration classifications. Exact requirements remain on the responsible official source.</p>
    </div>
  );
}

function ArrowIcon() {
  return <span aria-hidden>→</span>;
}
