# YouNew Data Project

Data Project is the data-development stream inside YouNew. It is not a separate app and it does not introduce screens, tabs, buttons, menus, or SwiftUI restructuring.

## Mission

Build the most complete, structured, verified, connected, and maintainable knowledge base about life in the Netherlands. New records are prepared in small JSON batches, pass the publication gates, and are then projected into the existing `NetherlandsKnowledgeDatabase`, `KnowledgeIndex`, Search, and AI context.

## Source of truth

- `schema/entity.schema.json` defines the canonical editorial record.
- `work-packages.json` defines ownership, independence, and QA state for WP-01 through WP-17.
- `milestones/<wp-id>/` defines bounded delivery milestones owned by a work package.
- `releases/releases.json` identifies the exact dataset version published to users.
- `coverage-targets.json` defines long-term numerical coverage goals.
- `coverage-dimensions.json` defines required topic families and province breadth independently from record volume.
- `reports/` contains generated Data Dashboard, Coverage, Quality Score, and Data Health artifacts. The consolidated stakeholder report is available at `reports/general-work-report/report.html` with its validated source artifact and reproducibility notes.
- `batches/<wp-id>/` contains reviewable data batches. One file belongs to exactly one work package, milestone, and target release.
- Existing Swift data remains the runtime source until a reviewed batch is explicitly imported. Draft files are never user-visible.

## Publication gates

Every record must pass, in this order:

1. Build — the app compiles and the data decodes.
2. Static QA — required fields, types, IDs, dates, and lifecycle state are valid.
3. Duplicate QA — IDs, canonical names, websites, coordinates, and primary media are not duplicated.
4. Source QA — an exact HTTPS source page is opened, attributed, and date-stamped.
5. Media QA — every supplied asset has reusable rights metadata; visual entities require a verified hero, gallery, thumbnail, and map preview before publication. Government, document and knowledge records may have an empty `images` collection.
6. Search QA — title, aliases, and keywords make the record discoverable without collisions.
7. AI QA — summaries are grounded in sources, contain no unsupported certainty, and link to related entities.

`verification_status: verified` means the exact source was checked. A search-result page, social post, aggregator, or generated text is not a source.

## Working in small batches

Copy `templates/batch.template.json` into `batches/<wp-id>/MN-<slug>-NNN.json`, populate it, and keep `publication_status` as `draft`. Move it to `qa` only after editorial review, then to `published` only when every gate is `passed` and the batch is assigned to a semantic Data Release.

The operating sequence is:

`Work Package -> Milestone -> QA -> Data Release -> Published`

Data Release versions are scoped to a dataset. New records use a minor release, corrections use a patch release, and incompatible schema or meaning changes use a major release. A published release is immutable.

Run the Data Project checks with:

```sh
python3 scripts/data-project-qa.py
python3 scripts/generate-data-dashboard.py
```

For a completed work package, also run the existing app checks and tests:

```sh
scripts/run-static-qa.sh
xcodebuild test -project YouNew.xcodeproj -scheme YouNew -destination 'platform=iOS Simulator,name=<booted simulator>'
```

## Runtime mapping

| Editorial field | Existing runtime field |
| --- | --- |
| `entity_type` | `NetherlandsKnowledgeEntity.kind` |
| `description` | `summary` |
| `city_id` / `province_id` | `cityId` / `provinceId` |
| `coordinates` | `coordinate` |
| `official_source` | `source` |
| `images` | `NetherlandsVisualSet` |
| `related_entity_ids` | `relatedEntityIDs` / `KnowledgeRelation` |
| `ai_summary` | `aiSummary` |
| `search_keywords` | `keywords` |

The importer must preserve stable IDs. Renaming a title must never silently create a new entity.

## Measurement

Coverage counts all governed DATA PROJECT records so QA progress is visible before publication. The dashboard reports `Published` separately, so reviewed coverage is never confused with the version currently shipped to users. Existing runtime Swift data is explicitly marked `legacy-runtime-unversioned` until it is audited and migrated; it is never silently presented as verified DATA PROJECT coverage.

Coverage has two layers. Volume coverage compares governed records with the numerical target for each domain. Coverage dimensions then measure how completely each work package is verified, backed by an official source, current, connected to related entities, geographically complete where applicable, media-ready where applicable, searchable, AI-ready, and published. A missing domain is reported as not applicable rather than receiving an invented percentage.

Breadth coverage is deliberately stricter than volume. Government and Housing are measured against fixed sets of topic families, while geographic datasets are measured against representation of all 12 Dutch provinces. Required values and aliases live in `coverage-dimensions.json`; adding many records to one already-covered topic or province does not improve breadth.

