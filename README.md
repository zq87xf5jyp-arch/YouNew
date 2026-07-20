# YouNew

YouNew is a local-first SwiftUI guide for people building a life in the
Netherlands. It brings practical newcomer tasks, verified-source navigation,
cities, saved items, checklists, local discovery, and a structured assistant into
one iOS app.

This branch is a Build Week readiness candidate, not a published production
release. Current evidence and remaining blockers are stated below.

## 1. Overview

YouNew helps a newcomer move from a broad question to a concrete next action and,
where available, an official source. The application is intentionally independent
from any government body and does not provide legal or medical advice.

App identity: `nl.younew.app`, version 1.1 (5). The deployment target is iOS 17.6.

## 2. Problem

New residents face related tasks across different institutions: municipal
registration, BSN, DigiD, health insurance, a huisarts, transport, work, housing,
documents, and local services. Requirements vary with municipality, residence,
work/study situation, and immigration status. Search results alone rarely explain
which step unlocks the next one.

## 3. Solution

YouNew combines:

- structured newcomer guides and typed in-app destinations;
- a local KnowledgeIndex over governed content records;
- official-source cards and explicit uncertainty warnings;
- city, map, search, checklist, saved-item, and discovery surfaces;
- a deterministic local assistant that works without a provider credential;
- an optional bounded backend path for the named Build Week AI scenario.

The product separates mandatory steps from situation-dependent guidance and asks
users to verify consequential decisions with the relevant official institution.

## 4. Target users

The primary audience is a recent or prospective resident of the Netherlands who
needs an understandable sequence of practical steps. Secondary audiences include
international students, workers, partners/families, refugees, entrepreneurs, and
residents moving between municipalities. Content coverage and eligibility rules are
not complete for every status.

## 5. Main demo scenario

The named flow is `BuildWeekNewcomerDemo`:

1. Open AI Assistant.
2. Select or infer the new-resident context.
3. Ask: “I recently received an address in the Netherlands. What should I do
   first for BSN, DigiD, health insurance, and a huisarts?”
4. With a configured backend, request a structured GPT-5.6 response.
5. Review BSN/municipal registration.
6. Review DigiD.
7. Review health-insurance applicability.
8. Review finding a huisarts.
9. Open at least one linked YouNew guide.
10. Open at least one confirmed official source.

The answer must distinguish generally required actions from steps that depend on
municipality or personal status. A separate offline/error test demonstrates the
local guide fallback; the fallback is not presented as a live model response.

## 6. Screenshots

No screenshot is currently labelled judge-ready. Historical runtime and QA captures
exist locally, but they may be stale and have not all completed privacy and media-
rights review. Before submission, the owner should add current captures for:

| Required capture | Status |
|---|---|
| Home/newcomer context | Owner capture pending |
| Structured AI answer with source badge | Live backend proof and owner capture pending |
| BSN → DigiD in-app transition | Owner capture pending |
| Health insurance / huisarts steps | Owner capture pending |
| Interactive Netherlands map | Owner capture pending |
| Explicit local guide fallback | Owner capture pending |

Each final image must be produced from the final commit, contain no personal data or
secret, and use only rights-cleared media.

## 7. Architecture

```text
SwiftUI views
  -> typed AppRouter destinations
  -> view models and feature services
  -> ContentRepository / KnowledgeIndex
  -> bundled Swift + governed runtime JSON

AI Assistant
  -> local safety and named-scenario routing
  -> configured backend? -> AIClient -> backend -> OpenAI Responses API
  |                                      -> strict structured JSON
  |                                      -> actual model + request ID
  -> unavailable/error/invalid? -> deterministic local guide
  -> source/origin-labelled UI -> app destination or official HTTPS source
```

The iOS app never needs an OpenAI API key. The backend owns provider authentication,
the system instruction, bounded grounding context, model allowlist, timeouts, limits,
and output validation.

## 8. GPT-5.6 integration

Official OpenAI documentation identifies GPT-5.6 models as available through the
Responses API and supports Structured Outputs. This repository's target contract is
a server-owned, JSON-schema response with `summary`, ordered `steps`, `warnings`,
the model actually used, and a request ID. The bounded context uses existing YouNew
knowledge records for BSN, DigiD, health insurance, and huisarts guidance.

Implementation files are under `YouNew/Services`, the assistant view/view model, and
`BackendExamples/`. The backend is not deployed by this repository workflow. At the
current evidence cutoff, `OPENAI_API_KEY` and `YOUNEW_AI_BACKEND_URL` were absent and
no live request was executed. Therefore the accurate claim is **implementation
present/in progress; live GPT-5.6 runtime proof pending**, not “YouNew currently uses
GPT-5.6 in production.”

