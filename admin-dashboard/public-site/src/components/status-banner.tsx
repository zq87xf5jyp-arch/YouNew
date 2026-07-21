"use client";

import type { CSSProperties } from "react";
import { useEffect, useState } from "react";
import defaultSiteConfig from "@/config/site-config.json";

type StatusBannerConfig = {
  enabled: boolean;
  id: string;
  tone: "information" | "warning";
  message: string;
  action?: {
    label: string;
    href: string;
  };
};

type SiteConfig = {
  schemaVersion: number;
  statusBanner: StatusBannerConfig;
};

const fallbackConfig = defaultSiteConfig as SiteConfig;
const visuallyHidden: CSSProperties = {
  position: "absolute",
  width: 1,
  height: 1,
  padding: 0,
  margin: -1,
  overflow: "hidden",
  clip: "rect(0, 0, 0, 0)",
  whiteSpace: "nowrap",
  border: 0
};

export function StatusBanner() {
  const [config, setConfig] = useState<SiteConfig>(fallbackConfig);
  const [dismissed, setDismissed] = useState(false);
  const [interactive, setInteractive] = useState(false);
  const [announcement, setAnnouncement] = useState("");

  useEffect(() => {
    setInteractive(true);
    const controller = new AbortController();

    fetch("/data/site-config.json", {
      cache: "no-store",
      headers: { Accept: "application/json" },
      signal: controller.signal
    })
      .then((response) => {
        if (!response.ok) throw new Error(`Site configuration returned ${response.status}`);
        return response.json() as Promise<SiteConfig>;
      })
      .then((nextConfig) => {
        if (nextConfig?.statusBanner && typeof nextConfig.statusBanner.enabled === "boolean") {
          setConfig(nextConfig);
        }
      })
      .catch((error: unknown) => {
        if (error instanceof DOMException && error.name === "AbortError") return;
        // The bundled, truthful default remains visible if the editable config cannot be loaded.
      });

    return () => controller.abort();
  }, []);

  useEffect(() => {
    try {
      const wasDismissed = sessionStorage.getItem(`younew-banner:${config.statusBanner.id}`) === "dismissed";
      setDismissed(wasDismissed);
      setAnnouncement(!wasDismissed && config.statusBanner.enabled ? config.statusBanner.message : "");
    } catch {
      setDismissed(false);
      setAnnouncement(config.statusBanner.enabled ? config.statusBanner.message : "");
    }
  }, [config.statusBanner.enabled, config.statusBanner.id, config.statusBanner.message]);

  const dismiss = () => {
    try {
      sessionStorage.setItem(`younew-banner:${config.statusBanner.id}`, "dismissed");
    } catch {
      // Dismissing still works for this render when storage is unavailable.
    }
    setDismissed(true);
    setAnnouncement("Application availability update dismissed.");
  };

  return (
    <>
      <p data-status-banner-live role="status" aria-live="polite" aria-atomic="true" style={visuallyHidden}>{announcement}</p>
      {config.statusBanner.enabled && !dismissed ? (
        <aside
          className={`status-banner status-banner-${config.statusBanner.tone}`}
          aria-label="Application availability update"
        >
          <div className="section-shell status-banner-inner">
            <p className="status-banner-message">{config.statusBanner.message}</p>
            <div className="status-banner-actions">
              {config.statusBanner.action ? (
                <a className="status-banner-link" href={config.statusBanner.action.href}>
                  {config.statusBanner.action.label}
                </a>
              ) : null}
              <button className="status-banner-dismiss" type="button" disabled={!interactive} onClick={dismiss} aria-label="Dismiss availability update">
                Dismiss
              </button>
            </div>
          </div>
        </aside>
      ) : null}
    </>
  );
}
