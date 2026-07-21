# Data Health blocker — shipped runtime links

Evidence date: 2026-07-21 (Europe/Amsterdam)

## Verdict

**BLOCKED — real fail-closed network-health evidence.**

The ignored, generated `knowledge_data_health.json` was produced at
2026-07-20T23:29:35+00:00. It records 18 confirmed broken URLs after the current
checker’s HEAD-to-full-GET fallback. This is point-in-time evidence, not a new
network run performed for this report.

Deleting, zeroing, or ignoring that evidence to obtain an offline static PASS would
conceal a product-facing release risk. A fresh clone has no generated network report
and correctly uses an epoch/zero-count sentinel meaning **network not run**, not
**all links healthy**.

## Product impact

| Scope | Count |
|---|---:|
| Distinct confirmed-broken URLs | 18 |
| Affected published `amsterdam-v0.1.0` entities | 30 |
| Runtime field occurrences | 85 |
| Legacy-runtime links | 0 |

All findings occur in the tracked, bundled
`YouNew/Resources/Data/younew-runtime-data.json`. `DataProjectRuntimeLoader` admits
the affected records as `published` and `verified`, so this is not draft-only
content.

## Safe affected-group inventory

- One official BREDA route;
- two obsolete Creative Commons deed paths (68 field occurrences across 22
  entities / 34 media objects);
- five unavailable Flickr asset URLs;
- nine unavailable provenance pages for place/media records; and
- one obsolete ScraperWiki/Funda attribution URL.

The raw URL list is intentionally not copied into this public readiness document.

## Required remediation

1. Verify any claimed official route in a normal owner-approved browser session;
   permit a temporary override only with expiring, retained evidence of genuine
   access restriction.
2. Implement a fail-closed versioned `amsterdam-v0.1.1` overlay/effective-release
   mechanism. Directly editing the published base batch is unsafe because the base
   release is immutable and duplicate stable IDs are rejected.
3. Replace each affected media/provenance record only with a reviewed source,
   asset, author, license, retrieval date, and relevance evidence; alternatively
   obtain owner approval to remove optional media and use a neutral fallback.
4. Canonicalize the two obsolete Creative Commons URLs in both attribution and
   license fields. Do not invent replacement links.
5. Re-run importer, release validation, offline static QA, fresh network link
   check, and affected app flows. Require explicit release approval before runtime
   data changes.

## Boundary

The untracked remediation plan in `DataProject/operations/` is a useful local plan,
not an approved release artifact. The expected engineering minimum is roughly one
to two days for overlay/importer/checker work; source/media verification and owner
approval are the larger variable blocker.
