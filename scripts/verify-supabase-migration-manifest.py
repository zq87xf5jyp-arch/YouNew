#!/usr/bin/env python3
"""Fail when an applied production migration is renamed or edited in place."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SUPABASE = ROOT / "admin-dashboard" / "supabase"
MIGRATIONS = SUPABASE / "migrations"
MANIFEST = SUPABASE / "production-migration-manifest.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"Supabase migration manifest failed: {message}")


payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
require(payload.get("schemaVersion") == 1, "unsupported manifest schema")
require(payload.get("projectRef") == "pgdzdxsiagfjioxwuqxf", "unexpected production project ref")

managed = payload.get("managedMigrations")
require(isinstance(managed, list) and managed, "managed migration list is empty")

expected_managed_files: set[str] = set()
seen_versions: set[str] = set()
for entry in managed:
    version = entry.get("version")
    name = entry.get("name")
    expected_md5 = entry.get("md5")
    expected_bytes = entry.get("bytes")
    require(isinstance(version, str) and re.fullmatch(r"20\d{12}", version) is not None, f"invalid version {version!r}")
    require(isinstance(name, str) and re.fullmatch(r"[a-z0-9_]+", name) is not None, f"invalid name for {version}")
    require(version not in seen_versions, f"duplicate version {version}")
    seen_versions.add(version)

    filename = f"{version}_{name}.sql"
    expected_managed_files.add(filename)
    path = MIGRATIONS / filename
    require(path.is_file(), f"missing managed migration {filename}")
    data = path.read_bytes()
    require(len(data) == expected_bytes, f"byte size drifted for {filename}")
    require(hashlib.md5(data).hexdigest() == expected_md5, f"MD5 drifted for {filename}")

actual_managed_files = {path.name for path in MIGRATIONS.glob("20*.sql")}
require(actual_managed_files == expected_managed_files, "managed migration file set differs from the production manifest")

bootstrap = payload.get("historicalBootstrapFiles")
require(isinstance(bootstrap, list) and bootstrap, "historical bootstrap list is empty")
expected_bootstrap_files = set(bootstrap)
actual_bootstrap_files = {path.name for path in MIGRATIONS.glob("000*.sql")}
require(actual_bootstrap_files == expected_bootstrap_files, "historical bootstrap file set drifted")

print(f"Supabase production migration manifest passed: {len(managed)} managed versions, {len(bootstrap)} historical bootstrap files")
