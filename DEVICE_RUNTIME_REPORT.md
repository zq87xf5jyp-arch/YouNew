# Device Runtime Report — YouNew

**Date:** 2026-06-18  
**Phase:** Runtime Certification  
**Scope freeze:** Architecture, features, redesign, refactors, and new functionality are frozen.  
**Certification rule:** PASS only when verified on a working simulator or physical device.

## Runtime Environment

| Item | Evidence | Status |
|---|---|---|
| Target simulator | `YouNew (DD6314A8-FA00-4A38-9D9C-3E6C1D3D3CC1)` reported as Booted | AVAILABLE |
| Simulator UI | Computer inspection showed Simulator window on iOS 26.5 SpringBoard/Spotlight | AVAILABLE |
| App installed on simulator | `simctl get_app_container DD6314A8-FA00-4A38-9D9C-3E6C1D3D3CC1 nl.younew.app app` failed after CoreSimulatorService connection became invalid, but Simulator Spotlight later showed YouNew | PARTIAL / GUI VERIFIED |
| App discoverable in simulator UI | Spotlight search for `YouNew` showed YouNew and YouNewUITests-Runner; tapping YouNew launched the app | AVAILABLE |
| Simulator service health | Basic boot/list can succeed, but install/app-container operations fail when CoreSimulatorService/simdiskimaged becomes invalid | BLOCKED |
| Physical device | `xcrun devicectl list devices` timed out waiting for CoreDeviceService to initialize | NOT AVAILABLE |
| Instruments device list | `xcrun xctrace list devices` crashed because Instruments could not write to `/Users/ivan/Library/Caches/com.apple.dt.InstrumentsCLI/path_manager` | BLOCKED |
| Runnable simulator build | Complete simulator bundle found at `/private/tmp/YouNewDerivedDataScreenshotRegression/Build/Products/Debug-iphonesimulator/YouNew.app` with bundle ID `nl.younew.app` | AVAILABLE |
| Simulator install | `xcrun simctl install ... YouNew.app` failed after CoreSimulatorService connection became invalid | BLOCKED |
| Direct Simulator executable | `/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/Contents/MacOS/Simulator` exited with code 134 after Objective-C duplicate-class startup warning | BLOCKED |
| Writable cache retry | `HOME=/private/tmp/codex-sim-home XDG_CACHE_HOME=/private/tmp/codex-sim-cache xcrun simctl list ...` still failed with CoreSimulatorService/simdiskimaged invalid | BLOCKED |
| Non-destructive simulator reset | `xcrun simctl shutdown DD6314A8-FA00-4A38-9D9C-3E6C1D3D3CC1` failed before shutdown because CoreSimulatorService/device set initialization failed | BLOCKED |

## Runtime Certification Matrix

| Area | Required verification | Runtime result | Evidence |
|---|---|---|---|
| Navigation | Open tabs, routes, detail screens, modals, sheets, deep links, and return paths | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Running installed build opened Home and Worker route; Back returned to Home. Tapping visible `Explore city` CTA opened `Worker route` instead of city detail. |
| Search | Type, filter, open results, verify no lag/freezes | PARTIAL | Search tab loaded visually with search input, category chips, empty-state card, tab selected, and popular-question card. Input/results were not completed because Computer Use click/state access became intermittent. |
| AI | Input, send, retry, stop, fallback, source cards, open guide/source, quick questions | NOT VERIFIED | Not yet tested after launch; runtime was redirected to verified Home navigation defect |
| Images | Verify hero/card/detail images render correctly on device | PARTIAL | Home Amsterdam hero image rendered; broader image audit not completed |
| Buttons | Single-tap every button and verify destinations/actions | PARTIAL FAIL / FIX PENDING RUNTIME RECHECK | Home Back worked; Home `Explore city` opened wrong destination |
| Back navigation | Verify return navigation from every opened route | PARTIAL PASS | Worker route Back returned to Home; broader back paths not tested |
| Performance | Measure scrolling/search/AI/images/lists/maps/large screens | BLOCKED | No running app; no Instruments trace |
| Memory | Observe leaks/retention under repeated navigation | BLOCKED | No running app; no memory graph |
| Device behavior | Safe areas, touch targets, keyboard, rotation/large screen behavior | PARTIAL FAIL / BLOCKED | App launched, but Computer Use lost access to the Simulator window after Search tab attempt |

