# Missing Evidence Register

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20

This file lists claims that cannot be established from the current repository. Absence of evidence is not treated as evidence of failure unless the capability is demonstrably absent from the effective runtime path.

## External product/distribution evidence

| Required evidence | Why it is needed | Current status |
|---|---|---|
| App Store Connect “My Apps” screenshot | Proves app record, bundle ID, version, submission/review state | MISSING |
| TestFlight builds page | Proves a processed/current build, expiry and tester group | MISSING |
| App Store public listing URL/screenshot | Proves a public version | MISSING |
| Build upload/processing status | Proves upload rather than local readiness | MISSING |
| Xcode Organizer distribution archive/validation | Proves distribution signing and App Store-valid archive | MISSING; historical archive was Development-signed |
| Final App Privacy answers | Repository privacy policy/manifest do not prove App Store Connect declarations | MISSING |

The owner should provide screenshots with personal/certificate details redacted but with app name, version/build, status and date visible.

## GitHub/repository evidence

- No remote URL is configured.
- GitHub existence is NOT VERIFIED.
- Public/private visibility is UNKNOWN.
- There is no current-state clean clone because essential source/data are untracked.
- No final judge branch/commit hash exists for this working state.
- No LICENSE/third-party notice exists.
- Image redistribution rights are incomplete.
- No committed iOS CI result exists.

Required future evidence:

1. final commit hash and remote URL;
2. visibility screenshot or API response;
3. clean-clone build/test transcript on a new path/machine;
4. committed CI run URL;
5. license and asset-attribution review;
6. final secret-scan report on the exact public commit.

## AI and GPT evidence

### Repository-confirmable

- Local deterministic assistant implementation: `YouNew/ViewModels/AIViewModel.swift:238-425`, `YouNew/Services/AIResponseComposer.swift:4-42,362-415`.
- Dormant proxy client and Worker example: `YouNew/Services/AIClient.swift`, `BackendExamples/cloudflare-worker-ai-proxy.js`.
- Worker example model fallback `gpt-4.1-mini`: `BackendExamples/cloudflare-worker-ai-proxy.js:93`.
- Hard-coded dormant system prompt/context/parser/safety source: `YouNew/Services/AIClient.swift:190-231`, `YouNew/Services/AIContextBuilder.swift`, `YouNew/Services/AIResponseParser.swift`, `YouNew/Services/AISafetyFilter.swift`.
- Planning/architecture artifacts: `AI_SYSTEM_ARCHITECTURE.md`, `AI_WORKFLOWS.md`, `AI_CONTEXT_MODEL.md`.
- AI-related tests and historical reports: `YouNewTests/AIFoundationTests.swift`, `YouNewTests/AIAssistantAnswerEngineTests.swift`, `AI_RELEASE_AUDIT.md`.
- No pre-audit runtime source/config/existing-report/history reference to GPT-5.6. The generated audit files themselves necessarily contain the queried term.
- No pre-audit Build Week evidence package or ChatGPT export was found. `BuildWeekAudit/*` files are outputs of this audit, not historical proof of prior ChatGPT usage.

### Not repository-confirmable

- A deployed AI proxy/endpoint.
- A successfully correlated live provider request/response.
- A production model name.
- GPT-5.6 usage now or historically.
- Model/account/organization configuration.
- Full ChatGPT conversation history.
- Who authored any particular prompt.
- Which model produced old planning/code/report work.

Required runtime evidence for any live-AI claim:

1. deployed endpoint identity (secret-free);
2. client-to-backend request correlation ID;
3. backend provider log showing the selected model and successful response;
4. schema-compatible response accepted by the app;
5. uncut demo video from clean launch;
6. privacy disclosure and sanitized field-level payload review;
7. exact regression test for the Build Week scenario;
8. failure-mode tests for timeout, 429, malformed/empty and unavailable model.

## ChatGPT/GPT-5.6 workflow evidence

The repository cannot establish early idea discussions, old model choice, prompt authorship, or full decision history. Obtain from ChatGPT:

- export or screenshots of key conversations;
- visible conversation title and date;
- visible model badge/name where the claim depends on a model;
- initial concept and product-goal discussion;
- examples of human requirements becoming acceptance criteria;
- visual-reference uploads;
- explicit rejection and redesign requests;
- Codex task/report analysis and follow-up decisions;
- Build Week submission preparation.

Redact API keys, personal data, private account/workspace identifiers, unrelated messages, and hidden system content.

## Codex authorship evidence

Commit metadata contains no Codex/ChatGPT/OpenAI co-author marker. Repository-local tooling metadata does contain a `codex/structured-refactor-phase2` branch and six opaque `refs/codex/turn-diffs/checkpoints/...` refs; their internal identifiers are intentionally omitted. This is VERIFIED evidence of a Codex tooling/workflow footprint, while reports, QA scripts, chronology and one untracked explicit-approval marker are consistent with the documented AI-assisted workflow. None of it proves who wrote a specific line or commit, which model ran, or the missing session contents.

Use only:

> The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

Do not use “Codex wrote X” until session export, task record, or commit metadata supports it.

## Owner-role evidence

Repository reports support user-supplied visual references, rejection/refinement cycles, product/audience documents, and an explicit-approval workflow. They do not independently prove the identity of the person who performed every simulator/device check or authored every requirement.

Missing personal-attribution evidence:

- dated requirements/prompts authored by the owner;
- screenshot-review conversations;
- explicit rejection/rework messages;
- priority/audience decisions;
- simulator testing evidence tied to owner action;
- physical-device testing evidence tied to owner action;
- final approval/submission decisions.

## Test and runtime evidence

Current missing or incomplete evidence includes:

- full green unit suite (current: 446/450 pass);
- full green static aggregate (five commands fail across four distinct issues);
- a green full UI suite after repairing the six current failures (two 42 pt touch-target cases, two missing `transport.screen` cases, missing Rijksmuseum Search result, and Dutch-course Search assertion);
- exact requested address/newcomer AI scenario;
- current VoiceOver manual pass;
- complete Dynamic Type/device/language matrix;
- iPhone SE/15/17 Pro and iPad current screenshots;
- offline matrix across Home/Search/Map/AI/Places/Calendar;
- current Time Profiler trace;
- current main-thread/hang trace;
- current memory graph and leak ownership evidence;
- 30-minute navigation/media/map soak;
- snapshot/pixel-diff visual regression suite;
- distribution archive validation.

Historical CoreSimulator blockers are documented, but do not excuse missing current evidence. Each claim must be reclassified from historical only after a fresh artifact is attached.

## Content and release evidence

- `cities-v0.1.0` and runtime payload are untracked.
- Milestone/release status is internally inconsistent.
- Latest tracked dashboard is stale (5 published) relative to current local runtime (188).
- Live link reachability was not rerun during this audit; the 0-broken result uses stored evidence for 1,141 URLs.
- Semantic source-to-claim matching is not comprehensively reviewed.
- Hotel dataset remains empty in the latest local report.
- Deep governed multi-city parity beyond Amsterdam is missing.

## Media evidence

- Complete source URL, author/creator, exact license, modification and redistribution terms for all shipped images.
- Proof that ignored local image metadata will accompany the public repository or be reproducibly generated.
- OCR/EXIF/privacy scan of final screenshots/assets.
- Manual verification that public-business contacts and media can be redistributed.

## Demo/submission evidence

- No `.mov`, `.mp4`, `.m4v`, or `.webm` file was found.
- No final demo script or timestamped uncut capture exists.
- No Build Week submission receipt/draft was found.
- No judge-facing repository URL exists.

Video readiness must therefore remain at or below 10%; this audit rates it 0%.
