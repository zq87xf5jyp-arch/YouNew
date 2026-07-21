# YouNew — Technical Overview

Evidence cutoff: 21 July 2026  
Document status: implementation-level overview for the Build Week candidate

## Evidence boundary

This document describes what is present in the current repository. It is not a
production-readiness certificate and does not replace the final build and test
artifacts. Current result counts, simulator details, duration, and pass/fail status
belong in `FINAL_VALIDATION.md` after the final candidate snapshot is closed.

## Product

YouNew is a native iOS application built with SwiftUI. It is intended to help
people navigate practical newcomer tasks in the Netherlands through structured
guides, official-source links, local discovery, saved content, a Netherlands map,
and a guided knowledge assistant.

The candidate is a demonstration build. The repository does not establish that
the app is production ready, that every content category is complete, or that a
distributed App Store or TestFlight build matches this checkout.

## Runtime architecture

| Layer | Current implementation | Primary evidence |
|---|---|---|
| Application shell | `YouNewApp` creates the SwiftUI scene, installs shared state stores, locale, migration, and startup prewarming. | [AppEntry.swift](../YouNew/App/AppEntry.swift) |
| Root navigation | `RootTabView` owns the canonical tabs and their navigation paths. Compact layouts use the app's custom floating tab bar; regular layouts can use side navigation. | [AppTabView.swift](../YouNew/App/AppTabView.swift) |
| Typed routing | `AppDestination` and `AppNavigationResolver` translate stable route identifiers into typed in-app destinations. | [AppDestination.swift](../YouNew/App/Navigation/AppDestination.swift), [AppRouter.swift](../YouNew/App/Navigation/AppRouter.swift) |
| Shared state | Observable state objects carry app, language, saved-item, and document state through the SwiftUI environment. | [AppEntry.swift](../YouNew/App/AppEntry.swift), [AppStateViewModel.swift](../YouNew/ViewModels/AppStateViewModel.swift) |
| Canonical content | `DataProjectRuntimeLoader` decodes the bundled governed payload. `ContentRepository` and `KnowledgeIndex` project that content for app consumers. | [DataProjectRuntimeLoader.swift](../YouNew/Services/DataProjectRuntimeLoader.swift), [ContentRepository.swift](../YouNew/Services/ContentRepository.swift), [KnowledgeIndex.swift](../YouNew/Services/KnowledgeIndex.swift) |
| Guided assistant | Local workflow and response engines normalize a query, select a bounded journey, retrieve indexed records, and build actions and source-backed sections. | [AIWorkflowEngine.swift](../YouNew/Services/AIWorkflowEngine.swift), [AIResponseComposer.swift](../YouNew/Services/AIResponseComposer.swift), [AIViewModel.swift](../YouNew/ViewModels/AIViewModel.swift) |
| Map | A custom SwiftUI surface renders Netherlands province geometry, labels, cities, landmarks, selection, zoom, and pan. | [NetherlandsInteractiveMapView.swift](../YouNew/Views/NetherlandsInteractiveMapView.swift), [PremiumNetherlandsMapModel.swift](../YouNew/Models/PremiumNetherlandsMapModel.swift) |
| Images | Shared role-aware views resolve local, remote, loading, and fallback states with focal-point policy, downsampling, cache bounds, and HTTP validation. | [AppContentImageView.swift](../YouNew/Core/Imaging/AppContentImageView.swift), [ImageLoader.swift](../YouNew/Core/Imaging/ImageLoader.swift), [NLDesignSystem.swift](../YouNew/Core/DesignSystem/Components/NLDesignSystem.swift) |

The architecture is intentionally pragmatic: SwiftUI views and view models are
combined with routers, repositories, shared stores, and service layers. It should
be described as a hybrid SwiftUI architecture, not as a strict or pure MVVM
implementation.

## Content and release path

The versioned `DataProject/` tree separates governed authoring data from the
runtime payload:

1. Schemas and work-package records define content structure and lifecycle
   metadata.
