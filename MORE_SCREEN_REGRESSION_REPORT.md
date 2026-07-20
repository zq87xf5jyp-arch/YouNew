# More Screen Regression Report

Date: 2026-06-18

## Scope

This report covers the P0 More screen layout regression pass requested after the release readiness audit. The focus was limited to the existing implementation: More screen hero sizing, vertical spacing, tab-bar safe area behavior, and the floating AI launcher overlay.

No redesign or duplicate system was introduced.

## P0 Findings And Fixes

### P0 BUG #1 - More Screen Hero Expansion

Status: Fixed in code, guarded by static QA, and verified by focused simulator UI test.

Problem:
- The shared `CategoryHeroVisual` accepted a height but did not constrain its final frame with a fixed resolved height.
- In an expanding parent, the hero could grow beyond its intended card size and visually behave like a full-screen image.
- A focused simulator UI test exposed a second issue: the grouped hero accessibility element was reported at 1053.8 pt tall, even after the visual source-level clamp. That created a real accessibility/regression risk, so the accessibility surface was fixed instead of weakening the test.

Fix:
- `CategoryHeroVisual` now clamps requested hero height to the regression-safe range of 220-320 pt.
- The hero card now uses the resolved value as its fixed height, preventing parent-driven expansion.
- The More screen now requests a 240 pt hero height.
- The oversized grouped hero accessibility element was removed; the visible hero text remains accessible through its normal text elements.
- A bounded, non-interactive More hero bounds marker is exposed only for regression verification.

Files:
- `YouNew/Components/NetherlandsVisualComponents.swift`
- `YouNew/Views/MoreHubView.swift`

Verification:
- Static QA enforces `let resolvedHeight = min(max(height, 220), 320)`.
- Static QA enforces `.frame(height: resolvedHeight, alignment: .bottomLeading)` and the bounded max-width frame.
- Static QA enforces More hero `height: 240`.
- Focused simulator UI test passed: `YouNewUITests.testMoreMenuLayoutKeepsHeroBoundedAndAIHidden`.

### P0 BUG #2 - Floating AI Button Covers More Content

Status: Fixed in code, guarded by static QA, and verified by focused simulator UI test.

Problem:
- The global contextual AI button was eligible to appear above the More tab.
- On dense card layouts this could overlap actionable content, the hero, or bottom cards.

Fix:
- The global contextual AI launcher is now hidden on the More tab.
- More still retains its existing local AI entry points and assistant-related cards.
- Root safe-area reservation is no longer added for the global AI launcher while More is selected.

Files:
- `YouNew/Views/RootTabView.swift`

Verification:
- Static QA enforces `!isMenuPresented && selectedTab != .assistant && selectedTab != .more`.
- Static QA guard exists for the root visibility condition.
- Focused simulator UI test asserts `global.aiLauncher` is absent on More.

### P0 BUG #3 - Large Empty Areas

Status: Fixed for the identified More regression path; no new risky expansion found in `MoreHubView`.

Findings:
- `MoreHubView.swift` does not use `GeometryReader`, `containerRelativeFrame`, or `maxHeight: .infinity`.
- The More hero is now bounded to a fixed card height.
- The global AI overlay reserve is removed from More by hiding the launcher on that tab.
- Remaining `Spacer` usage in `MoreHubView.swift` is localized inside rows/cards and does not create page-level artificial gaps.

Verification:
- Focused source scan completed for `MoreHubView.swift`, `NetherlandsVisualComponents.swift`, and `RootTabView.swift`.
- Focused source scan completed for `MoreHubView.swift`, `NetherlandsVisualComponents.swift`, and `RootTabView.swift`.
- Focused simulator UI test verifies the dashboard follows the hero without a large artificial gap.

### P0 BUG #4 - More Screen Layout Integrity

Status: Fixed in code; focused automated verification passed. Manual visual certification is still required before claiming App Store readiness.

Checked:
- Hero remains a bounded card.
- Hero image remains clipped inside the card.
- Floating AI launcher does not overlay More.
- More tab still preserves tab-bar/safe-area behavior.
- No source-level evidence of unbounded More page expansion remains.

Verification:
- Focused simulator UI test passed: `xcodebuild ... -only-testing:YouNewUITests/YouNewUITests/testMoreMenuLayoutKeepsHeroBoundedAndAIHidden test`.
- Static QA passed after the final accessibility-surface adjustment.
- Simulator `build-for-testing` passed after the final accessibility-surface adjustment.

## Verification Commands

Passed:
- `scripts/run-static-qa.sh`
- `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination id=<SIMULATOR_UDID> -derivedDataPath <TEMP_DIR>/LayoutRegression -parallel-testing-enabled NO -only-testing:YouNewUITests/YouNewUITests/testMoreMenuLayoutKeepsHeroBoundedAndAIHidden test`
- `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination id=<SIMULATOR_UDID> -derivedDataPath <TEMP_DIR>/LayoutRegression build-for-testing`

## Remaining Release Risk

This regression is fixed at the source level and has focused simulator verification for the More hero, dashboard spacing, tab-bar overlap, and hidden global AI launcher.

Before final TestFlight/App Store readiness is claimed, run a live visual pass on simulator or device for:
- More tab at small and large Dynamic Type.
- Light and Dark Mode.
- iPhone compact height and large iPhone.
- Scroll from top hero through bottom cards.
- Tab switching into and out of More.

Current readiness statement: not yet safe to claim App Store Ready from this regression pass alone because live visual screenshots/manual interaction were not completed in this pass.
