# Financial reconciliation and weekly owner report

This continues the existing Admin finance schema and report engine. It reads provider evidence and writes private artifacts. It cannot create a payment, change billing settings, issue a refund, grant access, send a report or schedule itself.

Run with Node 24 from `admin-dashboard`:

```sh
node scripts/finance-reconcile.mjs /private/config.json /private/finance-output
node --test scripts/finance/test-reconcile.mjs
node --test scripts/finance/test-commerce-diagnostics.mjs
```

An optional third argument is the UTC date ending the seven-day reporting window, exclusive. Without it, the last seven completed UTC days are used. The weekly window can cross calendar months. Current or historical monthly totals are never assigned to a week without dated evidence.

The private config has `enabled` (default disabled), absolute `accountingSnapshotPath`, absolute `paymentScopePath`, and optional absolute `accountingJournalPath`. Set `enabled:false` to stop future calls without deleting receipts. A missing provider or accounting source creates an explicit incomplete report with unknown totals; CLI exit 2 signals attention. Disabled/locked calls do not contact a provider. A stale lock requires checking its recorded process before removal; it is never broken automatically.

`accountingSnapshotPath` uses the unchanged `src/lib/finance/report.ts` schema. `paymentScopePath` is a trusted local export from the YouNew order executor, never browser input:

```json
{
  "accountId": "acct_REPLACE",
  "environment": "sandbox",
  "payments": [{ "paymentIntentId": "pi_REPLACE", "source": "younew-primary" }],
  "evidence": "Reviewed YouNew commerce ledger export reference"
}
```

The finance key is supplied separately as `YOUNEW_STRIPE_FINANCE_READ_KEY`. Only a restricted `rk_test_...` or `rk_live_...` key matching the scope is accepted. It needs read access to its own account, PaymentIntents/expanded charges, refunds and balance transactions. No write permission is needed. The fixed API host and GET-only endpoint allowlist prevent unrelated network destinations; only the approved YouNew PaymentIntents are read, excluding other products sharing the account. Do not store a key in config, Git or logs.

The implemented commerce exporter is `node services/digital-commerce/maintenance.mjs finance-scope /private/commerce.sqlite /private/payment-scope.json`. It reads the selected durable database and excludes subject/email data. Refresh this scope before reconciliation on the same approved host. A synthetic database is not a source of real receipts; the private production database must be identified before wiring a scheduled run.

Provider charge and fee observations become verified rows for their actual dates/currencies. Refunds retain their gross amounts and refund dates in `PROVIDER_OBSERVATIONS.json`; a gross refund is not automatically an ex-VAT refund of earned revenue. No charge becomes revenue, a subscription, a unique customer or a confirmed payout to the bank. A negative fee credit is held for accounting instead of converted to zero. An account/scope mismatch, incomplete or repeated refund pagination, inconsistent refund total, wrong environment or unconfirmed capture fails closed. Pending refunds and disputes create exceptions.

The source scope is not evidence of all-provider completeness, so the adapter never creates financial coverage. Dated reviewed accounting entries can supply accruals, expenses, bank matches, purchase/renewal/cancellation counts and owner minutes. That optional journal is:

```text
version: 1
checkedAt: UTC ISO timestamp
entries: existing finance row fields plus occurredAt (UTC); row.month must match that date
coverage: [{start: UTC inclusive, end: UTC exclusive, currency, metric, evidence}]
```

Journal entries reuse the strict finance row validator. Coverage must end before its review timestamp. An interval must cover the complete report window before the engine treats missing rows as confirmed zero. Fresh provider rows not matched in that journal invalidate that metric's coverage; they do not invent completeness. Open-month coverage and subscription/customer snapshots from an earlier monthly review are not carried forward under a new check timestamp. Original reviewed inputs remain in the receipt folder.

Each request has a 10-second timeout, a total provider budget of 120 seconds, at most two retries, and a 100-payment / five-refund-page-per-payment cap. Authentication failures are not retried. Long provider Retry-After limits defer work instead of being ignored. No raw provider body, headers, key, customer identity or email is written to the report.

