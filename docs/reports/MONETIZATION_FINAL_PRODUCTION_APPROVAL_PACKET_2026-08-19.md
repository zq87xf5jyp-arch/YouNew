# Monetization final production approval packet — 2026-08-19

Owner: Ivan Chernikov  
Scope: pre-production validation only  
Production deployment, production migrations, merge, payments and outreach: **not authorized and not performed**

## Decision

**NO-GO for production.**

The local candidate has strong functional and privacy evidence: 81/81 core
pgTAP assertions, 67/67 retention/aggregation assertions, schema lint, Admin,
public and visual checks pass locally. That evidence is not a substitute for the
required independent GitHub runs. Four material gates remain open:

1. the approved branch could not be pushed, so there is no draft PR, Actions URL
   or independently produced artifact;
2. the two approved commits contain the original five migrations and 81 core
   assertions, while the sixth retention/report migration and its 67 assertions
   remain uncommitted and local under the current push boundary;
3. no encrypted logical backup of the current production schema and operational
   data could be created without a database dump credential, and a stricter
   production-shaped reconstruction correctly stopped on production-snapshot
   guard drift;
4. both Admin and public dependency audits return two HIGH advisories.

No result below is described as remote, independent, production-applied or
legally approved unless it actually is.

## 1. GitHub preflight, push and draft PR

### Approved branch identity

| Item | Evidence |
|---|---|
| Branch | `agent/monetization-preprod-validation-2026-08-18` |
| First approved commit | `879f95b` — `Add monetization pre-production validation` |
| Tip approved commit | `174c3c6` — `Complete monetization pre-production release gate` |
| Parent/base | `60accbc` (`origin/main`) |
| History rewrite/force push | None |
| Origin mutation | None; remains `https://github.com/zq87xf5jyp-arch/YouNew.git` |

The approved branch still points exactly at `174c3c6`. Compliance work was done
on local continuation branch
`agent/monetization-compliance-closure-2026-08-19`; it is uncommitted and was not
added to the approved branch.

### Workflows triggered by an approved-branch push

| Workflow | Why it triggers | Permissions / external effect |
|---|---|---|
| `Admin CI` | Any push touching `admin-dashboard/**` | `contents: read`; frozen install, static checks, lint, tests and build only |
| `Monetization Visual Pre-production Verification` | Explicit approved branch and public/Playwright path filters | `contents: read`; local preview and synthetic Playwright data only |
| `Supabase Disposable Verification` | Explicit approved branch and Supabase/test path filters | `contents: read`; local disposable Supabase only |

The push does **not** trigger Product CI, Governance, Data Project Health or
Secret Scan because their push branches are `main`; the secret scanner will run
on the draft PR. Release Journal is tag-only. App Store sync and repository
backup are scheduled/manual and are not branch-push jobs.

Every push-triggered checkout sets `persist-credentials: false`. No triggered job
references a production database secret, calls `supabase link`, `db push`, a
deployment API, Hostinger or Vercel. The preflight therefore found **no path from
this approved branch push to production mutation**.

### Push/PR outcome

- Local HTTPS push could not authenticate; origin and credentials were not changed.
- The GitHub write integration returned `403 Resource not accessible by integration`.
- No bypass, force push, alternate remote or credential modification was attempted.
- Draft PR URL: **unavailable**.
- Actions run URLs and remote artifact URLs: **unavailable**.

Exact owner command, unchanged:

```bash
git push -u origin agent/monetization-preprod-validation-2026-08-18
```

After that succeeds, create a **draft** PR only. Do not merge. The exact approved
branch will independently validate only its five migrations and 81 assertions;
publishing the local compliance closure requires a separate expansion of the
allowed commit scope.

## 2. Verification matrix

