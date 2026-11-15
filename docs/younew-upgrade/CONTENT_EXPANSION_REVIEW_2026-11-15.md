# Travel content preparation — cumulative journal, 2026-11-15

Status: **review preparation, not a release candidate and not published**.

Base: Draft PR #69 (`a56429fcc42a209324b51f29eda953684e043b0b`). Working checkout: `/Users/ivan/YouNew`. No merge, production deployment, signing change, TestFlight or App Store operation.

## Coverage

| City | Referenced objects | Source content checked | Draft revisions/new entries | Optimized photo candidates |
|---|---:|---:|---:|---:|
| leiden | 55 | 54 | 6 | 8 |
| amsterdam | 20 | 17 | 20 | 11 |
| rotterdam | 13 | 13 | 10 | 5 |
| den-haag | 14 | 11 | 10 | 6 |
| utrecht | 15 | 15 | 10 | 6 |
| eindhoven | 12 | 10 | 10 | 4 |

- 129 referenced objects: 63 existing compact-release records, 20 revisions preserving Amsterdam IDs, 46 proposed new IDs. No duplicate IDs in the effective set. Existing records remain references to immutable files, not a second editable catalogue.
- 66 EN/NL draft records prepared across six batches. 57 have newly read primary-source content; 9 remain fact-check blocked. The other 63 retain their existing 2026-11-09 source checks. Thus 120/129 (93.0%) source coverage is **not 120 newly checked URLs**.
- 40 photo candidates / 120 optimized WebP variants (480, 800, 1200 px), approximately 13 MB including evidence. 11 candidates were visually inspected as photographs; this is not Simulator QA. All 40 still require human licensing/attribution review; zero new photos approved or activated.
- Two candidates (Foam and Van Gogh Museum) have ambiguous author extraction: author and attribution are explicitly null, with a blocking issue. Extracted incorrect values are retained only as rejected evidence. Seven discovery candidates were rejected before download because they depicted a person, artwork, unrelated park, historical event or an obsolete venue entrance.
- Six draft cultural collections reference existing IDs with checked sources in their own city. No durations, distances, prices or popularity claims.
- Zero new coordinates verified. Eight referenced objects retain existing coordinate data (seven already in runtime); this does not establish 80% geographic coverage.
- Runtime is unchanged: 12 Leiden cards, 4 bundled approved photos, 7 coordinates and 6 ticket links. Burcht still has no ticket action. Existing remote photos are not counted as newly prepared local photos.

## Per-batch findings

- Leiden: six additional museum/culture drafts. Existing restaurants, hotels, services and parks reused by reference. De Engelenbak excluded from this review index after the previously observed unrelated casino promotion; no upstream publication status changed.
- Amsterdam: twenty historical IDs reused. Generic old descriptions were replaced in review only; old coordinates/images were not silently treated as freshly verified.
- Rotterdam: Depot Boijmans is distinguished from the main museum. The current Fotomuseum site describes Santos in Katendrecht; an older entrance photograph was rejected.
- Den Haag: ten draft entries; three source checks remain blocked.
- Utrecht: ten draft entries; Catharijneconvent and UMU source URLs corrected using official visitor/university pages. Stale event dates on pages were not imported.
- Eindhoven: ten draft entries. Official source confirms the former preHistorisch Dorp now uses Museumpark VONK; its proposed stable ID is retained with former names documented.

## Remaining gaps and limits

- Photo target is not achieved: only 40/129 (31.0%) have newly optimized candidates, and even those are not approved. Existing approved media remains available separately. Missing media is not replaced by invented imagery.
- The 80% coordinate target is not achieved. The bounded Overpass preparation stopped before submitting its data query because robots policy was unavailable/disallowed. Its empty evidence file must not be interpreted as geographic verification.
- Public Commons category/file pages were used; robots-disallowed API/search routes were not bypassed. Category lookup failures and candidates are recorded in `media-discovery.json`. No claim is made that all possible public sources have been exhausted.
- Four selected media candidates have no optimized files (licensing parsing or response-size limits). Remaining identity/rights checks are explicit review work. SHA-256 proves file integrity, not licensing or factual correctness.
- Nine unresolved primary sources:
  - `place.leiden-oude-sterrewacht`
  - `museum.foam`
  - `museum.artis-micropia`
  - `museum.museum-van-loon`
  - `museum.den-haag-mauritshuis`
  - `museum.den-haag-kunstmuseum`
  - `place.den-haag-madurodam`
  - `place.eindhoven-strijp-s`
  - `place.eindhoven-park-theatre`

- No newly verified events, addresses, prices, hours, menu/booking or ticket actions were activated. Source-page action candidates are discovery hints only, not verified buttons.
- Free space temporarily fell below the 200 MiB downloader reserve. Only this task’s temporary x86_64 build object caches were removed; source, user data, arm64 outputs and the existing `.app` were retained. Downloading resumed and the cached candidate pass completed.
- Preparation has passed six city batches, but the requested complete release-candidate coverage remains unfinished. Next work is targeted missing-media/coordinate evidence and human review, not publication or a claimed finished app.

## Reproduction and validation

No dependencies added. Existing canonical entity schema validator is reused.

```sh
python3 scripts/prepare-travel-expansion.py --write
python3 scripts/prepare-travel-expansion.py --check
python3 scripts/tests/travel_expansion_review_test.py
node scripts/export-approved-ios-places.mjs --check
node --experimental-strip-types --test scripts/tests/approved-ios-places.test.mjs scripts/tests/approved-ios-completion.test.mjs scripts/tests/leiden-completion-selection.test.mjs admin-dashboard/public-site/tests/editorial-release.test.ts admin-dashboard/public-site/tests/place-review.test.ts admin-dashboard/public-site/tests/leiden-nature-review.test.ts
```

- Eight new offline checks passed: existing canonical schema/EN-NL, IDs/reference hashes, draft boundaries, source proofs, media hashes, collection links, runtime immutability and deterministic regeneration.
- Twenty existing publication/export/review tests passed. Governed exporter `--check` passed with the unchanged 12-card approved projection.
- These are draft structural checks, not the full publication gate: missing coordinates/media and unapproved records intentionally remain ineligible for release.
- No Xcode build performed in this iteration: no iOS code, runtime resources or project configuration changed. The attached Xcode project was the old iCloud checkout, so it was not used for this task.
- No Simulator/device navigation, Save, Maps, Tickets, VoiceOver, themes, performance or offline runtime checks performed in this iteration. Full runtime QA remains required after a sufficiently complete approved candidate is integrated.

## Files and boundaries

- `DataProject/research/travel-expansion-20261115/`: source registry, curated EN/NL input, content inspection, media discovery/evidence/variants, coordinate limitation evidence, reference index.
- `DataProject/staging/travel-expansion-20261115/`: six canonical draft batches with SHA-bound manifests and six draft collections. Explicitly staged despite the repository’s staging ignore rule.
- `scripts/prepare-travel-expansion.py`, `scripts/discover-travel-media.py`, `scripts/prepare-travel-media.py`, `scripts/prepare-travel-coordinates.py`: cached, bounded preparation tools. Existing publication/exporter paths are untouched.
- `scripts/tests/travel_expansion_review_test.py`: offline verification. This cumulative journal replaces per-object reports.

Human approval records, previous review packages, runtime content and published data remain unchanged. The new manifests contain no reviewer identity or granted publication permission.