References: [GPT-5.6 announcement](https://openai.com/index/gpt-5-6/),
[GPT-5.6 model documentation](https://developers.openai.com/api/docs/models/gpt-5.6-sol),
and [Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs).

## 9. Local deterministic fallback

The established local path uses `AIWorkflowEngine`, `AssistantAnswerEngine`,
`AIResponseComposer`, `AppSearchEngine`, and `KnowledgeIndex`. It remains available
when the backend is not configured, offline, timed out, rate-limited, unavailable,
or returns an invalid response. The UI must label this path “Local guide mode” and
must not display a GPT-5.6 badge for it.

The fallback is useful product functionality, but it is not a live LLM, vector RAG,
legal expert, or government service.

## 10. Use of Codex

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.
Evidence packets describe requirements, implementation,
tests, results, decisions, limitations, and the additional screenshots/logs needed.
No source-line authorship or specific private Codex session is claimed without a
session export supplied by the owner.

## 11. Owner role

The owner is responsible for product direction, requirement acceptance, review of
generated or assisted work, final legal/privacy/media decisions, credentials,
deployment, repository visibility, distribution, demo recording, and submission.
The repository does not claim that the owner personally authored every source line.

Only the owner may authorize remote creation, push, backend deployment, TestFlight,
App Store release, public screenshots, or Build Week submission.

## 12. Technical stack

- Swift 5 and SwiftUI; iOS 17.6 minimum target
- MVVM-style view models, services, repositories, and typed routing
- URLSession and Codable/JSON contracts
- XCTest and XCUITest
- Python and shell static/data/media gates
- governed `DataProject` batches, schema, release manifests, and runtime import
- optional JavaScript serverless backend example
- OpenAI Responses API only through the backend

The Xcode workspace resolves SwiftPM dependencies recorded by the project; no
separate iOS package-install command is required.

## 13. Repository structure

| Path | Purpose |
|---|---|
| `YouNew/` | iOS application, services, bundled content, resources, and UI |
| `YouNewTests/` | unit and local integration tests |
| `YouNewUITests/` | runtime navigation, accessibility, content, and demo tests |
| `DataProject/` | governed data inputs, schema, migrations, releases, and reports |
| `scripts/` | static QA, import, media, data-health, and reproducibility tooling |
| `BackendExamples/` | bounded server-side AI integration; not proof of deployment |
| `BuildWeekAudit/` | frozen pre-remediation audit evidence |
| `BuildWeekFix/` | remediation and final readiness evidence |
| `.github/workflows/` | repository automation candidates; no GitHub run is yet proven |
| `admin-dashboard/public-site/` | optional public-site source, separate from the iOS demo |

Raw media workspaces, staging caches, dependencies, DerivedData, result bundles, and
signing material are intentionally excluded.

## 14. Setup

Requirements for the verified local configuration:

- macOS with Xcode 26.6 or a compatible version that supports the project;
- an installed iOS Simulator (the latest audit used iPhone 17 Pro / iOS 26.5);
- Python 3 for static/data gates;
- Node.js only for backend contract tests, if present.

Open `YouNew.xcodeproj`, allow Xcode to resolve the recorded Swift packages, select
the `YouNew` scheme and a simulator, then Run. A backend is not required for the
local deterministic assistant.

For a signed physical-device build, configure your own Apple development team. Do
not commit signing identities or provisioning profiles.

## 15. Backend setup

`BackendExamples/` is the server-side boundary. Review its README and tests before
use. A safe setup must:

1. store `OPENAI_API_KEY` in the provider's encrypted secret store;
2. configure only an explicitly supported GPT-5.6 model identifier;
3. restrict the endpoint/origin and add deployment-appropriate abuse protection;
4. run the backend contract tests;
5. deploy only after owner approval;
6. append `/v1/newcomer-demo` to the owner-approved HTTPS Worker origin and inject
   that full endpoint into the iOS `YOUNEW_AI_BACKEND_URL` build setting;
7. verify a real request's returned model metadata and request ID without logging
   question or answer bodies.

No backend deployment, credential provisioning, or live provider verification was
performed as part of repository preparation.

## 16. Environment variables

Copy `.env.example` only for local reference. Do not commit the populated file.

| Name | Scope | Required | Secret |
|---|---|---:|---:|
| `OPENAI_API_KEY` | Backend only | Live path | Yes |
| `OPENAI_MODEL` | Backend only | Live path | No; must pass the backend allowlist |
| `YOUNEW_AI_BACKEND_URL` | iOS build setting; full `/v1/newcomer-demo` URL | Live path | No, but environment-specific |

Never add `OPENAI_API_KEY` to Swift, Info.plist, Xcode build settings, asset catalogs,
test fixtures, logs, or the application bundle.

## 17. Build

Replace the simulator name only if it is unavailable locally:

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNew \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  clean build \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

The audited working tree completed a clean Debug simulator build. A clean-clone
build tied to a final curated commit is still required before submission.

## 18. Tests

Unit tests:

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNewUnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  test \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES
```

Static, import, data, media, accessibility, and content gates:

```sh
scripts/run-static-qa.sh
```

UI tests (serial execution is intentional for this suite):

```sh
xcodebuild \
  -project YouNew.xcodeproj \
  -scheme YouNewUITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  test \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  -parallel-testing-enabled NO
```

The last closed complete Stage 2 snapshot recorded unit **450/450 PASS** and static
**40/40 PASS**. Additional Build Week AI/demo tests and QA checks were added after
that snapshot and have focused passing results, but the expanded complete unit and
aggregate static reruns remain final-snapshot gates. The closed pre-remediation UI
result was **80/86**; one new fallback UI test has passed independently, while the
targeted original failures and complete post-fix UI suite are still pending. Do not
report the UI gate as green until closed result bundles cover the intended final
snapshot. See `BuildWeekFix/TEST_REMEDIATION.md`.

## 19. Demo instructions

1. Build the final curated commit on a clean simulator.
2. Configure the approved backend URL for the main live run; never configure a
   provider key in the app.
3. Open YouNew → AI Assistant and enter the address/new-resident question from the
   named demo scenario.
4. Confirm the response is marked live, displays the actual GPT-5.6 model metadata
   and request ID, and shows four ordered steps.
5. Open a BSN/DigiD/insurance/huisarts in-app destination.
6. Open one allowlisted official HTTPS source and return to YouNew.
7. Record the uncut main flow without exposing credentials, notifications, personal
   data, or backend logs.
8. Run the separate backend-unavailable test and confirm “Local guide mode”; do not
   splice that fallback into the main live demonstration.

If live model metadata cannot be verified, demonstrate only the local guide and say
so explicitly. Never substitute a saved response for live inference.

## 20. Privacy

YouNew is local-first, but it handles potentially sensitive newcomer questions and
documents. Users should not enter identifiers, bank details, medical records,
credentials, or exact addresses into the assistant. The optional live path sends a
bounded request to a separately operated backend; its deployed retention, hosting,
and legal configuration are not yet proven. Read `PRIVACY.md` and `SECURITY.md`.

Final App Store privacy labels, GDPR roles, support/privacy URLs, cache deletion,
backend retention, and shipping-binary behavior require owner review.

## 21. Media attribution

`MEDIA_ATTRIBUTION.md` inventories 72 manifest-backed `nl_*` assets; 65 require
attribution. The catalog also contains 98 non-`nl_*` imagesets outside that manifest
and an AppIcon. Their evidence is not yet reconciled into one complete rights ledger;
existing records conflict for some city/province identity assets. The repository-wide
license does not relicense third-party media. See `BuildWeekFix/MEDIA_RIGHTS.md`
before publishing screenshots, video, TestFlight builds, or a public repository.

## 22. Known limitations

- No deployed backend or live GPT-5.6 request is proven at the current cutoff.
- The full post-remediation UI suite and clean-clone proof are pending.
- The optional public-site package currently has no committed lockfile and uses
  semver ranges, so its dependency graph is not yet byte-for-byte reproducible.
- There is no Git remote, GitHub Actions run, TestFlight proof, App Store proof,
  final demo video, or submission receipt.
- Media rights remain partial; 98 non-manifest imagesets, the AppIcon, and one
  incomplete manifest license record block blanket redistribution until reconciled.
- Content is broad but uneven. Do not claim that all 34 categories are fully filled.
- Official procedures and links change; municipality/status-specific guidance must
  be reverified for consequential decisions.
- Legal, immigration, financial, and medical information is educational only.
- Performance, physical-device behavior, VoiceOver, Reduce Motion, and the complete
  device/language/Dynamic Type matrix are not release-certified.

## 23. Build Week status

Status at the 2026-07-20 documentation cutoff:

| Gate | Status | Evidence boundary |
|---|---|---|
| Clean Debug simulator build | PASS | Current working tree; clean-clone proof pending |
| Unit tests | STAGE 2 PASS / FINAL RERUN PENDING | Last complete snapshot 450/450; expanded suite added later |
| Static QA | STAGE 2 PASS / FINAL RERUN PENDING | Last aggregate snapshot 40/40; focused AI QA passed later |
| DataProject/import validation | PASS | Current local snapshot |
| UI tests | PENDING POST-FIX | Frozen baseline 80/86; do not claim 86/86 yet |
| Deterministic assistant | AVAILABLE | Local guide, not live LLM |
| GPT-5.6 implementation | PARTIAL | Official API contract researched; runtime proof absent |
| Repository safety | PARTIAL | Essential files still need a curated commit; no remote |
| Clean clone | NOT YET PROVEN | Must run outside the source working directory |
| README/security/privacy | PREPARED | Must be checked against final commit |
| Media rights | PARTIAL/BLOCKED | Unresolved assets listed in media evidence |
| Demo/submission | NOT READY | Owner credentials, captures, video, and submission required |

Do not call the project production-ready or submission-ready until required gates are
green on one curated commit and owner-only actions are complete.