| Gate | Result | Evidence boundary |
|---|---:|---|
| Core monetization pgTAP | **81/81 PASS** | Local disposable PostgreSQL 17.6 |
| Retention boundaries/legal hold/audit | **35/35 PASS** | Local-only sixth migration |
| Aggregate-report privacy | **32/32 PASS** | Local-only sixth migration |
| All database assertions | **148/148 PASS** | Local; seven TAP suites |
| Schema lint (`public,private`) | **PASS** | No schema errors |
| Admin TypeScript | **PASS** | Local frozen dependency state |
| Admin ESLint | **PASS** | Local frozen dependency state |
| Admin tests | **64/64 PASS** | Includes five compliance static contracts; exceeds 59/59 baseline |
| Admin production build | **PASS** | 32 routes |
| Public TypeScript | **PASS** | Local frozen dependency state |
| Public ESLint | **PASS** | Local frozen dependency state |
| Public tests | **157/157 PASS** | Local |
| Public production build | **PASS** | 611/611 generated routes |
| Visual Playwright | **6/6 PASS** | Local, 24 screenshots; not independent CI |
| Approved-branch history secret scan | **PASS** | Gitleaks 8.28.0, 157 commits, 39.05 MB, repository ignore baseline applied |
| Compliance delta secret scan | **PASS** | Gitleaks 8.28.0; source delta contains no finding |
| Test-artifact secret scan | **PASS** | Gitleaks 8.28.0; 832.93 KB; no finding |
| Admin dependency audit | **FAIL** | 2 HIGH, 0 critical |
| Public dependency audit | **FAIL** | Same 2 HIGH, 0 critical |
| Independent GitHub CI | **NOT RUN** | Push/PR blocked |

Primary TAP artifact:
[`admin-dashboard/supabase/ci-artifacts/pgtap-results.tap`](../../admin-dashboard/supabase/ci-artifacts/pgtap-results.tap).
Schema lint:
[`compliance-db-lint.log`](../../admin-dashboard/supabase/ci-artifacts/compliance-db-lint.log).

The package and lockfile hashes remained unchanged during the authorized frozen
install and audit:

| File | SHA-256 |
|---|---|
| `admin-dashboard/package.json` | `4c726f9aa87590b742ed9a4b07dab671cbcc57ebd178f88c24543287de8ed97c` |
| `admin-dashboard/pnpm-lock.yaml` | `66ffb06edb7948d7afd24a78425c7ccb1211b6b93953f4e54d42fcd31c0b94bb` |
| `admin-dashboard/public-site/package.json` | `5ea59c7b89098f3755a059fbf2126538219203ca8caa9c63384377d6fc302922` |
| `admin-dashboard/public-site/pnpm-lock.yaml` | `41b651e0fafe72d40458837a3fbb814ebafee9881c472a282eb1ceca41fa569f` |

### Dependency blocker

Both workspaces resolve:

