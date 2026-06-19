# Final TestFlight Gate Report

Date: 2026-06-11

## Final Verdict

❌ Block TestFlight

## Why

Internal TestFlight requires a real uploadable build. This gate pass found no confirmed source-level content/city/navigation blocker after static QA, but the app is not upload-ready because build identity and archive verification are not clean.

## Critical

| Issue | Screen/File | Root Cause | Recommended Fix |
| --- | --- | --- | --- |
| Placeholder-style Bundle Identifier | `YouNew.xcodeproj/project.pbxproj` | Main app uses `com.company.younew` | Replace with the exact App Store Connect bundle id registered under the Apple Developer account |
| Release build failed | Xcode build / asset catalog | CoreSimulator/ibtool reports no available iPhone simulator runtimes during asset catalog compilation | Repair/install iOS simulator runtime or archive on a healthy Xcode install; rerun Release archive |
| Provisioning profile verification failed | Local Xcode signing environment | Xcode reported local profiles missing required UUID property | Remove invalid profiles, refresh automatic signing, confirm App ID/profile for final bundle id |

## High

| Issue | Area | Root Cause | Recommended Fix |
| --- | --- | --- | --- |
| Runtime performance not measured | Cities, provinces, map, search | Local build/runtime unavailable | Run physical iPhone manual test before upload confidence |
| Previously reported map/city scroll lag not disproven | Map/city screens | No runtime FPS/memory evidence in this pass | Test 10-15 cities, map pan/zoom, search, airplane mode, dark mode |

## Medium

| Issue | Area | Root Cause | Recommended Fix |
| --- | --- | --- | --- |
| Dormant mock translation/OCR code | `TranslatorView`, `MockTranslationProvider`, `MockOCRProvider` | Mock providers remain in code but were not found as visible routes | Do not expose before real provider or explicit non-translation positioning |
| External link behavior unverified | Official sources, maps | Runtime unavailable | Manual tap test all external links |

## Low

| Issue | Area | Recommendation |
| --- | --- | --- |
| Text layout not runtime-proven | Russian/Dutch/iPhone SE/iPad | Manual device QA |
| Dark Mode is forced | App root | Acceptable for current product if intentional; Apple does not require light mode |

## Passed Static Gates

- Content QA passed.
- User-visible completeness QA passed.
- Media QA passed.
- Place media QA passed.
- History media QA passed.
- Image runtime data QA passed.
- KNM QA passed.
- Dutch course QA passed.
- Brand QA passed.
- App icon QA passed.
- Privacy manifest lint passed.
- Localized plist lint passed.
- Missing content asset scan passed.

## Manual iPhone Checklist Before Retesting Gate

1. Delete app.
2. Install fresh build.
3. Complete onboarding and relaunch.
4. Open 10-15 city pages.
5. Search `BSN`, `DigiD`, `Belastingdienst`, `Leiden`, `Rotterdam`.
6. Pan/zoom map.
7. Check Dark Mode.
8. Enable airplane mode and verify no hangs.
9. Open all external links used in core flows.
10. Watch memory and heat while scrolling cities/provinces.

## Approval Condition

The gate can move to `✅ Ready For Internal TestFlight` only after:
- final real bundle id is configured,
- Release archive completes,
- signing/provisioning is clean,
- manual iPhone smoke test confirms onboarding, navigation, city pages, map, search, and no major scroll lag.
