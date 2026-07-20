# AI Assistant Architecture Audit

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Scope: current dirty working tree, not only `HEAD`
Final classification: **MOCK/PARTIAL — local deterministic guided assistant; not live LLM**

## Status legend

- **VERIFIED** — supported by current source or a reproducible check.
- **PARTIAL** — implementation/evidence exists, but the complete runtime claim is not proven.
- **NOT VERIFIED** — no adequate evidence was found.
- **NOT IMPLEMENTED** — the requested capability is absent from the effective runtime path.

## Direct answer

The visible assistant works locally. It uses deterministic workflows, bundled lexical search, and template composition. A dormant HTTP client and a Cloudflare Worker example exist, but the current observable send path returns before the network call for every accepted non-empty question. Therefore the defensible status is **MOCK/PARTIAL**, not REAL LIVE AI, BACKEND AI, or CLIENT-DIRECT AI.

There is no evidence of GPT-5.6. The only explicit model name found is the backend example's fallback `gpt-4.1-mini` (`BackendExamples/cloudflare-worker-ai-proxy.js:93`). This is not evidence that the deployed app uses that model, because no deployment or endpoint is verified.

## Effective runtime path

```text
AIAssistantView
  -> AIViewModel.sendCurrentMessage()
     -> AIWorkflowEngine (local guided workflow)
     -> AssistantAnswerEngine (local direct answer)
     -> AIResponseComposer (local search/composition)
        -> AppSearchEngine
           -> KnowledgeIndex (bundled/static knowledge)
     -> early return for all accepted requests

Dormant/unreachable branch in the current flow:
     -> AIService
        -> AIClient
           -> YOUNEW_AI_PROXY_URL
              -> example Cloudflare Worker
                 -> OpenAI Responses API
```

The decisive evidence is:

- `AIViewModel.sendCurrentMessage()` runs workflow, direct-answer, and composer branches and returns on a local response: `YouNew/ViewModels/AIViewModel.swift:238-341`.
- `AIResponseComposer.compose()` always returns an `AIResponse`: found content produces a composed response; no content produces `missingInformationResponse`: `YouNew/Services/AIResponseComposer.swift:4-42,362-415`.
- The cache/network code is below those returns: `YouNew/ViewModels/AIViewModel.swift:343-388`.

## Verification matrix

