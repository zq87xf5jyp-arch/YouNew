# ADR-009 — Content governance database hardening

- Status: proposed
- Date: 2026-08-01
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/schema/content-governance.schema.json; admin-dashboard/src/lib/governance
- Related migrations: admin-dashboard/supabase/migrations/20260801003000_harden_content_governance_performance.sql

## Problem and context

The content governance tables already enforce row-level security, but the
database advisor identified repeated authentication-function evaluation,
overlapping permissive policies and missing indexes on foreign-key columns.
Those findings increase query cost and make the authorization model harder to
audit as editorial history grows.

## Considered options

1. Leave the existing policies and indexes unchanged until traffic increases.
2. Replace overlapping policies with one explicit authenticated policy per
   operation, evaluate the authenticated user once per statement, and index
   every governance foreign-key path used by joins and review queues.
3. Move governance authorization into the application and relax database RLS.

## Decision

Propose option 2. Keep the database as the enforcement boundary, preserve the
existing role capabilities, consolidate policies deterministically, and add
non-destructive indexes. Anonymous access remains denied and authenticated
mutations remain limited to the operations defined by the governance contract.

## Consequences and risks

The change improves predictable query planning and reduces policy ambiguity
without changing table data. A policy-name mismatch in an older environment
could leave a superseded policy in place; the migration therefore drops every
known prior policy name before creating the canonical set. Rollback is a new
forward migration restoring the earlier policy definitions and removing only
the indexes introduced here after verifying they are unused.

## Verification

Run the Supabase migration audit, verify RLS is enabled on every governance
table, verify anonymous reads and authenticated inserts remain denied where the
contract requires, and confirm the security/performance advisors report no
duplicate permissive policies, per-row auth initialization plans or unindexed
foreign keys. CI must also pass `scripts/adr-policy-check.py` against the target
branch before this proposal is eligible for human acceptance.
