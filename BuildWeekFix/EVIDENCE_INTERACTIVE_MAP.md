# Evidence packet — Interactive Netherlands map

Status: **VERIFIED implementation / PRIMARY DEMO BLOCKER TARGETED-VERIFIED**

Evidence date: 2026-07-21 (Europe/Amsterdam)

## 2026-07-21 evidence boundary update

The prior `61e7ce11` 82/87 UI result and its 102.043 ms sample are historical
diagnostics. The later closed clean-clone snapshot is `efd1a7c5` at **84/87 RED**.
After that snapshot, the root tab bar was moved to the frontmost interactive
overlay while retaining a noninteractive safe-area reservation. The preserved
targeted bundle passed 3/3 checks and delivered 10/10 Map ↔ Home transitions on
the first tap. This closes the primary demo blocker in the tested configuration;
it does not establish an all-UI or all-device green result.

## Original problem

The product needed a recognizable Netherlands discovery surface whose province selection did not depend on fragile rectangular hit areas or stale city state.

## Product requirement

Provide a SwiftUI map with deterministic province geometry, accessible selection points, zoom/pan interaction, city and landmark context, and typed navigation into app content.

## Implementation

- A custom SwiftUI/vector surface renders province geometry, labels, city dots, landmarks, selection, zoom, and pan.
- `PremiumProvinceHitTesting` checks exact province paths first and uses a bounded boundary-distance fallback for compact targets.
- `PremiumNetherlandsMapModel` projects the selected city and published data into typed map sections and markers.
- Province and city actions use typed `AppDestination` routes.

## Files

- `YouNew/Views/NetherlandsInteractiveMapView.swift`
- `YouNew/Models/PremiumNetherlandsMapModel.swift`
- `YouNew/Core/Interaction/PremiumProvinceHitTesting.swift`
- `YouNew/App/Navigation/AppRouter.swift`

## Tests

- `YouNewTests/PremiumNetherlandsMapModelTests.swift`
- `YouNewTests/PremiumProvinceHitTestingTests.swift`
- `YouNewUITests/MapChipUITests.swift`
- Map and navigation checks invoked by `scripts/run-static-qa.sh`
- The map unit tests are included in a clean-clone **460/460** unit result. The
  historical `61e7ce11` serial UI result is **82/87**; its 102.043 ms root-tab
  sample remains diagnostic evidence only. The later `efd1a7c5` aggregate is
  **84/87 RED**. The later targeted map bundle is **3/3 PASS**, including Leiden,
  Middelburg, and **10/10 first-tap Map ↔ Home transitions** with a maximum
  recorded app-side sample of 94.1 ms. The ledger is recorded in
  `BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md` and `TEST_REMEDIATION.md`.

## Measurable result

The model test requires all 12 provinces. The hit-testing suite includes exactly 100 seed-driven deterministic interior samples and rejects missed or wrong-province selections. This proves the tested geometry samples, not every possible edge or device gesture.

## Build Week freeze decision

The current selected-city behavior and targeted-verified Map → Home flow are the
accepted demo scope. Marker expansion and map redesign are intentionally deferred.

## Limitations

- Current marker behavior emphasizes the selected city rather than proving simultaneous full-city coverage.
- Historical runs contained slow or undelivered Map → Home events. The final
  targeted artifact passed its unchanged contract, but that result must not be
  generalized to every device or environment.
- No current ETTrace, physical-device, VoiceOver, Reduce Motion, or complete device/orientation matrix is attached.
- Unit geometry checks do not substitute for visual inspection of labels, boundaries, gestures, and modal navigation.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew contains a custom SwiftUI Netherlands map with typed province/city data,
deterministic path-based hit-testing tests, and a targeted-verified first-tap return
to Home in the recorded candidate configuration. This is not all-device
certification.

## Packaging boundary

No additional screenshot automation, trace, or runtime pass is required by the
engineering freeze. The final owner-recorded demo follows `BuildWeek/DEMO_GUIDE.md`.
