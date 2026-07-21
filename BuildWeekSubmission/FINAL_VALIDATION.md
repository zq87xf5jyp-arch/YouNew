# Final validation

Recorded: 2026-07-21 (Europe/Amsterdam)
Candidate source: branch `main`, HEAD `7a1f6bc8fcffac84e5798338380bb97aca815b3d`
Workspace: dirty; this pass performed no commit, push, remote mutation, deploy, upload, or submission

## Executive result

**Build Week candidate readiness: 84/100.**

The bounded judge demo is supportable, but this is not an all-green or production-ready build. Clean build, 460 unit tests, structural import validation, the base deterministic Assistant flow, the Map/root delivery fix, five-city traversal, and eight simulator screenshots are verified. The full UI suite is 79/87, static QA is 43/44 known gates, and three isolated UI failures remain reproducible.

Score details: [`../BuildWeekFinal/GLITCH_READINESS.md`](../BuildWeekFinal/GLITCH_READINESS.md).

## Current verified gates

| Gate | Result | Evidence |
|---|---|---|
| Clean build | **PASS** | `/private/tmp/YouNewBuildWeekCleanBuildPostFixFinal.xcresult`; [`BUILD_FINAL_SUMMARY.json`](../BuildWeekFinal/artifacts/BUILD_FINAL_SUMMARY.json) |
| Unit | **460/460 PASS**, 0 failed, 0 skipped | `/private/tmp/YouNewBuildWeekUnitFinalPreserved.xcresult`; [`UNIT_FINAL_SUMMARY.json`](../BuildWeekFinal/artifacts/UNIT_FINAL_SUMMARY.json) |
| Static QA | **43/44 known checks PASS; 1 FAIL** | Sole failure: `data-health-gate.py`, `governed_broken_links=18` |
| Full UI suite | **79/87 PASS**, 8 failed, 0 skipped | `/private/tmp/YouNewBuildWeekFullUISerialFinal.xcresult`; [`UI_FINAL_SUMMARY.json`](../BuildWeekFinal/artifacts/UI_FINAL_SUMMARY.json) |
| Eight-failure isolated rerun | **5/8 PASS**, 3 failed, 0 skipped | `/private/tmp/YouNewBuildWeekEightFailuresRerun.xcresult`; [`UI_FAILURE_RERUN_SUMMARY.json`](../BuildWeekFinal/artifacts/UI_FAILURE_RERUN_SUMMARY.json) |
| Map/root delivery | **PASS in serialized and manual checks** | 10/10 first-action transitions in `/private/tmp/YouNewBuildWeekRootLatencySerialFinal.xcresult`; manual metric `sequence=1;tab=home;delayMs=95.108` |
| Root latency ceiling | **FAIL in latest isolated rerun** | One sample `191.158 ms`, unchanged requirement `<100 ms` |
| Map calibration | **99/100, then unchanged repeat 100/100** | `/private/tmp/YouNewBuildWeekMapCalibrationSerialFinal.xcresult`; `/private/tmp/YouNewBuildWeekMapCalibrationSerialRepeat.xcresult` |
| Base local Assistant | **PASS** | BSN → address → DigiD, local fallback, and health-insurance guide are green in current/targeted evidence |
| Assistant selected-city shortcut | **FAIL** | `Open Leiden` does not reach city detail in the isolated workflow; excluded from demo |
| Published cities traversal | **PASS** | Five cities traverse Home/Search/AI/Map/Guide/detail in the isolated rerun |
| First Steps accessibility | **Locally fixed; composite test still FAILS later** | `firstSteps.screen` is exposed and the detail/back path advances; the same long test later times out on Guide scroll to Transport in `/private/tmp/YouNewBuildWeekGuideFixFinal2.xcresult` |
| DataProject/import | **PASS** | 17 work packages, 7 milestones, 7 releases, 27 batches, 450 records; `cities-v0.1.0` 5/5 |
| Scoped secret scan | **PASS WITH SCOPE** | 1,039 files, 23,040,033 bytes, 0 high-confidence hits; [`FINAL_DATA_SECURITY_SUMMARY.json`](../BuildWeekFinal/artifacts/FINAL_DATA_SECURITY_SUMMARY.json) |
| Internal generated-site references | **PASS** | 14,953 references across 229 existing generated HTML files |
| External URL health | **FAIL** | 2,494 checked: 1,821 reachable, 18 confirmed broken, 623 restricted, 32 transient |
| Simulator visual smoke | **8/8 inspected** | [`../BuildWeekFinal/SCREENSHOT_MANIFEST.md`](../BuildWeekFinal/SCREENSHOT_MANIFEST.md) |

## Full UI failures

The finalized aggregate contains these eight failures:

1. Guide category composite routing.
2. Leisure/education typed route.
3. Discovery chip route.
4. Transport chip route.
5. Root-tab latency.
6. Published-cities traversal.
7. Assistant selected-city route.
8. Assistant health-insurance guide.

The unchanged isolated rerun passed items 2, 3, 4, 6, and 8. Items 1, 5, and 7 remain open. Isolated passes are supplementary and do not replace the honest 79/87 aggregate.

## Map/root blocker verdict

The original product blocker was event-delivery overlap between the Map's full-window surface and the root tab bar hosted through `safeAreaInset`. The implementation retains a noninteractive safe-area reservation and hosts the sole interactive bar in a frontmost root overlay. Map hit testing, province/city routes, AI overlay, test coverage, and expected values remain intact.

Verdict: **delivery blocker fixed in the tested simulator configuration; latency risk remains**.

## Main demo smoke

Use this bounded path:

1. Open Home.
2. Open the Assistant and explicitly describe it as a local deterministic guided assistant.
3. Run BSN → address available → include DigiD.
4. Open the verified guide/source action.
5. Open Map and return Home using the root tab bar.
6. Open one of the five imported city details through Home, Search, or Map.

Do not use the Assistant `Open Leiden` shortcut or the long Guide-to-Transport composite path. No evidence proves live OpenAI inference or GPT-5.6 inside the app.

## Repository state

- Branch: `main`, tracking `origin/main`.
- HEAD: `7a1f6bc8fcffac84e5798338380bb97aca815b3d`.
- Reachable commits: 66.
- Configured remote: `origin` → `https://github.com/zq87xf5jyp-arch/YouNew.git`.
- Worktree: dirty; no staged files were created by this pass.
- The remote and commit history existed before final validation; their public visibility/synchronization was not verified.

## Historical — not current

- User-provided prior audit: unit 446/450, static 35/40, UI 80/86.
- These values must not be presented as current results.

## Remaining blockers and limitations

1. Full UI is not green: current aggregate 79/87.
2. Three failures reproduce in isolation: Guide scroll/UI query, root latency, Assistant selected-city route.
3. Static QA is not green: 18 confirmed broken governed URLs.
4. Media rights are only partially confirmed.
5. TestFlight/App Store parity is unverified.
6. No live GPT-5.6/OpenAI runtime is proved.
7. No complete physical-device, VoiceOver, OS/device matrix, soak, or production certification exists.
8. The exact dirty workspace has not been reproduced from a clean clone.

## Claim boundary

Safe: native SwiftUI app; deterministic local guided Assistant; interactive Netherlands map; fixed root-tab delivery; governed content/import platform; `cities-v0.1.0` five-city import; clean build PASS; unit 460/460; static 43/44 known gates; full UI 79/87; structural data/import PASS; documented Codex-assisted workflow.

Unsafe: all tests pass; all links work; GPT-5.6/live OpenAI powers the app; all content/media is complete or cleared; production ready; verified TestFlight/App Store parity; verified public GitHub synchronization.
