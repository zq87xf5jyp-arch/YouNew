#!/usr/bin/env python3
"""Run baseline and additive Admin pgTAP groups against the disposable DB."""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path


ADMIN_ROOT = Path(__file__).resolve().parents[1]
RUNTIME_TESTS = ADMIN_ROOT / ".supabase-ci-runtime" / "supabase" / "tests"
ARTIFACTS = Path(
    os.environ.get(
        "SUPABASE_ARTIFACT_DIR",
        str(ADMIN_ROOT / "supabase" / "ci-artifacts"),
    )
)
CORE_TEST_FILES = [
    "analytics_ingest_windows_rls_test.sql",
    "business_inquiry_pipeline_test.sql",
    "business_inquiry_deduplication_test.sql",
    "lead_analytics_funnel_test.sql",
    "business_inquiry_notification_test.sql",
]
COMPLIANCE_TEST_FILES = [
    "monetization_retention_policy_test.sql",
    "pilot_usage_report_privacy_test.sql",
]
GEO_TEST_FILES = [
    "geo_relevance_analytics_test.sql",
]
HISTORICAL_NON_TARGETED_TEST_FILES = {"content_governance_test.sql"}
BASELINE_TEST_FILES = CORE_TEST_FILES + COMPLIANCE_TEST_FILES + GEO_TEST_FILES
ADMIN_REMEDIATION_TEST_FILES = sorted(
    path.name
    for path in (ADMIN_ROOT / "supabase" / "tests").glob("*.sql")
    if path.name not in set(BASELINE_TEST_FILES)
    and path.name not in HISTORICAL_NON_TARGETED_TEST_FILES
)
TEST_FILES = BASELINE_TEST_FILES + ADMIN_REMEDIATION_TEST_FILES


def docker(*args: str, input_bytes: bytes | None = None) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        ["docker", *args],
        input=input_bytes,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )


container = os.environ.get("SUPABASE_DB_CONTAINER")
if not container:
    listing = docker("ps", "--format", "{{.Names}}", "--filter", "name=^supabase_db_")
    if listing.returncode != 0:
        raise SystemExit(listing.stdout.decode("utf-8", errors="replace"))
    matches = [line for line in listing.stdout.decode().splitlines() if line]
    if len(matches) != 1:
        raise SystemExit(f"Expected one disposable Supabase DB container, found {matches}")
    container = matches[0]

ARTIFACTS.mkdir(parents=True, exist_ok=True)

# The local CLI runs migrations as the non-superuser `postgres` role and
# reserves `supabase_admin` membership, so the generated disposable migration
# copy cannot execute the production-reviewed ALTER DEFAULT PRIVILEGES for that
# platform role. Apply the exact statement as the owning local platform role
# immediately before security tests. This never contacts a linked project.
platform_acl = docker(
    "exec",
    "-i",
    container,
    "psql",
    "-X",
    "-v",
    "ON_ERROR_STOP=1",
    "--no-psqlrc",
    "-U",
    "supabase_admin",
    "-d",
    "postgres",
    input_bytes=(
        b"alter default privileges for role supabase_admin in schema public "
        b"revoke all privileges on tables from public, anon, authenticated;\n"
    ),
)
platform_acl_output = platform_acl.stdout.decode("utf-8", errors="replace")
(ARTIFACTS / "disposable-platform-default-acl.log").write_text(
    platform_acl_output,
    encoding="utf-8",
)
if platform_acl.returncode != 0:
    raise SystemExit(
        "Disposable supabase_admin default ACL normalization failed\n"
        + platform_acl_output
    )

combined = []
total = 0
core_total = 0
compliance_total = 0
geo_total = 0
admin_remediation_total = 0

for filename in TEST_FILES:
    path = RUNTIME_TESTS / filename
    sql = path.read_bytes()
    planned_match = re.search(rb"select\s+plan\((\d+)\)", sql, re.IGNORECASE)
    if not planned_match:
        raise SystemExit(f"Missing pgTAP plan in {filename}")
    planned = int(planned_match.group(1))
    result = docker(
        "exec",
        "-i",
        container,
        "psql",
        "-X",
        "-v",
        "ON_ERROR_STOP=1",
        "--no-psqlrc",
        "-U",
        "postgres",
        "-d",
        "postgres",
        input_bytes=sql,
    )
    output = result.stdout.decode("utf-8", errors="replace")
    (ARTIFACTS / f"{path.stem}.log").write_text(output, encoding="utf-8")
    if result.returncode != 0:
        raise SystemExit(f"{filename} exited {result.returncode}\n{output}")
    if re.search(r"\bnot ok\b", output):
        raise SystemExit(f"{filename} contains a failed assertion\n{output}")
    assertions = re.findall(r"\bok\s+(\d+)\s+-\s+([^\r\n]+)", output)
    numbers = [int(number) for number, _ in assertions]
    if numbers != list(range(1, planned + 1)):
        raise SystemExit(
            f"{filename}: expected assertions 1..{planned}, observed {numbers}"
        )
    combined.append(f"# {filename}\n1..{planned}")
    combined.extend(f"ok {number} - {description.strip()}" for number, description in assertions)
    total += planned
    if filename in CORE_TEST_FILES:
        core_total += planned
    elif filename in COMPLIANCE_TEST_FILES:
        compliance_total += planned
    elif filename in GEO_TEST_FILES:
        geo_total += planned
    else:
        admin_remediation_total += planned

if core_total != 81:
    raise SystemExit(f"Expected 81 core assertions, executed {core_total}")
if compliance_total != 67:
    raise SystemExit(f"Expected 67 compliance assertions, executed {compliance_total}")
if geo_total != 43:
    raise SystemExit(f"Expected 43 geo analytics assertions, executed {geo_total}")
if not ADMIN_REMEDIATION_TEST_FILES or admin_remediation_total <= 0:
    raise SystemExit("Expected at least one additive Admin remediation pgTAP suite")
if total != 191 + admin_remediation_total:
    raise SystemExit(
        f"Expected {191 + admin_remediation_total} targeted assertions, executed {total}"
    )

combined.extend([
    "",
    f"Core monetization assertions={core_total}/81 PASS",
    f"Retention and aggregation assertions={compliance_total}/67 PASS",
    f"Geo analytics assertions={geo_total}/43 PASS",
    f"Admin remediation assertions={admin_remediation_total}/{admin_remediation_total} PASS",
    f"Files={len(TEST_FILES)}, Tests={total}",
    "Result: PASS",
    "",
])
summary = "\n".join(combined)
(ARTIFACTS / "pgtap-results.tap").write_text(summary, encoding="utf-8")
(ARTIFACTS / "admin-remediation-assertion-count.txt").write_text(
    f"{admin_remediation_total}\n", encoding="utf-8"
)
(ARTIFACTS / "targeted-pgtap-assertion-count.txt").write_text(
    f"{total}\n", encoding="utf-8"
)
print(summary)
