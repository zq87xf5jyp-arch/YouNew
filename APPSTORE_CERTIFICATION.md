# App Store Certification — YouNew

**Date:** 2026-06-18  
**Phase:** Runtime Certification  
**Rule:** PASS only with verified evidence on a working simulator or physical device.  
**Feature state:** Frozen. No feature development, redesign, new screens, new functionality, or refactors were performed.

## Certification Decision

**APP STORE CERTIFICATION: BLOCKED**

The App Store runtime certification cannot be granted because only a partial installed-build smoke pass completed, a real Home navigation defect was found, and the patched build could not be runtime-rechecked.

## Evidence-Only Checklist

| Area | App Store runtime requirement | Result | Evidence |
|---|---|---|---|
| Launch stability | App launches without crash | PARTIAL PASS | YouNew launched from Simulator Spotlight and Home rendered |
| Navigation | No broken routes, stuck navigation, or bad destinations | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Home launched; `Explore city` opened `Worker route` instead of city detail. Source fix applied but fixed build not runtime-rechecked. |
| Search | No freezes, valid results open correctly | PARTIAL | Search screen loaded visually, but typing/results were not verified because Computer Use click/state access became intermittent |
| AI | No frozen states; send/retry/stop/source actions work | NOT VERIFIED | AI tab tap attempt returned `noWindowsAvailable`; screen could not be verified |
| Images | No broken, stretched, blurred, or incorrect runtime assets | PARTIAL | Home Amsterdam hero image rendered |
| Buttons | Every button works on single tap | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Home `Explore city` opened wrong destination |
| Back navigation | Every opened path can return cleanly | PARTIAL PASS | Worker route Back returned to Home; broader paths not tested |
| Performance | 60 FPS target verified under runtime use | NOT VERIFIED | No running app; no profiling trace |
| Memory | No leaks under repeated use | NOT VERIFIED | No running app; no memory graph |
| Device behavior | Safe areas, touch targets, keyboard, dynamic behavior verified | PARTIAL FAIL / BLOCKED | App launched, but Simulator/Computer window became unavailable after Search tab attempt |

## Runtime Blockers

| Blocker | Evidence |
|---|---|
| Simulator service unavailable for app operations | `simctl get_app_container ... nl.younew.app app` and `simctl install ... YouNew.app` failed with CoreSimulatorService/simdiskimaged invalid |
| Direct bundle launch unavailable | `xcrun simctl launch ... nl.younew.app` failed with CoreSimulatorService/simdiskimaged invalid |
| Xcode runtime launch unavailable | `xcodebuild ... test-without-building` for a focused UI test hung and was terminated with exit 143 |
| Direct Simulator executable unavailable | Direct execution of Simulator exited with code 134 after startup warning |
| Writable-cache recovery failed | Retrying `simctl`/`xctrace` with temp HOME/cache paths did not restore simulator or Instruments access |
| Non-destructive simulator reset unavailable | `xcrun simctl shutdown ...` failed because CoreSimulatorService could not initialize the device set |
| Fixed build unavailable | Fresh `xcodebuild ... build-for-testing` for the runtime fix stayed silent for about 90 seconds and was terminated with exit 143 |
| Xcode metadata unavailable | `xcodebuild -project YouNew.xcodeproj -list` hung and was terminated with exit 143 |
| Simulator window unavailable after tab attempt | Computer Use lost access to the Simulator window after a Search tab tap from Worker route, returning `timeoutReached` / `noWindowsAvailable` |
| Direct service state differs from GUI | `simctl` install/launch failed, but Simulator Spotlight showed YouNew and launched the installed build |
| Resumed GUI interaction unavailable | Computer Use using `com.apple.iphonesimulator` showed YouNew on the Search tab, but clicking the visible Search field returned `noWindowsAvailable` and the next state read returned `timeoutReached` |
| Resumed Xcode metadata unavailable | `xcodebuild -project YouNew.xcodeproj -list` again hung after printing only the command invocation and was terminated with exit 143 |
| Writable-cache Xcode metadata recovered | With Xcode HOME/cache/module-cache paths moved to `<TEMP_DIR>`, `xcodebuild -project YouNew.xcodeproj -list` completed and listed the YouNew target/scheme |
| Writable-cache fixed build unavailable | The writable-cache simulator build progressed but failed with exit 65 during asset catalog compilation because CoreSimulatorService/simdiskimaged left Xcode with no available simulator runtimes |
| Keyboard input workaround unavailable | Computer Use text input returned `noWindowsAvailable`; Swift CoreGraphics keyboard events hit a HiServices/XPC connection error and left the visible Search screen unchanged |
| Post-block resumed check unchanged | A later resumed check again showed YouNew visually on Search and confirmed writable-cache Xcode metadata still works, while writable-cache `simctl list devices available` still fails with CoreSimulatorService/simdiskimaged connection errors |
| Second post-block resumed check unchanged | A second later resumed check again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable` |
| Third post-block resumed check unchanged | A third later resumed check again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable` |
| Physical device unavailable | `xcrun devicectl list devices` timed out waiting for CoreDeviceService to fully initialize |
| Instruments unavailable | `xcrun xctrace list devices` crashed because it could not write to its cache directory in the sandbox |
| Runnable simulator artifact found but not installable | `<TEMP_DIR>/ScreenshotRegression/Build/Products/Debug-iphonesimulator/YouNew.app` exists and has bundle ID `nl.younew.app`, but install failed |

## App Store Outcome

**Not certified for App Store submission.**

No full runtime PASS is assigned without fixed-build verification on a working simulator or physical device. A real Home navigation defect was found, patched with a narrow CTA hit-target/routing fix, and guarded by static QA. `python3 scripts/apple-review-static-qa.py` and `scripts/run-static-qa.sh` passed, but the patched build still requires runtime certification.
