#!/usr/bin/env python3
"""Verify applied production identities and reviewed pending migration bytes."""

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
require(payload.get("schemaVersion") == 2, "unsupported manifest schema")
require(payload.get("projectRef") == "pgdzdxsiagfjioxwuqxf", "unexpected production project ref")

managed = payload.get("managedMigrations")
require(isinstance(managed, list) and managed, "managed migration list is empty")
pending = payload.get("pendingMigrations")
require(isinstance(pending, list), "pending migration list is missing")

expected_managed_files: set[str] = set()
seen_production_versions: set[str] = set()
seen_local_versions: set[str] = set()
for entry in managed:
    production_version = entry.get("version")
    local_version = entry.get("localVersion", production_version)
    name = entry.get("name")
    expected_md5 = entry.get("md5")
    expected_bytes = entry.get("bytes")
    require(isinstance(production_version, str) and re.fullmatch(r"20\d{12}", production_version) is not None, f"invalid production version {production_version!r}")
    require(isinstance(local_version, str) and re.fullmatch(r"20\d{12}", local_version) is not None, f"invalid local version {local_version!r}")
    require(isinstance(name, str) and re.fullmatch(r"[a-z0-9_]+", name) is not None, f"invalid name for {production_version}")
    require(production_version not in seen_production_versions, f"duplicate production version {production_version}")
    require(local_version not in seen_local_versions, f"duplicate local version {local_version}")
    seen_production_versions.add(production_version)
    seen_local_versions.add(local_version)

    filename = f"{local_version}_{name}.sql"
    expected_managed_files.add(filename)
    path = MIGRATIONS / filename
    require(path.is_file(), f"missing managed migration {filename}")
    data = path.read_bytes()
    require(len(data) == expected_bytes, f"byte size drifted for {filename}")
    require(hashlib.md5(data).hexdigest() == expected_md5, f"MD5 drifted for {filename}")

for entry in pending:
    version = entry.get("version")
    name = entry.get("name")
    expected_md5 = entry.get("md5")
    expected_bytes = entry.get("bytes")
    require(isinstance(version, str) and re.fullmatch(r"20\d{12}", version) is not None, f"invalid pending version {version!r}")
    require(isinstance(name, str) and re.fullmatch(r"[a-z0-9_]+", name) is not None, f"invalid pending name for {version}")
    require(version not in seen_production_versions, f"pending version already exists in production {version}")
    require(version not in seen_local_versions, f"duplicate local version {version}")
    seen_local_versions.add(version)

    filename = f"{version}_{name}.sql"
    expected_managed_files.add(filename)
    path = MIGRATIONS / filename
    require(path.is_file(), f"missing pending migration {filename}")
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

print(
    "Supabase migration manifest passed: "
    f"{len(managed)} applied production versions, "
    f"{len(pending)} reviewed pending versions, "
    f"{len(bootstrap)} historical bootstrap files"
)
