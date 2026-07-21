# Acceptance criteria

## Navigation

- Exactly five primary destinations appear in this order: Home, Guide, Map, Saved, More.
- The order and count do not change across compact layouts; regular layout may change orientation only.
- Search is reachable in one action from Home and Guide.
- AI is reachable contextually and does not own a separate content corpus.

## Content preservation

- Every row in the pre-migration inventory maps to a canonical ID or an explicit non-content utility.
- No useful item is deleted until automated parity verifies title, body, links and locale variants.
- All public items are reachable via Guide, Search, Map or a documented contextual link.
- Audience tags never make a public item inaccessible.

## Taxonomy and data

- Every content item has exactly one primary category from the agreed eight.
- Geography uses Country/Province/City/Place fields, never category names.
- Every item has one allowed content type.
- Stable IDs survive navigation refactors and Saved migrations.

## Duplicates

- Exact duplicate bodies: 0, excluding translations and attributed quotations.
- Every semantic duplicate group has one canonical item.
- Cards outside the canonical screen store a reference, not copied text.

## Search, Map and AI

- 100% of public canonical IDs appear in the search index.
- Search returns one canonical result per entity and supports localized aliases.
- Map renders only geographic entities/services and links to canonical guide content.
- AI answers include canonical deep links; high-risk answers include official source and review date.

## UI and accessibility

- No content is obscured by status bar or floating tab bar on supported devices.
- No truncation at accessibility Dynamic Type sizes; layouts reflow or scroll.
- All actionable elements have VoiceOver labels, roles and logical focus order.
- Text and controls meet WCAG AA contrast; Reduce Motion/Transparency are respected.

## Reliability

- Cold launch reaches usable UI in <2 s p95 on reference device; no black screen >3 s.
- Home, Guide, Map, Search, Saved and AI have explicit loading, empty, offline and error states.
- No endless spinner: every network operation has timeout, retry/cancel and recovery action.

## Release gate

- Static QA passes, including persona IA.
- Unit/UI tests pass on iPhone SE, iPhone 15 and iPhone 17 Pro in EN/NL/RU and light/dark modes.
- Zero P0/P1 open issues; all P2 issues have accepted owners and regression tests.
