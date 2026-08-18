# YouNew monetization readiness — private Gate 1 search scorecard

Date: 2026-08-18 (Europe/Amsterdam)  
Mode: local, private and non-publishing. No QA guide entered the public index; no deployment, publication, production write or external message occurred.

## Outcome

The private Gate 1 search candidate is **PARTIAL**. It clears the numeric search threshold with **48/50 actionable queries (96%)**, has **2 zero-result queries** and **0 invisible location substitutions**. This is not a Gate 1 GO because all 20 candidate guides remain unreviewed QA packets with pending publication gates and no verified guide media.

The checked-in public index still contains 573 documents and no `privateQaPracticalGuide` records. The scorecard adds the 20 packets only in memory, gives them private `/__private-search-eval__/...` routes and refuses any packet whose status, reviewer or publication gate is not the expected fail-closed QA state.

## Scorecard

| Evaluation surface | Actionable | Zero results | Invisible location substitutions | Public? |
|---|---:|---:|---:|:---:|
| Audited Phase 0 production-source baseline | 31/50 (62%) | 7 | 2 | Yes, unchanged production evidence |
| Current local public-content candidate after location-safe ranking fix | 32/50 (64%) | 7 | 0 | No deployment |
| Current local candidate plus 20 private QA guides | 48/50 (96%) | 2 | 0 | No; in-memory evaluation only |

The local public-content improvement comes from one real search correction: `landlord problem` now retains national housing guidance in the first five results instead of silently treating Amsterdam-only `!WOON` as the default. No content record or public index document was added.

## Remaining content gaps

1. `Dutch citizenship` — zero useful result.
2. `pregnancy midwife` — zero useful result.

These are genuine gaps outside the exact 20-guide set. No synonym or destination was invented to inflate the score.

## Location-safety correction

- Generic intent queries without an inferred or selected place penalize documents that carry a city, municipality or province identity.
- Named local entities remain discoverable: the `Rijksmusem` typo regression still resolves to Rijksmuseum.
- Queries with a place retain local relevance: `register with gemeente in Leiden` renders Leiden first.
- `Register gemeente` renders the national BSN/registration route first; Amsterdam appears only as a labelled later result.
- `landlord problem` renders the national housing route first.

Regression coverage was added for unscoped registration and landlord queries. The rendered local `/search` flow was exercised through the visible form; all three expected results appeared and the browser console reported no warnings or errors.

## Reproducible evidence

```text
pnpm test
pnpm qa:search
pnpm qa:monetization
pnpm qa:monetization:private
```

- Public web tests: **146/146 PASS** in the current local candidate.
- Search regression matrix: **2,608/2,608 PASS**, covering 12 provinces and 342 municipalities.
- Focused search tests: **19/19 PASS**.
- Private scorecard: **48/50**, 0 invisible substitutions.

The private scorecard implementation is `admin-dashboard/public-site/scripts/monetization-gate1-private-scorecard.mjs`. It fails if the local public candidate drifts from 32 actionable queries, if either public or private evaluation contains an invisible location substitution, if the private result is below 45/50, or if QA content leaks into the public index.

## Decision

**PARTIAL — numeric search criterion passes only in a private candidate. NO-GO for Gate 1 completion, publication, deployment or commercialization.**

## Next smallest useful action

Assign named reviewers to the 20 QA packets and create source-backed review dossiers for Dutch citizenship and pregnancy/midwife. After corrections, rerun this same private scorecard. Publication remains a separate approval after reviewer, media, evidence-registry and publication-gate requirements are satisfied.
