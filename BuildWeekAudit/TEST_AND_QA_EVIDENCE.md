# Test and QA Evidence

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Audit host: macOS 26.5.2 (25F84), arm64; Xcode 26.6 (17F113); iPhone 17 Pro, iOS 26.5 Simulator
Source state: dirty local `fix/ui-regression` working tree, frozen for final verification at **2026-07-19 23:35:52 CEST**; report creation excluded from the recorded baseline

## Result legend

- **VERIFIED PASS/FAIL** — fresh command and reproducible artifact or captured output.
- **PARTIAL** — a relevant check ran, but its scope does not establish the whole claim.
- **HISTORICAL** — older report/result bundle, not proof for the current tree.
- **NOT VERIFIED** — no adequate result was found.
- **NOT IMPLEMENTED** — no corresponding automated facility was found.

## Current test inventory

| Area | Status | Evidence |
|---|---|---|
| Unit tests | VERIFIED inventory | `YouNewTests` contains 38 Swift files. The fresh xcresult enumerates 450 test metadata entries; Swift Testing's console summary reports 443 tests in 36 suites because the two reporting layers count generated/parameterized metadata differently. |
| UI tests | VERIFIED inventory | `YouNewUITests` contains 10 Swift files and 86 `test...` method definitions found by source inventory. |
| Integration tests | PARTIAL | Integration behavior is embedded in the unit target, e.g. `YouNewTests/LiveDataIntegrationTests.swift`, content/import/index tests; no separate integration target exists. |
| Snapshot/pixel-diff tests | NOT IMPLEMENTED | Visual static checks, screenshot matrices and an HTML gallery exist, but no current automated reference-image pixel-diff framework was found. |
| Media Registry tests | VERIFIED present | `YouNewTests/MediaRegistryTests.swift`; no Media Registry case appears among the four fresh unit failures. |
| Import validation | VERIFIED present/current pass | `scripts/data-project-import-static-qa.py` and DataProject release/import artifacts. |
| Duplicate validation | VERIFIED present/current pass | DataProject import and visible-image offline checks; current snapshot records zero disallowed duplicate groups in their respective scopes. |
| Broken relation validation | VERIFIED present/current pass | `scripts/data-health-gate.py` and import validation report zero structural issues/broken relations. This is not a fresh live URL crawl. |
| Accessibility | PARTIAL/FAIL runtime | `scripts/accessibility-static-qa.py` passes, but two frozen-snapshot UI tests independently reproduce a 42 pt versus 44 pt primary Home control failure. Manual VoiceOver/Reduce Motion coverage also remains incomplete. |
| Performance | PARTIAL/PASS static | `scripts/performance-static-qa.py` passes on the frozen snapshot; no current Instruments/ETTrace/memgraph artifact exists, so runtime performance is not release-proven. |
| Build verification | VERIFIED PASS | Fresh clean Debug simulator build succeeded with zero xcresult warnings/errors. No distribution archive was attempted. |

## Fresh command ledger

Simulator identifiers are intentionally omitted; `<AUDIT_SIMULATOR_UDID>` denotes the selected iPhone 17 Pro/iOS 26.5 destination.

### 1. Clean build

- **Command:** `xcodebuild -project YouNew.xcodeproj -scheme YouNew -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath <TEMP_DIR>/CurrentTree/DerivedData -resultBundlePath <TEMP_DIR>/CurrentTree/CleanBuild.xcresult clean build CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES`
- **Environment/device:** iPhone 17 Pro Simulator, iOS 26.5; signing disabled; Debug.
- **Date/time:** 2026-07-19 23:37:21–23:39:13 CEST.
- **Result:** **VERIFIED PASS** — `BUILD SUCCEEDED`.
- **Passed/failed/skipped:** one clean action and one build action passed; 0 build errors, 0 warnings, 0 analyzer issues in xcresult.
- **Duration:** 111.980 seconds.
- **Output artifact:** `<TEMP_DIR>/CurrentTree/CleanBuild.xcresult` and derived app under the adjacent DerivedData directory.
- **Snapshot integrity:** the app/project/script directories used by this run were verified byte-identical to the 23:35:52 frozen snapshot after the cutoff; later report edits are outside the audited product scope.
- **Boundary:** Debug simulator build only; this is not an Archive, distribution-signing or App Store validation result.

### 2. Unit tests

- **Command:** `xcodebuild -project YouNew.xcodeproj -scheme YouNewUnitTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath <TEMP_DIR>/BuildWeekAudit/DerivedData -resultBundlePath <TEMP_DIR>/BuildWeekAudit/UnitTests.xcresult test CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES`
- **Environment/device:** iPhone 17 Pro Simulator, iOS 26.5; isolated frozen-snapshot DerivedData.
- **Date/time:** 2026-07-19 23:40:46–23:43:18 CEST.
- **Result:** **VERIFIED FAIL**.
- **Passed/failed/skipped:** xcresult: **450 total, 446 passed, 4 failed, 0 skipped**. Test operation: 80.236 seconds; Swift Testing execution: 45.810 seconds; action duration: 152.402 seconds including build/launch overhead.
- **Output artifact:** `<TEMP_DIR>/BuildWeekAudit/UnitTests.xcresult`.
- **Failed cases:**

  1. `KnowledgeDataGovernanceTests/partnerVerificationRequiresRealWebsiteAndStatus()`
  2. `KnowledgeIndexTests/netherlandsKnowledgeDatabaseProvidesUnifiedDataPlatform()`
  3. `KnowledgeIndexTests/allGuideArticlesCitiesAndProvincesAreIndexedForAI()`
  4. `KnowledgeIndexTests/localPartnersAreIndexedForEverySupportedCityAndCoreCategory()`

