# OpenAI Build Week Readiness

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Decision basis: current local working tree, fresh simulator/static checks, Git history and repository artifacts

## Overall decision

**Overall readiness: 35% — NOT READY for submission.**

YouNew has a substantial product implementation and unusually broad technical evidence. The blockers are not lack of product work; they are claim accuracy, reproducibility and release proof. The effective AI path is local/deterministic, the current unit/static/UI baselines are red, the audited state is not committed or remotely reproducible, and no TestFlight/App Store/video evidence is present.

## Readiness matrix

Percentages are audit judgments against a judge-ready submission, not measured product telemetry.

| Category | Readiness | Verified strengths | Blockers | Exact next action | Expected evidence after completion |
|---|---:|---|---|---|---|
| Product demo readiness | 55% | App builds; current UI tests pass the narrow BSN/DigiD and health-insurance guided paths; source cards and typed routes exist. | Requested combined newcomer/address scenario is not proven; overall UI suite is 80/86, not green; no uncut demo capture. | Freeze one narrow, truthful local-assistant path and add an exact combined-scenario regression or use the passing narrow flow. | Passing exact test plus uncut capture showing prompt, structured answer, sources and route. |
| Stability | 40% | Clean Debug simulator build; 446/450 unit entries, 35/40 static commands and 80/86 UI tests pass. | Four unit failures, five failing static commands/four distinct issues, six UI failures, no current soak/profile. | Repair only after owner authorizes phase two; rerun clean build, unit, static and full UI suites on the final commit. | Green `.xcresult` bundles, static transcript and soak/profile artifacts tied to one commit. |
| AI scenario quality | 35% | Deterministic structured guidance, local knowledge lookup, citations/source cards, privacy copy and failure copy exist. | It is not live model inference; grounding is partial; exact multi-topic scenario and Russian wording are not proven. | Decide whether to present honestly as local guided intelligence or implement and prove a compatible backend AI path. | Claim-aligned architecture diagram, exact-scenario test and, only for live AI, correlated backend/model logs. |
| Codex evidence | 65% | Repository contains implementation, audits, QA scripts, import/release artifacts and iteration reports consistent with a Codex-assisted workflow. | No session export or commit attribution proves that Codex wrote specific code. | Export dated Codex tasks/sessions and map each selected example to commits/reports/tests. | Five traceable before/requirement/result/evaluation evidence packets. |
| GPT-5.6 evidence | 0% | None before this audit. | No pre-audit GPT-5.6 reference in runtime/config/history/existing reports; dormant Worker names `gpt-4.1-mini`. Generated audit files necessarily mention the queried term. | Remove GPT-5.6 claims unless external model/session evidence exists; if used later, capture provider-side proof. | Dated model-visible ChatGPT export or provider log, with secrets redacted. |
| Product story | 70% | Clear newcomer mission, Netherlands focus, governed content, human-review artifacts and meaningful product breadth. | Owner decision chronology and Build Week narrative are not consolidated into public evidence. | Create a concise problem → human direction → AI-assisted build → verified result narrative. | Judge-facing README/submission text with dated links to evidence. |
| GitHub readiness | 15% | Local Git repository with 56 commits and a `.gitignore`. | No remote; public/private unknown; hundreds of dirty paths; essential files untracked; no LICENSE; large artifacts/licensing risks. | Curate a clean branch, add license/notices, exclude artifacts/secrets, push, then verify a clean clone. | Remote URL/visibility, final hash, clean status, clean-clone build and CI URL. |
| README readiness | 35% | README exists and describes basic setup plus mock/static limitations. | Stale/incomplete for judges; no verified architecture, exact setup, claims boundary or evidence index. | Rewrite after the final runnable commit is frozen. | README that reproduces build/demo from clean clone and accurately labels local/live components. |
| Demo video readiness | 0% | No video evidence. | No `.mov`, `.mp4`, `.m4v` or `.webm`; no final script or uncut capture. | Record only after the demo path and final build are frozen. | Dated playable file plus script and final-build identifier. |
| Submission readiness | 25% | Version/build, privacy manifest and Release configuration exist locally. | No distribution validation, TestFlight/App Store proof, judge repository, license, green baseline or submission receipt. | Complete the owner checklist in `OWNER_ACTIONS.md` in dependency order. | App Store Connect/TestFlight screenshots, public repo, green artifacts, video and submission receipt. |

## Safest competition claim today

**VERIFIED/PARTIAL:** YouNew can be demonstrated as a SwiftUI Netherlands newcomer information product with a deterministic, locally grounded guided assistant over bundled content. A narrow BSN → address → DigiD flow is supported by implementation and automated test definitions.

**Do not claim today:** live OpenAI inference, GPT-5.6, production AI, a public GitHub repository, active TestFlight, public App Store availability, a fully green test suite, or full multi-city content parity.

## Recommended demo scenarios

### Scenario 1 — safest

Ask about obtaining a BSN, answer the assistant's address question, then follow the DigiD next step. Evidence: `YouNewTests/AIAssistantAnswerEngineTests.swift:221-237` and `YouNewUITests/YouNewUITests.swift:91-122`.

Status: **PARTIAL but current narrow runtime path passed**. The frozen UI suite passed the BSN workflow cases, including municipality/documents/source/selected-city actions. It still needs an exact clean-launch capture, and the overall suite is red. Present it as a local guided flow, not live GPT.

### Scenario 2 — backup

Use the separate health-insurance guided flow and its structured actions. Evidence: UI test definitions in `YouNewUITests/YouNewUITests.swift:182-270` plus the local answer engine/composer described in `AI_ASSISTANT_ARCHITECTURE.md`.

Status: **PARTIAL but current narrow runtime path passed**. The health-insurance UI workflow completed in the frozen run; the overall suite and an uncut demo capture are still red/missing.

