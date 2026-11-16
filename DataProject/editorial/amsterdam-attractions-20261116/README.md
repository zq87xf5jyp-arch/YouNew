# Amsterdam attractions — 10 EN/NL draft revisions

Prepared 2026-11-16 from PR75 `fa0ec02`. Existing historical IDs only. No production publication, approval or outreach. No new dependencies or iOS changes.

## Contents

- `records.json`: 10 cards, 5 source-linked blocks per locale (100 blocks), 10 selected official BAG address points.
- `manifest.json`: hash-bound `needs_review`, `privateOnly: true`, `publicationAuthorized: false`.
- `source-checks.json`: 33 evidence entries. 32 direct HTTP 200 checks; OBA is indexed official evidence with direct 403/429, explicitly pending a live check. These are not 33 live-success claims.
- `review-issues.json`: two publication blockers: Nieuwe Kerk conflicting official hours and OBA live verification. The other eight cards also need owner/editor approval.
- `media-followup.json`: new leads and specific blockers for four first-photo gaps and four replacement heroes. Zero new images downloaded or authorised. No email or permission request sent.
- `REVIEW.html`: paired text, source links and the photo follow-up; links to the unchanged five-photo visual package.
- `evidence/preserved-pr75.json`: SHA-256 snapshot of all 32 existing photo-package files, including licenses, captions, placement recommendations and 1024px Supernova.

## Coordinate scope

Each point comes from the first PDOK result after exact street, house number, postcode and Amsterdam locality review, linked to the operator's address (Nieuwe Kerk: Rijksmonumentenregister). They are address points, not surveyed accessible entrances. No new coordinate system or iOS schema is introduced. Historical source batches and mobile runtime are unchanged.

## Sources and editorial decisions

Direct HTML responses and geocoder responses are cached outside the repository at `/Users/ivan/YouNew-Expansion-20261116-Evidence`; hashes and selected-address evidence are versioned here. Public HTML hashes are observations, not claims that third-party pages will remain byte-identical. OBA's compact indexed evidence is included instead of inventing a successful live fetch.

A’DAM LOOKOUT's stale search snippet disagreed with its contact page. Direct responses from both current pages agree: Mon–Thu 11:00–19:00, Fri–Sun 11:00–21:00. Nieuwe Kerk's direct pages still disagree; both are shown and approval remains pending. Hortus explicitly mentions partial Palm House closure. ARTIS hours are seasonal; the Micropia schedule is not substituted for zoo hours. All prices are observations on 16 November 2026, not guarantees for a future date.

No legacy photo with unverified provenance is carried into these ten revisions; `images: []` is deliberate. This text batch does not claim to fill ten media gaps. Four original photo gaps remain, plus four better-hero requests.

## Local review

From `admin-dashboard/public-site`, use the existing `scripts/build-place-review.mjs` with `YOUNEW_PLACE_REVIEW=amsterdam-attractions-20261116,missing-photos-20261116`. Serve the resulting `out` on loopback only. It is private/noindex with an empty sitemap. Ordinary generation remains at 96 entities / 50 places with photos; combined private review is 106 / 55. These are local artifact counts, not a fresh production audit.

Human review must resolve `review-issues.json` and approve the exact hashes before a separately authorised release. No approval is inferred from preparation of this batch.
