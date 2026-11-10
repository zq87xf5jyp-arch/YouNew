# Supabase P0-2 security and migration identity review

Date: 2026-08-18 (Europe/Amsterdam)  
Project: `pgdzdxsiagfjioxwuqxf`  
Status: **PARTIAL — reviewed local remediation; production unchanged**

## Outcome

The access decision is server-only. `anon` and `authenticated` must have no
direct access to `private.analytics_ingest_windows`; `service_role` retains DML,
and only `service_role` may execute `public.ingest_analytics_batch(jsonb)`.

The forward migration
`20260818145801_harden_analytics_ingest_windows_rls.sql` was created with the
pinned Supabase CLI and prepared locally. It:

- enables RLS on `private.analytics_ingest_windows`;
- adds a restrictive `false` policy for `anon` and `authenticated`;
- reasserts the table and ingest-RPC grants;
- adds explicit restrictive rejection policies to the two intentional
  deny-by-default tables reported by Security Advisor;
- fails atomically if required objects or postconditions differ.

The local Edge Function called nonexistent production RPC
`ingest_analytics_batch_v2`. It now calls the verified production function
`ingest_analytics_batch`. No Edge Function was deployed.

## Confirmed production evidence

Before remediation, `private.analytics_ingest_windows` had RLS disabled, no
policies, no direct `anon/authenticated` DML privileges and full
`service_role` DML. `public.ingest_analytics_batch(jsonb)` is `SECURITY DEFINER`,
has a fixed empty `search_path`, is executable only by `service_role`, and is the
only production function matching `ingest_analytics_batch%`.

The two Security Advisor `rls_enabled_no_policy` findings are intentional
server-only stores, but explicit policy is clearer and testable:

| Table | Client grants | Service grants | Classification | Local remediation |
|---|---|---|---|---|
| `public.feedback_rate_limits` | none | read/write | Edge/RPC rate-limit state; direct client access forbidden | restrictive client rejection policy |
| `public.governance_action_receipts` | none | read/write | idempotency/audit state written by guarded definer functions | restrictive client rejection policy |

## SECURITY DEFINER classification

All seven Security Advisor warnings are intentional authenticated RPC
capabilities rather than anonymous surfaces. Every function denies `anon`, uses
a fixed `search_path`, derives the caller through `auth.uid()` or a private role
helper, and validates an approved internal role. The warnings remain valuable:
any future grant or guard change requires a new review.

| Function | Callable roles | Effective guard | Classification |
|---|---|---|---|
| `activate_content_artifact(uuid)` | authenticated, service_role | owner/admin via `private.current_admin_role()`; candidate integrity checks; audit log | intentional privileged activation RPC |
| `request_content_sync()` | authenticated, service_role | owner/admin; creates queued candidate with manual activation | intentional privileged orchestration RPC |
| `verify_content_now(...)` | authenticated | owner/admin/qa plus approved reviewer, recent official source and idempotency/version checks | intentional human-verification RPC |
| `approve_content_publication(...)` | authenticated | owner/admin plus verified state and recorded human review | intentional human-publication RPC |
| `set_governance_owner_and_interval(...)` | authenticated | owner/admin plus approved owner and bounded interval | intentional policy-maintenance RPC |
| `transition_content_review_task(...)` | authenticated | owner/admin/editor/qa; approval/closure restricted to owner/admin/qa | intentional workflow RPC |
| `record_research_observation(...)` | authenticated | owner/admin/qa plus enabled feature flag and active consent | intentional consent-gated research RPC |

Recommendation: retain these grants for the documented Admin workflows, keep
the advisor warnings visible, and add negative RPC authorization tests before
any function body or grant change. The `service_role` grants on activation/sync
should be revalidated during the disposable-database test because their role
helpers are caller-identity based.

## Migration identity reconciliation

Production contains 24 applied migrations. The names and exact SQL bytes match
the repository. Two timestamps are aliases, not content drift:

| Local file version | Production version | Name | Exact bytes |
|---|---|---|---|
| `20260805173500` | `20260805221430` | `normalize_article_search_taxonomy` | MD5 `ea265966b977ac1824b84f5b3e78e990`, 5711 bytes |
| `20260805223000` | `20260805231047` | `expand_privacy_safe_analytics_dashboard` | MD5 `e04e3378050bbe7cd5ecf79c28126807`, 17709 bytes |

Manifest schema 2 records those aliases without renaming applied-history SQL.
The new `20260818145801` migration is recorded separately as reviewed pending
SQL. Therefore identity is reconciled locally and honestly: 24 applied remote,
24 matching applied artifacts, and one pending local migration.

## Verification

Passed locally:

- `python3 -m unittest scripts.tests.test_analytics_ingest_security_contract`;
- `python3 scripts/verify-supabase-migration-manifest.py`;
- JSON validation of the schema-2 manifest;
- read-only production checks of functions, grants, policies, migration records
  and Security Advisor findings.

Authored but not executed:

- `admin-dashboard/supabase/tests/analytics_ingest_windows_rls_test.sql` contains
  19 pgTAP assertions for RLS, grants, RPC execution and accidental-grant defense.

The local machine has no PostgreSQL client or Docker runtime, so a disposable
database migration and pgTAP run could not be performed. Running pgTAP with
`--linked` was deliberately avoided because it would execute test writes on
production, even though the test is transactional.

## Production gate

Do not apply or deploy from this report. P0-2 can become GO only after a separate
owner approval authorizes: backup/restore evidence, disposable database apply,
all 19 pgTAP assertions, Edge ingestion smoke, reviewed dry-run, production
migration apply, and post-apply advisors. Until then, production still has the
original RLS finding and the phase remains PARTIAL.
