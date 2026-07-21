# Build Week final UI baseline

Recorded: 2026-07-21 (Europe/Amsterdam)

## Baseline decision

The control UI run is no longer active, but it did **not** finish normally. Its result bundle was left in staging form and has no `Info.plist`, so it must not be reported as a completed 87-test result. This baseline records the completed test cases from the runner log, the interrupted test, and the latest earlier finalized bundle separately.

No application or test source was changed before this file and the preserved log artifacts were created.

## Control run identity

- Command: `xcodebuild test -project YouNew.xcodeproj -scheme YouNewUITests -destination platform=iOS Simulator,id=1D538DCE-A487-40C2-801F-811D44D6397D -derivedDataPath /private/tmp/YouNewCleanClonePostFix.L8VF0h/DerivedData -resultBundlePath /private/tmp/YouNewCleanClonePostFix.L8VF0h/FullUIFinal.xcresult -parallel-testing-enabled NO -maximum-parallel-testing-workers 1 -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO`
- Source checkout: `/private/tmp/YouNewCleanClonePostFix.L8VF0h/repo`
- Commit: `da8c3fe22e7a5d99b2187aab1141700b2d34f508`
- Checkout state: clean detached HEAD (`git status --short --branch` returned only `## HEAD (no branch)`).
- UI test inventory in that source: 87 `test…` methods.
- Simulator: `YouNew BuildWeek Shard 3`; iPhone 17 Pro; iOS 26.5 (23F77); arm64; UDID `1D538DCE-A487-40C2-801F-811D44D6397D`.
- Xcode: 26.6 (17F113).
- macOS: 26.5.2 (25F84).
- Run began: result bundle created at 2026-07-21 01:48:26 +0200; XCTest suite began at 01:50:37 +0200.
- Controller interruption: 2026-07-21 03:14:06 +0200; the owning Codex turn was aborted with reason `interrupted` while `xcodebuild` was still active.
- Last runner output: 2026-07-21 03:14:12 +0200.
- Observed wall interval: 1h 25m 46s from result-bundle creation, or 1h 23m 35s from suite start. There is no authoritative XCTest finish duration because the run was interrupted.
- Original result bundle: `/private/tmp/YouNewCleanClonePostFix.L8VF0h/FullUIFinal.xcresult` (1.7 GB, incomplete staging bundle, missing `Info.plist`).

## Results recoverable from the runner log

| Measure | Result |
|---|---:|
| Test inventory | 87 |
| Started before interruption | 21 |
| Completed | 20 |
| Passed | 17 |
| Failed | 3 |
| Skipped | 0 |
| Started but without outcome | 1 |
| Not reached | 66 |

These are partial-run counts, not a completed-suite pass rate.

### Recorded failures

1. `AccessibilityRuntimeUITests/testAccessibilityTextSizeKeepsSearchUsable`
   - Failure: text entry could not be synthesized because neither the search field nor a descendant had keyboard focus.
   - Duration: 38.939s.
   - Initial classification: accessibility/search interaction blocker candidate; targeted reproduction is required to distinguish product focus delivery from runner state.
2. `CategoryRoutingRuntimeUITests/testEveryCityScopedCategoryListReachesItsTypedDetailAndReturns`
   - Failure: `Typed list opened the wrong detail: category.list.cafes.leiden`.
   - Duration: 124.716s.
   - Initial classification: confirmed navigation/content-routing defect and relevant to the demo if that city/category route is used.
3. `ContentCompletionRuntimeUITests/testPrimaryTabsRenderCompletedSurfacesWithoutPlaceholderCopy`
   - Failure: visible unfinished copy `will appear here` on the Guide tab.
   - Duration: 58.331s.
   - Initial classification: confirmed visible content-completion defect; not a crash, but unsuitable for a judge-facing path until localized or excluded from the demo.

### Interrupted test

- `ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling` started but emitted no pass/fail result before the runner stopped.
- The `.xcresult` was never finalized. No `xcodebuild`, `xctest`, `YouNewUITests-Runner`, or `XCBBuildService` process remained when the baseline was inspected.
- Controller evidence identifies the termination boundary: this was an aborted orchestration turn, not a completed test outcome or an infrastructure result emitted by XCTest. It would still be inaccurate to label the in-progress test passed, failed, skipped, or timed out.

## Map/root-tab blocker confirmation

The interrupted HEAD run never reached `MapChipUITests`, so it cannot be cited as a fresh execution of the map case.

The blocker remains confirmed by the latest earlier finalized full UI bundle:

