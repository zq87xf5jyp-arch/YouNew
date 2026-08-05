# ADR-012 — Search-ready content publication contract

- Status: proposed
- Date: 2026-08-05
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: admin-dashboard/src/components/admin/content-manager.tsx; admin-dashboard/public-site/src/data/search-qa-matrix.json; admin-dashboard/public-site/tests/search-qa-matrix.test.ts; admin-dashboard/tests/search-content-readiness-contract.test.ts
- Related migrations: admin-dashboard/supabase/migrations/20260805134500_article_search_readiness.sql; admin-dashboard/supabase/migrations/20260805134530_article_search_constraints.sql; admin-dashboard/supabase/migrations/20260805134545_article_search_publication_gate.sql; admin-dashboard/supabase/migrations/20260805134600_article_search_readiness_view.sql; admin-dashboard/supabase/migrations/20260805134630_remove_premature_article_search_indexes.sql

## Problem and context

The public taxonomy and generated search index can cover known terms while new
Admin articles still omit the metadata needed for discovery, geographic
fallback and profile-aware ranking. UI-only validation is insufficient because
imports, future integrations or service-role writes can bypass the form.
Conversely, a database-only constraint cannot explain editorial risks before a
reviewer attempts publication.

## Considered options

1. Keep search metadata only in the generated public taxonomy.
2. Validate metadata only in the Admin application.
3. Define one additive database model, expose editorial warnings in Admin,
   enforce completeness at publication and verify required public queries from
   a versioned QA matrix.

## Decision

Propose option 3. Every article stores canonical intent, aliases, keywords,
supported languages, geographic scope, profiles, official HTTPS sources,
quality score and index status. Drafts may remain incomplete so editors can
work incrementally, but a database trigger rejects incomplete published rows.
A security-invoker view and the Admin interface surface explicit readiness
warnings. Existing published rows receive only a bounded metadata backfill;
their body, status, evidence and publication timestamps are not changed.

The release query matrix is versioned with the application. It covers the
critical life domains across EN/NL/RU, all supported municipalities and
provinces, profiles, typos and city aliases. Production remains NO-GO until the
release-critical browser smoke passes on desktop Chromium and mobile WebKit.

## Consequences and risks

Search eligibility becomes reviewable and enforceable across application and
database boundaries. Editors gain more required fields and must resolve
warnings before publication. Existing rows are not falsely marked search-ready;
they remain visible with honest warnings. Search-array indexes are intentionally
removed while the table is small and should be reintroduced only when query
plans demonstrate a need, avoiding current write amplification and unused-index
noise.

The taxonomy and Admin metadata are still separate sources with different
lifecycles. Drift is contained by using the public taxonomy for category choices
and by contract tests, but a future unified content pipeline remains desirable.

## Verification

Automated contracts verify all mandatory fields, warning types, publication
gate behavior, narrowly scoped legacy-trigger handling and the production smoke
definition. Public search tests execute every matrix term across all 342
municipalities and 12 provinces. Pre-deploy validation covers static generation,
links, security, data governance and service-worker output. After deployment,
the eight critical journeys must pass on the production origin in both required
browser engines before the release is classified GO.
