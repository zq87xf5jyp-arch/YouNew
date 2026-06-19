# TestFlight Release Audit

Generated: 2026-06-10
Scope: audit-only pass. No product code changes were made before this report.
App: YouNew.nl iOS app

## Executive Verdict

Final verdict: Not TestFlight Ready

Current TestFlight readiness score: 78 / 100
Target score: 85 / 100
Target status: Not met

YouNew.nl is close in content depth and visual quality, especially after the city imagery and premium section work. The app now presents as a serious newcomer guide with strong official-source framing, emergency guidance, rich city/province content, and a polished dark visual system.

It should not be submitted to TestFlight yet. Three release blockers remain:

1. The app build cannot complete in this environment because asset catalog compilation fails when Xcode cannot access simulator runtimes.
2. Static QA is not green: content QA fails on forbidden side menu `flag.fill` usage, and brand QA fails on Leiden official symbol source metadata.
3. First-launch onboarding completion appears to be stored only in memory, so users may be shown onboarding again after a fresh app launch unless another persistence layer handles it outside the inspected state model.

Official release references checked:

- Apple TestFlight overview: https://developer.apple.com/testflight/
- Apple App Store Connect test information: https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information/
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

## Scorecard

| Area | Score | Release Assessment |
| --- | ---: | --- |
| Content | 89 / 100 | Strong practical coverage across cities, government, transport, housing, healthcare, emergency, work, integration, KNM, and Dutch A1/A2. Needs final freshness pass for dated legal/tax/work/health content. |
| UX | 80 / 100 | Feature-rich and useful, but dense. First-time users get many choices quickly, and some custom flows need device tap-through. |
| Navigation | 82 / 100 | Main tabs and side menu cover the full product. Risk: large menu surface and some important paths depend on category naming rather than explicit newcomer journeys. |
| Trust | 84 / 100 | Strong official-source framing, AI disclaimers, emergency disclaimers, privacy controls, and local profile messaging. Needs final App Store/TestFlight notes and dated-info verification. |
| Accessibility | 76 / 100 | Many labels, scalable text guards, empty states, and large touch controls exist. Custom map canvas, carousels, icon-only controls, and dynamic type still need real VoiceOver/device QA. |
| Visual Design | 90 / 100 | Premium dark interface, city imagery, category accents, and rich hero treatments are strong. Still needs screenshot QA across device classes and light/dark expectations. |
| First-Time User Experience | 72 / 100 | Onboarding is well structured, but completion persistence is a release risk and the Home screen can feel dense immediately after onboarding. |

Static product quality score: 82 / 100
Release readiness score after build/static-gate blockers: 78 / 100

## Audit Method

Reviewed current source structure, routing, prior audit artifacts, static QA scripts, and a fresh build attempt.

Key local evidence:

- Root shell and tabs: `YouNew/Views/RootTabView.swift`
- First launch onboarding gate: `YouNew/ContentView.swift:12`
- In-memory onboarding flag: `YouNew/ViewModels/AppStateViewModel.swift:20`
- Onboarding completion handler: `YouNew/ViewModels/AppStateViewModel.swift:208`
- Home feature and persona routes: `YouNew/Views/HomeView.swift:2062`
- Search empty and no-result states: `YouNew/Views/SearchView.swift:127`
- Saved empty state: `YouNew/Views/FavoritesView.swift:16`
- Government services hero and service grid: `YouNew/Views/GovernmentHubView.swift:71`
- Emergency official contacts and source links: `YouNew/Views/EmergencyHubView.swift:11`
- AI assistant empty, loading, error, and offline states: `YouNew/Views/AIAssistantView.swift:35`
- Destination routing fallback: `YouNew/Views/AppDestinationView.swift:20`
- Current visual benchmark report: `VISUAL_CONSISTENCY_AUDIT.md`
- Current city/image release report: `FINAL_RELEASE_REPORT.md`
- Current bug report: `BUG_REPORT.md`

Runtime limitation:

The local Xcode environment cannot complete a full simulator/device audit. `xcodebuild` reaches asset catalog compilation, then fails with:

`No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`

Because of this, crash, freeze, memory, real tap, device screenshot, orientation, and VoiceOver verification remain required on a working Xcode device/simulator.

## Verification Results

| Check | Result |
| --- | --- |
| Project scheme discovery | Passed. `xcodebuild -list -json` found scheme `YouNew` and targets `YouNew`, `YouNewTests`, `YouNewUITests`. |
| Build with signing disabled | Failed. Asset catalog compilation blocked by unavailable CoreSimulator runtime services. |
| Combined static QA | Failed. Stops after localization and history media, then brand QA fails on Leiden source metadata. |
| Content static QA | Failed. `RootTabView.swift` contains `flag.fill`, which the gate treats as forbidden side menu official-symbol usage. |
| Brand static QA | Failed. Expected `Flag of Leiden.svg` and `Leiden wapen.svg`; registry currently uses `Flag_of_Leiden.svg` and `Leiden_wapen.svg`. |
| KNM static QA | Passed. |
| Dutch course static QA | Passed. |
| Media static QA | Passed. |
| Place media static QA | Passed. |
| History media static QA | Passed. |
| User-visible completeness static QA | Passed. |

