# YouNew geo analytics migration validation — 2026-08-19

Owner: Ivan Chernikov  
Validation executor: Codex  
Scope: disposable pre-production validation only  
Production connection, production credentials, real analytics/leads/PII,
production migration, deployment and merge: **not used or performed**

## Executive verdict

| Gate | Verdict |
| --- | --- |
| Disposable migration mechanics | **GO** |
| Existing application regression baseline | **GO** |
| Database privacy/security assertions | **GO** |
| End-to-end consent and abuse assurance | **PARTIAL** |
| Production | **NO-GO** |

The migration applies after the complete source-controlled chain, applies on a
clean rebuild, changes only the analytics ingest function/comment, passes all
SQL assertions, and has an exact tested rollback. Public and Admin regression
suites and builds are green. Production remains blocked because browser consent
is not independently provable at the Edge boundary, canonical geo identifiers
are format-bounded rather than registry-backed, and the shared event envelope
needs an explicit owner data-minimisation decision.

## 1. Validated candidate

| Field | Value |
| --- | --- |
| Migration | `20260819080242_allow_geo_relevance_analytics.sql` |
| Bytes | `5569` |
| MD5 | `113043c51e207e6d0d7c7ae6da4b5df2` |
| SHA-256 | `e3482e32f9c12ab003578ffb4be1e1cfe8e16152887c42af2a16d9f63f849e76` |
| Supabase CLI | `2.109.1` |
| PostgreSQL | `17.6` |
| Docker | rootless disposable Docker inside Lima; database service only |
| Data | empty or deterministic synthetic fixtures only |

The manifest verifier confirms 24 production-history entries, seven pending
forward migrations and six historical bootstrap files. The new migration is
the seventh pending file. No `supabase link`, remote database URL, production
secret or production project operation was used.

## 2. Reproducible disposable chain

The runtime applied all 37 checked-in source migrations byte-for-byte:

- six historical bootstrap migrations;
- 24 managed historical migrations;
- seven pending forward migrations, ending with the geo migration.

Three clearly named disposable-only compatibility migrations were inserted to
supply historical preconditions that an empty database cannot otherwise meet:

1. `0007_disposable_restore_legacy_analytics_policies.sql`;
2. `20260805173459_disposable_seed_search_taxonomy_rows.sql`;
3. `20260805173501_disposable_remove_search_taxonomy_rows.sql`.

They use synthetic data, remove the temporary article/auth rows immediately,
and are not production migrations. The resulting local history contains 40
records: 37 byte-identical source migrations plus three disposable fixtures.
This distinction must be preserved in any release claim.

Primary reproducible commands, run with production-related environment
variables explicitly unset, were:

```bash
python3 scripts/prepare-disposable-supabase-baseline.py
pnpm dlx supabase@2.109.1 start \
  --exclude edge-runtime,gotrue,imgproxy,kong,logflare,mailpit,postgres-meta,postgrest,realtime,storage-api,studio,supavisor,vector \
  --workdir .supabase-ci-runtime
pnpm dlx supabase@2.109.1 db reset --local --no-seed \
  --workdir .supabase-ci-runtime
pnpm dlx supabase@2.109.1 migration up --local \
  --workdir .supabase-ci-runtime
python3 scripts/run-disposable-pgtap.py
pnpm dlx supabase@2.109.1 db lint --local \
  --schema public,private --level error --fail-on error \
  --workdir .supabase-ci-runtime
```

The CLI `test db --local` wrapper could not mount tests correctly through the
remote Lima Docker socket. The same nine checked-in suites were therefore run
with Supabase's official `public.ecr.aws/supabase/pg_prove:3.36` image against
the disposable database and passed. The GitHub workflow keeps the standard CLI
command because a native GitHub runner does not have that remote-socket
limitation.

Evidence:

- [disposable source identity](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/disposable-baseline.json)
- [migration list](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/migration-list.txt)
- [first clean rebuild](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/clean-apply-1.log)
- [second clean rebuild](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/clean-apply-2.log)
- [manifest verifier](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/manifest-verifier.log)

## 3. Schema before and after

The normalized schema diff contains only:

- replacement of `public.ingest_analytics_batch(jsonb)`;
- addition of the eight geo event names;
- bounded geo property validation;
- fail-closed handling of missing consent version;
- rejection of a top-level `city` on geo events;
- canonical format validation for Action Panel `content_id`;
- an updated function comment documenting the service-role-only boundary.

No table, column, policy, RLS state, grant, index or unrelated function was
added, removed or changed. The final inventory contains 40 public tables, nine
private tables, 42 public/private functions and 129 indexes. No public/private
application table had RLS disabled, and there were zero browser grants on the
private monetization tables.

Evidence:

- [normalized schema diff](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/schema-before-after.diff)
- [final schema inventory](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/schema-inventory-after.json)
- [schema lint](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/db-lint.log)

Schema lint result: **PASS — no schema errors found**.

## 4. Test results

