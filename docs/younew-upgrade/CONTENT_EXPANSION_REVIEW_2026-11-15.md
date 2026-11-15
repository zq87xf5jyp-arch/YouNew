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

## Follow-up: exact approval request (2026-11-15)

Prepared from PR #70 in `feature/travel-approval-selection-20261115`. Prior source files, image bytes, staging manifests and approvals were preserved unchanged.

- Reused official-source address evidence and matched 33 new coordinates against BAG via the already-used public PDOK service. Full street, house number, city and supplied postcode must agree. Points are address centroids, not entrance surveys. Two mismatches remain blocked: Dutch Resistance Museum (BAG house-number suffixes) and Muziekgebouw Eindhoven (official site says Heuvel; BAG says Heuvel Galerie). No nearest-result substitution.
- All 40 local photo candidates visually inspected and their Commons pages checked. Thirty-two proposed for owner approval. Four held for subject/presentation problems (Foam is soap foam, Markthal is mostly a neighbouring streetscape, VONK is under construction, Parktheater is backstage); four held because the entity's primary-source content is unresolved (Kunstmuseum, Mauritshuis, Museum Van Loon, Madurodam).
- Van Gogh Museum attribution corrected in the new selection to photographer Minke Wagenaar. Earlier rejected extraction remains immutable historical evidence. No image downloaded or generated again; all 96 selected derivative files are referenced with existing SHA-256 hashes.
- Exact request: **57 source-checked EN/NL record projections, 32 photos, 33 address coordinates, six cultural collections**. Existing compact records are not re-approved wholesale. Nine unresolved sources and all unlisted fields remain outside scope. Selected park photos are explicitly visible in the review; other pending Leiden park draft fields remain excluded.
- Selection SHA-256: `d00afc1621010eba612be3dc397c08a3b0f3a2633538fbe825697b00b8e0dca7`.
- [Human-readable selection with photographs and EN/NL text](TRAVEL_APPROVAL_REVIEW_2026-11-15.md); [exact machine-readable selection](TRAVEL_APPROVAL_SELECTION_2026-11-15.json).
- **Human approval still pending**: no reviewer identity or approval receipt invented. The new selection does not activate runtime content. After approval, the existing governed exporter needs tested support for this exact selection; its current earlier Leiden approval remains intact.
- Tests: seven new selection checks + eight existing expansion checks + twenty publication/export/review tests passed (35 total). Governed exporter `--check` passed. Negative tests reject changed address/coordinate evidence; checks bind source/media hashes and ensure wrong-subject photos cannot enter this selection.
- No iOS code or runtime resources changed; no Xcode build or Simulator run performed. Runtime remains 12 cards, four local photos, seven coordinates and six ticket links. Full runtime QA remains mandatory after integration.
- The 80% image/coordinate targets are still unmet. This is a concrete approval-ready subset, not a complete national release candidate. Continue unresolved-source and missing-media work without publishing unapproved data.

Reproduce this follow-up offline:

```sh
python3 scripts/prepare-travel-selection.py --check
python3 scripts/tests/travel_selection_test.py
```

Optional cached evidence retrieval uses `--fetch-coordinates` / `--fetch-media`; neither grants approval. The previous `index.json` remains the historical PR #70 checkpoint. This journal and the new exact selection describe the follow-up, preventing old counters from being misrepresented as newly activated content.

## Follow-up: owner-approved local iOS integration (2026-11-15)

The owner explicitly approved the exact PR #71 selection in this conversation. The historical selection above remains unchanged (including its original pending fields); the decision is recorded separately in `DataProject/editorial/travel-ios-local-20261115-approval.json`, attributed to the existing registered human owner `owner.ivan`.

**Selection SHA-256:** `d00afc1621010eba612be3dc397c08a3b0f3a2633538fbe825697b00b8e0dca7`.

| Scope | Approved and integrated locally | Notes |
|---|---:|---|
| EN/NL record projections | 57 | Only explicitly selected fields |
| Photographs | 32 | Existing 1200px WebP bytes reused; author, license, source, capture date and transformation credit retained |
| BAG coordinates | 33 | Address-centroid disclosure in EN/NL; not surveyed entrances |
| Collections | 6 | Every member resolves to an existing canonical object |
| Additional new approval | 0 | Nine unresolved entities, two ambiguous coordinates and all excluded draft fields remain blocked |

