# YouNew monetization readiness — Phase 3 MVP gap matrix

Date: 2026-08-18 (Europe/Amsterdam)  
Mode: local source audit and remediation only. No public copy or price was approved, no production migration was applied, and no lead, message, campaign or payment was created.

## Outcome

Phase 3 is **PARTIAL / NO-GO at Gate 3**. The repository has a secure, consented business-inquiry path, Admin review, sponsorship separation, disabled-by-default placements and clearly labelled demonstration data. Four pending Phase 3 migrations and aligned Web/Admin contracts now implement the required local commercial stages, mandatory controlled lost reasons, evidence-gated `won`, bounded exact-retry suppression, a property-free receipt funnel and a PII-minimised internal Admin inbox. However, the public business surface is still advertising-first, none of those migrations has passed a disposable-database rehearsal or been applied, and the site does not present the required 90-day onboarding pilot.

Five concrete contract gaps were corrected locally. First, the Admin lead consumer's historical column drift was removed. Second, Supabase CLI 2.109.1 created `20260818191112_harden_business_inquiry_pipeline.sql`; it adds qualification fields, the seven-stage lifecycle, stage timestamps, controlled loss taxonomy, evidence-gated `won`, narrow column grants and a PII-minimised audit extension. Third, `20260818192423_deduplicate_business_inquiry_submissions.sql` makes exact valid retries idempotent for fifteen minutes and returns the original safe receipt. Fourth, `20260818193310_extend_lead_analytics_funnel.sql` admits only property-free `lead_start` and `lead_submit`, leaves `pilot_request` rejected, and adds an Admin-only security-invoker aggregate. Fifth, `20260818194626_add_business_inquiry_notification_inbox.sql` creates one safe unread Admin notification for a new inquiry but none for an exact retry; its table contains no submitted contact, company, message or UTM fields. Legacy values are preserved in `legacy_status` and mapped conservatively: nothing is promoted to qualified, proposal or won. These are source changes only; production was not changed.

## Commercial offer contract — draft for owner approval

The first offer should be one narrow product for an employer or relocation provider, not an audience-reach package:

**90-day international-employee onboarding pilot**

- one dedicated onboarding hub;
- 10–20 human-reviewed practical routes selected from the approved guide set;
- explicit city/region and employee-profile scope;
- customer branding separated from editorial decisions;
- consent-safe usage and CTA measurement;
- an anonymized periodic report and export;
- content-update SLA with named responsibilities;
- clear boundary: navigation information, not personal legal, tax, immigration or medical advice.

The prompt's **€1,500 for 90 days** is a test hypothesis for the first 1–3 founding clients, not an approved tariff or market fact. It must remain absent from public copy until the owner approves it. Founding Partner Page (€149 setup + €39/month) and Sponsored Practical Guide (from €350) are secondary hypotheses; performance packages and display advertising remain deferred until traffic and lead measurement are proven.

## Required surfaces

| Required surface | Current repository evidence | Decision |
|---|---|---|
| `/for-business` — one pilot proposition | `/business` exists but leads with placements, profiles and media-kit inventory | Missing; do not alias misleading ad-first copy |
| `/for-business/pilot` | No route or approved pilot copy | Missing; draft offer above awaits owner/design approval |
| `/partners` | `/business/partners` defines verification and editorial independence | Partial; content exists under a different IA |
| `/partners/apply` | `/business/apply` provides validated API-first submission plus user-controlled mail fallback | Partial; route and ad-heavy field model differ |
| Partner profile template | Organic organization pages and disabled sponsored-placement model exist | Partial; no approved verified/sponsor profile contract for the pilot |
| Pricing/offer comparison | `/business/pricing` honestly says request a quote and publishes no unapproved rate | Safe current state; pilot comparison missing |
| Inquiry success/error states | Valid receipt required for success; errors preserve fields and may prepare an unsent draft | Ready locally |
| Demo report | Media kit labels `DEMO REPORT · ILLUSTRATIVE DATA` and disclaims live advertiser analytics | Ready as an advertising example; pilot outcome report missing |
| Privacy/terms/sponsorship | Privacy, terms, partner rules and paid/editorial separation exist | Partial; pilot data-controller/processor responsibilities need explicit review |

## Lead contract and pipeline

### Existing and confirmed

- Browser and Edge Function validation, honeypot, five-request hourly rate limit and origin allowlist.
- Service-role-only insert RPC; no public table insert grant.
- RLS, approved-admin read, owner/admin update, audit log and PII-minimized export.
- Contact, company, website, organization type, offer-like placement interests, audience, city/province, message, consent, source page, UTM fields and timestamps.
- API success only after `YNI-…` receipt validation; fallback draft never claims delivery.

### Corrected consumer drift

