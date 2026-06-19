# AI System Architecture

## Mission

The assistant is an application subsystem, not a static FAQ renderer. It must answer from app knowledge, navigate to app destinations, adapt to user context, guide users through workflows, and refuse unsupported claims when verified app data is missing.

## Current Foundation

The codebase already contains the main subsystem pieces:

- `KnowledgeIndex` in `YouNew/Services/KnowledgeIndex.swift`
- `KnowledgeGraph` in `YouNew/Services/KnowledgeGraph.swift`
- `AppSearchEngine` in `YouNew/Services/AppSearchEngine.swift`
- `AIResponseComposer` in `YouNew/Services/AIResponseComposer.swift`
- `AIWorkflowEngine` in `YouNew/Services/AIWorkflowEngine.swift`
- `AIContextBuilder` in `YouNew/Services/AIContextBuilder.swift`
- `AIViewModel` in `YouNew/ViewModels/AIViewModel.swift`
- `AIAssistantView` in `YouNew/Views/AIAssistantView.swift`
- `RootTabView` global AI launcher in `YouNew/Views/RootTabView.swift`
- `AIAskButton` screen-local launcher in `YouNew/Components/AIAskButton.swift`

The current local path is:

1. User asks a question in `AIAssistantView`.
2. `AIViewModel` applies safety checks.
3. Active workflow is advanced, or a new workflow is started through `AIWorkflowEngine`.
4. If no workflow applies, `AIResponseComposer` queries `AppSearchEngine`.
5. `AppSearchEngine` queries `KnowledgeIndex`.
6. `KnowledgeIndex` returns ranked `KnowledgeSearchResult` values with graph neighbors and quick actions.
7. `AIResponseComposer` builds `AIResponse` with sections, sources, quick actions, and destination IDs.
8. `AIAssistantView` renders structured responses and action buttons.

## Required Production Contract

Every assistant answer must be produced from this contract:

```swift
struct AssistantRequest {
    let query: String
    let mode: AssistantMode
    let context: AIContext
    let conversation: [AIMessage]
}

struct AssistantGrounding {
    let primaryResults: [KnowledgeSearchResult]
    let graphNeighbors: [KnowledgeItem]
    let sources: [OfficialSource]
    let destinationCandidates: [AppDestination]
    let missingEvidence: Bool
}

struct AssistantPlan {
    let response: AIResponse
    let navigationIntent: AppDestination?
    let workflow: AIWorkflow?
    let auditTrace: AssistantAuditTrace
}
```

The assistant must not generate final content until `AssistantGrounding` is available. If `primaryResults` is empty, it must return the unverified response path with official sources, closest guide candidates if any, and a search action.

## Core Subsystems

### 1. Context Layer

Source: `AIContextBuilder`

Required inputs:

- current screen
- current route ID
- recent route IDs
- selected city
- selected province
- selected language
- user status
- completed checklist items
- completed guides
- saved items
- last searches
- current topic title and summary
- official sources for current screen

Production rule:

`AIContext` must be refreshed whenever selected tab, active destination, language, selected city, selected user status, checklist completion, saved items, or pending AI launch mode changes.

### 2. Knowledge Layer

Sources:

- mock and curated data files under `YouNew/Data`
- route definitions in `AppDestination`
- guide/article models
- cities and provinces
- nearby places
- official services
- documents
- institutions
- search answers

The index must be the only local source used by assistant answers. Static route shortcuts such as `AINavigatorRoutes.quickRoutes` are acceptable only as migration scaffolding and should be converted to `KnowledgeItem` records.

### 3. Retrieval Layer

Source: `AppSearchEngine`

Retrieval must:

- normalize multilingual synonyms
- search titles, summaries, categories, city, province, keywords, and source names
- boost exact title matches
- boost city/province context
- include graph neighbors
- include official source candidates
- return route candidates
- run off the main thread
- meet `<200ms` local retrieval at current index size

### 4. Composition Layer

Source: `AIResponseComposer`

Every response must contain:

