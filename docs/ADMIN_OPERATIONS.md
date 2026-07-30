# YouNew Admin operations

## Roles

| Role | Expected access |
|---|---|
| `owner` | All protected operational views and state transitions |
| `admin` | Operational views and approved transitions |
| other authenticated user | Denied |
| anonymous user | Sign-in only; no operational data |

Role checks exist in both the Next.js application and database/function layer. UI hiding is not authorization.

## Daily checks

- review new business inquiries and feedback;
- review failed or long-running sync jobs;
- confirm latest content candidate fingerprint against the reviewed release;
- inspect service registry/status and the private workspace endpoint;
- watch authentication, RLS and Edge Function error logs without copying PII;
- keep the public status page honest when a backend service is unavailable.

## Business inquiries

- Open the list/detail only from an authenticated Admin session.
- Status and notes changes must be intentional and auditable.
- The PII-safe export omits message, internal note, phone, KvK, budget and other sensitive fields.
- Never place inquiry text or contact data in application logs, GitHub issues or release reports.
- Delete/retention requests are handled through the documented privacy contact and a reviewed database operation.

## Feedback

- Treat reports as untrusted text.
- Verify corrections against official sources before changing content.
- Do not treat support as an emergency channel.
- Keep optional email and message content out of logs and analytics.

## Content and sync

- Publish only after every evidence/mapping/media field passes.
- Generate a candidate artifact through the sync page.
- Compare job state, record count and SHA-256 fingerprint.
- A candidate is not production. Incorporate it into DataProject, rerun gates and deploy through the release runbook.
- Retry with the same idempotency key when the prior result is uncertain.

## Backup and incidents

- Run `pnpm backup` with `DATABASE_URL` supplied by the secure secret store.
- Keep backup files outside the repository with mode `0600` or stricter.
- Validate with `pg_restore --list`.
- For authorization or data-exposure incidents, stop the affected path, preserve evidence, rotate exposed secrets, and follow `docs/ROLLBACK_RUNBOOK.md`.

## Current release limitations

- Eleven migrations and four Edge Functions are present in the connected project. The local `analytics-ingest` correction still requires a clean reviewed release before deployment.
- Authenticated production Admin E2E is not complete.
- Two approved owner profiles exist, but permitted E2E credentials were not supplied.
- `admin.younew.nl` resolves over TLS and redirects anonymous dashboard requests to `/login`; authenticated owner/admin workflows and the unapproved-user denial path remain unverified in production.
- Leaked-password protection and managed project backups are unavailable on the current Free plan. The owner accepted these limitations on 2026-07-28.
- The accepted Free-plan risk does not replace a fresh off-site manual Postgres dump.
- Until an upgrade, use strong unique owner/admin passwords, MFA, minimal approved accounts and authentication-log review as compensating controls.
