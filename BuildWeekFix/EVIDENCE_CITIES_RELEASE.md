# Evidence packet — `cities-v0.1.0`

Status: **VERIFIED clean-clone release metadata and unit coverage / PARTIAL end-to-end proof**

Evidence date: 2026-07-21 (Europe/Amsterdam)

## 2026-07-21 evidence boundary update

The earlier `61e7ce11` UI references are historical only. The last fully closed
clean-clone UI snapshot is `efd1a7c5`, **84/87 RED**; `da8c3fe2` requires a fresh
complete serial result. Separately, current network Data Health evidence finds 18
broken URLs in shipped runtime data, so release metadata/import success is not a
claim that all published external links are currently healthy.

## Original problem

Priority-city content needed a governed release that replaced legacy city records without duplicates and remained addressable across Search, AI context, Home, Places, Map, and typed routes.

## Product requirement

Release Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven through explicit lifecycle and QA gates, preserving canonical IDs, official-source metadata, coordinates, media, summaries, and safe corrupt-data fallback.

## Implementation

- `cities-v0.1.0` is marked `published` and contains five governed city records.
- The batch and migration registry map the five legacy city IDs to canonical IDs.
- The runtime loader projects the release into the bundled payload; repository and index consumers resolve only the canonical records.
- A corrupt dataset is rejected rather than silently merged.

## Versioned implementation files

- `DataProject/releases/releases.json`
- `DataProject/batches/WP-06/M1-priority-cities-001.json`
- `DataProject/observability/migration-registry.json`
- `YouNew/Resources/Data/younew-runtime-data.json`
- `YouNewTests/PublishedCitiesDataReleaseTests.swift`

Generated, ignored evidence recreated by the documented clean-clone pipeline:

- `DataProject/reports/release-manifests/cities-v0.1.0.json`
- `DataProject/reports/import-preview.json`

These two reports are not shipped as versioned inputs and are not implied to exist
before the generator/import commands run.

## Tests

- `publishedReleaseReplacesMappedLegacyCitiesWithoutDuplicates`
- `publishedCitiesFeedSearchAIHomePlacesAndMapData`
- `runtimeLoaderRejectsCorruptedDataset`
- All are included in the authoritative clean-clone unit result of **460/460**.
- The static/import gates are included in the authoritative report-free clean-clone
  aggregate result of **40/40**.
- The published-place test now also proves the exact
  `article:data-project:museum.rijksmuseum` string route round-trips to the canonical
  published destination.

## Measurable result

The clean-clone-generated manifest contains five records and seven marked QA gates.
The generated import preview selects one release, accepts five records, excludes
zero, removes zero technical duplicates, and reports zero broken relations. These
are deterministic structural results, not live-link or equal-depth city-content proof.

## Owner decision

The owner must confirm the five-city public scope, reconcile any stale milestone wording with the published release state, and approve a judge narrative that explicitly distinguishes a published city identity record from deep city-specific content coverage.

## Limitations

- Amsterdam has deeper governed content than the other four priority cities.
- Full Search → detail → Saved and complete five-city UI coverage are not promoted
  to a release-wide UI PASS: the historical `61e7ce11` serial suite is 82/87, the
  later closed `efd1a7c5` snapshot is 84/87 RED, and current code requires its own
  complete aggregate.
- Release manifests and import previews are intentionally ignored generated
  evidence; clean-clone regeneration, not committing those outputs, is the
  portability contract.
- An approval marker in metadata is not independent proof of the approver's identity or decision history.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

The curated repository contains a governed five-city `cities-v0.1.0` release for
Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven, with clean-clone
deterministic checks for canonical migration, duplicates, relations, string-route
restoration, and corrupt-data fallback. Equal content depth is not claimed.

## Screenshot or log still needed

Capture the five cities in the final app, plus one uncut canonical route from Search or Map to a city detail and Saved state. Attach the closed post-fix city UI-test summary and clean-clone import output; redact fingerprints and internal approval metadata.
