# Navigation Audit — YouNew.nl

**Audit date:** 2026-06-18  
**Result:** STATIC PASS, LIVE WALKTHROUGH BLOCKED

## Verified Static Coverage

| Area | Result | Evidence |
|---|---|---|
| `AppDestination` render coverage | PASS | `route-action-static-qa.py` confirmed 70 rendered cases |
| Hardcoded destination references | PASS | 51 hardcoded references checked |
| Guide section IDs | PASS | 8 hardcoded guide section IDs checked |
| KNM module IDs | PASS | 6 hardcoded KNM module IDs checked |
| Menu destinations | PASS | 36 menu destinations mapped |
| AI route aliases | PASS | 10 Practical Guide aliases checked |
| Stable route IDs | PASS | `route-id-stability-static-qa.py` covered checklist, fines, Dutch terms, guides, legal info, daily life, expansion models, map places, and search answers |
| Button nesting | PASS | No nested Button/NavigationLink labels found |

## Runtime Walkthrough Status

| Requested area | Status |
|---|---|
| Home, Search, Map, Saved, AI Assistant, More | NOT COMPLETED live |
| Cities, Provinces, History, Government, Transport, Housing, Healthcare, Language, Documents, Settings | NOT COMPLETED live |
| Every detail screen/modal/sheet/deep link/card/button | NOT COMPLETED live |
| Back navigation | NOT COMPLETED live |
| Duplicate pushes, route loops, stuck navigation | STATIC CHECKED where possible, LIVE UNVERIFIED |

## Blocker Evidence

- Fresh `xcodebuild ... build-for-testing` stalled and was terminated with exit 143.
- CoreSimulatorService became invalid during `simctl` app-container lookup.
- YouNew was not discoverable in Simulator Spotlight, so no manual tap-through could be completed on the current booted simulator.

## Current Verdict

No static broken routes were found. However, the release requirement is stricter than static coverage: every route and button must be opened and backed out of on a real runtime. That has not been completed, so navigation is not release-certified yet.
