# ADR-005 — Link checking and retry policy

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: scripts/check-external-links.py; DataProject/governance/status-policy.json
- Related migrations: admin-dashboard/supabase/migrations/20260801002204_content_governance_platform.sql

## Problem and context

One network failure does not prove that an official source is unavailable.
Conversely, repeated hard failures must create visible operational work.

## Considered options

1. Mark unavailable after one failure, causing false downgrades.
2. Record classified attempts and apply a time-bounded retry threshold.
3. Ignore failures until manual reports arrive, delaying safety response.

## Decision

Propose option 2. Store every classified attempt. Two consecutive problems
create an idempotent review task. `source_unavailable` requires three hard
failures spanning at least 24 hours. Restricted and transient outcomes remain
distinct from confirmed hard failure. Recovery creates an event; it does not
silently restore verified status.

## Consequences and risks

The checker requires rate limits, jittered retries and publisher-friendly
scheduling. Authentication walls and bot protection can remain inconclusive.
Operators must review critical sources rather than treating HTTP status alone
as ground truth.

## Verification

Tests cover classification, retry timing, task deduplication, recovery and the
three-failure/24-hour unavailable threshold.
