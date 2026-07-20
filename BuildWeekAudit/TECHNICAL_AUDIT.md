# YouNew Technical Audit for OpenAI Build Week

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Repository root: current local `YouNew` Git worktree
Audit mode: evidence-first; no source/project setting was changed

## Executive summary

YouNew is a substantial SwiftUI newcomer-information app with broad local content, a typed navigation/search/map system, a mature custom image pipeline, an extensive test inventory, a governed content project and many QA reports/scripts. The current dirty working tree produces a successful clean Debug simulator build.

It is not submission-ready. The effective AI Assistant is deterministic/local rather than live OpenAI; no pre-audit GPT-5.6 evidence exists; the unit suite has four failures; aggregate static QA has five failing commands representing four distinct issues; the UI suite has six failures out of 86 tests; essential source/data/CI files are untracked; no remote or GitHub repository is configured; licensing and judge setup are incomplete; no distribution/TestFlight/App Store proof or demo video exists.

Overall Build Week readiness is assessed in `BuildWeekAudit/BUILD_WEEK_READINESS.md`. The most important technical truth is documented in `BuildWeekAudit/AI_ASSISTANT_ARCHITECTURE.md`.

## Verification legend

- **VERIFIED** — current code, configuration, Git object or reproducible command.
- **PARTIAL** — evidence exists, but the complete claim is not established.
- **NOT VERIFIED** — adequate evidence was not found.
- **NOT IMPLEMENTED** — capability is absent from the effective path.
- **HISTORICAL** — report/xcresult evidence from an older tree; not a current pass.

## Project facts

| Fact | Status | Current value/evidence |
|---|---|---|
| Application name | VERIFIED | YouNew; app target `YouNew` at `YouNew.xcodeproj/project.pbxproj:107-129`; entry `YouNewApp` at `YouNew/App/AppEntry.swift:35-36`. |
| Bundle Identifier | VERIFIED | `nl.younew.app` for Debug and Release: `YouNew.xcodeproj/project.pbxproj:446-499`. |
| Primary platform | VERIFIED | iOS app; project also lists simulator/macOS/xrOS support: `YouNew.xcodeproj/project.pbxproj:442-459,494-511`. |
| Minimum iOS | VERIFIED | 17.6 for app: `YouNew.xcodeproj/project.pbxproj:442,494`. Current test targets require iOS 26.5: `:524,551,577,603`. |
| Language | VERIFIED | Swift 5: `YouNew.xcodeproj/project.pbxproj:457,509`. |
| UI framework | VERIFIED | SwiftUI app/scene: `YouNew/App/AppEntry.swift:1-2,35-69`. UIKit/AppKit bridges/system frameworks are used where needed. |
| Architecture | VERIFIED hybrid | SwiftUI + ObservableObject/MVVM-style view models + services/repository + typed router/environment injection. Evidence: `YouNew/ViewModels/AppStateViewModel.swift:4-5`, `YouNew/ViewModels/AIViewModel.swift:6-7`, `YouNew/Services/ContentRepository.swift:41-52`, `YouNew/App/Navigation/AppRouter.swift:3-4`, `YouNew/App/AppEntry.swift:45-69`. Not strict/pure MVVM. |
| Main targets | VERIFIED | `YouNew`, `YouNewTests`, `YouNewUITests`: `YouNew.xcodeproj/project.pbxproj:107-174,219-223`. |
| Version/build | VERIFIED | 1.1 (5): `YouNew.xcodeproj/project.pbxproj:418,446,470,498`. |
| Configurations | VERIFIED | Debug and Release only; no Production/TestFlight-named configuration: `YouNew.xcodeproj/project.pbxproj:411-658`. Archive uses Release: `YouNew.xcodeproj/xcshareddata/xcschemes/YouNew.xcscheme:99-102`. |

### Main directories