| Question | Status | Evidence |
|---|---|---|
| Where is the UI? | VERIFIED with entry-point limitation | `AIAssistantView` owns an `AIViewModel`, input and send/cancel controls: `YouNew/Views/AIAssistantView.swift:96-97,428-543`. `.assistantHub` routes to it: `YouNew/App/Navigation/AppDestinationView.swift:219,818-830`. Home and Guide wire explicit entry buttons at `YouNew/App/AppTabView.swift:788-793,830-835`, with UI controls at `YouNew/Views/RootHomeView.swift:762-780` and `YouNew/Views/RootGuideView.swift:75-100`. The contextual floating launcher type exists but is disabled because `shouldShowContextualAIButton` always returns `false`: `YouNew/App/AppTabView.swift:310-334`. |
| Request handler | VERIFIED | `@MainActor final class AIViewModel` and `sendCurrentMessage()`: `YouNew/ViewModels/AIViewModel.swift:6-7,238-425`. |
| OpenAI called directly by iOS | NOT IMPLEMENTED | No OpenAI endpoint/client call is present in the iOS source. The iOS client targets an app-configured proxy only. |
| Own backend used now | NOT IMPLEMENTED in effective path | `AIService`/`AIClient` exist but are unreachable after the local composer response. |
| Serverless function | PARTIAL | Example only: `BackendExamples/cloudflare-worker-ai-proxy.js:1-5,86-127`. No `wrangler.toml`, deployment record, or live URL found. |
| Other AI system | NOT VERIFIED | No other model provider or on-device model was found. |
| Local/mock responses | VERIFIED | `AIWorkflowEngine`, `AssistantAnswerEngine`, `AIResponseComposer`, `AppSearchEngine`, and `KnowledgeIndex`. |
| Endpoint | NOT VERIFIED | `AIClient.configuredEndpoint()` expects `YOUNEW_AI_PROXY_URL`: `YouNew/Services/AIClient.swift:181-188`. The current project settings do not provide that Info.plist key. |
| Model | PARTIAL/example only | Example fallback `gpt-4.1-mini`: `BackendExamples/cloudflare-worker-ai-proxy.js:93`. No runtime/deployment proof. |
| GPT-5.6 | NOT VERIFIED | No pre-audit runtime source, configuration, existing report, commit metadata, or reachable-history evidence identifies GPT-5.6. The audit files themselves necessarily mention the queried term. |
| Client API key | NOT FOUND | iOS stores no OpenAI key. The Worker example expects server secret name `OPENAI_API_KEY`: `BackendExamples/cloudflare-worker-ai-proxy.js:2,89`; no value is present. |
| Secret in bundle | NOT FOUND by targeted scan | No strong-format credential or private-key block found in current text/reachable Git history. Scan limitations are in `BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md`. |
| System prompt | PARTIAL/dormant | `AIClient.systemPrompt`: `YouNew/Services/AIClient.swift:190-231`; not reached by the current local send flow. |
| Local retrieval | VERIFIED | `KnowledgeIndex` builds a lexical bundled index: `YouNew/Services/KnowledgeIndex.swift:3-43,50-118,126-330`. It is not vector RAG. |
| Citations/source links | PARTIAL | Structured source cards and HTTPS links are rendered at `YouNew/Views/AIAssistantView.swift:2187-2217`. Source-to-answer semantic matching is not guaranteed: the missing-information response attaches generic Government.nl while marking itself unverified (`YouNew/Services/AIResponseComposer.swift:362-415`). |
| Verified-only grounding | PARTIAL | Composer treats a source-backed item as verified, but also permits general content without a source: `YouNew/Services/AIResponseComposer.swift:27-37`. A displayed source card therefore does not, by itself, prove claim-specific grounding. |
| Hallucination protection | PARTIAL | Local unknown-query response explicitly says verified information is unavailable but still offers a generic official-source action (`YouNew/Services/AIResponseComposer.swift:362-415`). Dormant backend parser trusts a `verified` flag plus structurally valid HTTPS URLs; no semantic citation verification/allowlist is proven: `YouNew/Services/AIResponseParser.swift:54-67,103-123`. |
| Privacy notice | VERIFIED | Assistant warning: `YouNew/Views/AIAssistantView.swift:1929-1934`; disclosure: `YouNew/Views/PrivacyDataControlView.swift:266-292`; policy: `PRIVACY_POLICY.md:9-19`. |
| Message persistence | VERIFIED local, privacy limitation | `UserDefaults` v2 keys and migration: `YouNew/Core/Extensions/AppDataMigration.swift:3-29`; `AppDataMigration` begins at `:31`; save/load: `YouNew/ViewModels/AIViewModel.swift:878-943`. Raw user input is appended and persisted before safety evaluation (`YouNew/ViewModels/AIViewModel.swift:247-256,554-557`), so blocked/warned sensitive-pattern text remains locally until cleared/reset. |
| Demo without manual backend setup | VERIFIED for local flows | The local guided assistant needs no endpoint/secret. This does not demonstrate a live OpenAI model. |

### System prompt formation

The dormant HTTP prompt is not composed dynamically from the user profile. It is a hard-coded multiline constant, `AIClient.systemPrompt`, at `YouNew/Services/AIClient.swift:190-231`. It instructs a hypothetical model to use selected city/audience/screen/category, avoid invented sources and sensitive-data requests, keep answers practical, and return a named structure. It is serialized as the `systemPrompt` request field at `YouNew/Services/AIClient.swift:136-148`; runtime context and history are separate fields. The effective local path does not use any model/system prompt. The example Worker then concatenates the client-supplied system prompt, context, history and question (`BackendExamples/cloudflare-worker-ai-proxy.js:57-84`) rather than enforcing a server-owned prompt.

## Context and data

### Data used by the current local path

The local path can use bundled knowledge, current route/category, selected city/province, app language, persona/user situation, search context, saved/progress signals, and locally stored conversation state through `AIContextBuilder`, `AppSearchEngine`, and `KnowledgeIndex` (`YouNew/Services/AIContextBuilder.swift:73-142`; `YouNew/Services/AppSearchEngine.swift:12-37`; `YouNew/Services/KnowledgeIndex.swift:50-118`). Current unit failures in `KnowledgeDataGovernanceTests` and `KnowledgeIndexTests` mean complete index coverage/partner governance is not presently proven.

