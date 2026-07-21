# Evidence packet — Governed content platform

Status: **VERIFIED on curated clean-clone source / PARTIAL editorial completeness**

Evidence date: 2026-07-21 (Europe/Amsterdam)

## 2026-07-21 evidence boundary update

Offline clean-clone structural/import checks remain useful reproducibility evidence,
but a separately captured current network-health report contains 18 confirmed
broken URLs in tracked shipped runtime data. Those URLs affect 30 published
entities and 85 field occurrences. This packet therefore does not claim current
external-source health or publication readiness until a reviewed release remediation
and fresh network verification pass.

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
- Authoritative clean-clone evidence: **460/460 unit tests passed**, **40/40
  static-QA commands passed**, and DataProject import validation passed after
  release-manifest generation from an initially report-free clone.

## Measurable result

The clean-clone-generated dashboard reports 450 governed records, 188 published
records, 27 batches, 587 media references, and zero structural health issues. The
versioned runtime payload contains 188 entities and seven release entries. The
observability output reports 0.0% measured usage coverage and does not establish
migration progress. These are structural measurements, not a claim that every
record is editorially complete or observed in production use.

## Owner decision

The owner must approve which QA/planned releases may become public, assign editorial responsibility for freshness and source review, and decide how the currently unmeasured consumer-usage registry will be populated without auto-publishing content.

## Limitations

- `DataProject/reports/` remains intentionally ignored; consumers must run the
  documented generator before importer validation. The aggregate and CI order now
  enforce that dependency.
- Deep governed content is uneven by city and domain; the repository must not claim complete coverage across all 34 categories.
- The current observability report records 188 published records but zero measured consumer-use events, so source-level consumer bridges are not the same as usage telemetry.
- Stored URL health is not a fresh semantic review of every external source.

## Safe public claim

The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

The curated repository contains a schema-governed content/import pipeline with
explicit release gates, deterministic runtime generation, migrations, and
clean-clone structural health checks. Breadth, editorial completeness, and usage
telemetry remain bounded limitations.

## Screenshot or log still needed

Attach a redacted final import/health transcript, the clean-clone regeneration result, and one final-build walkthrough showing the same canonical record in at least two consumers. A compact dashboard screenshot may show aggregate counts but must not expose internal fingerprints or approver identifiers.
