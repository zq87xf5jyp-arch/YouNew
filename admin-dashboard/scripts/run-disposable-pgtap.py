#!/usr/bin/env python3
"""Run the five migration pgTAP files against the disposable DB container."""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path


ADMIN_ROOT = Path(__file__).resolve().parents[1]
RUNTIME_TESTS = ADMIN_ROOT / ".supabase-ci-runtime" / "supabase" / "tests"
ARTIFACTS = ADMIN_ROOT / "supabase" / "ci-artifacts"
TEST_FILES = [
    "analytics_ingest_windows_rls_test.sql",
    "business_inquiry_pipeline_test.sql",
    "business_inquiry_deduplication_test.sql",
    "lead_analytics_funnel_test.sql",
    "business_inquiry_notification_test.sql",
]


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
combined = []
total = 0

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

if total != 81:
    raise SystemExit(f"Expected 81 assertions, executed {total}")

combined.extend(["", f"Files={len(TEST_FILES)}, Tests={total}", "Result: PASS", ""])
summary = "\n".join(combined)
(ARTIFACTS / "pgtap-results.tap").write_text(summary, encoding="utf-8")
print(summary)
