# Content and `cities-v0.1.0` Evidence

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Scope: current local working tree

## Executive conclusion

The local working copy contains a five-city `cities-v0.1.0` release marked published and wired into a production runtime JSON. The five cities are Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven. The release/import gates report five eligible/imported records, zero exclusions, zero technical duplicates, and zero broken relations.

However, the entire `DataProject/` tree and `YouNew/Resources/Data/younew-runtime-data.json` are untracked. Therefore the release is **VERIFIED locally but PARTIAL as a repository/public claim**: a clean clone of `HEAD` will not contain this evidence or runtime payload.

No release fingerprint or internal entity identifier is reproduced in this report.

## Release manifest

| Fact | Status | Evidence |
|---|---|---|
| Release | VERIFIED | `DataProject/reports/release-manifests/cities-v0.1.0.json:3-18`. |
| Version | VERIFIED | `0.1.0`, same manifest. |
| Status | VERIFIED locally | `published`, same manifest. |
| Generated/publication evidence date | VERIFIED locally | Manifest generated `2026-07-18T09:35:32Z`; release metadata records publication on 2026-07-14: `DataProject/releases/releases.json:36-56`. |
| Governed/published/verified records | VERIFIED | Five records in all three categories: manifest `:20-36`. |
| Official sources | VERIFIED as metadata | Five: manifest `:20-36`. Live semantic accuracy was not re-reviewed item-by-item in this audit. |
| QA gates | VERIFIED as manifest state | Seven gates marked passed: manifest `:20-36`. |
| Approver | PARTIAL | An explicit-approval marker is present at `DataProject/releases/releases.json:36-56`. Its internal value is intentionally omitted. The untracked metadata is not independent identity/session proof. |
| Fingerprint | VERIFIED present, intentionally omitted | `DataProject/releases/releases.json:36-56`; import preview also contains hashes. |

The milestone metadata is internally stale: `DataProject/milestones/WP-06/M1.json:5-23` still describes QA/explicit approval rather than a consistently finalized published state. This lowers confidence from fully consistent to PARTIAL.

## Target cities

`DataProject/batches/WP-06/M1-priority-cities-001.json` contains all expected records:

| City | Status | Evidence |
|---|---|---|
| Amsterdam | VERIFIED | title/record at `:29-35`; lifecycle in the same batch. |
| Rotterdam | VERIFIED | `:108-114`. |
| Den Haag | VERIFIED | `:187-193`. |
| Utrecht | VERIFIED | `:266-272`. |
| Eindhoven | VERIFIED | `:345-351`; published/verified lifecycle example at `:399-414`. |

The batch records a five-record target and publication count plus passed build/static/duplicate/source/media/search/AI gates at `:3-25`.

## Import preview

`DataProject/reports/import-preview.json:475-583` is a deterministic preview for the selected release.

| Metric | Current local value | Status |
|---|---:|---|
| Selected releases | 1 | VERIFIED |
| Eligible records | 5 | VERIFIED |
| Imported/mapped records | 5 | VERIFIED |
| Excluded/skipped records | 0 | VERIFIED |
| Legacy conflicts discovered/migrated | 5 / 5 | VERIFIED |
| Technical duplicates removed | 0 | VERIFIED |
| Broken relations | 0 | VERIFIED |
| Production artifact changed in preview | false | VERIFIED; expected for preview |

The preview contains fingerprints/hashes. They are intentionally not published here.

## Runtime payload

`YouNew/Resources/Data/younew-runtime-data.json` contains 188 total entities in the current working copy. Release metadata at the top-level `releases` array identifies `cities-v0.1.0`; the five corresponding city entities are present and marked published/verified. Evidence markers appear around `:1868,1962,2056,2150,2244`, with release summary around `:15699,15749-15771`.

The latest local content report decomposes the runtime into 183 Amsterdam records plus five city records: `Audit/REAL_DEVICE_CONTENT_AUDIT_2026-07-18.md:9-16`. Runtime loader enforcement is in `YouNew/Services/DataProjectRuntimeLoader.swift:20-64`; mapping/media verification follows at `:73-193`.

Tests exist for exact city replacement, no duplicates, Search/AI/Home/Map visibility, and corrupted-payload rejection: `YouNewTests/PublishedCitiesDataReleaseTests.swift:7-60`. In the fresh frozen-snapshot run on 2026-07-19, all three `PublishedCitiesDataReleaseTests` passed; the overall unit suite still failed four separate knowledge-index/partner-governance tests. Those failures do not invalidate the narrow city-release test result, but they do block a broader claim that all governed knowledge is complete. See `TEST_AND_QA_EVIDENCE.md`.

