# YouNew Admin — Full Remediation Pre-Production Approval Packet

Дата: 2026-08-19  
Область: локальная реализация и pre-production validation  
Production deployment authorization: **not granted**  
Технический вердикт: **PARTIAL**  
Production verdict: **NO-GO**

## 1. Executive decision

Admin переведён с разрозненных прототипных состояний на общие authorization,
release-truth и source-state контракты. Критические ограничения Editor,
published-content, Storage, review publication и settings применяются на серверной
и/или database границе, а не только в UI. Dashboard, Trust и Releases используют
один `ReleaseTruthSnapshot`; live Supabase evidence загружается независимо как
`OperationalTruth`. Прототипные страницы явно read-only, а отсутствие или сбой
источника больше не отображаются как успешный ноль.

Это ещё не production approval. В текущем окружении отсутствует Docker/Postgres,
поэтому SQL chain и 397 pgTAP assertions не были исполнены. Первый disposable run
также намеренно остановится после генерации точного schema-delta candidate: его
PostgreSQL fingerprints должны быть отдельно просмотрены и закреплены. Текущий
encrypted backup→restore drill подготовлен как post-migration сценарий, но ещё не
исполнен. Эти три пункта блокируют production независимо от локальных TypeScript,
unit, build и browser результатов.

## 2. Boundary evidence

- Production Supabase credentials не использовались.
- Production database, leads, analytics и PII не читались и не копировались.
- Production migrations и deployment не выполнялись.
- Merge, push, force-push и изменение remote/credentials не выполнялись.
- Платежи, outreach, email и LinkedIn-сообщения не отправлялись.
- Использовались только локальные файлы и synthetic E2E fixtures.

## 3. Implemented controls

### Authorization and content safety

- `routePolicies` является общим registry для middleware, navigation, server
  actions и tests.
- Owner/Admin могут управлять published content; Editor ограничен только
  `draft`, `review`, `qa` на UI, server-action и RLS уровнях.
- Каждая article mutation читает текущий status из database. Editor не может
  изменить, снять с публикации или удалить published row, а также использовать
  `research`, `needs_review` или `archived` как обход.
- Изменение published article владельцем переводит материал в review и очищает
  устаревшее publication evidence; прежнее evidence не переиспользуется после
  фактического изменения содержания.
- Browser Storage DELETE удалён. Неиспользуемые image paths удаляются только
  server-side после успешного save; referenced/published paths защищены.
- Generic `approved → closed` удалён. Review task закрывается только publication
  RPC, которая одновременно фиксирует publication state/evidence.

### Release and operational truth

- Один typed `ReleaseTruthSnapshot` содержит commit, source-tree state, digest,
  evidence hashes, candidate/packaged/deployed metrics, gates, technical verdict
  и отдельное deployment authorization.
- Dashboard, Trust, Releases и public trust summary используют один snapshot.
- Public/Admin dev, test и production build теперь каждый раз регенерируют общий
  release truth после формирования public payload.
- Commit-bound snapshots являются exact-run build artifacts. Они не могут быть
  самоссылочно закреплены в commit с тем же `HEAD`; checked-in snapshot поэтому
  считается provisional, а CI должен публиковать точный artifact текущего run.
- Operational queries классифицируются как data, empty, forbidden, unavailable
  или stale независимо друг от друга.
- `0/N` означает измеренный ноль; denominator 0 — `N/A`; missing — unknown;
  query failure — unavailable. Ни unknown, stale, provisional, ни unavailable не
  могут дать GO.
- Review Queue использует deterministic database order, typed DTO, pagination и
  отдельный exact SLA count.

### Canonical data and honest read-only UI

- Map DTO строится из packaged governed content и municipality registry; Public
  API и Admin Map читают тот же fingerprinted payload.
- Official Links нормализуются одним URL contract, а runtime check results,
  aliases и notes хранятся отдельно. Legacy Map/Links оставлены read-only;
  duplicate cleanup — только preview + audited soft-supersede.
