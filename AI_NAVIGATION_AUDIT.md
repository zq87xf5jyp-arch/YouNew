# AI Navigation Audit

Date: 2026-06-16

## Floating Controls

Issue:
- The global contextual AI launcher remained visible on the Assistant tab.
- On iPhone it could overlap the newest answer card and composer area.

Fix:
- `RootTabView.shouldShowContextualAIButton` now returns false while `selectedTab == .assistant`.

Result:
- Assistant content is no longer covered by the AI launcher.
- The launcher remains available on non-Assistant tabs.

## Source Navigation

Issue:
- Source rows exposed URL text directly in answer cards.

Fix:
- Source rows now render as verified source cards.
- External navigation is exposed through an `Open Source` button.
- Accessibility hint still contains the host for context, without placing raw URLs in the visual answer body.

## App Destination Mapping

Verification:
- `BSN` maps to a verified BSN destination.
- `transport` maps to a verified transport destination.
- `housing` maps to a verified housing destination.

No fallback is used when verified local data exists for these topics.

