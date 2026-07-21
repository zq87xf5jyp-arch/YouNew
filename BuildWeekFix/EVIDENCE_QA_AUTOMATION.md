# Evidence packet — QA automation

Status: **VERIFIED clean-clone build, unit, static, and backend gates / UI RED**

Evidence date: 2026-07-21 (Europe/Amsterdam)

## 2026-07-21 evidence boundary update

The `61e7ce11` 82/87 result below is a historical diagnostic, not a result for
the current product/test source. The last fully closed clean-clone UI snapshot is
`efd1a7c50bf7b5e2f82be047b084b6d73cb009a7`, **84/87 RED**. Current source
`da8c3fe22e7a5d99b2187aab1141700b2d34f508` requires a new complete serial UI
aggregate; focused tests never replace it.

An offline clean-clone structural static run passed, but that does not clear the
separately captured current network Data Health finding: 18 confirmed broken URLs
in shipped runtime data. The link-health blocker remains red until a reviewed
release remediation and fresh network check close it.

## Original problem

A broad SwiftUI product with local content, navigation, media, accessibility, search, AI workflows, and map behavior needed repeatable gates instead of relying on visual spot checks or historical test totals.

## Product requirement

Keep independent build, unit, static, import, accessibility, and UI gates; classify failures by root cause; preserve assertions and user functionality; and publish only closed, reproducible result totals.

## Implementation

- Shared Xcode schemes separate app build, unit tests, and UI tests.
- Swift Testing suites cover AI, routing, repositories, release data, privacy, media, map geometry, and corruption fallback.
- UI suites cover navigation, accessibility, localization, content completion, map, Search, published cities, and local assistant workflows.
- `scripts/run-static-qa.sh` aggregates 40 code, content, accessibility, media, data, privacy, and release checks.
- `BuildWeekFix/TEST_REMEDIATION.md` records each original failure, classification, fix, files, rationale, and rerun state without skipped tests, removed assertions, or added sleeps.

## Files

- `YouNew.xcodeproj/xcshareddata/xcschemes/YouNew.xcscheme`
- `YouNew.xcodeproj/xcshareddata/xcschemes/YouNewUnitTests.xcscheme`
- `YouNew.xcodeproj/xcshareddata/xcschemes/YouNewUITests.xcscheme`
- `YouNewTests/`
- `YouNewUITests/`
- `scripts/run-static-qa.sh`
- `BuildWeekFix/TEST_REMEDIATION.md`

## Tests

- Authoritative clean-clone Xcode unit aggregate: **460/460 passed, 0 failed, 0 skipped,
  0 expected failures** on iPhone 17 Pro / iOS 26.5.
- Authoritative clean-clone aggregate static rerun: **40/40 commands passed** from
  an initially report-free clone; DataProject import validation also passed.
- The static PASS is bounded: visible-image remote QA checked no cached URLs and
  made zero network requests; observability reported 0.0% usage coverage and did
  not establish migration progress.
- Audit baseline UI run: **80/86 passed, 6 failed, 0 skipped**. The historical
  serial clean-clone run at `61e7ce11` is **82/87**, with 5 failed,
  0 skipped, and 0 expected failures. Its retained failures are a municipality Back
  path, a family-route synthetic tap, root-tab latency, healthcare map focus, and
  named fallback launch state. The explicit local fallback passed in a later bounded
  2/2 Assistant diagnostic, but no focused result replaces the red aggregate.

## Measurable result

Stage 2 moved the original unit gate from 446/450 to 450/450 and static QA from
35/40 to 40/40 while retaining the original tests and assertions. The final suite
then expanded; the current authoritative Xcode inventory is 460 tests and passed
completely in the clean clone. Its console also reports a 453-test Swift Testing
sub-summary; seven XCTest cases make up the aggregate difference. The final
historical `61e7ce11` UI inventory is 82/87 and remains red. Its latency failure is
102.043 ms against the unchanged `< 100 ms` contract; the other retained failures
remain in the ledger rather than being hidden by retry or relaxation.

## Owner decision

The owner must define the mandatory physical-device, accessibility, language, and performance matrix and approve submission only after the full UI and clean-clone gates close green or an explicitly documented environment blocker is accepted.

## Limitations

- Result bundles are intentionally local artifacts; portable totals, commands, and
  commit linkage are recorded in `BuildWeekFix/CLEAN_CLONE_PROOF.md`.
- The historical `61e7ce11` full UI status is red at 82/87. No physical-device or complete
  VoiceOver/contrast/performance matrix is proven.
- A passing static matcher proves a source contract, not runtime behavior.
- GitHub CI and clean-clone results are separate gates and are not implied by local success.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew has broad automated unit, UI, accessibility, routing, media, content, and
release checks. Historical and bounded current evidence supports clean-clone build,
460/460 unit, offline 40/40 static, DataProject/import, and mocked backend-contract
gates. It does not
claim GitHub CI, physical-device certification, live GPT-5.6, or production readiness.

## Screenshot or log still needed

Preserve redacted `xcresult` summaries for the final build, unit, and full UI runs; the exact 40-command static transcript; clean-clone commands and hashes; and final screenshots for Accessibility XXXL, Dark Mode, map interaction, Search routing, and the named assistant demo.
