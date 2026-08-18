#!/usr/bin/env python3
"""Build a clean-test Supabase fixture without mutating immutable migrations.

The first managed migration contains a production-state guard. That guard is
valuable when the exact production snapshot is the input, but it intentionally
rejects the repository's historical 0001-0006 bootstrap on a fresh database.
For disposable restore testing we copy the complete Supabase directory and
remove only that historical precondition block from the copy. The migration's
DDL and every pending migration remain byte-for-byte identical to source.
"""

from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path


ADMIN_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ADMIN_ROOT / "supabase"
RUNTIME_ROOT = ADMIN_ROOT / ".supabase-ci-runtime"
RUNTIME_SUPABASE = RUNTIME_ROOT / "supabase"
GUARDED_MIGRATION = "20260727170658_harden_rls_and_function_boundaries.sql"
OVERLAPPING_BOOTSTRAP = "0006_lock_down_analytics_ingest.sql"
PRODUCTION_DATA_MIGRATION = "20260805173500_normalize_article_search_taxonomy.sql"
PENDING_PREFIX = "20260818"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


if RUNTIME_ROOT.exists():
    shutil.rmtree(RUNTIME_ROOT)

shutil.copytree(
    SOURCE_ROOT,
    RUNTIME_SUPABASE,
    ignore=shutil.ignore_patterns("ci-artifacts"),
)

# 0006 was added as a standalone bootstrap hardening step, while the first
# managed migration still expects the two ingest policies to exist so it can
# remove them as part of the same production-reviewed transition. Applying
# both in lexical order makes the managed migration fail before its DDL. Keep
# the managed transition as the authoritative clean-fixture implementation.
runtime_bootstrap = RUNTIME_SUPABASE / "migrations" / OVERLAPPING_BOOTSTRAP
if not runtime_bootstrap.is_file():
    raise SystemExit(f"Expected overlapping bootstrap migration: {OVERLAPPING_BOOTSTRAP}")
runtime_bootstrap.unlink()

# This metadata backfill deliberately requires three reviewed production rows
# and refuses an empty database. It is unrelated to analytics/lead schema and
# cannot be satisfied with synthetic inserts without weakening its provenance
# precondition, so omit it from the empty-data fixture only.
runtime_data_migration = RUNTIME_SUPABASE / "migrations" / PRODUCTION_DATA_MIGRATION
if not runtime_data_migration.is_file():
    raise SystemExit(f"Expected production-data migration: {PRODUCTION_DATA_MIGRATION}")
runtime_data_migration.unlink()

source_guarded = SOURCE_ROOT / "migrations" / GUARDED_MIGRATION
runtime_guarded = RUNTIME_SUPABASE / "migrations" / GUARDED_MIGRATION
original = runtime_guarded.read_text(encoding="utf-8")
start_marker = "do $migration_guard$\n"
end_marker = "\n$migration_guard$;\n"
start = original.find(start_marker)
end = original.find(end_marker, start)
if start < 0 or end < 0:
    raise SystemExit("Historical production guard markers were not found exactly once")
if original.find(start_marker, start + 1) >= 0 or original.find(end_marker, end + 1) >= 0:
    raise SystemExit("Historical production guard markers are ambiguous")

normalized = original[:start] + original[end + len(end_marker) :]
if not normalized.lstrip().startswith("-- REVIEW PACKAGE ONLY."):
    raise SystemExit("Unexpected historical migration prefix")
if "create schema private authorization postgres;" not in normalized:
    raise SystemExit("Historical migration DDL was not retained")
runtime_guarded.write_text(normalized, encoding="utf-8")

pending_source = sorted((SOURCE_ROOT / "migrations").glob(f"{PENDING_PREFIX}*.sql"))
if len(pending_source) != 5:
    raise SystemExit(f"Expected exactly five pending migrations, found {len(pending_source)}")

pending_identity = []
for source_path in pending_source:
    runtime_path = RUNTIME_SUPABASE / "migrations" / source_path.name
    source_digest = sha256(source_path)
    runtime_digest = sha256(runtime_path)
    if source_digest != runtime_digest:
        raise SystemExit(f"Pending migration changed in disposable copy: {source_path.name}")
    pending_identity.append({"file": source_path.name, "sha256": source_digest})

artifact_dir = SOURCE_ROOT / "ci-artifacts"
artifact_dir.mkdir(parents=True, exist_ok=True)
record = {
    "runtime": "disposable_clean_bootstrap",
    "productionConnectionUsed": False,
    "productionCredentialsUsed": False,
    "historicalGuardNormalization": {
        "file": GUARDED_MIGRATION,
        "reason": (
            "The immutable guard validates a production-specific pre-migration "
            "snapshot and rejects the repository's clean 0001-0006 bootstrap. "
            "Only the guard block is removed in the generated copy; its DDL remains."
        ),
        "sourceSha256": sha256(source_guarded),
        "runtimeSha256": sha256(runtime_guarded),
    },
    "overlappingBootstrapExcluded": {
        "file": OVERLAPPING_BOOTSTRAP,
        "sourceSha256": sha256(SOURCE_ROOT / "migrations" / OVERLAPPING_BOOTSTRAP),
        "reason": (
            "Its policy-removal transition is also performed by the first managed "
            "migration, whose reviewed precondition requires those policies to exist."
        ),
    },
    "productionDataMigrationExcluded": {
        "file": PRODUCTION_DATA_MIGRATION,
        "sourceSha256": sha256(SOURCE_ROOT / "migrations" / PRODUCTION_DATA_MIGRATION),
        "reason": (
            "It is a bounded metadata backfill for three pre-existing reviewed "
            "production articles and intentionally rejects an empty database."
        ),
    },
    "pendingMigrations": pending_identity,
}
(artifact_dir / "disposable-baseline.json").write_text(
    json.dumps(record, indent=2) + "\n",
    encoding="utf-8",
)

print(f"Prepared disposable Supabase baseline at {RUNTIME_ROOT}")
print("Verified five pending migrations byte-for-byte against source")
