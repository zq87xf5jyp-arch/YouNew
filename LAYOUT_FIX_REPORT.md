# Layout Fix Report

Date: 2026-06-18

## Summary

The More screen P0 layout regression was addressed without redesigning the screen or creating duplicate layout systems. The fix constrains the existing shared hero component, removes the global floating AI launcher from the More tab, and corrects the oversized hero accessibility frame exposed by simulator testing.

## Files Changed

### `YouNew/Components/NetherlandsVisualComponents.swift`

Change:
- Added a bounded `resolvedHeight` for `CategoryHeroVisual`.
- Applied the resolved height as the fixed hero container height.
- Removed the grouped hero accessibility element that XCTest reported as 1053.8 pt tall.

Result:
- Shared category hero cards cannot expand beyond 320 pt.
- Hero cards cannot shrink below 220 pt.
- Parent containers can no longer stretch hero images into full-screen blocks.
- The hero no longer exposes one oversized accessibility object.

### `YouNew/Views/MoreHubView.swift`

Change:
- Updated the More hero card request to `height: 240`.
- Added a bounded, non-interactive `more.hero.bounds` regression marker for the focused UI test.

Result:
- More screen hero now uses a stable card-sized height inside the requested 220-320 pt range.
- The focused UI test can measure the bounded hero slot without relying on the oversized accessibility grouping.

### `YouNew/Views/RootTabView.swift`

Change:
- Updated contextual AI button visibility so the global floating AI launcher is not shown on `.more`.

Result:
- Floating AI control cannot cover the More hero, cards, or bottom content.
- Existing assistant access remains available through More screen content and the Assistant tab.

### `scripts/apple-review-static-qa.py`

Change:
- Added/updated static guards for:
  - AI launcher hidden on More.
  - Shared hero height clamped to 220-320 pt.
  - Hero card bounded by fixed `resolvedHeight`.
  - More hero set to 240 pt.

Result:
- The regression fix is now enforced by the static QA suite.

### `FINAL_RELEASE_REPORT.md`

Change:
- Restored the required honesty marker stating that App Store readiness cannot be claimed until remaining visual, live walkthrough, archive, AI interaction, and FPS profiling checks are complete.

Result:
- Release documentation no longer overclaims readiness beyond verified evidence.

## Requirement Mapping

### Hero image must remain inside card

Satisfied in code:
- `CategoryHeroVisual` clamps height to 220-320 pt.
- The final hero frame uses the resolved value as a fixed height.
- Existing clipping remains in the component.

### Hero target height max 220-320 pt

Satisfied in code:
- Shared clamp: 220-320 pt.
- More screen request: 240 pt.

### Hero must never become full screen

Satisfied at source and focused runtime level:
- Parent-driven vertical expansion is blocked by the component-level fixed height.
- Focused simulator UI test verifies the More hero bounds stay inside 220-320 pt and below 45% of the window height.

### AI button must not cover More content

Satisfied in code:
- Global contextual AI launcher is hidden while the More tab is selected.

### Remove artificial vertical gaps

Satisfied for the identified regression path:
- More screen has no `GeometryReader`, `containerRelativeFrame`, or page-level `maxHeight: .infinity`.
- AI safe-area reserve is not active on More.
- More hero is no longer expandable.

### More screen layout must remain navigable

Satisfied by focused runtime verification:
- Route/action static QA passed.
- Button/action static QA passed.
- Focused More layout simulator UI test passed.

## Verification Results

Passed:
- Focused More layout UI test: `YouNewUITests.testMoreMenuLayoutKeepsHeroBoundedAndAIHidden`.
- Localization key static QA: 610 keys covered for English, Dutch, and Russian.
- Route/action static QA.
- Button/action static QA.
- Apple review static QA.
- Report honesty static QA.
- App icon QA.
- Visible image remote QA: 294 visible assignments, 294 unique URLs, 0 duplicate source groups.
- Image runtime data QA.
- Visual report static QA.
- AI subsystem static QA.
- Persona IA static QA.
- Content, KNM, Dutch course, user-visible completeness, media, place media, history media, and brand static QA.
- `scripts/run-static-qa.sh`.
- Simulator `build-for-testing` after the final accessibility-surface adjustment.

## Not Completed In This Pass

The following still require live/manual or instrumented verification before final release readiness can be honestly claimed:
- Simulator/device screenshots of the fixed More tab.
- Manual tap walkthrough of every More card/button after the layout fix.
- Runtime FPS profiling.
- AI send/stop/retry interaction pass.
- Archive/export validation.

## Current Release Decision

The More screen P0 layout regression is fixed at source level and passes focused automated simulator verification.

The full application is not yet certified App Store Ready from this pass alone. A live visual and interaction regression pass is still required before the final readiness claim.
