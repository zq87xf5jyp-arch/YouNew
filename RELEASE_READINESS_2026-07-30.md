# YouNew system and sale readiness — 2026-07-30

Assessment time: 2026-07-30, Europe/Amsterdam.

## Decision

**CONDITIONAL / NO-GO for an unconditional production handover.**

The product is a functioning, locally verified multi-component asset and the live public/Admin/Supabase surfaces exist. It is not yet a clean, transferable release because the candidate has no isolated commit/tag, fresh restore evidence or authenticated production Admin E2E. No production mutation was made during this assessment.

## Confirmed current state

| Component | Result | Evidence |
|---|---|---|
| Public web | PASS locally and live smoke | 585 static routes, 575 indexable URLs, 83/83 tests, 47,462 internal checks; live home/guides/business/guide routes rendered without relevant console errors |
| Admin | PASS locally; PARTIAL live | lint, typecheck, 10/10 tests and production build pass; `admin.younew.nl` resolves, uses TLS and redirects anonymous dashboard access to `/login` |
| Supabase | PASS for availability; PARTIAL release parity | project healthy, 11 remote migrations, 4 active Edge Functions; local `analytics-ingest` correction is not yet deployed |
| Data/content | PASS structurally; FAIL investor depth target | 450 governed records, 186 public projection records, 15 public summaries, 20 guide scaffolds and 0 production-ready practical guides |
| Freshness | PASS investor threshold | 440/450 governed records inside SLA (97.8%); the 10 exceptions are time-sensitive historical event records |
| Media rights | PASS engineering gate | 170 iOS assets inventoried, 0 unresolved gate failures; 27 derived symbols retain exact source and derivation evidence |
| AI proxy | PASS contract tests | 13/13 tests; explicit model contract and invalid-output rejection |
| iOS | PASS Debug and unsigned device Release; BLOCKED executable tests | Debug app/test targets compile/link; after restarting a stalled CoreSimulator asset agent, the exact CI gate `Release` + `generic/platform=iOS` completed with `BUILD SUCCEEDED`; local test-runner install/launch still stalled, so executable tests are not reported as passed |
| Git/CI identity | FAIL release gate | branch `admin-dashboard-integration`, working baseline `a3e59642`, dirty worktree, 6 commits ahead and 4 behind its remote |
| Backup/rollback | PARTIAL | repository backup workflow and runbooks exist; no fresh off-site Supabase dump plus restore-list/rehearsal evidence |
| Commercial | TEST/NOT PROVEN | 3 inquiries are test records; no paying customer, verified profile, live campaign, accepted paid lead or revenue evidence |

## Investor recommendation implementation

| Recommendation | Status | What is implemented | What still requires people/market/external authority |
|---|---|---|---|
| 40–50 high-intent guides | PARTIAL | governed programme, 20 scaffolds, strict publication gate | official research, full steps/FAQ/media, named human review; 0 production-ready today |
| ≥95% freshness | MET | 97.8% governed-record compliance | ongoing owner cadence and historical-event cleanup |
| Task/source/save/journey measurement | PARTIAL | consented event contract and KPI definitions | sufficient real-user sample and aggregate Admin reports |
| 10 distribution partners | NOT PROVEN | partner proposition exists | contracts and active distribution cannot be created without counterparties |
| 20 verified business profiles | NOT BUILT/PROVEN | verification target and advertising contract specified | verification operations, real companies and approved profiles |
| 5 paid pilots | NOT PROVEN | reviewed application path exists | offers, contracts, invoices and paying counterparties |
| Advertiser platform | SPECIFIED, NOT RELEASED | typed surfaces, exclusions, fail-closed sponsored rules and target operating contract | identity, verification, campaigns, approval, billing, leads, complaints/refunds and E2E |
| Country Pack | SPECIFIED, NOT VALIDATED | reusable contract and release invariants | Belgium pack, multilingual human review and ≤90-day repeatability evidence |
| GDPR/DSA/AI/WCAG | PARTIAL ENGINEERING | privacy/security/publication controls and control matrix | formal legal applicability, DPIA/records, AI inventory/disclosure review and WCAG 2.2 AA audit |
| Clean production release | PARTIAL | runbooks, local builds/tests, live surfaces | clean SHA/tag, green CI, fresh backup, authenticated E2E, rollback rehearsal and approved deployment |

## Release blockers

1. Freeze and review the intended changes; reconcile branch divergence without losing unrelated work; create a signed/tagged release candidate and run CI on that identity.
2. Create an encrypted off-site Supabase dump, record SHA-256, validate `pg_restore --list`, and rehearse restore against an isolated target.
3. Execute authenticated owner/admin and denied-user production E2E without exposing credentials or PII.
4. Resolve the CoreSimulator test-runner infrastructure issue or obtain green iOS unit/UI evidence on clean CI; then produce and validate the signed App Store archive.
5. Run formal IP title-chain, privacy/DSA/AI and WCAG 2.2 AA reviews; add company, contracts, finance and tax evidence to the data room.

## Updated assessment

- Technical product readiness: **7.8/10** — strong breadth and automated gates, with release identity/runtime evidence gaps.
- Transaction/data-room readiness: **5.5/10** — usable technical evidence, but corporate, financial, legal and clean handover evidence are incomplete.
- Institutional-seed readiness: **5.3/10** — slightly above the investor’s 5.0 technical baseline; traction, distribution, monetization and production-ready guides remain unproven.

These are assessment scores, not a valuation or a guarantee of saleability.
