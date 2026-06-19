# Release Readiness Report

Date: 2026-06-11

## Fixes Completed In This Pass

| Severity | Issue | Root Cause | Fix | Status |
| --- | --- | --- | --- | --- |
| High | Missing hero/category assets in onboarding and AI cards | Functions returned non-existent `landmark_*` asset names | Replaced with existing bundled category assets | Resolved |
| High | Missing document/fines/LGBTQ hero assets | Views referenced unbundled category asset names | Switched to existing assets or intentional generated fallback | Resolved |
| High | Saved hub items could reload without destinations | `SavedItemsStore` did not serialize several hub routes | Added persisted cases and round-trip restoration | Resolved |
| Medium | Document organizer buttons felt dead | Buttons did not scroll/navigate to relevant sections | Added `ScrollViewReader` targets | Resolved |
| Medium | Camera scanning privacy key missing from generated Info.plist settings | Camera flow existed but generated plist had no camera usage description | Added `NSCameraUsageDescription` | Resolved |

## Verification Run

Passed:
- Extended missing asset scan for direct `assetName:` and returned content asset strings.
- `content-static-qa.py`
- `media-static-qa.py`
- `place-media-static-qa.py`
- `history-media-static-qa.py`
- `image-runtime-data-qa.py`
- `user-visible-completeness-static-qa.py`
- `static-qa.py`
- `knm-static-qa.py`
- `dutch-course-static-qa.py`
- `brand-static-qa.py`
- `plutil -lint` for privacy and localized InfoPlist strings.

Build attempt:
- Release generic iOS build was attempted.
- Build failed at `CompileAssetCatalogVariant`.
- Root cause from Xcode output: `No available simulator runtimes for platform iphonesimulator`, with CoreSimulator/ibtool connection failures.
- This is an environment/runtime tooling blocker in the current machine context. It is not a successful app build.

## Scores

| Category | Score |
| --- | ---: |
| Content | 90 |
| Navigation | 90 |
| Performance | 82 |
| Readability | 86 |
| Accessibility | 84 |
| Trust | 90 |
| Visual Quality | 88 |
| Newcomer Friendliness | 91 |

Overall: 88/100

## Critical

None confirmed by static QA after fixes.

## High

Runtime build/device verification is still required before claiming public-release readiness.

## Medium

Dormant `TranslatorView` uses `MockTranslationProvider`. It was not found as an exposed navigation destination in this pass, but it must not be surfaced publicly without a real provider or very explicit non-translation positioning.

## Low

Source-level layout audit cannot replace device checks for Russian/Dutch text expansion, iPhone SE card fit, and iPad orientation.

## Final Verdict

⚠️ TestFlight Ready

Not Public Release Ready until a clean Xcode build and physical-device runtime pass verify text layout, scrolling FPS, map gestures, and visible navigation.