- Artifact: `/private/tmp/YouNewCleanCloneEfd.20260720/FullUIFinal.xcresult`
- Finalized result: 87 total; 84 passed; 3 failed; 0 skipped.
- Duration: 7,249.603s (2h 00m 49.603s).
- Device: the same iPhone 17 Pro / iOS 26.5 simulator.
- Failure: `MapChipUITests/testRootTabNavigationLatency` — `Home destination must become visible on the first tap.`
- Source commit: `efd1a7c50bf7b5e2f82be047b084b6d73cb009a7`.
- The diff from `efd1a7c5` to `da8c3fe2` changes backend examples, AI validation/tests, and category/content UI test diagnostics only; it does not change the root tab container, map implementation, or `MapChipUITests`. Therefore this is retained as a confirmed pre-fix product blocker, while a post-fix targeted execution is still required.
- Exported failure evidence shows the synthesized tap at screen coordinate `(53, 831)`, inside `tab.home`'s 74 × 48.7 pt frame. After the tap, `tab.map` is still Selected and the metric remains on `tab=map`; this rules out a threshold-only failure and demonstrates that root selection did not receive/commit that event.

The two other failures in that finalized bundle were a missing discovery group and a content-surface query timeout. The discovery routing case passed in the interrupted HEAD run; the content scrolling case was the point of interruption and remains unresolved.

## Comparison with the reported historical 80/86

| Run | Total | Passed | Failed | Skipped | Interpretation |
|---|---:|---:|---:|---:|---|
| User-provided historical result | 86 | 80 | 6 | not provided | Historical only; original artifact not identified here. |
| Latest earlier finalized bundle | 87 | 84 | 3 | 0 | Improvement of four passes and three fewer failures, with one additional test in inventory. |
| Current control run at HEAD | 87 inventory | 17 of 20 completed | 3 of 20 completed | 0 | Interrupted and not comparable as a full-suite result. |

No public claim should use `17/20` or `84/87` as a current final UI number. A complete post-fix suite is needed for current submission numbers.

## Working tree state at baseline capture

The tested clean clone was at the commit above. The owner workspace was on branch `build-week-readiness` at the same commit and already contained unrelated/in-progress user work before this task:

- 49 modified paths;
- 3 deleted paths;
- 126 untracked status entries;
- no staged diff;
- SHA-256 of the pre-baseline `git status --porcelain=v1` stream: `2103e144ad1951cd84ac25baafc1563afd71697f48e3d0782e3c3f91a13a9eac`.

Those changes are preserved. This task must avoid overwriting or reverting them.

## Preserved artifacts

Because the control `.xcresult` is incomplete and 1.7 GB, the available runner/test-manager evidence was copied into the repository instead of claiming a valid result bundle:

- `BuildWeekFinal/artifacts/UI_BASELINE_RUNNER_STDOUT_2026-07-21.log` — SHA-256 `5ff1ac9a0fa24d8f7c04b537db9b0da91c49620747f4819b7d81f4304c57d65b`.
- `BuildWeekFinal/artifacts/UI_BASELINE_TESTMANAGERD_2026-07-21.log` — SHA-256 `a37f3277b6aadf41eada40845a2352cb54936a952fd09f624dbbb85af296d27d`.
- `BuildWeekFinal/artifacts/UI_BASELINE_SCHEDULING_2026-07-21.log` — SHA-256 `143bcba0bdaa9b5e8aed055002c082adc39e06357c978062d75ff0bd735d77bb`.
- `BuildWeekFinal/artifacts/UI_MAP_TAB_FAILURE_EVIDENCE/` — exported screen recording, synthesized-event records, UI hierarchy, and manifest from the finalized map failure. The hierarchy file SHA-256 is `e5314e48ae0119841ced79a48e0cd374a1a59f8bc09bbcd7663053d53248ee09`; the recording SHA-256 is `2a53020ff8140c87de4f412fc48ca9169105254582e0395887a21c75eebd404e`.

The original partial bundle and the earlier valid completed bundle remain at the paths above for local inspection. They are temporary-machine artifacts and are not suitable for Git tracking.

## Baseline conclusion

- The control run was awaited and inspected; it ended without finalizing.
- Three failures were directly observed before interruption.
- The map/root-tab first-tap failure remains a confirmed blocker from the latest finalized unchanged map/root-tab baseline.
- A wrong city/category detail is the other directly demonstrated navigation defect.
- Search focus and the long-running content-scroll path require targeted reproduction before their root causes are asserted.
- Source changes may begin only after this baseline record.
