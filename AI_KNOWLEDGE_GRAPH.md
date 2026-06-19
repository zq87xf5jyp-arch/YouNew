# AI Knowledge Graph

## Purpose

The knowledge graph is the assistant's source of truth. It connects app content, app routes, official sources, cities, provinces, documents, workflows, warnings, deadlines, and related topics.

The assistant must query the graph before answering or navigating.

## Current Index Coverage

Measured from `KnowledgeIndex.shared`:

- total knowledge items: 770
- graph relations: 19,914
- routed items: 100
- sourced items: 649
- official source URL references: 711
- known AI route IDs: 23
- indexed route IDs: 12

Items by type:

| Type | Count |
| --- | ---: |
| appScreen | 8 |
| article | 49 |
| checklist | 13 |
| city | 12 |
| deadline | 3 |
| document | 3 |
| dutchCourseModule | 10 |
| dutchTerm | 37 |
| fine | 10 |
| guide | 72 |
| institution | 10 |
| knmModule | 10 |
| letter | 6 |
| mistake | 17 |
| nearbyPlace | 176 |
| officialService | 22 |
| province | 12 |
| resource | 35 |
| risk | 29 |
| rule | 15 |
| scenario | 14 |
| searchAnswer | 195 |
| topic | 12 |

## Canonical Node Schema

Current schema lives in `KnowledgeItem`.

Required production fields:

```swift
struct KnowledgeItem: Identifiable {
    let id: String
    let type: KnowledgeItemType
    let title: LocalizedKnowledgeText
    let summary: LocalizedKnowledgeText
    let category: String
    let city: String?
    let province: String?
    let keywords: [String]
    let route: AppDestination?
    let routeID: String?
    let sources: [OfficialSource]
    let lastReviewed: Date?
    let safetyLevel: KnowledgeSafetyLevel
    let sourcePath: String
}
```

Recommended additional fields:

```swift
let requirements: [String]
let documentsNeeded: [String]
let warnings: [String]
let deadlines: [String]
let workflowKind: AIWorkflowKind?
let audienceStatuses: [UserStatus]
let verifiedBy: [String]
let contentVersion: String
```

These fields should be explicit. The response composer should not infer requirements or warnings only from titles.

## Node Types

Current node types:

- guide
- article
- searchAnswer
- checklist
- document
- deadline
- officialService
- institution
- city
- province
- nearbyPlace
- fine
- rule
- letter
- dutchTerm
- knmModule
- dutchCourseModule
- risk
- mistake
- resource
- appTool
- appScreen
- topic
- scenario

Required additions:

- workflow
- workflowQuestion
- workflowOutcome
- officialSourceDirectory
- governmentService
- municipalityService
- userJourney
- appSection

## Relation Types

Current relation types:

- requires
- nextStep
- relatedTopic
- relatedGuide
- sameCategory
- officialSource
- opensDestination
- citySpecific
- provinceSpecific
- documentNeeded
- deadline
- warning
- fallback
- userStatusRecommended

Required relation behavior:

- `requires`: prerequisites, such as DigiD requiring BSN.
- `nextStep`: likely next user action after completing a topic.
- `relatedGuide`: guide/article to open from a topic.
- `officialSource`: source that must be shown for sensitive topics.
- `opensDestination`: app route opened by a node.
- `documentNeeded`: document required for process.
- `deadline`: deadline or time sensitivity.
- `warning`: scam, fine, safety, privacy, or legal caution.
- `fallback`: closest safe route when exact answer is missing.
- `userStatusRecommended`: route depends on student, worker, partner, asylum, tourist, or other profile state.

## Graph Construction

Current builder stages in `KnowledgeIndexBuilder.buildItems()`:

1. app screens
2. knowledge topics
3. life scenarios
4. official services
5. documents
6. municipalities
7. reminders
8. survival guide
9. beginner guides
10. guide content
11. checklist
12. fines
13. institutions
14. Dutch terms
15. letters
16. mistakes
17. risks
18. rules
19. scam warnings
20. legal info
21. daily life
22. LGBTQ support
23. nearby places
24. resources
25. KNM modules
26. Dutch course modules
27. search answers
28. provinces
29. cities

This is the right direction. The production issue is not lack of graph machinery; it is incomplete route coverage and weak explicit requirement/deadline fields.

## Ranking Rules

Current ranking:

- normalized phrase match
- normalized token match
- exact title boost
- title containment boost
- city entity boost
- province entity boost
- selected city context boost
- selected province context boost

Required ranking improvements:

- field weights: title > route title > official service > keywords > summary
- safety boost for official-source-backed items when query is legal, medical, financial, immigration, benefits, emergency, or fines
- workflow boost when query includes action verbs like need, apply, register, get, lost, received, deadline
- recency penalty for stale `lastReviewed`
- route availability boost
- user-context boost for status, completed guides, saved items, and current screen
- typo tolerance for common Dutch/Russian/English newcomer terms

## Query Pipeline

Required production pipeline:

1. Normalize query with multilingual synonyms.
2. Classify intent:
   - answer
   - navigate
   - workflow
   - search
   - explain current screen
   - translate
   - source lookup
3. Retrieve top local results from `KnowledgeIndex`.
4. Expand with graph neighbors.
5. Filter or rank by context.
6. Validate route IDs.
7. Validate official sources.
8. Compose answer with sections and quick actions.
9. Record audit trace.

## No-Answer Policy

If no verified node exists:

- do not generate from model memory
- return unverified response
- show official fallback source
- show closest guide if confidence is acceptable
- show app search action
- show related topic action

## Audit Queries

These queries must return verified graph-grounded answers:

- BSN
- DigiD
- municipality registration
- health insurance
- huisarts
- rent contract
- housing scam
- CJIB letter
- tax letter
- IND
- UWV
- DUO
- 112 emergency
- police non-emergency
- GP urgent care
- Dutch A1-A2
- KNM
- Amsterdam
- Rotterdam
- Utrecht
- North Holland
- South Holland
- official sources

## Known Coverage Gaps

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

Required fix:

Add `appScreen` or `appSection` `KnowledgeItem` records for each route ID. The audit must fail when a known route is not represented in the index.
