# Build Week remediation baseline

Captured: 2026-07-20 08:33:28 CEST (+0200)
Scope: current local working tree, including tracked modifications and untracked product files
Policy: evidence-first; no reset, stash, deletion, commit, push, publish, deploy, TestFlight, or release action was performed

## Git identity

| Fact | Baseline |
|---|---|
| Branch before remediation | `fix/ui-regression` |
| Remediation branch | `build-week-readiness` |
| Base commit | `b15a2f2913911763c989f9880f8ce376f903fc6e` |
| Remote | none configured |
| Staged files | 0 |
| Tracked files | 926 |
| Modified tracked paths | 119 |
| Deleted tracked paths | 2 |
| Untracked paths after the audit package was created | 331 |
| Ignored filesystem paths reported by Git | 27,532; dominated by dependencies, caches, generated image staging, and other local output |

Creating `build-week-readiness` preserved the complete dirty working tree. The branch operation did not alter, discard, stage, or commit any product file.

## Tracked changes

The following 119 tracked paths were modified at capture time:

```text
.gitignore
APP_STORE_PACKAGE.md
PRIVACY_POLICY.md
TERMS_OF_USE.md
YouNew.xcodeproj/project.pbxproj
YouNew/App/AppEntry.swift
YouNew/App/AppTabView.swift
YouNew/App/ContentView.swift
YouNew/App/Navigation/AppDestination.swift
YouNew/App/Navigation/AppDestinationView.swift
YouNew/App/Navigation/AppRouter.swift
YouNew/Core/DesignSystem/Components/AppAtmosphereBackground.swift
YouNew/Core/DesignSystem/Components/NLDesignSystem.swift
YouNew/Core/DesignSystem/Components/NetherlandsCityViews.swift
YouNew/Core/DesignSystem/Tokens/AppAnimations.swift
YouNew/Core/DesignSystem/Tokens/AppShadows.swift
YouNew/Core/Imaging/AppContentImageView.swift
YouNew/Core/Imaging/ImageLoader.swift
YouNew/Data/CanonicalPlaceImageResolver.swift
YouNew/Data/CityNewcomerPlacesData.swift
YouNew/Data/ContentMediaRegistry.swift
YouNew/Data/CuratedPlaceHeroMediaRegistry.swift
YouNew/Data/KNMGuideData.swift
YouNew/Data/LocalNetherlandsImagePackRegistry.swift
YouNew/Data/MockBeginnerGuidesData.swift
YouNew/Data/MockDashboardDiscoveryData.swift
YouNew/Data/MockDutchHolidaysData.swift
YouNew/Data/MockDutchTermsData.swift
YouNew/Data/MockExpandedSearchAnswers.swift
YouNew/Data/MockExpansionData.swift
YouNew/Data/MockLegalInfoData.swift
YouNew/Data/MockLocalPartnersData.swift
YouNew/Data/MockNetherlandsUnderstandingData.swift
YouNew/Data/MockResourcesData.swift
YouNew/Data/MockSearchAnswersData.swift
YouNew/Data/NetherlandsData.swift
YouNew/Data/SideMenuLandmarkRegistry.swift
YouNew/Data/TransportGuideData.swift
YouNew/Features/Home/View/UtilityCenterViews.swift
YouNew/Map.xcstrings
YouNew/Models/AppCategory.swift
YouNew/Models/DashboardDiscoveryModels.swift
YouNew/Models/InformationArchitecture.swift
YouNew/Models/LanguageManager.swift
YouNew/Models/LifeTimeline.swift
YouNew/Models/NearbyPlace.swift
YouNew/Models/PersonaTag.swift
YouNew/Models/RelatedContentEngine.swift
YouNew/Models/SavedItemsStore.swift
YouNew/Models/TabRouter.swift
YouNew/Services/AIContextBuilder.swift
YouNew/Services/AIWorkflowEngine.swift
YouNew/Services/AppSearchEngine.swift
YouNew/Services/ConnectivityStatus.swift
YouNew/Services/ContentRepository.swift
YouNew/Services/KnowledgeIndex.swift
YouNew/ViewModels/AppStateViewModel.swift
YouNew/ViewModels/MapViewModel.swift
YouNew/ViewModels/SearchViewModel.swift
YouNew/Views/AIAssistantView.swift
YouNew/Views/ChecklistView.swift
YouNew/Views/CitiesDirectoryView.swift
YouNew/Views/CultureAttractionsView.swift
YouNew/Views/DashboardDiscoveryViews.swift
YouNew/Views/DutchHolidaysView.swift
YouNew/Views/FavoritesView.swift
YouNew/Views/FinesInfoView.swift
YouNew/Views/FirstStepsView.swift
YouNew/Views/GreatDutchFiguresView.swift
YouNew/Views/GuideContentView.swift
YouNew/Views/HelpHubView.swift
YouNew/Views/HomeBusinessPartnerComponents.swift
YouNew/Views/HomeExploreListView.swift
YouNew/Views/HomeInteractionComponents.swift
YouNew/Views/HomeMapComponents.swift
YouNew/Views/HomeModels.swift
YouNew/Views/HomeView.swift
YouNew/Views/InstitutionDetailView.swift
YouNew/Views/LocalPartnersView.swift
YouNew/Views/MoreHubView.swift
YouNew/Views/NearbyMapView.swift
YouNew/Views/NetherlandsHistoryView.swift
YouNew/Views/NetherlandsInteractiveMapView.swift
YouNew/Views/OfficialSourceDirectoryView.swift
YouNew/Views/OnboardingQuestionnaireView.swift
YouNew/Views/PlacesDiscoveryView.swift
YouNew/Views/ProvinceDirectoryView.swift
YouNew/Views/RootGuideView.swift
YouNew/Views/RootHomeView.swift
YouNew/Views/RootMoreView.swift
YouNew/Views/SearchView.swift
YouNew/Views/SettingsView.swift
YouNew/Views/SurvivalNavigatorView.swift
YouNew/Views/TransportGuideView.swift
YouNewTests/AIFoundationTests.swift
YouNewTests/CityPlacesCalendarRegressionTests.swift
YouNewTests/CitySymbolValidationTests.swift
YouNewTests/ContentAccessPolicyTests.swift
YouNewTests/ContentExpansionCompletenessTests.swift
YouNewTests/ContentRepositoryTests.swift
YouNewTests/DashboardContentPolicyTests.swift
YouNewTests/KnowledgeIndexTests.swift
YouNewTests/PremiumNetherlandsMapModelTests.swift
YouNewTests/SearchSynonymTests.swift
YouNewTests/YouNewTests.swift
YouNewUITests/AccessibilityRuntimeUITests.swift
YouNewUITests/ContentCompletionRuntimeUITests.swift
YouNewUITests/HomeCategoryUITests.swift
YouNewUITests/LocalizationRegressionUITests.swift
YouNewUITests/MapChipUITests.swift
YouNewUITests/RootNavigationUITests.swift
YouNewUITests/YouNewUITests.swift
scripts/apple-review-static-qa.py
scripts/audit_place_media.py
scripts/performance-static-qa.py
scripts/persona-ia-static-qa.py
scripts/route-action-static-qa.py
scripts/run-static-qa.sh
scripts/search-static-qa.py
```

