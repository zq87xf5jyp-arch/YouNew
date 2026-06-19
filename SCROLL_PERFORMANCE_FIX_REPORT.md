# Scroll Performance Fix Report

## Result

Status: Targeted fixes applied, runtime FPS/memory measurement still required on device.

## Exact Causes Found

- Shared card press feedback used a zero-distance `DragGesture`, which can compete with `ScrollView` pan recognition in carousels and long lists.
- The AI Assistant scroll view had a broad simultaneous drag handler to dismiss the keyboard, creating another gesture competitor.
- The right-side menu panel had a whole-panel drag gesture, which could intercept vertical scroll in YouNew Guide and Dutch Figures areas.
- The map pan/zoom gesture remained active while map overlays were open.
- Home mini-map tap detection used zero-distance drag.

## Files Changed

- `YouNew/Resources/DesignSystem.swift`
- `YouNew/Views/AIAssistantView.swift`
- `YouNew/Views/RootTabView.swift`
- `YouNew/Views/NetherlandsInteractiveMapView.swift`
- `YouNew/Views/HomeView.swift`

## Fixes Made

- Replaced shared `PressableModifier` zero-distance drag with a tiny `LongPressGesture` for visual press state.
- Removed the AI Assistant broad scroll-level drag gesture.
- Removed the whole-panel side-menu drag gesture.
- Added reset-token top scrolling for long root tab scroll views.
- Gated map pan/zoom while overlays are presented.
- Replaced Home mini-map zero-distance drag with `SpatialTapGesture`.

## Performance-Oriented Checks

- Long lists still use lazy containers where already present, including AI message rendering.
- No random `UUID()`-style reset was introduced in view bodies during this pass.
- No additional image decoding path was added.
- No new blur-heavy or shadow-heavy repeated cells were introduced.

## Remaining Risks

- Scroll FPS and memory usage were not measured in this session because runtime/device verification was not available here.
- Existing older visual work in the dirty worktree may still affect performance outside the gesture conflicts fixed in this sprint.

## Verification

- Static QA: Passed.
- User-visible completeness static QA: Passed.
- Image runtime data QA: Passed.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

