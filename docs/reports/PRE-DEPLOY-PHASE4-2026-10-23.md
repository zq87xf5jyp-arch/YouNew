# YouNew Phase 4 — PRE-DEPLOY evidence report

Date: 23 October 2026  
Scope: local release candidate and isolated disposable Supabase environment  
Production deployment: **not performed**  
External outreach: **not performed**

## Executive result

**PRE-DEPLOY PASS.** The locally generated public package is internally consistent, the disposable database chain and isolated Edge round trip pass, and stale Amsterdam records fail closed. Production remains owner-authorisation gated.

| Gate | Result | Evidence |
|---|---|---|
| Amsterdam stale-catalog safety | PASS | 170/170 stale records excluded; zero dates refreshed from URL availability |
| Disposable migration chain | PASS | 52 source migrations checked byte-for-byte; 18 pending migrations checked; six local-only normalisations and nine fixtures isolated from source |
| Database and RLS tests | PASS | 15 pgTAP files, 404 tests; focused suite 392/392; database lint clean |
| NL/EN Edge E2E | PASS | two HTTP 201 responses, two persisted application rows, consent and PII-minimised notifications verified |
| Backup/restore rehearsal | PASS | encrypted logical backup restored into an isolated PostgreSQL 17.6 target; schema and managed boundaries verified |
| Public application | PASS | build, lint, typecheck, 199/199 tests, 2,608/2,608 search cases |
| Admin application | PASS | build, lint, typecheck, 154/154 tests |
| SEO and static package | PASS | 493 HTML files, 464 indexable sitemap URLs, 37,956 internal references, zero broken references |
| Security package scan | PASS | no known secret pattern; allowed HTTPS image hosts and Hostinger security headers checked |
| Visual QA | PASS | EN/NL desktop, safe empty catalogue, NL application and Amsterdam guide at 390×844; one overlap found and fixed |
| Partner outreach readiness | HOLD | 0/30 legally ready; 14 may advance to manual legal/channel review, 16 remain inbound/research only |

## 1. Catalog disposition

The effective published baseline contained 170 Amsterdam records whose review dates had expired. They are split into **108 critical** and **62 secondary** records. Fifty priority records received bounded source-identity and availability observations: 31 reachable, six redirected, ten restricted and three transient failures. Those observations do not prove facts.

- Confirmed current by field-level authoritative review in Phase 4: **0**
- Safely excluded from generated public output: **170**
- Deleted from the governed source or database: **0**
- Source dates refreshed from HTTP reachability: **0**
- Public governed source records: **177**
- Public packaged records after exclusion: **7**

The exclusion registry is deterministic and matched by both the content generator and the public-safe data-health gate. The default upstream freshness gate still reports 170 items of editorial debt; this is expected and is not hidden by the public gate. Public pages use only the seven accepted records and render an honest no-profile state instead of empty or broken profile routes.

Primary evidence:

- `DataProject/quality/phase4-amsterdam-stale-disposition.{json,csv,md}`
- `admin-dashboard/public-site/src/generated/public-freshness-exclusions.json`
- `admin-dashboard/public-site/src/generated/public-content.json`

## 2. Supabase and Edge validation

The disposable baseline generator leaves all historical source migrations byte-identical. Unsupported historical preconditions are represented only inside the generated disposable workspace. A clean reset then ran the complete chain and the final database suites.

Results:

- Source migrations verified byte-for-byte: **52**
- Pending migrations verified byte-for-byte: **18**
- Disposable-only exact normalisations: **6**
- Disposable-only precondition fixtures: **9**
- Focused pgTAP: **392/392 PASS**
- Complete pgTAP: **15 files / 404 tests PASS**
- Database lint: **no schema errors**

The NL and EN application forms were then submitted through the actual locally served Edge endpoint. Both returned HTTP 201 and were found in the isolated database. Notification rows were checked for PII minimisation. Synthetic rows were removed before the restore seed.

Evidence: `admin-dashboard/supabase/ci-artifacts/phase4/edge-e2e-evidence.md`, `prepare-final.log`, `db-reset-definitive.log`, `targeted-pgtap-definitive.log`, `full-supabase-test-db-definitive.log`, and `db-lint-final-clean.log`.

## 3. Backup and restore

The backup scripts now bind the encrypted dump to a hashed managed-boundary companion covering buckets, storage policies, auth triggers and YouNew cron jobs. Restore rejects a mismatched or missing companion.

- Archive: `younew-20261023T181035Z.dump.age`
- Archive SHA-256: `782740a0f451d5ac4e0d33360d8a702caa1b93350673b73fe9c3a986351e9651`
- Managed-boundary SHA-256: `e3218696bb41d779c7ddcfd3235235fac7ef9d8221738e007df284d625b63884`
- Restore target: isolated local PostgreSQL 17.6
- Verified inventory: 43 public tables, 98 policies, 61 database functions, three storage buckets and 52 migration records
- Measured local synthetic RTO: one second

Limitations: RPO must be calculated from the timestamp of the real production backup at deployment time. Database backups contain Storage metadata, not Storage object payloads, so object storage needs a separate inventory/copy procedure. Edge functions and project-level settings must be deployed and checked separately.

## 4. Application, SEO, security and mobile QA

The final public gate completed with:

- 199/199 application tests
- 2,608/2,608 search/geography cases, 12 provinces and 342 municipalities
- 493 exported HTML files
- 464 sitemap URLs
- 37,956 checked internal links, fragments and assets; zero broken
- zero duplicate canonical/title failures and zero orphan/low-link IA failures
- exact `out`/`dist` mirror and a real HTTP 404 response
- no draft paths, local filesystem paths, credential signatures or unapproved remote image hosts in the package

`hreflang`, canonical mapping, sitemap and robots output are covered by the static suite. Empty organisation routes are removed from the output and sitemap; the NL/EN indexes are noindex while empty. Visual QA covered both languages, the fail-closed empty state, the application form and an Amsterdam city guide. A mobile spacing defect on the application page was corrected and rechecked at 390×844.

## 5. Business wave

The supplied list contains 30 organisations. Identity evidence was observed for 27 and an official public route for 16. A public contact page is not treated as permission for unsolicited marketing.

- Ready for lawful first contact now: **0**
- Ready for a human legal/channel decision: **14**
- Inbound/research only: **16**
- Sent / replied / interested / registered: **0 / 0 / 0 / 0**

Thirty Dutch free-listing drafts are prepared, but they remain drafts. No personal address was harvested and no message was sent.

## 6. Residual launch gates

There are **no known blocking local code, migration, RLS, package, SEO-link or mobile-layout errors** in the tested candidate. These launch-only gates remain:

1. Owner gives explicit permission for production deployment.
2. Freeze an exact commit/artifact digest and record the production environment variables without copying them into reports.
3. Take and timestamp a real production backup; separately inventory Storage objects.
4. Apply migrations and Edge functions to a non-production staging project if the owner requires hosted parity beyond the isolated local stack.
5. Execute the smoke, form-persistence, analytics-consent, indexing and error checks against the live deployment immediately after authorised publication.

Catalogue breadth is intentionally reduced to seven records until field-level review progresses. This is a product limitation, not a safety failure: the 170 unverified records cannot leak into public or SEO output.

## Decision

**Local PRE-DEPLOY: PASS. Production: NO-GO until explicit owner authorisation and execution of the live-only gates above.**