## Commands And Observations

| Check | Result |
|---|---|
| `xcrun simctl list devices available \| rg 'DD6314A8\|Booted\|YouNew'` | Reported target simulator as Booted |
| `xcrun simctl get_app_container ... nl.younew.app app` | Failed: CoreSimulatorService connection became invalid; unable to initialize simulator device set |
| DerivedData artifact lookup | Found complete `Debug-iphonesimulator/YouNew.app` at `/private/tmp/YouNewDerivedDataScreenshotRegression/Build/Products/Debug-iphonesimulator/YouNew.app` |
| `plutil -p .../YouNew.app/Info.plist` | Confirmed `CFBundleIdentifier = nl.younew.app`, `CFBundleShortVersionString = 1.0.0`, `CFBundleVersion = 1`, `MinimumOSVersion = 17.6` |
| `xcrun simctl install ... YouNew.app` | Failed: CoreSimulatorService connection became invalid; simdiskimaged unavailable |
| `xcrun simctl launch ... nl.younew.app` | Failed: CoreSimulatorService connection became invalid; simdiskimaged unavailable |
| `xcodebuild ... test-without-building -only-testing:YouNewUITests/.../testMoreMenuLayoutKeepsHeroBoundedAndAIHidden` | Started, then remained silent for about one minute and was terminated with exit 143 |
| `xcrun devicectl list devices` | Failed: timed out waiting for CoreDeviceService to fully initialize |
| `xcrun xctrace list devices` | Failed: Instruments could not create cache directory due sandbox permission |
| Direct Simulator executable launch | Failed with exit 134 after startup warning involving `PFExportGIFRequest` duplicate class |
| Writable-cache `simctl` retry | Failed with CoreSimulatorService connection invalid and simdiskimaged unavailable |
| Writable-cache `xctrace` retry | Failed with the same Instruments cache permission exception under `/Users/ivan/Library/Caches/com.apple.dt.InstrumentsCLI/path_manager` |
| Non-destructive simulator shutdown retry | Failed with CoreSimulatorService connection invalid and unable to locate device set |
| Simulator GUI inspection | Simulator SpringBoard and Spotlight were visible through Computer Use; later Spotlight showed YouNew and app launched |
| Runtime Home smoke | YouNew launched from Spotlight and Home loaded with Amsterdam hero, tab bar, hero image, city pills, persona card, and global AI launcher visible |
| Runtime back navigation smoke | Home -> Worker route -> Back returned to Home |
| Runtime button defect | Visible Home `Explore city` CTA opened `Worker route`, not the selected city detail |
| Runtime tab switch attempt | Tapping Search from Worker route caused Computer Use to lose the Simulator window; subsequent Simulator state reads returned `timeoutReached` / `noWindowsAvailable` while Simulator still appeared running/frontmost |
| Runtime Search screen load | Simulator later recovered and showed Search screen with search field, chips, empty-state card, selected Search tab, and popular question content |
| Runtime Search input attempt | Coordinate click on the search field returned intermittent `noWindowsAvailable`; input/results not verified |
| Source fix | Removed `magneticEffect()` from the Home hero city `NavigationLink`, added `home.hero.exploreCity` accessibility identifiers to both city CTA variants, and tightened the CTA hit target with `contentShape(Rectangle())` plus `zIndex(2)` |
| Static regression guard | `scripts/apple-review-static-qa.py` now requires the Home hero city CTA to target `AppDestination.nlCityDetail(selectedHeroCity.id)`, expose `home.hero.exploreCity`, avoid `.magneticEffect()`, own a rectangular hit target, and remain above neighboring hero content |
| Static regression after source fix | `python3 scripts/apple-review-static-qa.py` passed; `scripts/run-static-qa.sh` passed after the source fix and guard |
| Fresh runtime recheck after source fix | BLOCKED: `xcodebuild ... build-for-testing` for `/private/tmp/YouNewDerivedDataRuntimeFix` stayed silent for about 90 seconds and was terminated with exit 143 |
| Runtime AI tab attempt | Coordinate tap on AI Assistant tab returned intermittent `noWindowsAvailable`; subsequent Simulator state read also returned `noWindowsAvailable`, so AI screen did not become verifiable |
| Xcode metadata diagnostic | `xcodebuild -project YouNew.xcodeproj -list` stayed silent after the command line and was terminated with exit 143 |
| Resumed runtime GUI check | Computer Use using `com.apple.iphonesimulator` showed YouNew still open on the Search tab with the search field, chips, empty state, tab bar, AI assistant pill, and popular question card visible |
| Resumed runtime interaction attempt | Computer Use click on the visible Search field returned `noWindowsAvailable`; a follow-up state read returned `timeoutReached` |
| Resumed macOS accessibility attempt | `osascript` could not address the Simulator process and failed with a HiServices/XPC connection error |
| Resumed Xcode metadata retry | `xcodebuild -project YouNew.xcodeproj -list` again printed only the command invocation, remained silent for about 60 seconds, and was terminated with exit 143 |
| Writable-cache Xcode metadata retry | With `HOME`, `XDG_CACHE_HOME`, and `CLANG_MODULE_CACHE_PATH` pointed at `/private/tmp`, `xcodebuild -project YouNew.xcodeproj -list` completed and listed target `YouNew` plus scheme `YouNew` |
| Writable-cache fixed-build retry | The same writable-cache environment let `xcodebuild ... -destination 'generic/platform=iOS Simulator' ... build` progress into a real build, but it failed with exit 65 during `CompileAssetCatalogVariant` because `actool` reported `No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]` after CoreSimulatorService/simdiskimaged dropped |
| Fixed build artifact after writable-cache retry | `/private/tmp/YouNewDerivedDataRuntimeFix/Build/Products/Debug-iphonesimulator/YouNew.app` was created only as part of the failed build; build did not complete successfully and is not valid for runtime certification |
| Resumed keyboard input attempt | Computer Use `type_text` into the visible Simulator returned `noWindowsAvailable`; a Swift CoreGraphics keyboard-event attempt hit a HiServices/XPC connection error and left the visible Search screen unchanged |
| Repeated resumed blocker | Across resumed passes, YouNew remains visually renderable in Simulator, but runtime proof cannot continue because Computer Use click/text input, CoreGraphics input events, simctl install/launch/list stability, and fixed-build compilation all fail through Simulator/CoreSimulator/HiServices service errors |
| Post-block resumed service check | On a fresh resumed attempt, Computer Use still showed YouNew visually on the Search tab, writable-cache `xcodebuild -project YouNew.xcodeproj -list` still completed, and writable-cache `simctl list devices available` still failed immediately with CoreSimulatorService/simdiskimaged connection errors |
| Second post-block resumed service check | A second fresh resumed attempt again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed with CoreSimulatorService/simdiskimaged errors, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable` |
| Third post-block resumed service check | A third fresh resumed attempt again showed YouNew visually on Search, while writable-cache `simctl list devices available` failed with CoreSimulatorService/simdiskimaged errors, `xcrun devicectl list devices` timed out waiting for CoreDeviceService, and Computer Use click returned `noWindowsAvailable` |

## Certification Outcome

**DEVICE RUNTIME CERTIFICATION: BLOCKED**

No full runtime area is certified PASS. A real Home button routing defect was verified on the running simulator build and a narrow source fix was applied, but the fixed build could not be rebuilt/installed for runtime re-verification in this session.
