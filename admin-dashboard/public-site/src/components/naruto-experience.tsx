"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  CheckCircle2,
  ExternalLink,
  LifeBuoy,
  RefreshCw,
  Search,
  ShieldCheck
} from "lucide-react";
import { publicWebSummary } from "@/lib/content/presentation";
import { rankSearchDocuments, type SearchDocument } from "@/lib/search/rank";

type SearchIndex = { schemaVersion: 3; documents: SearchDocument[] };

const suggestedQuestions = [
  "I need a BSN",
  "I need housing",
  "I need a huisarts",
  "I want to learn Dutch"
] as const;

const urgentPattern = /\b(112|danger|emergency|urgent|unsafe|violence|suicide|brand|noodgeval|spoed|gevaar|опасн|экстрен|срочн)\b/i;

function officialSources(document: SearchDocument): string[] {
  return [...new Set([...(document.officialSourceUrls ?? []), ...(document.officialSourceURLs ?? [])])]
    .filter((value) => /^https?:\/\//i.test(value));
}

function sourceLabel(value: string): string {
  try {
    return new URL(value).hostname.replace(/^www\./, "");
  } catch {
    return "Official source";
  }
}

function checkedDateLabel(value: string): string {
  const date = new Date(value.includes("T") ? value : `${value}T00:00:00Z`);
  if (Number.isNaN(date.getTime())) return value;
  return new Intl.DateTimeFormat("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC"
  }).format(date);
}

