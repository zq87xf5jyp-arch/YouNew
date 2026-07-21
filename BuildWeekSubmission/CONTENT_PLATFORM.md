# Governed Content and Import Platform

Evidence cutoff: 21 July 2026  
Document status: current structural evidence with network-health limitation

## Purpose

YouNew ships practical newcomer content inside the application. `DataProject/`
provides a governed path from authoring records to a deterministic runtime
payload so app features do not depend on unrelated hard-coded copies or silently
publish incomplete records.

The platform is designed around stable identifiers, lifecycle state, source and
freshness metadata, migrations, duplicate and relation checks, explicit releases,
and reproducible imports.

## Data flow

```text
schemas + work packages + batch records
                 |
                 v
     validation and release gates
                 |
                 v
      deterministic import preview
                 |
                 v
 bundled production runtime payload
                 |
                 v
 loader -> repository/index -> app consumers
```

The core implementation is:

- [DataProject/README.md](../DataProject/README.md) — authoring, validation,
  release, and import contract.
- [entity.schema.json](../DataProject/schema/entity.schema.json) — governed
  entity shape.
- [work-packages.json](../DataProject/work-packages.json) — versioned work scope.
- [releases.json](../DataProject/releases/releases.json) — explicit release
  lifecycle and QA metadata.
- [migration-registry.json](../DataProject/observability/migration-registry.json)
  — legacy-to-canonical identifiers.
- [import-data-project.py](../scripts/import-data-project.py) — eligibility,
  publication, duplicate, relation, migration, and output checks.
- [younew-runtime-data.json](../YouNew/Resources/Data/younew-runtime-data.json) —
  bundled deterministic production payload.
- [DataProjectRuntimeLoader.swift](../YouNew/Services/DataProjectRuntimeLoader.swift)
  — runtime decoding and validation boundary.
- [ContentRepository.swift](../YouNew/Services/ContentRepository.swift) and
  [KnowledgeIndex.swift](../YouNew/Services/KnowledgeIndex.swift) — canonical
  app-facing projections.

## Current versioned inventory

| Item | Current repository fact | Meaning |
|---|---:|---|
| Work packages | 17 | Versioned content-production scopes. |
| Batch JSON files | 27 | Governed authoring batches currently present. |
| Release definitions | 7 | Two marked `published`, four `qa`, one `planned`. |
| Bundled runtime schema | 1 | Runtime payload schema version. |
| Bundled runtime mode | `production` | Import mode encoded in the payload; not App Store status. |
| Bundled runtime entities | 188 | Canonical entities in the checked-in runtime JSON. |
| Bundled runtime releases | 2 | Published releases selected into the runtime payload. |
| Bundled migration mappings | 15 | Legacy identifiers mapped in the runtime payload. |

These are repository inventory counts, not test-result totals and not a claim of
complete editorial coverage.

## Release gates

The import preview records a policy requiring:

- all seven QA gates;
- a `published` release state for production selection;
- a `published` record lifecycle state; and
- a `verified` record verification state.

The importer also evaluates canonical migration, technical duplicates, broken
relations, excluded records, and production-blocked releases. This prevents a
record from becoming part of the production payload solely because a JSON file
exists.

Release metadata remains an internal governance decision. It must not be confused
with an external deployment, App Store release, or independent verification of
the named approver.

## `cities-v0.1.0`

The governed five-city release is marked `published` in the release registry and
contains:

| City | Canonical ID |
|---|---|
| Amsterdam | `city.amsterdam` |
| Rotterdam | `city.rotterdam` |
| Den Haag | `city.den-haag` |
| Utrecht | `city.utrecht` |
| Eindhoven | `city.eindhoven` |

The current generated release manifest records five governed, published, verified
records and seven marked QA gates. The current generated import preview reports:

| Structural import field | Value |
|---|---:|
| Selected releases | 1 |
| Eligible records | 5 |
| Excluded records | 0 |
| Technical duplicates removed | 0 |
| Broken relations | 0 |
| Production artifact changed | false |

[PublishedCitiesDataReleaseTests.swift](../YouNewTests/PublishedCitiesDataReleaseTests.swift)
defines focused contracts for canonical legacy replacement, duplicate absence,
indexed search, city coordinates, HTTPS source shape, hero media, consumer data,
typed guide routing, and corrupt-dataset rejection. Its final execution result is
reported only in `FINAL_VALIDATION.md`.

The five records establish city identity and core metadata. They do not establish
equal depth of city-specific guides; Amsterdam currently has deeper governed
coverage than the other four cities.

## Structural import health is not URL health

Two different checks answer different questions:

| Check | Current evidence | What it proves | What it does not prove |
|---|---|---|---|
| `import-preview.json` | 5 eligible records, 0 excluded, 0 technical duplicates removed, 0 broken relations for the selected city release. | The selected release satisfies the recorded structural import rules. | That external pages are reachable or still editorially appropriate. |
| `data-health.json` | Status `attention_required`; 2,494 URLs checked, 1,821 reachable, 18 confirmed broken, 623 access-restricted, and 32 transient failures. | A separate network-health run found unresolved external-link risk in the wider governed runtime data. | That every restricted or transient result is broken, or that a later run will be identical. |

Therefore the safe claim is:

> The repository contains a schema-governed content/import platform and a
> structurally valid five-city release. Current external-source health is not
> fully green: the latest available network report contains 18 confirmed broken
> URLs.

Do not shorten this to “data validation passes” without specifying which
structural command ran and separately disclosing the network-health result.

## Runtime consumers

The bundled payload is loaded into canonical data models and projected into:

- repository-backed Guide and typed destinations;
- indexed Search;
- local assistant composition and official-source actions;
- city content used by Home and Places; and
- map models and city navigation.

The focused city test verifies these source-level integrations for the five
canonical city identities. Final UI evidence must still show the actual candidate
moving through at least one city route.

## Failure behavior

The runtime loader parses the bundled schema and returns an empty loaded result for
malformed input rather than accepting partial corrupt JSON. Tests define that
contract. This is a bounded corruption behavior, not a general guarantee against
every semantic content error.

Generated reports under `DataProject/reports/` are ignored run artifacts. They
must be regenerated by the documented commands when reproducing an import. The
versioned release definitions, batches, migration registry, importer, and bundled
runtime payload remain the portable implementation evidence.

## Current limitations

- The latest network-health report contains 18 confirmed broken URLs.
- Content breadth and depth are uneven across cities and domains.
- Internal `published` status does not mean external distribution.
- Recorded approval metadata is not independent proof of approver identity.
- Consumer-source wiring is not production usage telemetry.
- Media metadata does not by itself establish complete rights clearance.
- A structurally valid source may still become stale or change meaning.
- Generated report values must be tied to the exact final candidate run before
  submission.

## Evidence still required before submission

- Regenerate the release manifest and import preview from the final candidate.
- Preserve the exact structural validation transcript.
- Re-run network health and either remediate the 18 confirmed broken URLs or
  retain them as an explicit limitation.
- Capture one end-to-end city route in the final app.
- Obtain owner approval for release scope, external-source wording, and media
  rights.