### Data the dormant HTTP request can serialize

If the network branch becomes reachable, `AIClient.RequestBody` can send:

- current question;
- app/assistant locale;
- current screen, selected section, category, topic title/summary and preferred destination;
- user situation/status, active and secondary persona tags, and persona search scope;
- selected city and province;
- current route identifier, recent searches and route history;
- official-source **titles and count only**;
- saved item identifiers/titles/kinds;
- completed checklist/guide identifiers and journey progress;
- up to the latest six messages.

Evidence: `YouNew/Services/AIClient.swift:27-113,125-149`; context construction: `YouNew/Services/AIContextBuilder.swift:73-142`.

The dormant request does **not** serialize exact GPS, document/photo contents, official-source URLs/page bodies, or local `hasBSN`/`hasDigiD`/`hasInsurance` flags. Those flags are built at `YouNew/ViewModels/AIViewModel.swift:496-510` but are not fields in `AIClient.RetrievalContext`. Source titles/count at `YouNew/Services/AIClient.swift:41-92` do not constitute sending the verified source content itself.

Because the HTTP branch is currently unreachable, no personal data is proven to leave the app through the AI Assistant in this working tree. This is a statement about the traced runtime path, not a general network/privacy certification for the whole app.

## Backend example incompatibilities

Even if reachability were fixed, the checked-in Worker example is not compatible with the current iOS contract:

1. iOS sends `contextRetrieval`: `YouNew/Services/AIClient.swift:27-39`.
2. Worker reads `body.context`: `BackendExamples/cloudflare-worker-ai-proxy.js:59`.
3. Parser accepts only `verified == true`: `YouNew/Services/AIResponseParser.swift:54-67`.
4. Worker response omits `verified`: `BackendExamples/cloudflare-worker-ai-proxy.js:96-126`.

The unchanged example would therefore not yield an accepted verified backend response.

The Worker is an undeployed example, so this is **not a verified current production vulnerability**. If deployed unchanged, it would also be publicly callable without app/user authentication or attestation, allow CORS `*` (`BackendExamples/cloudflare-worker-ai-proxy.js:12-16`), accept the system prompt from the client (`:57-59,78-84`), and enforce its IP rate limit only when the optional KV binding exists (`:28-48`). These are future deployment-risk candidates requiring a separate backend security design.

## Safety and error handling

| Condition | Status | Evidence/limitation |
|---|---|---|
| Empty input | VERIFIED | Local safety/input guards and unit-test coverage exist in `YouNewTests/AIFoundationTests.swift`. |
| Network failure | PARTIAL/dormant | `AIClient` produces transport errors; `AIService` reduces most to a generic unverified response: `YouNew/Services/AIClient.swift:3-20,151-169`; `YouNew/Services/AIService.swift:18-55`. |
| Timeout | VERIFIED in dormant transport | Request/transport timeout error handling: `YouNew/Services/AIClient.swift:3-20,151-169`. |
| Rate limit | VERIFIED in dormant transport | HTTP 429 classification exists in `AIClient`. |
| Malformed response | VERIFIED in dormant transport/parser | Decode/validation paths: `YouNew/Services/AIClient.swift:151-169`; `YouNew/Services/AIResponseParser.swift:54-123`. |
| Unavailable model | PARTIAL | No dedicated model-unavailable behavior was found; non-success status becomes generalized failure. |
| Empty response | VERIFIED in dormant transport | Empty/missing accepted answer is rejected by the parser/client path. |
| Sensitive-data warning | PARTIAL | `YouNew/Services/AISafetyFilter.swift:9-46` recognizes some identifiers/passport/medical terms, but not a complete address/email/phone/IBAN/name taxonomy. Evaluation happens only after raw input has been persisted (`YouNew/ViewModels/AIViewModel.swift:247-256,554-557`). |
| Clear chat | PARTIAL | Conversation/workflow responses are cleared, but 30-day answer cache is not; normalized user question participates in cache key: `YouNew/ViewModels/AIViewModel.swift:456-477,689-725,878-903`. |
| Dedicated error presenter | NOT USED | `YouNew/Services/AIErrorHandler.swift:3-40` exists; no current usages were found. |

## Requested Netherlands-address demo

Prompt intent: a recent newcomer now has an address and asks what to arrange first.

