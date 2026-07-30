# ADR-004 — Confidence evidence index and readiness scorecard

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/governance/status-policy.json; docs/KPI_FRAMEWORK_V19.md
- Related migrations: admin-dashboard/supabase/migrations/20260730130000_content_governance_platform.sql

## Problem and context

A numeric score is useful for comparison but can be misread as probability or
used to hide a critical failure in an average.

## Considered options

1. Manually editable trust score.
2. Reproducible evidence coverage index with stored breakdown and formula
   version.
3. Probabilistic truth estimate without a calibrated ground-truth dataset.

## Decision

Propose option 2. Record confidence is the sum of official-source evidence
(40), active human review (20), independent second review (15), freshness (10)
and verified jurisdiction applicability (15). It is not a probability. Source
Trust Score remains separate. Readiness dimensions use their specified minima;
Overall Readiness is the minimum established dimension and cannot override
hard release gates.

## Consequences and risks

Scores are derived server-side and never directly edited. Missing denominators
produce `not_established`. Disputed, unavailable, archived and unverified
records are excluded before ranking regardless of score. The formula can still
incentivize evidence collection over outcome quality, so User Outcome Gate
remains mandatory.

## Verification

Formula-version fixtures, denominator reconciliation and critical-failure
tests prove that aggregates cannot convert a failed hard gate into GO.
