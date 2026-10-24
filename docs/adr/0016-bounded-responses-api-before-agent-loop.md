# ADR-016 — Bounded Responses API before any agent loop

- Status: proposed
- Date: 2026-08-18
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: ADR-003, ADR-007, `DataProject/ai-evaluation/manifest.json`
- Related migrations: none

## Problem and context

YouNew's user-facing assistant must explain approved published guidance, preserve jurisdiction and freshness, cite official sources, admit uncertainty and escalate high-stakes questions. The repository currently demonstrates a local deterministic assistant and has an optional bounded `/v1/newcomer-demo` client contract, but it has no deployed OpenAI backend evidence.

Adding an agent loop would introduce tool selection, state, approval, tracing and failure modes that the current read-only question-answer workflow does not need. AI must not compensate for unreviewed content, perform government or professional actions, collect sensitive identifiers or allow commercial status to affect facts.

## Considered options

1. Keep the deterministic local assistant only.
2. Add one server-controlled OpenAI Responses API call after deterministic governed retrieval and before independent response validation.
3. Add an Agents SDK loop with tools, state and handoffs.

## Proposed decision

Keep option 1 as the truthful shipped state. Prepare option 2 as the first possible live experiment only after the documentation, human-content and eval gates pass. Do not implement option 3 until a measured workflow requires repeated tool calls, persisted state, approvals or handoffs.

The bounded contract direction is:

1. Accept only bounded question, locale, explicit location assumption, profile scope and client contract version. Reject or redact sensitive personal data before any model call.
2. Retrieve only published, human-approved, freshness-eligible records. Excluded and wrong-jurisdiction records never enter model context. Commercial/sponsor fields are omitted from retrieval and ranking.
3. Make one server-side model call with a versioned instruction and strict structured output. No client-side secret, arbitrary URL fetch, shell/file tool, browser action or state mutation is allowed.
4. Require short answer, ordered steps, location assumption, selected record IDs, official HTTPS sources with verified dates, uncertainty, escalation and a no-answer reason when evidence is insufficient.
5. Independently validate every record ID, citation, verified date, route and escalation against the server-owned context. Any mismatch, missing high-stakes source or malformed output returns the deterministic unverified/no-answer response.
6. Log bounded operational metadata only: request ID, model/prompt/context/retrieval versions, selected record IDs, latency, cost units, outcome and aggregate safety category. Raw questions and free-form answers are not retained by default.
7. Keep model and provider configuration server-side and allowlisted. The mobile/web clients display live origin only after the validated response carries the required request and model metadata.

## Consequences and risks

- The first live experiment remains small, reversible and testable against the existing deterministic assistant.
- Agents SDK features are deliberately unavailable until they solve an evidenced requirement.
- Human review of the eval corpus and content remains on the critical path; a large generated draft corpus does not prove model quality.
- The generic backend parser remains `.unverified`. The bounded newcomer parser and undeployed Worker reference now require release/source dates, location, uncertainty, escalation and a complete trace, but deliberately fail closed because no human-reviewed release is allowlisted.
- Official OpenAI documentation must be re-read immediately before implementation. On 2026-08-18 the required docs URLs could not be loaded in the active sandbox because DNS/network access was unavailable; this ADR is therefore architecture intent, not an API-compatibility assertion.

## Verification and acceptance

Before any non-production live call:

- review current official Responses, Agents and agent-evals documentation;
- approve at least the selected release eval subset with named human reviewers;
- review and freeze the existing strict JSON Schema plus the server/client public-contract validators;
- define model/prompt/retrieval versions and cost/latency limits;
- prove secrets are absent from app bundle, logs and Git;
- run baseline/candidate in the same environment with zero critical regressions;
- obtain owner approval for a non-production experiment.

Before choosing Agents SDK, record a separate ADR showing the required loop/state/tool/approval behavior and why a single bounded call is insufficient.
