# Existing weekly maintenance read stage

Integrated local source for the existing Monday `younew-2` owner report. No schedule is created. No finance file, credential, RPC scope, provider or runtime is changed by this module. Canonical integration is complete; root owns native amendment and separate real acceptance.

## Invocation from the canonical source

Use the existing Node24 executable:

```sh
'/Users/ivan/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node' '/Users/ivan/Library/Mobile Documents/com~apple~CloudDocs/все проекты/YouNew-Ecosystem/02-Product/admin-dashboard/scripts/maintenance/cli.mjs' --collect-public --automation-id younew-2 --trigger heartbeat --output '/Users/ivan/YouNew-Local-2026-09-18/operations-growth-20260919/operations/sync-workflow/automation-followup/output'
```

Optional `--sources /absolute/path/AGGREGATE_INPUT.json` reads an explicitly prepared dated envelope. Missing/unusable input yields unknown, never zeros. Supply a fresh immutable input path only after the existing task performs the fixed approved read through an available MCP connector; this CLI does not invoke MCP, find credentials or expand finance's service-role scope. Root's `aggregate-input.mjs --print-query` prints the fixed query. `--evidence /absolute/raw.json --output /absolute/new-envelope.json` validates its receipt and writes a new exclusive file; it performs no provider call. Hashes prove byte consistency, not provider authenticity.

For root's separate manual acceptance use `--trigger manual --manual-key manual-<unique-label>` instead of heartbeat. Logical weekly keys use automation ID + Monday Amsterdam date. They are not native execution IDs. `--native-run-id` is optional and only accepts a real supplied execution ID; absent is null. Non-Monday heartbeat collection is refused. No current run is marked scheduled by this CLI; external execution readback is a separate fact.

Default exports `run()` disabled unless `enabled:true`; CLI requires explicit `--collect-public`. An `output/DISABLED` marker stops CLI before sources/network. Existing `.maintenance.lock` returns locked; never automatically remove another owner's lock. Exit 0 = observed, 2 = partial, 3 = disabled/locked, 1 = failed closed. A partial report is useful and should be read, not silently discarded.

## Output and retry boundary

Read the returned `directory` first: `MAINTENANCE_REPORT.json`, `.md`, immutable hash `RECEIPT.json`. `LATEST.json` advances atomically; retry after a receipt commit/pointer failure repairs the pointer without another GET. Older replay never rewinds a newer pointer. Same logical key/context returns the existing receipt without another source attempt or receipt. Different week/native context, malformed/future-dated prior state, hash mismatch, incomplete receipt and corrupt pointer fail closed. A new manual key represents a deliberate new attempt; never invent one to defeat weekly dedupe.

Five fixed HTTPS GET targets only: homepage, `/start/`, `/essentials/housing-and-renting/`, Admin `/api/public/content-sync`, Admin `/api/mobile/sync`. No authenticated endpoints, callbacks or mutation methods. DNS answers must all be public; connection pins the chosen public IP with original hostname TLS verification. Redirects ≤2, restricted to the exact target origin/path with no query/fragment; maximum 2 MiB body. At most 3 attempts per target/source for 408/500/502/503/504 or transient transport/timeout, global 30s deadline and 5s per attempt. 401/402/403/429 and other terminal results do not retry. DNS work may finish in the background after timeout, but no subsequent request is started; awaited work remains bounded. Count here means top-level attempts; each may contain at most 3 HTTP hops. Bodies are discarded after semantic validation; only safe counts/fingerprints persist.

HTML requires YouNew identity, exact canonical route and no login/soft404 title. This is HTTP identity, not a browser journey. API200 must match the source contract; unavailable feed with zero records is valid empty availability, not publication. Mobile API describes a packaged static artifact. Candidate success, active feed and installed/public client delivery remain separate.

## Optional source contract

`schemaVersion:1,sources:{taskKey:...}`; allowed keys: broken_links, aging_content_queue, feedback_intake, website_app_sync, backup_restore, weekly_owner_report. Each source supplies schemaVersion/taskKey/sourceId/evidenceAt/result, optional source job attempt/success/schedule dates and real run ID/attempt, fixed non-PII counters, plus `sourceEvidence:{path,sha256}`. Full accepted example is root's dated `root-integration/AGGREGATE_INPUT_FINAL.json`. No arbitrary text, customer/order IDs or source body copied. Missing source access stays unknown. Past success/source identity survives unavailable/malformed reads; success of a fresh read never becomes success of an old CI/job. Source counts may include owner/synthetic QA and are not users. Trust denominator covers operational governance records only.

Optional CI/backup/feedback sources are injected dated inputs, not new provider integrations. Unconfigured adapters remain unknown. Current supplied root aggregate uses the existing fixed Supabase read; finance is untouched. Known Arrival404, SMTP535 and Sites/GitHub403 remain existing evidence; these denied operations are never repeated by this collector.

## Delivery and acceptance

Every receipt says prepared_not_sent / deliveryState not_confirmed / notificationSent false. This tool contains no sender and cannot deduplicate effects it does not perform. Native prompt must separately check task history before an owner-message retry and hold if history is unavailable. This stage does not create aging tasks, verify advice, publish candidates, run backups, synchronize banks, upload Admin snapshots or establish recurring success.

The 26 portable targeted tests exercise actual exported runner/transport logic using injected safe synthetic responses and temporary private files. The original candidate's separate saved-MCP aggregate case remains in its historical 27-test receipt outside this repository. No external requests from tests. Root's actual public CLI acceptance and the first real Monday run are distinct later evidence; no automatic operation is claimed here.
