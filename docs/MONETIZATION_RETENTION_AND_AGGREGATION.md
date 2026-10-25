# Monetization retention and aggregate-report operations

Date: 2026-08-19  
Status: local pre-production candidate; **not applied to production**

Migration:
`20260818235619_enforce_monetization_retention_and_private_reports.sql`.

## Default retention contract

| Policy key | Default | Storage behavior |
|---|---:|---|
| `unfinished_applications` | 30 days | Submitted leads explicitly classified `unfinished`; browser drafts are not persisted |
| `unconfirmed_spam_leads` | 90 days | Leads explicitly classified `unconfirmed` or `spam` |
| `lost_archived_leads` | 365 days | Lost/archived leads excluding protected contract records |
| `admin_notifications` | 90 days | PII-minimised internal inbox rows |
| `raw_usage_events` | 90 days | Web/app sessions/events and pilot usage events |
| `anonymized_aggregate_reports` | 730 days | Aggregate pilot-report snapshots |
| `temporary_csv_exports` | 30 days maximum | Application streams CSV and does not persist it; authorized temporary copies must be deleted externally |
| `technical_logs_no_pii` | 30 days | Provider-controlled; application audit records zero database deletions for this policy |

Contracts, invoices and statutory accounting documents are outside this cleanup.
Won leads and `contract_record` rows are never selected by the automated lead
policies.

## Security boundary

- Policy, hold, cleanup-audit and pilot-usage/report tables are in `private`.
- RLS is enabled on every new table.
- `anon` and `authenticated` receive no table or function access.
- `service_role` is the only application role allowed to configure, clean,
  generate or export.
- Cleanup runs with an advisory transaction lock so schedules cannot overlap.
- Deletion audit contains run ID, policy, cutoff and counts only—never a deleted
  ID, email, phone, name, message or payload.

## Dry-run and scheduled cleanup

After an independently approved production migration, the owner or an authorized
service boundary first runs:

```sql
select *
from private.run_retention_cleanup(
  p_dry_run := true,
  p_reference_at := statement_timestamp()
);
```

Review each `eligible_count`, legal hold, contract exclusion and cutoff. A dry run
records count-only evidence and deletes nothing. Production cleanup remains
blocked until that review is accepted.

The migration registers one `pg_cron` job named
`younew-monetization-retention-cleanup` for `17 3 * * *` UTC:

```sql
select * from private.run_retention_cleanup(false);
```

Supabase documents Cron as a `pg_cron` integration and recommends keeping jobs
short and limiting concurrency. The owner should alert on a run that remains
`running`, fails to produce eight audit rows, or deletes an unexpected count.

## Changing a period

Use the controlled function; direct browser access is unavailable:

```sql
select private.set_retention_days(
  p_policy_key := 'lost_archived_leads',
  p_retention_days := 365
);
```

Database constraints impose reviewed minimum/maximum bounds. Every change needs:

1. owner and privacy/legal rationale;
2. public notice/DPA comparison;
3. disposable dry-run and boundary tests;
4. change ticket/date/approver outside the database;
5. production dry-run evidence before the next non-dry run.

## Legal holds

An authorized administrator may create a hold only for:

- `litigation`;
- `regulatory`;
- `security_incident`;
- `data_subject_request`;
- `contractual`.

Supported resources are business inquiries/notifications, app events/sessions,
pilot usage events and aggregate reports. A hold requires a future `hold_until`;
release is explicit. The cleanup checks both a lead and its linked notification
holds before deleting the lead. Holds must be narrowly scoped and reviewed on a
calendar; they are not a way to disable retention indefinitely.

## Aggregate pilot reports

Raw pilot events accept only:

- internal `client_scope_id`;
- SHA-256 pseudonymous `subject_token_hash`;
- `route_opened`, `step_completed`, `official_source_opened` or `search_used`;
- event time, consent version/granted state and sample flag.

No email, phone, name, IP, user ID, free text, individual timeline,
partner/sponsor field or arbitrary property object exists in the table.

Generate one client-scoped report through the service boundary:

```sql
select public.generate_pilot_usage_report(
  p_client_scope_id := '<approved-client-scope-uuid>',
  p_period_start := date '2026-08-19',
  p_period_end := date '2026-11-17',
  p_sample_data := false
);
```

The period cannot exceed 92 days. Real and sample events are selected separately.
A `(date, event)` segment is stored only when it contains at least five events
**and** five distinct subject tokens. Other segments are omitted and only their
number is retained.

Export by report ID:

```sql
select public.export_pilot_usage_report('<report-uuid>');
```

The JSON contains data label, period, minimum cohort, suppression statement and
eligible aggregate segments. It excludes the internal client scope and every
individual identifier. Expired reports fail closed. Demo reports are labelled
`sample data`; real/sample and different clients cannot be combined.

## Verification evidence

Disposable PostgreSQL 17.6 result on 2026-08-19:

- core monetization pgTAP: **81/81 PASS**;
- retention boundaries/legal holds/audit/configuration: **35/35 PASS**;
- aggregation/consent/client isolation/suppression/export privacy: **32/32 PASS**;
- combined database assertions: **148/148 PASS**;
- `public,private` schema lint: **PASS**.

The synthetic retention test proves the 30/90/365-day boundaries, exact-boundary
preservation, won-record exclusion, three hold types, dry-run no-deletion behavior,
count reconciliation and configuration range. The report test proves cohort
suppression, client/sample isolation and absence of PII/IDs/free text in export.

## Operational stop conditions

Stop cleanup/report generation and set the release status to NO-GO if:

- any expected pgTAP or schema lint fails;
- a dry-run selects a won/contract/accounting record;
- a hold is ignored;
- counts do not reconcile;
- browser roles gain private access;
- an exported key/value contains a client/individual identifier or free text;
- a cohort under five is present;
- a report combines customers or sample/real data;
- production schema differs from the pinned migration manifest.

Any corrective database change is a reviewed forward migration. Do not drop
tables, weaken RLS or run a destructive production restore as an automatic
rollback.