- Link health измеряется только по полному свежему canonical observation;
  invalid, epoch, future и older-than-24h observations дают unknown/stale, не 0.
- Categories, Cities, Map, Visual QA, Bugs, Links, AI Knowledge, Feedback и Audit
  Log явно помечены read-only; inert `CrudTable.cta` и фиктивные controls удалены.
- Global Search стал role-bounded route launcher без PII search.
- Notifications доступны Owner/Admin, ведут во внутренний inbox и показывают
  видимый warning, если bounded unread count недоступен.
- Content, Feedback, Bugs, Business inquiries и другие поверхности не превращают
  source failure или integrity error в успешный empty state.

### Operational mutations

- Feedback получает server-controlled `record_origin`; sample, synthetic и
  legacy-unclassified исключаются из user KPI по умолчанию.
- Business inquiries используют explicit-column selects и typed adapters.
  Некорректные required fields дают PII-free `Data integrity error`.
- CSV export использует upper watermark + composite keyset, explicit 10,000-row
  bound, typed export adapter и fail-closed integrity validation.
- Settings read fail-closed, валидируют allowlisted keys/email/HTTPS/language/
  canonical city; `maintenance_mode` остаётся JSON boolean; values обновляются
  без перезаписи concurrent publication status. Все 11 keys bootstrap additive
  migration.
- Sync jobs получили queued time, heartbeat, lease, attempts и terminal
  `timed_out`; claim/heartbeat/finalize выполняются RPC, direct INSERT отозван.
  Cron пока deliberately dry-run-only и ничего не изменяет.

### Analytics v2

- URL contract: `?days=7|30|90&platform=web|ios|all`, default `web`.
- Additive `security_invoker` views дают scoped daily metrics, exact period
  overview, event totals, exact sessions, funnel и complete-week comparison.
- Sessions считаются `count(distinct session_id)` за период; platform mismatch не
  попадает в engagement/duration denominators.
- Current/previous comparison использует две полные UTC weeks без today.
- Query health отделён от recency; iOS без ingest отображается как no-data.
- Action Panel interaction reconciles to two raw events, one key action, one
  source open and one separate CTA. Top events = top-12 + Other.
- Geo aggregates не выдают city/intent/user identifiers в Admin views.
- Legacy mobile endpoint остаётся disabled.

## 4. Migration manifest

Manifest state: **24 managed + 17 pending + 6 historical bootstrap**.

| Order | Version | Migration | Bytes | MD5 |
|---:|---|---|---:|---|
| 1 | 20260818145801 | harden_analytics_ingest_windows_rls | 5294 | e702afeef312705d2a5bc5a8858da0c4 |
| 2 | 20260818191112 | harden_business_inquiry_pipeline | 8280 | 716b6222ca3010e4f385082414169440 |
| 3 | 20260818192423 | deduplicate_business_inquiry_submissions | 11408 | d3010eb22035a572d0b36a8c522e68a0 |
| 4 | 20260818193310 | extend_lead_analytics_funnel | 12423 | 220bfa6bddd463acb67a86b31bbea285 |
| 5 | 20260818194626 | add_business_inquiry_notification_inbox | 4858 | e9df9c0cbd8828bbe6cfa26f57c5a295 |
| 6 | 20260818235619 | enforce_monetization_retention_and_private_reports | 27230 | 8f7e418080a080e3204106f344836ee0 |
| 7 | 20260819080242 | allow_geo_relevance_analytics | 5569 | 113043c51e207e6d0d7c7ae6da4b5df2 |
| 8 | 20260819124835 | harden_editor_published_articles | 2096 | 41991d26985b684763458922f3e498ae |
| 9 | 20260819124836 | harden_content_image_storage | 2928 | 3e1e728b4085de4dd1b87a583850a997 |
| 10 | 20260819124837 | add_feedback_record_origin | 5740 | b4b68900509810f0a901ca8eda76f758 |
| 11 | 20260819124838 | add_analytics_v2_scoped_exact_metrics | 15665 | 4bc7ec0c4cd79a5709543575ec880dc0 |
| 12 | 20260819124839 | add_canonical_map_overrides | 16045 | 8963ffeba633445a74389e84434e0e31 |
| 13 | 20260819124856 | add_sync_job_leases | 11981 | 2ba90f2dd993900a536644d0b6298473 |
| 14 | 20260819132519 | align_review_task_closure_with_publication_v2 | 4944 | 6b22c1618d3618b2693c7345d3c8a417 |
| 15 | 20260819142321 | add_admin_review_queue_view | 1244 | 917cc24913f3f0d406582044089d0ba6 |
| 16 | 20260819143000 | bootstrap_admin_settings_contract | 1654 | 970a1edd5805ab30d389fe0be981d3e1 |
| 17 | 20260819173000 | harden_public_relation_privileges | 543 | ba4ab214766866a1d9af022f60e7beed |

