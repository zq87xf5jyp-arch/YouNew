# Content model migration report

Date: 2026-07-11

## Result

The application now has a canonical `ContentItem` domain, typed category/geography/source/relation models, a single `ContentRepository`, lossless legacy adapters, repository validation, canonical search, ID-only Saved persistence and AI canonical references.

Legacy arrays remain as migration inputs. They were not deleted because retirement is allowed only after all view-specific rendering has parity tests.

## Metrics

| Stage | Objects migrated | Duplicates merged | References updated | Items lost | Errors remaining | Warnings remaining |
|---|---:|---:|---:|---:|---:|---:|
| Plan | 0 | 0 | 0 | 0 | 1 legacy persona policy gate | not measured |
| Canonical schema | 0 | 0 | 0 | 0 | 0 compile errors | 0 schema warnings |
| Repository and validation | 1,200 source objects discovered | 870 repeated source URL references deduplicated | 0 | 0 | 0 | 504 |
| Exact-content merge and consumers | 1,146 canonical objects | 54 exact content objects + 870 source references | 6 consumer contracts | 0 | 0 | 406 |

The 406 warnings are evidence requiring editorial review: normalized title/body collisions and stale verification dates. They are not silently deleted or automatically merged because identical short labels can represent different geography or action semantics. Structural validation errors are zero.

## Consumer contract

- Home: `ContentRepository.homeReferences` returns canonical IDs; audience changes order only.
- Guide: `ContentRepository.guideItems` returns every published item and optional category projection.
- Search: `AppSearchEngine.searchContent` indexes `ContentItem`; legacy result shape is now an adapter.
- Map: `ContentRepository.mapItems` returns only published, map-visible items with valid coordinates.
- Saved: persisted payload contains only `id` and `savedAt`; legacy snapshots are read once and rewritten canonically.
- AI: `answerContentContext` returns canonical IDs, deep links and a repository-backed summary.

## Automatic validation

Implemented checks:

- duplicate ID;
- duplicate canonical URL;
- duplicate normalized title;
- identical normalized body in different objects;
- unknown category;
- unknown city;
- missing source for official/emergency content;
- stale verification date;
- unused object;
- published object unreachable through Guide/Search;
- invalid coordinates on map-visible objects.

## Commits

- `52556e5a` — migration plan.
- `c3f5419f` — canonical domain models.
- `c499eb45` — repository and validation.
- `86743097` — Search, Saved and AI consumer adapters plus exact duplicate aliases.

## Remaining migration boundary

Some SwiftUI view files already had unrelated uncommitted user changes before this work. They were not folded into migration commits. Home and Guide can consume the new repository projections now, while their legacy presentation arrays remain available until a separate, parity-tested view migration removes those storage responsibilities.
