"use client";

import { type KeyboardEvent, useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import { ShieldCheck } from "lucide-react";
import siteConfig from "@/config/site-config.json";
import {
  createSupabaseAnalyticsProvider,
  randomUUIDv4,
  type AnalyticsProvider
} from "@/lib/analytics/client";

type ConsentChoice = "accepted" | "declined";

const consentStorageKey = "younew.analytics-consent.2026-07-28";
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
  const providerRef = useRef<AnalyticsProvider | undefined>(undefined);
  const consentGrantPendingRef = useRef(false);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const dialogRef = useRef<HTMLElement>(null);
  const declineRef = useRef<HTMLButtonElement>(null);
  const previousFocusRef = useRef<HTMLElement | null>(null);
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
    if (!settingsOpen) return;
    previousFocusRef.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    window.requestAnimationFrame(() => declineRef.current?.focus());
  }, [settingsOpen]);

  useEffect(() => {
    if (!isReady || choice !== "accepted" || !siteConfig.analytics.enabled) return;

    let provider: AnalyticsProvider;
    try {
      provider = createSupabaseAnalyticsProvider({
        configuration: siteConfig.analytics,
        appInstanceId: sessionIdentifier(appInstanceStorageKey),
        sessionId: sessionIdentifier(sessionStorageKey)
      });
    } catch {
      return;
    }
    providerRef.current = provider;
    window.__YOUNEW_ANALYTICS__ = provider;
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
    window.requestAnimationFrame(() => triggerRef.current?.focus());
  };

  const decline = () => {
    saveConsent("declined");
    clearAnalyticsSession();
    setChoice("declined");
    setSettingsOpen(false);
    window.requestAnimationFrame(() => triggerRef.current?.focus());
  };

  const closeSettings = () => {
    setSettingsOpen(false);
    window.requestAnimationFrame(() => (triggerRef.current ?? previousFocusRef.current)?.focus());
  };

  const handleDialogKeyDown = (event: KeyboardEvent<HTMLElement>) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeSettings();
      return;
    }
    if (event.key !== "Tab") return;
    const focusable = [...(dialogRef.current?.querySelectorAll<HTMLElement>('a[href],button:not([disabled])') ?? [])];
    if (focusable.length === 0) return;
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  };

  return (
    <>
      {!settingsOpen ? (
        <button
          ref={triggerRef}
          type="button"
          className="analytics-settings-trigger"
          onClick={() => setSettingsOpen(true)}
          aria-label="Open analytics privacy choices"
        >
          <ShieldCheck aria-hidden />
          <span className="visually-hidden">Privacy choices</span>
        </button>
      ) : null}
      {settingsOpen ? (
        <section
          ref={dialogRef}
          className="analytics-consent"
          role="dialog"
          aria-modal="true"
          aria-labelledby="analytics-consent-title"
          onKeyDown={handleDialogKeyDown}
        >
          <div>
            <p className="analytics-consent-eyebrow">Your privacy choice</p>
            <h2 id="analytics-consent-title">Help improve YouNew?</h2>
            <p>
              With your permission, YouNew counts page visits and bounded product actions.
              We do not send search text, profile details, precise location, advertising IDs
              or cross-site identifiers. The identifier lasts only for this browser tab.
            </p>
            <p>
              Data is stored in the EU for up to {siteConfig.analytics.retentionDays} days.
              You can change this choice at any time. Read the <a href="/privacy/">Privacy Policy</a>.
            </p>
          </div>
          <div className="analytics-consent-actions">
            <button ref={declineRef} type="button" className="button-secondary" onClick={decline}>
              Decline analytics
            </button>
            <button type="button" className="button-primary" onClick={accept}>
              Allow anonymous analytics
            </button>
          </div>
        </section>
      ) : null}
    </>
  );
}