Two tracked paths were deleted before remediation began:

```text
IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png
YouNew/Services/PremiumInteractionServices.swift
```

Both deletions are treated as owner work in progress. They will not be restored or removed from history without evidence that doing so is correct.

## Untracked inventory

Top-level distribution at capture time:

| Scope | Paths | Initial classification |
|---|---:|---|
| `DataProject/` | 98 | mixed: essential governance inputs plus generated reports and one local staging cache |
| `TestArtifacts/` | 78 | local device/result artifacts; exclude from repository pending privacy review |
| `admin-dashboard/public-site/` | 38 | separate optional public-site deliverable; not required for the iOS demo |
| `IA_Audit_Screenshots/` | 25 | evidence/media with unresolved redistribution and privacy review |
| `YouNew/` | 21 | essential application source/resource files |
| `scripts/` | 16 | essential QA/import tooling for documented reproducibility |
| `YouNewTests/` | 12 | essential unit/integration tests |
| `BuildWeekAudit/` visible to Git | 8 | essential prior audit evidence |
| `Audit/` | 4 | historical evidence; curate, do not treat as current PASS |
| `YouNewUITests/` | 2 | essential UI tests |
| `.github/` | 1 | DataProject health workflow; essential only if retained and documented |
| Root data/audit/migration files | 28 | mixed source-of-truth, generated evidence, and review material |

The broad `*_AUDIT.md` / `*_REPORT.md` ignore rules additionally hide these two required audit artifacts:

```text
BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md
BuildWeekAudit/TECHNICAL_AUDIT.md
```

### Essential untracked application files

These files are compiled or referenced by the current filesystem-synchronized Xcode project and are required to reproduce the audited application state:

