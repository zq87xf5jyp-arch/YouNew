# Content Audit

Date: 2026-06-16

## Scope

Audited government, housing, healthcare, transport, history, monarchy, cities, provinces, documents, KNM, Dutch A1-A2, and search-answer content through static QA and data route validation.

## Validation Performed

- `scripts/content-static-qa.py`: passed through aggregate static QA.
- `scripts/knm-static-qa.py`: passed.
- `scripts/dutch-course-static-qa.py`: passed.
- `scripts/user-visible-completeness-static-qa.py`: passed.
- Data-backed route validation: 361 routes passed.

## Findings

- No duplicate article blocker reported by static QA.
- No missing user-visible content blocker reported by static QA.
- No stale route IDs found in data-backed route validation.
- Official source coverage passed static QA.

## Current Status

- Known P0 content blockers: 0.
- Known P1 content blockers: 0.

## Release Note

Government/legal/health/tax content remains informational and source-first. Final product copy should continue to avoid claiming official authority.

