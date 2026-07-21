# Priority backlog

## Phase 0 — evidence and launch stability

- P0: capture startup console and fix black launch screen; owner iOS; acceptance cold-launch p95 <2 s.
- P0: add content reachability test proving no audience hides public content.
- P1: establish baseline counts: canonical items, searchable items, duplicates, orphan screens.

## Phase 1 — canonical content model

- Introduce `CanonicalContentItem` with stable ID, localized title/body, category, secondary categories, content type, geography, audience tags, sources and review date.
- Build adapters from current GuideContent/Mock*Data without deleting material.
- Make Search and AI consume the same repository.

## Phase 2 — navigation consolidation

- Replace AppTab/TabItem duality with Home, Guide, Map, Saved, More.
- Split PlacesDiscoveryView into Guide browse and Map discovery.
- Remove the full duplicate catalog from RightSideMenuOverlay.
- Move useful content out of More; leave profile/settings/legal/support.

## Phase 3 — Home reduction

- Keep next step, status, current city, emergency, search and a small recommended set.
- Convert all other Home modules to references into Guide/Map.
- Enforce Home section budget and priority rules in tests.

## Phase 4 — content deduplication and migration

- Resolve every group in `03_duplicate_content.csv`.
- Merge legacy/orphan screens only after content parity checks.
- Add redirects for old AppDestination values and saved item IDs.

## Phase 5 — trust, localization, accessibility

- Require official source and review date for sensitive facts.
- Move inline multilingual strings to structured localization.
- Run VoiceOver, Dynamic Type accessibility sizes, contrast and reduced-motion matrix.

## Phase 6 — regression proof

- Full UI tests on iPhone SE, iPhone 15, iPhone 17 Pro; light/dark; EN/NL/RU.
- Offline tests for Home, Guide, Map, Search and AI.
- Search coverage 100%, duplicate bodies 0, orphan destinations 0.