Swift Testing printed 443 tests/36 suites and eight issue events. That console count is retained as a reporting-layer difference; the final result and four distinct failures above come from the xcresult test tree.

### 3. Full UI tests

- **Command:** `xcodebuild -project YouNew.xcodeproj -scheme YouNewUITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' -derivedDataPath <TEMP_DIR>/BuildWeekAudit/DerivedData -resultBundlePath <TEMP_DIR>/BuildWeekAudit/UITests.xcresult test CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES -parallel-testing-enabled NO`
- **Environment/device:** iPhone 17 Pro Simulator, iOS 26.5; serial execution.
- **Date/time:** 2026-07-19 23:43:53.702 CEST – 2026-07-20 00:55:51.457 CEST on the frozen snapshot.
- **Result:** **VERIFIED FAIL** — the runner reached a closed result bundle; this was not an infrastructure cancellation.
- **Passed/failed/skipped:** **86 total, 80 passed, 6 failed, 0 skipped, 0 expected failures**.
- **Duration:** action elapsed 4,317.755 seconds (71 min 57.755 s); test-operation observer reported 4,311.346 seconds.
- **Output artifact:** `<TEMP_DIR>/BuildWeekAudit/UITests.xcresult`.
- **Current failed cases:**

  1. `AccessibilityRuntimeUITests/testAccessibilityTextSizeKeepsHomeControlsReachable()` — `home.currentProfile` measured 42 pt high versus 44 pt required.
  2. `RootNavigationUITests/testAccessibilitySizeKeepsPrimaryHomeActionsReachable()` — the same 42 pt versus 44 pt primary-Home-action issue.
  3. `ContentCompletionRuntimeUITests/testRequiredContentDestinationsRenderCompletedSurfacesWithoutPlaceholderCopy()` — expected `transport.screen` did not render.
  4. `ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling()` — the same `transport.screen` destination failure in scrolling coverage.
  5. `PublishedCitiesRuntimeUITests/testPublishedAmsterdamMuseumFlowsFromSearchToGuideAndSaved()` — published Rijksmuseum record missing from Search.
  6. `YouNewUITests/testSearchAfspraakFindsDutchCourse()` — assertion failed at `YouNewUITests/YouNewUITests.swift:697`.

- **Superseded-attempt boundary:** an earlier 22:55 run observed the 42 pt versus 44 pt issue but was invalidated because source changed during execution. The current frozen-snapshot run independently reproduced it, so the accessibility issue is now current evidence; no totals from the superseded run are used.

### 4. Static analysis/QA aggregate

- **Primary command:** `scripts/run-static-qa.sh`
- **Execution method:** a non-mutating copy of the frozen working tree was placed at `<TEMP_DIR>/BuildWeekAudit/StaticSnapshot`; the top-level fail-fast script stopped at the first red gate, then all 40 listed commands were invoked individually so later gates could be classified.
- **Environment:** macOS shell/Python; no source-tree writes. Generators wrote only inside the temporary snapshot.
- **Date/time:** 2026-07-19 approximately 23:45 CEST; full individual-command batch 8.4 seconds.
- **Result:** **VERIFIED FAIL** — 35 commands exited 0 and 5 commands failed, representing 4 distinct failure groups.
- **Passed/failed/skipped:** 35 passed, 5 failed, 0 skipped among the 40 commands listed by `scripts/run-static-qa.sh`.
- **Failed gates:**

  1. `scripts/static-qa.py` — ambient background motion is not wired through the shared layer.
  2. `scripts/brand-static-qa.py` — the same ambient-background-motion root issue is enforced by the brand gate.
  3. `scripts/apple-review-static-qa.py` — global AI launcher must hide while Menu, More or Saved is active.
  4. `scripts/persona-ia-static-qa.py` — Search direct results, guide routes and institution detail routes are not persona-filtered as required by the gate.
  5. `scripts/content-static-qa.py` — Home Transport tile does not open the expected transport guide.

- **Passing highlights:** localization/routing/button/URL safety; accessibility and performance static QA; search and route-ID stability; report honesty; icon validation; offline visible-image, image runtime/render and visual-system checks; AI subsystem; DataProject QA/import/dashboard/observability/operations/health/workflow; KNM/Dutch course; user-visible completeness; public site; media/place/history checks.
- **Output artifacts:** regenerated reports and `VISUAL_AUDIT_GALLERY.html` under the temporary snapshot. The durable classification is this audit report; temporary generated files were not copied back.
- **Lint/analyze boundary:** no SwiftLint configuration/executable or other conventional lint target was found, so no SwiftLint command was available to run. The clean-build xcresult reports zero analyzer-warning metrics, but a separate `xcodebuild analyze` action was not configured or executed; custom repository gates are the current static-analysis facility.

