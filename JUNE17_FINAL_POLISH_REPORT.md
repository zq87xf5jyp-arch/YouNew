# June 17 Final Polish Report

## Focus

Only the requested launch blockers were addressed:

- Localization
- Culture screen
- Scroll smoothness
- Transport visuals

No new feature area was added.

## Fix Summary

### Localization

Status: Fixed in code.

- English is now the release language mode.
- Runtime no longer follows Russian/Dutch device locale for normal launch.
- Stale `appLanguage` storage is reset to English.
- Settings no longer exposes non-English language choices for this launch pass.

Files:

- `YouNew/Models/LanguageManager.swift`
- `YouNew/ViewModels/AppStateViewModel.swift`
- `YouNew/Views/SettingsView.swift`

### Culture & Attractions

Status: Fixed in code.

- Rebuilt the screen into a linear reading flow: hero, intro, topic, explanation, source, next topic.
- Removed the confusing expandable card sequence.
- Removed large unrelated image reveals from the middle of the scroll.
- Converted article imagery to compact thumbnails.

File:

- `YouNew/Views/CultureAttractionsView.swift`

### Scroll Smoothness

Status: Improved in code; physical-device runtime pass still required.

- Culture screen no longer keeps expansion state or oversized inline images.
- Dutch Figures list now allows only one expanded figure at a time.
- Dutch Figures portraits were reduced from 48 pt to 42 pt and card padding was tightened.
- City detail hero height reduced from 372 pt to 320 pt, lowering repeated city-page scroll weight.
- Transport visual cards no longer use heavy Canvas-based abstract art.

Files:

- `YouNew/Views/CultureAttractionsView.swift`
- `YouNew/Views/RootTabView.swift`
- `YouNew/Views/ProvinceDirectoryView.swift`
- `YouNew/Views/TransportGuideView.swift`

### Transport Visuals

Status: Fixed in code.

- Replaced abstract transport visual cards with concrete identity cards:
  - NS trains
  - OVpay
  - 9292 planner
  - Metro
  - Bus
  - Station
- Reused verified transport media where available.
- Removed abstract hero overlays and replaced the hero badges with concrete NS / OVpay / 9292 labels.
- Reduced visual card media height to 88 pt.

File:

- `YouNew/Views/TransportGuideView.swift`

## Verification Run

| Check | Result |
| --- | --- |
| Swift parse for changed files | Passed |
| Source-level Swift typecheck for app Swift files | Passed |
| `scripts/static-qa.py` | Passed |
| `scripts/user-visible-completeness-static-qa.py` | Passed |
| `scripts/image-runtime-data-qa.py` | Passed |
| `git diff --check` for changed files | Passed |
| Full Xcode build | Failed due local `actool` / CoreSimulator runtime failure |

## Remaining Risk

Physical-device runtime verification was not performed in this session. The full Xcode build is still blocked by the local asset-catalog tool failing with:

`No available simulator runtimes for platform iphonesimulator. SimServiceContext supportedRuntimes=[]`

## Final Verdict

⚠️ TestFlight only after a successful local Xcode build and quick physical-device check of:

- English-only visible UI
- Culture & Attractions scroll
- Dutch Figures expansion
- City detail scrolling
- Transport visuals

