# TestFlight Certification — YouNew

**Date:** 2026-06-18  
**Phase:** Runtime Certification  
**Rule:** PASS only with verified evidence on a working simulator or physical device.  
**Feature state:** Frozen. No new functionality, screens, redesign, architecture changes, or refactors were performed.

## Certification Decision

**TESTFLIGHT CERTIFICATION: BLOCKED**

An installed build launched through Simulator Spotlight, but direct install/launch services remain unreliable and a real Home navigation defect was found. Therefore TestFlight readiness cannot be certified.

## Evidence

| Gate | Required | Result | Evidence |
|---|---|---|---|
| Working runtime | App launches on simulator or physical device | PARTIAL / SERVICE BLOCKED | YouNew launched from Simulator Spotlight, but simulator service install/app-container/direct-launch operations fail with CoreSimulatorService/simdiskimaged invalid |
| Install state | Current YouNew build installed and discoverable | PARTIAL / GUI VERIFIED | Complete simulator app bundle exists; `simctl install` failed, but Simulator Spotlight showed YouNew and launched an installed build |
| Direct launch | Existing installed app can be launched by bundle ID | BLOCKED | `xcrun simctl launch ... nl.younew.app` failed with CoreSimulatorService/simdiskimaged invalid |
| Xcode UI-test launch path | Xcode can launch the app via UI test runner | BLOCKED | `xcodebuild ... test-without-building` stayed silent for about one minute and was terminated with exit 143 |
| Navigation | Tabs/routes/buttons/back paths verified live | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Home launched; Back worked from Worker route; visible `Explore city` CTA opened Worker route instead of city detail. Narrow source fix applied, but fixed build could not be runtime-rechecked. |
| Search | Typing/filtering/result navigation verified live | PARTIAL | Search screen loaded visually with input/chips/empty state, but typing/results could not be completed because Computer Use click/state access became intermittent |
| AI | Input/send/retry/stop/fallback/sources verified live | NOT VERIFIED | AI tab tap attempt returned `noWindowsAvailable`; screen could not be verified |
| Images | Runtime image rendering verified live | PARTIAL | Home Amsterdam hero image rendered |
| Buttons | Single-tap behavior verified live | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Home `Explore city` opened wrong destination |
| Back navigation | Back paths verified live | PARTIAL PASS | Worker route Back returned to Home; broader paths not tested |
| Performance | Runtime profiling captured | NOT VERIFIED | No running app; no Instruments trace |
| Memory | Runtime memory behavior observed | NOT VERIFIED | No running app; no memory graph |
| Device behavior | Safe areas, keyboard, touch, rotation/large screen behavior verified | PARTIAL FAIL / BLOCKED | App launched, but Simulator/Computer window became unavailable after Search tab attempt |

## Blocking Conditions

1. CoreSimulatorService connection became invalid during runtime tooling.
2. Direct simulator service install/launch remained unavailable even though the app was discoverable through Spotlight.
3. Physical-device discovery failed because CoreDeviceService timed out.
4. Instruments device discovery failed because `xctrace` could not write its cache in this sandbox.
5. Xcode UI-test launch path hung and had to be terminated.
6. Direct Simulator executable launch exited with code 134.
7. Retrying `simctl` and `xctrace` with writable temp HOME/cache paths did not restore runtime tooling.
8. Non-destructive `simctl shutdown` reset failed because CoreSimulatorService/device set initialization failed.
9. Fresh runtime-fix build attempt stayed silent for about 90 seconds and was terminated with exit 143.
10. `xcodebuild -project YouNew.xcodeproj -list` also hung and was terminated with exit 143.
11. Resumed GUI check showed YouNew still visible on the Search tab, but Computer Use click on the Search field returned `noWindowsAvailable` and the next state read returned `timeoutReached`.
12. Resumed `xcodebuild -project YouNew.xcodeproj -list` retry again hung after printing only the command invocation and was terminated with exit 143.
13. Retrying Xcode with writable `<TEMP_DIR>` HOME/cache/module-cache paths allowed project metadata to load, proving the previous metadata hang was partly cache/log related.
14. The writable-cache simulator build still failed with exit 65 at asset catalog compilation because `actool` could not discover simulator runtimes after CoreSimulatorService/simdiskimaged dropped again.
15. Computer Use text input into the visible Simulator returned `noWindowsAvailable`; Swift CoreGraphics keyboard events hit a HiServices/XPC connection error and did not change the visible Search screen.
16. A later resumed check again showed YouNew visually on Search and confirmed writable-cache Xcode metadata still works, but writable-cache `simctl list devices available` still fails with CoreSimulatorService/simdiskimaged connection errors.
17. A second later resumed check again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable`.
18. A third later resumed check again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable`.

## Runtime Defect Found

| Defect | Evidence | Fix status |
|---|---|---|
| Home `Explore city` opens `Worker route` instead of city detail | Verified by launching YouNew from Simulator Spotlight, tapping visible `Explore city`, and observing `Worker route` screen | Source fix applied in `YouNew/Views/HomeView.swift`; the CTA now targets city detail, has a stable runtime identifier, owns its rectangular hit target, and is stacked above neighboring hero content. `scripts/apple-review-static-qa.py` guards the fix; `python3 scripts/apple-review-static-qa.py` and full `scripts/run-static-qa.sh` passed; runtime recheck blocked by build/install failure |
| Simulator/Computer window lost after tab attempt | After tapping Search from Worker route, Computer Use could no longer read the Simulator window (`timeoutReached` / `noWindowsAvailable`) while Simulator still appeared running/frontmost | Blocks further runtime certification in this session |
| AI tab attempt could not be verified | Coordinate tap on AI Assistant tab returned `noWindowsAvailable` and the next Simulator state read also failed | AI runtime remains unverified |
| Fixed-build compilation failed at asset catalog | Writable-cache `xcodebuild ... generic/platform=iOS Simulator ... build` progressed into compilation, then failed because `actool` reported no available simulator runtimes | Fixed build still unavailable for install/runtime recheck |
| Search input could not be verified by keyboard workaround | The Search screen remained visible and unchanged after Computer Use text input failed and CoreGraphics keyboard events completed | Search typing/results still unverified |

## Required To Reopen Certification

- Restore a working simulator service or connect a physical iPhone.
- Install the current YouNew build.
- Launch the app successfully.
- Execute runtime checks for navigation, search, AI, images, buttons, back navigation, performance, memory, and device behavior.

No estimated readiness is provided.
