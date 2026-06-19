# Active Tab Reset Report

## Result

Status: Implemented in code, runtime device verification still required.

## Required Behavior Implemented

- Inactive tab tap: switches tab normally.
- Active tab tap: resets that tab to its root/top state with one tap.
- More active tap: scrolls the More menu back to the top instead of closing unexpectedly.

## Files Changed

- `YouNew/Views/RootTabView.swift`
- `YouNew/Views/HomeView.swift`
- `YouNew/Views/SearchView.swift`
- `YouNew/Views/FavoritesView.swift`
- `YouNew/Views/AIAssistantView.swift`
- `YouNew/Views/NetherlandsInteractiveMapView.swift`

## Root Cause

The previous tab tap dispatcher treated active-tab reset as a double-tap-style behavior. That did not match standard mobile expectations and made return-to-top feel unreliable.

## Fix Applied

- Added per-tab reset tokens in `RootTabView`.
- `handleTabSelection(_:)` now calls `resetTabToRoot(_:)` immediately when the tapped tab is already selected.
- `resetTabToRoot(_:)` clears active destinations, closes menu overlays, clears navigation paths for the selected tab, and increments the tab reset token.
- `HomeView`, `SearchView`, `FavoritesView`, `AIAssistantView`, and the More menu use `ScrollViewReader` top anchors.
- `SearchView` clears keyboard focus on active Search tap while preserving the query.
- `AIAssistantView` scrolls to the assistant top and dismisses keyboard without erasing conversation.
- `NetherlandsMapHubView` closes selected province/territory overlays and resets map scale/offset.

## Tab Behaviors

| Tab | One-tap active reset behavior |
| --- | --- |
| Home | Scrolls Home to top |
| Search | Clears keyboard focus and scrolls results to top; query remains |
| Map | Closes province/territory overlays and resets map transform |
| Saved | Scrolls saved list to top |
| AI Assistant | Scrolls assistant to top; conversation remains |
| More | Scrolls side menu to top |

## Verification

- Static QA: Passed.
- User-visible completeness static QA: Passed.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

