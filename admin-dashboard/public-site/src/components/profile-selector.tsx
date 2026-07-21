"use client";

import { useEffect, useState } from "react";
import { BriefcaseBusiness, Building2, GraduationCap, Home, Plane, Users } from "lucide-react";
import { track } from "@/lib/analytics/client";
import { localContentRepository, type UserPathProfile } from "@/lib/storage/local-content";

const profiles: Array<{
  id: UserPathProfile;
  label: string;
  description: string;
  links: Array<{ label: string; href: string }>;
  icon: typeof Plane;
}> = [
  { id: "tourist", label: "Tourist", description: "Places, culture and moving around Amsterdam.", links: [{ label: "Places", href: "/places" }, { label: "Transport", href: "/categories/transport" }], icon: Plane },
  { id: "student", label: "Student", description: "Study, housing and everyday local services.", links: [{ label: "Education", href: "/categories/education" }, { label: "Housing guides", href: "/categories/housing" }], icon: GraduationCap },
  { id: "expat", label: "Expat", description: "Municipal services, housing and healthcare.", links: [{ label: "Government", href: "/categories/government" }, { label: "Healthcare", href: "/categories/healthcare" }], icon: Building2 },
  { id: "refugee", label: "Refugee", description: "Essential services, safe official sources and practical support.", links: [{ label: "Government", href: "/categories/government" }, { label: "Emergency help", href: "/emergency" }], icon: Users },
  { id: "worker", label: "Worker", description: "A released starting point for work-related administration and daily travel.", links: [{ label: "Starting work journey", href: "/journeys" }, { label: "Transport", href: "/categories/transport" }], icon: BriefcaseBusiness },
  { id: "resident", label: "Resident", description: "Municipal tasks, healthcare, housing and local services.", links: [{ label: "Government", href: "/categories/government" }, { label: "Cities", href: "/cities" }], icon: Home }
];

export function ProfileSelector() {
  const [selected, setSelected] = useState<UserPathProfile | null>(null);

  useEffect(() => {
    const requestedProfile = new URLSearchParams(window.location.search).get("profile");
    const requested = profiles.find((profile) => profile.id === requestedProfile)?.id ?? null;
    if (requested) {
      setSelected(requested);
      localContentRepository.setProfile(requested);
      return;
    }
    setSelected(localContentRepository.profile());
  }, []);
  const active = profiles.find((profile) => profile.id === selected);

  function choose(profile: UserPathProfile) {
    setSelected(profile);
    localContentRepository.setProfile(profile);
    track({ name: "profile_selected", profile });
  }

  return (
    <section className="profile-picker" aria-labelledby="profile-picker-title">
      <div className="profile-picker-heading">
        <h2 id="profile-picker-title">Choose a starting point</h2>
        <p>This preference stays on this device. It does not create an account or hide other content.</p>
      </div>
      <div className="profile-picker-grid">
        {profiles.map(({ id, label, description, icon: Icon }) => (
          <button type="button" className={selected === id ? "is-selected" : ""} aria-pressed={selected === id} onClick={() => choose(id)} key={id}>
            <Icon aria-hidden /><span><strong>{label}</strong>{description}</span>
          </button>
        ))}
      </div>
      {active ? (
        <div className="profile-recommendations" aria-live="polite">
          <strong>Useful now for {active.label.toLowerCase()}s</strong>
          {active.links.map((link) => <a href={link.href} key={link.href}>{link.label}</a>)}
        </div>
      ) : null}
    </section>
  );
}