Manifest verifier result: **PASS**. The files are pinned by bytes and MD5 and
pending versions are strictly ordered after managed production versions.

## 5. Schema before/after gate

`capture_admin_schema_inventory.sql` records normalized fingerprints for:

- RLS enable/force state;
- policy roles, command, `USING` and `WITH CHECK`;
- views and security options;
- columns, constraints, indexes and triggers;
- function definition/security;
- table, column, routine, schema and default privileges, including `PUBLIC`.

The validator accepts only an exact reviewed manifest containing the before and
after MD5 for every changed object plus exact hashes for every addition/removal.
Name/prefix allowlists were removed. Added PUBLIC grants fail independently even
if present in a reviewed candidate. Malicious fixtures prove rejection of a
weaker same-name policy and a `PUBLIC DELETE` grant.

Current reviewed manifest status: **awaiting_disposable_review**. The first CI run
will write `admin-schema-reviewed-delta-candidate.json` and fail. After human
review, the exact hashes must be committed and the workflow rerun. No schema diff
has been approved in this local environment.

## 6. Test evidence

### Locally executed

| Gate | Result |
|---|---|
| Admin TypeScript | PASS |
| Admin ESLint | PASS; 0 warnings/errors |
| Admin Node/unit/security tests | 130/130 PASS |
| Admin production build | PASS; 32/32 routes |
| Admin isolated Playwright | 70 PASS / 20 intentional role skips / 0 failed / 0 flaky |
| Public TypeScript | PASS |
| Public ESLint | PASS |
| Public tests | 178/178 PASS |
| Public production build | PASS; 611/611 static pages, export 2/2 |
| Admin high-severity dependency audit | PASS; 0 advisories after `js-yaml` 4.3.1 and `nanoid` 3.3.18 override |
| Public high-severity dependency audit | PASS; 0 advisories after `js-yaml` 4.3.1 and `nanoid` 3.3.18 override |
| Python governance/restore contracts | PASS |
| Shell syntax for backup/restore/build scripts | PASS |
| Migration manifest | PASS; 24 managed / 17 pending / 6 bootstrap |
| `git diff --check` | PASS |

### pgTAP inventory

| Suite | Assertions |
|---|---:|
| Core | 81 |
| Compliance | 67 |
| Geo | 43 |
| Historical governance | 12 |
| Admin content security | 37 |
| Admin operational truth | 60 |
| Analytics v2 | 43 |
| Canonical Map/Links | 44 |
| Public relation privilege hardening | 10 |
| Targeted total excluding historical suite | 385 |
| All 14 checked-in SQL suites | 397 |

Static plans and assertion counts reconcile. Runtime result: **NOT EXECUTED**;
Docker/Postgres/Supabase runtime is unavailable locally. Required production gate
remains **397/397 PASS in disposable CI**. Any failure is NO-GO.

### Browser evidence boundary

The isolated suite covers 17 routes, Owner/Editor/QA/Viewer, 1440×900 and
390×844. It uses a localhost synthetic Supabase and a production Next bundle;
the closed-auth profile is built separately because `NEXT_PUBLIC_*` values are
compile-time inputs. Exact results: Owner 20 PASS / 2 role skips; Editor 16/6;
QA 16/6; Viewer 16/6; fail-closed profile 2/0. Aggregate: **70 PASS, 20
intentional role/profile skips, 0 failed, 0 flaky**. The Owner JSON report embeds
34 PNG screenshots: 17 routes × desktop/mobile.

