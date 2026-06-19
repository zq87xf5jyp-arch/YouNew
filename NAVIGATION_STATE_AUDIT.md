# Navigation & State Audit — YouNew iOS App
**Date:** 2026-06-13  
**Scope:** Full routing graph, environment objects, navigation path management, destination router

---

## Architecture Overview

```
YouNewApp (App entry)
└── @StateObject appState: AppStateViewModel        ← app-wide
    @StateObject savedItemsStore: SavedItemsStore.shared
    @StateObject languageManager: LanguageManager
    @StateObject documentStore: DocumentStore
    └── ContentView
        └── RootTabView
            ├── @StateObject tabRouter: TabRouter
            ├── @State selectedTab: AppTab
            ├── @State homeNavPath / searchNavPath / mapNavPath /
            │         favoritesNavPath / assistantNavPath: NavigationPath
            ├── tabContent (ZStack switch on selectedTab)
            │   ├── homeTabStack    → NavigationStack(path: $homeNavPath)
            │   │     └── HomeView
            │   ├── searchTabStack  → NavigationStack(path: $searchNavPath)
            │   │     └── SearchView
            │   ├── mapTabStack     → NavigationStack(path: $mapNavPath)
            │   │     └── NetherlandsMapHubView
            │   ├── favoritesTabStack → NavigationStack(path: $favoritesNavPath)
            │   │     └── FavoritesView
            │   └── assistantTabStack → NavigationStack(path: $assistantNavPath)
            │         └── AIAssistantView
            └── Each NavigationStack uses a single .navigationDestination(for: AppDestination.self)
                  └── AppDestinationView(destination:) — 40-case routing table
```

**Environment injection chain:**
- `appState`, `savedItemsStore`, `languageManager`, `documentStore` — injected at `YouNewApp`, available everywhere.
- `tabRouter` — injected at `RootTabView.body`, available to all views inside both tab stacks and overlays.

---

## Findings

---

### FIXED: Orphaned `MapViewModel @StateObject` in `RootTabView`

**Severity:** MEDIUM  
**File:** `RootTabView.swift:47` (removed)

`@StateObject private var mapViewModel = MapViewModel()` was declared in `RootTabView` but:
- Never passed to any child view
- Never injected via `.environmentObject(mapViewModel)`
- Never read or written anywhere in `RootTabView`

`NearbyMapView` creates its own `MapViewModel` instance via `viewModel ?? MapViewModel()` in its `init`. `NetherlandsInteractiveMapView` does not use `MapViewModel` at all.

The orphaned instance allocated `MapViewModel` (which holds `@Published` region/location/search state) at app startup and retained it for the entire app lifecycle without purpose.

**Fix applied:** Removed `@StateObject private var mapViewModel = MapViewModel()` from `RootTabView`.

---

### FIXED: `moreNavPath` dead state + `clearPath(for: .more)` dead branch

**Severity:** LOW-MEDIUM  
**File:** `RootTabView.swift:57` (removed), `clearPath(for:)` (updated)

`@State private var moreNavPath = NavigationPath()` was declared but:
- Never passed to any `NavigationStack` (the `.more` switch case renders `homeTabStack`, backed by `homeNavPath`)
- `clearPath(for: .more)` was the only caller — setting `moreNavPath = NavigationPath()` on dead state

Root cause: the `.more` tab does not have its own content view. When the menu opens, `selectedTab` stays on `previousContentTab` (e.g., `.home`) and only `isMenuPresented = true` changes. The `tabContent` switch never legitimately hits `.more`.

**Fix applied:**
- Removed `@State private var moreNavPath = NavigationPath()`
- In `clearPath(for:)`, merged `.more` case into `.home, .more: homeNavPath = NavigationPath()`

---

### FIXED: `tabContent` switch `.more` dead case consolidated

**Severity:** LOW  
**File:** `RootTabView.swift:603` (consolidated)

`case .more: homeTabStack` was a separate switch arm — identical outcome to `case .home`. Since `selectedTab` is never `.more` at runtime (confirmed by tracing `openMenu()` which always resets `selectedTab = previousContentTab`), this was unreachable.

**Fix applied:** Merged into `case .home, .more: homeTabStack` for correctness and clarity.

---

### CONFIRMED BUG: `AppDestination.scamWarning(UUID)` discards its associated value

**Severity:** HIGH  
**File:** `AppDestinationView.swift:144`

```swift
case .scamWarning:
    KNMGuideView(initialModuleID: "safety")
```

The pattern match ignores the `UUID` associated value. Both `.scamWarning(someUUID)` and `.scamWarningsList` navigate to the same `KNMGuideView(initialModuleID: "safety")`. Deep links to individual scam warnings silently degrade to the category list.

**Fix required:**

Either:
1. If `ScamWarning` items have a corresponding KNM module ID, thread the UUID through to `KNMGuideView`.
2. If individual routing isn't yet implemented, rename the case to make this explicit:
   ```swift
   case .scamWarning:
       KNMGuideView(initialModuleID: "safety")  // individual routing not yet implemented
   ```

The current state is silently wrong — callers believe they're navigating to a specific warning.

---

### NOTED: Duplicate tab enum (`AppTab` + `TabItem`)

