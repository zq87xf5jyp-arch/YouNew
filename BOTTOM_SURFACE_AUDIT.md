# Bottom Surface Audit

Date: 2026-06-14

## Root Cause

The root floating tab bar already reserves bottom space through `FloatingTabBarMetrics.rootContentInset`. The AI Assistant added a second bottom reserve inside its composer overlay, ignored the bottom safe area, and rendered full-width opaque backgrounds behind the safety notice and input row. This created the black rectangular slab visible in IMG_6805.jpg.

## Fixes Applied

| Screen | File | Fix |
|---|---|---|
| Root shell | `YouNew/Views/RootTabView.swift` | Replaced the fragile manually sized/positioned root background with a full-screen `GlobalBackgroundView().ignoresSafeArea()`. |
| Root shell | `YouNew/Views/RootTabView.swift` | Removed root-level bottom content padding in the bottom tab layout so the shell no longer creates a separate empty slab behind child screens. |
| Floating tab bar | `YouNew/Views/RootTabView.swift` | Removed `.ignoresSafeArea(edges: .bottom)` from the floating tab bar's own capsule background so it cannot paint outside its visible pill. |
| AI Assistant | `YouNew/Views/AIAssistantView.swift` | Empty state now uses the same safe-area-aware composer reserve as chat messages instead of a fixed legacy bottom spacer. |
| AI Assistant | `YouNew/Views/AIAssistantView.swift` | Removed the duplicated empty-state safety text; the safety warning is now rendered once in the bottom composer area. |
| AI Assistant | `YouNew/Views/AIAssistantView.swift` | Removed full-width bottom backgrounds from the safety notice and input row. Only the text field and send button keep their own local surfaces. |

## Remaining Bottom Hosts Reviewed

- `RootTabView` remains the owner of the floating tab bar.
- `HomeView`, map views, and onboarding still use bottom/safe-area modifiers for their own screens; they were not changed because the current red-marked defect was isolated to AI Assistant.

## Verification

- macOS Debug build: PASS.
- Source check: no Swift literal `Content not found.` remains; floating tab bar no longer ignores the bottom safe area.
- Runtime screenshot verification after fix: NOT PERFORMED because simulator/device runtime is unavailable from this environment.
