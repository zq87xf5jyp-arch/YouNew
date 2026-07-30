# ADR-006 — Local semantic duplicate candidate detection

- Status: proposed
- Date: 2026-07-30
- Draft author: Codex drafting agent
- Human decision owner: @zq87xf5jyp-arch (repository owner)
- Supersedes: none
- Related contracts: DataProject/governance/semantic-duplicate-model.json
- Related migrations: admin-dashboard/supabase/migrations/20260730130000_content_governance_platform.sql

## Problem and context

Exact matching misses multilingual or differently titled records describing
the same task. Automatic merging risks jurisdictional data loss.

## Considered options

1. External embedding API, which exports governed content and adds vendor
   dependency.
2. Pinned local multilingual embeddings with review-only candidates.
3. Lexical similarity only, which is less reliable across EN, NL and RU.

## Decision

Propose option 2 using `intfloat/multilingual-e5-small` from a pinned revision
and verified safetensors/ONNX artifact. No content is sent to an external API.
Candidate pairs are first constrained by compatible content type and
jurisdiction. Cosine similarity at or above 0.90 creates a
`possible_duplicate` review task. Automatic merge or deletion is forbidden;
exact duplicates continue to block publication.

## Consequences and risks

The model, revision, artifact digest, MIT license and dependency chain must be
recorded in the SBOM. A threshold is not a truth probability. Human labels
`duplicate`, `related` and `false_positive` become calibration evidence.
Until a representative labelled report exists, semantic detection is advisory.

## Verification

Offline EN/NL/RU fixtures validate pair filtering and task creation. Runtime
refuses an unpinned or digest-mismatched model artifact.