The requested single prompt combining municipality registration, BSN, DigiD, insurance, GP and banking is **NOT VERIFIED** and should not be the contest's unrehearsed main path.

## Five strongest Codex-workflow evidence candidates

Use the authorship-safe wording from `CODEX_EVIDENCE.md`.

1. Premium image system: roles, fallbacks, readability overlays, downsampling, bounded caches, actor coalescing and lifecycle guards.
2. Interactive Netherlands vector map: typed province/city data, geometry and hit-testing tests.
3. Governed content platform: 450 managed records, validation gates, release manifests and runtime-payload generation.
4. `cities-v0.1.0`: five-city manifest/import evidence with zero duplicate and broken-relation findings in the recorded preview.
5. Broad QA automation: unit/UI inventories plus accessibility, routing, content, media and release static gates—reported honestly, including current failures.

These demonstrate engineering breadth and evidence discipline. They do not, by themselves, establish line-by-line Codex authorship.

## Critical blockers in dependency order

1. Freeze and commit a reproducible product state; remove generated/device artifacts from judge scope.
2. Resolve licensing, asset provenance and repository LICENSE/NOTICE decisions.
3. Align the AI claim with reality; either demonstrate the deterministic assistant honestly or implement/prove live backend AI under a separately authorized phase.
4. Restore green unit, static and UI/accessibility baselines; attach current artifacts.
5. Configure a remote, verify public/private scope, and prove clean-clone build plus CI.
6. Validate a distribution archive and provide App Store Connect/TestFlight/public listing evidence as applicable.
7. Rewrite the judge README, record the final uncut demo and capture ChatGPT/Codex/owner-decision evidence.

## Direct answers to the 15 owner questions

### 1. How does the AI Assistant technically work?

**VERIFIED:** `AIAssistantView` passes user text to `AIViewModel.sendCurrentMessage()`. The effective path runs `AIWorkflowEngine`, `AssistantAnswerEngine`, `AIResponseComposer`, `AppSearchEngine` and `KnowledgeIndex` locally, then returns before the dormant `AIClient` network branch. It is deterministic guided logic over bundled/local content.

### 2. Does it use GPT-5.6?

**NOT VERIFIED:** No pre-audit GPT-5.6 evidence was found. The only explicit provider model is `gpt-4.1-mini` in an undeployed Cloudflare Worker example; that Worker is not the effective app path.

### 3. Is AI working in production, or is it mock/partial?

**MOCK/PARTIAL:** It is a working local guided assistant, not verified production LLM inference. Status: `MOCK/PARTIAL`, not `REAL LIVE AI`, `BACKEND AI` or `CLIENT-DIRECT AI`.

### 4. Is there a GitHub repository?

**NOT VERIFIED:** A local Git repository exists, but no remote is configured and no GitHub URL is present.

### 5. Is it public or private?

**UNKNOWN:** This cannot be determined without a remote or external GitHub evidence.

### 6. Can it be safely handed to judges?

**No, not in the current state.** Essential files are untracked; there is no license; large device artifacts and incomplete image-rights evidence remain; current test gates are red. The targeted text/history scan found no actual secret, but that alone is insufficient.

### 7. Is there a working README?

**PARTIAL:** `README.md` exists and gives basic setup/mock limitations, but it is stale and insufficient for judge reproduction and claim verification.

### 8. Is there a current TestFlight build?

**NOT VERIFIED:** No TestFlight processing/build evidence exists in the repository. App Store Connect/TestFlight screenshots are required.

### 9. Is there a public App Store version?

**NOT VERIFIED:** No public listing URL or App Store screenshot was found.

### 10. What main scenario can actually be shown?

The safest current candidate is the narrow local BSN → address → DigiD guided flow, with the health-insurance flow as backup. It must be described as deterministic/local and still needs a current clean-launch capture. The combined newcomer scenario is not verified.

### 11. Which test figures are confirmed now?

The fresh clean Debug simulator build passed with zero xcresult warnings/errors. Unit: 450 metadata entries, 446 passed, 4 failed, 0 skipped. Static: 35/40 commands passed; five failed across four distinct issues. UI: 86 total, 80 passed, 6 failed, 0 skipped. DataProject/import/structural checks passed on the audit snapshot. Exact artifacts/times are in `TEST_AND_QA_EVIDENCE.md`.

### 12. Which figures are only historical?

Historical reports mention varying totals such as 241, 378, 387 and 404/410 tests, prior static passes, accessibility PARTIAL and CoreSimulator blockers. No pre-audit repository/history occurrence or result artifact supporting the exact claims “42 unit tests passed” and “55 UI tests, 0 failures” was located; the generated audit files now repeat those queried strings. Historical artifacts do not override current red results.

### 13. Which five examples best demonstrate Codex work?

Premium image pipeline; interactive Netherlands map; governed content/import/release platform; `cities-v0.1.0`; and broad QA/accessibility/release automation. Say: “The repository contains implementation and reports consistent with the documented Codex-assisted workflow.”

### 14. What evidence is missing?

Live AI/model/GPT-5.6 logs; ChatGPT/Codex session exports; GitHub remote/visibility and clean clone; LICENSE/complete media rights; green current UI/unit/static artifacts; performance/memory/VoiceOver evidence; exact combined demo test; distribution/TestFlight/App Store proof; demo video; and owner-attributed device/review evidence.

### 15. What is mandatory before submission?

Create a clean licensed reproducible repository; align AI claims; achieve green current build/unit/static/UI gates; prove the exact demo; provide distribution/TestFlight/App Store status; rewrite README; attach five traceable Codex/owner evidence packets; record the final video; and submit with a receipt.

## Stop condition

This audit does not authorize fixes, publishing, deployment, release, repository push or submission. Await a separate owner instruction.