- `YouNew/App` — app entry, root/tab/navigation.
- `YouNew/Core` — design system, imaging, localization, interaction, utilities.
- `YouNew/Data` — bundled/static/mock and media data.
- `YouNew/Features`, `Models`, `Services`, `ViewModels`, `Views` — product layers.
- `YouNew/Assets.xcassets`, `Resources`, `en.lproj`, `nl.lproj`, `ru.lproj` — assets/runtime/localization.
- `YouNewTests`, `YouNewUITests` — unit/integration/UI automation.
- `scripts`, `QA` — static gates and reports.
- Current but untracked: `DataProject`, `Audit`, `.github`, much of `admin-dashboard`.

## Dependencies

Xcode resolves:

- swift-algorithms 1.2.1;
- swift-async-algorithms 1.1.5;
- swift-collections 1.6.0;
- swift-numerics 1.1.1.

Evidence: `YouNew.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`. Only the Algorithms product is linked directly (`YouNew.xcodeproj/project.pbxproj:123-125,689-694`); no corresponding package imports were found in current Swift source. No CocoaPods/Carthage/Package.swift dependency manager exists.

System frameworks/imports include SwiftUI, Combine, CoreLocation, MapKit, EventKit/EventKitUI, VisionKit, UniformTypeIdentifiers, UserNotifications, Network, LocalAuthentication and UIKit/AppKit.

## Backend dependency matrix

| Component | Status | Evidence |
|---|---|---|
| Default app data | VERIFIED local/static | Bundled `Mock*Data` and canonical local payload; README states mock/static/local limitations at `README.md:59-64`. |
| Optional own API | PARTIAL/untracked | `YOUNEW_API_BASE_URL`; HTTPS city place/business summary endpoints in `YouNew/Services/HomePlaceSyncService.swift:4-17,57-76` and `YouNew/Services/HomeBusinessSyncService.swift:31-49`. No concrete URL. |
| AI proxy | PARTIAL example; not runtime-effective | `AIClient` expects `YOUNEW_AI_PROXY_URL` (`YouNew/Services/AIClient.swift:181-188`), absent from project settings; example Worker only. Current send path never reaches it. |
| Weather | PARTIAL/untracked | Direct Open-Meteo request: `YouNew/Services/HomeWeatherService.swift:65-84`. |
| Calendar | PARTIAL/untracked | Visit Leiden fetch/parser: `YouNew/Services/VisitLeidenCalendarService.swift:82-134`. |
| Admin/Supabase | PARTIAL/untracked | Private Next.js/React/Supabase app in `admin-dashboard/package.json`; integration TODOs in `admin-dashboard/README.md:113-122`. |
| Deployment | NOT VERIFIED | No deployed endpoint/config/receipt for Worker, admin or own API. |

## Git repository facts

| Fact | Status | Evidence |
|---|---|---|
| Git repository | VERIFIED | Local `.git` and 56 reachable commits. |
| Current branch | VERIFIED | `fix/ui-regression`. |
| Remote URL | NOT IMPLEMENTED | `git remote -v` empty; `.git/config:1-7` has no remote. |
| GitHub repository | NOT VERIFIED | No remote/URL evidence. |
| Public/private | UNKNOWN | Cannot be determined locally. |
| First commit | VERIFIED | 2026-05-21T14:06:29+02:00. |
| Latest available commit | VERIFIED | 2026-07-12T00:11:14+02:00. |
| Working tree baseline | DIRTY | 119 modified, 2 deleted, 323 untracked file paths before report creation. |

The current audited product is not reproducible from Git because modified tracked code references essential untracked types/resources. See `BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md`.

## CI/CD

- `.github/workflows/data-project-health.yml` exists locally and validates DataProject/offline publication gates plus nightly link health.
- The workflow is untracked and therefore absent from `HEAD`/a clone.
- No iOS build/test/archive pipeline is configured.
- No deployment/upload automation is verified.

Classification: **PARTIAL CI; CD NOT IMPLEMENTED/NOT VERIFIED**.

## App Store and TestFlight

