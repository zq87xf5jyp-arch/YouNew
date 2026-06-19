# AI Layout Audit

Date: 2026-06-16

## Composer

Issue:
- The input composer was inserted with `safeAreaInset`, but the scroll reserve used a fixed height estimate.
- Dynamic composer growth could exceed the estimate and visually collide with content or navigation chrome.

Fix:
- Added `AssistantComposerHeightPreferenceKey`.
- The Assistant screen measures actual composer height.
- Scroll bottom padding uses:
  - measured composer height
  - floating tab bar height
  - floating tab bar bottom offset
  - safe area bottom

## Tab Bar Clearance

Issue:
- The root tab bar is hosted outside the Assistant scroll content.
- Assistant content needed explicit terminal clearance.

Fix:
- The composer inset includes a clear non-interactive clearance equal to tab bar height, tab bar offset, and safe area.
- Scroll content receives matching bottom padding.

## Cards And Text

Fix:
- Verified source card no longer renders raw URL text that can wrap poorly.
- Source title and institution text can wrap vertically.
- Structured response cards have no fixed height cap.

Residual QA:
- Dynamic Type should be visually checked on device/simulator for very large accessibility sizes before App Store release.