The opt-in exporter produces `YouNew/Resources/Data/younew-approved-local-test.json`: **85 unique entities, 36 bundled photos, 40 coordinates, 85 official website fields, six existing ticket links, six collections**. This combines the original 12 Leiden cards with 57 selected projections and 16 previously approved web records required by the selected photos/collections. The latter reuse existing governed approval; their pending draft fields are not imported. These are artifact counts, not a claim that every application screen has been visually verified. All 85 have EN/NL descriptions. Local photo coverage is 36/85 (42.4%); coordinate coverage is 40/85 (47.1%), below the national candidate targets. Existing remote licensed imagery is not counted as bundled photos.

The production artifact remains byte-for-byte unchanged: 12 records, four local photos, seven coordinates and six ticket links. Release code does not load the local-test artifact; Debug explicitly opts in after checking mode and selection hash. The Xcode resource group still copies local resources into products, so any future shipping workflow must explicitly exclude the local candidate resources or obtain appropriate release authorization. This PR does not change publishing/build settings or authorize a Release shipment.

Implementation:

- `scripts/approved-ios-travel.mjs` verifies the registered human receipt, exact scope, fixed approved selection hash, bound source/media bytes, field allowlist, collection membership and BAG evidence. Mutations fail closed.
- `scripts/export-approved-ios-places.mjs --local-test` integrates through the existing exporter; default export remains unchanged. No whole batch is marked published.
- `DataProjectRuntimeLoader.swift` accepts this candidate only in Debug and preserves existing production loading.
- `MockDashboardDiscoveryData.swift` connects approved records to the existing canonical catalog, retains Saved IDs for known name variants and avoids inventing missing coordinates. Name normalization prevents duplicate spellings (e.g. Van Abbemuseum / Van Abbe Museum).
- `DashboardDiscoveryViews.swift` reuses existing place cards and actions for six collections, and labels BAG accuracy; `HomeView.swift` exposes the collections. Existing Save, Share, Website, Apple Maps and six Tickets actions are reused.
- `CityPlacesCalendarRegressionTests.swift` covers existing Leiden IDs and the candidate, local-only loading, canonical links, translations, media and alias uniqueness. These tests compile, but require an installed Simulator to execute.

Verification commands:

```sh
node scripts/export-approved-ios-places.mjs --check
node scripts/export-approved-ios-places.mjs --local-test --check
python3 scripts/prepare-travel-selection.py --check
node --test scripts/tests/approved-ios-places.test.mjs scripts/tests/approved-ios-completion.test.mjs scripts/tests/leiden-completion-selection.test.mjs scripts/tests/approved-ios-travel.test.mjs
python3 -m unittest scripts/tests/travel_selection_test.py scripts/tests/travel_expansion_review_test.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project /Users/ivan/YouNew/YouNew.xcodeproj -scheme YouNew -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/younew-leiden-build ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build-for-testing
```

Ten Node tests and fifteen Python tests passed. Both deterministic exporter checks and the unchanged selection check passed. The actual Debug `.app` contains all 36 expected WebP files with matching SHA-256, and its candidate JSON matches the export byte-for-byte. No newly fetched photos are bundled. Xcode build-for-testing compiled app, unit-test and UI-test targets. Final build: **TEST BUILD SUCCEEDED**, with no `warning:` or `error:` diagnostics in `/tmp/younew-travel-local-build.log`.

Xcode tools were attached to the old iCloud checkout, so the build used the explicit correct `/Users/ivan/YouNew/YouNew.xcodeproj` path. The command-line developer directory initially pointed at CommandLineTools; the per-command environment override selected Xcode without changing global configuration. The sandbox initially blocked SwiftPM; the authorized build rerun outside that restriction succeeded. `simctl list runtimes` returned an empty list. No Simulator launch, screenshots, runtime test execution or device QA is claimed. Runtime QA remains mandatory: photo rendering, Saved persistence, collection navigation, Apple Maps, ticket destinations, EN/NL, small screens, themes, VoiceOver, memory and offline behavior. No production, TestFlight, App Store Connect, signing or merge action occurred.

### Next safe batch: replacement photo sources

