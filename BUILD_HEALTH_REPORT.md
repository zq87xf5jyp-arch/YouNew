# BUILD_HEALTH_REPORT

Date: 2026-06-11  
Scope: Pre-TestFlight release blockers only. No code changes made.

## Verdict

Status: BLOCKED FOR LOCAL PACKAGE VERIFICATION

The Swift source type-checks, but the full Release build/package verification did not complete in this local Xcode environment. This means compiler warnings, final asset-catalog packaging, linker output, and archive/upload readiness are not fully proven from this machine.

## Build Metadata

- Project: `YouNew.xcodeproj`
- Scheme checked: `YouNew`
- App version: `MARKETING_VERSION = 1.0`
- Build number: `CURRENT_PROJECT_VERSION = 1`
- Bundle identifier: `com.company.younew`
- App deployment target: iOS 17.6
- Reference: `YouNew.xcodeproj/project.pbxproj`

## Build Checks

| Check | Result | Notes |
| --- | --- | --- |
| Xcode project discovered | PASS | `YouNew.xcodeproj` exists. |
| Swift source type-check | PASS | Release-visible Swift sources type-check without source errors. |
| Full Release build | BLOCKED | `xcodebuild` stopped during asset catalog tooling with `Assets.xcassets: error: No available simulator runtimes for platform iphonesimulator`. |
| Compiler warnings | NOT FULLY VERIFIED | Full build did not complete. |
| Linker/package validation | NOT VERIFIED | Full build did not complete. |
| App icon validation | PASS | `scripts/validate-app-icons.sh` passed. |
| Static content QA | PASS | `scripts/content-static-qa.py` passed. |
| Media static QA | PASS | `scripts/media-static-qa.py`, `scripts/place-media-static-qa.py`, and `scripts/history-media-static-qa.py` passed. |
| Brand/static feature QA | PASS | Brand, KNM, Dutch course, and user-visible completeness scripts passed. |
| Runtime image data QA | FAIL | `scripts/image-runtime-data-qa.py` fails with stale Kinderdijk root-cause expectation. |

## Asset Health

- `Assets.xcassets` scanned with no missing referenced files and no invalid `Contents.json` records found.
- Duplicate binary hashes were limited to AppIcon slots that intentionally reuse generated icon PNGs.
- Asset catalog total size: 23 MB.
- Largest image assets:
  - `premium_home_housing.png`: 2.7 MB
  - `premium_home_documents.png`: 2.3 MB
  - `premium_home_work.png`: 2.3 MB
  - `premium_home_emergency.png`: 2.2 MB
  - `home_work_zuidas.jpg`: 2.2 MB

## URL Health

- No obviously malformed hardcoded URLs were found in the static URL scan.
- Four Apple Maps links still use `http://maps.apple.com` in `YouNew/ViewModels/MapViewModel.swift:503`, `505`, `520`, and `522`.
- These are conventional Apple Maps launch URLs, but `https://maps.apple.com` is safer for public-release review optics.

## Data Health

`scripts/audit_place_media.py` completed but reported data hygiene warnings:

- `mediaSchemaVersion: 2`
- `provinces in catalog: 11`
- `cities in catalog: 29`
- `registry entries: 41`
- `missing hero image: 19`
- `missing flag: 4`
- `missing coat of arms: 1`
- orphan registry entry: `nl-province-noord_holland`

The user stated the runtime city image issue has been manually reviewed on a physical device, so this report does not reclassify those visual records as runtime blockers. The orphan and missing-media warnings should still be cleaned before public App Store release.

## Release Blockers

1. Full Release build/archive verification is blocked locally by Xcode/CoreSimulator asset tooling.
2. `scripts/image-runtime-data-qa.py` fails and must be fixed, removed from release gating, or updated to the current image-registry truth.
3. `com.company.younew` must be confirmed as the real App Store Connect bundle identifier. If it is still a placeholder, it blocks TestFlight upload.

## Required Next Actions

1. Run a successful Release archive on a healthy Xcode installation with valid iOS runtimes installed.
2. Make the runtime image data QA gate pass or formally retire its stale Kinderdijk assertion.
3. Confirm App Store Connect app record, provisioning profile, signing team, and bundle identifier.