#### Complete 40-command frozen-snapshot ledger

All commands below were invoked individually from `<TEMP_DIR>/BuildWeekAudit/StaticSnapshot`. Aggregate wall time was 8.4 seconds; per-command durations were not retained, so none are invented.

| # | Command | Result |
|---:|---|---|
| 1 | `python3 scripts/static-qa.py` | FAIL |
| 2 | `python3 scripts/localization-key-static-qa.py` | PASS |
| 3 | `python3 scripts/route-action-static-qa.py` | PASS |
| 4 | `python3 scripts/button-action-static-qa.py` | PASS |
| 5 | `python3 scripts/url-source-safety-static-qa.py` | PASS |
| 6 | `python3 scripts/apple-review-static-qa.py` | FAIL |
| 7 | `python3 scripts/accessibility-static-qa.py` | PASS |
| 8 | `python3 scripts/performance-static-qa.py` | PASS |
| 9 | `python3 scripts/search-static-qa.py` | PASS |
| 10 | `python3 scripts/route-id-stability-static-qa.py` | PASS |
| 11 | `python3 scripts/report-honesty-static-qa.py` | PASS |
| 12 | `python3 scripts/zero-compromise-report-static-qa.py` | PASS |
| 13 | `scripts/validate-app-icons.sh` | PASS |
| 14 | `python3 scripts/visible-image-remote-qa.py --offline` | PASS |
| 15 | `python3 scripts/image-runtime-data-qa.py` | PASS |
| 16 | `python3 scripts/image-render-static-qa.py` | PASS |
| 17 | `python3 scripts/visual-system-static-qa.py` | PASS |
| 18 | `python3 scripts/generate-visual-audit-gallery.py` | PASS |
| 19 | `python3 scripts/visual-report-static-qa.py` | PASS |
| 20 | `python3 scripts/ai-subsystem-static-qa.py` | PASS |
| 21 | `python3 scripts/persona-ia-static-qa.py` | FAIL |
| 22 | `python3 scripts/content-static-qa.py` | FAIL |
| 23 | `python3 scripts/data-project-qa.py` | PASS |
| 24 | `python3 scripts/data-project-import-static-qa.py` | PASS |
| 25 | `python3 scripts/generate-data-dashboard.py` | PASS |
| 26 | `python3 scripts/data-dashboard-static-qa.py` | PASS |
| 27 | `python3 scripts/generate-data-observability.py` | PASS |
| 28 | `python3 scripts/data-observability-static-qa.py` | PASS |
| 29 | `python3 scripts/generate-data-operations.py` | PASS |
| 30 | `python3 scripts/data-operations-static-qa.py` | PASS |
| 31 | `python3 scripts/data-health-gate.py` | PASS |
| 32 | `python3 scripts/data-project-workflow-static-qa.py` | PASS |
| 33 | `python3 scripts/knm-static-qa.py` | PASS |
| 34 | `python3 scripts/dutch-course-static-qa.py` | PASS |
| 35 | `python3 scripts/user-visible-completeness-static-qa.py` | PASS |
| 36 | `python3 scripts/public-site-static-qa.py` | PASS |
| 37 | `python3 scripts/media-static-qa.py` | PASS |
| 38 | `python3 scripts/place-media-static-qa.py` | PASS |
| 39 | `python3 scripts/history-media-static-qa.py` | PASS |
| 40 | `python3 scripts/brand-static-qa.py` | FAIL |

### 5. Import/content validation

- **Commands:** `python3 scripts/data-project-qa.py`; `python3 scripts/data-project-import-static-qa.py`; associated dashboard/observability/operations generators and gates listed in `scripts/run-static-qa.sh`.
- **Environment:** current working-tree snapshot, temporary output only.
- **Date/time:** 2026-07-19 approximately 23:45 CEST.
- **Result:** **VERIFIED PASS in audited scope**.
- **Passed/failed/skipped:** DataProject QA reports 17 work packages, 7 milestones, 7 releases, 27 batches and 450 governed records. Import validation passed deterministic ID, duplicate, geography and relation checks. Snapshot regeneration produced 450 governed records, 188 published runtime records and quality score 100 under the script's own rubric.
- **Duration:** included in the static batch; individual timings were not retained.
- **Output artifact:** temporary `StaticSnapshot/DataProject/reports/*` plus `CONTENT_RELEASE_EVIDENCE.md`.
- **Boundary:** generation in a copy proves script behavior, not that the untracked outputs are reproducible from `HEAD` or deployed.

### 6. Targeted secret scan

