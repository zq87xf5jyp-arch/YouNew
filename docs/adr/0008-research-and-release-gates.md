# ADR-008 — Research telemetry and release gates

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: docs/user-validation/RESEARCH_PROTOCOL.md; docs/user-validation/PRIVACY_CONTRACT.md
- Related migrations: admin-dashboard/supabase/migrations/20260801002204_content_governance_platform.sql

## Problem and context

Structural quality and AI metrics do not prove that newcomers can complete
high-stakes Dutch administrative journeys without errors or assistance.
Research telemetry can itself create privacy risk.

## Considered options

1. Release from engineering checks only.
2. A consented, data-minimized 20-observation outcome study plus hard content
   and AI gates.
3. General product analytics without a purpose-limited research protocol.

## Decision

Propose option 2. Use random research-session UUIDs, separate consent and
90-day retention. Do not collect BSN, medical data, contacts, form text, IP or
user-agent. GO still requires Content Governance Gate, AI Gate, User Outcome
Gate and Overall Readiness at least 80. A score never overrides a hard failure.
Missing denominators or evidence produce `not_established`.

## Consequences and risks

The current release remains NO-GO until the five journeys form one verified
system and the real study passes. Research ingestion remains feature-disabled
until human privacy review, lawful-basis confirmation and operational retention
verification. CONDITIONAL GO cannot waive the User Outcome Gate.

## Verification

The protocol requires ten newcomers and twenty observations, with predefined
completion, source-open, wrong-turn, external-search, help, time and critical
error thresholds. Reports distinguish observed evidence from assumptions.
