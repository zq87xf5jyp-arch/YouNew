#!/usr/bin/env python3
"""Validate ADR structure and require ADR evidence for governance changes."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADR_DIR = ROOT / "docs" / "adr"
REQUIRED_HEADINGS = (
    "## Problem and context",
    "## Considered options",
    "## Decision",
    "## Consequences and risks",
    "## Verification",
)
SENSITIVE_PATTERNS = (
    "DataProject/schema/content-governance.schema.json",
    "DataProject/governance/status-policy.json",
    "DataProject/governance/semantic-duplicate-model.json",
    "scripts/governance_contract.py",
    "scripts/import-data-project.py",
    "scripts/check-external-links.py",
    "scripts/semantic_duplicate_candidates.py",
    "admin-dashboard/supabase/migrations/",
    "admin-dashboard/src/lib/governance",
    "DataProject/ai-evaluation/",
)


def fail(message: str) -> None:
    raise SystemExit(f"ADR policy failed: {message}")


def changed_paths(base: str | None) -> set[str]:
    if not base:
        return set()
    completed = subprocess.run(
        ["git", "diff", "--name-only", f"{base}...HEAD"],
        cwd=ROOT,
        check=False,
        text=True,
        capture_output=True,
    )
    if completed.returncode:
        fail(f"cannot compare with {base}: {completed.stderr.strip()}")
    return {line.strip() for line in completed.stdout.splitlines() if line.strip()}


def validate_record(path: Path, expected_id: str, expected_status: str) -> None:
    text = path.read_text(encoding="utf-8")
    title_match = re.search(r"^# (ADR-\d{3}) — .+$", text, flags=re.MULTILINE)
    if not title_match or title_match.group(1) != expected_id:
        fail(f"{path.name} has an invalid ADR title")
    metadata = {}
    for key, value in re.findall(r"^- ([A-Za-z ]+): (.+)$", text, flags=re.MULTILINE):
        metadata[key] = value.strip()
    for key in (
        "Status",
        "Date",
        "Draft author",
        "Human decision owner",
        "Supersedes",
        "Related contracts",
        "Related migrations",
    ):
        if not metadata.get(key):
            fail(f"{path.name} is missing {key}")
    if metadata["Status"] not in {"proposed", "accepted", "superseded", "deprecated"}:
        fail(f"{path.name} has an unsupported status")
    if metadata["Status"] != expected_status:
        fail(f"{path.name} status differs from index.json")
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", metadata["Date"]):
        fail(f"{path.name} date must be YYYY-MM-DD")
    owner = metadata["Human decision owner"].casefold()
    if metadata["Status"] == "accepted" and any(token in owner for token in ("pending", "tbd", "codex", "ai ")):
        fail(f"{path.name} cannot be accepted without a real human decision owner")
    for heading in REQUIRED_HEADINGS:
        if heading not in text:
            fail(f"{path.name} is missing {heading}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=os.getenv("ADR_DIFF_BASE"))
    args = parser.parse_args()

    index_path = ADR_DIR / "index.json"
    if not index_path.is_file():
        fail("docs/adr/index.json is missing")
    index = json.loads(index_path.read_text(encoding="utf-8"))
    records = index.get("records", [])
    expected_ids = [f"ADR-{number:03d}" for number in range(1, len(records) + 1)]
    actual_ids = [record.get("id") for record in records]
    if actual_ids != expected_ids:
        fail("ADR IDs must be contiguous and ordered")
    if index.get("nextNumber") != len(records) + 1:
        fail("nextNumber must follow the last indexed ADR")
    for record in records:
        path = ADR_DIR / str(record.get("file", ""))
        if not path.is_file():
            fail(f"indexed file is missing: {path.name}")
        validate_record(path, record["id"], record["status"])

    changed = changed_paths(args.base)
    sensitive = {path for path in changed if any(pattern in path for pattern in SENSITIVE_PATTERNS)}
    if sensitive:
        adr_changes = {
            path for path in changed
            if path == "docs/adr/index.json"
            or (path.startswith("docs/adr/") and re.search(r"/\d{4}-.+\.md$", path))
        }
        if "docs/adr/index.json" not in adr_changes or len(adr_changes) < 2:
            fail("governance-sensitive changes require index.json and a numbered ADR update")

    print(f"ADR policy passed: {len(records)} records; {len(sensitive)} sensitive changed paths")


if __name__ == "__main__":
    main()