An exclusive file lock serializes a single private output root. Every enabled run attempts a current read. The same exact attempt and facts reuse an immutable receipt after hash verification; a later attempt creates a new dated receipt even if amounts did not change. After receipt validation, `CURRENT_FINANCE_SNAPSHOT.json` is replaced atomically and can be mounted once as `YOUNEW_FINANCE_SNAPSHOT_PATH` for the protected Admin. `LATEST.json` records this stable `snapshotPath` plus its immutable `receiptSnapshotPath`. Receipt files are owner-readable only. `runs.jsonl` and `exceptions.jsonl` contain actual outcomes. Prior receipts and manual source files are never overwritten. Customer delivery is always `prepared_not_sent`.

The report and existing Admin observations distinguish report attempt/completion, original accounting review, and the last successful completed collection for each source. Only a complete bound Stripe scope read or both validated commerce RPC reads advance that source's success timestamp. Partial/unavailable reads retain a previous success only from an integrity-verified immutable report for the same source, account and environment; they never carry prior counters forward as current. Older receipts without this evidence leave the timestamp unknown. Disabled diagnostics have no attempt timestamp. This is collection success, not complete accounting, bank settlement, sandbox lifecycle success, or worker execution. A separately reviewed full-flow sandbox receipt belongs in accounting-source observations with its own event time; it must not create live financial rows.

No scheduler is created by this script. The approved existing executor can run this command weekly and inspect exit status/logs. Its notification delivery and mounted private inputs must be tested on that host. Missing credentials, the scoped order export, dated accounting/bank evidence, or a scheduled runner remain explicit blockers; this script alone is not background automation.

Optional commerce diagnostics use the same private weekly report and protected Admin snapshot. The private config must explicitly opt in; omission or `enabled:false` makes no commerce calls:

```json
{
  "commerceDiagnostics": {
    "enabled": false,
    "origin": "https://pgdzdxsiagfjioxwuqxf.supabase.co",
    "expectedAccountId": "acct_REPLACE",
    "environment": "sandbox"
  }
}
```

For the approved executor, supply `YOUNEW_COMMERCE_DIAGNOSTICS_SERVICE_ROLE_KEY` only through its private environment. This is a **broad service-role credential**, not a restricted read-only key. The collector itself hardcodes only the read actions `finance_scope` and `diagnostics` at that exact project's `/rest/v1/rpc/arrival_commerce_command`; it cannot accept a caller-supplied action, body or destination. The supported legacy JWT must identify that project and the `service_role`; anon JWTs, another project and opaque keys fail closed. The server still verifies the credential. No secret belongs in config, a receipt, a browser or Git.

The two RPC responses bind counters to the expected Stripe account/environment. The reader has a 6-second request limit, a 20-second total budget, at most two bounded retries for transient failures, and a 1 MB response limit. Permanent authentication failures and long Retry-After delays are not retried. Exceptions created during the reads are compared against the completed collection timestamp, not its start. Future-dated evidence is rejected.

`COMMERCE_DIAGNOSTICS.json` is a sixth immutable receipt file. The weekly report and Admin observation show payment inbox pending/retry/processing, payment dead letters, notification dead letters and grouped unresolved owner exception codes. Customer, order, event and PaymentIntent identifiers are omitted. These counters never become financial rows or coverage. Source failure replaces current counters with unknown, while preserving old receipt folders. An observed snapshot includes its timestamp and a 15-minute freshness limit; expired evidence must be labeled stale, never relabeled current.

The present server contract has **no worker execution/last-success timestamps and no pending-notification count**. Both stay UNKNOWN, including when every observed counter is zero. A fresh read proves a queue snapshot only. Dead letters and owner exceptions add owner-action decisions to the report; a pending count alone does not prove delay. Connecting timestamped worker evidence, scheduled collection, actual notification delivery and operational response remains required before unattended service. No database migration or worker modification was introduced here.

Diagnostics acceptance imports the existing Unix-socket-only disposable PostgreSQL 17 helper and executes the real migration/RPC state transitions. It then intercepts only the fixed HTTP transport, routes the two reads to the actual local RPC, and produces the real finance report. It does not call hosted Supabase or Stripe. PostgreSQL 17 binaries are required for this scoped test; `ARRIVAL_TEST_PG_BIN` can identify that already-installed local runtime.

Provider field semantics checked 19 September 2026: [PaymentIntent retrieval](https://docs.stripe.com/api/payment_intents/retrieve), [Charge object](https://docs.stripe.com/api/charges/object), [refund pagination](https://docs.stripe.com/api/refunds/list), [balance transaction retrieval](https://docs.stripe.com/api/balance_transactions/retrieve). API version matches the existing payment bridge: `2026-08-26.dahlia`.