Prepared five new **source-metadata records only**, in `DataProject/research/travel-media-followup-20261115/`, using `scripts/prepare-travel-media-followup.py`. It reuses the existing cached, bounded, robots-aware client and never modifies earlier evidence or the approved selection. All five Commons pages supplied explicit author/license metadata and source-page SHA-256. No image binaries or derivatives were downloaded; these are not five ready or approved photos.

| Existing entity | Candidate | Review limitation |
|---|---|---|
| Foam | Amsterdam Keizersgracht 0609 001.JPG; Janericloebe; CC BY 3.0 | Narrow facade crop, visual check pending; entity primary source remains unresolved |
| Huis Marseille | Huismarseille.jpg; J.M. Luijt; CC BY 3.0 | Alternative to oversized earlier source; visual check pending |
| Markthal | Markthal - Rotterdam.jpg; Erik Zachte; CC BY-SA 4.0 | Check building prominence and crop |
| Museumpark VONK | PreHistorisch Dorp.jpg; author field Eindhoven Museum; CC BY-SA 4.0 | EXIF names Freekje Groenemans Fotografie; rights clarification required; 2016 view is not evidence of current VONK appearance |
| Parktheater Eindhoven | 13-06-29-eindhoven-50mm-52.jpg | Author/license preserved in JSON; visual identity and suitability pending |

All five remain `needs_review`, `publicationAuthorized: false`, `reviewerId: null`, with empty image file arrays. The preparation is idempotent and its five records were checked for license/source metadata and review isolation. Disk space fell to approximately 190 MiB during compilation (later recovered to approximately 386 MiB); no large media fetch or Simulator installation was attempted. Continue visual/rights checks and source resolution after ensuring sufficient workspace capacity. Do not regenerate or reapprove the exact PR #71 subset.

## Follow-up from PR #73: Release isolation and two review batches (2026-11-15)

Branch `feature/travel-review-release-isolation-20261115`, based on `512abc1`. Existing approved selections, historical research, owner receipts and all `YouNew/` runtime bytes remain unchanged. No new approval, production deployment or store action.

### Release safety

