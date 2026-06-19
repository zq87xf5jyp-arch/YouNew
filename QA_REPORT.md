# QA Report

Date: 2026-06-01

## Static/Build Validation

Status: **passed**

- `python3 scripts/user-visible-completeness-static-qa.py`: passed
- `python3 scripts/content-static-qa.py`: passed
- `python3 scripts/knm-static-qa.py`: passed
- `python3 scripts/dutch-course-static-qa.py`: passed
- `python3 scripts/place-media-static-qa.py`: passed
- `scripts/run-static-qa.sh`: passed
- Xcode diagnostics for changed Swift files: clean
- Xcode `BuildProject`: passed
- compile errors: 0
- build warnings: 0

This confirms the static content, routing, localization, media, KNM, Dutch A1-A2, and user-visible completeness gates that are currently automated.

## Runtime Visual QA

Status: **not performed**

- Blocked by: CoreSimulatorService unavailable in this environment (connection became invalid / connection refused)
- simctl runtime check: failed
- Must be completed locally on iOS Simulator or physical iPhone

macOS runtime is not accepted as a replacement for iPhone QA because it does not validate iPhone safe areas, compact widths, home indicator spacing, bottom navigation overlap, touch targets, iOS app icon rendering, or localized mobile layout.

The final runtime handoff checklist is:

- `QA/FINAL_IOS_RUNTIME_QA.md`
- `QA/ROUTE_ACTION_SANITY_REPORT.md`

## Intentionally Empty States

The following empty states are acceptable because they depend on user data:

- Saved is empty until the user saves places, guides, or sources.
- Documents are empty until the user adds documents.
- Search history is empty until the user searches.
- User-data arrays may be optional/default-empty.
- Relationship arrays may be optional/default-empty where no related content exists.

Every intentionally empty user-facing screen must still have:

- a clear title,
- useful explanation,
- an action button where relevant,
- no TODO/debug text,
- no raw localization keys,
- no mixed-language UI.

## Current Release Recommendation

| Channel | Status |
|---|---|
| Internal QA build | Acceptable |
| Internal TestFlight | Only after local runtime QA passes |
| External TestFlight | Not ready |
| App Store | Not ready |

Do not advance to Internal TestFlight until runtime visual QA passes on iOS Simulator or physical iPhone.

Do not mark App Store ready until all of the following are complete:

- runtime visual QA passes on iOS Simulator or physical iPhone,
- required screenshots are captured,
- app icon is verified on the iOS Home Screen,
- signing/archive is verified,
- privacy policy URL exists,
- support URL exists,
- App Store metadata is prepared,
- final media/license attribution is checked.

## Remaining QA Risks

- Runtime visual density on small iPhones still needs screenshot review.
- Russian text wrapping must be verified on real iPhone widths.
- Bottom navigation overlap must be checked screen by screen.
- Source/open-link buttons should be tapped in simulator/manual QA.
- App icon rendering must be verified on the iOS Home Screen.
