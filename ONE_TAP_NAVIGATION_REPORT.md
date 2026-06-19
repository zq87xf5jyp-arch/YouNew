# One-Tap Navigation Report

## Result

Status: Implemented in code, runtime device verification still required.

## Root Cause

The tab dispatcher did not treat a single active-tab tap as a reset event. It also allowed menu state and navigation state to remain active in ways that made a single tap feel inconsistent.

## Files Changed

- `YouNew/Views/RootTabView.swift`
- `YouNew/Views/HomeView.swift`
- `YouNew/Views/SearchView.swift`
- `YouNew/Views/FavoritesView.swift`
- `YouNew/Views/AIAssistantView.swift`
- `YouNew/Views/NetherlandsInteractiveMapView.swift`

## Fix Applied

- Single active-tab tap now dispatches a reset immediately.
- No double tap is required.
- No precision tap is required because tab hit areas are at least 44 pt and use a full rectangular content shape.
- Open menu overlays are closed when switching to a regular tab.
- More active tap keeps the menu open and scrolls it to top.
- Map active tap closes foreground map overlays and resets transform.

## Expected User Behavior

| Action | Expected result |
| --- | --- |
| Tap Home while already on Home | Home scrolls to top |
| Tap Search while already on Search | Keyboard closes; Search scrolls to top; query remains |
| Tap Map while already on Map | Province/territory overlay closes; map resets |
| Tap Saved while already on Saved | Saved list scrolls to top |
| Tap AI Assistant while already on AI Assistant | Assistant scrolls to top; conversation remains |
| Tap More while menu is open | More menu scrolls to top |

## Verification

- Static QA: Passed.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

