# ADR-003 — Provenance and prohibition of AI publication

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/schema/content-governance.schema.json
- Related migrations: admin-dashboard/supabase/migrations/20260730130000_content_governance_platform.sql

## Problem and context

Source citations do not establish how a record entered the system or which
transformations produced it. AI-generated and migrated material must not gain
publication authority from a service role.

## Considered options

1. Store only the latest editor. This loses the origin and transformation chain.
2. Store immutable origin plus append-only transformation and review events.
3. Trust service-role writes after automated validation, which grants AI an
   unacceptable publication path.

## Decision

Propose option 2. `contentOrigin` is immutable. Every transformation stores its
parent version, actor type, UTC timestamp, artifact digest and transformation
identifier. AI-generated and migrated records start draft/unverified. Only a
separate server-side human approval event by an authorized active reviewer can
make them publication eligible. AI cannot populate `reviewedBy`.

## Consequences and risks

Storage grows append-only and requires retention planning, but auditability is
preserved. Service credentials remain high-impact assets; database constraints
and RPC authorization are required in addition to UI controls.

## Verification

SQL tests attempt direct service/AI publication, reviewer impersonation, origin
mutation and replay. Every path must fail except an idempotent authorized human
verification followed by explicit publication approval.
