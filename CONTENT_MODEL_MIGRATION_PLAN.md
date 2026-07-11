# Content model migration plan

Date: 2026-07-11

## Safety invariants

- No source object is deleted during migration.
- Every legacy `KnowledgeItem` must produce exactly one canonical `ContentItem` or an explicit merge record.
- Home, Guide, Search, Map, Saved and AI read canonical IDs from one repository.
- Audience affects ranking only; it never removes an item from Guide or Search.
- Every stage reports migrated, merged, references updated, lost and remaining validation errors.

## Baseline findings

- `KnowledgeIndexBuilder.buildItems()` concatenates more than thirty independent arrays.
- Duplicate IDs are currently hidden by `items.filter { seen.insert($0.id).inserted }`; duplicate evidence is discarded.
- `KnowledgeItem.category` is an unconstrained `String` and mixes topics, UI sections and entity roles.
- `KnowledgeItem.city` and `province` are names/strings rather than canonical references.
- `SavedItemsStore` persists title, subtitle, kind and destination snapshots instead of only canonical IDs.
- `KnowledgeIndex.search` can exclude content through persona scope.
- Sources are embedded repeatedly as `OfficialSource` values and canonical URL identity is not enforced.
- Existing entity families include multiple category enums, place models, city/province representations, search answers and dashboard-specific records.

## Stages

### 1. Canonical schema

Add `ContentItem`, `Category`, `Country`, `Province`, `City`, `Place`, `SourceReference` and `ContentRelation`, plus typed IDs, content/action/status enums and coordinates. Preserve localized content and legacy routing metadata through adapters.

Gate: compile + schema unit tests. Expected loss: 0.

### 2. Repository and validation

Add `ContentRepository` that converts all legacy knowledge records without silently dropping IDs. Add validation for duplicate ID/URL/title/body, unknown category/city, missing source, stale review date, unused content and Guide/Search reachability.

Gate: repository tests and validation report. Expected loss: 0.

### 3. Consumer adapters

- Search indexes `ContentItem` and ranks audience tags without exclusion.
- Map reads only repository items with coordinates and `isMapVisible`.
- Saved persists canonical IDs only and resolves display metadata from repository.
- AI answer context returns canonical IDs and deep links.
- Home and Guide receive canonical references from repository projections.

Gate: focused unit/UI/static tests. Expected loss: 0.

### 4. Data normalization

Replace free-form category/city/source creation in legacy builders with canonical references. Merge exact duplicates through a migration alias table. Keep redirects for old IDs and saved records.

Gate: migrated + merged = baseline source count; unresolved aliases = 0; lost = 0.

### 5. Legacy retirement

Retire legacy arrays only after all call sites use repository references and parity tests cover localized text, routes, sources and Saved migration.

Gate: no orphan object, no unreachable object, no duplicate stored body, lost = 0.

## Stage report format

| Metric | Meaning |
|---|---|
| Objects migrated | Legacy objects represented by canonical items |
| Duplicates merged | Legacy IDs redirected to one canonical ID |
| References updated | Consumer/storage references switched to canonical IDs |
| Items lost | Source objects with neither canonical item nor merge alias |
| Errors remaining | Validator errors after the stage |

