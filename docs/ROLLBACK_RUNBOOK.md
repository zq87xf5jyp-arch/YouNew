# YouNew rollback runbook

Rollback is component-specific. Prefer the smallest reversible action that restores service.

## Trigger conditions

- public navigation, assets or offline shell fail after deployment;
- public forms lose data, expose data or return false success;
- Admin authorization permits an unapproved user;
- migration causes integrity, RLS or performance regression;
- content fingerprint differs from the reviewed artifact.

## Public website

1. Stop further uploads and preserve the failed artifact and logs.
2. Use the verified Hostinger backup/restore control or re-upload the last known-good static artifact to the same document root, including `.htaccess` and `.well-known`.
3. Purge CDN/cache and verify homepage, 404, service worker, assets and headers.
4. Keep business/feedback status degraded until their end-to-end path is reverified.

Public static rollback does not roll back Supabase data.

The current manual Hostinger backup was created 2026-07-28 12:34 and its `domains/younew.nl/public_html` contents were inspected. Do not execute a live restore merely as a rehearsal: it overwrites production and requires an incident trigger or explicit owner authorization and a verified recovery point.

## Edge Functions

1. Disable the affected UI entry point or status-label the service degraded.
2. Deploy the previous reviewed function bundle from its recorded commit SHA.
3. Verify invalid payload denial, CORS, rate limiting and one controlled request.
4. Preserve failed-request logs without copying PII into the incident record.

## Database

Do not reverse a production migration by dropping tables, columns or history.

1. Block the affected write path.
2. Capture current database state and incident timestamps.
3. Create and review a forward-only compensating migration.
4. Dry-run in an isolated/staging database where available.
5. Apply the compensating migration and re-run RLS/integrity checks.

A whole-database restore is a last-resort incident action because it can discard valid writes made after the backup. It requires owner approval, a measured recovery point, a maintenance window and a tested restore command:

```bash
pg_restore --list 'absolute-backup-file.dump'
pg_restore --clean --if-exists --no-owner --no-acl --dbname 'secure-target-database-url' 'absolute-backup-file.dump'
```

Never paste the database URL into tickets or repository files.

## Content

- Retire or supersede a bad record with a new immutable overlay.
- Restore the prior release head and regenerate all three destinations: iOS runtime, public projection and Admin runtime.
- Compare fingerprints before deployment.
- Do not edit an accepted release in place.

## Closeout

Record incident start/end, component, prior and failed SHA/fingerprint, data-loss assessment, security assessment, operator, verification results and follow-up owner.
