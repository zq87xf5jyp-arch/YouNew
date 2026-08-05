# ADR-012 — Search-ready content publication contract

- Status: proposed
- Date: 2026-08-05
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: `admin-dashboard/src/components/admin/content-manager.tsx`; `docs/reports/SEARCH_QA_MATRIX.json`; `admin-dashboard/tests/search-content-readiness-contract.test.ts`
- Related migrations: `admin-dashboard/supabase/migrations/20260805140524_article_search_canonical_title.sql`; `admin-dashboard/supabase/migrations/20260805140534_article_search_taxonomy_categories.sql`; `admin-dashboard/supabase/migrations/20260805140541_article_search_metadata_columns.sql`; `admin-dashboard/supabase/migrations/20260805140802_article_search_metadata_backfill.sql`; `admin-dashboard/supabase/migrations/20260805140810_article_search_constraints.sql`; `admin-dashboard/supabase/migrations/20260805140818_article_search_publication_gate.sql`; `admin-dashboard/supabase/migrations/20260805140825_article_search_readiness_view.sql`; `admin-dashboard/supabase/migrations/20260805140933_remove_premature_article_search_indexes.sql`

## Problem and context

The public taxonomy and generated search index can cover known terms while new
Admin articles still omit the metadata needed for discovery, geographic
fallback and profile-aware ranking. UI-only validation is insufficient because
imports or service-role writes can bypass the form. A database-only constraint,
in turn, cannot explain editorial risks before publication is attempted.

## Considered options

1. Keep search metadata only in the generated public taxonomy.
2. Validate metadata only in Admin.
3. Define one additive database model, surface editorial warnings in Admin,
   enforce completeness at publication, and verify public queries from a
   versioned QA matrix.

## Decision

Use option 3. Every article stores its canonical title, intents, aliases,
keywords, supported languages, geographic scope, profiles, official HTTPS
sources, quality score and index status. Drafts may remain incomplete, but the
database rejects incomplete published rows. A security-invoker readiness view
and Admin UI expose explicit warnings. Existing published rows receive only a
bounded metadata backfill; their content, status and publication evidence are
not changed.

The exhaustive QA report covers the critical EN/NL/RU intents across all 342
municipalities, 12 provinces and supported profiles. Production remains NO-GO
until desktop Chromium and mobile WebKit browser smoke passes.

## Consequences and risks

Search eligibility becomes reviewable and enforceable at both application and
database boundaries. Editors gain more required fields and must resolve
warnings before publication. Existing rows are not falsely marked search-ready.
Search-array indexes are removed while the table is small; they should return
only after production query plans demonstrate a real need.

The public taxonomy and Admin metadata still have different lifecycles. Contract
tests and canonical category choices reduce drift, but a single governed content
pipeline remains the preferred future architecture.

## Verification

Automated contracts verify every mandatory field, warning type, publication
gate, narrowly scoped legacy-trigger handling and production smoke definition.
The public search matrix verifies 2,608 combinations and records its search
index fingerprint. Pre-deploy validation covers generation, links, security,
governance and service-worker output. The eight critical user journeys must then
pass against the exact production origin in both browser engines.
