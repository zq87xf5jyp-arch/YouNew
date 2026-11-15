import type statusSnapshot from "@/config/status.json";

export type StatusSnapshot = typeof statusSnapshot;

const humanDate = (date: string) =>
  new Intl.DateTimeFormat("en-NL", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "Europe/Amsterdam"
  }).format(new Date(date));

export function StatusPanel({ snapshot }: { snapshot: StatusSnapshot }) {
  // HTML and the public JSON are produced together by the normal static build.
  // Do not overwrite this dated snapshot with a different cached runtime file.
  const current = snapshot;

  return (
    <div className="status-panel">
      <p className="status-snapshot-note">
        <strong>Static status snapshot.</strong> This page does not use live monitoring. Snapshot checked{" "}
        <time dateTime={current.checkedAt}>{humanDate(current.checkedAt)}</time>.
      </p>
      <p><strong>{current.assessment}</strong></p>

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
          <dl className="status-release-details" aria-label="Published entity counts">
            {([
              ["Published entities", current.content.counts.total],
              ["Places", current.content.counts.places],
              ["Summary guides", current.content.counts.summaryGuides],
              ["Cities", current.content.counts.cities],
              ["Full practical guides", current.content.counts.fullGuides]
            ] as const).map(([label, count]) => <div key={label}><dt>{label}</dt><dd>{count}</dd></div>)}
          </dl>
          <p className="status-card-meta">
            Latest editorial release: <time dateTime={current.content.asOf}>{humanDate(current.content.asOf)}</time>.
            {" "}Underlying source checks: {current.content.sourceCheckedDates.map(humanDate).join("; ")}.
            {" "}The snapshot check is not a new verification of every content claim.
          </p>
        </article>

        <article className="status-card">
          <div className="status-card-heading">
            <h2>{current.ios.label}</h2>
            <span className={`status-pill status-${current.ios.status}`}>{current.ios.status}</span>
          </div>
          <p>{current.ios.summary}</p>
          <dl className="status-release-details">
            <div>
              <dt>Public version</dt>
              <dd>{current.ios.publicVersion ?? "Not independently verified"}</dd>
            </div>
            <div>
              <dt>Public release date</dt>
              <dd><time dateTime={current.ios.releasedAt}>{humanDate(current.ios.releasedAt)}</time></dd>
            </div>
          </dl>
          <p>
            Source comparison: {current.ios.sourceComparison.webOnlyIDs} published web IDs are absent from the current iOS source bundle;
            {" "}{current.ios.sourceComparison.sharedIDs} IDs are shared. This compares source artifacts, not the shipped App Store binary.
          </p>
        </article>

        <article className="status-card">
          <div className="status-card-heading">
            <h2>{current.businessForm.label}</h2>
            <span className={`status-pill status-${current.businessForm.status}`}>{current.businessForm.status}</span>
          </div>
          <p>{current.businessForm.summary}</p>
        </article>
      </section>

      <section className="status-section" aria-labelledby="status-evidence">
        <h2 id="status-evidence">Evidence and dates</h2>
        <p>{current.history}</p>
        <ul className="status-list">
          {current.evidenceLinks.map((link) => <li key={link.href}><a href={link.href}>{link.label}</a></li>)}
        </ul>
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
