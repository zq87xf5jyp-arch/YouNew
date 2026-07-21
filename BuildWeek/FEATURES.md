# YouNew Features

YouNew is a native SwiftUI iOS guide for practical newcomer life in the
Netherlands. The Build Week candidate concentrates on implemented, demonstrable
features and does not depend on a deployed backend.

## Main Build Week journey

1. Start on Home with the newcomer’s situation, not a feature list.
2. Cut to the already-submitted supported prompt: **“I recently received an
   address in the Netherlands. What should I do first for BSN, DigiD, health
   insurance, and a huisarts?”**
3. Show the ordered BSN → DigiD → health insurance → huisarts route.
4. Open the related BSN guide and a stored Government.nl/Rijksoverheid source
   action.
5. Show Map, Search, Cities, and Categories in a 30-second breadth montage.
6. Close with the creator story: ChatGPT supported product thinking and writing;
   Codex supported engineering, stabilization, and Build Week preparation.

The demonstrated assistant path is a deterministic local fallback, not a live or
generative ChatGPT, OpenAI, or GPT-5.6 response. The OpenAI collaboration story is
separate from the in-app runtime.

## User-facing features

### Structured Home and Guide

- Newcomer-oriented entry points and practical guide navigation.
- Typed destinations that connect content without string-based screen routing.
- Mandatory and situation-dependent guidance presented with appropriate warnings.

### Local guided assistant

- Bounded local workflows for BSN registration, DigiD, health insurance,
  housing, official letters or fines, and “what next” guidance.
- Explicit workflow states and accepted choices for repeatable behavior.
- Indexed search over local YouNew knowledge.
- Structured answer sections, safety notes, next steps, in-app destinations, and
  stored official-source actions.
- Visible local-guide origin and no provider credential required for the
  documented demo.

### Search, Saved, and practical organization

- Search across indexed YouNew knowledge.
- Saved items for returning to useful content.
- Checklists that support practical newcomer tasks.
- Local discovery and place-oriented surfaces.

### Interactive Netherlands map

- Custom SwiftUI geometry for all twelve Dutch provinces.
- Province labels and selection, city markers, landmarks, zoom, and pan.
- Path-based hit testing with deterministic geometry contracts.
- Typed navigation from map selections into app content.

### Governed city discovery

The versioned `cities-v0.1.0` release includes five canonical city records:

- Amsterdam
- Rotterdam
- Den Haag
- Utrecht
- Eindhoven

These records flow through the governed content platform into runtime app
consumers. Content depth is not equal across all five cities.

### Shared premium image system

- Role-aware image sizing, aspect ratios, overlay policy, and focal points.
- Local and remote candidates with loading and deterministic fallback states.
- Target-pixel downsampling, bounded memory caches, disk thumbnails, and
  in-flight request coalescing.
- HTTP response validation and accessibility labels.

## Product foundations

### Typed navigation

`AppDestination` and the application router connect guides, assistant actions,
map content, search results, and other app surfaces through stable destination
types.

### Governed content delivery

- Versioned schemas, work packages, records, and release definitions.
- Stable identifiers, lifecycle and verification state, source metadata, and
  migrations.
- Deterministic validation and import into a bundled runtime payload.
- Shared `ContentRepository` and `KnowledgeIndex` projections for app consumers.

The checked-in runtime payload contains 188 canonical entities, two included
releases, and 15 migration mappings. These are repository inventory facts, not a
claim that every content category is complete.

### Verification infrastructure

- Shared build, unit, and UI test schemes.
- Static checks covering routing, accessibility, content, privacy, media, data,
  imports, and release rules.
- Focused contracts for local assistant workflows, map geometry, canonical city
  data, and corrupt runtime-dataset rejection.

Current candidate results and their evidence boundaries are reported separately;
this feature list does not claim that every aggregate gate is green.

## Explicit candidate boundaries

- The demonstrated assistant is local and deterministic.
- No deployed backend or verified live GPT-5.6/OpenAI response is claimed.
- The product is independent from government and does not provide legal, medical,
  immigration, financial, or tax advice.
- Content coverage is broad but uneven, and official procedures can change.
- The latest documented network-health report includes 18 confirmed broken URLs
  in the wider shipped dataset; stored source actions are not a universal link-
  health guarantee.
- Media-rights review and public distribution remain owner-controlled gates.
- The candidate is designed for a strong Build Week demonstration, not presented
  as production-ready or App Store-ready.

Technical details: [Build Week technical overview](../BuildWeekSubmission/TECHNICAL_OVERVIEW.md).
