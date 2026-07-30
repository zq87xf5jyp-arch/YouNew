# YouNew Governed Knowledge Platform — implementation readiness

Date: 2026-07-30

Decision: **NO-GO**

Branch: `codex/governed-knowledge-platform`

## Executive decision

The repository now contains the governed-platform contracts, additive Supabase design, review workflow, deterministic status and confidence policies, Trust Dashboard, BRP + Amsterdam non-publishable vertical, degraded public/iOS disclosures, local semantic-duplicate policy, AI evaluation corpus/framework, and user-outcome research protocol.

This is an implementation checkpoint, not release evidence. No Supabase production migration, scheduled write-back, DataProject publication, web/admin deployment, or iOS release was performed.

The release remains **NO-GO** because:

1. no record has a complete governed publication envelope;
2. all 1,000 AI cases remain human-unapproved drafts and no baseline/candidate run exists;
3. the national municipality denominator is not established;
4. the Supabase migration and pgTAP/RLS suite have not run against an approved database;
5. the semantic model artifact/dependency chain is not fully installed and verified locally;
6. the user-outcome study has 0/20 valid observations.

## Implemented scope

| Area | Repository evidence | State |
|---|---|---|
| Governance contract | `DataProject/schema/content-governance.schema.json`, shared fixtures, Python/TypeScript/Swift policies | Implemented |
| ADR governance | `docs/adr/`, eight proposed ADRs, index and CI coupling check | Implemented; human acceptance pending |
| Provenance and review | Additive Supabase tables, immutable version/event logs, protected RPCs and fail-closed RLS | Authored; database execution pending |
| Confidence | Versioned evidence coverage index and breakdown; separate Source Trust Score | Implemented |
| Review Queue | Admin queue, transition actions and SLA-aware data contract | Implemented; live state pending migration |
| Coverage and Trust Dashboard | Deterministic artifact, formula metadata, evidence states, hard gates and prioritized risks | Implemented |
| BRP + Amsterdam | Seven official-source-backed records staged as migrated, draft, unverified, needs-review | Implemented; intentionally non-publishable |
| AI retrieval/explainability | Status filtering, jurisdiction-first ranking, deterministic decision trace and user disclosure | Implemented |
| AI regression | 1,000 versioned EN/NL/RU draft cases, validator, deterministic release evaluator | Framework complete; release evidence not established |
| Semantic duplicates | Local-only pinned model policy, preflight, compatible-pair filter and review-only threshold | Framework complete; model run/calibration pending |
| Link health | Error classification, retry thresholds, immutable attempts and disabled write-back | Implemented |
| Research | Consent, privacy contract, observation form, protocol and results template | Prepared; study not started |

## Evidence snapshot

The generated Trust Dashboard reports:

- 450 canonical records;
- 0 governed verified records;
- 186 legacy/public records (41.3%), all shown with degraded governance disclosure;
- 0/5 production-ready Amsterdam pilot municipality-topic cells;
- national municipality-topic coverage: `not_established`;
- AI release evidence: 0/1,000 human-approved cases;
- user research: 0/20 valid observations;
- Content Governance, AI and User Outcome hard gates: all failed;
- Overall Readiness: `not_established`.

`confidenceScore` is an evidence coverage index, not a probability of truth. No aggregate score can override a critical hard-gate failure.

## Verification completed

| Component | Result |
|---|---:|
| Python governance/AI/link/coverage/unit tests | 67/67 passed |
| Admin Node tests | 17/17 passed |
| Public web Node tests | 86/86 passed |
| Backend proxy tests | 13/13 passed |
| iOS governance tests | 14/14 passed |
| iOS AI decision-trace tests | 7/7 passed |
| iOS runtime compatibility/release tests | 6/6 passed |
| Admin TypeScript and ESLint | Passed |
| Public web TypeScript and ESLint | Passed |
| Public Next.js production build | Passed; 585 static pages generated |
| iOS build-for-testing | Passed |
| ADR, repository and practical-guide static QA | Passed |
| AI corpus validation | 1,000 cases; release evidence `not_established` |
| Semantic detector preflight | Passed; inference not run |
| Supabase pgTAP/RLS | Authored, not executed |
| Manual VoiceOver/keyboard/contrast/offline-error matrix | Not executed |
| User Outcome study | Not started |

The three iOS results above come from completed individual result bundles. A later combined re-run exceeded the XcodeBuildMCP 300-second tool timeout and produced no valid result bundle, so it is not counted as evidence or as a test failure.

## Production blockers

### P0 — evidence and approvals

- Human owners must review and accept or supersede the proposed ADRs.
- Approve a non-production Supabase target, apply the additive migration there, and run pgTAP/RLS plus rollback/compatibility tests.
- Perform independent human review of the BRP and Amsterdam candidate; approval must occur through the server-side event/RPC path.
- Establish and version the official national municipality denominator.

### P0 — AI and supply chain

- Install only the pinned safetensors/ONNX model artifact, verify its SHA-256 and complete the dependency SBOM.
- Human-review and approve the regression corpus.
- Run baseline and candidate under the same recorded environment; all hard blocking objectives must pass.
- Calibrate semantic duplicate threshold with labelled reviewer outcomes before it can inform a release claim.

### P0 — user outcomes

- Obtain protocol/privacy approval.
- Run the 10-participant, 20-observation study without prohibited personal data.
- Pass BRP and overall completion, source-open, error, help, wrong-turn and time gates.

### P1 — accessibility and degraded operation

- Run the iOS runtime accessibility suite and manual VoiceOver reading-order checks.
- Verify Dynamic Type, keyboard operation, contrast/forced-colors, offline and source-error behavior on supported iOS and browser targets.
- Record evidence artifacts; compile-time accessibility modifiers and static web tests are not sufficient release proof.

## Authorized next execution sequence

1. Review and accept ADRs.
2. Approve a non-production Supabase environment.
3. Apply migration, run pgTAP/RLS, compatibility and rollback exercises.
4. Complete human BRP review and publish only through approved RPCs.
5. Verify the pinned semantic model/SBOM and run candidate detection.
6. Approve and run the AI regression corpus.
7. Execute the user-outcome study.
8. Regenerate the Trust Dashboard and readiness report from current evidence.
9. Request separate approval for each production migration/publication/deployment/release action.
