# Monetization security and privacy checklist

Date: 2026-08-18  
Decision: **PARTIAL / NO-GO production**

| Control | Status | Evidence / remaining action |
|---|---|---|
| No production credentials or real PII in testing | PASS | Local attempts used generated state only; repository security scan passed. |
| Purpose limitation | PASS locally | Form is explicitly for a scoped pilot proposal and states that submission creates no contract, invoice or payment. |
| Data minimisation | PASS locally | No employee data requested; phone optional; UI warns against names, health data and other sensitive employee data. |
| Consent and authority | PASS locally | Privacy consent and submitter-authority confirmations are mandatory in browser, Edge and RPC contracts. |
| Input validation | PASS locally | Lengths, enums, dates, URL, email, KvK, canonical source, offer and role checked at multiple boundaries. |
| Bot and abuse controls | PASS by contract | Honeypot, hashed rate key, five requests/hour and 24-hour rate-state cleanup; runtime proof pending. |
| Duplicate protection | PASS by contract | Fifteen-minute exact retry returns original receipt; no stored PII fingerprint; runtime proof pending. |
| Direct database access | PASS by contract | Submission RPC is service-role-only; anonymous/authenticated grants rejected; runtime RLS/grant proof pending. |
| Admin authorization | PASS locally | Lead management/export limited to approved owner/admin roles; notification reads require approved Admin. |
| Mandatory loss reason / won evidence | PASS locally | UI and DB constraints fail closed; no legacy status is promoted to won. |
| Notification minimisation | PASS by contract | One internal record per new insert with safe reference only; no contact/company/message fields; no external delivery. |
| Analytics minimisation | PASS locally | Lead events are consent-aware and property-free; form fields and receipt IDs are excluded. |
| Browser receipt storage | PASS locally | Only confirmation ID and creation time stored in session storage; no submitted form fields. |
| CSV authorization and minimisation | PASS locally | Owner/admin gate, `no-store`, row cap, no message or internal notes. |
| CSV formula injection | PASS locally | Dangerous spreadsheet prefixes are apostrophe-neutralized; regression test included. |
| Transport/browser policy | PASS static | HTTPS production origin, HSTS, CSP, frame denial, permissions policy, `nosniff`, strict referrer policy. |
| Search indexing | PASS static | Success page is noindex/nofollow; seven legacy business pages are noindex and worker-redirected with 308. |
| Secrets/package scan | PASS | Built static package contains no known secret patterns or local paths. |
| Retention schedule for lead PII | PARTIAL | Operational privacy-request handling exists, but a reviewed lead-retention period and automated deletion/anonymisation job are not evidenced. Define before production launch. |
| Controller/processor and DPA terms | NO-GO | Must be fixed in proposal/contract before an accepted pilot processes employee usage data. |
| Usage-report aggregation threshold | NO-GO | Define minimum cohort/reporting rules so an employer cannot infer individual employee behavior. |
| Data-subject request rehearsal | PARTIAL | Process is documented generally; run a lead-specific access/delete rehearsal in disposable/staging data. |
| Incident response and lead audit review | PARTIAL | Existing operations controls apply; add the lead tables/notification inbox to the release and incident checklist. |
| Disposable database proof | BLOCKED | All 81 pgTAP assertions remain unexecuted because Docker/Postgres is unavailable locally; exact CI fallback is ready. |
| Legal/tax/VAT and invoice model | NO-GO | Manual invoice only; counsel/accounting approval required before contract or invoice. |

## Production blockers

1. 81/81 disposable pgTAP PASS and schema lint PASS.
2. Lead-PII retention period and executable deletion/anonymisation procedure.
3. Controller/processor, DPA and aggregate-reporting rules in the pilot contract.
4. Verified encrypted backup and disposable restore rehearsal.
5. Owner approval for the exact migrations, Edge Function, Admin and public release actions.