- **Environment:** repository text and all reachable Git commits; no network. Commands emit only matching file paths, never matched values. Current-tree scans exclude `.git`, dependency/build caches, device-result artifacts, the large ignored image staging tree, and this generated audit output.
- **Current-text command:** `rg -l -I -uu --hidden -g '!.git/**' -g '!admin-dashboard/node_modules/**' -g '!admin-dashboard/.next/**' -g '!admin-dashboard/public-site/node_modules/**' -g '!admin-dashboard/public-site/.next/**' -g '!admin-dashboard/public-site/out/**' -g '!TestArtifacts/**' -g '!netherlands_app_images/**' -g '!BuildWeekAudit/**' -e '(sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-[0-9A-Za-z-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,})' .` The final `-uu` rerun deliberately included otherwise-ignored source/config files while retaining explicit exclusions for dependencies, build outputs, device artifacts, bulk image staging and the generated audit.
- **Reachable-history command:** `for audit_commit in $(git rev-list --all); do git grep -I -l -E '(same strong-token/private-key pattern)' "$audit_commit" -- 2>/dev/null || true; done` followed by path-only de-duplication. The full pattern is identical to the current-text command; it is abbreviated here only to keep the command readable, not because a different scan ran.
- **Sensitive-filename command:** `rg --files -uu --hidden -g '!.git/**' -g '!admin-dashboard/node_modules/**' -g '!admin-dashboard/.next/**' -g '!TestArtifacts/**' -g '!netherlands_app_images/**' | rg -i '(^|/)(\.env($|\.)|.*\.(pem|p12|pfx|cer|crt|mobileprovision|provisionprofile)|id_(rsa|ed25519)(\.pub)?$|.*credentials.*|.*secrets?.*)'`
- **Date/time/duration:** initial current-text pass 2026-07-19 23:55:42 CEST, 0.12 s; final `-uu` current-text rerun 2026-07-20 01:04:11 CEST, 0.10 s; reachable history 2026-07-19 23:55:58–23:56:10 CEST, 12.85 s; filename scan 23:56:21 CEST, 0.02 s.
- **Result:** **PARTIAL PASS** — no actual API key/token/password/private key/certificate/provisioning profile was confirmed.
- **Findings:** current text and reachable history each identified one candidate path, `YouNew/Data/MockScamWarningsData.swift`; review confirms the `sk-...`-shaped string at line 339 is a content slug/false positive. The filename scan identified only `admin-dashboard/.env.example`, whose inspected content contains placeholder variable names, not values. The safe identifier `OPENAI_API_KEY` appears in the Worker example but does not match a secret value.
- **Passed/failed/skipped:** strong-pattern text/history checks passed after manual candidate review; dedicated entropy scanners `gitleaks`, `detect-secrets` and `trufflehog` were unavailable; OCR/EXIF and binary xcresult/device diagnostics were not comprehensively scanned.
- **Output artifacts:** the final `-uu` rerun emitted the same single reviewed path to the captured console; its durable interpretation is in this report and `REPOSITORY_SECURITY_AUDIT.md`. Earlier path-only temporary lists were written under `<TEMP_DIR>/`; they are not repository deliverables.

### 7. Broken references/relations

- **Commands:** `python3 scripts/data-health-gate.py`, `python3 scripts/data-project-import-static-qa.py`, `python3 scripts/route-action-static-qa.py`, `python3 scripts/route-id-stability-static-qa.py`.
- **Environment/date:** temporary current-tree snapshot, 2026-07-19.
- **Result:** **VERIFIED PASS for structural relations and typed-route static scope**.
- **Passed/failed/skipped:** zero structural data-health issues; import manifest reports zero broken relations; route action/ID gates pass.
- **Duration:** included in the static batch.
- **Output artifact:** temporary data-health/import reports and this file.
- **Boundary:** stored source-health evidence covers 1,141 URLs with 0 confirmed broken, but this audit did not perform a fresh live crawl. Restricted/transient URLs are not equivalent to verified reachable URLs.

### 8. Working-tree check

- **Commands:** `git status --short --untracked-files=all`; `git branch --show-current`; `git rev-list --count HEAD`; `git remote -v`.
- **Environment/date:** repository root, 2026-07-19 before creation of `BuildWeekAudit` outputs.
- **Result:** **VERIFIED DIRTY**.
- **Passed/failed/skipped:** branch `fix/ui-regression`; 56 commits; no remote; 119 modified, 2 deleted and 323 untracked file paths (444 porcelain paths total) at the recorded baseline.
- **Duration:** under one second.
- **Output artifact:** `REPOSITORY_SECURITY_AUDIT.md` and `TECHNICAL_AUDIT.md`.
- **Boundary:** the ten requested audit output files themselves are later untracked additions and are not counted in that baseline.

## Test-category conclusions

### Unit tests

Status: **VERIFIED FAIL CURRENTLY**. Broad coverage is real, but “the unit suite passes” is false for this working tree. Four current failures concern partner/source verification and KnowledgeIndex completeness.

### UI tests

Status: **VERIFIED FAIL CURRENTLY**. The closed frozen-snapshot xcresult contains 86 tests: 80 passed and 6 failed. It supersedes historical prose and the interrupted pre-freeze attempt.

### Integration tests

Status: **PARTIAL**. `LiveDataIntegrationTests`, repository/index/import and runtime-baseline checks exercise integrations locally. There is no separate end-to-end backend/provider environment or deployed-service contract suite.

### Snapshot/visual regression tests

Status: **PARTIAL/NOT IMPLEMENTED as pixel diff**. Static visual-system and image-render gates, screenshot matrices, selected captures and a 257-card generated gallery exist. No current golden-image pixel comparator with thresholded pass/fail was found.

### Media Registry tests

Status: **VERIFIED PRESENT; current cases pass by exclusion from failure list**. Evidence: `YouNewTests/MediaRegistryTests.swift`, `scripts/media-static-qa.py`, `scripts/place-media-static-qa.py`, `scripts/history-media-static-qa.py`.