The applied production table currently uses `reference_code`, `company_name`, `contact_person`, `email`, `admin_notes` and the retired statuses `new`, `reviewing`, `responded`, `accepted`, `declined`, `test`, `archived`. Admin previously used a second incompatible field/status contract. The pending source contract now centralises `new`, `qualified`, `discovery`, `proposal`, `won`, `lost`, `archived` in one typed module and aligns list, details, update action, export and workspace active-count consumers with the forward migration.

The database and server action both fail closed: `lost` requires one of twelve reviewed reason codes, `other_explicit` also requires a factual detail, and `won` requires `paid_pilot`, `paid_founding_partner_page` or `signed_paid_trial` plus a non-future evidence date. Free-form loss detail is excluded from CSV and audit JSON. Existing `accepted` records do not become invented revenue.

The dedupe function validates before lookup, retains the existing service-role-only RPC boundary and hourly rate limit, serializes exact requests with a transaction-scoped hash that is never stored, compares every material persisted field, and returns the original receipt only within fifteen minutes. A material change or expired window creates a new inquiry. The duplicate audit record contains no submitted PII.

### Required before Gate 3

1. Run the four pending Phase 3 migrations and their 62 pgTAP assertions in a disposable production-like Supabase environment; do not use production as the test database.
2. Prove the local PII-minimised Admin inbox with approved and unapproved identities. Add confirmation email only after a legitimate sender domain and recipient path are configured; never include sensitive message content in a broad channel.
3. Keep the local consent-safe `lead_start` and receipt-backed `lead_submit` contract property-free. Define `pilot_request` only after the 90-day pilot offer and CTA are approved; the current ingest must continue rejecting it.
4. Update the public form from campaign inventory fields to the approved pilot qualification questions. The database/Admin fields exist locally, but public `contact_role` and explicit `offer_interest` collection remains intentionally deferred until copy, design and pricing approval.
5. Prove the complete request, duplicate, spam, Admin, export and analytics path in a disposable production-like environment.

## Safety invariants

- Sponsored status cannot affect factual answers, organic search ranking, official-source ordering, emergency routes, health/legal/government guidance or guide review.
- Sample/demo values must stay visibly labelled and must never be presented as customer, audience, ROI or conversion evidence.
- No identity documents, health data, payment details or sensitive employee information belong in the public lead form.
- A submission is an inquiry, not a reservation, contract, price acceptance or payment.

## Verification

- Admin full contract suite: **57/57 PASS**, including five pipeline/schema assertions, four dedupe assertions, three lead-analytics assertions, three notification-inbox assertions and four lead edge-validation cases.
- Phase 3 pgTAP contracts: **62 assertions authored** (19 pipeline + 13 dedupe + 12 lead analytics + 18 notification inbox), not executed because no disposable PostgreSQL/Supabase runtime is available; production was deliberately not used.
- Public web suite: **149/149 PASS**, including the focused business/analytics and API-first/fallback copy assertions.
- Final isolated public package: build 605/605, TypeScript, ESLint, smoke, link/asset and security stages passed; runtime-404 stage was environment-blocked by `listen(127.0.0.1)` `EPERM`.
- Focused ESLint for every changed Admin TS/TSX file: **PASS** using the already installed cached toolchain. A full Admin typecheck could not be rerun because Admin dependencies are absent and an isolated offline reconstruction could not complete without unavailable package-store/network access. The earlier audited Admin baseline remains 42/42 with clean build/lint/typecheck, but it is not evidence for these new source edits.

## Gate 3 decision

| Criterion | Evidence | Decision |
|---|---|---|
| Production-like end-to-end submission | Earlier live rows and repository path exist; final disposable E2E not run | PARTIAL |
| Duplicate and spam handling | Rate/bot controls plus exact-retry suppression are prepared locally; 13-assertion dedupe pgTAP has no disposable execution | PARTIAL |
| Lead visible in Admin/CRM | Pipeline-aware Admin plus a safe unread/acknowledged inbox align locally; migrations have no disposable apply or deployment | PARTIAL |
| Consent-aware analytics | Property-free start and receipt-backed submit are ready locally behind an unapplied migration; pilot request remains blocked pending offer approval | PARTIAL |
| Sponsorship separate from editorial | Disabled-by-default catalogue and exclusions tested | GO locally |
| Critical results cannot be paid upward | Explicit excluded surfaces and organic ordering safeguards | GO locally |
| Demo is visibly sample data | Explicit labels and tests | GO locally |
| Owner approved public copy and pricing | No approval record | NO |

**NO-GO for Gate 3, deployment, public pilot offer, CRM write, outreach or payment.**

## Next smallest useful action

Answer the consolidated choices in `MONETIZATION_OWNER_APPROVAL_PACKET_2026-08-18.md`: pilot promise/price posture, route IA/copy, design source, review owners and disposable-runtime permission. Separately after explicit approval, rehearse all five pending Supabase migrations and their 81 pgTAP assertions on a disposable database. Do not repurpose the advertising form or apply production DDL silently.
