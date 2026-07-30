# YouNew advertiser platform contract

Status: target operating and data contract. Current production remains a reviewed inquiry workflow, not advertiser self-service.

## Current boundary

YouNew currently supports a protected public application, server validation, rate limiting, an auditable Admin inquiry workflow and typed but globally disabled sponsored-placement rules. It does not provide advertiser login, company verification, campaign purchase, live inventory, billing or guaranteed analytics.

## Target modules

| Module | Minimum production capability |
|---|---|
| Identity and roles | Advertiser owner/member, reviewer, compliance and finance roles with least privilege and MFA |
| Company verification | KvK/registry evidence, domain/contact verification, reviewer decision, expiry and re-verification |
| Inventory | Versioned eligible surfaces, exclusions, pricing basis, availability and jurisdiction |
| Campaign builder | Creative, targeting, dates, budget, disclosures and accessibility fields |
| Approval | Editorial/compliance review, conflicts, reasons, immutable decision trail |
| Contract and billing | Quote/order, invoice, tax basis, payment state, cancellation and credit note |
| Lead operations | Consent-aware lead inbox, routing, accept/reject reason and response SLA |
| Reporting | Accepted-lead and campaign aggregates with denominators; no unsupported outcome claims |
| Complaints and refunds | Case record, evidence, resolution, refund/credit and audit log |
| Public policy | Sponsored label, advertiser identity, why shown, ranking separation and complaints route |

## Non-negotiable controls

- Sponsored placement is fail-closed and remains disabled until a verified advertiser, approved campaign, valid dates, safe destination and eligible surface all match.
- Payment never creates an “official” status or changes organic relevance.
- Emergency, legal, privacy, support, official-source and procedural-step surfaces remain ad-free.
- Personal inquiry or lead data is excluded from analytics and buyer-facing exports.
- Billing, lead acceptance and complaints use immutable event/audit records.
- Every commercial claim includes its population, period and denominator.

## Release gate

Self-service advertising cannot be enabled until threat modelling, privacy review, DSA applicability/classification, payments/tax review, authorization tests, complaint/refund operations, backup/restore and production E2E are complete. Until then, YouNew must describe the offer as manually reviewed inquiry/pilot only.
