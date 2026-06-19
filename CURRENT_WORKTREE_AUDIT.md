# Current Worktree Audit

**Date:** 2026-05-29 20:08 Europe/Amsterdam  
**Branch:** `main`  
**Audit mode:** stabilization only. No files were reverted and no feature work was added.

## Command Results

| Command | Result |
|---|---|
| `git status` | Many staged additions, unstaged modifications/deletions, and untracked files are present. |
| `git diff --stat` | 34 files changed, 6682 insertions, 1276 deletions. |
| `BuildProject` | Pass. Full Xcode build succeeded. |
| Runtime screenshots | Not captured. `CoreSimulatorService` is unavailable from this session. |

## Modified Files

Unstaged modified files:

- `LOCALIZATION_AUDIT.md`
- `QA_REPORT.md`
- `YouNew.xcodeproj/project.pbxproj`
- `YouNew/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `YouNew/Components/AppAtmosphereBackground.swift`
- `YouNew/Components/NLDesignSystem.swift`
- `YouNew/Components/NetherlandsVisualComponents.swift`
- `YouNew/ContentView.swift`
- `YouNew/Data/MockBeginnerGuidesData.swift`
- `YouNew/Data/MockLGBTQSupportData.swift`
- `YouNew/Models/FineInfoItem.swift`
- `YouNew/Models/NewcomerMistake.swift`
- `YouNew/Resources/AppColors.swift`
- `YouNew/Services/AIContextBuilder.swift`
- `YouNew/Services/AISafetyRules.swift`
- `YouNew/Services/MockAIService.swift`
- `YouNew/Utilities/AppDataMigration.swift`
- `YouNew/ViewModels/AIViewModel.swift`
- `YouNew/Views/FinesInfoView.swift`
- `YouNew/Views/HomeView.swift`
- `YouNew/Views/KnowledgeDebugView.swift`
- `YouNew/Views/LegalDisclaimerView.swift`
- `YouNew/Views/PrivacyDataControlView.swift`
- `YouNew/Views/ProvinceDirectoryView.swift`
- `YouNew/Views/RootTabView.swift`
- `YouNewTests/KnowledgeTopicQuickAnswerTests.swift`
- `YouNewTests/OfficialServicesDirectoryTests.swift`
- `YouNewTests/RoadmapDataTests.swift`
- `YouNewTests/YouNewTests.swift`
- `YouNewUITests/HomeCategoryUITests.swift`
- `YouNewUITests/LocalizationRegressionUITests.swift`
- `YouNewUITests/YouNewUITests.swift`

## Added Files

Staged added files include:

- `APP_STORE_PACKAGE.md`
- `ARCHITECTURE.md`
- `ASSET_CREDITS.md`
- `BackendExamples/cloudflare-worker-ai-proxy.js`
- `CITY_ASSET_REQUIREMENTS.md`
- `LOCALIZATION_AUDIT.md`
- `MANUAL_RUNTIME_QA_CHECKLIST.md`
- `MISSING_CITY_ASSETS.md`
- `QA_REPORT.md`
- `README.md`
- `RUNTIME_ACTIVE_FILES.md`
- `YouNew/Assets.xcassets/drenthe_flag.imageset/Contents.json`
- `YouNew/Assets.xcassets/drenthe_flag.imageset/drenthe_flag.svg`
- `YouNew/Assets.xcassets/map_drenthe.imageset/map_drenthe.svg`
- `YouNew/Components/AIAskButton.swift`
- `YouNew/Components/AppAtmosphereBackground.swift`
- `YouNew/Components/NLDesignSystem.swift`
- `YouNew/Components/NetherlandsVisualComponents.swift`
- `YouNew/Data/MockBeginnerGuidesData.swift`
- `YouNew/Data/MockDeadlinesData.swift`
- `YouNew/Data/MockDutchTermsData.swift`
- `YouNew/Data/MockLGBTQSupportData.swift`
- `YouNew/Data/MockLettersData.swift`
- `YouNew/Data/MockNetherlandsUnderstandingData.swift`
- `YouNew/Data/MockResourcesData.swift`
- `YouNew/Data/MockRiskData.swift`
- `YouNew/Models/AIContext.swift`
- `YouNew/Models/FineInfoItem.swift`
- `YouNew/Models/NewcomerMistake.swift`
- `YouNew/Models/ResourceLinkItem.swift`
- `YouNew/PrivacyInfo.xcprivacy`
- `YouNew/Resources/AppColors.swift`
- `YouNew/Services/AIClient.swift`
- `YouNew/Services/AIContextBuilder.swift`
- `YouNew/Services/AIErrorHandler.swift`
- `YouNew/Services/AIResponseParser.swift`
- `YouNew/Services/AISafetyFilter.swift`
- `YouNew/Services/AISafetyRules.swift`
- `YouNew/Services/AIService.swift`
- `YouNew/Services/AIUsageLimiter.swift`
- `YouNew/Services/MockAIService.swift`
- `YouNew/Utilities/AppDataMigration.swift`
- `YouNew/ViewModels/AIViewModel.swift`
- `YouNew/Views/FinesInfoView.swift`
- `YouNew/Views/HomeView.swift`
- `YouNew/Views/KnowledgeDebugView.swift`
- `YouNew/Views/LegalDisclaimerView.swift`
- `YouNew/Views/PrivacyDataControlView.swift`
- `YouNew/Views/ProvinceDirectoryView.swift`
- `YouNew/Views/RootTabView.swift`
- `YouNewTests/AIContextBuilderTests.swift`
- `YouNewTests/AIContextExpansionTests.swift`
- `YouNewTests/AIFoundationTests.swift`
- `YouNewTests/FuzzySearchTests.swift`
- `YouNewTests/KnowledgeTopicQuickAnswerTests.swift`
- `YouNewTests/OfficialServicesDirectoryTests.swift`
- `YouNewTests/RoadmapDataTests.swift`
- `YouNewTests/SearchSynonymTests.swift`
- `YouNewUITests/HomeCategoryUITests.swift`
- `YouNewUITests/LocalizationRegressionUITests.swift`

Untracked added files include source files, localization folders, assets, release documents, `CURRENT_WORKTREE_DIFF.patch`, and local build output directories.

## Deleted Files

Unstaged deleted files:

- `YouNew/Item.swift`
- `YouNew/YouNewApp.swift`

## Grouped Change Categories

### 1. Tab Bar / Layout

| Files | Status | Risk |
|---|---|---|
| `YouNew/Views/RootTabView.swift`, `YouNew/ContentView.swift`, `YouNew/Components/AppAtmosphereBackground.swift`, `YouNew/Components/NLDesignSystem.swift`, `YouNew/Views/HomeView.swift`, `YouNew/Views/FinesInfoView.swift`, `YouNew/Views/PrivacyDataControlView.swift` | Needs runtime verification | High |

Reason: these files can affect floating tab bar clearance, scroll bottom spacing, compact-width layout, and card clipping. Screenshots are required before release confidence.

### 2. Navigation

| Files | Status | Risk |
|---|---|---|
| `YouNew/Views/RootTabView.swift`, `YouNew/ContentView.swift`, `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/HomeView.swift`, `YouNew.xcodeproj/project.pbxproj`, `YouNew/NavigateNLApp.swift`, deleted `YouNew/YouNewApp.swift` | Should be manually reviewed | High |

Reason: app entry and route-host files are in flux. Double back buttons, route regressions, and target membership issues need manual review plus runtime navigation checks.

### 3. Localization

| Files | Status | Risk |
|---|---|---|
| `YouNew/en.lproj/`, `YouNew/nl.lproj/`, `YouNew/ru.lproj/`, `YouNew/Resources/L10n.swift`, `LOCALIZATION_AUDIT.md`, `YouNewUITests/LocalizationRegressionUITests.swift` | Needs runtime verification | Medium |

Reason: build passes, but mixed-language UI can only be confirmed on-device/simulator across target screens.

### 4. City / Province Data

| Files | Status | Risk |
|---|---|---|
| `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Data/MockExpansionData.swift`, `YouNew/Data/MockNearbyPlacesData.swift`, `YouNew/Models/ExpansionModels.swift`, province/city tests | Needs runtime verification | Medium |

Reason: province and city data feed active navigation and detail pages. Build passes, but Amsterdam/Leiden top and bottom screenshots remain missing.

### 5. Visual Assets / Generated Graphics

| Files | Status | Risk |
|---|---|---|
| `YouNew/Components/NetherlandsVisualComponents.swift`, `YouNew/Components/NLDesignSystem.swift`, `YouNew/Views/HomeView.swift`, `YouNew/Views/NearbyMapView.swift`, `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Assets.xcassets/` | Needs runtime verification | High |

Reason: generated graphics and assets can affect performance, clipping, contrast, and missing-asset presentation. Runtime screenshots are required.

### 6. Documents / QA Reports

| Files | Status | Risk |
|---|---|---|
| `README.md`, `ARCHITECTURE.md`, `APP_STORE_PACKAGE.md`, `QA_REPORT.md`, `MANUAL_RUNTIME_QA_CHECKLIST.md`, `RUNTIME_ACTIVE_FILES.md`, `RUNTIME_SCREENSHOT_LOG.md`, `ASSET_CREDITS.md`, `CITY_ASSET_REQUIREMENTS.md`, `MISSING_CITY_ASSETS.md`, privacy/release/legal docs | Safe to keep, but manually review release claims | Medium |

Reason: documentation is useful, but release wording must not claim App Store or TestFlight readiness while runtime screenshots are missing.

### 7. Other Unrelated Changes

| Files | Status | Risk |
|---|---|---|
| `BackendExamples/cloudflare-worker-ai-proxy.js`, AI service/client/parser files, safety rules, migration utilities, app icon files, generated build folders, `CURRENT_WORKTREE_DIFF.patch`, broad untracked source files | Suspicious/unrelated or should be manually reviewed | Medium to High |

Reason: these changes are outside the current visual/runtime stabilization scope. Generated build folders and Xcode user data should not be committed.

## Manual Review Notes

- Do not revert anything automatically.
- Keep generated build folders out of commits: `.DerivedData/`, `.DerivedDataCodex/`, `.DerivedDataLocal/`, `.DerivedDataMac/`, `.derivedData 2/`, `DerivedData/`.
- Keep Xcode user state out of commits: `YouNew.xcodeproj/xcuserdata/`.
- Review deleted app-entry files before staging: `YouNew/YouNewApp.swift`.
- Review project target membership after broad new-file additions.

## Stabilization Verdict

Not ready for TestFlight. Runtime screenshots are missing.