**Severity:** LOW / Technical Debt  
**Files:** `TabRouter.swift`, `RootTabView.swift`

Two enums cover the same domain:
- `AppTab` (`.home, .search, .map, .favorites, .assistant, .more`) — used for `selectedTab: AppTab` in `RootTabView`
- `TabItem` (`.home, .search, .map, .saved, .ai, .more`) — used for `TabRouter.selectedTab: TabItem`

A conversion extension `AppTab.tabItem` bridges them. This adds boilerplate everywhere: `tabRouter.select(tab)` where `tab: AppTab` goes through `select(_ tab: AppTab) → select(tab.tabItem)`.

No functional bug, but every tab operation converts through this unnecessary indirection.

**Recommendation:** Consolidate to one enum. Migrate `TabRouter` to use `AppTab` directly, removing `TabItem` entirely.

---

### NOTED: `AppStateViewModel` God Object causes broad rebuild propagation

**Severity:** ARCHITECTURAL (no immediate fix)  
**File:** `AppStateViewModel.swift`

`AppStateViewModel` has 20+ `@Published` properties across multiple concerns:

| Property | Concern |
|---|---|
| `selectedCity`, `selectedUserStatus`, `userProfile` | User profile |
| `toastMessage`, `toastDismissTask` | Ephemeral UI |
| `pendingAIContext`, `pendingAIPrompt` | AI routing |
| `pendingMapFocus`, `preferredMapCategory` | Map routing |
| `checklistItems` | Feature data |
| `hasCompletedQuestionnaire` | Onboarding |

Any change to any property (e.g., `toastMessage = "Saved"`) fires `objectWillChange` on the entire object, triggering body re-evaluations in every view that holds `@EnvironmentObject private var appState: AppStateViewModel`. This includes `HomeView`, `SearchView`, `NearbyMapView`, `AIAssistantView`, etc.

**Recommendation:** Split into domain-scoped objects: `ToastViewModel`, `AIRoutingState`, `MapRoutingState`. Each subscribes only views that actually use it. This is a significant refactor — flag for a dedicated session.

---

### NOTED: `AppStateViewModel.selectedLanguage` mirrors `LanguageManager.appLanguage`

**Severity:** LOW  
**Files:** `AppStateViewModel.swift:27`, `NavigateNLApp.swift:29-33`

Two sources of truth for the app language, kept in sync by:
```swift
// onAppear:
appState.selectedLanguage = languageManager.appLanguage.rawValue
// onChange:
appState.selectedLanguage = newLanguage.rawValue
```

If any code path updates `appState.selectedLanguage` directly (bypassing `languageManager`), the two drift. Most views read from `languageManager.appLanguage` — `appState.selectedLanguage` is used by `privacyExportPayload` and `resetPersonalState`. The sync is one-directional (languageManager → appState) with no reverse path, so the risk is low but the redundancy is unnecessary.

**Recommendation:** Remove `AppStateViewModel.selectedLanguage`. Have `privacyExportPayload` accept `AppLanguage` as a parameter, or read it from `LanguageManager` directly.

---

### NOTED: String-keyed destinations in routing table are fragile

**Severity:** LOW  
**File:** `AppDestinationView.swift:32, 44`

```swift
case .institution(let name):
    MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame })

case .letter(let title):
    MockLettersData.examples.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame })
```

These destinations use string names as identifiers. Renaming an institution or letter title silently breaks any saved deep-link or cross-reference. UUID-keyed alternatives exist for most other destination types.

---

### NOTED: `AppDestination.searchList` pushes a root tab view as a detail

**Severity:** LOW  
**File:** `AppDestinationView.swift:103`

```swift
case .searchList: SearchView()
```

`SearchView` is the root content of the Search tab. Pushing it as a `NavigationStack` destination creates a nested search experience with a back button — the user sees a full search UI inside a detail sheet. This is semantically inconsistent: `SearchView` owns its own scroll, keyboard, and category state but loses the tab-level navigation context.

This may be intentional (quick-access search from any tab), but worth reviewing whether a lighter-weight search sheet would be more appropriate.

---

## Fix Summary

| # | File | Change | Severity |
|---|---|---|---|
| N1 | `RootTabView.swift` | Removed orphaned `@StateObject mapViewModel = MapViewModel()` | MEDIUM |
| N2 | `RootTabView.swift` | Removed dead `@State moreNavPath`; merged into `homeNavPath` | LOW-MEDIUM |
| N3 | `RootTabView.swift` | Consolidated dead `case .more: homeTabStack` into `case .home, .more:` | LOW |

**Requires manual fix:**

| # | File | Issue |
|---|---|---|
| N4 | `AppDestinationView.swift:144` | `.scamWarning(UUID)` discards UUID — individual warning routing broken |

**Architectural recommendations (no immediate fix):**

| # | Issue |
|---|---|
| N5 | Merge `AppTab` + `TabItem` into one enum |
| N6 | Split `AppStateViewModel` into domain-scoped view models |
| N7 | Remove `AppStateViewModel.selectedLanguage` redundancy |

---

## Verification

```
RootTabView.swift — 0 diagnostics ✓
```
