# ADR-018 — Localized guide publication and private editorial review

- Status: proposed
- Date: 2026-11-11
- Draft author: Codex
- Human decision owner: pending owner review of PR 59; no new content or tracking activation approved
- Supersedes: none
- Related contracts: entity.schema.json practical_guide; immutable editorial approval; public projection; analytics consent
- Related migrations: none; optional additive SQLite guide_events table in the disabled analytics candidate

## Problem and context

The full-guide importer previously accepted only the English route. The public catalogue includes owner-approved short EN/NL guides on stable URLs. Deepening these guides must preserve historical approval, keep unapproved translations private and avoid implying that draft source checking is human editorial review. The SEO plan also requests aggregate guide usefulness metrics without sensitive query text or persistent cross-day identifiers.

## Considered options

1. Replace historical editorial payloads or infer Dutch approval from English approval.
2. Add a reviewed translation contract and an explicit upgrade relationship, preserving old immutable batches and defaults.
3. Publish duplicated new URLs or copy draft payloads directly into the public export.

## Decision

Propose option 2. Keep practical_guide as the English compatibility payload. Add practical_guide_locales.nl, validating the same structure, source references, chronology, media, reviewer registry and publication checks. Dutch evidence must explicitly identify locale=nl; an English evidence item cannot authorize it. A published translation requires a published English payload. Draft translations are omitted from the runtime and search.

A canonical full guide may supersede an existing LIVE short guide only with a published eligible parent and attributes.supersedesEditorialRelease matching the exact historical editorial release. Keep the old editorial record immutable and retain its previously approved short translation until the full translation has its own approval. Unexpected ID collisions still fail. Reuse the original ID/URL.

The isolated review projection requires an explicit build flag, draft status and null reviewer/publication gate. It uses the same renderer but never grants publication eligibility. The production projection is empty; production package checks reject review routes, private-review markers and included draft payloads. Protected QA uses existing authentication and no-store/noindex, with preserved pointers and a rehearsed rollback.

Guide analytics are disabled on both client and server. Activation requires a new consent version, bounded public IDs and a separate owner decision. Count only dedicated official continuation links as guide actions; ordinary source citations remain separate. Deduplicate by tab session, UTC day, public content ID and locale. Keep the previous consenting guide-visit date only in the browser; export a bounded return flag, not that date or a stable cross-day visitor ID. Reports expose aggregates only. No email addresses, document contents, search phrases or full referrers are added.

## Consequences and risks

No new guides or translations are published by this change. Source dates are not editorial approval. Publication still requires current source checks, a registered human reviewer, scoped evidence, media approval and a separately approved release. DE/ES remain unsupported for public full guides. Old short NL content can remain visible while a new full NL translation is withheld; interfaces must not claim that it has the same depth.

The return metric describes consenting full-guide visits, not all website visits or unique people. Daily medians cannot be averaged into a weekly median. Before enabling tracking, review the definitions, consent copy, public allowlist and retention; preserve the live database during rollback. GSC, Apple attribution and field Web Vitals remain unavailable until actual access/data exist.

## Verification

Synthetic importer tests reject a missing NL reviewer, English-only evidence, missing EN payload and wrong NL route. Public projection tests cover full NL search without a short template, absence of drafts, explicit upgrades, preserved URLs and unchanged historical approval. Client/PHP tests cover flags, consent, public IDs, deduplication, cumulative active time, retention and private aggregate output. Validate the ordinary package and all private review pages; rehearse the QA pointer rollback. PR CI and owner review remain separate from local and Hostinger evidence; no reviewer identity or approval is fabricated.
