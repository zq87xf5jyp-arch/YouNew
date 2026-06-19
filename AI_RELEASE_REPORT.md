# AI Release Report

## Status

Not production ready yet.

The app has a substantial assistant foundation, but the audit still finds route coverage gaps and missing release gates. The assistant should not be described as fully production ready until those are resolved with tests.

## What Is Already Implemented

- Local `KnowledgeIndex`
- Local `KnowledgeGraph`
- Local `AppSearchEngine`
- Structured `AIResponse`
- Response sections
- Quick actions
- Official source fallback
- Unverified response path
- User context model
- Context builder using screen, language, city, province, saved items, route, searches, checklist progress, and completed guides
- Multi-step workflow engine
- Global AI mode launcher in `RootTabView`
- Screen-local `AIAskButton`
- Answer cache for verified responses
- Safety filter and usage limiter surfaces

## Measured Audit

Measured from `KnowledgeIndex.shared`:

- total knowledge items: 770
- graph relations: 19,914
- routed items: 100
- sourced items: 649
- official source URL references: 711
- known AI route IDs: 23
- indexed route IDs: 12

Known AI route IDs missing direct index entries:

- assistant
- cities
- dutch
- fines
- healthinsurance
- huisarts
- institutions
- knm
- letters
- provinces
- settings

## Pass Criteria Review

| Criterion | Status | Notes |
| --- | --- | --- |
| AI can answer using app knowledge | Partial pass | `AIResponseComposer` queries `AppSearchEngine`, but coverage and ranking need audit gates. |
| AI can navigate users through the app | Partial pass | Quick actions and route IDs exist; not every known route is indexed. |
| AI can guide users through processes | Partial pass | Several workflows exist; more core workflows are needed. |
| AI can search all content | Partial pass | 770 items indexed; direct route coverage incomplete. |
| AI can open relevant screens | Partial pass | Route resolver exists; missing route index entries must be fixed. |
| AI adapts to user context | Pass foundation | `AIContext` captures city, province, language, status, saved items, recent routes, searches, checklist, guides. |
| AI behaves like a real assistant | Partial pass | The subsystem exists, but release gates and workflow coverage must be completed. |

## Critical Release Blockers

1. Missing direct index entries for 11 known AI routes.
2. No documented automated audit that every route, guide, article, city, province, and quick action is reachable.
3. Requirements, documents, deadlines, and warnings are partly inferred from result types and titles instead of explicit structured fields.
4. `AINavigatorRoutes.quickRoutes` still contains hardcoded navigation-answer content and should be migrated into the knowledge index or removed.
5. Workflow coverage is not yet broad enough for all high-risk newcomer journeys.
6. Search ranking is lexical and useful, but not yet robust enough for typo-heavy multilingual newcomer queries.
7. Global AI modes exist in UI, but each mode needs an explicit assistant-mode contract and tests.

## Required Fixes Before Release

### Route Coverage

Add `KnowledgeItem` records for:

- assistant
- cities
- dutch
- fines
- healthinsurance
- huisarts
- institutions
- knm
- letters
- provinces
- settings

Add a test that fails when:

```swift
Set(AppDestination.allKnownAIRouteIDs()).subtracting(Set(KnowledgeIndex.shared.items.compactMap(\.routeID))).isEmpty == false
```

### Graph Integrity

Add tests that verify:

- every relation `fromID` exists
- every relation `toID` exists
- every `KnowledgeItem.routeID` resolves
- every quick action destination resolves
- every sensitive item has at least one official source

### Structured Content

Extend `KnowledgeItem` or add a sidecar metadata model for:

- requirements
- documents needed
- warnings
- deadlines
- workflow kind
- audience status

Then update `AIResponseComposer` to use these fields directly.

### Workflows

Add workflows for:

- municipality registration
- healthcare navigation
- benefits and allowances
- taxes
- transport fines
- moving address
- emergency triage
- work and residence permit handoff

### Search

Improve `KnowledgeNormalizer` and ranking:

- more Dutch/Russian/English synonyms
- typo tolerance
- official-source boost for sensitive topics
- route boost
- workflow intent boost
- stale content penalty

### Launcher Modes

Make every `GlobalAIMode` set:

- `AssistantMode`
- prompt
- context
- expected retrieval behavior
- destination behavior

## Release Gate Checklist

- [ ] Route coverage audit passes.
- [ ] Graph integrity audit passes.
- [ ] Sensitive content source audit passes.
- [ ] Quick action resolver audit passes.
- [ ] BSN workflow audit passes.
- [ ] Health insurance workflow audit passes.
- [ ] Missing-information fallback audit passes.
- [ ] Local search benchmark is `<200ms`.
- [ ] Answer generation target is `<2s`.
- [ ] No main-thread search work over release threshold.
- [ ] No navigation action can push an invalid route.
- [ ] No static answer path bypasses retrieval or workflow grounding.

## Recommended Next Implementation Sprint

1. Add missing route knowledge items.
2. Add `KnowledgeIndexCoverageReport`.
3. Add graph and route audit tests.
4. Migrate `AINavigatorRoutes.quickRoutes` into `KnowledgeIndexBuilder`.
5. Add explicit structured metadata fields for documents, warnings, requirements, and deadlines.
6. Expand workflows for municipality registration and healthcare navigation first.
7. Add latency measurement around `AppSearchEngine.search`.

## App Store Review Position

The assistant should present itself as informational guidance, not legal, medical, immigration, or financial advice. Sensitive answers must show official sources and avoid collecting private identifiers.

Required UX copy already aligns with this through `AISafetyRules` and unverified fallback behavior. Keep that behavior mandatory.

## Final Readiness Decision

Current decision: hold release for AI subsystem claims.

The assistant architecture is viable and already partially implemented. Ship as production-ready only after route coverage, graph integrity, sensitive-source coverage, and workflow tests pass.
