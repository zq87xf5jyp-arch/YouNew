#!/usr/bin/env python3
"""Fail closed on known admin/backend production-readiness regressions."""

from pathlib import Path
import hashlib
import json
import re


ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        raise SystemExit(f"Admin production QA failed: missing {relative}")
    return path.read_text(encoding="utf-8")


auth = read("admin-dashboard/src/lib/auth.ts")
middleware = read("admin-dashboard/src/middleware.ts")
data = read("admin-dashboard/src/lib/data.ts")
public_api = read("admin-dashboard/src/lib/public-api.ts")
sync_route = read("admin-dashboard/src/app/api/mobile/sync/route.ts")
mobile_sync = read("admin-dashboard/src/lib/mobile-sync.ts")
runtime_generator = read("admin-dashboard/scripts/generate-governed-runtime.mjs")
crud_table = read("admin-dashboard/src/components/admin/crud-table.tsx")
owner_migration = read("admin-dashboard/supabase/migrations/0003_promote_first_owner.sql")
analytics_lockdown = read("admin-dashboard/supabase/migrations/0006_lock_down_analytics_ingest.sql")
seed = read("admin-dashboard/supabase/seed/seed.sql")
workflow = read(".github/workflows/admin-ci.yml")
runtime_text = read("YouNew/Resources/Data/younew-runtime-data.json")
runtime = json.loads(runtime_text)
admin_runtime = json.loads(read("admin-dashboard/src/generated/governed-runtime.json"))
admin_manifest = json.loads(read("admin-dashboard/src/generated/governed-runtime-manifest.json"))
public_content = json.loads(read("admin-dashboard/public-site/src/generated/public-content.json"))

failures: list[str] = []

if 'YOUNEW_ADMIN_DEMO_MODE === "true"' not in auth or 'YOUNEW_ADMIN_DEMO_MODE === "true"' not in middleware:
    failures.append("local admin demo mode is not explicit opt-in")
if 'YOUNEW_ADMIN_DEMO_MODE !== "false"' in auth + middleware + data:
    failures.append("implicit demo-mode enablement returned")
if "fallbackByTable" in public_api or "sampleArticles" in public_api or "defaultCities" in public_api:
    failures.append("public API can still substitute demo content")
if "status: 503" not in public_api or '"Cache-Control": "no-store"' not in public_api:
    failures.append("public API does not fail closed with an uncached 503")
for token in ("status: 200", "status: 304", 'request.headers.get("if-none-match")', "X-YouNew-Dataset-Fingerprint"):
    if token not in sync_route:
        failures.append(f"canonical mobile sync contract is missing {token}")
if "artifact: runtimeArtifact" not in mobile_sync or "datasetFingerprint" not in mobile_sync:
    failures.append("mobile sync is not backed by the generated governed runtime")
if "publicationStatus === \"published\"" not in runtime_generator or "duplicate entity IDs" not in runtime_generator:
    failures.append("admin runtime generator does not fail closed on publication state and duplicate IDs")
if admin_runtime != runtime:
    failures.append("admin runtime artifact differs from the iOS governed runtime")
if admin_manifest.get("datasetFingerprint") != runtime.get("datasetFingerprint"):
    failures.append("admin runtime manifest fingerprint differs from the iOS governed runtime")
if admin_manifest.get("entityCount") != len(runtime.get("entities", [])):
    failures.append("admin runtime manifest entity count is stale")
if admin_manifest.get("sourceSha256") != hashlib.sha256(runtime_text.encode("utf-8")).hexdigest():
    failures.append("admin runtime manifest source digest is stale")
if public_content.get("datasetFingerprint") != runtime.get("datasetFingerprint"):
    failures.append("public website fingerprint differs from the iOS governed runtime")
if {item["id"] for item in public_content.get("entities", [])} != {item["id"] for item in runtime.get("entities", [])}:
    failures.append("public website entity IDs differ from the iOS governed runtime")
if any(token in crud_table for token in ("<Edit", "<Trash2", "<Plus")):
    failures.append("inert CRUD mutation controls are visible")
if re.search(r"[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}", owner_migration, re.I):
    failures.append("owner bootstrap migration contains a hard-coded UUID")
for role in ("anon", "authenticated"):
    expected = f"revoke insert on table public.app_events from {role}"
    if expected not in analytics_lockdown:
        failures.append(f"analytics event INSERT is not revoked from {role}")
    expected = f"revoke insert on table public.app_sessions from {role}"
    if expected not in analytics_lockdown:
        failures.append(f"analytics session INSERT is not revoked from {role}")
if "younew.allow_demo_seed" not in seed or "Demo seed refused" not in seed:
    failures.append("demo seed lacks an explicit non-production opt-in guard")
for command in ("pnpm install --frozen-lockfile", "pnpm lint", "pnpm typecheck", "pnpm build"):
    if command not in workflow:
        failures.append(f"admin CI does not run {command}")

if failures:
    raise SystemExit("Admin production QA failed:\n- " + "\n- ".join(failures))

print("Admin production QA passed: app/site/admin runtime parity, versioned ETag sync, fail-closed data, explicit demo mode, analytics RLS hardening, guarded seed and CI coverage.")
