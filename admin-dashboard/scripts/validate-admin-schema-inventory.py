#!/usr/bin/env python3
"""Compare a disposable Admin schema delta with an explicitly reviewed manifest.

The validator deliberately does not infer approval from object names. PostgreSQL's
normalized definition hash for every removal, change and addition must be pinned
after a human reviews the first disposable run. Until then the gate fails closed
and emits a PII-free candidate manifest as a CI artifact.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


Inventory = dict[str, str]


def read_inventory(path: Path) -> Inventory:
    inventory: Inventory = {}
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw_line.strip()
        if not line:
            continue
        columns = line.split("|")
        if len(columns) != 3 or len(columns[2]) != 32:
            raise SystemExit(f"Malformed schema inventory row in {path}:{line_number}")
        identity = f"{columns[0]}|{columns[1]}"
        if identity in inventory:
            raise SystemExit(f"Duplicate schema inventory identity in {path}:{line_number}: {identity}")
        inventory[identity] = columns[2]
    return inventory


def observed_delta(before: Inventory, after: Inventory) -> dict[str, Any]:
    before_keys = set(before)
    after_keys = set(after)
    removed = {identity: before[identity] for identity in sorted(before_keys - after_keys)}
    added = {identity: after[identity] for identity in sorted(after_keys - before_keys)}
    changed = {
        identity: {"before": before[identity], "after": after[identity]}
        for identity in sorted(before_keys & after_keys)
        if before[identity] != after[identity]
    }
    return {
        "schemaVersion": 1,
        "status": "candidate_unreviewed",
        "removed": removed,
        "changed": changed,
        "added": added,
    }


def read_reviewed_delta(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise SystemExit(f"Cannot read reviewed schema delta {path}: {error}") from error
    if not isinstance(value, dict) or value.get("schemaVersion") != 1:
        raise SystemExit(f"Unsupported reviewed schema delta format in {path}")
    for field in ("removed", "changed", "added"):
        if not isinstance(value.get(field), dict):
            raise SystemExit(f"Reviewed schema delta field {field!r} must be an object")
    return value


def public_grant_additions(delta: dict[str, Any]) -> list[str]:
    grant_prefixes = ("table_grant|", "column_grant|", "routine_grant|", "schema_grant|")
    return sorted(
        identity
        for identity in delta["added"]
        if identity.startswith(grant_prefixes) and ":PUBLIC:" in identity
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("before", type=Path)
    parser.add_argument("after", type=Path)
    parser.add_argument("--reviewed", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()

    before = read_inventory(args.before)
    after = read_inventory(args.after)
    observed = observed_delta(before, after)
    reviewed = read_reviewed_delta(args.reviewed)
    args.candidate.write_text(json.dumps(observed, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    reviewed_payload = {
        "removed": reviewed["removed"],
        "changed": reviewed["changed"],
        "added": reviewed["added"],
    }
    observed_payload = {
        "removed": observed["removed"],
        "changed": observed["changed"],
        "added": observed["added"],
    }
    unexpected_public_grants = public_grant_additions(observed)
    reviewed_status = reviewed.get("status")
    exact_match = reviewed_payload == observed_payload

    lines = [
        "ADMIN SCHEMA AND SECURITY INVENTORY REVIEW",
        f"before_objects={len(before)}",
        f"after_objects={len(after)}",
        f"added_objects={len(observed['added'])}",
        f"removed_objects={len(observed['removed'])}",
        f"changed_definitions={len(observed['changed'])}",
        f"reviewed_status={reviewed_status}",
        f"exact_reviewed_delta_match={'yes' if exact_match else 'no'}",
    ]
    if unexpected_public_grants:
        lines.append("unexpected_public_grant_additions=" + ",".join(unexpected_public_grants))
    if not exact_match:
        lines.append("review_required=inspect the candidate manifest and pin every identity and normalized md5")

    passed = reviewed_status == "reviewed" and exact_match and not unexpected_public_grants
    lines.append("verdict=" + ("PASS" if passed else "FAIL"))
    args.report.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    if not passed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