- `js-yaml` 4.3.0: HIGH
  [GHSA-5p4m-2wfm-xmqj](https://github.com/advisories/GHSA-5p4m-2wfm-xmqj),
  patched in 4.3.1;
- `nanoid` 3.3.17: HIGH
  [GHSA-2v37-7h3g-55p8](https://github.com/advisories/GHSA-2v37-7h3g-55p8),
  patched in 3.3.18.

They are transitive build/tooling dependencies, but the owner required any
failed audit to produce NO-GO. No lockfile or version was changed implicitly.
The local workflow
[`monetization-dependency-audit.yml`](../../.github/workflows/monetization-dependency-audit.yml)
uses frozen installs and fails at HIGH severity.

## 3. Visual evidence

The six approved routes were exercised at 1440×900 and 390×844 with synthetic
data. The 24 captures cover initial/business pages, pricing/CTA, empty and
validation-error forms, synthetic filled/submitted form, success state,
navigation focus, partner disclosure and the legacy 308 destination. The suite
also checks horizontal overflow, focus visibility, WCAG contrast, overlaps,
sample-data boundaries and absence of synthetic contact values in analytics.

- [Desktop screenshots](../../admin-dashboard/visual-validation/screenshots/desktop-1440x900/)
- [Mobile screenshots](../../admin-dashboard/visual-validation/screenshots/mobile-390x844/)

Visual verdict: **local PASS / independent-CI evidence missing**. No UI change was
introduced by the local retention/DPA closure, so the existing captures remain
the applicable candidate evidence.

## 4. Migration manifest and dry-run

Production was read-only inventoried at 24 managed versions. Six migrations are
now pinned as pending locally:

| Order | Version | Name | MD5 |
|---:|---|---|---|
| 1 | `20260818145801` | `harden_analytics_ingest_windows_rls` | `e702afeef312705d2a5bc5a8858da0c4` |
| 2 | `20260818191112` | `harden_business_inquiry_pipeline` | `716b6222ca3010e4f385082414169440` |
| 3 | `20260818192423` | `deduplicate_business_inquiry_submissions` | `d3010eb22035a572d0b36a8c522e68a0` |
| 4 | `20260818193310` | `extend_lead_analytics_funnel` | `220bfa6bddd463acb67a86b31bbea285` |
| 5 | `20260818194626` | `add_business_inquiry_notification_inbox` | `e9df9c0cbd8828bbe6cfa26f57c5a295` |
| 6 | `20260818235619` | `enforce_monetization_retention_and_private_reports` | `8f7e418080a080e3204106f344836ee0` |

Manifest verification: **PASS** — 24 applied, 6 pending, 6 historical
bootstrap files. Offline dry-run: **PASS** for byte/hash identity, ordering and
screening for table/schema drops, truncation and dropped columns. No production
connection or credential was used. Evidence:
[`production-migration-dry-run.txt`](../../admin-dashboard/supabase/ci-artifacts/production-migration-dry-run.txt).

The sixth migration is intentionally absent from approved commit `174c3c6`.
Therefore its manifest and workflow changes cannot be represented as published
or independently tested under the current two-commit push authorization.

## 5. Backup and restore evidence

### Read-only production inventory

No PII rows were selected. At `2026-08-19T00:06:25Z`, the connected project
`pgdzdxsiagfjioxwuqxf` reported PostgreSQL 17.6, database size 15,617,171 bytes,
39 public tables, 2 private tables and 24 managed migrations. Safe control counts
were: profiles 2, business inquiries 3, feedback 2, app sessions 107, app events
610 and audit logs 9. All public application tables reported RLS enabled.

This is inventory evidence, **not a backup**.

### Confirmed synthetic mechanics drill

An age-encrypted logical archive containing only deterministic synthetic data was
created and restored into a fresh isolated local Supabase target:

| Measure | Result |
|---|---:|
| Archive | `younew-20260819T003107Z.dump.age` |
| Archive bytes | 335,139 |
| SHA-256 | `b1989e92e4747c28bf91619294093d39aa52d6b1b8d624947b5fb56b664ae486` |
| Backup duration | 24 seconds |
| Fresh-target wall duration | 118 seconds |
| Measured inner restore RTO | 6 seconds |
| Restored operational counts | Exact synthetic fixture match |
| Restored RLS/grants/index checks | PASS |
| Real leads/PII | None |

Evidence:
[`synthetic-restore-drill`](../../admin-dashboard/supabase/ci-artifacts/synthetic-restore-drill/).
The target had zero disabled application-table RLS flags, zero browser grants on
private monetization tables and all six required indexes.

The synthetic source used the fully migrated local candidate while the generic
production restore runbook repaired the target to the current 24-version
production manifest. This proves encryption, checksum, logical restore and
security/count verification mechanics, but it is not a faithful backup of the
current production source.

### Production-shaped drill blocker

A second attempt used historical bootstrap plus only the 24 manifest-managed
files and no pending migration. It stopped at
`20260727170658_harden_rls_and_function_boundaries` with
`Reviewed RLS policy snapshot has drifted`. The immutable guard correctly proves
that the repository bootstrap is not an exact substitute for the live
pre-migration production snapshot. The failure log is
[`production-shape-start.log`](../../admin-dashboard/supabase/ci-artifacts/production-shape-start.log).

No database dump password, temporary read-only connection URL or Management API
backup-export capability was available. Production operational data was not
copied through SQL or CI. Therefore the required **current-production encrypted
backup plus disposable restore drill remains incomplete and blocks production**.

Rollback decision owner: **Ivan Chernikov**. A technical executor may perform a
restore only after the owner identifies the exact backup/PITR point and explicitly
authorizes that production action. Destructive production restore was not run.

## 6. Retention policy and dry-run

Local migration `20260818235619` implements configurable defaults:

| Class | Default |
|---|---:|
| Unfinished applications | 30 days |
| Unconfirmed/spam leads | 90 days |
| Lost/archived leads | 365 days |
| Admin notifications | 90 days |
| Raw usage events | 90 days |
| Anonymized aggregate report snapshots | 730 days |
| Temporary CSV copies | 30-day external maximum; application does not persist them |
| Technical logs without PII | 30-day provider setting |

Won leads, `contract_record` rows, contracts, invoices and statutory accounting
documents are excluded from automated lead cleanup. The migration adds bounded
configuration, daily `pg_cron` scheduling at 03:17 UTC, advisory locking, dry-run,
legal holds and a count-only deletion audit that stores no deleted identifier or
PII.

Disposable dry-run/boundary result: **35/35 PASS**. Tests prove exact-boundary
preservation, 30/90/365-day eligibility, won-record protection, legal holds,
zero deletion in dry-run, count reconciliation, controlled configuration and
out-of-range rejection. The schedule and non-dry cleanup were not enabled in
production.

Operational document:
[`MONETIZATION_RETENTION_AND_AGGREGATION.md`](../MONETIZATION_RETENTION_AND_AGGREGATION.md).

## 7. Usage aggregation privacy

The local database boundary accepts only client-scope UUID, SHA-256 pseudonymous
subject token, four bounded event names, event time, affirmative consent version
and sample flag. It has no field for email, phone, name, IP, user ID, free text,
individual timeline, partner/sponsor influence or arbitrary properties.

Report generation is service-only and enforces:

- one client and one real/sample class per report;
- both at least five events **and** five distinct subject tokens per segment;
- suppression of smaller segments;
- only consent-gated events;
- no identifiers, PII, subject hashes, free text or timelines in export;
- `sample data` labels in demo output;
- no partner/sponsor branch.

Automated privacy result: **32/32 PASS**. Browser roles have no private table or
report-function access. This is local evidence for the uncommitted sixth
migration, not a live production claim.

## 8. Privacy/DPA closure

Draft packet:
[`MONETIZATION_PRIVACY_DPA_DRAFTS_2026-08-19.md`](../privacy/MONETIZATION_PRIVACY_DPA_DRAFTS_2026-08-19.md).

It contains the requested data-processing map, controller/processor decision
record, field/purpose inventory, processor/subprocessor register, provider DPA
checklist, B2B pilot DPA template, data-subject-request procedure and incident
procedure. It is explicitly **draft, unsigned and not legal advice**.

Open privacy/legal gates:

1. YouNew legal entity/address/registration and competent authority are not
   completed in the DPA template.
2. Provider DPA acceptance, account plan, region, transfer mechanism, support
   access, backup/log retention and deletion evidence are not verified.
3. OpenAI Sites currently documents no residency support at launch; the actual
   public hosting/account data path needs a transfer assessment or hosting change
   before form data is collected there.
4. Employee lawful basis, transparency, works-council implications and the
   employment-consent imbalance need Dutch legal review.
5. The public privacy page must remain truthful about current manual retention
   until the migration and schedule are actually approved and deployed.
6. Provider infrastructure logs/backups may exceed application defaults.

Legal completeness is **not confirmed**. Owner/counsel review is required before
a live employee-data pilot or DPA signature.

## 9. Security and privacy verdict

| Area | Verdict |
|---|---|
| Production access boundary | PASS — read-only inventory only; no migration/deploy/restore |
| RLS/private grants in candidate | PASS locally |
| Duplicate lead/notification contract | PASS locally |
| Retention deletion safety | PASS locally |
| Aggregate export privacy | PASS locally |
| Secret scan | PASS for approved history, compliance delta and artifacts |
| Test data | PASS — synthetic only; encrypted dump; no real lead/PII copy |
| Dependency security | **FAIL — two HIGH advisories** |
| Production backup/restore proof | **FAIL/incomplete** |
| Independent remote proof | **FAIL/incomplete** |
| Privacy/DPA legal closure | PARTIAL; specialist/owner review outstanding |

Overall security/privacy release verdict: **NO-GO**.

## 10. Rollback point and triggers

The rollback point must be the timestamp and immutable checksum of a fresh,
encrypted **production** logical backup plus the confirmed Supabase PITR/backups
state immediately before migration. It does not yet exist in this packet.

Stop the migration/deployment and invoke the owner rollback decision if any of
the following occurs:

- migration version/hash/order mismatch or SQL failure;
- RLS disabled, browser grant exposed or advisor regression;
- lead writes, dedupe, mandatory loss reason or one-notification behavior fails;
- retention dry-run selects won/contract/accounting records or ignores a hold;
- deletion/report counts do not reconcile;
- a report exposes a cohort under five, identifiers, free text or mixed clients;
- Admin/public build or smoke route returns a regression/5xx;
- production control counts diverge unexpectedly.

Rollback is not a reverse migration that drops new objects or weakens RLS.
First stop writes/jobs/report generation and restore the previous application
release. If database state is unsafe, Ivan Chernikov chooses and explicitly
authorizes PITR or encrypted-backup restore. Rehearse that exact selected restore
in disposable infrastructure first whenever time and incident safety permit.

## 11. Exact production deployment sequence — not authorized now

1. Remediate `js-yaml` to at least 4.3.1 and `nanoid` to at least 3.3.18 through
   reviewed overrides/dependency updates; explain lockfile changes and rerun every
   Admin/public test, build, audit and secret scan.
2. Run the owner push command for the exact two approved commits and create a
   draft PR. Record the PR URL and all Actions/artifact URLs; do not merge.
3. Separately authorize and publish reviewed commit(s) containing the sixth
   migration, 67 privacy assertions, retention/report implementation, backup
   verification changes, DPA docs and audit workflow. The current two-commit
   authorization does not cover them.
4. Require independent CI to pass: 81/81 core, 67/67 compliance, schema lint,
   Admin/public type/lint/tests/build, visual 6/6, secret scan and zero HIGH/
   critical dependency findings.
5. Complete owner/counsel review of the DPA, controller/processor/lawful-basis
   record, employee notice/choice and every active processor/subprocessor.
6. Obtain a temporary, least-privilege production dump connection through the
   approved Supabase mechanism. Create an age-encrypted roles/schema/data archive
   with `admin-dashboard/scripts/backup-postgres.sh`; never store its private
   identity, URL or password in source/Actions artifacts.
7. Record backup timestamp, SHA-256, bytes, production migration list, safe control
   counts, Supabase backup/PITR state and RPO. Restore that exact archive with
   `admin-dashboard/scripts/restore-rehearsal.sh` into a fresh disposable
   Supabase target. Verify exact 24 source migration versions, tables, RLS, grants,
   indexes and reconciled counts; record backup/restore duration and RTO.
8. Ivan reviews the final PR, independent evidence, legal gaps, actual backup/
   restore evidence and rollback point, then gives a new explicit approval for
   **merge**, **production migration** and **deployment** as separate actions.
9. In the approved maintenance window, pause Admin lead edits and event/report
   writes. Recheck production still has the exact 24-version manifest and the
   recorded control counts.
10. Apply exactly the six hash-pinned migrations once through the managed
    Supabase migration boundary, in the order in section 4. Stop on any drift.
11. Immediately verify migration versions, RLS, grants, required indexes,
    duplicate handling, notification count, report privacy functions, Security/
    Performance Advisors and control counts.
12. Deploy only the owner-approved Admin/public artifacts. Run the six route smoke
    tests, lead submission with an explicitly synthetic record, Admin stage/lost/
    CSV checks and consent-gated analytics checks. Do not enable checkout or
    outreach.
13. Run retention cleanup in `p_dry_run := true` mode only. Review all eight policy
    counts, exclusions and holds. Enable non-dry scheduled cleanup only under the
    separately approved operational decision.
14. Unpause writes, monitor bounded logs/notifications and record the final
    production version, timestamps and owner sign-off. Keep the rollback point
    until the agreed stability window expires.

Until those steps and approvals are complete, the definitive gate remains:
**NO-GO; stop before merge, production migration, deployment, payment activation
or external outreach.**
