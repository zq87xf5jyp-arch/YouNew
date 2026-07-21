"use client";

import { useEffect, useState } from "react";

export type StatusSnapshot = {
  schemaVersion: number;
  snapshotType: "static";
  liveMonitoring: false;
  checkedAt: string;
  website: {
    status: "operational";
    label: string;
    summary: string;
  };
  content: {
    status: "current";
    label: string;
    asOf: string;
    summary: string;
  };
  ios: {
    status: "unconfirmed";
    label: string;
    publicVersion: string | null;
    testedVersion: string;
    testedBuild: string;
    summary: string;
  };
  limitations: string[];
  webAlternatives: Array<{
    label: string;
    href: string;
    summary: string;
  }>;
};

const humanDate = (date: string) =>
  new Intl.DateTimeFormat("en-NL", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "Europe/Amsterdam"
  }).format(new Date(date));

export function StatusPanel({ snapshot }: { snapshot: StatusSnapshot }) {
  const [current, setCurrent] = useState(snapshot);

  useEffect(() => {
    const controller = new AbortController();
    fetch("/data/status.json", { cache: "no-store", headers: { Accept: "application/json" }, signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error(String(response.status));
        return response.json() as Promise<StatusSnapshot>;
      })
      .then((next) => {
        if (next?.schemaVersion === 1 && next.snapshotType === "static" && next.liveMonitoring === false) setCurrent(next);
      })
      .catch((error: unknown) => {
        if (error instanceof DOMException && error.name === "AbortError") return;
        // Keep the bundled snapshot when the mutable status file is unavailable.
      });
    return () => controller.abort();
  }, []);

  return (
    <div className="status-panel">
      <p className="status-snapshot-note">
        <strong>Static status snapshot.</strong> This page does not use live monitoring. Snapshot checked{" "}
        <time dateTime={current.checkedAt}>{humanDate(current.checkedAt)}</time>.
      </p>

      <section className="status-grid" aria-label="YouNew service status">
        <article className="status-card">
          <div className="status-card-heading">
            <h2>{current.website.label}</h2>
            <span className={`status-pill status-${current.website.status}`}>{current.website.status}</span>
          </div>
          <p>{current.website.summary}</p>
        </article>

        <article className="status-card">
          <div className="status-card-heading">
            <h2>{current.content.label}</h2>
            <span className={`status-pill status-${current.content.status}`}>{current.content.status}</span>
          </div>
          <p>{current.content.summary}</p>
          <p className="status-card-meta">
            Content date: <time dateTime={current.content.asOf}>{humanDate(current.content.asOf)}</time>
          </p>
        </article>

        <article className="status-card">
          <div className="status-card-heading">
            <h2>{current.ios.label}</h2>
            <span className={`status-pill status-${current.ios.status}`}>not confirmed</span>
          </div>
          <p>{current.ios.summary}</p>
          <dl className="status-release-details">
            <div>
              <dt>Public version</dt>
              <dd>{current.ios.publicVersion ?? "Not confirmed"}</dd>
            </div>
            <div>
              <dt>Locally tested version</dt>
              <dd>
                {current.ios.testedVersion} (build {current.ios.testedBuild})
              </dd>
            </div>
          </dl>
        </article>
      </section>

      <section className="status-section" aria-labelledby="status-limitations">
        <h2 id="status-limitations">Known limitations</h2>
        <ul className="status-list">
          {current.limitations.map((limitation) => (
            <li key={limitation}>{limitation}</li>
          ))}
        </ul>
      </section>

      <section className="status-section" aria-labelledby="status-alternatives">
        <h2 id="status-alternatives">Available web alternatives</h2>
        <div className="status-alternatives">
          {current.webAlternatives.map((alternative) => (
            <a className="status-alternative" href={alternative.href} key={alternative.href}>
              <strong>{alternative.label}</strong>
              <span>{alternative.summary}</span>
            </a>
          ))}
        </div>
      </section>
    </div>
  );
}
