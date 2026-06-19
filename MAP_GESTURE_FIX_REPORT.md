# Map Gesture Fix Report

## Result

Status: Fixed in code, runtime device verification still required.

## Root Cause

The map layer kept its pan/zoom gesture active while province overlays or territory sheets were open. That allowed the background map gesture to compete with vertical scrolling inside foreground cards.

## Files Changed

- `YouNew/Views/NetherlandsInteractiveMapView.swift`
- `YouNew/Views/HomeView.swift`

## Fix Applied

- Added `mapGestureMask` in `NetherlandsMapHubView`.
- The map pan/zoom gesture now receives `.all` only when no province card or territory sheet is open.
- When a foreground overlay is open, the map gesture mask switches to `.subviews`, so modal/card scroll gestures can win.
- Active Map tab tap now calls `resetMapInteractionState()` to close overlays and restore scale/offset.
- Decorative map layers already use `allowsHitTesting(false)`.
- The Home mini-map province picker now uses `SpatialTapGesture` instead of a zero-distance drag.

## Before Behavior

- Province cards could feel sticky when vertical scrolling.
- Background map gestures could compete with foreground overlay scrolling.
- The Home map card used a zero-distance drag for tap behavior, which could interfere with parent scrolling.

## After Behavior

- Province overlays have priority for vertical scroll.
- Map pan remains available when the map itself is the active interaction surface.
- Home mini-map taps no longer masquerade as drags.

## Verification

- Gesture blocker search: No remaining `DragGesture(minimumDistance: 0)` found in the inspected app view/resource/component files.
- Static QA: Passed.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

