"use client";

import { useEffect, useState } from "react";
import { ExternalLink, RefreshCw, ShieldCheck } from "lucide-react";
import {
  ADMIN_CONTENT_FEED_URL,
  parseAdminContentFeed,
  type AdminContentFeed
} from "@/lib/admin-content-feed";

type FeedState =
  | { status: "loading" }
  | { status: "ready"; feed: AdminContentFeed }
  | { status: "error" };

function formattedDate(value: string) {
  return new Intl.DateTimeFormat("en-NL", {
    dateStyle: "medium",
    timeZone: "Europe/Amsterdam"
  }).format(new Date(value));
}

function ContentParagraphs({ content }: { content: string }) {
  const paragraphs = content
    .split(/\n{2,}/)
    .map((paragraph) => paragraph.trim())
    .filter(Boolean);
  return <>{paragraphs.map((paragraph, index) => <p key={`${index}-${paragraph.slice(0, 24)}`}>{paragraph}</p>)}</>;
}

export function AdminUpdates() {
  const [state, setState] = useState<FeedState>({ status: "loading" });

  useEffect(() => {
    const controller = new AbortController();
    async function load() {
      try {
        const response = await fetch(ADMIN_CONTENT_FEED_URL, {
          headers: { Accept: "application/json" },
          signal: controller.signal
        });
        if (!response.ok) throw new Error("content_feed_unavailable");
        const feed = parseAdminContentFeed(await response.json());
        if (!feed) throw new Error("content_feed_invalid");
        setState({ status: "ready", feed });
      } catch (error) {
        if (error instanceof DOMException && error.name === "AbortError") return;
        setState({ status: "error" });
      }
    }
    void load();
    return () => controller.abort();
  }, []);

  if (state.status === "loading") {
    return (
      <div className="updates-state" role="status">
        <RefreshCw aria-hidden />
        <div><h2>Loading verified updates</h2><p>The public Admin feed is being checked.</p></div>
      </div>
    );
  }

  if (state.status === "error") {
    return (
      <div className="updates-state updates-state-warning" role="status">
        <ShieldCheck aria-hidden />
        <div>
          <h2>Admin updates are temporarily unavailable</h2>
          <p>No unverified fallback content is shown. The reviewed YouNew guides and destinations remain available through the main navigation.</p>
        </div>
      </div>
    );
  }

  if (!state.feed.available) {
    return (
      <div className="updates-state">
        <ShieldCheck aria-hidden />
        <div>
          <h2>No Admin update has been activated</h2>
          <p>Drafts, review items and empty candidates are never shown here.</p>
        </div>
      </div>
    );
  }

  return (
    <section className="updates-feed" aria-labelledby="updates-feed-title">
      <header className="updates-feed-header">
        <div>
          <p className="section-label cyan">Synced from Admin</p>
          <h2 id="updates-feed-title">{state.feed.recordCount} verified update{state.feed.recordCount === 1 ? "" : "s"}</h2>
        </div>
        <dl>
          <div><dt>Activated</dt><dd>{formattedDate(state.feed.activatedAt)}</dd></div>
          <div><dt>Fingerprint</dt><dd title={state.feed.fingerprint}>{state.feed.fingerprint.slice(0, 12)}</dd></div>
        </dl>
      </header>
      <div className="updates-list">
        {state.feed.records.map((record) => (
          <article className="update-card" key={record.id}>
            <div className="update-card-labels">
              <span>{record.language.toUpperCase()}</span>
              {record.categorySlug ? <span>{record.categorySlug.replaceAll("-", " ")}</span> : null}
            </div>
            <h3>{record.title}</h3>
            {record.summary ? <p className="update-summary">{record.summary}</p> : null}
            {record.content ? (
              <details>
                <summary>Read full update</summary>
                <div className="update-content"><ContentParagraphs content={record.content} /></div>
              </details>
            ) : null}
            <footer>
              <span>Verified {formattedDate(record.verifiedDate)}</span>
              <a href={record.officialSourceUrl} target="_blank" rel="noreferrer">
                Official source <ExternalLink aria-hidden />
              </a>
            </footer>
          </article>
        ))}
      </div>
    </section>
  );
}
