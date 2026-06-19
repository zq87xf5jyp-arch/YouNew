# Apple Review Report

Date: 2026-06-17

## Result

Status: NOT CERTIFIED for upload readiness from this environment; static privacy/permission gate passes.

## Apple Review Checks

| Check | Status | Notes |
| --- | --- | --- |
| Unfinished visible sections | Pass static | Static content QA passed |
| Misleading visible content | Pass static | Official-source disclaimers and privacy copy present |
| Broken links | Unverified runtime | Static URL presence checked indirectly; external opening needs device |
| Fake functionality | Pass static / runtime unverified | Mock-backed `TranslatorView` is not exposed by production routing and overclaiming fallback copy was removed; dormant OCR/translator functionality still must not be surfaced before live review |
| Hidden errors | Pass static | No tracking in privacy manifest |
| Privacy concerns | Pass static | `scripts/apple-review-static-qa.py` verifies privacy manifest, UserDefaults/FileTimestamp reasons, camera/location strings, location Settings recovery, scanner guard, protected scan writes, backup exclusion, and no photo-library API usage |
| Touch targets | Pass static | Denied-location Settings button and institution navigation chips now enforce the shared 44-point minimum touch height |
| Build/upload readiness | Blocked runtime | macOS `build-for-testing` passed; iOS simulator/device runtime remains unavailable in this environment |

## Fixed In Current Pass

1. Added `scripts/apple-review-static-qa.py` and wired it into `scripts/run-static-qa.sh`.
2. Verified `PrivacyInfo.xcprivacy` declares no tracking, no tracking domains, no collected data, UserDefaults reason `CA92.1`, and FileTimestamp reason `C617.1`.
3. Verified generated Info.plist settings include camera and when-in-use location purpose strings.
4. Verified the document scanner checks camera availability and the camera purpose string before presenting `VNDocumentCameraViewController`.
5. Verified scanned PDFs are written with complete file protection and temporary scan files are excluded from backup.
6. Verified denied/restricted location state offers a Settings recovery action.
7. Fixed the denied-location Settings button to use the shared minimum touch height.
8. Fixed shared institution navigation chips to use the shared minimum touch height.
9. Removed official-translation claims from fallback translator copy and added a user-visible completeness guard that fails if mock-backed `TranslatorView` is production-routed while still using `MockTranslationProvider()`.

## Gate Impact

Apple/TestFlight upload should remain blocked until a working iOS simulator or physical device pass verifies live permissions, safe areas, accessibility, dark mode, Dynamic Type, offline/error states, and every visible route/button/sheet.
