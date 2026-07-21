# BuildWeekNewcomerDemo evidence

Evidence cutoff: 2026-07-21 (Europe/Amsterdam)

Branch: `build-week-readiness`

Named flow: `BuildWeekNewcomerDemo`

Context version: `newcomer-after-address.v1`

## 2026-07-21 evidence boundary update

The prior `61e7ce11` UI aggregate is historical only. The last fully closed
clean-clone UI snapshot is `efd1a7c5` at **84/87 RED**; the current product/test
source `da8c3fe2` requires its own complete serial result. The focused fallback
evidence below remains useful for deterministic mode but does not certify the full
UI gate or a live response.

The local Worker contract now passes **13/13** mocked-upstream tests after a
canonical Responses-completion check was added. The earlier clean-clone 12/12
result remains historical. Neither count is live OpenAI proof.

## Demo readiness verdict

The named, bounded newcomer flow and its deterministic offline fallback are implemented. The local fallback has a passing targeted UI test. The live main path, external official-source opening, and judge-facing video are **not yet proven** because no deployed backend URL, backend credentials, or live GPT-5.6 response is available in this environment.

The contract fixture in `GPT56_INTEGRATION_EVIDENCE.md` is test data only. It must never be substituted for the main demo response or presented as a live model result.

## Required 11-step flow

| Step | Demo action | Repository implementation | Evidence status |
|---:|---|---|---|
| 1 | Open AI Assistant. | Assistant destination and `AIAssistantView` are available; UI tests launch directly into the assistant. | Implemented; local runtime exercised. |
| 2 | Select or establish a new-resident context. | The named quick prompt is offered for non-tourist context. For the judge flow, select the resident/newcomer context before entering the assistant. | Implemented; owner must capture the exact visible context transition. |
| 3 | Ask about first steps after receiving an address. | Multilingual canonical prompt in `BuildWeekNewcomerDemo.prompt(for:)`; matcher requires BSN, DigiD, insurance, and huisarts. | Implemented and exercised locally. |
| 4 | Receive a structured live GPT-5.6 response. | Named flow bypasses local intent interception and cache; only an exact validated GPT-5.6 model plus request ID can render the live badge. | **Blocked: no live backend/runtime proof.** |
| 5 | Show BSN. | Step 1 binds `topic:registration-bsn` to the municipality-registration guide and exact Government.nl source. | Implemented; fallback UI test exposes step 1. |
| 6 | Show DigiD. | Step 2 binds `topic:digid` to the DigiD safety guide and exact DigiD source. | Implemented; fallback UI test exposes step 2. |
| 7 | Show health insurance. | Step 3 marks applicability as situation-dependent and binds the health-insurance guide/source. | Implemented; fallback UI test exposes step 3. |
| 8 | Show huisarts. | Step 4 marks huisarts registration as recommended and locally variable, with an emergency caveat. | Implemented; fallback UI test exposes step 4. |
| 9 | Open at least one related app section. | Quick actions use allowlisted app destinations. Targeted UI coverage taps the BSN guide action and reaches `practicalGuide.municipalityRegistration`. | **PASS in targeted fallback UI test.** Live-run capture pending. |
| 10 | Open at least one confirmed official source. | Every step includes a server-owned HTTPS source action. A separate read-only cutoff check reached all four expected Government.nl/DigiD pages; targeted UI coverage verifies the action but does not tap through to the external browser. | URLs confirmed at cutoff; external-open runtime capture pending. |
| 11 | Demonstrate network fallback separately. | Missing backend and all live-path failures return a four-step `.localGuide` response with no model/request ID and a visible local badge. | **PASS in separate targeted UI test.** Keep it out of the main live video. |

## Stable demonstration script

### Main video — only after live verification

1. Start from a clean app state and select the resident/newcomer context.
2. Open AI Assistant and show the context cue.
3. Enter or select this canonical question:

   `I recently received an address in the Netherlands. What should I do first for BSN, DigiD, health insurance, and a huisarts?`

4. Wait for a response carrying all three runtime indicators:
   - `Live OpenAI · verified backend`;
   - an exact allowed GPT-5.6 model name;
   - a non-empty request ID.
5. Show the four ordered sections: BSN, DigiD, health insurance, huisarts.
6. Point out which steps depend on registration, gemeente, residence, work, or study status, and that the response gives no legal guarantee or invented deadline.
7. Open the BSN app guide (or another allowlisted guide) and return.
8. Open one of the exact official source actions and show the HTTPS destination.
9. End without claiming production readiness, legal advice, or universal eligibility.

If the response shows `Local guide mode`, `Unverified response source`, no model, or no request ID, stop the main take. That is not a live GPT-5.6 proof.

### Separate fallback take/test

1. Launch without `YOUNEW_AI_BACKEND_URL`, or use an isolated owner-approved failure environment.
2. Submit the same named prompt.
3. Show `Local guide mode` and the four deterministic steps.
4. Confirm no model or request ID is displayed.
5. Open the BSN app guide.
6. Label the clip as local/offline fallback and do not splice it into the live-response moment.

## Why the main answer is not pre-recorded

- The named prompt takes a dedicated backend path in `AIViewModel`.
- It bypasses the app's local intent interception and answer cache.
- Only a response that passes `AIResponse.isLiveOpenAI`, exact model allowlisting, request-ID validation, exact four-step source/route matching, bounds, and language checks receives live origin.
- All other outcomes are rebuilt from `BuildWeekNewcomerDemo.localResponse` and visibly labelled local guide mode.
- Legacy persisted responses default to local origin; they cannot become live merely because an older payload said it was verified.

