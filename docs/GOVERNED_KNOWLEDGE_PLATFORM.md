# YouNew Governed Knowledge Platform

## Confirmed architecture

DataProject is the canonical editorial source. Supabase is an operational
projection for provenance, source checks, human review, append-only versions
and research observations. iOS, public web and AI consume generated,
versioned artifacts; they do not create canonical publication authority.

The governance contract has three independent axes:

- `publicationStatus`: draft / qa / published / archived;
- `verificationStatus`: unverified / verified / review_due_soon / overdue /
  source_unavailable / disputed / archived;
- `reviewState`: needs_review / assigned / in_review / approved / monitoring /
  expired / closed.

## Affected-component matrix

| Component | New responsibility | Compatibility boundary | Activation |
| --- | --- | --- | --- |
| DataProject | Canonical envelope, coverage policy, ADR and evaluation artifacts | Missing envelope is unverified | Repository merge |
| Supabase | Operational state, immutable versions/events, review queue and source attempts | Additive migration only | Separate approval required |
| Admin | Content Health, Trust Dashboard, explicit verify/approve RPC | Falls back to repository evidence when views are absent | After migration |
| Public web | Degraded status, source, jurisdiction and decision trace | Optional fields; old artifacts remain decodable | Separate deployment |
| iOS | Optional governance model and degraded presentation | Missing envelope is unverified; decoder stays backward compatible | Separate release |
| AI | Fail-closed retrieval and machine-validated explainability | Excluded statuses never rank | AI gate required |
| Research | Purpose-limited 20-observation protocol | No general product analytics implied | Privacy approval required |

## Safety and rollback

The migration initializes `governance_consumers`, `scheduled_writeback` and
`research_ingestion` as disabled. Rollback disables the new consumers/RPC
workflow but preserves tables and append-only evidence. DataProject
publication, scheduled write-back, production migration, web/admin deployment
and iOS release are not part of this implementation action.

## Current evidence

- Legacy records do not contain `ContentGovernanceEnvelope`; they are treated
  as unverified.
- The national official municipality denominator is not established.
- The semantic model artifact is pinned, but the transitive Python wheel lock
  remains partial and no calibrated labelled report exists.
- The 1,000 AI cases are generated drafts with zero human approvals.
- The real User Outcome study has not started.

Therefore the current release authority is **NO-GO**, independent of any
numeric score.
