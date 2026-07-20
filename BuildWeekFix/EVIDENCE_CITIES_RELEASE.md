# Evidence packet — `cities-v0.1.0`

Status: **VERIFIED local release metadata and unit coverage / PARTIAL end-to-end proof**

Evidence date: 2026-07-20 (Europe/Amsterdam)

## Original problem

Priority-city content needed a governed release that replaced legacy city records without duplicates and remained addressable across Search, AI context, Home, Places, Map, and typed routes.

## Product requirement

Release Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven through explicit lifecycle and QA gates, preserving canonical IDs, official-source metadata, coordinates, media, summaries, and safe corrupt-data fallback.

## Implementation

- `cities-v0.1.0` is marked `published` and contains five governed city records.
- The batch and migration registry map the five legacy city IDs to canonical IDs.
- The runtime loader projects the release into the bundled payload; repository and index consumers resolve only the canonical records.
- A corrupt dataset is rejected rather than silently merged.

## Files

- `DataProject/reports/release-manifests/cities-v0.1.0.json`
- `DataProject/releases/releases.json`
- `DataProject/batches/WP-06/M1-priority-cities-001.json`
- `DataProject/reports/import-preview.json`
- `DataProject/observability/migration-registry.json`
- `YouNew/Resources/Data/younew-runtime-data.json`
- `YouNewTests/PublishedCitiesDataReleaseTests.swift`

## Tests

- `publishedReleaseReplacesMappedLegacyCitiesWithoutDuplicates`
- `publishedCitiesFeedSearchAIHomePlacesAndMapData`
- `runtimeLoaderRejectsCorruptedDataset`
- All are included in the last closed complete Stage 2 unit result of **450/450**.
  Additional Build Week tests were added afterward, so the expanded complete unit
  rerun remains pending.
- The static/import gates are included in the last closed **40/40** aggregate static
  result. The final aggregate rerun and complete post-fix UI rerun are still pending
  and are not reported as passed here.

## Measurable result

The current manifest contains five records and seven marked QA gates. The current import preview selects one release, accepts five records, excludes zero, removes zero technical duplicates, and reports zero broken relations. These are deterministic structural results, not live-link or equal-depth city-content proof.

## Owner decision

The owner must confirm the five-city public scope, reconcile any stale milestone wording with the published release state, and approve a judge narrative that explicitly distinguishes a published city identity record from deep city-specific content coverage.

## Limitations

- Amsterdam has deeper governed content than the other four priority cities.
- Full Search → detail → Saved and complete five-city UI coverage are not yet backed by a closed post-fix full UI result.
- Current release artifacts are local/untracked until repository curation and clean-clone proof complete.
- An approval marker in metadata is not independent proof of the approver's identity or decision history.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

The local working tree contains a governed five-city `cities-v0.1.0` release for Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven, with deterministic checks for canonical migration, duplicates, relations, and corrupt-data fallback. Equal content depth and full end-to-end UI coverage are not claimed.

## Screenshot or log still needed

Capture the five cities in the final app, plus one uncut canonical route from Search or Map to a city detail and Saved state. Attach the closed post-fix city UI-test summary and clean-clone import output; redact fingerprints and internal approval metadata.