These controls prevent a stored fixture from masquerading as live. They do not prove that a live request has happened; that requires the blocked runtime capture below.

## Automated evidence

| Layer | Check | Result | What it proves / does not prove |
|---|---|---|---|
| iOS unit | `BuildWeekNewcomerDemoTests` plus full unit suite | **PASS — included in clean-clone 460/460** | Existing KnowledgeIndex records/routes, accepted/rejected response contracts, exact fallback origin, legacy-cache behavior, endpoint rules, and final route integrity. |
| Backend | Node syntax + Worker contract tests | **PASS — local 13/13; historical clean-clone 12/12** | Exact request/response keys, GPT-5.6-only configuration, actual-model metadata, canonical Responses completion, native-only CORS behavior (`OPTIONS` → 405, `Allow: POST`, no `Access-Control-Allow-Origin`), source/route contract, sensitive-input rejection, safe errors, timeout, and upstream body cap. Provider fetch is mocked; not live proof. |
| Static QA | `scripts/ai-subsystem-static-qa.py` | **PASS — included in clean-clone 40/40** | Cross-file client/backend/source/route/fallback invariants. Not runtime proof. |
| iOS UI | `testBuildWeekNewcomerDemoUsesExplicitLocalFallbackWithoutBackend` | **PASS — 1/1 historical target; PASS in later 2/2 Assistant diagnostic** | The paired 51.933-second diagnostic (same clean clone/simulator) also passed healthcare map focus and named fallback, proving visible local origin, four structured steps, source-action presence, and BSN-guide navigation without a backend. It does not replace the red full-suite aggregate. |
| Build | Clean-clone simulator build | **PASS — 0 errors/warnings** | The implementation compiles from the curated source snapshot. Not live proof. |

Targeted UI result bundle: `<TEMP_DIR>/YouNewBuildWeekFixStage3/NewcomerFallbackUI.xcresult`.

The targeted test intentionally covers fallback, not a fake live response. It
confirms source-action presence but does not open an external browser. Complete
clean-clone totals are recorded separately in `CLEAN_CLONE_PROOF.md`. The old
one-time serial suite at `61e7ce11` is closed red at 82/87; the later full
clean-clone snapshot is red at 84/87. Its fallback failure showed an already running
Map/Russian launch state rather than the requested Assistant destination, while the
later paired diagnostic passed. No live or full-suite PASS is inferred.

## Files in the demo path

- `YouNew/Services/BuildWeekNewcomerDemo.swift`
- `YouNew/Services/AIClient.swift`
- `YouNew/Services/AIService.swift`
- `YouNew/Services/AIResponseParser.swift`
- `YouNew/Services/AISafetyFilter.swift`
- `YouNew/Models/AIContext.swift`
- `YouNew/ViewModels/AIViewModel.swift`
- `YouNew/Views/AIAssistantView.swift`
- `YouNew/App/Navigation/AppRouter.swift`
- `YouNew/Services/KnowledgeIndex.swift`
- `BackendExamples/cloudflare-worker-ai-proxy.js`
- `YouNewTests/BuildWeekNewcomerDemoTests.swift`
- `YouNewUITests/YouNewUITests.swift`
- `scripts/ai-subsystem-static-qa.py`

## Grounding shown in the demo

| Step | Knowledge record | Exact official host | App surface |
|---|---|---|---|
| BSN | `topic:registration-bsn` | `government.nl` | Municipality registration guide |
| DigiD | `topic:digid` | `digid.nl` | DigiD safety guide |
| Health insurance | `government-service:health-insurance` | `government.nl` | Health insurance basics guide |
| Huisarts | `government-service:gp` | `government.nl` | Finding a huisarts guide |

The response must keep mandatory/situation-dependent/recommended distinctions visible. Municipality and status dependencies must remain explicit. The presenter must not add deadlines, rights, obligations, or guarantees that are absent from the bounded records.

## Live verification still required

The owner must provide or approve all of the following before the main-flow status can change to PASS:

1. An owner-controlled HTTPS backend deployment for `POST /v1/newcomer-demo`.
2. `OPENAI_API_KEY` configured only as a backend secret.
3. An explicit allowed `OPENAI_MODEL` and confirmed account access to that exact GPT-5.6 model.
4. The full deployed endpoint supplied to the iOS build as `YOUNEW_AI_BACKEND_URL`.
5. A fresh-device run showing the live badge, actual model metadata, request ID, all four steps, an in-app destination, and one exact official HTTPS source.
6. A redacted record that correlates the returned request ID with the owner-controlled runtime without exposing the prompt, key, or personal data.
7. A separate offline/error run showing the local badge and no model metadata.
8. A judge-facing video recorded from the verified live run; no fixture text or fallback splice.

## Limitations and safe claim

- Live GPT-5.6, backend deployment, provider access, latency, availability, official-source external opening, and the final video remain blocked/unverified.
- The fallback is deterministic product functionality, not an LLM response.
- The Worker is reference code and still needs owner deployment security, abuse controls, and operational review.
- The four-step scenario is intentionally narrow; it is not evidence of an unrestricted general-purpose assistant.
- The local UI pass does not replace full-suite or clean-clone proof.

Safe public claim:

> YouNew contains a named, bounded newcomer demo flow with structured GPT-5.6 backend integration code and an explicitly labelled deterministic local fallback. The live GPT-5.6 demonstration remains subject to owner-provided backend credentials and runtime verification.
