# Interactivity Test Plan

Legend: ✅ verified by code/build in this pass, ⚠️ requires device or simulator runtime tap verification.

## Fixed Bugs
- ✅ AI Assistant send button dismisses keyboard by clearing `@FocusState` and resigning first responder.
- ✅ AI Assistant Return key uses `.submitLabel(.send)` and sends through the same dismiss path.
- ✅ AI Assistant chat scroll uses `.scrollDismissesKeyboard(.interactively)` plus drag dismiss fallback.
- ✅ AI Assistant empty/chat background taps dismiss keyboard.
- ✅ Home "Explore city" is a `NavigationLink` to `AppDestination.cityDetail(province:city:)`.
- ✅ Home "Explore city" has immediate haptic feedback.
- ✅ Decorative hero/map overlays have hit testing disabled where they could block controls.
- ✅ Map tab shows six overseas territory controls and presents a territory info sheet.
- ✅ Map tab province fills use province-specific vertical gradients.

## Home Screen
- ⚠️ Hero city image visible and fills card edge-to-edge.
- ⚠️ Horizontal city pills scroll left/right without bouncing off edges.
- ⚠️ Tapping city pill changes featured city (name, image, stats).
- ✅ "Explore city" button navigates to `CityDetailView`.
- ⚠️ Back button returns to home.
- ⚠️ Category stories scroll horizontally.
- ⚠️ Tapping Work opens Work/Jobs screen.
- ⚠️ Tapping Study opens Study screen.
- ⚠️ Tapping Housing opens Housing screen.
- ⚠️ Tapping Documents opens Documents screen.
- ⚠️ Tapping Transport opens Transport screen.
- ⚠️ Tapping Healthcare opens Healthcare screen.
- ⚠️ Quick Action cards all tappable with press animation.
- ✅ "Netherlands Map" section has a functional Explore Map action wired to the map tab.
- ⚠️ Emergency 112 banner tapping opens Emergency screen.
- ⚠️ Scroll to bottom: content not cut off by tab bar.

## Map Screen
- ✅ Map data contains all 12 provinces.
- ✅ Tapping province selects/highlights it.
- ✅ Province selection card appears when selected.
- ✅ Tapping same province again deselects.
- ✅ Tapping outside province deselects.
- ✅ Nearby button is wired through navigation.
- ✅ Overseas territory dots are tappable and present an info sheet.
- ✅ Compass is decorative only.
- ✅ Scale bar is decorative only.
- ✅ Legend "Ваш город" / "Города" is visible in the decoration layer.

## AI Assistant Screen
- ✅ Empty state exists on first load.
- ✅ Suggestion cards populate the input field.
- ✅ Typing in input drives orange send-button state.
- ✅ Tapping send sends and dismisses keyboard.
- ✅ Pressing Return sends and dismisses keyboard.
- ✅ Tapping chat area dismisses keyboard.
- ✅ Dragging scroll dismisses keyboard.
- ✅ Send path preserves loading state and AI response flow.
- ✅ Input field grows vertically up to 5 lines.
- ⚠️ Tab bar visible after keyboard dismissed: requires device/simulator keyboard verification.

## Search Screen
- ⚠️ Search field auto-focuses.
- ⚠️ Typing filters results in real time.
- ⚠️ Tapping result navigates to correct screen.
- ⚠️ Clear button clears input.
- ⚠️ Keyboard dismiss works with the same pattern as AI screen.

## Saved Screen
- ⚠️ Shows saved items or empty state.
- ⚠️ Tapping item navigates to detail.
- ⚠️ Delete/unsave works.

## More Screen
- ⚠️ Settings row tappable.
- ⚠️ Language selector works.
- ⚠️ About/version info visible.
- ⚠️ All list rows tappable with navigation.

## Tab Bar
- ⚠️ All 6 tabs tappable.
- ⚠️ Active tab shows orange icon + dot.
- ⚠️ Tab switch has spring animation.
- ⚠️ Haptic fires on tab switch.
- ⚠️ No tab switches without visual feedback.
- ⚠️ Double-tapping active tab scrolls to top of that screen.

## Navigation
- ⚠️ Every screen with back can navigate back.
- ⚠️ Back gesture works on all screens.
- ⚠️ Deep links work: province tap -> city tap -> back stack correct.
- ⚠️ No dead ends.

## Device Matrix
- ⚠️ iPhone SE: needs simulator/device runtime pass.
- ⚠️ iPhone 15 Pro: needs simulator/device runtime pass.
- ⚠️ iPhone 15 Pro Max: needs simulator/device runtime pass.
