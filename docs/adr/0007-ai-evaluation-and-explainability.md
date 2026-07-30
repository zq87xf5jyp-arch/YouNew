# ADR-007 — AI evaluation, retrieval and explainability

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/governance/status-policy.json; DataProject/ai-evaluation/manifest.json
- Related migrations: none

## Problem and context

Model or retrieval changes can silently worsen jurisdiction, citation,
freshness, safety and refusal behavior. Hidden reasoning is neither a stable
contract nor an appropriate explanation surface.

## Considered options

1. Spot-check prompts before release.
2. Versioned 1,000-case corpus, deterministic policy graders and independently
   calibrated subjective review.
3. Let the candidate model grade its own release claim.

## Decision

Propose option 2. Retrieval orders exact jurisdiction, admissible status,
official source, freshness, record confidence and stable ID. Excluded statuses
never rank; overdue may only support an official-authority fallback with a
warning. The response includes a deterministic decision trace: selected IDs,
citations, freshness/jurisdiction evidence, ranking factors, confidence
breakdown, aggregated exclusion reasons and policy/model/context versions. It
does not expose chain-of-thought.

## Consequences and risks

All generated evaluation cases remain drafts until human approval. Baseline
and candidate run in the same environment. Critical regressions or
inconclusive critical comparisons block release. Subjective graders require
blinding and calibration; candidate self-evaluation is prohibited.

## Verification

The corpus manifest enforces partitions, languages and category counts.
Deterministic graders require 100% critical safety/privacy/source-status cases,
at least 98% groundedness/citation/jurisdiction/refusal, zero critical
regressions and no objective drop greater than one percentage point.