Release target now excludes `younew-approved-local-test.json` and `approved-travel-*.webp` through `EXCLUDED_SOURCE_FILE_NAMES`. The device Release effective settings confirm these patterns. This applies to resource build phases per [Apple's build settings reference](https://developer.apple.com/documentation/xcode/build-settings-reference).

An additional post-resource build phase runs `scripts/check-ios-release-resources.sh`. In Release it scans the physical product, rejects either forbidden filename pattern, and requires the bundled production JSON to match the governed source. It never silently deletes files. Debug retains the approved local candidate. Tests verify this is the only project configuration change besides adding the guard; Bundle ID, Team, signing and entitlements are unchanged.

`build-for-testing` for the correct checkout succeeded, with no error/warning diagnostics in `/tmp/younew-release-isolation-debug-build.log`. The guard was also invoked against the **real existing Debug .app under Release rules** and correctly rejected it. Positive and negative resource-package fixtures passed. A full Release binary/archive was **not built or inspected**: available space is insufficient. An attempted Xcode dry-run failed because this Xcode no longer supports `-dry-run`; this is not presented as a successful Release check. Before distribution, a real Release build and package inspection remain mandatory. No runtime visual QA was performed.

### Batch 1: eleven source/address follow-ups, five photo candidates

The nine unresolved primary-source records and two ambiguous addresses were investigated using alternate official/operator pages. Five pages were accessible: three support existing EN/NL descriptions (Oude Sterrewacht via Hortus, ARTIS-Micropia via ARTIS, Strijp-S via district operator), and two clarify address evidence. Existing descriptions are referenced by immutable file/hash, not recreated.

- Muziekgebouw: the property operator's venue directory explicitly identifies **Heuvel Galerie 140, 5611 DK Eindhoven**. Its exact BAG address yields a new review-only address centroid. The prior failed Heuvel match remains untouched. This is property-operator corroboration, not a surveyed entrance.
- Verzetsmuseum: the official visitor page still says Plantage Kerklaan 61; BAG suffix ambiguity remains unresolved. No coordinate selected.
- Six primary sources remain unresolved: Foam, Museum Van Loon, Mauritshuis, Kunstmuseum, Madurodam (robots disallowed/unavailable), and Parktheater (redirect loop). Search discovery alone did not override the fetch/publication gate.
- Four new, small WebP review derivatives were prepared from the previously identified Commons alternatives, with original author/license/source metadata, download and derivative SHA-256. All four were actually viewed locally: Huis Marseille facade, Markthal facade, Parktheater facade/sign, Foam facade/sign. They are **not activated**. Foam is a narrow 250px image, suitable only for consideration as a gallery/detail image; its primary source remains blocked. Parktheater's primary source also remains unresolved. Huis Marseille and Markthal are image candidates for existing Debug cards, pending owner review and crop QA.
- VONK was not downloaded or proposed: the Eindhoven Museum author field conflicts with EXIF credit to Freekje Groenemans Fotografie. No permission was inferred, and no contact was sent. Historical appearance also needs qualification. The contradiction remains unresolved.

New evidence lives only in `DataProject/research/travel-gap-review-20261115/`. The earlier five metadata records and all approved photos are immutable.

### Batch 2: ten missing coordinates using approved addresses

Reused the current approved addresses and their original source-check dates. Nine exact BAG matches: Bikini Bikini, In den Doofpot, Verboden Toegang, Het Prentenkabinet, Oudt Leyden, Chabot Museum, Sonnenborgh, VVV Leiden and Café Laken. No restaurant address was fetched again unnecessarily.

Fotomuseum Den Haag remains held: BAG uses `'s-Gravenhage`, while the approved address uses Den Haag. The strict matcher does not silently introduce locality aliases. This is an alias-validation task, not permission to choose an approximate point. Each accepted point preserves BAG identity, response hash, CC0 provenance, address evidence and the address-centroid accuracy label.

| Layer | Records | Bundled/new photos | Coordinates | Collections |
|---|---:|---:|---:|---:|
| Approved local / Debug, unchanged | 85 | 36 | 40 | 6 |
| Production artifact / intended Release, unchanged | 12 | 4 | 7 | 0 |
| New review this iteration | 3 existing EN/NL pairs with resolved source evidence | 4 derivatives, 0 approved | 10 new exact matches, 0 approved | 0 |

The review coordinate count is nine batch-2 matches plus Muziekgebouw. Approved coverage remains 36/85 photos (42.4%) and 40/85 coordinates (47.1%). Approval of all ten new coordinate candidates would yield 50/85 (58.8%); this is a projection, not runtime content. Area/park applicability needs separate entrance/geometry review. The 80% goals are not met.

### Reproduction and limits

```sh
python3 scripts/prepare-travel-gap-review.py
python3 scripts/finalize-travel-gap-review.py
python3 scripts/prepare-travel-gap-coordinates.py
python3 scripts/prepare-travel-gap-media.py
python3 -m unittest scripts/tests/test_ios_release_resources.py scripts/tests/test_travel_gap_review.py scripts/tests/travel_selection_test.py scripts/tests/travel_expansion_review_test.py
node scripts/export-approved-ios-places.mjs --check
node scripts/export-approved-ios-places.mjs --local-test --check
```

Twenty-four Python checks and ten existing Node checks passed (34 total). New checks cover exact BAG address/point equality, media/source SHA-256, review isolation, EN/NL record bindings, unchanged runtime/approval bytes, Release configuration scope and actual guard behavior. Both exporter checks passed. Review-only files require no additional iOS build.

Disk capacity is a real limit: approximately 298 MiB initially, then temporary-file writes failed with `ENOSPC`. Only known compiler intermediates from this task's `/tmp/younew-leiden-build/.../Objects-normal/arm64` were removed (about 346 MiB); the built app and logs were retained. No user files or unrelated caches were removed. Each image download checks a 200 MiB reserve; four small derivatives were prepared while above it. Space subsequently fell again to approximately 184 MiB, so further binary preparation is paused. Do not retry failed sources in loops or install Simulator runtimes on this nearly full volume.

Next safe work: free workspace capacity through owner-controlled storage management, then Amsterdam's missing address evidence and licensed images for already prepared objects; validate the Den Haag locality alias, resolve six source gates and the VONK rights conflict. New data stays in review. Before release, build and inspect an actual Release package and complete runtime QA.
