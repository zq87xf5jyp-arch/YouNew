# Localization Cleanup Report

## Release Language Mode

Selected release mode: English.

## Root Cause

Runtime could mix Russian, Dutch, and English because `LanguageManager` defaulted to `AppLanguage.preferredSupported`. On a Russian or Dutch device, the app could auto-select that language even though the release target is English. Existing `appLanguage` values in `UserDefaults` could also keep a stale non-English mode between installs or debug runs.

## Fixes Applied

- `LanguageManager` now pins normal runtime language to English for launch.
- Stale `appLanguage` storage is reset to English during `LanguageManager` initialization.
- `AppStateViewModel.selectedLanguage` now defaults to English.
- `AppStateViewModel.resetPersonalState()` now resets selected language to English instead of device-preferred language.
- Settings no longer presents Russian/Dutch language buttons for this release. It shows a static English release-language card instead, avoiding dead or misleading controls.

## Files Changed

- `YouNew/Models/LanguageManager.swift`
- `YouNew/ViewModels/AppStateViewModel.swift`
- `YouNew/Views/SettingsView.swift`

## Scope Notes

Dutch official product/service terms such as DigiD, BSN, OVpay, gemeente, huisarts, NS, and 9292 remain where they are real Dutch service names or practical terms a newcomer must recognize. Surrounding UI copy is English in release mode.

## Verification

- Grep check found no remaining `preferredSupported.rawValue` reset path in the patched localization files.
- Static localization QA passed for `en`, `nl`, and `ru`.
- Source-level Swift typecheck passed.
- Full Xcode build remains blocked by local `actool` / CoreSimulator runtime failure.