The suite does not represent production data or production authentication.
Successful Trust transition/verify/approve, populated Business detail save,
enabled Settings save, enabled Sync request and the full browser image
upload/alt/cover/remove cycle are not represented by the synthetic fixture.
Server-side orphan-image cleanup is unit/security-tested, but its Storage network
path is not E2E-confirmed. These paths remain explicitly unverified.

Local evidence paths:

- `admin-dashboard/e2e-reports/admin-e2e-demo-owner.json` (34 embedded PNGs);
- `admin-dashboard/e2e-reports/admin-e2e-demo-{editor,qa,viewer}.json`;
- `admin-dashboard/e2e-reports/admin-e2e-closed.json`;
- `admin-dashboard/dependency-audit-artifacts/{admin,public}-audit.json`.

## 7. Disposable CI and performance evidence

Prepared workflow actions:

1. clean rebuild from the normalized baseline and exact pending chain;
2. pre/post schema dump and normalized security inventory;
3. exact reviewed-delta fail-closed gate;
4. legacy sync backfill fixture verification and removal;
5. dynamic execution of every pgTAP file and declared plan;
6. Map/Links/review/sync/feedback PII-free inventories;
7. `EXPLAIN (ANALYZE, BUFFERS)` for Analytics v2 at 7/30/90 days;
8. migration rebuild and previous-schema reproducibility check;
9. independent encrypted synthetic post-migration backup→restore rehearsal with
   dynamic full-manifest count, RLS/grants/index/count verification and measured
   backup/restore duration;
10. sanitized artifacts only; encrypted archive and age identity stay in runner
    temp and are deleted rather than uploaded.

No GitHub run URL exists because push/workflow dispatch is outside the current
authorization. Therefore none of these prepared CI checks is claimed as executed.

## 8. Backup, restore and rollback

Restore safety now requires:

- exact loopback or Unix-socket DSN parsing, including rejection of nested URI or
  conninfo in `dbname`;
- a random disposable target marker before destructive prepare SQL;
- encrypted `age` archive checksum verification;
- isolated Supabase runtime and automatic volume removal;
- full post-migration history: 24 managed + 17 pending;
- exact public/private RLS, grants, indexes and synthetic counts verification;
- `PUBLIC`, anon and authenticated grant checks using `table_privileges`.

Source→target schema/security inventories are compared byte-for-byte after one
documented normalization: local Supabase may seed implicit `supabase_admin`
default ACLs for anon/authenticated, while restore preparation deliberately
revokes them because the logical dump omits those platform defaults. The target
must contain zero such rows; every other captured identity/fingerprint must match.

The previous-schema rebuild in Supabase CI is only reproducibility evidence; it
is not called rollback. The coherent encrypted post-migration backup→restore
rehearsal has **not been executed in this environment** and is not yet a current
CI artifact. Measured backup/restore duration is therefore unavailable. This is a
production blocker.

Rollback model is forward corrective:

- rollback point: verified encrypted pre-migration backup + exact Admin bundle;
- trigger: any migration, RLS, grant, data-count, build, P0 accessibility or
  critical smoke failure;
- application rollback: redeploy previous verified Admin bundle;
- database rollback: stop rollout and apply a reviewed forward corrective
  migration; destructive down-migration is not automatic;
- destructive restore in production requires a separate incident decision and
  owner authorization;
- rollback owner: Ivan Chernikov, with Codex providing tested commands/evidence.

## 9. Security and privacy verdict

Static code verdict: **PASS with runtime evidence pending**.

- Editor published-content boundary is enforced in RLS and server actions.
- Direct browser Storage DELETE is denied.
- Legacy Map/Links DML is revoked; Links cleanup uses an audited RPC.
- Direct sync-history INSERT is revoked.
- PUBLIC/anon/authenticated lose inherited `TRUNCATE`, `REFERENCES`, `TRIGGER`
  and `MAINTAIN` on every public relation; future postgres/supabase_admin table
  defaults are fail-closed and application SELECT/DML remains explicit.
