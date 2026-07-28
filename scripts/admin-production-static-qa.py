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
security_migration = read("admin-dashboard/supabase/migrations/20260727170658_harden_rls_and_function_boundaries.sql")
index_migration = read("admin-dashboard/supabase/migrations/20260727170715_add_foreign_key_indexes.sql")
business_migration = read("admin-dashboard/supabase/migrations/20260727234843_business_inquiries.sql")
business_function = read("admin-dashboard/supabase/functions/business-inquiry/index.ts")
business_validation = read("admin-dashboard/supabase/functions/_shared/business-inquiry.ts")
business_page = read("admin-dashboard/src/app/(admin)/business-inquiries/page.tsx")
business_action = read("admin-dashboard/src/app/(admin)/business-inquiries/actions.ts")
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
for token in ("create schema private", "drop policy \"server inserts app events\"", "drop policy \"server inserts app sessions\"", "A client role still has direct analytics INSERT privilege"):
    if token not in security_migration:
        failures.append(f"production security migration is missing {token}")
if "create index" not in index_migration:
    failures.append("production index migration is missing its indexes")
for token in (
    "alter table public.business_inquiries enable row level security",
    "revoke all on table public.business_inquiries from public, anon, authenticated",
    "approved admins read business inquiries",
    "owners and admins update business inquiries",
    "grant execute on function public.submit_business_inquiry(jsonb, text) to service_role",
):
    if token not in business_migration:
        failures.append(f"business inquiry migration is missing {token}")
for token in (
    "BUSINESS_INQUIRY_ALLOWED_ORIGINS",
    "BUSINESS_INQUIRY_RATE_LIMIT_SALT",
    "validateBusinessInquiryPayload",
    "submit_business_inquiry",
):
    if token not in business_function:
        failures.append(f"business inquiry function is missing {token}")
if "websiteConfirmation" not in business_validation or "consentToPrivacy" not in business_validation:
    failures.append("business inquiry server validation lacks abuse or consent checks")
if not re.search(r'fetchRowsResult<BusinessInquiryRow>\s*\(\s*"business_inquiries"', business_page):
    failures.append("admin business inquiry queue is not connected to Supabase")
if 'admin.role !== "owner" && admin.role !== "admin"' not in business_action:
    failures.append("business inquiry mutation lacks owner/admin authorization")
for command in ("pnpm install --frozen-lockfile", "pnpm test", "pnpm lint", "pnpm typecheck", "pnpm build"):
    if command not in workflow:
        failures.append(f"admin CI does not run {command}")

if failures:
    raise SystemExit("Admin production QA failed:\n- " + "\n- ".join(failures))

print("Admin production QA passed: app/site/admin runtime parity, fail-closed data, canonical security migrations, protected business inquiry workflow and CI coverage.")
