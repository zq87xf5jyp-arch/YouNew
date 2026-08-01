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
2. Redeploy the last known-good retained OpenAI Sites version recorded in the release report.
3. Purge CDN/cache and verify homepage, 404, service worker, assets and headers.
4. Keep business/feedback status degraded until their end-to-end path is reverified.

Public static rollback does not roll back Supabase data.

Do not execute a live rollback merely as a rehearsal: it changes production and requires an incident trigger or explicit owner authorization and a verified prior Sites version.

## Admin Dashboard

1. Stop the failed Hostinger deployment and preserve its logs and ZIP checksum.
2. Reactivate the retained last known-good deployment or upload the verified rollback ZIP recorded in the release report.
3. Verify anonymous login redirect, owner navigation, protected API denial and health endpoints.
4. Keep mutating operations disabled until authorization and database connectivity are reverified.

Do not use a Hostinger filesystem restore to roll back Supabase data.

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

A whole-database restore is a last-resort incident action because it can discard valid writes made after the backup. It requires owner approval, a measured recovery point, a maintenance window and a successful isolated rehearsal of the exact encrypted archive.

First verify the encrypted archive checksum against its manifest and run the repository rehearsal against an isolated local Supabase/PostgreSQL target:

```bash
BACKUP_ARCHIVE='absolute-backup-file.dump.age' \
AGE_IDENTITY_FILE='absolute-age-identity-file' \
RESTORE_REPORT_PATH='absolute-restore-verification.json' \
  pnpm --dir admin-dashboard restore:rehearsal
```

Only during an approved incident window, restore the same age-encrypted logical SQL stream to the secure recovery target:

```bash
age --decrypt --identity 'absolute-age-identity-file' 'absolute-backup-file.dump.age' | \
  psql --dbname 'secure-target-database-url' --single-transaction --set ON_ERROR_STOP=1
```

Never paste the database URL into tickets or repository files.

## Content

- Retire or supersede a bad record with a new immutable overlay.
- Restore the prior release head and regenerate all three destinations: iOS runtime, public projection and Admin runtime.
- Compare fingerprints before deployment.
- Do not edit an accepted release in place.

## Closeout

Record incident start/end, component, prior and failed SHA/fingerprint, data-loss assessment, security assessment, operator, verification results and follow-up owner.
