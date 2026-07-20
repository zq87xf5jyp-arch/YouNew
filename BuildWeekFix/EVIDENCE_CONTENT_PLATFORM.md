# Evidence packet — Governed content platform

Status: **VERIFIED in the local working tree / PARTIAL repository portability**

Evidence date: 2026-07-20 (Europe/Amsterdam)

## Original problem

Bundled newcomer information needed stable identifiers, publication state, source metadata, deduplication, migrations, and predictable delivery to Search, Guide, AI, Saved, Home, and Map consumers.

## Product requirement

Maintain one governed data workflow with schema validation, explicit release approval, deterministic imports, relation and duplicate checks, runtime fallback, and measurable health without automatic publication.

## Implementation

- `DataProject/` defines schemas, 17 work packages, seven tracked releases, 27 batch files, release manifests, source/freshness policy, migrations, and generated reports.
- The import tool applies eligibility, lifecycle, duplicate, relation, migration, and approval gates before producing a deterministic runtime payload.
- `DataProjectRuntimeLoader`, `ContentRepository`, and `KnowledgeIndex` load and project the bundled data into app consumers while rejecting corrupt input.
- Stage 2 strengthened `local_partner` governance so plan, verification, and sponsorship metadata cannot silently disappear.

## Files

- `DataProject/README.md`
- `DataProject/schema/entity.schema.json`
- `DataProject/work-packages.json`
- `DataProject/releases/releases.json`
- `DataProject/observability/migration-registry.json`
- `scripts/import-data-project.py`
- `YouNew/Resources/Data/younew-runtime-data.json`
- `YouNew/Services/DataProjectRuntimeLoader.swift`
- `YouNew/Services/ContentRepository.swift`
- `YouNew/Services/KnowledgeIndex.swift`

## Tests

- `YouNewTests/DataProjectRuntimeBaselineTests.swift`
- `YouNewTests/ContentRepositoryTests.swift`
- `YouNewTests/KnowledgeDataGovernanceTests.swift`
- `YouNewTests/KnowledgeIndexTests.swift`
- DataProject QA, import validation, dashboard, observability, and health checks under `scripts/`
- Last closed complete Stage 2 evidence: **450/450 unit tests passed**, **40/40
  static-QA commands passed**, and DataProject import validation passed after runtime
  regeneration. Additional Build Week AI/demo checks were added later, so expanded
  final-snapshot aggregate reruns remain pending.

## Measurable result

The current generated dashboard reports 450 governed records, 188 published records, 27 batches, 587 media references, and zero structural health issues. The runtime payload contains 188 entities and seven release entries. These are local generated-state measurements, not yet clean-clone proof or a claim that every record is complete.

## Owner decision

The owner must approve which QA/planned releases may become public, assign editorial responsibility for freshness and source review, and decide how the currently unmeasured consumer-usage registry will be populated without auto-publishing content.

## Limitations

- At packet preparation time, `DataProject/` and the runtime payload are essential untracked files; public portability is not proven until the curated commit and clean-clone audit complete.
- Deep governed content is uneven by city and domain; the repository must not claim complete coverage across all 34 categories.
- The current observability report records 188 published records but zero measured consumer-use events, so source-level consumer bridges are not the same as usage telemetry.
- Stored URL health is not a fresh semantic review of every external source.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

The local working tree contains a schema-governed content/import pipeline with explicit release gates, deterministic runtime generation, migrations, and structural health checks. Breadth, editorial completeness, usage telemetry, and clean-clone portability remain bounded limitations.

## Screenshot or log still needed

Attach a redacted final import/health transcript, the clean-clone regeneration result, and one final-build walkthrough showing the same canonical record in at least two consumers. A compact dashboard screenshot may show aggregate counts but must not expose internal fingerprints or approver identifiers.
