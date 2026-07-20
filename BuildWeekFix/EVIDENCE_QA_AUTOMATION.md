# Evidence packet — QA automation

Status: **VERIFIED Stage 2 unit/static snapshot / expanded final reruns pending**

Evidence date: 2026-07-20 (Europe/Amsterdam)

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

- Last closed complete Stage 2 unit rerun: **450/450 passed, 0 failed, 0
  skipped, 0 expected failures** on iPhone 17 Pro / iOS 26.5. Additional Build Week
  AI/demo tests were added afterward and have focused passing evidence; the expanded
  complete suite still requires a final-snapshot rerun.
- Last closed aggregate Stage 2 static rerun: **40/40 commands passed**;
  DataProject import validation also passed. Focused AI QA passed after later changes,
  but the final aggregate rerun remains a gate.
- Audit baseline UI run: **80/86 passed, 6 failed, 0 skipped**. One new local
  fallback UI test passed independently. Fixes are documented, but closed reruns of
  the original failures and complete post-fix UI suite are still pending; no green
  UI claim is made.

## Measurable result

Stage 2 moved the original unit gate from 446/450 to 450/450 and static QA from
35/40 to 40/40 while retaining the original tests and assertions. Later tests do
not invalidate that historical snapshot, but they expand the final gate. UI
improvement is not measurable until the closed post-fix summaries exist.

## Owner decision

The owner must define the mandatory physical-device, accessibility, language, and performance matrix and approve submission only after the full UI and clean-clone gates close green or an explicitly documented environment blocker is accepted.

## Limitations

- The closed Stage 2 unit result bundle is stored outside the repository; a portable
  redacted summary and a new final-snapshot result still need to be captured.
- Full post-fix UI status is pending, and no physical-device or complete VoiceOver/contrast/performance matrix is proven.
- A passing static matcher proves a source contract, not runtime behavior.
- GitHub CI and clean-clone results are separate gates and are not implied by local success.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew has broad automated unit, UI, accessibility, routing, media, content, and
release checks. The current evidence supports the closed Stage 2 unit/static
snapshot and focused later AI/fallback checks; it does not yet support green
expanded final unit/static, full UI, CI, clean-clone, or production-readiness claims.

## Screenshot or log still needed

Preserve redacted `xcresult` summaries for the final build, unit, and full UI runs; the exact 40-command static transcript; clean-clone commands and hashes; and final screenshots for Accessibility XXXL, Dark Mode, map interaction, Search routing, and the named assistant demo.
