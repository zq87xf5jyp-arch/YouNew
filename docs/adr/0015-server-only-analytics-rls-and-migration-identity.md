# ADR-015 — Make analytics rate-limit state server-only and record migration identity aliases

- Status: proposed
- Date: 2026-08-18
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: `admin-dashboard/supabase/production-migration-manifest.json`; `scripts/verify-supabase-migration-manifest.py`; `admin-dashboard/supabase/tests/analytics_ingest_windows_rls_test.sql`
- Related migrations: `20260818145801_harden_analytics_ingest_windows_rls.sql`

## Problem and context

Production evidence showed that `private.analytics_ingest_windows` had row-level
security disabled. Direct `anon` and `authenticated` grants were already absent,
and only the service-role analytics ingestion RPC used the table, but the missing
RLS layer weakened defense in depth. Security Advisor also reported two
RLS-enabled tables with no policies: `public.feedback_rate_limits` and
`public.governance_action_receipts`. Their grants and consumers likewise show an
intentional server-only contract.

The 24 production migration names matched the repository, but two production
timestamps differed from the local filenames. Production statement bytes prove
that each pair is identical, so renaming or rewriting the historical local SQL
would add risk without changing the database.

## Considered options

1. Leave grants as the only analytics protection and merely document the RLS
   finding.
2. Enable RLS with no policies, relying on PostgreSQL's implicit deny behavior.
3. Enable RLS, retain service-only grants and add explicit restrictive rejection
   policies for client roles; record production/local timestamp aliases in a
   versioned manifest.

## Decision

Use option 3. The forward migration enables RLS on
`private.analytics_ingest_windows`, explicitly rejects every `anon` and
`authenticated` operation, preserves service-role DML and keeps the ingest RPC
service-only. It also turns the two intentional no-policy tables into explicit
deny contracts without expanding their grants.

The manifest schema records production version as `version`, an exceptional
repository filename timestamp as `localVersion`, and unapplied reviewed SQL in
`pendingMigrations`. Historical SQL bytes remain immutable. The analytics Edge
Function calls the production RPC `ingest_analytics_batch`; it does not introduce
a second privileged `_v2` function.

## Consequences and risks

Client access stays denied even if table privileges are accidentally broadened.
The service-role path continues to bypass RLS as intended, so service credentials
remain a high-impact secret. The explicit rejection policies remove ambiguity
from advisor output but do not replace grant review.

The migration is pending and has not changed production. Applying it without a
database backup, pgTAP run and ingestion smoke test could interrupt analytics.
Manifest aliases are evidence-backed exceptions, not permission to invent or
renumber future migrations.

## Verification

Production was inspected read-only on 2026-08-18. The two aliased production
records have the same MD5 and byte length as their local SQL files:
`ea265966b977ac1824b84f5b3e78e990` / 5711 bytes and
`e04e3378050bbe7cd5ecf79c28126807` / 17709 bytes. Static unit tests verify the
forward SQL, Edge RPC name, role matrix, pgTAP coverage and manifest fingerprint.
The migration contains transactional preflight and postcondition checks.

Before acceptance or application, run the pgTAP file on a disposable database,
exercise the Edge ingestion path, review Supabase Security and Performance
Advisors, and obtain separate production approval. After application, move the
pending manifest entry into applied history using the production-recorded version
and re-check exact bytes.
