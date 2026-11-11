"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import { ShieldCheck } from "lucide-react";
import siteConfig from "@/config/site-config.json";
import {
  createHostingerAnalyticsProvider,
  randomUUIDv4,
  type AnalyticsProvider
} from "@/lib/analytics/client";

type ConsentChoice = "accepted" | "declined";

const consentStorageKey = siteConfig.analytics.guideMetricsEnabled ? "younew.analytics-consent.2026-11-11-guides" : "younew.analytics-consent.2026-07-28";
const appInstanceStorageKey = "younew.analytics-app-instance";
const sessionStorageKey = "younew.analytics-session";

function readConsent(): ConsentChoice | null {
  try {
    const value = window.localStorage.getItem(consentStorageKey);
    return value === "accepted" || value === "declined" ? value : null;
  } catch {
    return null;
  }
}

function saveConsent(choice: ConsentChoice) {
  try {
    window.localStorage.setItem(consentStorageKey, choice);
  } catch {
    // The current page can still honor the choice when storage is unavailable.
  }
}

function browserPrivacySignalEnabled() {
  const navigatorWithPrivacy = navigator as Navigator & {
    globalPrivacyControl?: boolean;
    doNotTrack?: string | null;
  };
  const windowWithPrivacy = window as Window & { doNotTrack?: string | null };
  return navigatorWithPrivacy.globalPrivacyControl === true
    || navigatorWithPrivacy.doNotTrack === "1"
    || windowWithPrivacy.doNotTrack === "1";
}

function sessionIdentifier(key: string) {
  try {
    const existing = window.sessionStorage.getItem(key);
    if (existing) return existing;
    const created = randomUUIDv4();
    window.sessionStorage.setItem(key, created);
    return created;
  } catch {
    return randomUUIDv4();
  }
}

function clearAnalyticsSession() {
  try {
    window.sessionStorage.removeItem(appInstanceStorageKey);
    window.sessionStorage.removeItem(sessionStorageKey);
  } catch {
    // No persisted analytics identifier exists when session storage is blocked.
  }
}

