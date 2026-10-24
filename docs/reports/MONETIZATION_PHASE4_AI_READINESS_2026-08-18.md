# YouNew monetization readiness — Phase 4 AI and content operations

Date: 2026-08-18 (Europe/Amsterdam)  
Mode: repository audit, deterministic verification and proposed architecture only. No OpenAI request, key access, backend deployment, dataset upload or production change occurred.

## Outcome

Phase 4 is **PARTIAL / NO-GO at Gate 4**. YouNew has unusually strong fail-closed foundations: the shipped assistant is truthfully local and deterministic; the optional native client accepts only one bounded scenario endpoint; retrieval policy excludes unsafe statuses and wrong municipalities; responses require sources; and a 1,000-case multilingual/adversarial corpus plus deterministic comparator exists.

The existing **undeployed** Cloudflare Worker reference and iOS parser have now been hardened around a mandatory content-release ID/date, source check dates, user-visible location assumption, uncertainty, escalation and complete decision trace. The checked-in server release remains `qa`, so the Worker returns `503 knowledge_not_release_eligible` before contacting OpenAI. The independent iOS release allowlist is empty, so backend metadata alone cannot create a live answer.

This closes the safe contract gap but does not open the release gate. The corpus is not release evidence: **0/1,000 cases are human-approved**, every generated case is draft/non-release-eligible, and no baseline/candidate model runs exist. No deployed OpenAI backend or live request is evidenced.

## Architecture decision

ADR-016 proposes **no Agents SDK at this stage**. The required workflow is one controlled, read-only explanation over server-selected records, so the smallest appropriate future experiment is one server-side Responses API call with strict structured output and an independent validator. Agents SDK becomes justified only if a measured need appears for repeated tool loops, state, approvals or handoffs.

The current product claim remains: local deterministic assistant, no live OpenAI inference. The checked-in Worker is a contract-tested reference, not a configured service.

## Current contract inventory

| Requirement | Evidence | Decision |
|---|---|---|
| Only published/approved sources | Worker default is a server-owned `qa` release and fails before the provider call; iOS independently requires an exact bundled release ID/date | Fail-closed; no release approved |
| Short answer and steps | Local composer and bounded demo parser provide structured sections/actions | Ready locally |
| Location assumption | Bounded response requires localized user-visible scope and the UI displays it; language guard checks it | Ready in the bounded reference; no approved release |
| Official sources | Exact server-owned title/URL/route contracts for all four records; trace must cite the same set with no duplicates | Ready in the bounded reference |
| Verified date | Release date plus exact per-source dates are mandatory, valid ISO dates and surfaced as `OfficialSource.lastChecked` | Ready in the bounded reference; dates do not equal human approval |
| Uncertainty | Mandatory localized structured field, length-bounded and displayed | Ready in the bounded reference |
| Escalation | Mandatory localized structured field includes 112 and official/professional escalation, then is language-checked and displayed | Ready in the bounded reference |
| Sponsor independence | Retrieval rank uses jurisdiction, official source, freshness, confidence and stable ID; no sponsor input | Ready in deterministic policy; local partner text still needs explicit presentation separation |
| Content expiry/review | Verification state, next review, overdue and exclusion logic exist | Ready structurally; human operations incomplete |
| Tracing/cost | Decision trace and eval cost/latency schema exist | No live trace or cost monitoring evidence |
| Client secrets | Native client contains endpoint only; undeployed Worker reads the key server-side and never logs/returns it | Ready by inspected reference; deployment not evidenced |

## Fail-closed implementation evidence

- Backend contract tests: **15/15 PASS**, including default QA-release rejection before the mocked OpenAI fetch, exact release metadata, invalid dates/reviewer, exact response keys, upstream failures, byte limits and timeout.
- `scripts/ai-subsystem-static-qa.py`: PASS, including release/date/boundary/trace enforcement across backend, parser, model, UI and tests. It resolves all five governed DataProject records, confirms they remain QA, and matches their exact official source URLs and `2026-07-14` check dates. The health-insurance and GP backend mappings were corrected from adjacent `healthcare.*` topics to the exact canonical government records.
- Swift syntax parse for all six edited model/parser/UI/test files: PASS.
- Post-edit iOS build/tests: environment-blocked before compilation because the managed sandbox denies SwiftPM's nested `sandbox-exec`; Simulator service is also unavailable. Cached packages and temporary writable caches did not change that boundary. Therefore the earlier 473-test result is retained only as pre-edit evidence and is not represented as post-edit validation.

## Eval evidence

- Corpus: **1,000 cases** across English 400, Dutch 300 and Russian 300.
- Partitions: development 200, held-out validation 300, held-out regression 400, held-out adversarial 100.
- Safety/privacy/emergency/refusal: 150 cases.
- Prompt injection/malformed/offline: 100 cases.
- Defined release thresholds: 100% critical safety/privacy/source-status, ≥98% groundedness/citation/jurisdiction/refusal, zero critical regressions, no objective drop above 1 percentage point, and explicit ADR for >20% cost/latency regression.
- `validate_ai_regression_corpus.py`: PASS; composition and source IDs close, generated drafts remain fail-closed.
- Comparator unit tests: **2/2 PASS**; unapproved cases and missing groundedness block release.
- Human approval: **0/1,000**; evidence state `not_established`.
- Baseline run: missing. Candidate run: missing. Independent calibrated subjective grades: missing.

The dataset exceeds the requested 30-case minimum numerically but fails the release-quality requirement because generated repetitions and unapproved expected outcomes cannot validate a live model.

## Documentation gate

The OpenAI Developers skill requires the current Agents guide before Agents SDK changes and the current agent-evals guide before eval changes. Attempts to read the official pages through the available web path returned no content, and direct access failed with DNS resolution blocked for `developers.openai.com`. No Agents SDK or eval implementation was changed. The existing undeployed Responses API reference was only hardened around server/client release eligibility and its public contract; its provider request shape was not expanded. Before any live prototype, SDK work or eval mutation, read:

- `https://developers.openai.com/api/docs/guides/agents`
- `https://developers.openai.com/api/docs/guides/agent-evals`
- the current official Responses API guide and structured-output guidance linked from the OpenAI developer documentation.

## Gate 4 decision

| Criterion | Evidence | Decision |
|---|---|---|
| Eval threshold set before launch | Versioned thresholds exist | GO |
| 100% high-stakes source and escalation | Mandatory in the bounded contract; no approved/live eval run | PARTIAL |
| Honest no-answer | Fail-closed unverified response exists | GO locally |
| Prompt-injection tests preserve rules | 100 draft adversarial cases; no executed model run | PARTIAL |
| Tracing and cost monitoring | Schemas only | NO |
| No secrets in clients/logs/Git | Client/Worker design and static policies support this; no deployed-environment proof | PARTIAL |

**NO-GO for Gate 4, live OpenAI inference, Agents SDK, dataset upload or deployment.**

## Next smallest useful action

Have named reviewers approve the **five governed DataProject records behind the four bounded client steps** as one dated release and approve a diverse eval subset (at least 30 cases, including every critical behavior type). After the official-docs gate is complete, add the same reviewed release ID/date to both server code and the iOS allowlist in one reviewed change, run backend/iOS/eval verification, and request separate owner approval for a non-production live Responses API experiment. Keep the other generated cases as drafts rather than bulk-approving them.
