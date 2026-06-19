# Stuck Scroll Root Cause Report

## Result

Status: Confirmed gesture blockers removed in code. Runtime device verification still required.

## Root Causes

| Cause | Location | Fix |
| --- | --- | --- |
| Zero-distance drag used for card press feedback | `YouNew/Resources/DesignSystem.swift` | Replaced with `LongPressGesture(minimumDuration: 0.01, maximumDistance: 12)` |
| Zero-distance drag used as Home mini-map tap detector | `YouNew/Views/HomeView.swift` | Replaced with `SpatialTapGesture` |
| Scroll-level drag used to dismiss AI keyboard | `YouNew/Views/AIAssistantView.swift` | Removed; keyboard dismissal remains via background tap and scroll keyboard behavior |
| Whole-panel drag gesture on More/Guide side menu | `YouNew/Views/RootTabView.swift` | Removed; menu scroll view now owns vertical scrolling |
| Background map gestures active under foreground overlays | `YouNew/Views/NetherlandsInteractiveMapView.swift` | Added `mapGestureMask` to defer to subviews while overlays are open |
| Overlay blocking bottom navigation | `YouNew/Views/RootTabView.swift` | Added bottom clearance and z-index ordering; toast hit testing disabled |

## Search Result

Searched `YouNew/Views`, `YouNew/Resources`, and `YouNew/Components` for:

- `DragGesture(minimumDistance: 0`
- direct `.gesture(DragGesture`
- direct `.simultaneousGesture(DragGesture`
- `highPriorityGesture`

No remaining direct matches were found after the fix pass.

## Remaining Gesture Usage

The map still uses drag internally for pan/zoom, but it is gated by `mapGestureMask` and only takes full priority when no foreground map overlay is open.

## Verification

- Static QA: Passed.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