| Suite | Result |
| --- | ---: |
| Core migration pgTAP | **81/81 PASS** |
| Retention and aggregate-report privacy pgTAP | **67/67 PASS** |
| Geo analytics pgTAP | **43/43 PASS** |
| Targeted migration assertions | **191/191 PASS** |
| Every checked-in SQL pgTAP suite | **203/203 PASS** |
| Public TypeScript | **PASS** |
| Public ESLint | **PASS** |
| Public tests | **178/178 PASS** |
| Public production build | **PASS — 611/611 static pages, export 2/2** |
| Admin TypeScript | **PASS** |
| Admin ESLint | **PASS** |
| Admin tests | **72/72 PASS** |
| Admin production build | **PASS — 32/32 static pages** |

The first two geo pgTAP attempts are retained as diagnostic evidence. They
identified a missing-consent fail-open expression and test-harness errors; both
were fixed before the final 43/43, 191/191 and 203/203 runs. They are not final
release failures.

An initial final Admin typecheck encountered duplicate files only inside an
ignored iCloud-synchronized `.next/types` cache. The generated cache was moved
out of the worktree, regenerated, and the complete TypeScript, ESLint, 72-test
and production-build sequence then passed. This was not a source-code failure.
The final build emitted non-blocking webpack cache serialization messages and
the known Next Edge Runtime warning for `@supabase/supabase-js`; exit status was
zero and all 32 static pages were generated.

Evidence:

- [targeted TAP summary](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/pgtap-results.tap)
- [all SQL suites](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/all-pgtap.log)
- [Public tests](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/public-tests.log)
- [Public build](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/public-build.log)
- [Admin tests](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/admin-tests.log)
- [Admin build](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/admin-build.log)

## 5. Consent, event and PII validation

Confirmed behavior:

- no accepted browser consent means no provider and no event;
- consent grant permits the bounded event batch;
- withdrawal synchronously removes and disposes the provider, discards queued
  events, and prevents later events;
- missing, unsupported or revoked consent-version values fail closed in the RPC;
- explicit-city detection, city correction and national fallback are covered;
- first-result and official-source clicks remain backward-compatible;
- Action Panel CTA is covered with a canonical content identifier;
- raw query, common PII keys, top-level city, email/free-text content identifiers
  and unsupported properties are rejected or discarded;
- URL query parameters are not copied into analytics `screen`;
- geo event timestamp, screen, platform, ranking/app version, schema version,
  consent version and environment are server-derived before the service-role RPC;
- a POST without an Origin is rejected, and only allowlisted browser origins
  receive CORS access;
- the actual request stream is limited to 65,536 bytes, including chunked or
  headerless bodies; `Content-Length` is only an early rejection hint.

An already in-flight HTTP request cannot be recalled after withdrawal; only
queued and future writes are guaranteed to stop. More importantly, the server
can validate the consent contract version but cannot independently prove that a
human made the browser choice. This is a production privacy decision, not a
passing database assertion.

## 6. RLS, grants and abuse boundary

Runtime verification confirms:

| Control | Result |
| --- | --- |
| `public.app_events` RLS | enabled |
| `public.app_sessions` RLS | enabled |
| `private.analytics_ingest_windows` RLS | enabled |
| `anon` RPC execute | denied |
| ordinary `authenticated` RPC execute | denied |
| `service_role` RPC execute | allowed |
| anonymous/authenticated direct read | denied |
| anonymous/authenticated insert/update/delete | denied |
| required analytics indexes | present |
| existing 120 events/minute per-instance window | retained |
| actual request-body byte limit | enforced independently of `Content-Length` |
| public bundle service-role exposure | none detected |

The migration does not broaden the existing Admin model. Existing aggregate
views and approved-role contracts remain green, while raw analytics stay outside
anonymous and ordinary authenticated access.

Evidence:

- [runtime security verification](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/security-runtime-verification.log)
- [public secret/service-role scan](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/service-role-secret-exposure-scan.log)
- [bounded request-body audit](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/bounded-request-body-static-audit.log)

## 7. Aggregate B2B privacy

The existing report boundary remained green under the full chain:

- minimum five subjects and five events per segment;
- small-cohort suppression;
- no email, phone, name, IP, user ID, free text or individual timeline in export;
- one client scope per report and cross-client isolation;
- only consent-gated events;
- no partner/sponsor influence;
- demo data marked as sample and kept separate from real aggregates.

Result: **67/67 PASS**, including retention and report-export privacy.

## 8. Performance and resilience

A single transaction ingested a synthetic batch of 50 geo events in the
disposable VM:

| Measure | Result |
| --- | ---: |
| Batch | 50 events |
| PostgreSQL execution time | `97.847 ms` |
| Stored before transaction rollback | 50 |
| Rate-window rows | 1 |
| Final data retained | 0; transaction rolled back |

Client tests confirm batching rather than N+1 requests, fire-and-forget UI
behavior, and isolation of a rejected analytics request from search, guide and
CTA behavior. The measured local time is evidence of bounded execution, not a
production latency SLO.

Evidence: [performance profile](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/performance-50-event-batch.log).

