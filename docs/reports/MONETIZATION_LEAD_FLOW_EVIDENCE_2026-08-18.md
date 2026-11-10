# Monetization lead-flow evidence

Date: 2026-08-18  
Scope: local source and static package only  
External messages, production writes, payments and real lead submissions: none

## End-to-end contract

```text
/partners/apply
  → browser + Edge validation
  → service-role-only submit_business_inquiry RPC
  → exact-retry suppression / new lead row
  → one PII-minimised Admin inbox notification
  → new → qualified → discovery → proposal → won/lost → archived
  → owner/admin CSV export
```

## Evidence by step

| Step | Implemented control | Verification |
|---|---|---|
| Form intent | `offerInterest=onboarding_pilot`, mandatory contact role, canonical source `/partners/apply/` | Public contract tests PASS |
| Consent and accuracy | Both confirmations required; form warns not to enter employee or sensitive data | Browser and Edge validators align |
| Bot/rate defense | Honeypot plus server-side bounded rate key/window | Edge and pgTAP contracts authored |
| Stored receipt | Success is shown only after a valid server receipt; session storage contains only receipt ID and timestamp | Public repository/form tests PASS |
| Duplicate handling | Identical submissions within 15 minutes serialize under a transaction advisory lock and return the original safe receipt; no extra PII fingerprint is stored | Admin contract tests PASS; runtime pgTAP pending |
| New-lead notification | After-insert trigger creates one internal notification containing only inquiry ID and safe reference code | Admin contract tests PASS; runtime pgTAP pending |
| Pipeline | Seven owner-approved stages; `lost` requires a controlled reason; `won` requires evidence type and non-future date | Admin action and SQL contract tests PASS |
| Audit | Status/offer/outcome changes record controlled metadata, excluding contact data, free-form loss detail and notes | Static SQL contract PASS |
| Analytics | `lead_start`, `lead_submit`, `pilot_request` accept no properties; submit/request occur only after stored receipt | Public/Admin contract tests PASS; runtime pgTAP pending |
| CSV | Owner/admin only, 1,000-row cap, `no-store`, no message or internal notes, quotes escaped and spreadsheet formulas neutralized | Dedicated unit test PASS |

## Current test evidence

- Admin unit/contract suite: **59/59 PASS**.
- Full public suite: **157/157 PASS**.
- Public offer/routing tests: **7/7 PASS** after the noindex addition.
- Migration manifest: PASS.
- Exactly 81 migration-specific pgTAP assertions: statically confirmed.
- Disposable database: not available locally; runtime assertions are not claimed.

## Honest limitations

- No real lead was created because production and external systems are outside the approved boundary.
- No external email/webhook notification exists; the required notification is the internal Admin inbox only.
- CSV download was tested as code, not through an authenticated production browser session.
- Database behavior remains unproven until the disposable CI/local stack runs all 81 assertions.
