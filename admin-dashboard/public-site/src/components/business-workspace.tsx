"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import {
  ArrowRight,
  BadgeCheck,
  BarChart3,
  BriefcaseBusiness,
  Building2,
  Check,
  FileText,
  LayoutDashboard,
  LockKeyhole,
  MapPin,
  Megaphone,
  MessageSquareMore,
  RefreshCcw,
  ShieldCheck,
  UserRound
} from "lucide-react";
import type { BusinessUserProfileId, RequestedPlacementId } from "@/lib/business/types";

const placementOptions: ReadonlyArray<{
  id: Extract<RequestedPlacementId, "verified-organization-profile" | "sponsored-city-placement" | "featured-local-partner">;
  title: string;
  description: string;
  icon: typeof BadgeCheck;
}> = [
  {
    id: "verified-organization-profile",
    title: "Verified organization profile",
    description: "Identity and claims are checked before publication.",
    icon: BadgeCheck
  },
  {
    id: "sponsored-city-placement",
    title: "Sponsored city placement",
    description: "A labelled placement beside relevant published city context.",
    icon: MapPin
  },
  {
    id: "featured-local-partner",
    title: "Featured local partner",
    description: "A reviewed local presentation in an agreed context.",
    icon: Building2
  }
];

const audienceOptions: ReadonlyArray<{ id: BusinessUserProfileId; label: string }> = [
  { id: "student", label: "Students" },
  { id: "expat", label: "Expats" },
  { id: "resident", label: "New residents" },
  { id: "tourist", label: "Tourists" },
  { id: "worker", label: "Workers" },
  { id: "refugee", label: "Refugees" }
];

const locationOptions = ["Netherlands", "Province", "Municipality", "City"] as const;
type LocationScope = (typeof locationOptions)[number];

const workspaceNavigation = [
  { href: "#workspace-overview", label: "Overview", icon: LayoutDashboard },
  { href: "#workspace-profile", label: "Business profile", icon: UserRound },
  { href: "#workspace-placements", label: "Placements", icon: MapPin },
  { href: "#workspace-campaign", label: "Campaign draft", icon: Megaphone },
  { href: "#workspace-leads", label: "Leads", icon: MessageSquareMore },
  { href: "#workspace-reporting", label: "Reporting", icon: BarChart3 },
  { href: "#workspace-verification", label: "Verification", icon: ShieldCheck }
] as const;

