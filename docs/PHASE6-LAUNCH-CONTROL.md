# YouNew Phase 6 — controlled launch gates

Date: 24 October 2026. Current decision: **NO-GO**. No production deployment is authorised or performed.

## Candidate identity

The owner-supplied Phase 5 archive with SHA-256 `ba0b0cbfa6c298ae2ae6d2f9b8ecf52675986b8c0ea66380b2973550f6a13dec` is byte-intact but superseded because its frozen dependencies are now affected by published security advisories. It must not be deployed.

The Phase 6 freeze script creates a new immutable public archive and source checksum manifest after the current local checks. Its new SHA-256 is the only value that may be referenced by a future deployment permission.

## Mandatory gate matrix

| Gate | Evidence required | Current state |
|---|---|---|
| Exact artifact | Archive SHA and source-manifest SHA both match | Prepared for new freeze |
| Dependency safety | Admin and public production audits have no known high/critical vulnerability | PASS locally |
| Public tests/build | Unit, static, 404, internal-link, security, canonical, hreflang, sitemap and robots checks | PASS locally |
| Admin tests/build | Tests, lint, typecheck and production build | PASS locally; Edge warning requires staging observation |
| Indexable value | Every one of 464 sitemap URLs has standalone useful evidence | **BLOCKED: 457 PASS, 7 REVIEW** |
| Amsterdam freshness | All 170 exclusions remain until separately accepted evidence changes them | PASS locally |
| QA data release | Explicit acceptance of `amsterdam-v0.1.9` overlay SHA | Not accepted |
| Production DB backup | Encrypted, hashed backup created in the launch window | Not executed |
| Storage backup | All bucket payloads copied, encrypted and reconciled separately | Not executed |
| Restore rehearsal | DB restored into isolated target; Storage archive fully verified | Prepared, not executed in production window |
| Staging parity | Exact archive, NL/EN routes, consent, forms and two marked Edge submissions pass | Not executed for this candidate |
| Owner deployment permission | Exact new SHA, window, operator, scope and rollback owner | Not granted |

Any non-PASS mandatory row stops publication.

## Separate permissions that must never be conflated

1. **Data release acceptance** may approve `amsterdam-v0.1.9`; it does not publish it.
2. **Static production deployment** may approve one exact archive; it does not authorise database migrations, DNS changes or catalogue acceptance.
3. **Production database migration** requires its own written scope and backup/restore decision.
4. **DNS change**, **QA-catalogue promotion** and **business outreach** each require separate authority.

## Pre-launch operator sequence

1. Resolve the seven indexable-value reviews or deliberately remove those routes from indexing/public navigation without producing an empty pilot.
2. Freeze a new candidate and run `scripts/phase6-launch-preflight.sh` against its manifest.
3. Obtain an explicit owner permission naming that exact candidate SHA, maintenance window, deployment operator and rollback owner.
4. In the authorised window, create the encrypted production database backup.
5. Create and reconcile the separate encrypted Storage payload backup. Stop if bucket/object/byte counts or hashes disagree.
6. Verify the database restore in a disposable database and verify every Storage object hash locally. Never restore into production during rehearsal.
7. Deploy the exact archive to private staging. Execute EN and NL smoke, canonical/hreflang/robots/sitemap/404 checks and mobile QA.
8. Submit one uniquely marked EN and one NL application through the real staging Edge endpoint; prove persistence and notification minimisation; remove only those known test rows.
9. Record GO/NO-GO. Deployment remains stopped if any result is missing, ambiguous or stale.

## Post-deploy smoke, only after separate permission

Check over production HTTPS:

- `/`, `/nl/`, `/search/`, `/nl/zoeken/`;
- Amsterdam pilot navigation and the approved governed card set;
- free NL/EN business-registration routes and actual persistence using tagged test records;
- `/robots.txt`, `/sitemap.xml`, canonical, hreflang, real 404 and security headers;
- absence of all unapproved freshness exclusions from pages, search and sitemap;
- consent behaviour before and after opt-in;
- application/Edge/server error logs without exposing PII.

Repeat the availability and error check immediately, after 15 minutes, 1 hour, 6 hours and 24 hours. Exclude tagged tests from commercial KPIs.

## Rollback

Rollback triggers include repeated 5xx, broken NL/EN routes, failed application persistence, PII leakage, analytics before consent, wrong canonical/noindex, publication of excluded records, artifact mismatch or a material RLS/secret failure.

1. Stop traffic expansion and preserve evidence.
2. Restore the previous known-good static hosting release.
3. Do not touch the database if the authorised change was static-only.
4. If a separately authorised migration occurred, use its documented forward-fix or restore decision; never improvise a destructive rollback.
5. Re-run smoke before reopening and record timestamps, affected requests, potential data-loss window and recovery evidence.

## Current conclusion

The package is technically improved but is not ready for an owner deployment request: seven indexable routes still require editorial/evidence resolution, live backup gates have not run, staging parity has not run for the new candidate, and the current production `/nl/` route returns 404.

