from __future__ import annotations

import hashlib
import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SUPABASE = ROOT / "admin-dashboard" / "supabase"
MIGRATION = (
    SUPABASE
    / "migrations"
    / "20260818145801_harden_analytics_ingest_windows_rls.sql"
)
PGTAP = SUPABASE / "tests" / "analytics_ingest_windows_rls_test.sql"
EDGE_FUNCTION = SUPABASE / "functions" / "analytics-ingest" / "index.ts"
MANIFEST = SUPABASE / "production-migration-manifest.json"
RESTORE_REHEARSAL = ROOT / "admin-dashboard" / "scripts" / "restore-rehearsal.sh"


def normalized_sql(path: Path) -> str:
    return re.sub(r"\s+", " ", path.read_text(encoding="utf-8").lower()).strip()


class AnalyticsIngestSecurityContractTests(unittest.TestCase):
    def test_forward_migration_enables_rls_and_explicitly_denies_clients(self) -> None:
        sql = normalized_sql(MIGRATION)
        self.assertIn(
            "alter table private.analytics_ingest_windows enable row level security",
            sql,
        )
        self.assertIn("for all to anon, authenticated", sql)
        self.assertIn("using (false)", sql)
        self.assertIn("with check (false)", sql)
        self.assertIn("reject direct feedback rate limit access", sql)
        self.assertIn("reject direct governance receipt access", sql)

    def test_forward_migration_preserves_service_only_direct_access(self) -> None:
        sql = normalized_sql(MIGRATION)
        self.assertIn(
            "revoke all on table private.analytics_ingest_windows from public, anon, authenticated",
            sql,
        )
        self.assertIn(
            "grant select, insert, update, delete on table private.analytics_ingest_windows to service_role",
            sql,
        )
        self.assertIn("ingest_analytics_batch(jsonb)", sql)

    def test_pgtap_covers_anon_authenticated_and_service_role(self) -> None:
        sql = normalized_sql(PGTAP)
        self.assertIn("set local role anon", sql)
        self.assertIn("set local role authenticated", sql)
        self.assertIn("set local role service_role", sql)
        self.assertIn("private.analytics_ingest_windows", sql)
        self.assertIn("public.ingest_analytics_batch(jsonb)", sql)

    def test_edge_function_calls_the_production_rpc_contract(self) -> None:
        source = EDGE_FUNCTION.read_text(encoding="utf-8")
        self.assertIn("/rest/v1/rpc/ingest_analytics_batch`", source)
        self.assertNotIn("ingest_analytics_batch_v2", source)

    def test_manifest_tracks_the_forward_migration_without_editing_history(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        matches = [
            entry
            for entry in manifest["pendingMigrations"]
            if entry["version"] == "20260818145801"
        ]
        self.assertEqual(len(matches), 1)
        entry = matches[0]
        data = MIGRATION.read_bytes()
        self.assertEqual(entry["name"], "harden_analytics_ingest_windows_rls")
        self.assertEqual(entry["bytes"], len(data))
        self.assertEqual(entry["md5"], hashlib.md5(data).hexdigest())

    def test_manifest_records_verified_production_timestamp_aliases(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        aliases = {
            (entry["version"], entry.get("localVersion"), entry["name"])
            for entry in manifest["managedMigrations"]
            if "localVersion" in entry
        }
        self.assertEqual(
            aliases,
            {
                (
                    "20260805221430",
                    "20260805173500",
                    "normalize_article_search_taxonomy",
                ),
                (
                    "20260805231047",
                    "20260805223000",
                    "expand_privacy_safe_analytics_dashboard",
                ),
                (
                    "20260919161612",
                    "20260919140355",
                    "arrival_commerce_private_store",
                ),
            },
        )

    def test_restore_rehearsal_maps_local_files_to_production_versions(self) -> None:
        source = RESTORE_REHEARSAL.read_text(encoding="utf-8")
        self.assertIn("(.localVersion // .version)", source)
        self.assertIn(".managedMigrations + .pendingMigrations", source)
        self.assertIn('${local_version}_${migration_name}.sql', source)
        self.assertIn('${migration_version}_${migration_name}.sql', source)


if __name__ == "__main__":
    unittest.main()