| Item | Status | Evidence |
|---|---|---|
| Release/production configuration | PARTIAL | Standard Release exists and is used for Archive; no distinct Production `.xcconfig`. |
| TestFlight configuration | PARTIAL | Standard Release Archive exists at `YouNew.xcodeproj/xcshareddata/xcschemes/YouNew.xcscheme:99-102`; a separately named TestFlight configuration is not required. No dedicated export/upload automation exists, and external TestFlight build status is NOT VERIFIED. |
| Version/build | VERIFIED local | 1.1 (5). |
| Signing | PARTIAL | Automatic signing and a team are configured; identifier intentionally redacted. No distribution profile/archive proof. |
| Test bundle IDs | PARTIAL drift | Release test targets still use placeholder-style `com.company...` IDs (`YouNew.xcodeproj/project.pbxproj:554,606`). |
| Entitlements | NOT IMPLEMENTED explicitly | No `.entitlements` file/`CODE_SIGN_ENTITLEMENTS`. `REGISTER_APP_GROUPS = YES` does not prove an App Group entitlement. |
| StoreKit | NOT IMPLEMENTED | No `.storekit` file. |
| Privacy manifest | VERIFIED source | `YouNew/PrivacyInfo.xcprivacy`: tracking false; collected-data list empty; UserDefaults/FileTimestamp reasons. `plutil` inspection passed and clean build copied it into bundle. |
| Privacy declarations | PARTIAL | Policy/draft labels exist; App Store Connect answers are external. |
| Metadata | PARTIAL/stale | `APP_STORE_PACKAGE.md` conflicts with current identity/version; no standard ASC/Fastlane export. |
| Release notes | PARTIAL/HISTORICAL | `TESTFLIGHT_CHECKLIST.md:25-45` contains draft TestFlight notes for stale version 1.0 (1), including known issues. No final notes matching current local 1.1 (5) or a submission record are verified. |
| Public App Store version | NOT VERIFIED | No listing URL or external screenshot. |
| Active TestFlight build | NOT VERIFIED | Internal readiness reports do not prove upload/processing. |

Historical `APP_STORE_QA_PACKAGE.md:3-12,25-33,46-50` says version 1.1 (5) was NOT READY and a July 11 archive was Development-signed with debug entitlement. It is historical, not current distribution proof.

Required external screenshots are listed in `BuildWeekAudit/MISSING_EVIDENCE.md`.

## Current reproducible verification summary

Full commands, times and artifacts: `BuildWeekAudit/TEST_AND_QA_EVIDENCE.md`.
Final build/unit/static/UI verification uses a product-source cutoff of **2026-07-19 23:35:52 CEST**. The product directories were frozen or checked byte-identical to that snapshot; subsequent edits were limited to the requested `BuildWeekAudit` reports.

| Gate | Current result |
|---|---|
| Clean Debug simulator build | PASS; zero xcresult warnings/errors. |
| Unit suite | FAIL; 446/450 pass, 4 fail, 0 skipped. |
| UI suite | FAIL; closed frozen-snapshot result: 80/86 pass, 6 fail, 0 skipped. |
| Aggregate static QA | FAIL; 35/40 commands pass, 5 fail across 4 distinct failure groups. |
| DataProject QA/import | PASS on non-mutating temporary snapshot. |
| Structural relation/health | PASS; stored link evidence, not new live crawl. |
| Targeted secret/history scan | No true secret found; dedicated scanner unavailable; binary/OCR/EXIF limitations. |
| Working tree | DIRTY/non-reproducible. |

Historical claims such as 241/378/387/404 test counts and “static QA passed” are not current results. The exact 42-unit/55-UI claims had no supporting pre-audit occurrence/artifact; generated audit files now mention them only because they were queried. Current evidence takes precedence.

## Priority findings

### Critical

1. **Confirmed — current product is not reproducible for judges.** Essential source/data/CI are untracked; no remote exists. Evidence: Git status, filesystem-synchronized group, referenced untracked files.
2. **Confirmed — AI marketing mismatch.** Effective assistant path is local deterministic; no live endpoint/model/GPT-5.6 proof. Evidence: early-return trace in `BuildWeekAudit/AI_ASSISTANT_ARCHITECTURE.md`.
3. **Confirmed — repository redistribution is not authorized/verified.** No LICENSE; image rights incomplete; device artifacts risk publication.

