"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Building2, GraduationCap, Plane, RotateCcw, Users } from "lucide-react";
import { track } from "@/lib/analytics/client";
import { localContentRepository, type UserPathProfile } from "@/lib/storage/local-content";

const profiles = [
  {
    id: "tourist",
    label: "Tourist",
    description: "See places, transport and short-stay information relevant to visiting the Netherlands.",
    icon: Plane,
    links: [
      { label: "Browse places", href: "/places" },
      { label: "Find transport", href: "/categories/transport" }
    ]
  },
  {
    id: "student",
    label: "Student",
    description: "See tasks and guidance relevant to studying and settling in the Netherlands.",
    icon: GraduationCap,
    links: [
      { label: "View education guidance", href: "/categories/education" },
      { label: "Find housing guidance", href: "/categories/housing" }
    ]
  },
  {
    id: "expat",
    label: "Expat",
    description: "See starting points for registration, housing, work and local services.",
    icon: Building2,
    links: [
      { label: "Start with registration", href: "/guides/first-registration-in-amsterdam" },
      { label: "View government services", href: "/categories/government" }
    ]
  },
  {
    id: "refugee",
    label: "Refugee",
    description: "See essential services, safety routes and published support information.",
    icon: Users,
    links: [
      { label: "Open emergency help", href: "/emergency" },
      { label: "View government services", href: "/categories/government" }
    ]
  }
] as const satisfies readonly Readonly<{
  id: Extract<UserPathProfile, "tourist" | "student" | "expat" | "refugee">;
  label: string;
  description: string;
  icon: typeof Plane;
  links: readonly Readonly<{ label: string; href: string }>[];
}>[];

export function HomepageProfileSelector() {
  const [selected, setSelected] = useState<UserPathProfile | null>(null);

  useEffect(() => {
    const stored = localContentRepository.profile();
    setSelected(profiles.some((profile) => profile.id === stored) ? stored : null);
  }, []);

  const active = profiles.find((profile) => profile.id === selected);

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
        {active ? (
          <>
            <div><strong>Suggested starting points for {active.label.toLowerCase()}s</strong><span>This preference is saved only in this browser.</span></div>
            <nav aria-label={`${active.label} suggestions`}>
              {active.links.map((link) => <Link href={link.href} key={link.href}>{link.label} <ArrowIcon /></Link>)}
            </nav>
            <button onClick={clear} type="button"><RotateCcw aria-hidden /> Clear choice</button>
          </>
        ) : (
          <p>Choose a situation to show two relevant starting points. All published content stays available.</p>
        )}
      </div>
      <p className="uf-profile-note">These profiles are browsing preferences, not legal or immigration classifications.</p>
    </div>
  );
}

function ArrowIcon() {
  return <span aria-hidden>→</span>;
}
