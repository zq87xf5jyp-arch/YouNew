# App Store Readiness

Date: 2026-07-01

## Decision

Not ready to claim App Store ready.

## Gate Status

| Gate | Status | Evidence |
| --- | --- | --- |
| Builds without errors | BLOCKED | App-target build passes in this environment, but this App Store gate stays blocked until full runtime validation is completed |
| Static QA | PASS | `scripts/run-static-qa.sh` passed |
| Unit QA | PASS | 241 tests passed |
| Targeted UI runtime QA | PASS | iPhone 15 QA: HomeCategory, MapChip, AccessibilityRuntime passed; iPhone SE QA: AccessibilityRuntime and LocalizationRegression passed; iPhone 17 Pro: AccessibilityRuntime, HomeCategory, MapChip, and LocalizationRegression passed |
| Full UI runtime QA | PARTIAL | Targeted smoke is green on iPhone 15 QA, iPhone SE QA, and iPhone 17 Pro; exhaustive `YouNewUITests` target still required |
| Real device runtime QA | NOT RUN | Required before App Store claim |
| AI live runtime QA | PARTIAL | Static/unit passed; live send/stop/retry still required |
| Search live runtime QA | PARTIAL | Static/unit passed; iPhone SE accessibility search typing smoke passed; full route walkthrough still required |
| Performance profiling | PARTIAL | XCTest launch metric passed on iPhone SE QA; Instruments/ETTrace trace still required |

## Required Before App Store Submission

- Stable full UI suite or manual walkthrough on real device.
- Device crash log review showing no YouNew crashes.
- AI send/stop/retry runtime verification.
- Search typing and route verification.
- Instruments performance pass for launch, scroll, search, map, and assistant flows.
