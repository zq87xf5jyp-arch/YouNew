# Touch And Scroll Device QA

## Purpose

Manual device script for the June 17 touch, tab bar, and scroll performance pass.

## Required Device Setup

- Install a fresh build on a physical iPhone.
- Test in Dark Mode and Light Mode.
- Test with normal text size and one larger Dynamic Type size.
- Run at least one pass after force quitting and relaunching the app.

## Exact Steps

1. Launch app.
2. Scroll Home down.
3. Tap Home once.
4. Expected: Home returns to top.
5. Open Map.
6. Open a province modal.
7. Scroll modal vertically from top to bottom.
8. Swipe city cards horizontally inside the province modal.
9. Tap Map once.
10. Expected: modal closes or map returns to default state.
11. Open YouNew Guide from More.
12. Scroll Dutch Figures list from top to bottom.
13. Expand 5 figures.
14. Collapse 5 figures.
15. Expected: no sticky scroll and no heavy lag.
16. Tap every bottom tab once: Home, Search, Map, Saved, AI Assistant, More.
17. Expected: immediate response for every tab.

## Additional Regression Steps

1. Open More.
2. Scroll More menu down.
3. Tap More once while it is already open.
4. Expected: menu remains open and scrolls to top.
5. Open Search and type `BSN`.
6. Scroll results down.
7. Tap Search once.
8. Expected: keyboard closes, results return to top, query remains `BSN`.
9. Open AI Assistant.
10. Send or select a quick prompt.
11. Scroll conversation.
12. Tap AI Assistant once.
13. Expected: conversation is preserved and screen scrolls to top.
14. Open Map, zoom/pan map, then open a province card.
15. Expected: province card scrolls vertically without the map stealing the gesture.

## Pass Criteria

- No tab requires a double tap.
- No tab requires tapping precisely on icon/text.
- No visible overlay blocks the bottom tab bar.
- Province cards and menus scroll without sticking.
- Horizontal carousels do not block vertical scroll once the user changes direction.
- No crash, freeze, or long stall during the guide and figures list.

## Current Execution Status

Prepared, not executed in this session.