### Import, duplicate and broken-relation validation

Status: **VERIFIED PASS in current snapshot scope**. The manifest/import gates report no duplicate or broken-relation failures. Separate image-source offline QA reports 294 assignments, 294 unique URLs and zero duplicate source groups. These are different scopes and must not be merged into one universal “no duplicates” claim.

### Accessibility tests

Status: **PARTIAL/CURRENT UI FAILURES**. Static accessibility gate passes, but two runtime cases reproduce the same 42 pt versus 44 pt Home touch-height defect. VoiceOver focus, Reduce Motion and full device/language/Dynamic Type coverage also remain incomplete.

### Performance tests

Status: **PARTIAL/CURRENT STATIC PASS**. The source policy gate passes on the frozen snapshot. No measured launch/FPS/hang/leak/soak result is current, so performance cannot be called release-proven.

## Historical artifacts and claim audit

| Claim/artifact | Classification | Evidence-based conclusion |
|---|---|---|
| “42 unit tests passed” | NOT VERIFIED | No pre-audit repository/history occurrence or result artifact was found; generated audit files now repeat the queried string. It is not the current count. |
| “55 UI tests, 0 failures” | NOT VERIFIED | No pre-audit occurrence/result bundle supporting this claim was found. The current closed run executed 86 tests, with 80 passing and 6 failing. |
| “build/static QA passed” | MIXED/HISTORICAL | Fresh clean Debug build passes; current aggregate static QA has five failing commands/four distinct failure groups. Older green reports apply only to older trees/scopes. |
| “accessibility was PARTIAL” | VERIFIED HISTORICAL and CURRENTLY PARTIAL | Historical `visual_regression_qa.md:18`/`APPSTORE_READINESS.md:20`; fresh static pass exists, but manual VoiceOver/Reduce Motion and the full device/language/Dynamic Type matrix remain incomplete. |
| “CoreSimulator blocked runtime checks” | VERIFIED HISTORICAL | `DEVICE_RUNTIME_REPORT.md`, `APPSTORE_CERTIFICATION.md`, `QA/FINAL_IOS_RUNTIME_QA.md` and many related reports document service failures. The current audit did obtain live simulator execution, so the old blocker is not the present explanation for red tests. |
| Historical real-device-labelled result bundle | HISTORICAL/FAIL | `RealDeviceContentAudit-2026-07-17.xcresult`: 3 tests, 1 passed, 2 failed; action cancelled, about 15 minutes. It does not prove a current physical-device pass. |
| Five July 15 small result bundles | HISTORICAL/NO TEST RESULT | Actions failed to start; no tests ran and build was not requested. |
| Counts 241, 378, 387, 404/410 | HISTORICAL | Examples: `APPSTORE_READINESS.md:15` (241), `APP_STORE_QA_PACKAGE.md:20` and `INFORMATION_GUIDE_FINAL_REPORT.md:38` (378), `FINAL_RUNTIME_GATE_REPORT.md:23` (387), `Audit/YouNew_Full_Product_Readiness_2026-07-13/artifact.json` (404/410). They are not interchangeable and are not current. |

## Complete report-like Markdown inventory

The audit enumerated every pre-existing Markdown path whose filename contains `audit`, `qa`, `report`, `readiness`, or `certification` (case-insensitive), using:

`rg --files -g '*.md' | rg -i '(^|/)[^/]*(audit|qa|report|readiness|certification)[^/]*\.md$' | sort`

The scan returned 138 paths after report creation: four are this audit's own outputs, leaving **134 pre-existing report-like Markdown files**. Presence is not proof that a report is current or correct; current/historical classifications above take precedence. The full pre-existing path inventory is:

```text
01_app_audit.md
ACTIVE_TAB_RESET_REPORT.md
AI_ARCHITECTURE_REPORT.md
AI_AUDIT.md
AI_CRITICAL_FIX_REPORT.md
AI_DISCLOSURE_REPORT.md
AI_LAYOUT_AUDIT.md
AI_NAVIGATION_AUDIT.md
AI_NAVIGATION_REPORT.md
AI_PERFORMANCE_REPORT.md
AI_RELEASE_AUDIT.md
AI_RELEASE_REPORT.md
AI_RENDERING_AUDIT.md
APPLE_REVIEW_REPORT.md
APPSTORE_AUDIT.md
APPSTORE_CERTIFICATION.md
APPSTORE_READINESS.md
APP_STORE_QA_PACKAGE.md
Audit/REAL_DEVICE_CONTENT_AUDIT_2026-07-17.md
Audit/REAL_DEVICE_CONTENT_AUDIT_2026-07-18.md
BACKGROUND_AUDIT.md
BLOCKER_FIX_REPORT.md
BOTTOM_SURFACE_AUDIT.md
BUG_FIX_REPORT.md
BUG_REPORT.md
BUILD_HEALTH_REPORT.md
BUNDLE_ID_REPORT.md
BUSINESS_DISCOVERY_QA_REPORT.md
CITY_COMPLETENESS_REPORT.md
CITY_CONTENT_AUDIT.md
CITY_IMAGE_AUDIT_REPORT.md
CITY_IMAGE_RUNTIME_AUDIT.md
CITY_RELEASE_REPORT.md
CLICKABILITY_REPORT.md
CONTENT_AUDIT.md
CONTENT_COMPLETENESS_REPORT.md
CONTENT_COMPLETION_REPORT.md
CONTENT_MODEL_MIGRATION_REPORT.md
CONTENT_RELEASE_REPORT.md
CRASH_CONCURRENCY_AUDIT.md
CRASH_ORIGIN_AUDIT.md
CULTURE_SCREEN_RESTRUCTURE_REPORT.md
CURRENT_WORKTREE_AUDIT.md
DEVICE_CERTIFICATION_REPORT.md
DEVICE_RUNTIME_REPORT.md
DUPLICATE_IMAGE_REPORT.md
DataProject/reports/general-work-report/REPORT_NOTES.md
DataProject/reports/runtime-data-flow-audit.md
EMPTY_SPACE_REPORT.md
FACT_ACCURACY_AUDIT.md
FINAL_RELEASE_REPORT.md
FINAL_RUNTIME_GATE_REPORT.md
FINAL_TESTFLIGHT_GATE_REPORT.md
FIRST_LAUNCH_REPORT.md
FLAG_AUDIT.md
FLAG_BINDING_FIX_REPORT.md
FULL_CONTENT_ROUTING_QA_REPORT.md
FULL_UI_REDESIGN_REPORT.md
GESTURE_INTERCEPTION_AUDIT.md
HANG_AUDIT.md
IMAGE_AUDIT.md
IMAGE_LICENSE_REPORT.md
IMAGE_QA_REPORT.md
IMAGE_REPLACEMENT_REPORT.md
IMAGE_RUNTIME_VERIFICATION_REPORT.md
IMAGE_SIZE_AUDIT.md
IMAGE_SYSTEM_AUDIT.md
INFORMATION_ARCHITECTURE_AUDIT.md
INFORMATION_GUIDE_FINAL_REPORT.md
JUNE17_FINAL_POLISH_REPORT.md
JUNE17_RELEASE_BLOCKER_REPORT.md
JUNE17_TOUCH_SCROLL_FINAL_REPORT.md
LAYOUT_FIX_REPORT.md
LOCALIZATION_AUDIT.md
LOCALIZATION_CLEANUP_REPORT.md
LOCALIZATION_PURGE_REPORT.md
MANUAL_DEVICE_QA_CHECKLIST.md
MANUAL_RUNTIME_QA_CHECKLIST.md
MAP_GESTURE_FIX_REPORT.md
MENU_REDESIGN_REPORT.md
MORE_SCREEN_REGRESSION_REPORT.md
NAVIGATION_AUDIT.md
NAVIGATION_REFACTOR_REPORT.md
NAVIGATION_REPORT.md
NAVIGATION_STATE_AUDIT.md
NAV_LANGUAGE_REPORT.md
NEWCOMER_JOURNEY_REPORT.md
ONBOARDING_PERSISTENCE_REPORT.md
ONE_TAP_NAVIGATION_REPORT.md
PERFORMANCE_AUDIT.md
PERFORMANCE_FIX_REPORT.md
PERFORMANCE_RELEASE_REPORT.md
PERFORMANCE_REPORT.md
PLACE_MEDIA_RENDER_AUDIT.md
QA/BrandRuntimeQA.md
QA/FINAL_IOS_RUNTIME_QA.md
QA/ROUTE_ACTION_SANITY_REPORT.md
QA_REPORT.md
REAL_DEVICE_QA_REPORT.md
RELEASE_HARDENING_REPORT.md
RELEASE_READINESS_REPORT.md
ROUTE_INTEGRITY_REPORT.md
SCROLL_AUDIT.md
SCROLL_FIX_REPORT.md
SCROLL_PERFORMANCE_FIX_REPORT.md
SCROLL_PERFORMANCE_REPORT.md
STAGE5_RELEASE_AUDIT.md
STUCK_SCROLL_ROOT_CAUSE_REPORT.md
TAB_BAR_HIT_AREA_REPORT.md
TESTER_EXPERIENCE_REPORT.md
TESTFLIGHT_BUILD_READINESS.md
TESTFLIGHT_CERTIFICATION.md
TESTFLIGHT_READINESS.md
TESTFLIGHT_RELEASE_AUDIT.md
TEXT_LAYOUT_REPORT.md
TOUCH_AND_SCROLL_DEVICE_QA.md
UI_AUDIT.md
VISUAL_ASSET_AUDIT.md
VISUAL_AUDIT.md
VISUAL_COMPLETENESS_AUDIT.md
VISUAL_CONSISTENCY_AUDIT.md
ZERO_COMPROMISE_AUDIT.md
accessibility_report.md
content_routing_runtime_qa_report.md
design-qa.md
final_qa_report.md
localization_report.md
navigation_test_report.md
orphaned_content_report.md
runtime_scroll_report.md
strict_visual_audit.md
strict_visual_refinement_report.md
visual_regression_qa.md
visual_regression_qa_after.md
```

Non-Markdown evidence was also inspected where relevant: `Audit/YouNew_Full_Product_Readiness_2026-07-13/YouNew_Full_Product_Readiness_Report.html`, its `artifact.json`, DataProject JSON/CSV reports, and local `.xcresult` bundles described above. This is a path inventory, not a claim that all 134 prose reports were rerun; most are historical assertions and only fresh commands/artifacts receive current PASS/FAIL status.