```text
YouNew/App/Navigation/DiscoveryMenuRouting.swift
YouNew/Core/AppPublicLinks.swift
YouNew/Core/DesignSystem/Tokens/AppHaptics.swift
YouNew/Core/Interaction/PremiumProvinceHitTesting.swift
YouNew/Data/LicensedPartnerMediaRegistry.swift
YouNew/Data/PremiumKnowledgeSeedData.swift
YouNew/Data/VerifiedLeidenVenueData.swift
YouNew/Models/BusinessPortalModels.swift
YouNew/Models/DiscoveryEventFilter.swift
YouNew/Resources/Data/younew-runtime-data.json
YouNew/Services/DataProjectRuntimeLoader.swift
YouNew/Services/HomeBusinessSyncService.swift
YouNew/Services/HomePlaceSyncService.swift
YouNew/Services/HomeWeatherService.swift
YouNew/Services/KnowledgeDataGovernance.swift
YouNew/Services/KnowledgeDataHealthService.swift
YouNew/Services/VisitLeidenCalendarService.swift
YouNew/Views/BusinessPortalViews.swift
YouNew/Views/DiscoverySideMenu.swift
YouNew/Views/HomePremiumInformationCard.swift
YouNew/Views/TypedCategorySectionView.swift
```

### Essential untracked tests

```text
YouNewTests/BusinessPortalTests.swift
YouNewTests/DataProjectRuntimeBaselineTests.swift
YouNewTests/DiscoveryEventFilterTests.swift
YouNewTests/DiscoveryMenuRoutingTests.swift
YouNewTests/KnowledgeDataGovernanceTests.swift
YouNewTests/LiveDataIntegrationTests.swift
YouNewTests/PremiumProvinceHitTestingTests.swift
YouNewTests/PublicReleaseLinksTests.swift
YouNewTests/PublishedCitiesDataReleaseTests.swift
YouNewTests/TypedCategoryRouteSerializationTests.swift
YouNewTests/VerifiedLeidenVenueTests.swift
YouNewTests/VisitLeidenCalendarParserTests.swift
YouNewUITests/CategoryRoutingRuntimeUITests.swift
YouNewUITests/PublishedCitiesRuntimeUITests.swift
```

### Essential reproducibility tooling

The current release/content claims depend on a curated subset of `DataProject/`, the runtime JSON, the following 16 scripts, and the local workflow. Generated reports must be distinguishable from canonical inputs; `DataProject/staging/amsterdam-01-cache.json` is a local 16 MiB cache and is not a repository input until proven otherwise.

```text
.github/workflows/data-project-health.yml
scripts/amsterdam-batch-qa.py
scripts/amsterdam-data-production.py
scripts/check-external-links.py
scripts/content-text-audit.py
scripts/data-dashboard-static-qa.py
scripts/data-health-gate.py
scripts/data-observability-static-qa.py
scripts/data-operations-static-qa.py
scripts/data-project-import-static-qa.py
scripts/data-project-qa.py
scripts/data-project-workflow-static-qa.py
scripts/generate-data-dashboard.py
scripts/generate-data-observability.py
scripts/generate-data-operations.py
scripts/import-data-project.py
scripts/route-content-audit.py
```

### Must not be staged by default

- `TestArtifacts/` (about 361 MiB): xcresult/device/session diagnostics; may contain device identifiers, logs, screenshots, or user data.
- `DataProject/staging/amsterdam-01-cache.json`: generated staging cache with source/media metadata.
- `admin-dashboard/**/node_modules`, `.next`, `out`, package caches, and other generated web output.
- DerivedData, module caches, xcresult bundles, archives, provisioning profiles, certificates, `.env` files, and local logs.
- Screenshots or image files whose creator, source, license, modification terms, and redistribution rights are not confirmed.
- Root audit/migration exports until each is classified as canonical input, reproducible output, historical evidence, or private working material.

## Current failing gates

### Unit — 446/450

1. `KnowledgeDataGovernanceTests/partnerVerificationRequiresRealWebsiteAndStatus()`
2. `KnowledgeIndexTests/netherlandsKnowledgeDatabaseProvidesUnifiedDataPlatform()`
3. `KnowledgeIndexTests/allGuideArticlesCitiesAndProvincesAreIndexedForAI()`
4. `KnowledgeIndexTests/localPartnersAreIndexedForEverySupportedCityAndCoreCategory()`

No unit test is skipped. Root-cause analysis must distinguish content/product defects from test defects before any change.

### Static QA — 35/40 commands

1. `scripts/static-qa.py` — shared ambient background motion contract not satisfied.
2. `scripts/brand-static-qa.py` — the same ambient-motion root defect is independently enforced.
3. `scripts/apple-review-static-qa.py` — global AI launcher visibility rule is not satisfied for Menu, More, or Saved.
4. `scripts/persona-ia-static-qa.py` — required persona filtering is absent on specified search/guide/institution routes.
5. `scripts/content-static-qa.py` — Home Transport tile does not resolve to the expected transport guide.

These are five failing commands and four distinct root-cause groups.

### UI — 80/86

