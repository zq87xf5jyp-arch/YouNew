# YouNew production go/no-go

Decision date: 23 October 2026  
Current state: **local PRE-DEPLOY PASS / production NO-GO pending owner authorisation**

## Decision rule

Production can be authorised only when every pre-deploy gate is green and a named owner accepts the exact release candidate, deployment window and rollback responsibility. No script in this phase grants that permission.

## Completed pre-deploy gates

- [x] Exact 170-record stale baseline reconciled.
- [x] 170/170 stale Amsterdam records fail closed in public output; no source row deleted.
- [x] No stale record is used in public organisation pages or SEO output.
- [x] Full disposable migration chain succeeds without modifying historical source migrations.
- [x] 404 pgTAP tests and the focused 392-test suite pass; database lint clean.
- [x] RLS, grants, function execution boundaries and negative client cases tested.
- [x] Real local Edge HTTP round trip saves NL and EN applications.
- [x] Consent evidence and PII-minimised notification payload verified.
- [x] Encrypted backup restored into a fresh isolated database and managed boundaries compared.
- [x] Public and admin builds, tests, lint and typecheck pass.
- [x] Canonical, hreflang, robots, sitemap, 404 and internal-link QA pass.
- [x] Mobile visual QA completed; discovered overlap fixed and rechecked.
- [x] Public package security scan finds no known secret signature.
- [x] Production database unchanged; no deployment and no outreach performed.

## Conditions that still block the deployment action

- [ ] Explicit written owner authorisation for production publication.
- [ ] Freeze the exact commit and artifact hashes selected for deployment.
- [ ] Confirm production environment variable ownership and secret rotation procedure.
- [ ] Take a timestamped production backup and calculate the resulting RPO.
- [ ] Inventory/copy Storage object payloads separately from the database backup.
- [ ] Assign deployment operator, monitoring owner, rollback operator and maintenance window.

## Immediately after an authorised deployment

- [ ] Verify homepage, NL homepage, search, five city guides, robots, sitemap and real 404 over production HTTPS.
- [ ] Submit one synthetic EN and one synthetic NL application and confirm persistence/notification, then purge the synthetic data.
- [ ] Check analytics remains consent-gated and contains no raw contact fields, email, phone or free text.
- [ ] Inspect server/Edge errors and database health at 15 minutes, two hours and 24 hours.
- [ ] Request sitemap processing in Search Console; record status without claiming indexing before Google reports it.
- [ ] Roll back if migrations, application persistence, consent boundaries, public freshness filtering or canonical mapping fail.

## Rollback trigger and sequence

Trigger rollback for any failed migration, missing application persistence, exposed stale record, material RLS/secret issue, canonical loop, widespread 5xx or unrecoverable static package mismatch.

1. Stop new deployment traffic and keep the previous static package available.
2. Restore the previous public package or hosting release.
3. If the database changed, use the deployment-specific backup and its hash-bound managed-boundary companion; do not use the local synthetic rehearsal dump as production data.
4. Re-deploy the previous Edge function bundle and verify the previous schema/function contract.
5. Run smoke, form and permission checks before reopening.
6. Record incident timestamps, data-loss window, affected requests and recovery evidence.

## Final verdict

The release candidate is ready for the owner to make a separate production decision. It is not authorised for publication by this document.
