# YouNew — Stage 5 Release Audit

Date: 2026-07-11  
Branch: `fix/ui-regression`  
Build: `1.1 (5)`  
Bundle ID: `nl.younew.app`  
Verdict: **NOT READY FOR APP STORE SUBMISSION**

The application builds, launches, and passes the complete static quality suite. Submission remains blocked until the incomplete runtime, accessibility, performance, and full XCTest evidence is closed.

## Changes in this pass

- Voice recognition is stopped when the AI Assistant screen disappears, preventing an audio-session leak after navigation.
- Microphone and speech-recognition permission prompts are localized in English, Russian, and Dutch.
- The stale navigation test was aligned with the canonical five tabs: Home, Guide, Map, Saved, More.
- No analytics SDK, tracking, dependency, route, or product feature was added.

## Evidence

| Gate | Result | Evidence |
| --- | --- | --- |
| Native simulator build | PASS | `xcodebuild build`, iPhone 17 Pro simulator, exit 0 |
| Launch smoke test | PASS | App installed and launched as process `nl.younew.app`; Home screenshot captured |
| Static QA suite | PASS | Localization, navigation, accessibility, performance, privacy, search, content, AI, image and visual gates |
| Localization | PASS | 582/582 UI keys in English, Dutch, and Russian |
| Release test-plan integrity | PASS | 125 release cases validated by the report gate |
| Content media mapping | PASS | 294 visible assignments; no duplicate source groups |
| Canonical navigation regression | PASS | Targeted XCTest for the five Russian tab labels, exit 0 |
| Full unit suite | INCOMPLETE | Many suites/cases passed; one stale test was corrected; XCTest runner then stalled during finalization and was interrupted |
| UI automation matrix | NOT PROVEN | No complete green run for SE, standard, Pro Max, landscape, Dynamic Type and VoiceOver |
| Performance targets | NOT PROVEN | No valid Instruments trace proving launch under 3 seconds, memory under 150 MB and FPS above 55 |
| Voice input on physical hardware | NOT PROVEN | Permission and microphone behavior require a real device |
| Archive/signing/App Store Connect | NOT PROVEN | No signed archive, upload validation, store metadata or privacy-label verification in this pass |

Runtime screenshot: `IA_Audit_Screenshots/stage5-home-smoke.png`.

## Confirmed findings

### High

1. **Full XCTest run does not complete reliably**
   - Screen: application-wide.
   - Steps: run the complete `YouNewTests` target on the configured simulator.
   - Expected: all tests finish and Xcode produces a final result.
   - Actual: many tests passed, but the runner stalled while finalizing the session.
   - Fix: stabilize the simulator/XCTest environment and retain the final `.xcresult` from an uninterrupted run.

2. **Release performance thresholds are not evidenced**
   - Screen: launch, Home scrolling, Map, AI Assistant.
   - Steps: record release-configured Time Profiler, Animation Hitches and Leaks runs on a supported physical device.
   - Expected: launch <3 s, memory <150 MB, FPS >55, no leaks.
   - Actual: static performance checks pass, but no valid trace proves the numerical targets.
   - Fix: capture and attach Instruments traces; optimize only measured hotspots.

3. **Accessibility/device matrix is incomplete**
   - Screen: all five roots and primary detail flows.
   - Steps: test VoiceOver, accessibility Dynamic Type, Reduce Motion and long strings on SE, standard and Pro Max sizes.
   - Expected: all content remains reachable with correct focus order and no overlap.
   - Actual: static accessibility QA passes and standard-size Home smoke is visually sound; the full matrix is not evidenced.
   - Fix: complete the manual/runtime matrix and retain screenshots or UI-test artifacts.

### Medium

1. **Voice input is not physically verified**
   - Screen: AI Assistant.
   - Steps: start and stop voice input, deny/allow permissions, background and leave the screen.
   - Expected: localized prompts, accurate state, microphone always stops on exit.
   - Actual: lifecycle and localization are implemented and compile; real microphone behavior is not proven.
   - Fix: execute the permission matrix on a physical iPhone.

2. **Distribution evidence is missing**
   - Screen: release pipeline.
   - Steps: archive Release, validate signing and upload to App Store Connect.
   - Expected: archive validation succeeds and privacy metadata matches behavior.
   - Actual: simulator build succeeds; signed distribution was not authorized or performed.
   - Fix: provide the distribution team/profile and validate the archive plus store metadata.

## Quality scores

| Area | Score | Basis |
| --- | ---: | --- |
| Build and static correctness | 9/10 | Build and all static gates pass |
| Content and navigation integrity | 9/10 | Canonical five-tab test and content gates pass |
| Accessibility readiness | 7/10 | Static coverage is strong; runtime matrix incomplete |
| Performance readiness | 6/10 | Code gate passes; numerical targets unproven |
| Privacy and permissions | 8/10 | Manifest and localized purpose strings present; device permission QA pending |
| Release operations | 5/10 | No signed archive or App Store validation |

## Release decision

Do not submit this build yet. No confirmed critical application defect was found in this pass, but the High evidence gaps above violate the release checklist. The next release candidate may be approved only after a complete green XCTest result, device accessibility matrix, valid performance/leak traces, physical voice-input QA, and signed archive validation are attached.