export function AnalyticsConsent() {
  const pathname = usePathname();
  const nl = pathname.startsWith("/nl") || /^\/review\/guides\/[^/]+\/nl\/?$/.test(pathname);
  const providerRef = useRef<AnalyticsProvider | undefined>(undefined);
  const consentGrantPendingRef = useRef(false);
  const [choice, setChoice] = useState<ConsentChoice | null>(null);
  const [isReady, setIsReady] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);

  useEffect(() => {
    const storedChoice = readConsent();
    setChoice(storedChoice ?? (browserPrivacySignalEnabled() ? "declined" : null));
    setSettingsOpen(storedChoice === null && !browserPrivacySignalEnabled());
    setIsReady(true);
  }, []);

  useEffect(() => {
    if (!isReady || choice !== "accepted" || !siteConfig.analytics.enabled || pathname.startsWith("/review/")) return;

    let provider: AnalyticsProvider;
    try {
      provider = createHostingerAnalyticsProvider({
        configuration: {...siteConfig.analytics, consentVersion: siteConfig.analytics.guideMetricsEnabled ? "2026-11-11-guides" : siteConfig.analytics.consentVersion},
        appInstanceId: sessionIdentifier(appInstanceStorageKey),
        sessionId: sessionIdentifier(sessionStorageKey)
      });
    } catch {
      return;
    }
    providerRef.current = provider;
    window.__YOUNEW_ANALYTICS__ = provider;
    window.dispatchEvent(new Event("younew:analytics-ready"));
    if (consentGrantPendingRef.current) {
      provider.track({ name: "analytics_consent_granted" });
      consentGrantPendingRef.current = false;
    }
    provider.track({ name: "page_view", path: pathname });
    void provider.flush?.();

    const flush = () => {
      void provider.flush?.();
    };
    window.addEventListener("pagehide", flush);
    return () => {
      window.removeEventListener("pagehide", flush);
      if (window.__YOUNEW_ANALYTICS__ === provider) {
        delete window.__YOUNEW_ANALYTICS__;
      }
      void provider.flush?.().finally(() => provider.dispose?.());
      providerRef.current = undefined;
    };
  }, [choice, isReady, pathname]);

  if (!isReady) return null;

  const accept = () => {
    consentGrantPendingRef.current = true;
    saveConsent("accepted");
    setChoice("accepted");
    setSettingsOpen(false);
  };

  const decline = () => {
    const provider = providerRef.current;
    if (window.__YOUNEW_ANALYTICS__ === provider) {
      delete window.__YOUNEW_ANALYTICS__;
    }
    provider?.dispose?.();
    providerRef.current = undefined;
    saveConsent("declined");
    clearAnalyticsSession();
    window.dispatchEvent(new Event("younew:analytics-declined"));
    try {
      localStorage.removeItem("younew.guide-last-visit.2026-11-11");
      for (const key of Object.keys(sessionStorage)) if (key.startsWith("younew.guide-return.") || key.startsWith("younew.guide-active.")) sessionStorage.removeItem(key);
    } catch { /* Storage may be unavailable. */ }
    setChoice("declined");
    setSettingsOpen(false);
  };

  return (
    <>
      {!settingsOpen ? (
        <button
          type="button"
          className="analytics-settings-trigger"
          onClick={() => setSettingsOpen(true)}
          aria-label={nl ? "Open privacykeuze voor analytics" : "Open analytics privacy choices"}
        >
          <ShieldCheck aria-hidden />
          <span className="visually-hidden">{nl ? "Privacykeuze" : "Privacy choices"}</span>
        </button>
      ) : null}
      {settingsOpen ? (
        <section
          className={choice === null ? "analytics-consent analytics-consent-inline" : "analytics-consent"}
          role="region"
          aria-labelledby="analytics-consent-title"
          aria-live="polite"
        >
          <div>
            <p className="analytics-consent-eyebrow">{nl ? "Jouw privacykeuze" : "Your privacy choice"}</p>
            <h2 id="analytics-consent-title">{nl ? "Wil je YouNew helpen verbeteren?" : "Help improve YouNew?"}</h2>
            <p>
              {nl
                ? "Met jouw toestemming telt YouNew paginabezoeken en een beperkt aantal productacties. We versturen geen zoektekst, profielgegevens, precieze locatie, advertentie-ID's of cross-site identifiers. De identifier blijft alleen in dit browsertabblad bestaan."
                : "With your permission, YouNew counts page visits and bounded product actions. We do not send search text, profile details, precise location, advertising IDs or cross-site identifiers. The identifier lasts only for this browser tab."}
            </p>
            <p>
              {nl ? `Gegevens worden maximaal ${siteConfig.analytics.retentionDays} dagen op de Hostinger-hosting van YouNew in de EU bewaard. Je kunt deze keuze altijd wijzigen. Lees het ` : `Data is stored on YouNew’s Hostinger hosting in the EU for up to ${siteConfig.analytics.retentionDays} days. You can change this choice at any time. Read the `}<a href="/privacy/">{nl ? "privacybeleid" : "Privacy Policy"}</a>.
            </p>
          </div>
          <div className="analytics-consent-actions">
            {siteConfig.analytics.guideMetricsEnabled ? <p>{nl ? "We tellen ook de openbare gids, actieve leestijd en vervolgklikken. Alleen lokaal bewaren we de vorige bezoekdatum. We versturen alleen of je 7–30 dagen geleden kwam, zonder blijvend bezoekers-ID." : "We also count the public guide, active reading time and next-step clicks. Only this browser keeps the previous visit date. We send only whether it was 7–30 days ago, without a persistent visitor ID."}</p> : null}
            <button type="button" className="button-secondary" onClick={decline}>
              {nl ? "Analytics weigeren" : "Decline analytics"}
            </button>
            <button type="button" className="button-primary" onClick={accept}>
              {nl ? "Anonieme analytics toestaan" : "Allow anonymous analytics"}
            </button>
          </div>
        </section>
      ) : null}
    </>
  );
}