export function NarutoExperience() {
  const [documents, setDocuments] = useState<SearchDocument[]>([]);
  const [query, setQuery] = useState("");
  const [submittedQuery, setSubmittedQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);

  useEffect(() => {
    const initialQuery = new URLSearchParams(window.location.search).get("q")?.trim() ?? "";
    setQuery(initialQuery);
    setSubmittedQuery(initialQuery);
    fetch("/data/search-index.json", { headers: { Accept: "application/json" } })
      .then((response) => {
        if (!response.ok) throw new Error(String(response.status));
        return response.json() as Promise<SearchIndex>;
      })
      .then((index) => {
        if (index.schemaVersion !== 3) throw new Error("Unsupported search index");
        setDocuments(index.documents);
      })
      .catch(() => setLoadError(true))
      .finally(() => setLoading(false));
  }, []);

  const ranked = useMemo(
    () => submittedQuery ? rankSearchDocuments(documents, submittedQuery, { limit: 8 }) : [],
    [documents, submittedQuery]
  );
  const primary = ranked.find(({ document }) => (document.numberedSteps?.length ?? 0) > 0)
    ?? ranked.find(({ document }) => officialSources(document).length > 0)
    ?? ranked[0];
  const related = ranked.filter(({ document }) => document.id !== primary?.document.id).slice(0, 4);
  const sources = primary ? officialSources(primary.document) : [];
  const urgent = urgentPattern.test(submittedQuery);

  function ask(value: string) {
    const normalized = value.trim();
    if (!normalized) return;
    setQuery(normalized);
    setSubmittedQuery(normalized);
    const params = new URLSearchParams({ q: normalized });
    window.history.replaceState(null, "", `${window.location.pathname}?${params}`);
  }

  function submit(event: FormEvent) {
    event.preventDefault();
    ask(query);
  }

  function reset() {
    setQuery("");
    setSubmittedQuery("");
    window.history.replaceState(null, "", window.location.pathname);
    document.querySelector<HTMLInputElement>("#naruto-question")?.focus();
  }

  return (
    <div className="naruto-experience">
      <form className="naruto-composer" role="search" onSubmit={submit}>
        <div className="naruto-input-row">
          <Search aria-hidden />
          <input
            id="naruto-question"
            aria-label="Ask Naruto a question about life in the Netherlands"
            autoComplete="off"
            placeholder="What do you need help with in the Netherlands?"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
          />
          <button className="button button-primary" type="submit" disabled={loading || !query.trim()}>
            Find my next step <ArrowRight aria-hidden />
          </button>
        </div>
        <div className="naruto-suggestions" aria-label="Suggested questions">
          {suggestedQuestions.map((suggestion) => (
            <button
              type="button"
              className={submittedQuery === suggestion ? "is-selected" : ""}
              aria-pressed={submittedQuery === suggestion}
              onClick={() => ask(suggestion)}
              key={suggestion}
            >
              {submittedQuery === suggestion ? <CheckCircle2 aria-hidden /> : null}{suggestion}
            </button>
          ))}
        </div>
      </form>

      <p className="naruto-privacy"><ShieldCheck aria-hidden /> No account or precise location required. Do not include identity numbers or medical details. Your question is matched in this browser against YouNew&apos;s published index.</p>

      <div className="naruto-status" aria-live="polite">
        {loading ? <p>Loading published YouNew guidance…</p> : null}
        {loadError ? (
          <section className="naruto-empty">
            <h2>Naruto cannot open the published index right now</h2>
            <p>Use YouNew search or try again when the connection is restored.</p>
            <Link className="button button-outline" href="/search/">Open search</Link>
          </section>
        ) : null}
      </div>

      {!loading && !loadError && !submittedQuery ? (
        <section className="naruto-intro" aria-labelledby="naruto-intro-title">
          <ShieldCheck aria-hidden />
          <div>
            <h2 id="naruto-intro-title">Published guidance, not an invented answer</h2>
            <p>Naruto finds the strongest available YouNew route, keeps official sources visible and says when verified guidance is missing.</p>
          </div>
        </section>
      ) : null}

      {!loading && !loadError && submittedQuery ? (
        <section className="naruto-answer" aria-labelledby="naruto-answer-title">
          <header>
            <div><span>Naruto found {ranked.length} published route{ranked.length === 1 ? "" : "s"}</span><h2 id="naruto-answer-title">{submittedQuery}</h2></div>
            <button type="button" onClick={reset}><RefreshCw aria-hidden /> New question</button>
          </header>

          {urgent ? (
            <aside className="naruto-urgent" role="note">
              <LifeBuoy aria-hidden />
              <div><strong>Need urgent help?</strong><p>For immediate danger in the Netherlands, call 112. YouNew keeps emergency guidance separate from general search.</p></div>
              <Link href="/emergency/">Open emergency help <ArrowRight aria-hidden /></Link>
            </aside>
          ) : null}

          {primary ? (
            <div className="naruto-primary-route">
              <p className="naruto-summary">{publicWebSummary(primary.document.summary)}</p>
              {primary.document.numberedSteps?.length ? (
                <ol className="naruto-steps">
                  {primary.document.numberedSteps.slice(0, 5).map((step, index) => <li key={step}><span>{index + 1}</span><p>{step}</p></li>)}
                </ol>
              ) : null}

              {sources.length ? (
                <section className="naruto-sources" aria-labelledby="naruto-sources-title">
                  <div><ShieldCheck aria-hidden /><span><h3 id="naruto-sources-title">Official sources</h3><p>Confirm current requirements with the responsible organization.</p></span></div>
                  <ul>{sources.map((source) => <li key={source}><a href={source} rel="noreferrer" target="_blank"><span>{sourceLabel(source)}</span><ExternalLink aria-hidden /></a></li>)}</ul>
                </section>
              ) : null}

              <section className="naruto-younew-guide" aria-labelledby="naruto-guide-title">
                <BookOpen aria-hidden />
                <div><h3 id="naruto-guide-title">YouNew guide</h3><p>{primary.document.verifiedAt ? `Source set checked ${checkedDateLabel(primary.document.verifiedAt)}.` : "Open the published route for its scope and verification details."}</p><Link href={primary.document.route}>{primary.document.title} <ArrowRight aria-hidden /></Link></div>
              </section>

              <p className="naruto-safety-note">Naruto only shows information from published YouNew guidance and official directories. If verified guidance is missing, Naruto says so.</p>
            </div>
          ) : (
            <div className="naruto-empty">
              <h3>No useful published match yet</h3>
              <p>Naruto does not invent a route when YouNew has no verified match. Try a broader question or open the full search.</p>
              <Link className="button button-outline" href={`/search/?q=${encodeURIComponent(submittedQuery)}`}>Open full search</Link>
            </div>
          )}

          {related.length ? (
            <nav className="naruto-related" aria-label="Related published routes">
              <h3>Related published routes</h3>
              <div>{related.map(({ document }) => <Link href={document.route} key={document.id}><span>{document.title}</span><ArrowRight aria-hidden /></Link>)}</div>
            </nav>
          ) : null}
        </section>
      ) : null}
    </div>
  );
}
