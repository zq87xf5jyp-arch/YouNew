# AI Assistant — Truthful Technical Description

Evidence cutoff: 21 July 2026  
Public classification: **local deterministic guided assistant**

## Short description

YouNew includes a structured knowledge assistant that guides users through
practical newcomer journeys. For the Build Week candidate, the demonstrated path
is local and deterministic: Swift code selects a bounded workflow, searches
indexed YouNew content, and constructs source-backed actions and next steps.

It is **not currently evidenced as a live GPT-5.6 or live OpenAI experience**.
It should not be described as a generative answer service.

## What the local assistant does

The assistant combines three local mechanisms:

1. **Workflow selection.** `AIWorkflowEngine` normalizes input and selects a known
   flow for BSN registration, DigiD, health insurance, housing, official letters
   or fines, or “what next” guidance.
2. **Deterministic progression.** Each workflow advances through explicit states
   and accepted choices. For example, the BSN journey asks whether the user has a
   fixed address and then whether DigiD guidance is needed.
3. **Indexed knowledge composition.** `AIResponseComposer` searches the local
   app index and assembles a bounded response with sections, warnings, next steps,
   typed in-app destinations, and official-source actions.

`AIViewModel` attempts active and newly matched local workflows before the later
service path. Responses record their origin, and the UI provides a local-guide
description rather than silently presenting a local result as live AI.

## Recommended Build Week journey

The reproducible local journey is:

1. Open the Assistant from Home.
2. Ask how to get a BSN.
3. Answer the fixed-address question.
4. Request DigiD guidance.
5. Open the resulting practical guide or content destination.
6. Open an official source action, such as the Government.nl BSN page or the
   official DigiD application page.

The flow is valuable because it converts a broad newcomer question into ordered,
repeatable actions. Its value does not depend on claiming free-form generation.

The repository also contains a bounded four-topic newcomer response for BSN,
DigiD, health insurance, and huisarts. It has a deterministic local fallback.
That combined path should be used in the public demo only if the final candidate's
runtime flow is separately reproduced; the BSN → address → DigiD workflow remains
the conservative default.

## Source and navigation behavior

Local responses can carry:

- one or more official-source records;
- explicit “open source” actions;
- typed app destination identifiers;
- structured response sections;
- a next-step recommendation;
- a safety note and verification state.

The presence of a source action means that the app can present the stored official
reference. It does not mean that every external URL is currently reachable. The
separate DataProject network-health report records 18 confirmed broken URLs across
the wider shipped dataset. The BSN and DigiD sources used in the demo should be
checked again during the final manual smoke test.

## Optional backend code: the exact boundary

The repository contains `AIClient` and a bounded `/v1/newcomer-demo` contract.
The client:

- accepts only the named newcomer scenario;
- sends a bounded question, locale, scenario identifier, context version, and
  existing knowledge-record identifiers;
- requires an explicitly configured endpoint;
- validates response size, origin, model allowlist, and request identifier; and
- falls back through `AIService` when the endpoint is absent or unavailable.

The model names in an allowlist are validation code, not proof that either model
ran. No preserved candidate artifact currently proves:

- that the endpoint was configured;
- that a request reached an OpenAI-backed service;
- that GPT-5.6 generated a response; or
- that a live response was used in the submitted app.

Accordingly, optional backend code is not part of the public capability claim.
Live LLM integration remains future work unless a separately reviewed server,
privacy boundary, runtime transcript, and result artifact are produced.

## Privacy boundary

The documented BSN workflow matching and local response construction execute
in-process. No API key is needed for that path.

This document does not claim that every possible assistant input is always
offline, because the source tree contains an optional client. If that client is
configured in a future build, its data handling, endpoint ownership, retention,
consent, and privacy disclosure must be reviewed before release. API keys and
provider secrets must remain server-side and must never be embedded in the app.

## Public wording

| Status | Wording |
|---|---|
| Safe | “YouNew includes a deterministic local guided assistant backed by structured workflows and indexed YouNew knowledge.” |
| Safe | “The assistant turns practical newcomer questions into repeatable journeys, in-app destinations, and official-source actions.” |
| Safe | “The Build Week demo uses the local BSN → address → DigiD workflow.” |
| Not supported | “Powered by GPT-5.6.” |
| Not supported | “Live OpenAI assistant.” |
| Not supported | “Generative AI answers.” |
| Not supported | “RAG” or “vector search,” unless a separate implementation and runtime artifact are produced. |
| Not supported | “Always correct,” “official advice,” or “production ready.” |

## Repository evidence

| Evidence | What it establishes |
|---|---|
| [AIWorkflowEngine.swift](../YouNew/Services/AIWorkflowEngine.swift) | Named workflows, deterministic states, accepted answers, and next-response selection. |
| [AIViewModel.swift](../YouNew/ViewModels/AIViewModel.swift) | Local workflow and local composition paths in the assistant request sequence. |
| [AIResponseComposer.swift](../YouNew/Services/AIResponseComposer.swift) | Indexed search, response sections, sources, actions, warnings, and destinations. |
| [KnowledgeIndex.swift](../YouNew/Services/KnowledgeIndex.swift) | Local indexed YouNew knowledge used by search and composition. |
| [AIAssistantView.swift](../YouNew/Views/AIAssistantView.swift) | User-facing response-origin and source/action presentation. |
| [BuildWeekNewcomerDemo.swift](../YouNew/Services/BuildWeekNewcomerDemo.swift) | Bounded source contracts and deterministic local fallback for the combined newcomer scenario. |
| [AIClient.swift](../YouNew/Services/AIClient.swift) | Optional bounded client and configuration guard; not live-runtime proof. |
| [AIService.swift](../YouNew/Services/AIService.swift) | Safety checks and deterministic fallback when the optional backend is not configured or fails. |
| [AIContext.swift](../YouNew/Models/AIContext.swift) | Guarded distinction between local and declared live response origin. |
| [YouNewUITests.swift](../YouNewUITests/YouNewUITests.swift) | Local newcomer flow and official-source action contracts; final run status is reported elsewhere. |

## Evidence still required before any live-AI claim

- A reviewed, deployed backend with documented ownership and privacy controls.
- A redacted runtime request/response transcript tied to the candidate build.
- Evidence of the actual provider and model used for that response.
- Failure, timeout, and offline-fallback validation.
- Owner approval of the resulting public wording.

Until all of those exist, the correct description is **local deterministic guided
assistant**.

