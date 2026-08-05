# ADR-014 — Correct the unapplied analytics admin policy contract

- Status: proposed
- Date: 2026-08-05
- Draft author: Codex implementation agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: `admin-dashboard/tests/analytics-source-contract.test.ts`; `scripts/verify-supabase-migration-manifest.py`; `scripts/adr-policy-check.py`
- Related migrations: `20260805223000_expand_privacy_safe_analytics_dashboard.sql`

## Problem and context

The analytics expansion migration referenced the removed public
`is_approved_admin()` function even though the production security boundary had
already moved that function to the `private` schema. The production migration
attempt failed atomically and Supabase did not record version 20260805223000, so
none of its analytics views, tables, grants or policies were partially applied.

## Considered options

1. Add a public compatibility wrapper before the analytics migration.
2. Leave the broken migration immutable and add a later migration.
3. Correct the unapplied migration to use the existing private function, update
   its manifest fingerprint and record the exceptional decision.

## Decision

Use option 3. The migration was never applied, so correcting its two RLS policy
expressions restores the intended hardened contract without rewriting production
history. Both policies call `(select private.is_approved_admin())`; no public
wrapper or additional executable surface is introduced. The manifest changes
only to the verified bytes of this unapplied migration.

## Consequences and risks

Fresh databases and production now execute the same private admin predicate used
by the rest of the schema. A future in-place edit would still fail the immutable
migration check. The exceptional risk is that a separate database could have
applied the original bytes; such a database must be compared by migration version
and fingerprint before synchronization rather than assuming equivalence.

## Verification

The production migration list is checked before retrying and must not contain
20260805223000. The regression test requires the private function and rejects the
removed public function. The migration manifest, ADR policy, Admin tests,
TypeScript check and ESLint must pass before merge. After application, database
queries verify the version, RLS policies, grants and aggregate views, followed by
Supabase security and performance advisors.