## Screen Audit

| Screen / Flow | Readiness | Findings |
| --- | --- | --- |
| Home | Strong, with release caveat | Premium city hero, featured city, quick actions, persona journeys, city moments, and category routes are present. The screen is high density and may overwhelm first-time users unless onboarding routes users into a focused next step. |
| Search | Strong | Search has suggestions, recent searches, popular questions, no-result handling, map suggestions, AI ask entry, and outdated-info reporting. Needs real keyboard, Dynamic Type, and empty-result tap-through on device. |
| Map | Medium-high | Visual quality is strong and city/province previews were previously repaired. Custom canvas gestures and zoom need VoiceOver, hit-zone, small-screen, and iPad runtime testing. |
| Cities | Strong | City imagery and hero fallback work were documented in prior audits. Remaining caveat: remote-first city hero assets should be validated on device and ideally bundled for offline/premium reliability. |
| Provinces | Medium-high | Province pages and map previews have improved imagery and fallbacks. Needs real screenshot check after build succeeds, especially for card cropping and localized labels. |
| Government Services | Strong | Official institutions, service grid, official-source disclaimer, and AI help banner are present. Content density is good for a utility app. |
| Transport | Strong | Transport has hero visual treatment, visual cards, category-specific accents, and official-source sections. Fares and rules should be freshness-checked before public release. |
| Housing | Medium-high | Housing guide content exists and is practical. Needs final freshness pass for rent allowance, scam, and rental-rights details, plus source accuracy review. |
| Healthcare | Medium-high | Healthcare guide and emergency-adjacent information exist. Needs official-source validation for 2026, especially urgent-care wording and insurance allowance details. |
| Emergency | Strong, with critical accuracy requirement | 112, non-emergency police, huisarts/huisartsenpost, and GGD guidance have source links and disclaimers. Must be manually verified because emergency content has zero tolerance for stale or ambiguous copy. |
| AI Assistant | Medium-high | Empty state, prompt chips, loading indicator, offline/error status, safety disclaimer, and source framing exist. Needs TestFlight notes, privacy review, and real network/offline tests. |
| Settings | Medium-high | Profile, language, menu position, navigation, reminders, map, documents, app, and safety sections exist. Needs persistence checks and reset-local-data confirmation on device. |
| Bookmarks / Saved | Strong | Empty state, categorized saved rows, remove action, and accessibility label for removal are present. Needs persistence test across app relaunch. |
| Onboarding | Medium | Full-screen first-run flow exists with profile, time in NL, priorities, city, documents, skip, progress, and privacy messaging. Release blocker: completion flag appears non-persistent in `AppStateViewModel`. |

## First-Time Journey Simulation

Target: each user can reach needed information in fewer than 3 taps from Home.

| User | Needed Information | Home Path | Tap Count | Status |
| --- | --- | --- | ---: | --- |
| First-time newcomer | Registration, BSN, DigiD, first steps | Home quick/persona route to First Steps or Municipality/Government | 1-2 | Pass, but depends on visible route order on small screens. |
| Refugee | Help nearby, documents, healthcare, emergency | Persona journey or side menu refugee/support route | 1-2 | Pass in routing, needs runtime tap validation. |
| International student | DUO, housing, insurance, transport | Persona journey "International student" | 1 | Pass. |
| Expat worker | Work permits, taxes, official services | Persona journey "Expat worker" or Government/Work route | 1-2 | Pass. |
| Tourist | Stay rules, transport, emergency | Persona journey "Tourist" or Transport/Emergency quick actions | 1-2 | Pass. |

Concern: because Home is dense, the routes are technically reachable, but first-time clarity should be validated with a real iPhone SE run. The visual hierarchy must make the persona journey obvious without reading the whole screen.

## Key Release Risks

### Critical

1. Build does not complete in this environment

- Screen/area: whole app
- Evidence: `xcodebuild` fails at asset catalog compilation.
- Impact: no reliable archive, simulator run, screenshot pass, UI automation, or TestFlight handoff can be confirmed here.
- Recommended fix: run on a working Xcode install with iOS simulator runtimes or a connected device; then archive with signing enabled.
- Status: Not fixed in this audit pass.

2. Onboarding completion is not visibly persisted

- Screen/area: first launch onboarding
- Evidence: `hasCompletedQuestionnaire` is `@Published` only in `AppStateViewModel.swift:20`; completion sets memory state only at `AppStateViewModel.swift:208`.
- Impact: users may see onboarding again after relaunch, which is a poor first TestFlight experience.
- Recommended fix: store completion in `AppStorage` or another persisted app state and migrate/reset through Privacy Data Control.
- Status: Not fixed in this audit pass.

3. Static QA gates are red

