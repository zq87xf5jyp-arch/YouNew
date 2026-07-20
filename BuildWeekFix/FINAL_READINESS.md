# Final Build Week readiness — draft

Evidence cutoff: 2026-07-20 (Europe/Amsterdam)
Branch: `build-week-readiness`
Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`
Document status: **DRAFT — final UI rerun and clean-clone proof are PENDING**

## Overall decision

**Overall readiness: NOT READY for submission.**

The repository now contains the named demo implementation, a bounded backend
contract, an explicit deterministic fallback, remediated unit/static failures,
judge-oriented documentation, and repository-safety evidence. It is not yet safe
to call production-ready or submission-ready. The final UI gate has not closed,
the candidate has not been proven from a clean clone, live GPT-5.6 has not been
runtime-verified, the working tree has not been curated into a reproducible
snapshot, and media rights remain incomplete.

This draft uses categorical evidence states rather than an invented readiness
percentage. A PASS below applies only to the stated evidence boundary.

## Readiness matrix

| Dimension | Current status | Evidence | Remaining gate |
|---|---|---|---|
| Build | **PASS — current working tree checkpoint** | A clean Debug simulator build completed locally. | **PENDING:** repeat from the curated clean clone and tie the result to the tested source snapshot. |
| Unit tests | **STAGE 2 PASS / FINAL RERUN PENDING** | The complete Stage 2 suite closed at 450/450 passed, with no skipped or expected failures. Focused AI tests also passed, but later contract hardening changed the final source snapshot. | **PENDING:** close the expanded complete unit suite on the final source snapshot and record the result bundle totals. |
| Static QA | **PASS — current working tree** | The current 40-command aggregate completed at 40/40; DataProject/import validation also passed. | Repeat in the clean clone and preserve the exact command/result record. |
| UI tests | **PENDING** | Frozen baseline: 80/86. All six failures were individually diagnosed and remediated. The separate newcomer fallback UI test passed 1/1. | **PENDING:** close the targeted six-test rerun, then the complete post-fix 87-test suite; do not infer PASS from an in-progress run. |
| AI Assistant | **AVAILABLE / PARTIAL** | The existing local deterministic assistant remains available and is visibly labelled local guide mode. The named flow fails closed to that fallback. | Complete final unit/UI reruns and verify the fallback again from the clean clone. |
| GPT-5.6 proof | **BLOCKED / NOT VERIFIED** | The iOS-to-backend implementation, exact model allowlist, structured-response validation, mocked backend tests (12/12), and official API-contract review exist. | A deployed owner-approved backend, protected credentials, actual allowed model metadata, provider request ID, and an anonymized live runtime check are absent. No live claim is permitted. |
| Repository safety | **PARTIAL / NOT JUDGE-SAFE YET** | Ignore rules, restrictive license draft, security/privacy documents, a targeted secret scan, essential-file inventory, and a proposed commit allowlist exist. No confirmed secret was found in the bounded scan. | Curate and review the mixed dirty tree, review staged content/history and personal metadata, decide the unresolved screenshot deletion, confirm licensing, and create the tested local snapshot. No remote or push is authorized. |
| Clean clone | **PENDING / NOT PROVEN** | No final clean-clone result exists yet. | Clone the curated local commit into a separate temporary directory; run documented build, unit, static, UI where supported, and fallback checks there. Record all closed results. |
| README | **PREPARED / FINAL VERIFICATION PENDING** | The README covers the requested 23 judge-facing topics and explicitly distinguishes local fallback from unverified live AI. | Reconcile its gate table and setup instructions with the final tested snapshot and clean-clone transcript. Add only rights-cleared final screenshots. |
| Media rights | **PARTIAL / BLOCKED** | A manifest-backed inventory covers 72 `nl_*` assets; 65 require attribution. | Confirm the missing license URL for one manifest item and reconcile 98 non-manifest imagesets plus AppIcon. Unknown rights must not be converted into guessed licenses or blanket redistribution claims. |
| Demo readiness | **PARTIAL / LIVE MAIN FLOW BLOCKED** | `BuildWeekNewcomerDemo` is implemented. The separate no-backend fallback test passed and opens a linked BSN guide. | Live GPT-5.6 response proof, an external official-source opening, final-snapshot capture, and an uncut judge video are missing. A fixture must not be shown as live. |
| Submission readiness | **NOT READY** | Technical remediation and evidence preparation are materially advanced. | Requires green mandatory gates on a reproducible snapshot, live-claim alignment, repository/media approval, judge access, rights-cleared captures, final video, and owner submission. |

## Gate detail

### Build

The current working tree has a passing local Debug simulator build. This proves that
the in-place project can compile in the audited environment; it does not prove that
all essential untracked files are captured or that a judge can reproduce it. Build
status must remain scoped to the current working tree until the clean-clone run
closes.

### Unit, static, and data gates

The four frozen unit failures were classified and corrected without disabling
tests, weakening assertions, or changing expected values merely to obtain green.
The last complete Stage 2 unit suite closed at 450/450. Seven named-demo tests were
added later, and the final expanded suite is still a required rerun.

The five frozen static-command failures were corrected through product fixes and
contract-aware matcher repairs. The current aggregate is 40/40. DataProject schema,
import, migration, and runtime validation pass in the current local snapshot.

### UI gate

The frozen UI baseline was 80/86. The six failures cover a real 44-point touch-
target defect and stale canonical route/result identifiers. The ledger in
`BuildWeekFix/TEST_REMEDIATION.md` records each cause and change. A separate new UI
test proves the named demo's explicit local fallback without a backend. The final
targeted and complete post-fix reruns are **PENDING**; therefore the UI gate is not
green in this draft.

### AI and GPT-5.6

The named iOS flow sends a bounded request only to an owner-configured backend. It
does not contain an OpenAI key, does not send conversation/profile state, validates
the response shape, model, request ID, sources, routes, language, and size, and
falls back to the deterministic local guide on every invalid or unavailable live
path. The backend example stores the key only in an environment variable, calls the
Responses API with structured output and `store: false`, applies limits/timeouts,
and does not log request or answer bodies.

The implementation is not runtime proof. At the evidence cutoff, the three required
environment variables were unset, the backend was undeployed, and no live provider
response had been captured. GPT-5.6 status is therefore **NOT VERIFIED / BLOCKED**,
with no silent model substitution allowed.

### Repository, privacy, and secrets

The repository remains a mixed dirty working tree inherited from owner work. The
readiness work did not discard those changes. Essential product sources, tests,
DataProject inputs, scripts, backend files, and evidence have been inventoried; build
products, result bundles, dependencies, local hosting metadata, signing material,
and local environment files are excluded by policy.

The bounded current-tree/history pattern scan found no confirmed secret. Dedicated
secret scanners, comprehensive binary/OCR/EXIF review, full personal-data review,
and deployed-secret-store review were not available. Git author metadata, signing-
team metadata, fixtures, institutional contact data, and legal/medical content still
require owner review. The safe claim is targeted-scan evidence, not security
certification.

### Media

Media is the principal public-redistribution blocker. The 72 manifest-backed assets
are not a complete catalog clearance: one lacks a recorded license URL, 98
non-manifest imagesets and AppIcon remain outside that reviewed manifest, and some
provenance records conflict. Unresolved assets must be proven, replaced, or excluded
from public repository and demo material.

## Current safe public claims

- YouNew is a SwiftUI iOS guide for newcomers to the Netherlands.
- The repository contains implementation and reports consistent with the documented Codex-assisted workflow.
- The current working tree has completed a clean Debug simulator build.
- The complete Stage 2 unit suite passed 450/450, while the expanded final suite remains pending.
- The current static aggregate passes 40/40, with clean-clone repetition pending.
- The local deterministic assistant is available and explicitly labelled local guide mode.
- The repository contains a bounded GPT-5.6 Responses API integration, but live GPT-5.6 access and deployment have not been runtime-verified.
- Media rights are only partially documented and do not support a blanket redistribution claim.

## Claims that remain prohibited

- production-ready, submission-ready, or all mandatory gates green;
- UI 87/87 until the closed complete post-fix result exists;
- live GPT-5.6, production OpenAI inference, or deployed backend;
- public/private GitHub repository, current TestFlight, or App Store availability;
- repository-wide media clearance or complete rights ownership;
- full population of all 34 content categories;
- legal, medical, insurance, residence, eligibility, or timing guarantees.

## Remaining blockers

1. Final targeted and complete UI results are **PENDING**.
2. Final expanded unit result on the frozen source snapshot is **PENDING**.
3. Curated local commit and clean-clone proof are **PENDING**.
4. Live GPT-5.6 runtime verification is **BLOCKED** pending owner backend access,
   credentials, deployment approval, and a safe runtime check.
5. Media rights remain **PARTIAL / BLOCKED**, including 98 non-manifest imagesets,
   AppIcon, and one incomplete manifest license record.
6. The owner must review license, privacy, legal/medical content, personal metadata,
   fixtures, screenshots, and public visibility.
7. No Git remote, push, deployment, TestFlight/App Store release, video, or
   submission has been performed.

## Finalization rule

Replace every PENDING field only from a closed artifact tied to the same curated
source snapshot. If a required gate remains red or unavailable, retain the exact
technical limitation and demonstrate the deterministic fallback honestly. Do not
upgrade this verdict to submission-ready until the clean-clone and mandatory test
gates are green and all owner-only release decisions are complete.
