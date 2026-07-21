# Technical Overview

## Product snapshot

YouNew is a native SwiftUI iOS application for people settling in the
Netherlands. The Build Week candidate uses the functionality already present in
the repository and deliberately avoids a new architecture or last-minute feature
expansion.

| Item | Candidate fact |
|---|---|
| Platform | iOS, Swift 5, SwiftUI |
| Bundle identifier | `nl.younew.app` |
| Version | 1.1 (5) |
| Minimum iOS version | 17.6 |
| Primary mode | Local-first, bundled content and deterministic workflows |
| Candidate AI description | Local guided assistant; no verified live OpenAI inference |

## Architecture

```text
SwiftUI screens
    ↓
RootTabView + typed AppDestination routes
    ↓
Feature view models and services
    ↓
ContentRepository / KnowledgeIndex / workflow engines
    ↓
Bundled Swift content + governed runtime JSON
```

The app uses a pragmatic SwiftUI architecture. Shared state is injected through
the environment, root navigation is owned centrally, and destinations are typed
instead of being assembled from arbitrary strings. Feature services and
repositories keep content lookup, routing, persistence, media loading, and
assistant behavior outside the view hierarchy where practical.

## Local guided assistant

The Build Week demo uses the existing local path:

1. `AIWorkflowEngine` selects a bounded workflow and explicit state.
2. The workflow asks only the follow-up questions needed for that path.
3. `KnowledgeIndex` and `ContentRepository` provide indexed YouNew material.
4. `AIResponseComposer` assembles sections, warnings, next steps, in-app routes,
   and stored official-source actions.
5. The interface identifies the result as local guide mode.

The BSN demo covers the address prerequisite and a DigiD follow-up. It requires
no API key, network provider, or deployed backend. Optional backend example code
exists in the repository, but it is not part of the candidate capability claim
and is not evidence of a live model request.

## Navigation and map

`RootTabView` owns the main Home, Guide, Map, and supporting navigation state.
The final targeted navigation change keeps the bottom safe-area reservation while
placing the interactive tab bar in the frontmost root overlay. Existing evidence
records 10/10 first-tap Map ↔ Home transitions in the targeted scenario.

The Netherlands map is implemented in SwiftUI rather than as a static image. It
contains province geometry, labels, selection state, city markers, zoom and pan,
and typed routes into province and city content. The governed
`cities-v0.1.0` release supplies Amsterdam, Rotterdam, Den Haag, Utrecht, and
Eindhoven for the candidate flow.

## Content platform

Content comes from two established sources:

- bundled Swift records used by existing feature screens; and
- governed JSON records produced through `DataProject/` schemas, batches,
  releases, validation, and deterministic import tooling.

The product favors explicit source actions and last-verified context. Structural
validation does not guarantee that every external website remains reachable; the
known link-health boundary is documented in
[KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md).

## Premium image system

The existing image layer remains unchanged in architecture. It supports
role-aware presentation, local and remote candidates, deterministic fallbacks,
downsampling, bounded caching, in-flight request coalescing, focal-point policy,
and accessibility labels. Media provenance and redistribution clearance are a
separate publication concern, not a claim implied by the implementation.

## Local data and privacy boundary

The documented demo does not need an OpenAI credential or a backend. User-facing
state such as saved items and guided progress is handled by existing app storage
and local services. Demonstrations should use synthetic questions and must not
include real identifiers, addresses, health information, credentials, or account
data.

## Repository map

| Path | Responsibility |
|---|---|
| `YouNew/` | iOS application source, resources, content, and UI |
| `YouNewTests/` | unit and local integration coverage |
| `YouNewUITests/` | runtime navigation and demo contracts |
| `DataProject/` | governed content source and import model |
| `scripts/` | static, data, media, and release checks |
| `BackendExamples/` | optional backend reference; outside the candidate claim |
| `BuildWeek/` | final judge- and owner-facing package |
| `BuildWeekFinal/` | preserved targeted remediation evidence |
| `BuildWeekSubmission/` | detailed evidence packet retained for traceability |

## Preserved evidence boundary

No new runtime verification was performed while assembling this package. The
final status uses already preserved evidence:

- candidate build recorded as PASS in `BuildWeekSubmission/FINAL_STATUS.json`;
- 460/460 unit result from the bounded prior candidate artifact;
- targeted map/root navigation result of 3/3 with 10/10 first-tap transitions;
- targeted Guide loading-state and search-focus fixes;
- structural content/import validation for the five-city release; and
- a bounded secret scan with no confirmed high-confidence credential.

These results support a Build Week demonstration candidate. They do not establish
App Store production readiness, all-device certification, complete content,
blanket media rights, or live-model operation.