Depth coverage prevents a single record from making a topic look complete. Each axis can define `minimum_records_per_value`; the dashboard caps credit at that minimum for every required value and lists underfilled topics or provinces separately. Government uses a floor of five governed records per topic family. Housing Core uses a floor of ten records for each of four families: renting, home buying, tenant rights and utilities. Healthcare Core also uses a floor of ten records for each of four families: GP and primary care, health insurance, hospitals and specialist care, and emergency and urgent care. Transport Core uses a floor of ten records for each of four families: NS and rail travel, OV-chipkaart and OVpay, cycling and bicycle services, and car parking. Education Core uses a floor of ten records for each of four families: schools and compulsory education, universities and higher education, DUO and student administration, and civic integration. Breadth and depth therefore remain separate claims.

Quality Score is calculated per work package from completeness, verification, official sources, media, geography, search metadata, and AI grounding. The exact weights are defined in `QUALITY_SCORE.md`. A package with no governed records has a score of 0, not an inferred score from legacy content.

Data Health reports broken links, expired events, missing media, duplicates, unverified sources, missing review dates, missing coordinates, and missing AI summaries. Offline structural checks run on every static QA. A clean clone uses an explicit epoch/zero-count sentinel when no generated network snapshot exists; this means “network not run”, not “all links verified”. The `--require-network` gate rejects that sentinel. Network source checks run nightly and replace it with fresh evidence before dashboard generation.

The scheduled GitHub workflow runs every night at 02:17 UTC, regenerates the dashboard from fresh network evidence, runs `python3 scripts/data-health-gate.py --require-network`, and uploads the dashboard, link evidence, and health report as build artifacts retained for 30 days. Critical health issues fail the job; access restrictions and transient network failures remain visible evidence without being misclassified as broken links. It never auto-publishes a batch or changes a release version.

## Data Observability

WP-16 is a read-only measurement layer. It observes governed data, release metadata, source health and exact stable-ID references in registered consumers, but it never changes entity content, verification state, lifecycle state, publication state or release versions.

The generated observability reports separate five KPIs:

- Data Usage Coverage measures the share of published governed records used by at least one registered consumer.
- Orphan Data Ratio measures published governed records with no consumer evidence.
- Migration Progress uses only explicit legacy-to-canonical mappings and remains not established until the legacy baseline is counted.
- Freshness Compliance applies a category-specific SLA and recommends needs_review after expiry without mutating the record.
- Source Trust Score combines officiality, validity, freshness and stability. Access restrictions and transient network failures remain visible but do not automatically reduce trust.

Consumer definitions live in observability/consumer-registry.json. Migration state, freshness SLA, source reliability policy and the release manifest schema live beside it. scripts/generate-data-observability.py writes only to DataProject/reports/, fingerprints its inputs before and after generation, and fails if an input changes.

## Data Operations

WP-17 manages operational decisions without becoming another source of truth. It converts Data Health and Data Observability evidence into a plan-only editorial queue, update schedule, link/source/media monitor summaries, release candidates, Data KPIs and separate capability/data-state maturity assessments.

The operating mode is `detect -> classify -> queue -> approve -> execute`. Detection, classification, prioritisation, local queue generation and reporting are automatic. Changing canonical records, verification or lifecycle state, archiving events, replacing sources or media, publishing or rolling back a release, and creating an external issue always require explicit approval. Published releases remain immutable; an approved rollback is represented by a new patch release.

The policies and registries live in `operations/`. `scripts/generate-data-operations.py` writes only generated evidence to `reports/`, verifies that its inputs did not change, and never creates GitHub issues or publishes data. `reports/operations.md` is the editorial summary; the action queue, scheduler, source/media monitors, release manager, analytics, KPI and maturity reports remain machine-readable JSON artifacts.

Usage analytics is not inferred from search indexing or configuration. It remains `not_established` until privacy-safe aggregate telemetry is deliberately enabled and populated. Source-change detection likewise remains `not_established` until a reviewed baseline exists. Unknown evidence is reported as unknown rather than as a passing score.

## Domain ownership

The 17 databases are covered by 15 domain work packages, plus the cross-cutting WP-16 Data Observability & Release Layer and WP-17 Data Operations. Places are owned by WP-06 Cities; Documents are curated in their subject package and governed by WP-01; the shared graph is WP-15. Cross-package relations are allowed, but a package may publish independently only when its outbound IDs resolve to an existing runtime entity or another Data Project record.
