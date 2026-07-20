# Evidence packet — Interactive Netherlands map

Status: **VERIFIED implementation / PARTIAL full-device runtime evidence**

Evidence date: 2026-07-20 (Europe/Amsterdam)

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
- The map unit tests are included in the last closed complete Stage 2 result of
  **450/450**. Additional Build Week tests were added afterward, and the expanded
  final-snapshot unit rerun and full UI rerun have not yet closed; this packet does
  not claim a green final matrix.

## Measurable result

The model test requires all 12 provinces. The hit-testing suite includes exactly 100 seed-driven deterministic interior samples and rejects missed or wrong-province selections. This proves the tested geometry samples, not every possible edge or device gesture.

## Owner decision

The owner should approve the map state used in the judge demo and decide whether the selected-city marker filter is intentional product scope or should expand before submission.

## Limitations

- Current marker behavior emphasizes the selected city rather than proving simultaneous full-city coverage.
- No current ETTrace, physical-device, VoiceOver, Reduce Motion, or complete device/orientation matrix is attached.
- Unit geometry checks do not substitute for visual inspection of labels, boundaries, gestures, and modal navigation.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

YouNew contains a custom SwiftUI Netherlands map with typed province/city data and deterministic path-based hit-testing tests. Complete physical-device accessibility and performance validation is still pending.

## Screenshot or log still needed

Capture the final build with all 12 province shapes visible, one deterministic province selection, zoom/pan, a city or landmark detail, and back navigation. Attach the closed map UI-test summary and, if performance is claimed, a redacted ETTrace excerpt.