1. `AccessibilityRuntimeUITests.testAccessibilityTextSizeKeepsHomeControlsReachable()` — `home.currentProfile` measured 42 pt high versus the adopted 44 pt minimum.
2. `RootNavigationUITests.testAccessibilitySizeKeepsPrimaryHomeActionsReachable()` — same primary Home touch-target defect.
3. `ContentCompletionRuntimeUITests.testRequiredContentDestinationsRenderCompletedSurfacesWithoutPlaceholderCopy()` — `transport.screen` did not render.
4. `ContentCompletionRuntimeUITests.testRequiredContentSurfacesStayCompletedWhileScrolling()` — same Transport destination defect under scrolling coverage.
5. `PublishedCitiesRuntimeUITests.testPublishedAmsterdamMuseumFlowsFromSearchToGuideAndSaved()` — Rijksmuseum was absent from Search.
6. `YouNewUITests.testSearchAfspraakFindsDutchCourse()` — Dutch-course Search assertion failed.

No UI test was skipped or marked as an expected failure.

## Environment

| Component | Baseline |
|---|---|
| Host OS | macOS 26.5.2 (25F84), arm64 |
| Xcode | 26.6 (17F113) |
| Project | `YouNew.xcodeproj` |
| App | Swift 5 / SwiftUI; bundle `nl.younew.app`; version 1.1 (5) |
| App deployment target | iOS 17.6 |
| Current test deployment target | iOS 26.5 |
| Prior audit simulator | iPhone 17 Pro, iOS 26.5 |
| SwiftPM resolution | swift-algorithms 1.2.1; swift-async-algorithms 1.1.5; swift-collections 1.6.0; swift-numerics 1.1.1 |

At baseline capture, a read-only `simctl` inventory attempt could not connect to CoreSimulatorService in the current restricted execution context. This is recorded as an environment condition, not a product/test result. The prior evidence bundle documents a completed iPhone 17 Pro/iOS 26.5 run; the simulator will be rechecked before fresh test execution.

## Available audit artifacts

All files below were read in full before remediation began:

1. `BuildWeekAudit/AI_ASSISTANT_ARCHITECTURE.md`
2. `BuildWeekAudit/BUILD_WEEK_READINESS.md`
3. `BuildWeekAudit/CODEX_EVIDENCE.md`
4. `BuildWeekAudit/CONTENT_RELEASE_EVIDENCE.md`
5. `BuildWeekAudit/MISSING_EVIDENCE.md`
6. `BuildWeekAudit/OWNER_ACTIONS.md`
7. `BuildWeekAudit/PUBLIC_FACTS.json`
8. `BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md`
9. `BuildWeekAudit/TECHNICAL_AUDIT.md`
10. `BuildWeekAudit/TEST_AND_QA_EVIDENCE.md`

The last two are currently hidden by the broad audit/report ignore rules and need a narrow inclusion rule during repository curation.

## Safe fixation plan

1. Preserve the dirty working state on `build-week-readiness`; do not reset, stash, restore, or mass-format it.
2. Diagnose each red unit/static/UI gate against current product requirements. Change product code/data when the test correctly exposes a defect; change a test only when evidence proves its contract is stale or incorrect.
3. Rerun narrow checks after each root-cause fix, then the complete unit/static/UI gates. Do not use skip, weakened assertions, changed expected values, or unexplained sleeps.
4. Keep all currently untracked Swift files and the runtime JSON in the essential-product candidate set. Their final inclusion requires build/test and secret/privacy review, not guesswork.
5. Curate `DataProject/` into canonical inputs, schemas, policies, required manifests, and reproducible reports. Exclude the staging cache and any generated file that is neither reproducible nor needed for judge evidence.
6. Improve `.gitignore` narrowly for build/test/device/backend secret output while explicitly allowing the intended `BuildWeekAudit/` and `BuildWeekFix/` evidence packages.
7. Do not stage media until provenance is complete. Unknown-rights media remains a blocker and must be replaced, excluded from the public scope, or covered by owner-provided evidence.
8. Run final current-tree and reachable-history secret/PII/certificate/provisioning scans before proposing a commit list. Never print matched secret values.
9. Prepare small, reviewable commit groups only after gates and safety checks: baseline/evidence; product fixes; AI client/backend contract; demo/tests; repository docs/security; curated data/media; final proof.
10. Do not create a remote, push, deploy, publish, archive for distribution, upload to TestFlight, or submit without a separate owner command.

## Stage 1 result

Branch creation: **PASS**.
Dirty-tree preservation: **PASS**.
Baseline evidence: **PASS**.
Repository handoff safety: **FAIL at baseline** due to red gates, untracked essential files, missing license, incomplete media rights, absent remote/clean-clone proof, and unverified live AI.