export function BusinessWorkspace({
  catalogFacts
}: {
  catalogFacts: Readonly<{
    formats: number;
    surfaces: number;
    municipalities: number;
    provinces: number;
  }>;
}) {
  const [placementId, setPlacementId] = useState<(typeof placementOptions)[number]["id"]>("verified-organization-profile");
  const [audiences, setAudiences] = useState<BusinessUserProfileId[]>(["student", "expat", "resident"]);
  const [locationScope, setLocationScope] = useState<LocationScope>("Netherlands");
  const selectedPlacement = placementOptions.find((placement) => placement.id === placementId) ?? placementOptions[0];
  const SelectedPlacementIcon = selectedPlacement.icon;

  const inquiryHref = useMemo(() => {
    const audienceValue = audiences.length ? audiences.join("-") : "not-selected";
    const content = `${placementId}:${audienceValue}:${locationScope.toLowerCase()}`;
    return `/business/apply/?utm_source=business-workspace&utm_medium=owned&utm_campaign=workspace-draft&utm_content=${encodeURIComponent(content)}`;
  }, [audiences, locationScope, placementId]);

  const toggleAudience = (id: BusinessUserProfileId) => {
    setAudiences((current) => current.includes(id)
      ? current.filter((audience) => audience !== id)
      : [...current, id]);
  };

  const resetDraft = () => {
    setPlacementId("verified-organization-profile");
    setAudiences(["student", "expat", "resident"]);
    setLocationScope("Netherlands");
  };

  return (
    <section className="business-workspace section-shell" aria-labelledby="business-workspace-title" data-business-workspace>
      <aside className="workspace-sidebar" aria-label="Business workspace navigation">
        <div className="workspace-sidebar-brand">
          <span aria-hidden>YN</span>
          <div><strong>YouNew Business</strong><small>Local workspace preview</small></div>
        </div>
        <nav>
          {workspaceNavigation.map((item, index) => {
            const Icon = item.icon;
            return (
              <a className={index === 0 ? "is-active" : undefined} href={item.href} key={item.href}>
                <Icon aria-hidden />
                {item.label}
              </a>
            );
          })}
        </nav>
        <dl className="workspace-catalog-facts" aria-label="Current product coverage, not audience size">
          <div><dt>{catalogFacts.formats}</dt><dd>formats</dd></div>
          <div><dt>{catalogFacts.surfaces}</dt><dd>surfaces</dd></div>
          <div><dt>0</dt><dd>live campaigns</dd></div>
          <div><dt>{catalogFacts.municipalities}</dt><dd>municipalities</dd></div>
          <div><dt>{catalogFacts.provinces}</dt><dd>provinces</dd></div>
        </dl>
      </aside>

      <div className="workspace-content">
        <nav className="workspace-mobile-tabs" aria-label="Workspace sections">
          <a href="#workspace-overview"><LayoutDashboard aria-hidden />Overview</a>
          <a href="#workspace-placements"><MapPin aria-hidden />Placements</a>
          <a href="#workspace-campaign"><Megaphone aria-hidden />Campaign</a>
        </nav>

        <header className="workspace-heading" id="workspace-overview">
          <div>
            <p className="workspace-eyebrow"><BriefcaseBusiness aria-hidden /> Business advertising workspace</p>
            <h1 id="business-workspace-title">Build your business presence with YouNew<span>.</span></h1>
            <p>Create a verified profile, choose transparent placements and submit every public change for review.</p>
            <span className="workspace-status-pill"><span aria-hidden /> Local workspace preview · not submitted</span>
          </div>
          <button className="workspace-reset" type="button" onClick={resetDraft}><RefreshCcw aria-hidden /> Reset draft</button>
        </header>

        <section className="workspace-status-grid" id="workspace-profile" aria-label="Draft status">
          <article><FileText aria-hidden /><span><small>Profile</small><strong>Draft</strong></span></article>
          <article id="workspace-verification"><ShieldCheck aria-hidden /><span><small>Verification</small><strong>Not submitted</strong></span></article>
          <article><Megaphone aria-hidden /><span><small>Campaigns</small><strong>0 live</strong></span></article>
        </section>

        <div className="workspace-editor">
          <div className="workspace-draft">
            <fieldset className="workspace-panel workspace-placement-options" id="workspace-placements">
              <legend>Choose your placement</legend>
              <p>Every option is reviewed before it can appear publicly.</p>
              {placementOptions.map((placement) => {
                const Icon = placement.icon;
                const selected = placement.id === placementId;
                return (
                  <label className={selected ? "is-selected" : undefined} key={placement.id}>
                    <input
                      type="radio"
                      name="workspacePlacement"
                      value={placement.id}
                      checked={selected}
                      onChange={() => setPlacementId(placement.id)}
                    />
                    <Icon aria-hidden />
                    <span><strong>{placement.title}</strong><small>{placement.description}</small></span>
                    <span className="workspace-choice-indicator" aria-hidden>{selected ? <Check /> : null}</span>
                  </label>
                );
              })}
            </fieldset>

            <section className="workspace-panel workspace-targeting" id="workspace-campaign" aria-labelledby="workspace-campaign-title">
              <div className="workspace-panel-heading">
                <div><h2 id="workspace-campaign-title">Campaign draft</h2><p>Selections stay in this page until you continue to the secure inquiry.</p></div>
                <span>Not saved</span>
              </div>
              <fieldset>
                <legend>Audience</legend>
                <div className="workspace-chip-grid">
                  {audienceOptions.map((audience) => {
                    const selected = audiences.includes(audience.id);
                    return (
                      <label className={selected ? "is-selected" : undefined} key={audience.id}>
                        <input type="checkbox" checked={selected} onChange={() => toggleAudience(audience.id)} />
                        {audience.label}
                        {selected ? <Check aria-hidden /> : null}
                      </label>
                    );
                  })}
                </div>
              </fieldset>
              <fieldset>
                <legend>Location</legend>
                <div className="workspace-segmented-control">
                  {locationOptions.map((location) => (
                    <label className={location === locationScope ? "is-selected" : undefined} key={location}>
                      <input
                        type="radio"
                        name="workspaceLocation"
                        value={location}
                        checked={location === locationScope}
                        onChange={() => setLocationScope(location)}
                      />
                      {location}
                    </label>
                  ))}
                </div>
              </fieldset>
              <div className="workspace-draft-actions">
                <Link className="button button-primary" href={inquiryHref}>Continue to secure inquiry <ArrowRight aria-hidden /></Link>
                <Link href="/business/advertise">Review placement rules</Link>
              </div>
            </section>
          </div>

          <aside className="workspace-preview-column" aria-label="Placement preview">
            <section className="workspace-panel workspace-preview">
              <span className="workspace-preview-label">Sponsored preview · not live</span>
              <div className="workspace-preview-card">
                <div className="workspace-preview-title">
                  <SelectedPlacementIcon aria-hidden />
                  <span><strong>Your reviewed business</strong><small>Illustrative preview only</small></span>
                  <BadgeCheck aria-label="Verification shown only as an interface preview" />
                </div>
                <div className="workspace-preview-lines" aria-hidden><span /><span /></div>
                <div className="workspace-preview-meta">
                  <span><UserRound aria-hidden />{audiences.length ? `${audiences.length} audiences` : "No audience selected"}</span>
                  <span><MapPin aria-hidden />{locationScope}</span>
                </div>
                <div className="workspace-preview-map" aria-hidden />
              </div>
              <p><strong>{selectedPlacement.title}</strong> · public status remains inactive until review and written approval.</p>
            </section>
          </aside>
        </div>

        <div className="workspace-empty-states">
          <article id="workspace-reporting"><BarChart3 aria-hidden /><div><h2>Reporting is available after real approved interactions.</h2><p>No illustrative impressions, clicks or conversion rates are shown.</p></div></article>
          <article id="workspace-leads"><LockKeyhole aria-hidden /><div><h2>Leads require a secure verified account.</h2><p>The public preview never exposes messages or contact details.</p></div></article>
        </div>

        <footer className="workspace-integrity-note">
          <ShieldCheck aria-hidden />
          <p><strong>Editorial independence stays intact.</strong> Payment cannot change organic ranking, official-source cards, map markers or emergency guidance.</p>
          <Link href="/business/media-kit">Media kit <ArrowRight aria-hidden /></Link>
        </footer>
      </div>
    </section>
  );
}
