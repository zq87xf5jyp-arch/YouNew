# Final validation

Recorded: 2026-07-21 (Europe/Amsterdam)

## Executive result

This is a candidate Build Week validation report, not an App Store release certification.

The app builds successfully in Xcode. The critical Map -> root tab delivery defect has a documented root cause, a local implementation fix, and earlier finalized targeted post-fix evidence. The current attempt to rerun a larger UI batch in this session was blocked by Simulator/resource exhaustion before a valid `.xcresult` could be finalized, so it is not counted as a product failure and not counted as a pass.

## Current verified in this session

| Gate | Current result | Evidence |
|---|---|---|
| Build | PASS | Xcode `BuildProject`, elapsed `61.234s`, log `/var/folders/wq/v9db0mrx0j71cw3k3c4btgm80000gn/T/ActionArtifacts/EA0F939B-AB2A-4BDA-BF9F-AE7B7C1AE442/BuildProject/BuildProject-Log-20260721-114112.txt` |
| Test inventory | RECORDED | Active plan `YouNew`: 547 enabled tests, 0 disabled; 460 `YouNewTests`, 87 `YouNewUITests`; full list `/var/folders/wq/v9db0mrx0j71cw3k3c4btgm80000gn/T/ActionArtifacts/EA0F939B-AB2A-4BDA-BF9F-AE7B7C1AE442/GetTestList/49FC18D7-2AC8-49D9-8692-E7BAFE73C835.txt` |
| UI rerun attempt | ENVIRONMENT BLOCKED | Xcode Navigator issues show Simulator launch failures: `Launchd job spawn failed. Resource temporarily unavailable`; the new result bundle lacked `Info.plist` and is not a valid finalized result |
| Direct shell `xcodebuild` | ENVIRONMENT BLOCKED | CoreSimulatorService/package diagnostics permission failures from sandboxed shell; not used for product verdict |

## Historical or earlier finalized evidence retained

| Gate | Result | Evidence |
|---|---|---|
| Clean control UI baseline before fix | Interrupted, not finalized | `BuildWeekFinal/UI_BASELINE.md`; incomplete bundle `/private/tmp/YouNewCleanClonePostFix.L8VF0h/FullUIFinal.xcresult` had no `Info.plist` |
| Latest earlier finalized full UI bundle | 87 total, 84 passed, 3 failed, 0 skipped | `/private/tmp/YouNewCleanCloneEfd.20260720/FullUIFinal.xcresult`; documented in `BuildWeekFinal/UI_BASELINE.md` |
| Map/root tab blocker before fix | FAIL | `MapChipUITests/testRootTabNavigationLatency`: first tap on Home not delivered while Map stayed selected |
| Map/root tab targeted after fix | PASS | `/private/tmp/YouNewBuildWeekMapOverlayFix.xcresult`; 3 total, 3 passed, 0 failed, 0 skipped; 10/10 Map <-> Home transitions delivered on first tap |
| Guide placeholder targeted after fix | PASS | `/private/tmp/YouNewBuildWeekContentPrimaryPostFix.xcresult`; `ContentCompletionRuntimeUITests/testPrimaryTabsRenderCompletedSurfacesWithoutPlaceholderCopy` |
| Accessibility search targeted after fix | PASS | `/private/tmp/YouNewBuildWeekAccessibilitySearchPostFix.xcresult`; 5/5 repetitions passed |
| Unit suite | PASS in prior finalized validation | 460/460 documented in `BuildWeekFinal/REMAINING_FAILURES.md`; not rerun in this resource-exhausted final attempt |
| Structural DataProject/import | PASS in prior validation | Documented in `BuildWeekFinal/REMAINING_FAILURES.md`; includes `cities-v0.1.0` dry-run for 5/5 cities |
| External link health | FAIL in prior validation | 18 confirmed HTTP 404 from 2,494 URLs, documented in `BuildWeekFinal/REMAINING_FAILURES.md` |

## Critical blocker status

Map/root tab blocker: fixed and targeted-verified.

The root cause was event-delivery overlap between the Map root scroll/gesture surface and the root tab bar installed via `safeAreaInset`. The fix keeps the safe-area layout reservation noninteractive and hosts the interactive tab bar as a frontmost root overlay. It does not disable map hit testing, does not change test thresholds, and does not reduce UI coverage.

Primary evidence: `BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md`.

## Main demo validation status

Recommended demo path:

1. Home opens.
2. AI Assistant opens from the existing app controls.
3. Use the local deterministic guided assistant for the bounded newcomer journey: BSN -> address -> DigiD.
4. Open the related guide/content route.
5. Show at least one official source.
6. Open Map.
7. Return through the root tab bar.
8. Open one imported city such as Amsterdam, Rotterdam, Den Haag, Utrecht, or Eindhoven.

Automation evidence exists for the assistant fallback and map/root pieces, but the final manual smoke and screenshots could not be completed in this session because Simulator app launch was resource-blocked.

## Static QA

The full static QA script was not rerun in the final attempt because the shell could no longer create new processes (`Resource temporarily unavailable`). Prior validation recorded 43/44 known static gates passing, with the remaining data-health failure caused by 18 governed broken external links. Do not claim all static QA passes.

## Data/import

Safe claim: structural DataProject/import validation passes in the prior validation set, including `cities-v0.1.0` importing five cities.

Unsafe claim: all source links are healthy. Fresh external-link health has known 404 failures.

## Secret scan

Prior scoped secret scan did not find high-confidence secrets. This final session did not rerun the scan because process creation became resource-blocked. Owner should rerun before any commit or upload.

## Broken references

Known broken external references remain: 18 HTTP 404 links in the prior data-health gate. These should be disclosed or remediated before public release. For Build Week demo, avoid paths that depend on those broken URLs.

## Final verdict

Overall readiness: candidate demo build, not production-ready.

The technical submission can honestly claim a native SwiftUI app, Codex-assisted implementation workflow, deterministic local guided assistant, interactive Netherlands map, governed content/import platform, five imported cities in `cities-v0.1.0`, and broad QA automation. It must not claim GPT-5.6 powers the in-app assistant, all tests pass, all media rights are complete, or App Store/TestFlight parity.