## Release-readiness test plan — 100 cases

**Status of every case below: PLANNED / NOT EXECUTED unless independently mapped to a fresh result above.** This list is a future release plan, not a fabricated pass report.

### Critical — QA-001 to QA-020

| ID | Area | Planned check | Acceptance evidence |
|---|---|---|---|
| QA-001 | Build | Clean Release build with isolated DerivedData | Exit 0, full log and xcresult, no compile/link errors |
| QA-002 | Launch | First launch on minimum supported iOS | No crash/blank screen; video and device log |
| QA-003 | Launch | Cold launch offline with empty caches | App remains usable; runtime log/video |
| QA-004 | AI | Open assistant, enter and send a question | Complete input → view model → answer trace/video |
| QA-005 | AI | Establish actual runtime AI mode | Redacted network capture proves backend/live or absence |
| QA-006 | Security | Scan final app bundle for credentials | Zero keys/tokens/private credentials; scanner report |
| QA-007 | AI | Send empty/whitespace input | No request or hang; UI test |
| QA-008 | AI | Execute address → BSN → DigiD flow | Structured consistent answer; UI test/video/source IDs |
| QA-009 | AI/content | Open every citation/action from QA-008 | Correct existing destination/source; route log |
| QA-010 | AI | Simulate unavailable endpoint/backend | Honest error/fallback; stub log/screenshot |
| QA-011 | Content | Load production runtime content from clean install | All mandatory JSON/records decode; validator log |
| QA-012 | Release | Validate `cities-v0.1.0` manifest | Schema, dates, cities/counts/fingerprint consistent |
| QA-013 | Import | Run duplicate/broken-relation gates | Zero disallowed findings; deterministic report |
| QA-014 | Navigation | Smoke all root/tab destinations | No dead end/crash; UI matrix |
| QA-015 | Navigation | Assistant action navigation and Back | Correct destination and preserved state; xcresult |
| QA-016 | Privacy | Validate packaged privacy manifest | Manifest in built bundle and lints |
| QA-017 | Privacy | Clear AI history and relaunch | Messages do not return; UI/storage evidence |
| QA-018 | Privacy | Match external AI payload to notice | Notice enumerates actual fields; redacted diff |
| QA-019 | Repository | Build from clean clone in new path | No dependence on untracked/local files |
| QA-020 | Submission | Judge follows README only | Build/demo works without hidden step; timed log |

### High — QA-021 to QA-055

| ID | Area | Planned check | Acceptance evidence |
|---|---|---|---|
| QA-021 | AI | Repeat known BSN question after cold launch | Semantically stable result; two captures |
| QA-022 | AI | Ask unsupported question | Explicit uncertainty; no fabricated facts |
| QA-023 | AI/content | Verify official status of all answer sources | Domain/status-to-claim audit |
| QA-024 | AI context | Change selected city and repeat | Current city used or absence stated |
| QA-025 | AI context | Change app locale | Predictable answer/source language matrix |
| QA-026 | AI context | Change persona/categories | Only intended recommendation changes |
| QA-027 | AI history | Ask a conversational follow-up | Correct continuity, no cross-session leak |
| QA-028 | AI cache | Relaunch after cached answer | Documented TTL/behavior; timestamps/log |
| QA-029 | AI failure | Simulate HTTP 429 | Clear retry behavior; stub/UI evidence |
| QA-030 | AI failure | Simulate timeout | Bounded spinner and recovery action |
| QA-031 | AI failure | Return malformed schema | Parser rejects safely; fixture test |
| QA-032 | AI failure | Return empty answer | Honest fallback, no empty card |
| QA-033 | AI failure | Return unavailable-model/server error | Not presented as verified answer |
| QA-034 | AI concurrency | Tap Send rapidly | No duplicate messages/requests or race crash |
| QA-035 | AI/localization | Enter demo prompt in Russian | Result matches documented language support |
| QA-036 | AI demo | Test combined newcomer scenario | Only proven BSN/DigiD/insurance/GP/bank content |
| QA-037 | AI stability | Repeat scenario over 10 cold launches | 10/10 without crash/hang |
| QA-038 | Content | Validate every runtime record schema | Zero decode/schema errors |
| QA-039 | Content | Exercise all five target cities | Correct content and routing for each city |
| QA-040 | Release | Reconcile eligible/imported/skipped counts | Manifest/import/runtime totals match |
| QA-041 | Import | Re-import identical batch | Idempotent; no new duplicates |
| QA-042 | Import | Inject broken-relation fixture | Gate rejects with precise relation |
| QA-043 | Import | Inject excluded/ineligible fixture | Correct skip reason code |
| QA-044 | Content | Fresh-check official URLs | Dated report, no confirmed broken links |
| QA-045 | Content/navigation | Open all search guide/article/institution routes | Correct destination type for each record |
| QA-046 | Images | Load valid remote image in `PremiumImageView` | Correct display without layout jump |
| QA-047 | Images | Disable network on first image load | Expected placeholder/fallback |
| QA-048 | Images | Verify role/aspect/focal preset | Important subject remains visible |
| QA-049 | Images | Load oversized image | Decoded size matches target/downsampling |
| QA-050 | Images | Rapidly reuse/close image views | Cancellation works; no stale image swap |
| QA-051 | Map | Select every supported city | Correct ID/label/destination matrix |
| QA-052 | Map | Pan/zoom and boundary hit tests | No false selection/gesture loss |
| QA-053 | Navigation | Three-level path and Back | Correct stack/state restoration |
| QA-054 | Accessibility | VoiceOver plus AX Dynamic Type | Named actions, no clipping; audit video |
| QA-055 | Privacy | Clear/reset all local AI data | History/caches cleared or retention disclosed |