2. Release definitions declare scope, status, and QA gates.
3. Import tooling checks eligibility, lifecycle state, duplicate identifiers,
   relations, migrations, and release approval.
4. A deterministic production JSON payload is bundled with the application.
5. The runtime loader rejects malformed data rather than silently merging it.
6. Repository, search, assistant, guide, home, places, and map code consume
   canonical identifiers.

The platform currently contains seven release definitions. Two are marked
`published`; the remaining definitions are in `qa` or `planned` states. A
published metadata state is an internal content lifecycle fact, not evidence of
App Store publication.

The governed five-city release `cities-v0.1.0` contains Amsterdam, Rotterdam,
Den Haag, Utrecht, and Eindhoven. Its generated import preview is structurally
clean for that selected release. External URL health is a separate gate and is
currently not green; see [CONTENT_PLATFORM.md](CONTENT_PLATFORM.md).

## Local guided assistant

The recommended Build Week path uses the local deterministic assistant:

- `AIWorkflowEngine` contains bounded flows for BSN registration, DigiD, health
  insurance, housing, official letters or fines, and next-step guidance.
- The BSN flow asks whether the user has a fixed address and whether DigiD
  guidance is needed before constructing the next response.
- `AIResponseComposer` searches indexed YouNew knowledge and assembles sections,
  in-app routes, next steps, safety notes, and official-source actions.
- The UI distinguishes a local guide response from a live response.

The repository also contains a bounded optional backend client and a guarded
response type. Their presence is not runtime proof that a backend is configured,
that an OpenAI request succeeded, or that GPT-5.6 powers the app. The public
candidate description therefore remains **local deterministic guided assistant**.
See [AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md](AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md).

## Interactive Netherlands map

The map is not a static screenshot. Its implementation includes:

- geometry for all twelve Dutch provinces;
- exact path-based province selection with a bounded compact-target fallback;
- province labels, selected state, city markers, landmarks, zoom, and pan;
- typed navigation from map content into app destinations; and
- deterministic geometry tests, including a seeded 100-point interior sample.

Those facts establish the implementation and its deterministic geometry
contracts. Final root-tab event delivery, accessibility, and end-to-end UI status
must still be reported from the final UI artifact; unit geometry tests do not
substitute for that runtime evidence.

## Premium image system

`PremiumImageView` is the shared policy-bearing entry point for image roles and
readability behavior. The underlying loaders include:

- typed display roles, default aspect ratios, overlay policy, and focal-point
  alignment;
- verified local-asset selection, remote candidates, loading placeholders, and
  deterministic fallback content;
- HTTP status and content-type checks;
- target-pixel downsampling before display;
- bounded memory caches, disk thumbnails, and in-flight request coalescing; and
- accessibility labels and stable image frames.

These are source-level capabilities. No current Instruments trace is used here to
claim a measured memory or frame-rate improvement. Media attribution and rights
clearance are tracked separately and remain incomplete.

## Verification infrastructure

The repository includes shared Xcode schemes, unit and UI targets, Swift Testing
and XCTest suites, DataProject validators, and a static-QA aggregate. The checks
cover routing, assistant workflows, data governance, canonical city migration,
map geometry, media registries, accessibility contracts, privacy, and release
rules.

No pass total is stated in this overview. Only the final preserved build logs and
`.xcresult` bundles may define the candidate's current verification status.

## Security and operational boundaries

- No API key is required for the documented local assistant demo.
- No API key or token should be added to the app bundle or repository.
- The optional client is restricted to a bounded scenario and validates its
  configured endpoint and response shape, but no live runtime claim is made.
- Official-source links are content references, not legal, medical, or
  immigration advice.
- Distribution evidence, external repository hosting, and media-rights approval
  remain owner-controlled gates.

## Evidence still required before submission

- Final clean build and test artifacts tied to one commit and working-tree state.
- Final map-to-root-tab UI evidence and the preserved result bundle.
- Final simulator screenshots for the documented demo flow.
- Owner confirmation of media rights and external distribution status.
- Owner confirmation that the wording in this document matches the submitted
  binary and video.

