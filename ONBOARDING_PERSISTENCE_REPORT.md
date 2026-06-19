# Onboarding Persistence Report

Generated: 2026-06-10
Scope: release-blocker investigation and fix

## Verdict

Status: Fixed

Before this pass, onboarding completion was not persistent. `AppStateViewModel.hasCompletedQuestionnaire` was an in-memory `@Published` value initialized to `false`, and `completeQuestionnaire()` only changed the current app session.

After this pass, onboarding completion is stored in `UserDefaults` under:

`younew.onboarding.completed.v1`

Target behavior is now implemented:

- Fresh install: onboarding appears.
- Complete or skip onboarding once: app stores completion as `true`.
- Relaunch app: onboarding does not appear again.
- Explicit personal data reset in Settings: completion is reset to `false`, so onboarding can appear again.

## Storage Inventory

| Area | Storage | Key | Result |
| --- | --- | --- | --- |
| App language | `@AppStorage` | `appLanguage` | Already persistent. |
| Navigation menu position | `@AppStorage` | `settings.navigationMenuPosition` | Already persistent. |
| Atomic guide simplified mode | `@AppStorage` | `settings.atomicGuideSimplifiedMode` | Already persistent. |
| Onboarding completion | `UserDefaults` through `AppStateViewModel` | `younew.onboarding.completed.v1` | Added in this pass. |
| App data schema migration | `UserDefaults` | `appDataSchemaVersion` | Existing cache migration state. |

## Code Changes

| File | Change |
| --- | --- |
| `YouNew/ViewModels/AppStateViewModel.swift` | Added `onboardingCompletionKey`, injected `UserDefaults`, initialized `hasCompletedQuestionnaire` from storage, and persisted every completion/reset state change. |
| `YouNewTests/YouNewTests.swift` | Added `onboardingCompletionPersistsAcrossRelaunchAndReset` regression test using an isolated `UserDefaults` suite. |

## First Launch Detection

First launch is controlled by `ContentView`:

- iOS uses a full-screen cover.
- macOS uses a sheet.
- The presentation binding is `!appState.hasCompletedQuestionnaire`.

Fresh install behavior:

1. `UserDefaults.bool(forKey: "younew.onboarding.completed.v1")` returns `false`.
2. `AppStateViewModel` initializes `hasCompletedQuestionnaire` as `false`.
3. `ContentView` presents onboarding.

## Completion Behavior

Completion paths:

- Skip button in `OnboardingQuestionnaireView`
- Final "start exploring" button in `OnboardingQuestionnaireView`

Both call:

`appState.completeQuestionnaire()`

The method now sets `hasCompletedQuestionnaire = true`, which writes `true` to `UserDefaults`.

## Reset Behavior

Explicit reset path:

- Settings -> Privacy & Data Control -> Delete personal data
- Calls `appState.resetPersonalState()`
- This sets `hasCompletedQuestionnaire = false`
- The `UserDefaults` key is updated to `false`

Non-personal cache reset:

- Settings cache reset calls `AppDataMigration.resetLocalCachedData()`
- This clears legacy display/cache values, but does not reset onboarding completion.
- This is intentional because cache reset should not force a completed user through onboarding again.

## Scene Phase / Relaunch Behavior

No scene phase reload hook is needed for onboarding completion. The app constructs `AppStateViewModel` at launch. The model now reads the persisted completion key during initialization, so relaunch behavior is deterministic.

Expected lifecycle:

1. User completes onboarding.
2. App writes `younew.onboarding.completed.v1 = true`.
3. User backgrounds, terminates, or relaunches app.
4. New `AppStateViewModel` reads `true`.
5. `ContentView` does not present onboarding.

## Verification

| Check | Result |
| --- | --- |
| Source inspection for previous persistence | Failed before fix: no onboarding `@AppStorage` or `UserDefaults` key existed. |
| Persistence implementation | Passed: `AppStateViewModel` now reads and writes `younew.onboarding.completed.v1`. |
| Reset implementation | Passed: `resetPersonalState()` writes `false`. |
| Regression test added | Passed parse: `onboardingCompletionPersistsAcrossRelaunchAndReset`. |
| Swift syntax parse | Passed. |
| Static QA suite | Passed. |
| Runtime relaunch test | Pending manual device QA because simulator runtimes are unavailable in this environment. |

## Manual Verification Steps

1. Delete the app from the device.
2. Install the app.
3. Launch the app.
4. Confirm onboarding appears.
5. Complete onboarding or tap Skip.
6. Confirm Home appears.
7. Force quit the app.
8. Relaunch the app.
9. Confirm onboarding does not appear.
10. Open Settings.
11. Open Privacy & Data Control.
12. Delete personal data.
13. Relaunch the app.
14. Confirm onboarding appears again.