- Screen/area: side menu and brand/media registry
- Evidence: `content-static-qa.py` fails on `flag.fill`; `brand-static-qa.py` fails on Leiden source metadata.
- Impact: release confidence is lower and CI-like local gates are not passing.
- Recommended fix: replace the side menu `flag.fill` symbols with non-official map/country icons, then align Leiden registry filenames or update the static guard if underscore filenames are intentionally canonical.
- Status: Not fixed in this audit pass.

### High

4. Full device UI audit is still blocked

- Screen/area: all screens
- Evidence: CoreSimulator runtime is unavailable, so actual device classes were not validated.
- Impact: iPhone SE, large iPhone, iPad, orientation, safe area, keyboard, and VoiceOver issues may still exist.
- Recommended fix: run manual and automated smoke tests on iPhone SE, iPhone 15/17 Pro Max class, and iPad.
- Status: Blocked by environment.

5. Emergency and legal/health content require final official-source freshness review

- Screen/area: Emergency, Healthcare, Housing, Work, Taxes, Government Services
- Evidence: some guide articles include explicit update metadata such as `June 2025`, and emergency links are high-stakes.
- Impact: stale guidance could harm trust and App Review confidence.
- Recommended fix: verify all official-source URLs and high-stakes facts against current official sources before external testing.
- Status: Not fixed in this audit pass.

### Medium

6. First Home experience may be too dense

- Screen/area: Home
- Evidence: Home includes hero city, featured city, quick actions, persona journeys, life scenarios, city moments, map previews, and category tiles.
- Impact: new users can reach information, but scanning cost is high.
- Recommended fix: add or emphasize a single "Start here" panel after onboarding, based on selected profile.
- Status: Should fix before public release.

7. Accessibility on custom interactive views is unverified

- Screen/area: Map, city carousel, AI chat, floating menu, onboarding
- Evidence: code includes accessibility labels in many places, but the custom map canvas and gesture layers need runtime VoiceOver checks.
- Impact: TestFlight feedback may include blocked navigation for assistive technology users.
- Recommended fix: manual VoiceOver pass plus UI tests for main destinations.
- Status: Should fix before public release, recommended before broad external TestFlight.

## Must Fix Before TestFlight

1. Get a clean build/archive on a working Xcode environment.

- Required result: `xcodebuild archive` or Xcode Archive succeeds with signing enabled.
- Current blocker: asset catalog compilation fails because no simulator runtimes are available to Xcode in this environment.

2. Persist onboarding completion across app launches.

- Required result: after completing or skipping onboarding, close and reopen the app; onboarding does not reappear unless the user resets local data.

3. Make all static QA gates green.

- Fix or justify `flag.fill` in `RootTabView.swift`.
- Align Leiden official symbol metadata with the brand QA expectations or update the QA script to match the canonical filenames.
- Re-run `bash scripts/run-static-qa.sh` and record a pass.

4. Complete a real-device smoke test for the 14 requested areas.

- Home
- Search
- Map
- Cities
- Provinces
- Government Services
- Transport
- Housing
- Healthcare
- Emergency
- AI Assistant
- Settings
- Bookmarks
- Onboarding

5. Verify high-stakes content against official sources.

- Emergency numbers and wording
- Healthcare urgent-care flow
- Work permit wording
- Tax/allowance guidance
- Housing rights and scam guidance
- AI disclaimer and source fallback language

6. Prepare TestFlight review notes.

- Explain that the app is an informational newcomer guide.
- Explain AI assistant behavior, safety limits, and whether the backend is live or mocked.
- Provide any login-free testing instructions.
- Document that emergency information is informational and links to official sources.

## Should Fix Before Public Release

1. Add a focused post-onboarding "Your next step" panel on Home.
2. Add explicit persisted empty/loading/error states for any remote image or AI/network failure that is not already covered by fallback components.
3. Bundle local city/province hero assets for the most important city screens to reduce dependence on remote image availability.
4. Run full screenshot QA in light and dark expectations. The app currently forces dark mode, so public messaging and review screenshots should be consistent with that product decision.
5. Add VoiceOver labels and adjustable actions for the custom map canvas and key gesture-driven UI.
6. Add analytics/crash reporting and TestFlight feedback instructions if the release process allows it.
7. Add a content freshness register for legal, healthcare, housing, tax, transport, and emergency information.

## Post-Launch Improvements

1. Add role-specific Home variants for newcomer, refugee, student, expat worker, and tourist.
2. Add offline packs for emergency, government, housing, healthcare, and transport basics.
3. Add in-app "last checked" metadata across all high-stakes guide pages.
4. Add localization QA for every supported language after major copy changes.
5. Add a small guided search mode for users who do not know Dutch institution names yet.
6. Expand automated UI tests to cover map selection, onboarding persistence, saved-item persistence, AI offline fallback, and every primary side-menu route.

## Final Readiness Decision

Not TestFlight Ready.

The app quality direction is good, and most product surfaces are close to beta quality. The current release state misses the 85/100 target because build validation, static QA gates, onboarding persistence, and real-device runtime QA are unresolved. Once those are fixed and verified, the app is likely to cross the TestFlight threshold quickly.