Runtime visibility is also not fully green: the current 86-test frozen UI run failed `PublishedCitiesRuntimeUITests/testPublishedAmsterdamMuseumFlowsFromSearchToGuideAndSaved()` because the expected Rijksmuseum result was missing from Search. Other city/assistant/map UI paths ran, but the release must not be described as end-to-end verified across all surfaces until that current failure is resolved and rerun.

## Current structural validation

The following commands were executed on a temporary copy of the current working tree so generator scripts could not overwrite user files:

| Command | Result | Measured evidence |
|---|---|---|
| `python3 scripts/data-project-qa.py` | PASS | 17 work packages, 7 milestones, 7 releases, 27 batches, 450 governed records. |
| `python3 scripts/data-project-import-static-qa.py` | PASS | Deterministic preview; schema/release/publication gates; stable IDs; duplicate, geography and relation checks; production approval/exclusion; corrupt-data fallback; Search/AI/Saved bridge. |
| `python3 scripts/generate-data-dashboard.py` | PASS in snapshot | 450 records; regenerated snapshot reported 188 published and 100% structural quality. |
| `python3 scripts/data-dashboard-static-qa.py` | PASS | 14 volume targets, 13 breadth axes, 17×9 coverage dimensions. |
| `python3 scripts/generate-data-observability.py` | PASS in snapshot | 450 governed records, 7 manifests, 100% freshness; input mutation none. |
| `python3 scripts/data-observability-static-qa.py` | PASS | 8 consumers, 450 usage/freshness rows, 7 manifests, read-only contract. |
| `python3 scripts/data-health-gate.py` | PASS | 0 structural issues; existing link evidence covers 1,141 URLs and reports 0 confirmed broken. This was not a new live network crawl. |
| `python3 scripts/data-project-workflow-static-qa.py` | PASS | Nightly schedule, retention, health gate and no-auto-publish policy. |

Temporary snapshot: `<TEMP_DIR>/BuildWeekAudit/StaticSnapshot` (local audit artifact; not a repository deliverable).

## Historical content audit and current delta

### 2026-07-17 baseline

Source: `Audit/REAL_DEVICE_CONTENT_AUDIT_2026-07-17.md:3-66`.

| Metric | Historical value | Classification |
|---|---:|---|
| Audited sections | 23 | HISTORICAL REPORT EVIDENCE |
| PASS | 2 | HISTORICAL |
| PARTIAL | 14 | HISTORICAL |
| EMPTY | 7 | HISTORICAL |
| Governed records | 450 | Still corroborated structurally |
| Published records | 5 | Superseded by current local runtime |
| Media assets | 587 | Still reported in newer local audit |
| Average governed-domain coverage | 5.6% | HISTORICAL rubric |

The report verdict was NOT READY and explicitly said its physical run was interrupted without a valid final xcresult. These numbers are not current pass results.

### 2026-07-18 post-import report

Source: `Audit/REAL_DEVICE_CONTENT_AUDIT_2026-07-18.md:3-72`.

| Metric | Newer local report | Delta/meaning |
|---|---:|---|
| Production runtime records | 188 | 5 → 188 (183 Amsterdam + five cities) |
| Governed records | 450 | unchanged |
| Media assets | 587 | unchanged |
| Official sources | 188 | 5 → 188 reported |
| PASS | 2 | unchanged |
| PARTIAL/fixed-limited | 20 | rubric/category changed |
| EMPTY | 1 | 7 → 1 |
| Application completeness | 52.2% | newer explicit PASS/PARTIAL/EMPTY rubric |

The 5.6% and 52.2% values are **not strictly comparable**: the denominator and scoring rubric changed. The newer report remains NOT READY because Hotels is empty, only Amsterdam has deep governed content, national batches remain unpublished, and the final physical visual traversal was blocked by device authentication.

`DataProject/reports/dashboard.json` is stale relative to the current runtime: it was generated 2026-07-15 and still reports five published records, although its 450 governed/587 media counts remain consistent with the reports. The temporary regeneration during this audit produced 188 published in the snapshot but did not alter the repository.

## Portability and public-claim boundary

- `DataProject/` is untracked.
- `YouNew/Resources/Data/younew-runtime-data.json` is untracked.
- `.github/workflows/data-project-health.yml` is untracked.
- The current app uses filesystem-synchronized Xcode groups, so files on disk affect what compiles.

Publicly safe claim **after committing and clean-clone verification**:

> The repository contains a governed five-city release for Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven, with deterministic import checks for eligibility, duplicates, relations, publication status, and runtime fallback.

Current claim:

> The local working copy contains that implementation and evidence, but Git portability is not yet verified.
