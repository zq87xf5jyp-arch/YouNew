# Website analytics on Hostinger

New website analytics uses the same-origin `/api/analytics-ingest.php` endpoint and private PHP 8.3/SQLite storage on the existing Hostinger plan. It requires visitor consent. No API key, Supabase connection, paid add-on, email or cloud build is needed.

## Review
In Hostinger File Manager, open `younew-private/analytics-data/report.json`. It contains daily browser-tab session and page-view counts, broad page sections, event counts, search result/zero-result metrics and average time to the first action. Daily sessions are not unique people. Only consenting visitors contribute; bots, synthetic checks and network failures can affect counts. The legacy admin analytics screen still shows historical Supabase data, which was not migrated or modified.

The database, report, keyed hashing salt and snapshots remain outside `public_html`, with owner-only permissions. There is no public report/read endpoint. The service never retains IP addresses, user agents, raw UUIDs, full page paths, search phrases, selected profile/location filters or form content. Browser identifiers become daily keyed hashes on the server. One-minute abuse counters use keyed hashes. Hostinger technical access logs are independent of this analytics database.

## Maintenance
Place `analytics-v1` and `analytics-data` inside `younew-private`, beside the existing `forms-v1` and `forms-data`. Do not replace form data.

Hostinger Cron Jobs PHP command (every five minutes):
`/usr/bin/php <domain-root>/younew-private/analytics-v1/maintenance.php`

The CLI-only job removes analytics older than 89 days, expires rate counters and rebuilds the report. A consistent SQLite snapshot refreshes at most once per 24 hours, keeping an additional one-day margin within the 90-day event/snapshot window. Verify `lastMaintenance` advances in the report. If the job fails, repair it before claiming scheduled retention. Hostinger hosting backups have their own expiration schedule; run maintenance after any restore before resuming reporting. A same-server snapshot is not an independent disaster backup.

The service bounds batches to 20 events/64 KiB, uses exact-origin validation, validates the complete batch atomically, deduplicates event IDs, caps network and session rates, and stops at 300,000 retained events. A client failure never blocks the visitor's primary action. Valid Origin is not bot authentication; counts are operational indicators, not billing evidence.

## Recovery
Frontend rollback: rename the current public folder aside and restore the saved previous public folder. The previous frontend sends analytics to Supabase; it restores that dependency. Keep both production data directories intact. Backend rollback must preserve the private database and schema. Never restore a QA database into production. Download private snapshots only to trusted owner-only local storage and verify SQLite integrity before use.

`tests.php` creates and cleans only isolated synthetic temporary storage. Temporary authenticated web QA uses `analytics-qa-data`, not production, and is excluded from the final public release.
