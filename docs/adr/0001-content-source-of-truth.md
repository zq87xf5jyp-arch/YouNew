# ADR-001 — Content source of truth and operational projection

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/schema/entity.schema.json; DataProject/schema/content-governance.schema.json
- Related migrations: admin-dashboard/supabase/migrations/20260801002204_content_governance_platform.sql

## Problem and context

YouNew has editorial records in DataProject and operational workflows in
Supabase. Treating both as independently editable sources would make versions,
publication state and client projections irreconcilable.

## Considered options

1. Make Supabase canonical. This simplifies admin writes but loses the
   repository-reviewed editorial history and reproducible generated artifacts.
2. Keep DataProject canonical and use Supabase as an operational projection.
   This requires explicit synchronization and conflict handling.
3. Permit bidirectional last-write-wins synchronization. This is simple to
   operate initially but cannot preserve evidence or deterministic releases.

## Decision

Propose option 2. DataProject owns canonical content. Supabase stores
operational governance state, review tasks, source checks and append-only
versions. A governed write-back produces a candidate DataProject change; it
never silently overwrites or publishes canonical content.

## Consequences and risks

Every projection carries a stable record ID, monotonic version and artifact
digest. Old clients may consume the legacy fields; new clients treat a missing
governance envelope as unverified. Rollback disables new consumers and RPCs by
feature flag while preserving audit tables. Synchronization conflicts remain a
known operational risk and must fail closed.

## Verification

Contract fixtures must produce identical effective status across Python,
TypeScript, Swift and SQL. Compatibility tests cover old-client/new-server and
new-client/old-server behavior.
