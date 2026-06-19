# Performance Audit

**Date:** 2026-06-18  
**Verdict:** Static performance-sensitive checks pass; full 60 FPS certification is blocked until a stable simulator or physical device profiling pass is available.

## Verified This Session

| Area | Result | Evidence |
|---|---|---|
| Static QA suite | PASS | `scripts/run-static-qa.sh` completed successfully |
| Image data pressure | PASS | 294 visible image assignments, 294 unique URLs, 0 duplicate source groups |
| Search data coverage | PASS | `search-static-qa.py` validated stable IDs and valid-content query coverage |
| AI subsystem structure | PASS | `ai-subsystem-static-qa.py` validated route/source/fallback structure |
| Visual audit gallery generation | PASS | 257 audit cards generated |
| App icon pixel checks | PASS | Required icon sizes passed alpha, brightness, and contrast checks |

## Blocked Runtime Measurements

| Target | Status |
|---|---|
| Scrolling FPS | NOT MEASURED |
| Search typing latency on device | NOT MEASURED |
| AI send/stop/retry runtime responsiveness | NOT MEASURED |
| Map interaction and chip scrolling | NOT MEASURED |
| Image-heavy city/province scrolling | NOT MEASURED |
| Large-screen layout performance | NOT MEASURED |
| Memory leaks | NOT MEASURED |
| Animation jank | NOT MEASURED |

## Runtime Blocker Evidence

- Fresh `xcodebuild ... build-for-testing` was silent for roughly two minutes and was terminated with exit 143.
- `simctl get_app_container ... nl.younew.app` failed after CoreSimulatorService connection became invalid.
- Simulator Spotlight did not find YouNew installed on the booted device.

## Required Before Release Claim

Run Instruments on a stable simulator or physical iPhone and capture at minimum:

- SwiftUI scrolling in Home, More, Cities, Provinces, History, and Search.
- Search query typing and result navigation.
- AI prompt send, stop, retry, source-card taps, and related-section navigation.
- Map pan/zoom/chip filtering.
- Memory graph after repeated navigation through detail screens.

Until those traces pass, the app is not 60 FPS certified.