- Settings and business adapters fail closed.
- Analytics views are additive and `security_invoker`.
- Feedback provenance is server-controlled.
- No service-role credential is intentionally shipped to public bundles.
- Dependency remediation is deliberately narrow: both workspaces override the
  vulnerable `js-yaml` 4.3.0 resolution to 4.3.1; the existing `nanoid` 3.3.18
  security pin is retained. Frozen installs and full high-severity audits pass.

Runtime RLS/grants/functions verdict: **NOT VERIFIED** until disposable pgTAP and
exact schema fingerprints pass. Legal/DPA completeness remains outside technical
assertion and requires owner/specialist review.

## 10. Known risks and remaining evidence

1. Exact disposable schema candidate has not been generated/reviewed.
2. 397 pgTAP assertions and migration reset/rebuild have not run.
3. Encrypted backup→restore rehearsal and measured RTO have not run.
4. Analytics 7/30/90 `EXPLAIN` evidence exists only as prepared CI SQL.
5. Sync reconciler is dry-run-only and discards its result; activation or a
   persistent PII-free alert requires a later owner-approved migration.
6. `unconfirmed`/`spam` retention classes have no audited Admin classification
   RPC yet; those retention defaults are not operational through normal Admin UI.
7. Exact-run release artifacts require generation in every build because a file
   committed inside a commit cannot contain that same commit's hash. Build paths
   now regenerate them, but checked-in snapshots remain provisional evidence.
8. Trust/Business/Settings/Sync success mutations and the image Storage network
   cycle absent from synthetic fixtures cannot be claimed E2E-verified.
9. No remote CI URLs, screenshots artifact URLs or independent runner evidence
   exist until an approved branch push/workflow dispatch.
10. Admin build emits the known non-blocking Next Edge Runtime warning for
    `process.version` inside `@supabase/supabase-js`; compilation, type checking
    and all 32 route generations still pass.

## 11. Exact production sequence — not authorized for execution

1. Preserve the dirty worktree and isolate only reviewed Admin remediation files
   into an approved feature branch/PR.
2. Run the disposable workflow once; download and inspect the exact schema delta
   candidate, pg dumps and PII-free inventory.
3. Pin the reviewed before/after fingerprints and rerun the workflow.
4. Require 397/397 pgTAP PASS, schema lint PASS, all Admin/Public checks PASS,
   Analytics EXPLAIN review and no P0 accessibility/visual failures.
5. Run the encrypted synthetic backup→restore rehearsal; record checksum, schema,
   RLS, grants, indexes, counts, backup time and restore RTO.
6. Close or explicitly accept every E2E mutation-evidence gap.
7. Before production migration, create and verify an encrypted production backup,
   PITR/rollback point and exact migration manifest. Do not copy PII to CI.
8. Obtain a new explicit owner approval naming the exact commit, manifest digest,
   backup and CI runs.
9. Apply all 17 pending migrations in manifest order. Stop immediately on any
   checksum, assertion or schema-diff mismatch.
10. Execute read-only production smoke checks for auth, roles, Dashboard/Trust/
    Releases truth, Content, Business inquiries, Settings, Analytics, Map/Links
    and notification source states.
11. Deploy the exact verified Admin bundle and repeat desktop/mobile smoke checks.
12. Keep sync timeout mutation disabled; activate it only in a later reviewed
    forward migration after the dry-run inventory is approved.

No step in this sequence was executed by this task.

## 12. Final gate

**PARTIAL / production NO-GO**.

The implementation materially closes the known UI, authorization, truth-source,
analytics and canonical-data defects, but production cannot be approved without
runtime SQL evidence, reviewed exact schema fingerprints, a current encrypted
restore rehearsal, complete browser mutation evidence and explicit owner approval.
Technical GO, when eventually achieved, will still not grant deployment authority.
