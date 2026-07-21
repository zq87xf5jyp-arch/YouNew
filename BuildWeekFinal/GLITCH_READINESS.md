# Glitch test and readiness score

Recorded: 2026-07-21 (Europe/Amsterdam)
Scope: bounded OpenAI Build Week demo candidate, not App Store production readiness

## Current score

**84 / 100 — ready for the bounded owner-recorded demo, with disclosed exclusions.**

This is a transparent engineering rubric, not an Xcode metric or a probability of being bug-free. The score is reduced for the finalized UI failures, broken external references, incomplete physical-device/VoiceOver coverage, media-rights gaps, and unverified distribution artifacts.

| Area | Weight | Earned | Evidence and deduction |
|---|---:|---:|---|
| Clean build | 10 | 10 | Post-fix clean build PASS; `/private/tmp/YouNewBuildWeekCleanBuildPostFixFinal.xcresult`. |
| Unit correctness | 15 | 15 | Current 460/460 PASS, 0 skipped; `/private/tmp/YouNewBuildWeekUnitFinalPreserved.xcresult`. |
| Static/data/security | 15 | 12 | 43/44 known static gates; structural data/import and scoped secret scan PASS. One data-health gate fails on 18 confirmed broken URLs. |
| Primary demo flow | 20 | 18 | Home, local BSN/address/DigiD assistant flow, guide/source action, Map → Home, and imported-city detail are supported. The assistant-selected-city shortcut is excluded. |
| Map/root navigation | 20 | 17 | The delivery blocker is closed: serialized and manual first-tap return works. A reproduced 191.158 ms sample still violates the unchanged 100 ms performance ceiling. |
| UI/accessibility breadth | 15 | 7 | Final full suite is 79/87. Isolated rerun is 5/8; Guide scroll/UI-query, selected-city assistant route, and root latency remain reproducible. First Steps accessibility exposure is locally fixed. |
| Evidence and handoff | 5 | 5 | Judge documents, claims register, screenshots, `.xcresult` paths, limitations, and a no-push handoff plan are present. |
| **Total** | **100** | **84** | Build Week candidate scale only. |

## Current glitch verdict

### Closed in the tested simulator configuration

- Map no longer blocks delivery to the root tab bar; Map → Home works on the first action in serialized automation and manual Computer Use.
- Clean build passes after the final source change.
- Unit suite passes 460/460.
- Search focus targeted repetitions pass 5/5.
- The base deterministic newcomer Assistant flow (BSN → address → DigiD) and health-insurance workflow pass.
- All five `cities-v0.1.0` cities pass the isolated Home/Search/AI/Map/Guide/detail traversal.
- First Steps opens correctly; its visible hero now exposes `firstSteps.screen` without grouping the entire long ScrollView.

### Open and not hidden

- Full UI aggregate: 79/87 PASS, 8 FAIL, 0 skipped.
- Isolated rerun of those eight: 5 PASS, 3 FAIL.
- Root-tab latency: all taps delivered, but one app-side sample was 191.158 ms against the unchanged `<100 ms` requirement.
- Guide composite routing: the corrected Getting Started path advances, then repeated clean runs time out evaluating the UI query after scrolling the returned Guide to Transport.
- Assistant selected-city shortcut: `Open Leiden` does not reach city detail in the isolated workflow. Two unverified implementation attempts were reverted.
- Current external-link health: 18 confirmed broken, 623 restricted, and 32 transient among 2,494 checked URLs.

## Demo boundary

Use only the documented flow in `DEMO_FLOW.md`: Home → local Assistant → BSN/address/DigiD → guide/official source → Map → Home → open one imported city through the stable Home/Search/Map route. Do not use the Assistant `Open Leiden` shortcut or the long Guide-to-Transport composite path in the recording.

## Readiness decision

- Build Week recording: **yes, bounded flow only, 84% engineering readiness**.
- Public repository handoff: owner review and explicit commit/push approval required.
- App Store production: not assessed and must not be claimed.