- concise answer
- checklist when relevant
- warnings when relevant
- requirements or documents when relevant
- deadlines when relevant
- related topics
- official sources
- quick actions
- app destination ID
- verification state

If evidence is missing, use `AIResponse.unverified` or the missing-information path. Do not fill gaps from model memory.

### 5. Workflow Layer

Source: `AIWorkflowEngine`

Workflows are state machines over `AIWorkflow`. A workflow must ask targeted questions before routing the user when the answer depends on missing user facts.

Current workflow coverage:

- health insurance
- BSN registration
- DigiD
- fine or official letter
- housing
- what next

Required workflow expansion:

- municipality registration
- childcare and school
- GP and urgent care
- benefits and allowances
- taxes
- transport fines and OV-chipkaart
- moving address
- emergency and crisis flows
- work permit / residence permit handoff

### 6. Navigation Layer

Sources:

- `AppDestination`
- `AppNavigationResolver`
- `TabRouter`
- `RootTabView`

Assistant actions must use typed destinations whenever possible. String route IDs are allowed at the response boundary, but must round-trip through `AppDestination.aiRoute(for:)` and `AppNavigationResolver`.

Navigation action types:

- open guide
- open screen
- open city
- open province
- open source
- save
- share
- related topic
- ask follow-up

### 7. UI Layer

Sources:

- `AIAssistantView`
- `RootTabView`
- `AIAskButton`

Global AI entry points must support:

- Ask Question
- Explain Screen
- What Should I Do Next?
- Find in App
- Translate
- Guide Me

The global launcher already exists in `RootTabView` as `GlobalAIMode`. Production readiness requires each mode to set a distinct `pendingAIPrompt`, `pendingAIContext`, and expected `AssistantMode`.

## No-Hallucination Policy

The assistant may only assert facts that come from:

- `KnowledgeItem.summary`
- structured app data fields
- official source metadata
- verified graph neighbors
- current user context

When data is absent:

> I don't have verified information in the app for this yet.

Required fallback actions:

- Find in App
- Open Official Sources
- Open Official Source
- Save
- Share
- Related Topic

## Performance Rules

- Build `KnowledgeIndex.shared` once and prewarm it from background utility queue.
- Keep search synchronous but off-main for large calls, or wrap with a detached task when invoked from UI.
- Avoid network dependency for local answers.
- Cache verified answer plans by normalized query plus context hash.
- Do not cache unverified or safety-critical answers unless the cache key includes app version and knowledge index version.
- Do not block navigation while generating answers.
- Cancel stale assistant tasks when a new request starts.

## Production Interfaces To Add

1. `AssistantMode`

```swift
enum AssistantMode: String, Codable {
    case askQuestion
    case explainScreen
    case nextStep
    case findInApp
    case translate
    case guideMe
}
```

2. `AssistantAuditTrace`

```swift
struct AssistantAuditTrace: Codable {
    let query: String
    let normalizedQuery: String
    let contextRouteID: String?
    let resultIDs: [String]
    let relationIDs: [String]
    let sourceTitles: [String]
    let destinationID: String?
    let verified: Bool
    let latencyMS: Int
}
```

3. `KnowledgeIndexCoverageReport`

```swift
struct KnowledgeIndexCoverageReport {
    let totalItems: Int
    let itemsByType: [KnowledgeItemType: Int]
    let routedItemCount: Int
    let sourcedItemCount: Int
    let missingRouteIDs: [String]
    let deadRouteIDs: [String]
    let unsourcedCriticalItems: [String]
}
```

## Acceptance Criteria

- User asks "How do I get BSN?" and receives a grounded answer, documents, municipality registration route, BSN guide route, official source action, and follow-up workflow if address status is unknown.
- User asks "I need health insurance" and enters a multi-step workflow that asks work and registration status before opening the correct healthcare guide.
- User asks about an unsupported topic and receives the unverified response, official source fallback, and app search action.
- Every rendered quick action resolves to either a valid app destination, valid URL, save action, share action, related topic query, or follow-up prompt.
- No assistant response is generated from a hardcoded final-answer template without index retrieval or workflow state.
