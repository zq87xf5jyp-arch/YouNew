# YouNew deployment runbook

Release target: 2026-07-29, Europe/Amsterdam

No production step in this runbook is authorized until the owner sends the exact instruction `GO LIVE`.

## Preconditions

1. Record the intended commit SHA and confirm the release changes are isolated from unrelated working-tree changes.
2. Require green public predeploy, Admin lint/type/test/build, Deno format/check and CI.
3. Confirm `admin.younew.nl` as the Admin destination on the existing Hostinger Business Web App slot. The plan supports Next.js and Node 24, matching the package engine; the Web App and DNS are not provisioned before `GO LIVE`.
4. Confirm the recorded 2026-07-28 owner acceptance of the current Supabase Free-plan limitations: no leaked-password protection and no managed project backups. This acceptance does not waive the manual backup requirement.
5. Install PostgreSQL client tools and create a fresh encrypted database backup:

```bash
cd admin-dashboard
DATABASE_URL='read-from-secure-secret-store' BACKUP_DIR='absolute-secure-backup-directory' pnpm backup
pg_restore --list 'absolute-backup-file.dump' >/dev/null
```

6. Record the backup path, SHA-256, restore-list result and retention owner. Never commit the dump or connection string.
7. Hostinger manual backup evidence exists for 2026-07-28 12:34 and its `public_html` contents were verified. If production files have changed since that timestamp, create another Hostinger backup immediately before deployment.

### Passwordless temporary backup access

The project database build `17.6.1.147` supports Supabase Temporary access. With explicit owner approval:

1. Enable the Temporary access feature preview.
2. Grant the current project owner `supabase_read_only_user` for the shortest practical period; use `postgres` only if the read-only dump is proven insufficient.
3. Create/use a Personal Access Token without placing it in chat, shell history, logs or repository files.
4. Connect over SSL, write the dump outside the repository with mode `0600`, and run `pg_restore --list`.
5. Record only the path, timestamp, SHA-256 and validation result.
6. Revoke the temporary role grant and PAT immediately after verification.

Do not reset the database password merely to create a backup; the Dashboard confirms that reset would break existing connections.

## Supabase release

Use the reviewed Supabase CLI version and project ref:

```bash
cd admin-dashboard
pnpm dlx supabase@2.109.1 link --project-ref pgdzdxsiagfjioxwuqxf
pnpm dlx supabase@2.109.1 db push --dry-run
```

Review the dry-run against `supabase/migrations/20260728075522_younew_production_operations.sql`. Stop on unexpected destructive SQL or drift.

Create independent random salts of at least 32 bytes in the secure secret manager, then set them without printing their values:

```bash
pnpm dlx supabase@2.109.1 secrets set BUSINESS_INQUIRY_RATE_LIMIT_SALT PUBLIC_FEEDBACK_RATE_LIMIT_SALT --project-ref pgdzdxsiagfjioxwuqxf
pnpm dlx supabase@2.109.1 db push
pnpm dlx supabase@2.109.1 functions deploy submit-business-inquiry --project-ref pgdzdxsiagfjioxwuqxf
pnpm dlx supabase@2.109.1 functions deploy submit-public-feedback --project-ref pgdzdxsiagfjioxwuqxf
pnpm dlx supabase@2.109.1 functions deploy prepare-content-sync --project-ref pgdzdxsiagfjioxwuqxf
```

Post-deploy checks:

- migration is recorded exactly once;
- operational tables have RLS enabled;
- anonymous direct table writes fail;
- one controlled business inquiry returns a receipt and appears in Admin;
- one controlled feedback report returns a receipt and appears in Admin;
- rate-limit and invalid payload tests fail without PII in logs;
- an authenticated owner creates one sync candidate, sees the same fingerprint, and does not activate it automatically.

Remove or clearly label controlled test records after preserving audit evidence.

## Admin Dashboard

Required server environment:

- `NEXT_PUBLIC_SUPABASE_URL`;
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`;
- any hosting-specific server configuration already required by the repository.

Do not add a service-role key to browser-visible variables. Deploy the verified `.next` build only after the hosting target is confirmed. Test sign-in, owner/admin authorization, denial for an unapproved user, business detail/actions/export, feedback, content publication gate, sync candidate and private workspace status.

## Public Hostinger artifact

Build from the recorded SHA:

```bash
cd admin-dashboard/public-site
pnpm predeploy:check
```

Upload the contents of `out/` to the intended Hostinger document root, including dotfiles such as `.htaccess` and `.well-known`. The exact Hostinger automation/API was not available, so the owner must use the existing verified deployment method. Do not merge the folder one level too high.

After upload:

- purge Hostinger/CDN cache;
- verify `/`, `/search/`, `/guides/woon/`, `/map/`, `/business/apply/`, `/support/`, `/privacy/`, `/status/` and a real 404;
- verify `/images/app-map-en.webp` and `/icons/apple-touch-icon.png` return `200` with correct MIME types;
- verify CSP, HSTS, `nosniff`, referrer, frame and permissions headers;
- verify service worker update and offline shell;
- run controlled business and feedback submissions only after Supabase is ready.

## Release evidence

Record:

- commit SHA and branch;
- database backup SHA-256;
- migration version;
- Edge Function deployment versions/timestamps;
- Admin deployment URL and build ID;
- public artifact SHA-256;
- Hostinger deployment timestamp;
- browser viewport results and screenshots;
- final production URLs and remaining issues.
