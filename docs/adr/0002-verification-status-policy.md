# ADR-002 — Verification and status policy

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/governance/status-policy.json; scripts/governance_contract.py
- Related migrations: admin-dashboard/supabase/migrations/20260801002204_content_governance_platform.sql

## Problem and context

Publication, evidence validity and human review progress are different facts.
A single status cannot represent them without unsafe implicit transitions.

## Considered options

1. One lifecycle enum. It is easy to display but conflates independent facts.
2. Three independent axes plus a deterministic effective status.
3. Free-form tags and client-side interpretation, which cannot be verified.

## Decision

Propose option 2. Use `publicationStatus`, `verificationStatus` and
`reviewState`. Effective verification precedence is archived, disputed,
source_unavailable, unverified, overdue, review_due_soon, verified.
`review_due_soon` begins by the smaller of 14 days or 25% of the review
interval, with a one-day minimum. A client may downgrade from current
timestamps but cannot upgrade without a human verification event.

## Consequences and risks

Consumers must render degraded states and cannot infer publication from review
state. Time calculations use ISO 8601 UTC. Clock skew can only cause a
conservative downgrade. Legacy records backfill as unverified.

## Verification

Golden timestamp fixtures run in all component languages. Boundary tests cover
one-day intervals, 14-day caps, null evidence and status precedence.