### High

1. **Confirmed — current QA is red.** Four unit failures, five failing static commands across four distinct root issues, and six UI failures.
2. **Confirmed — distribution status is unproven.** No distribution archive, TestFlight processing record or public listing evidence.
3. **Confirmed — exact Build Week scenario is not regression-tested or runtime-proven.** Narrow BSN/health flows exist only separately.
4. **Confirmed — current metadata/README are stale/incomplete.** A judge cannot reproduce/explain the product from README alone.

### Medium

1. **Candidate risk — performance.** The current source-policy performance gate passes, but no current trace, runtime profile, soak result or memgraph exists.
2. **Confirmed partial/current defect — accessibility/visual QA.** Static accessibility QA passes, but two current UI cases reproduce the same 42 pt versus 44 pt Home control. VoiceOver/full device-language-Dynamic-Type coverage remains incomplete.
3. **Confirmed partial — content breadth.** Latest local report leaves Hotels empty and deep data concentrated in Amsterdam.
4. **Confirmed partial — external source health.** Stored report says 0 confirmed broken of 1,141 URLs, but includes 450 restricted and 30 transient outcomes; no fresh crawl here.

### Low

1. **Confirmed configuration drift.** Release test bundle identifiers retain placeholder-style IDs.
2. **Confirmed portability issue.** Tracked audit reports contain local absolute paths.
3. **Confirmed evidence hygiene issue.** Several older readiness reports conflict with later code/results.

## Performance, memory, UI and accessibility boundary

- Performance implementation includes downsampling, caching, actor-based coalescing and view-lifecycle stale-update guards; underlying shared fetch cancellation is not fully proven. The frozen-snapshot static performance gate passes.
- No current ETTrace/Time Profiler/Core Animation trace exists; no FPS/launch percentile is claimed.
- No current memory graph/leak ownership evidence exists; no memory leak is claimed confirmed.
- Selected visual screenshots/reports exist, but no complete current device/language/accessibility regression matrix.
- Static accessibility QA passed, but runtime accessibility is red: two UI cases reproduce a 42 pt versus 44 pt Home touch target. Full VoiceOver/Reduce Motion/manual accessibility remains PARTIAL.

## Honest technical scores

These are audit judgments, not measured telemetry:

| Area | Score | Reason |
|---|---:|---|
| Performance | 6/10 | Good pipeline architecture and current static-policy pass; no measured runtime trace. |
| Stability | 4/10 | Clean build and broad passing coverage; unit, static and UI suites are all currently red. |
| Architecture | 7/10 | Strong typed/local systems; oversized surfaces and untracked integration state. |
| UX | 6/10 | Broad guided flows/sources; exact demo and full runtime matrix incomplete. |
| UI | 6/10 | Strong premium system and broad runtime traversal; six UI failures include two accessibility defects. |
| App Store readiness | 3/10 | Local identity/privacy present; distribution, metadata, licensing and external status missing. |
| Overall technical readiness | 5.5/10 | Capable product implementation, not yet a reproducible/submittable package. |

## Owner role

The supported wording is:

> Human founder, product owner, requirements author, reviewer, and final decision-maker working with AI as a product and engineering team.

Tracked design QA supports user-supplied references, rejection and refinement. Repository evidence does not show that the owner personally wrote code, nor does it independently prove every physical-device action. Conversation/session evidence should substantiate specific personal-attribution claims.

## ChatGPT and GPT-5.6 boundary

The repository can prove prompt/architecture/report/test artifacts and iteration chronology. It cannot prove old ChatGPT conversations, old model choice, prompt authorship, full product-decision history, or GPT-5.6. Required external evidence is enumerated in `BuildWeekAudit/MISSING_EVIDENCE.md`.

## Release decision

**NOT READY for Build Week submission, public judge repository, TestFlight certification or App Store claim.**

The audit stops here. No defect, route, configuration, repository state or content was repaired automatically.
