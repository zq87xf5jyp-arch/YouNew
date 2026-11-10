# Supabase monetization migration and rollback plan

Date: 2026-08-18  
Status: prepared only; no production command executed

## Release set

Apply exactly these reviewed migrations, in timestamp order, after disposable proof:

1. `20260818145801_harden_analytics_ingest_windows_rls.sql`
2. `20260818191112_harden_business_inquiry_pipeline.sql`
3. `20260818192423_deduplicate_business_inquiry_submissions.sql`
4. `20260818193310_extend_lead_analytics_funnel.sql`
5. `20260818194626_add_business_inquiry_notification_inbox.sql`

The production manifest records the exact hashes. Stop on any unrecorded file, hash drift, destructive statement, unexpected remote migration, or failed disposable assertion.

## Required preconditions

1. Owner approves the database apply as a separate production action.
2. Disposable result is 81/81 PASS; schema lint is PASS; TAP artifact reviewed.
3. Encrypted logical backup and disposable restore rehearsal are current and recorded by path, SHA-256, status and RTO.
4. New Edge, Admin and public artifacts are built from one recorded Git SHA; a schema-compatible Admin rollback package is available.
5. Lead intake and Admin updates have an announced short maintenance window.
6. Production migration list and dry-run match the manifest using pinned CLI 2.109.1.

## Compatibility-aware deployment order

1. Deploy the updated `submit-business-inquiry` Edge Function first. It sends the new offer/role fields but remains compatible with the current RPC, which ignores additional payload properties.
2. Temporarily stop Admin lead edits. Keep the old public form available only if the new Edge smoke passes.
3. Apply the five migrations once through the managed migration boundary.
4. Deploy the new Admin immediately; the old Admin status controls are not compatible with the new seven-stage constraint.
5. Verify RLS/grants, exact retry, one notification, stages, mandatory lost reason, won evidence and CSV authorization.
6. Deploy the public canonical routes and 308 worker last.
7. Run a controlled synthetic submission only with explicit approval, then remove or label it through the reviewed test-record procedure.

## Rollback strategy

These migrations are intentionally forward-only. Do **not** drop new columns/tables, disable the new RLS protection, or reverse mapped legacy statuses as an automatic rollback; that could lose audit evidence or recreate the security finding.

| Failure point | Safe response |
|---|---|
| Edge deploy before DB | Redeploy the previously recorded Edge version; no schema changed. |
| Migration fails inside its transaction | Stop. Confirm no new remote version was recorded, compare schema/manifest and investigate. Do not retry blindly. |
| Database succeeds, Admin deploy fails | Keep public canonical release stopped, keep lead edits in maintenance mode, retain the compatible new Edge, and deploy the prebuilt schema-compatible Admin rollback/repair artifact. Fix forward; do not redeploy the legacy Admin writer. |
| Admin succeeds, public deploy fails | Retain database, Edge and Admin; legacy `/business/apply/` remains accepted. Restore the previous public artifact/worker and fix the new site forward. |
| Public runtime regression | Restore the previous static/worker artifact; keep the compatible backend. Preserve receipts and audit logs. |
| RLS/grant/security verification fails | Disable public lead intake at the Edge/public routing layer, preserve the database for investigation, and apply a reviewed forward security migration. Never weaken RLS to restore availability. |
| Data integrity issue | Stop writes, preserve logs, restore into a separate environment, reconcile affected rows, and obtain owner approval before any production restore or corrective DML. |

## Post-apply evidence

- exact remote migration versions and hashes;
- 81/81 TAP output and schema lint;
- anonymous/authenticated/service-role RLS and grant matrix;
- one new synthetic receipt, one notification and one exact retry with no second notification;
- status transition negative/positive cases;
- Admin list/detail/export authorization;
- Security and Performance Advisor snapshots;
- Edge/Admin/public release IDs and artifact fingerprints;
- rollback owner, decision time and remaining risks.

No step above grants permission to execute a production action.

