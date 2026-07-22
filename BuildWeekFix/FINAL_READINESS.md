# Build Week readiness evidence — superseded interim report

Evidence cutoff: 2026-07-21 (Europe/Amsterdam)

Branch: `build-week-readiness`

Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`

Current product/test commit: `da8c3fe22e7a5d99b2187aab1141700b2d34f508`

Document status: **HISTORICAL INTERIM EVIDENCE — SUPERSEDED**

Canonical demo-handoff decision: `BuildWeek/FINAL_STATUS.md`.

This file preserves the stricter pre-freeze release audit chronology. It is not the
current Build Week packaging verdict and must not override the later targeted
Map/Guide/search evidence. No new runtime cycle is required by the final packaging
scope.

Scoped media-rights update (2026-07-22): historical unresolved-catalog counts in
the chronology are superseded by `MEDIA_RIGHTS.md` and
`ASSET_RIGHTS_STATUS.json`. The shipped 170-asset catalog now passes with zero
unresolved records. Screenshots, recordings, audio, and public-site media remain
separate release inventories.

## Evidence chronology

This report does not merge results across commits.

| Snapshot | Closed evidence | UI boundary |
|---|---|---|
| Audit baseline `b15a2f29` | Build PASS; unit 446/450; static 35/40; UI 80/86 | Baseline only |
| Historical `61e7ce11` | Detailed remediation record retained | 82/87 RED; historical only |
| Last fully closed clean clone `efd1a7c5` | Build, unit, offline static, import, and mocked backend checks passed | **84/87 RED** |
| Post-hardening `9b74a236` | Independent clean clone: build PASS, unit 460/460, offline static 40/40 | No complete serial UI aggregate |
| Current working tree over `da8c3fe2` | Adds four narrow product fixes: root-tab event delivery, Guide loading state, input hit testing, and one media URL correction | Targeted Map/Guide/search evidence is preserved; no complete post-fix aggregate claim |

## Overall decision

**Historical release decision: NOT PRODUCTION READY. Current Build Week decision: READY FOR DEMO HANDOFF.**

The deterministic local assistant and existing product flow are sufficient for the
frozen Build Week demo. Live GPT-5.6 is not part of the candidate claim. Broken
external links, non-catalog release-media review, and bounded aggregate UI evidence
remain honest production/distribution limitations; they do not reopen feature work
or invalidate the targeted-verified primary demo path.

## Readiness matrix

| Dimension | Status | Evidence boundary / remaining gate |
|---|---|---|
| Build | **PASS, recorded** | Final candidate status records a successful Xcode build; earlier independent clone at `9b74a236` also built with 0 errors/warnings. |
| Unit tests | **PASS — 460/460, bounded** | Independent clone at `9b74a236`; 0 failed, skipped, or expected failures. Later product diffs have targeted rather than aggregate evidence. |
| Static QA | **PASS — offline 40/40, bounded** | Independent report-free clone at `9b74a236`; zero image-network requests. It is not a fresh external-link audit. |
| DataProject/import | **STRUCTURAL PASS / RELEASE-DATA BLOCKED** | Import and offline structural gates pass; separate generated network evidence contains 18 confirmed broken URLs in shipped runtime data. |
| UI tests | **TARGETED PRIMARY FIXES PASS / AGGREGATE BOUNDED** | Map blocker: 3/3 and 10/10 first-tap transitions; Guide 1/1; search focus 5/5. No all-UI-green claim. |
| AI Assistant | **AVAILABLE** | Deterministic local guide mode is explicit and retained. |
| GPT-5.6 proof | **NOT VERIFIED / OUTSIDE CANDIDATE CLAIM** | Optional bounded code exists; no deployed backend, credentials, provider request ID, or live model metadata. |
| Repository safety | **PREPARED LOCAL HANDOFF** | No remote, push, deployment, or publication was performed. |
| Clean clone | **BOUNDED PRIOR PROOF** | Build/unit/static evidence is preserved; later targeted product fixes do not receive an aggregate claim. |
| README | **PREPARED** | Root GitHub README and the complete `BuildWeek/` package are present. |
| Media rights | **PASS — SHIPPED ASSET CATALOG** | All 170 catalog assets have governed records and `unresolved = 0`: 58 public-domain city symbols, 36 documented project-owned assets, and 76 attribution-ready third-party assets. Screenshots, recordings, audio, and public-site media remain separate review scopes. |
| Demo readiness | **READY FOR HANDOFF** | The main flow uses the local assistant; live model proof is not required or claimed. |
| Submission readiness | **PACKAGE READY / EXTERNAL STEPS PENDING** | Repository narrative, demo plan, checklist, Devpost text, and owner handoff are prepared. |

## Current technical evidence

### Build, units, static, and clean clone

An independent clone outside the owner working directory was created at `9b74a236`.
It built successfully, ran **460/460** unit tests with no skipped or expected-failure
tests, and completed the offline structural static aggregate. The Worker contract
ran locally with mocked upstream behavior and passed **13/13** after canonical
Responses-completion validation was added. These results do not prove live OpenAI,
external-link health, or production deployment.

### UI gate

The last closed complete clean-clone UI snapshot, `efd1a7c5`, is **RED at 84/87**.
Later narrow fixes have separate evidence: Map/root navigation passed 3/3 with
10/10 first-tap transitions, the Guide completion state passed 1/1, and search focus
passed five targeted repetitions. Cafe routing was not reproduced after multiple
focused attempts, so routing code was not changed speculatively. These results
close the demonstrated blockers without supporting an all-UI-green claim.

### Shipped runtime link health

Current ignored/generated network evidence reports **18 confirmed broken URLs** in
tracked `YouNew/Resources/Data/younew-runtime-data.json`: 30 published
`amsterdam-v0.1.0` entities and 85 runtime field occurrences are affected. The
offline sentinel in a clean clone means “network not run”, not “links healthy”.
The correct remediation is a reviewed, versioned release overlay plus fresh network
verification—not deleting or bypassing the evidence. See
`BuildWeekFix/DATA_HEALTH_BLOCKER.md`.

### AI Assistant and GPT-5.6

The iOS client contains no OpenAI key and sends only bounded scenario fields to an
owner-controlled backend URL. The Worker reference uses an environment-only key,
strict `gpt-5.6`/`gpt-5.6-sol` policy, structured output, timeout, limits, safe
errors, request ID, `store: false`, and no prompt/answer body logging. It now rejects
HTTP-200 but incomplete or provider-failed Responses objects. Any unavailable,
invalid, or unverified path visibly falls back to deterministic **Local guide mode**.

Live status remains **BLOCKED**: the environment has no configured backend URL or
provider credential, no approved deployment occurred, and no real request/model/
provider request ID was captured. A fixture or another model must never be shown as
live GPT-5.6.

### Repository, privacy, secrets, and media

No remote, push, deployment, release, TestFlight action, or submission occurred.
Filename-only secret/signing scans found no confirmed credential, certificate, or
provisioning file; the one OpenAI-shaped pattern match was a benign scam-warning
stable ID. This is a bounded scan, not public-release clearance. OCR/EXIF, history,
personal-data, legal/medical, and owner metadata review remain open.

The repository notice does not relicense third-party media. Catalog credits and
modification notices remain mandatory. Screenshots, recordings, audio, and
public-site media are not covered by the catalog PASS and must be separately
inventoried before publication. Exact-path staging remains mandatory for any
unreviewed non-catalog files.

## Safe public claims

- YouNew is a SwiftUI iOS guide for newcomers to the Netherlands.
- The repository contains implementation and reports consistent with the documented
  Codex-assisted workflow.
- An independent clone built the bounded product snapshot and passed 460/460 unit
  tests and offline structural static QA.
- The deterministic assistant fallback is available and explicitly labelled local
  guide mode.
- The Map → Home first-tap blocker is fixed and targeted-verified: 3/3 checks and
  10/10 first-tap transitions in the recorded configuration.
- The repository contains bounded GPT-5.6 Responses API integration code; live
  GPT-5.6 access and deployment are not runtime-verified.
- The shipped 170-asset catalog has complete deterministic rights records and zero
  unresolved assets; third-party conditions remain in force and non-catalog release
  media requires separate review.

## Prohibited claims

- Production-ready, submission-ready, all gates green, or judge-ready repository.
- A green current UI gate.
- Live GPT-5.6 inference, deployed backend, provider access, or model substitution.
- A GitHub remote, judge access, TestFlight, App Store release, or submitted entry.
- Repository-wide media clearance, ownership, or license grant.
- Current external-link health, full population of all 34 categories, or legal,
  medical, immigration, insurance, eligibility, entitlement, or timing guarantees.

## Frozen non-demo limitations

- Full post-fix aggregate UI evidence is not claimed.
- Eighteen shipped external URLs are recorded as broken in point-in-time evidence.
- Live GPT-5.6 is neither verified nor needed for the documented local demo.
- The shipped asset catalog passes its rights gate; screenshots, recordings, audio,
  and public-site media remain separate release scopes.
- Remote hosting, video publication, links, and submission remain owner-controlled.

## Finalization rule

`BuildWeek/FINAL_STATUS.md` is the canonical packaging verdict. This historical
report remains the source for bounded audit evidence only. No publish, push,
deployment, release, or submission action is authorized by this report.