### Medium — QA-056 to QA-085

| ID | Area | Planned check | Acceptance evidence |
|---|---|---|---|
| QA-056 | Performance | Measure cold launch on target device | Instruments/MetricKit trace and budget |
| QA-057 | Performance | Scroll long content for 60 seconds | Hitch/FPS trace within budget |
| QA-058 | Performance | Load 100 remote images | Bounded memory; Allocations/Leaks trace |
| QA-059 | Performance | Exercise disk/memory cache limits | Limits/pruning observed in metrics |
| QA-060 | Memory | Open/close assistant 50 times | No retained-object growth |
| QA-061 | Memory | Open map/city details 50 times | No sustained memory growth |
| QA-062 | Concurrency | Navigate away during async tasks | Cancelled task cannot update stale UI |
| QA-063 | Images | Reload after memory warning | Recovery without crash |
| QA-064 | Images | Return corrupt/unsupported image | Fallback rather than crash |
| QA-065 | Images/UI | Check overlays on light/dark heroes | Measured contrast meets chosen threshold |
| QA-066 | Media Registry | Resolve every runtime media reference | Zero missing registry entries |
| QA-067 | Media Registry | Run duplicate-source detection | All duplicate findings classified |
| QA-068 | Map/accessibility | Exercise map with Reduce Motion | No mandatory motion effect |
| QA-069 | Map/accessibility | VoiceOver traversal/city labels | Logical order and unique labels |
| QA-070 | Search | Typo, case and diacritic matrix | Predictable results, no crash |
| QA-071 | Search | Empty and very long query | No hang/unbounded work |
| QA-072 | Navigation | Launcher hidden in Menu/More/Saved | Policy matches runtime screenshots/tests |
| QA-073 | Navigation | Home Transport tile route | Opens the correct transport guide |
| QA-074 | Accessibility | Measure critical touch targets | All meet adopted minimum |
| QA-075 | Accessibility | Contrast in Light/Dark Mode | Critical UI meets threshold |
| QA-076 | Accessibility | Keyboard focus where supported | Predictable visible focus order |
| QA-077 | Localization | Truncation across supported languages | No clipped titles/CTAs at XL text |
| QA-078 | Privacy | Scan console/os_log for PII | No unredacted sensitive fields |
| QA-079 | Privacy | Exercise 30-day cache boundary | Expired entry removed/not used |
| QA-080 | App Store | Release archive with distribution setup | Archive and validation succeed |
| QA-081 | App Store | Inspect signed archive entitlements | Only required capabilities |
| QA-082 | App Store | Compare version/build everywhere | Project/archive/metadata/notes match |
| QA-083 | Repository | Run dedicated current+history secret scan | Zero verified secrets; tool report |
| QA-084 | Repository | Audit LICENSE and all image licenses | Redistribution basis for every public asset |
| QA-085 | Repository | Audit large files/LFS policy | No accidental xcresult/device/binary data |

### Low — QA-086 to QA-100

| ID | Area | Planned check | Acceptance evidence |
|---|---|---|---|
| QA-086 | UI | Smoke demo screens in Light/Dark | Readable colors/visible controls |
| QA-087 | UI | Portrait/landscape on supported devices | No critical clipping |
| QA-088 | UI | Smallest/largest supported iPhone | Demo flow remains usable |
| QA-089 | Lifecycle | Background/foreground during async load | No duplicate request/crash |
| QA-090 | State | Upgrade over prior local version | Safe preference/history migration/reset |
| QA-091 | State | Delete and reinstall | No dependency on residual data |
| QA-092 | Content | Localized city-name ordering | Stable expected order/names |
| QA-093 | Content | Display updated/published dates | Manifest-backed correct formatting |
| QA-094 | App Store | Validate icon/launch/display name | Final assets, no placeholder |
| QA-095 | App Store | Validate metadata/privacy/support URLs | Reachable and app-specific |
| QA-096 | Submission | Rehearse script on clean device | Fits time; no manual preparation |
| QA-097 | Submission | Validate demo video format/size | Playable, within limits, build-aligned |
| QA-098 | Documentation | Judge README checklist | Product, AI truth, setup, demo, tests, limits, licenses |
| QA-099 | CI/CD | Reproduce gates in CI | Immutable run/artifacts match local results |
| QA-100 | Release | Bind commit → archive → manifest → submission | One SHA/version/build/evidence chain |

## QA release conclusion

The test inventory is a strength; the current result is not green. A successful build must not be conflated with passing tests, and a mostly passing suite must not be reported as “all tests passed.” The authoritative current figures are the fresh xcresults and static gate outputs above.