| Requirement | Status | Evidence |
|---|---|---|
| User can type the question | VERIFIED | Assistant composer accepts text and caps it at 2,000 characters: `YouNew/Views/AIAssistantView.swift:426-470`. |
| One-shot structured answer | NOT VERIFIED | No exact intent, fixture, unit test, or completed runtime capture for this combined prompt. |
| Gemeente registration | PARTIAL | Present within separate municipality/BSN workflow branches: `YouNew/Services/AIWorkflowEngine.swift:124-130,420-445`; not verified in the requested combined response. |
| BSN | VERIFIED in separate flow | `AIWorkflowEngine` BSN workflow, `YouNewTests/AIAssistantAnswerEngineTests.swift:221-237`, and the current frozen UI run's BSN/address paths. |
| DigiD | VERIFIED in separate flow | Workflow branches/actions at `YouNew/Services/AIWorkflowEngine.swift:140-151,434-460,506-510`; the current frozen UI run passed the BSN-to-DigiD action path. |
| Health insurance | VERIFIED in separate flow | Health-insurance guided workflow and UI definitions at `YouNewUITests/YouNewUITests.swift:182-270`; all named health-insurance assistant tests passed in the current frozen UI run. |
| Huisarts/GP | PARTIAL | Separate health-flow/action evidence: `YouNew/Services/AIWorkflowEngine.swift:413-415,498`; not verified in the requested combined response. |
| Banking/admin actions in same response | NOT VERIFIED | No exact combined-response evidence. |
| In-app transitions | VERIFIED for existing workflows | Typed quick actions and route resolution are implemented/tested. |
| Official sources | PARTIAL for existing workflows | Structured source actions exist; live semantic/reachability match for the exact prompt was not checked, and a generic fallback source is possible. |
| Repeat-run stability | NOT VERIFIED for exact prompt | No regression test/capture. |

Russian phrasing is especially risky. `AIWorkflowEngine` recognizes several English/Dutch “what next” phrases but no equivalent Russian trigger (`YouNew/Services/AIWorkflowEngine.swift:673-695`). `KnowledgeNormalizer` does not normalize the combined terms “address / moved / first priority” (`YouNew/Services/KnowledgeIndex.swift:3-43`), while indexed titles/summaries/keywords are largely English (`YouNew/Services/KnowledgeIndex.swift:68-112`). The expected missing-information outcome is an inference from source, not a fabricated runtime result.

## Safe competition scenarios

At most two scenarios are recommended, both described honestly as local guided assistance:

1. **BSN after receiving an address** — ask `How do I get BSN?`, choose that an address is available, then follow the DigiD action. Evidence: `YouNewTests/AIAssistantAnswerEngineTests.swift:221-237`; UI definition `YouNewUITests/YouNewUITests.swift:91-122`. The named narrow paths passed in the current 80/86 frozen UI run; the overall suite is still red and no uncut demonstration capture exists.
2. **Health insurance next steps** — ask `I need health insurance`, answer registration/employment follow-ups, then use guide/map/source actions. Evidence: UI definitions `YouNewUITests/YouNewUITests.swift:182-270`. The named health-insurance paths passed in the current frozen UI run; the overall suite is still red and no uncut demonstration capture exists.

Do not label either scenario GPT-5.6, live OpenAI, generative RAG, or backend AI.

## Historical evidence boundary

- `AI_RELEASE_AUDIT.md:154-168` states “STATIC PASS, LIVE AI RUNTIME UNVERIFIED”; that remains directionally honest.
- `AI_ARCHITECTURE_REPORT.md` (2026-06-15) says requests go through a proxy; this is superseded by the current early-return path.
- `AI_DISCLOSURE_REPORT.md` describes 12 turns/v1 storage; current code uses six turns/v2.
- Current AI-related files are modified but uncommitted, including `YouNew/Services/AIContextBuilder.swift`, `YouNew/Services/AIWorkflowEngine.swift`, and `YouNew/Views/AIAssistantView.swift`.

## Verdict

- REAL LIVE AI: **NO**
- BACKEND AI: **NO in current effective runtime**
- CLIENT-DIRECT AI: **NO**
- MOCK/PARTIAL: **YES**
- NOT WORKING: **NO** — local flows are implemented and testable, but they are not a live model
- UNKNOWN: **NO for classification; YES for any external deployment not represented locally**
