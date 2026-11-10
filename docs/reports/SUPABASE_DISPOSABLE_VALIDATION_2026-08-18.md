# Supabase disposable validation — five pending migrations

Date: 2026-08-18  
Production connection: not used  
Production credentials or data: not used  
Decision: **PARTIAL — 81 assertions authored and statically reconciled; runtime execution blocked locally**

## Result

The repository contains exactly five pending migrations and five migration-specific pgTAP suites with exactly **81 planned assertions**:

| Suite | Assertions |
|---|---:|
| Analytics ingest window RLS and grants | 19 |
| Business inquiry pipeline | 19 |
| Exact-retry deduplication | 13 |
| Lead analytics funnel | 12 |
| Internal notification inbox | 18 |
| **Total** | **81** |

Static migration identity verification passes:

```text
Supabase migration manifest passed: 24 applied production versions,
5 reviewed pending versions, 6 historical bootstrap files
```

Runtime result is **NOT RUN**, not PASS. The local Supabase CLI 2.109.1 was invoked with telemetry disabled and generated local state only. `supabase start` stopped before creating a database because the environment has no reachable Docker daemon:

```text
Cannot connect to Docker daemon at unix:///var/run/docker.sock.
Docker Desktop is a prerequisite for local development.
```

No linked or remote command was used as a fallback.

## Exact disposable CI fallback

`.github/workflows/supabase-disposable-ci.yml` is a PR/manual workflow with read-only repository permission and no production secrets. It:

1. verifies the migration manifest and exact total of 81 assertions;
2. starts a generated local Supabase stack with pinned CLI 2.109.1;
3. rebuilds from migrations without seed or real data;
4. runs exactly the five suites and saves TAP output;
5. lints `public` and `private` schemas at error level;
6. always stops the stack without backup; and
7. uploads the TAP output for 14 days.

The workflow YAML parses locally. It has not been triggered because a GitHub workflow run is an external action and was not separately approved.

## Gate

Production migration is **NO-GO** until a disposable run returns all 81 assertions PASS, schema lint PASS, the TAP artifact is reviewed, and backup/restore evidence plus per-action owner approval exist.

