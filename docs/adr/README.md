# Architecture Decision Records

This directory records governance-sensitive architecture decisions for YouNew.
DataProject remains the canonical editorial source; accepted ADRs explain how
the iOS app, public website, admin dashboard, Supabase and AI consumers project
and enforce that data.

## Lifecycle

1. Copy `0000-template.md` and allocate the next number from `index.json`.
2. Draft the decision as `proposed`. An AI agent may only create or update a
   proposed ADR.
3. Assign a real human decision owner and obtain the required review.
4. Change the status to `accepted`, or record why it was rejected.
5. Never rewrite an accepted decision. Add a new ADR and mark the old one
   `superseded` or `deprecated`.

Governance schema, status/scoring policy, retrieval, link checking, semantic
duplicate policy, AI evaluation or Supabase governance migration changes must
update `index.json` and at least one ADR in the same pull request.

`scripts/adr-policy-check.py` validates this contract in CI.
