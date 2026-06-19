# Tab Bar Hit Area Report

## Result

Status: Fixed in code, runtime device verification still required.

## Root Cause

The custom floating tab bar relied on the visual icon/text layout for tap behavior. The button label was visually large, but the reliable tappable surface was not explicitly guaranteed on every tab item. The More overlay could also sit above the bottom navigation area when opened from compact bottom navigation, making taps feel swallowed.

## Files Changed

- `YouNew/Views/RootTabView.swift`

## Fix Applied

- Every floating tab button now has a minimum 44 pt tappable target using `AppIcons.Metrics.minimumTouchTarget`.
- Each tab button and tab item has `contentShape(Rectangle())`.
- The floating tab bar is promoted with `zIndex(100)`.
- Toast overlays have `allowsHitTesting(false)` so they cannot intercept bottom-tab taps.
- The right-side menu overlay reserves bottom-tab clearance on compact bottom navigation, preventing the menu backdrop from covering the tab bar.
- The More tab now visually reflects the open menu state through a binding that marks More selected while the menu is presented.

## Before Behavior

- Taps near the edges of tab items could feel unreliable.
- Open overlays could intercept taps intended for the tab bar.
- The More tab could open an overlay while the bottom bar remained visually available but partially blocked.

## After Behavior

- Home, Search, Map, Saved, AI Assistant, and More have predictable 44 pt minimum hit areas.
- Decorative/toast layers no longer block taps.
- The bottom tab bar stays above page content and remains tappable when the More menu is open.

## Verification

- Static QA: Passed.
- User-visible completeness static QA: Passed.
- Touch-blocker search: No remaining `DragGesture(minimumDistance: 0)`, direct `highPriorityGesture`, or broad direct `DragGesture` patterns found in `Views`, `Resources`, or `Components`.
- Swift syntax parse for touched files: Passed.
- Full Xcode build: Blocked by local `actool` / CoreSimulator runtime failure, not confirmed.

