# Release Blockers

Date: 2026-07-01

## Blocking For App Store Claim

| Blocker | Owner | Status |
| --- | --- | --- |
| Full runtime walkthrough on real device or stable simulator | QA | Required |
| Full UI suite completion without CoreSimulator launcher failure | QA / Xcode environment | Required; targeted iPhone 15 QA, iPhone SE QA, and iPhone 17 Pro smoke subsets are green |
| AI live send/stop/retry runtime verification | QA | Required |
| Search typing and route tap-through runtime verification | QA | Required; iPhone SE accessibility search typing smoke is green |
| Instruments performance trace for high-risk flows | QA / Performance | Required; XCTest launch metric passed, but valid Instruments trace is still missing |

## Not A YouNew Release Blocker In This Pass

| Issue | Classification |
| --- | --- |
| AppIntents metadata skipped, no dependency found | Harmless warning |
| No AppShortcuts found | Harmless warning |
| CoreSimulator `simdiskimaged` / connection refused | Apple/Xcode environment issue |
| XCTest runner Mach `-308` server died | Apple/Xcode simulator runner issue |
| `xcrun xctrace record` hangs and partial `.trace` export reports `Document Missing Template Error` | Apple/Xcode Instruments environment issue |

## YouNew Blocking Defects Found

None confirmed by completed gates.
