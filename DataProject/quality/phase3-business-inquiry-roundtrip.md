# Phase 3 business inquiry persistence evidence

Date: 2026-10-23  
Environment: disposable local Supabase database; no production or staging project was changed.

## Verified path

The reviewed Dutch local-business route `/nl/voor-bedrijven/aanmelden/` was submitted directly through `public.submit_business_inquiry(jsonb, text)` with a synthetic, non-deliverable contact record and the optional non-binding Business/Premium interest marker.

Observed result:

- receipt: `YNI-0A0D49C82CCF`
- created at: `2026-10-23 17:16:35.307986+00`
- stored inquiry rows: `1`
- matching privacy-safe notification rows: `1`
- readback confirmed `offer_interest = 'other'`
- readback confirmed `source_page = '/nl/voor-bedrijven/aanmelden/'`
- consent and accuracy confirmations were persisted

The synthetic transaction used an `example.invalid` address and did not send email.

## Database tests

- existing business inquiry pipeline: 19/19 passed
- duplicate and retry behavior: 13/13 passed
- notification behavior: 18/18 passed
- EN/NL local-route alignment: 7/7 passed

The new migration expands the database constraint and the server-owned RPC allowlist to the already reviewed EN and NL local-business routes. It preserves existing rows and receipts.

## Remaining limitation

The complete disposable migration chain is not green. The unmodified chain stops first on local role portability in `20260819173000_harden_public_relation_privileges.sql`; after isolating that local-only role issue, a later sandbox probe expects a `test_policy_required` fixture that is absent from the disposable baseline. The local route migration and its direct dependencies were tested, but production migration remains blocked until the entire exact chain passes without a generated-runtime workaround.

