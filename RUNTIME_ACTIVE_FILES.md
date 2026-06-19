# Runtime Active Files

**Date:** 2026-05-29  
**Status:** active build graph confirmed by Xcode build; visual simulator marker screenshots not captured because `xcrun simctl` cannot connect to CoreSimulatorService in this sandbox.

## Active Entry Points

| Runtime role | Active file |
|---|---|
| `@main` app | `YouNew/NavigateNLApp.swift` |
| Root content | `YouNew/ContentView.swift` |
| Root tab container | `YouNew/Views/RootTabView.swift` |
| Floating tab bar | `YouNew/Views/RootTabView.swift` (`FloatingTabBar`) |
| Home | `YouNew/Views/HomeView.swift` |
| Map / Help nearby | `YouNew/Views/NearbyMapView.swift` |
| Search | `YouNew/Views/SearchView.swift` |
| Saved | `YouNew/Views/FavoritesView.swift` |
| Explain | `YouNew/Views/AIAssistantView.swift` |
| More | `YouNew/Views/MoreHubView.swift` |
| City detail | `YouNew/Views/ProvinceDirectoryView.swift` (`CityDetailView`) |
| City data source | `YouNew/Views/ProvinceDirectoryView.swift` (`ProvinceCatalog`) |
| Asset existence helper | `YouNew/Views/ProvinceDirectoryView.swift` (`AssetAvailability`) |
| Localization | `YouNew/*.lproj/Localizable.strings`, `YouNew/Resources/L10n.swift` |

## Exact String Search Results

| Visible string group | Found in |
|---|---|
| Home hero (`Clear next steps...`, `Понятные шаги...`, `Start with your situation`, `Начните...`) | `YouNew/Views/HomeView.swift`, `YouNew/Resources/L10n.swift` |
| Map RU labels (`Помощь рядом`, `Опорные сервисы по городу`, `Все провинции`, `Город`, `Готовые маршруты`) | `YouNew/Views/NearbyMapView.swift`, `YouNew/Resources/L10n.swift`, `YouNew/ru.lproj/Localizable.strings` |
| City names/details (`Amsterdam`, `Leiden`, `North Holland`, `South Holland`, descriptions, GVB, Flag, Coat of arms, Open on map, Short history) | `YouNew/Views/ProvinceDirectoryView.swift`, `YouNew/*.lproj/Localizable.strings`, `YouNew/Resources/L10n.swift` |
| Tab labels (`Home`, `Search`, `Map`, `Saved`, `Explain`, `More`, RU equivalents) | `YouNew/Views/RootTabView.swift`, `YouNew/*.lproj/Localizable.strings`, `YouNew/Resources/L10n.swift` |

## Duplicate / Inactive Findings

No separate `CityDetailView.swift`, `FloatingTabBar.swift`, or `CustomTabBar.swift` is active. Editing a hypothetical standalone city detail or tab bar file would not affect runtime. `CityDetailView` and `FloatingTabBar` are nested in active files.

## Proof Marker Pass

Temporary markers were inserted in:

| Marker | File |
|---|---|
| `DEBUG_ACTIVE_HOME` | `YouNew/Views/HomeView.swift` |
| `DEBUG_ACTIVE_MAP` | `YouNew/Views/NearbyMapView.swift` |
| `DEBUG_ACTIVE_CITY_DETAIL` | `YouNew/Views/ProvinceDirectoryView.swift` |

Xcode `BuildProject` succeeded with the marker edits, proving these files are in the active target build graph. The markers were removed before the final build. Simulator screenshot proof remains blocked and must be done manually.
