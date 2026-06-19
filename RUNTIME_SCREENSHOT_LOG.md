# Runtime Screenshot Log

## 2026-05-29 20:08 Europe/Amsterdam — Stabilization Audit

Runtime screenshot capture is blocked in this session. `xcrun simctl list devices available` and `xcrun simctl list runtimes` both fail because `CoreSimulatorService` cannot initialize the simulator device set.

| Screen | Screenshot captured yes/no | Pass/fail | Issue found | File likely responsible | Action needed |
|---|---|---|---|---|---|
| Home top | No | Fail | Screenshot missing | `YouNew/Views/HomeView.swift` | Capture runtime screenshot and verify top hero/layout |
| Home bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/HomeView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify last item clears tab bar |
| Map / Nearby help bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/NearbyMapView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify support cards clear tab bar |
| Province list bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final province card visibility |
| Province detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final content clearance |
| Amsterdam city detail top | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture runtime screenshot and verify hero/fallback text |
| Amsterdam city detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final city content clears tab bar |
| Leiden city detail top | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture runtime screenshot and verify hero/fallback text |
| Leiden city detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final city content clears tab bar |
| Search bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/SearchView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final content clearance |
| Category detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/FinesInfoView.swift`, `YouNew/Views/DocumentOrganizerView.swift`, category destination views | Capture representative category detail bottom screenshot |
| Explain bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/AIAssistantView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final content clearance |
| More bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/MoreHubView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final content clearance |
| Settings bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/SettingsView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot and verify final content clearance |

### Required Bottom-Screenshot Checks

Not verified because screenshots are missing:

- Last content item fully visible above tab bar
- No tab bar overlap
- No double back button
- No clipped card
- No mixed-language UI
- No technical missing asset text

### Verdict

Not ready for TestFlight. Runtime screenshots are missing.

## 2026-05-29 20:18 Europe/Amsterdam — Visual Enrichment Pass

Runtime screenshot capture was attempted after the scoped visual enrichment pass. `xcrun simctl list devices available` and `xcrun simctl list runtimes` both failed because `CoreSimulatorService` cannot initialize the simulator device set.

| Screen | Screenshot captured yes/no | Pass/fail | Issue found | File likely responsible | Action needed |
|---|---|---|---|---|---|
| Home top | No | Fail | Screenshot missing | `YouNew/Views/HomeView.swift` | Capture runtime screenshot |
| Home bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/HomeView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot |
| Map / Nearby help bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/NearbyMapView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot |
| Province list bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot |
| Province detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot |
| Amsterdam city page | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture top and bottom screenshots |
| Leiden city page | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture top and bottom screenshots |
| Category detail | No | Fail | Screenshot missing | `YouNew/Views/FinesInfoView.swift`, `YouNew/Views/DocumentOrganizerView.swift` | Capture representative category detail |
| Explain | No | Fail | Screenshot missing | `YouNew/Views/AIAssistantView.swift` | Capture bottom screenshot and fixed-input clearance |
| More | No | Fail | Screenshot missing | `YouNew/Views/MoreHubView.swift` | Capture bottom screenshot |
| Settings | No | Fail | Screenshot missing | `YouNew/Views/SettingsView.swift` | Capture bottom screenshot |

### Verdict

Not ready for TestFlight. Runtime screenshots are missing.

## 2026-05-29 21:46 Europe/Amsterdam — Visual Enrichment Pass

Runtime screenshot capture was attempted after adding hero visuals to LGBTQ+ Support and Official Sources. `xcrun simctl list devices available` and `xcrun simctl list runtimes` both failed because `CoreSimulatorService` cannot initialize the simulator device set.

| Screen | Screenshot captured yes/no | Pass/fail | Issue found | File likely responsible | Action needed |
|---|---|---|---|---|---|
| LGBTQ+ Support | No | Fail | Screenshot missing | `YouNew/Views/LGBTQSupportView.swift` | Capture top and bottom screenshots |
| Official Sources | No | Fail | Screenshot missing | `YouNew/Views/OfficialSourceDirectoryView.swift` | Capture top and bottom screenshots |
| Category detail bottom | No | Fail | Screenshot missing; tab bar overlap not verified | Category destination views | Capture representative category bottom screenshot |
| More bottom | No | Fail | Screenshot missing; link into LGBTQ/Official Sources not verified | `YouNew/Views/MoreHubView.swift` | Capture More bottom screenshot |

### Verdict

Not ready for TestFlight. Runtime screenshots are missing.

## 2026-05-29 19:30 Europe/Amsterdam

Runtime screenshot capture was requested after the latest fixes. Capture is blocked in this sandbox because `CoreSimulatorService` is unavailable and `simctl` cannot list devices.

| Screenshot | Screen | Status | Notes |
|---|---|---|---|
| Home bottom | Home | Missing | CoreSimulatorService unavailable |
| Search bottom | Search | Missing | CoreSimulatorService unavailable |
| Map / Help nearby bottom | Map / nearby help | Missing | CoreSimulatorService unavailable |
| Province list bottom | Province directory | Missing | CoreSimulatorService unavailable |
| Province detail bottom | Province detail | Missing | CoreSimulatorService unavailable |
| Leiden city detail bottom | City detail | Missing | CoreSimulatorService unavailable |
| Amsterdam city detail bottom | City detail | Missing | CoreSimulatorService unavailable |
| Explain bottom | Explain | Missing | CoreSimulatorService unavailable |
| More bottom | More | Missing | CoreSimulatorService unavailable |
| Settings bottom | Settings | Missing | CoreSimulatorService unavailable |
| Documents bottom | Documents | Missing | CoreSimulatorService unavailable |
| Fines bottom | Fines / rules | Missing | CoreSimulatorService unavailable |

## Result

Fail for release verification. Screenshots are the source of truth, and the required runtime screenshots were not captured.

## 2026-05-29 19:36 Europe/Amsterdam

Runtime screenshot capture was attempted again before app-code changes. `xcrun simctl list devices available` and `xcrun simctl list runtimes` both failed because `CoreSimulatorService` is unavailable.

| Screenshot | Screen | Status | Notes |
|---|---|---|---|
| Home bottom | Home | Missing | CoreSimulatorService unavailable |
| Search bottom | Search | Missing | CoreSimulatorService unavailable |
| Map bottom | Map / nearby help | Missing | CoreSimulatorService unavailable |
| Province bottom | Province list/detail | Missing | CoreSimulatorService unavailable |
| City bottom | City detail | Missing | CoreSimulatorService unavailable |
| Explain bottom | Explain | Missing | CoreSimulatorService unavailable |
| More bottom | More | Missing | CoreSimulatorService unavailable |
| Settings bottom | Settings | Missing | CoreSimulatorService unavailable |
| Documents bottom | Documents | Missing | CoreSimulatorService unavailable |
| Fines bottom | Fines / rules | Missing | CoreSimulatorService unavailable |

## Result

Fail for release verification. No runtime screenshots were captured.

## 2026-05-29 19:49 Europe/Amsterdam

After increasing CityDetailView bottom reserve and improving fallback label wrapping, screenshot capture was attempted again.

| Screenshot | Screen | Status | Notes |
|---|---|---|---|
| Amsterdam top | City detail | Missing | CoreSimulatorService unavailable |
| Amsterdam middle | City detail | Missing | CoreSimulatorService unavailable |
| Amsterdam bottom | City detail | Missing | CoreSimulatorService unavailable |
| Leiden top | City detail | Missing | CoreSimulatorService unavailable |
| Leiden bottom | City detail | Missing | CoreSimulatorService unavailable |

## Result

Fail for release verification. The build passed, but runtime screenshots were not captured.

## 2026-05-29 21:55 Europe/Amsterdam — Visual Completeness / Empty State Pass

Runtime screenshot capture was attempted after adding reusable visual empty/source components and wiring them into Search, Saved, and Official Sources. `xcrun simctl list devices available` and `xcrun simctl list runtimes` both failed because `CoreSimulatorService` cannot initialize the simulator device set.

| Screen | Screenshot captured yes/no | Pass/fail | Issue found | File likely responsible | Action needed |
|---|---|---|---|---|---|
| Home top | No | Fail | Screenshot missing | `YouNew/Views/HomeView.swift` | Capture runtime screenshot |
| Home bottom | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/HomeView.swift`, `YouNew/Views/RootTabView.swift` | Capture bottom screenshot |
| Search | No | Fail | New visual empty/no-results states not runtime-verified | `YouNew/Views/SearchView.swift`, `YouNew/Components/NetherlandsVisualComponents.swift` | Capture empty, no-results, and bottom states |
| Saved | No | Fail | New visual empty state not runtime-verified | `YouNew/Views/FavoritesView.swift`, `YouNew/Components/NetherlandsVisualComponents.swift` | Capture empty and populated states |
| Map | No | Fail | Screenshot missing; tab bar overlap not verified | `YouNew/Views/NearbyMapView.swift`, `YouNew/Views/RootTabView.swift` | Capture map bottom screenshot |
| Province list | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture list bottom screenshot |
| Province detail | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture detail bottom screenshot |
| Amsterdam city detail | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture top and bottom screenshots |
| Leiden city detail | No | Fail | Screenshot missing | `YouNew/Views/ProvinceDirectoryView.swift` | Capture top and bottom screenshots |
| Category detail | No | Fail | Screenshot missing | Category destination views | Capture representative detail screenshot |
| Documents | No | Fail | Screenshot missing | `YouNew/Views/DocumentOrganizerView.swift` | Capture bottom screenshot |
| Fines | No | Fail | Screenshot missing | `YouNew/Views/FinesInfoView.swift` | Capture bottom screenshot |
| Explain | No | Fail | Screenshot missing | `YouNew/Views/AIAssistantView.swift` | Capture bottom screenshot |
| More | No | Fail | Screenshot missing | `YouNew/Views/MoreHubView.swift` | Capture bottom screenshot |
| Settings | No | Fail | Screenshot missing | `YouNew/Views/SettingsView.swift` | Capture bottom screenshot |
| Official Sources | No | Fail | New source visual cards not runtime-verified | `YouNew/Views/OfficialSourceDirectoryView.swift` | Capture top and bottom screenshots |

### Verdict

Not ready for TestFlight. Runtime screenshots are missing.
