# Real Device QA Report

Date: 2026-06-11

## Verdict

Status: NOT COMPLETED AS REAL PHYSICAL DEVICE QA

Reason: the available evidence in this session is a Simulator appshot and an MP4 file. The active device shown is `iPhone 17 Pro - iOS 26.5` in Simulator, not a confirmed physical iPhone. The MP4 duration was readable with AVFoundation (`77.38s`), but frame extraction failed with `Cannot Decode` for all sampled timestamps. `simctl` also failed because CoreSimulatorService is unavailable in this environment.

No code changes were made in this pass.

## Evidence Available

| Evidence | Status | Notes |
| --- | --- | --- |
| `<LOCAL_ARTIFACT>/ScreenRecording_06-11-2026 16-29-11_1.MP4` | Partial | File exists, 128 MB, duration readable as 77.38s, frame decode failed |
| Simulator appshot | Usable | Shows iPhone 17 Pro Simulator home screen |
| Live Simulator via `simctl` | Unavailable | CoreSimulatorService connection refused |
| Physical iPhone instrumentation | Unavailable | No connected physical-device control or screenshots available through tools |

## Confirmed Issues

### 1. Duplicate YouNew.nl App Icons Visible

Screen: iPhone Home Screen / Simulator appshot

Steps:
1. View the provided iPhone 17 Pro Simulator home screen.
2. Inspect installed app icons.

Expected:
Only one YouNew.nl app icon should be visible for testers.

Actual:
Two identical `YouNew.nl` icons are visible side by side.

Severity:
High

Root cause:
Most likely multiple installed builds with different bundle identifiers. The project history/configuration shows bundle identifier changes, and the current project still uses placeholder-style `com.company.younew`. An older installed app can remain beside the newer one if the bundle id changed.

Fix:
1. Set final real App Store Connect bundle id.
2. Delete all old YouNew builds from the device/simulator before QA.
3. Remove stale bundle ids such as old local/dev identifiers from test devices.
4. Reinstall only the archive intended for TestFlight.

Status:
Open. Not fixed in this pass because it depends on final bundle id/device install cleanup.

### 2. Physical Device QA Evidence Not Available

Screen:
All requested screens

Steps:
1. Attempt to inspect the attached recording.
2. Attempt to extract frames from the MP4.
3. Attempt to query/capture the running simulator.

Expected:
The QA pass should inspect Home, Map, Province cards, City detail pages, Search, Documents, Housing, Healthcare, Transport, Institutions, Emergency, AI Assistant, Bookmarks, Settings, and onboarding after reinstall on a physical iPhone.

Actual:
The recording could not be decoded into frames in this environment. `simctl` could not access the simulator. No physical iPhone automation/screenshot channel was available.

Severity:
Critical for QA confidence, not a confirmed app bug.

Root cause:
Tooling/environment limitation: MP4 frame extraction failed, and CoreSimulatorService is unavailable.

Fix:
Provide one of:
- H.264 MP4 screen recording that AVFoundation can decode here,
- a folder of screenshots from the physical iPhone,
- direct Xcode/Simulator runtime access with working CoreSimulatorService,
- manual QA results with screenshots for every requested screen.

Status:
Open.

### 3. TestFlight Install Identity Still Needs Cleanup

Screen:
Install/build configuration, visible as duplicate app icons.

Steps:
1. Inspect current app project bundle id.
2. Compare against visible duplicate installed apps.

Expected:
One final bundle id, one installed app, one TestFlight candidate.

Actual:
Project currently reports `com.company.younew`, and the provided Home Screen shows two YouNew.nl app icons.

Severity:
Critical for TestFlight release gate.

Root cause:
Placeholder bundle id and/or multiple installed bundle ids on the test device.

Fix:
Set the final registered bundle id, refresh signing, delete old installed apps, then reinstall a single candidate.

Status:
Open.

## Requested Screen Coverage

| Area | Runtime QA Status | Result |
| --- | --- | --- |
| Home screen | Partially visible only | Duplicate app icons confirmed before app launch |
| Map interactions | Not verified | No decodable frames/runtime control |
| Province cards | Not verified | No decodable frames/runtime control |
| City detail pages | Not verified | No decodable frames/runtime control |
| Search | Not verified | No decodable frames/runtime control |
| Documents | Not verified | No decodable frames/runtime control |
| Housing | Not verified | No decodable frames/runtime control |
| Healthcare | Not verified | No decodable frames/runtime control |
| Transport | Not verified | No decodable frames/runtime control |
| Institutions | Not verified | No decodable frames/runtime control |
| Emergency | Not verified | No decodable frames/runtime control |
| AI Assistant | Not verified | No decodable frames/runtime control |
| Bookmarks | Not verified | No decodable frames/runtime control |
| Settings | Not verified | No decodable frames/runtime control |
| Onboarding after reinstall | Not verified | Needs delete/reinstall/relaunch proof |

## Items Not Proven

The following cannot be marked pass or fail from available evidence:
- crashes,
- freezes,
- slow scrolling,
- broken buttons,
- wrong images inside app screens,
- duplicate city images inside app screens,
- clipped text,
- empty app spaces,
- unreadable app text,
- wrong city data,
- wrong municipality data,
- broken external links,
- repeated onboarding,
- memory spikes.

## Required Next Physical iPhone QA

1. Delete every installed YouNew.nl app icon from the device.
2. Install exactly one build with the final bundle id.
3. Record a new H.264 MP4 or provide screenshots.
4. Launch fresh and complete onboarding.
5. Kill/relaunch and confirm onboarding does not repeat.
6. Test Home, Map, Provinces, City detail pages, Search, Documents, Housing, Healthcare, Transport, Institutions, Emergency, AI Assistant, Bookmarks, and Settings.
7. Open 10-15 city pages.
8. Search `BSN`, `DigiD`, `Belastingdienst`, `Leiden`, `Rotterdam`.
9. Test airplane mode.
10. Watch memory/heat while scrolling city/province lists.

## Release Gate Impact

Block TestFlight until:
- only one YouNew.nl app icon is installed,
- final bundle id is configured,
- physical-device QA evidence proves no critical runtime issues.