## 9. Rollback and rebuild

The previous ingest function and comment were captured as executable rollback
SQL, applied after the geo migration, and compared with the pre-migration
normalized schema.

```text
before SHA-256: 6309a01d76d01acaed7119830ab62147ee535b4db2ac1f04cadc454385cde159
after rollback: 6309a01d76d01acaed7119830ab62147ee535b4db2ac1f04cadc454385cde159
```

After rollback validation, the disposable database was rebuilt twice from
scratch with the geo migration included; both rebuilds passed.

Evidence:

- [rollback SQL](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/rollback-geo-function.sql)
- [rollback execution](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/rollback-apply.log)
- [schema hashes](../../admin-dashboard/supabase/ci-artifacts/geo-analytics-20260819/rollback-schema-sha256.txt)

## 10. Validation-related changed files

- `.github/workflows/supabase-disposable-ci.yml`
- `admin-dashboard/public-site/src/components/analytics-consent.tsx`
- `admin-dashboard/public-site/tests/geo-analytics-client.test.ts`
- `admin-dashboard/scripts/prepare-disposable-supabase-baseline.py`
- `admin-dashboard/scripts/run-disposable-pgtap.py`
- `admin-dashboard/supabase/README.md`
- `admin-dashboard/supabase/functions/analytics-ingest/index.ts`
- `admin-dashboard/supabase/functions/analytics-ingest/geo-event-normalization.ts`
- `admin-dashboard/supabase/migrations/20260819080242_allow_geo_relevance_analytics.sql`
- `admin-dashboard/supabase/production-migration-manifest.json`
- `admin-dashboard/supabase/tests/geo_relevance_analytics_test.sql`
- `admin-dashboard/supabase/verification/profile_geo_analytics_insert.sql`
- `admin-dashboard/supabase/verification/verify_geo_analytics_runtime.sql`
- `admin-dashboard/tests/geo-analytics-edge-contract.test.ts`
- `admin-dashboard/tests/geo-relevance-analytics-contract.test.ts`
- `admin-dashboard/tests/monetization-compliance-contract.test.ts`
- `docs/SUPABASE_PRODUCTION.md`
- `docs/DEPLOYMENT_RUNBOOK.md`
- this report and the separate geo production approval packet.

The shared worktree already contained unrelated dirty files. They were neither
discarded nor claimed as part of this validation. Public build generation
recreated ignored build directories and regenerated two already-dirty tracked
assets (`public/data/search-index.json` and `public/sw.js`); they were preserved.

## 11. Remaining risks

1. **Consent assurance — medium.** The client gate works and the RPC rejects a
   wrong consent version, but a direct caller with the public application key
   can imitate the browser contract. There is no trusted server-side consent
   receipt tied to the anonymous session.
2. **Origin is not authentication — medium.** Missing and non-allowlisted Origin
   values are rejected, but a non-browser caller can spoof an allowlisted Origin.
3. **Rotatable abuse key — medium.** The 120/minute protection is keyed by a
   client-supplied `app_instance_id`; hostile clients can rotate UUIDs.
4. **Canonical identifiers — low/medium.** City, intent and content identifiers
   are regex-bounded, not checked against an authoritative taxonomy. A
   slug-shaped pseudonymous value can resemble a valid identifier.
5. **Literal allowlist decision — owner review.** Geo rows inherit anonymous
   technical envelope fields such as `client_event_id`, `app_instance_id`,
   `screen`, platform, environment, schema and consent version. They are bounded
   and contain no direct PII, but exceed a literal reading of “store only” the
   enumerated geo fields.
6. **Legacy compatibility — low/medium.** `search_result_opened` and
   `official_source_click` intentionally remain compatible and do not use the
   new geo normalizer; their older envelope remains client supplied.
7. **In-flight withdrawal race — low.** Provider disposal cannot cancel a POST
   that has already reached the server.
8. **No deployed Edge HTTP integration run.** The request reader has unit/static
   coverage and passed Admin/Deno-compatible TypeScript validation, while the
   browser and database boundaries were tested separately. The final Edge
   Function was not deployed to a disposable remote runtime for an HTTP-level
   integration test.
9. **Independent evidence absent.** These results are local. No branch push,
   draft PR or GitHub Actions run was authorized or performed in this scope.
10. **Full-chain interpretation.** Three disposable-only precondition migrations
   appear in local history. All 37 source migrations are byte-identical, but the
   40-row local history is not a production migration-history claim.

## 12. Disposable cleanup

After evidence was saved, the local Supabase containers were stopped without a
backup, the dedicated Lima VM and disposable disk were deleted, and the runtime
copy plus downloaded temporary tools were removed. The evidence directory and
source changes were retained. Nothing deleted contained production data; the
disposable runtime is not recoverable and can be recreated from the documented
scripts.

## Final decision

**Disposable migration mechanics: GO.**  
**Application regression baseline: GO.**  
**Privacy/security closure: PARTIAL.**  
**Production: NO-GO until the separate approval packet blockers are closed and
the owner gives a new explicit authorization.**
