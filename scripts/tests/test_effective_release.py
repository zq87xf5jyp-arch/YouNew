#!/usr/bin/env python3

import importlib.util
import json
import sys
import tempfile
import unittest
from datetime import date
from pathlib import Path
from unittest import mock


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from effective_release import (  # noqa: E402
    EffectiveReleaseError,
    canonical_sha256,
    effective_release_heads,
    file_sha256,
    resolve_release,
)


GATES_PENDING = {
    "build": "pending",
    "static": "pending",
    "duplicate": "pending",
    "source": "pending",
    "media": "pending",
    "search": "pending",
    "ai": "pending",
}
GATES_PASSED = {key: "passed" for key in GATES_PENDING}


def write_json(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def entity(description="A sufficiently long immutable base description for resolver testing."):
    return {
        "id": "place.amsterdam-test",
        "entity_type": "place",
        "category": "test-place",
        "city_id": "amsterdam",
        "province_id": "noord-holland",
        "coordinates": {"latitude": 52.37, "longitude": 4.89},
        "title": "Amsterdam Resolver Test",
        "description": description,
        "images": [],
        "official_source": {
            "title": "Official test page",
            "publisher": "City of Amsterdam",
            "url": "https://www.amsterdam.nl/en/",
            "is_official": True,
            "checked_at": date.today().isoformat(),
            "status": "verified_opened",
        },
        "website": "https://www.amsterdam.nl/en/",
        "related_entity_ids": [],
        "last_checked": date.today().isoformat(),
        "review_frequency_days": 90,
        "verification_status": "verified",
        "ai_summary": "A sufficiently long grounded summary for deterministic resolver fixture testing.",
        "search_keywords": ["Amsterdam", "resolver", "fixture"],
        "lifecycle_status": "published",
    }


class EffectiveReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.repository = Path(self.temporary.name)
        self.project = self.repository / "DataProject"
        self.base_path = self.project / "batches" / "WP-06" / "M2-amsterdam-001.json"
        self.overlay_path = self.project / "overlays" / "WP-06" / "amsterdam-v0.1.1.json"
        self.lock_path = self.project / "releases" / "acceptance-locks" / "amsterdam-v0.1.0.json"
        self.registry_path = self.project / "releases" / "releases.json"

        self.base_record = entity()
        write_json(self.base_path, {
            "schema_version": 1,
            "batch_id": "WP-06-M2-amsterdam-001",
            "work_package": "WP-06",
            "milestone": "WP-06-M2",
            "target_release": "amsterdam-v0.1.0",
            "publication_status": "published",
            "qa": GATES_PASSED,
            "records": [self.base_record],
        })
        self.base_hash = file_sha256(self.base_path)
        write_json(self.lock_path, {
            "schema_version": 1,
            "release_id": "amsterdam-v0.1.0",
            "accepted_at": "2026-07-18T11:35:00+02:00",
            "approver": "fixture-human-approval",
            "artifacts": [{
                "path": "DataProject/batches/WP-06/M2-amsterdam-001.json",
                "sha256": self.base_hash,
                "record_count": 1,
            }],
        })
        self.release_registry = {
            "schema_version": 1,
            "releases": [
                {
                    "id": "amsterdam-v0.1.0",
                    "work_package": "WP-06",
                    "dataset": "Amsterdam City 01",
                    "version": "0.1.0",
                    "status": "published",
                    "published_records": 1,
                    "qa": GATES_PASSED,
                },
                {
                    "id": "amsterdam-v0.1.1",
                    "work_package": "WP-06",
                    "dataset": "Amsterdam City 01",
                    "version": "0.1.1",
                    "status": "qa",
                    "published_records": 0,
                    "base_release_id": "amsterdam-v0.1.0",
                    "supersedes": "amsterdam-v0.1.0",
                    "base_batch_sha256": self.base_hash,
                    "overlay_path": "DataProject/overlays/WP-06/amsterdam-v0.1.1.json",
                    "acceptance_lock_path": "DataProject/releases/acceptance-locks/amsterdam-v0.1.0.json",
                    "qa": GATES_PENDING,
                },
            ],
        }
        write_json(self.registry_path, self.release_registry)

        self.replacement_record = entity(
            "A sufficiently long reviewed replacement description for resolver testing."
        )
        self.overlay = {
            "schema_version": 1,
            "release_id": "amsterdam-v0.1.1",
            "version": "0.1.1",
            "status": "qa",
            "work_package": "WP-06",
            "dataset": "Amsterdam City 01",
            "base_release_id": "amsterdam-v0.1.0",
            "supersedes": "amsterdam-v0.1.0",
            "base_batch_sha256": self.base_hash,
            "qa": GATES_PENDING,
            "evidence": [{
                "id": "evidence.amsterdam-test-review",
                "kind": "replacement_review",
                "url": "https://www.amsterdam.nl/en/",
                "checked_at": date.today().isoformat(),
                "note": "Human-reviewed fixture replacement evidence.",
            }],
            "replacements": [{
                "entity_id": self.base_record["id"],
                "original_canonical_sha256": canonical_sha256(self.base_record),
                "replacement_canonical_sha256": canonical_sha256(self.replacement_record),
                "reason": "Replace the fixture description after review.",
                "evidence_refs": ["evidence.amsterdam-test-review"],
                "record": self.replacement_record,
            }],
        }
        write_json(self.overlay_path, self.overlay)

    def tearDown(self):
        self.temporary.cleanup()

    def rewrite_overlay(self):
        write_json(self.overlay_path, self.overlay)

    def test_resolves_full_replacement_and_preserves_count_and_order(self):
        before = file_sha256(self.base_path)
        resolved = resolve_release(self.project, "amsterdam-v0.1.1")
        self.assertEqual([record["id"] for record in resolved.records], [self.base_record["id"]])
        self.assertEqual(resolved.records[0]["description"], self.replacement_record["description"])
        self.assertEqual(resolved.replacement_count, 1)
        self.assertEqual(file_sha256(self.base_path), before)
        self.assertEqual(effective_release_heads(self.project), ["amsterdam-v0.1.1"])
        self.assertEqual(effective_release_heads(self.project, {"published"}), ["amsterdam-v0.1.0"])

    def test_rejects_immutable_base_batch_drift(self):
        self.base_path.write_text(self.base_path.read_text(encoding="utf-8") + " ", encoding="utf-8")
        with self.assertRaisesRegex(EffectiveReleaseError, "base_batch_sha256|drifted"):
            resolve_release(self.project, "amsterdam-v0.1.1")

    def test_rejects_wrong_original_entity_hash(self):
        self.overlay["replacements"][0]["original_canonical_sha256"] = "0" * 64
        self.rewrite_overlay()
        with self.assertRaisesRegex(EffectiveReleaseError, "original canonical hash"):
            resolve_release(self.project, "amsterdam-v0.1.1")

    def test_rejects_partial_replacement_record(self):
        partial = {"id": self.base_record["id"], "description": "A changed partial record that must fail closed."}
        self.overlay["replacements"][0]["record"] = partial
        self.overlay["replacements"][0]["replacement_canonical_sha256"] = canonical_sha256(partial)
        self.rewrite_overlay()
        with self.assertRaisesRegex(EffectiveReleaseError, "record is partial"):
            resolve_release(self.project, "amsterdam-v0.1.1")

    def test_rejects_unresolved_evidence_reference(self):
        self.overlay["replacements"][0]["evidence_refs"] = ["evidence.missing"]
        self.rewrite_overlay()
        with self.assertRaisesRegex(EffectiveReleaseError, "unresolved evidence"):
            resolve_release(self.project, "amsterdam-v0.1.1")

    def test_manual_verification_override_field_is_rejected(self):
        self.overlay["manual_verification_overrides"] = []
        self.rewrite_overlay()
        with self.assertRaisesRegex(EffectiveReleaseError, "must contain exactly"):
            resolve_release(self.project, "amsterdam-v0.1.1")


class AmsterdamCandidateIntegrationTests(unittest.TestCase):
    def test_real_candidate_resolves_without_mutating_accepted_base(self):
        repository = SCRIPTS.parent
        project = repository / "DataProject"
        base_path = project / "batches" / "WP-06" / "M2-amsterdam-001.json"
        accepted_hash = "a24f464c86e1880a542b23f1606f8622218cc0c7aa75464a9a19402847813b07"
        self.assertEqual(file_sha256(base_path), accepted_hash)

        base = resolve_release(project, "amsterdam-v0.1.0")
        candidate = resolve_release(project, "amsterdam-v0.1.1")
        self.assertEqual(len(base.records), 183)
        self.assertEqual(len(candidate.records), 183)
        self.assertEqual(candidate.replacement_count, 30)

        changed_ids = {item["entity_id"] for item in candidate.overlay["replacements"]}
        base_by_id = {record["id"]: record for record in base.records}
        candidate_by_id = {record["id"]: record for record in candidate.records}
        self.assertEqual(set(base_by_id), set(candidate_by_id))
        unchanged_ids = set(base_by_id) - changed_ids
        self.assertEqual(len(unchanged_ids), 153)
        self.assertTrue(all(
            canonical_sha256(base_by_id[entity_id]) == canonical_sha256(candidate_by_id[entity_id])
            for entity_id in unchanged_ids
        ))
        self.assertEqual(file_sha256(base_path), accepted_hash)

    def test_link_checker_never_allowlists_client_errors(self):
        checker_path = SCRIPTS / "check-external-links.py"
        spec = importlib.util.spec_from_file_location("external_link_checker", checker_path)
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
        for status in (400, 402, 404, 405, 406, 410, 451):
            self.assertTrue(checker.is_confirmed_failure(status))
        for status in (200, 301, 401, 403, 429, 500, None):
            self.assertFalse(checker.is_confirmed_failure(status))

    def test_link_checker_does_not_turn_get_transport_failure_into_404(self):
        checker_path = SCRIPTS / "check-external-links.py"
        spec = importlib.util.spec_from_file_location("external_link_checker_transport", checker_path)
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
        url = "https://example.com/temporarily-unreachable"
        head_404 = checker.urllib.error.HTTPError(url, 404, "Not Found", None, None)
        get_timeout = checker.urllib.error.URLError("temporary timeout")
        with mock.patch.object(checker.urllib.request, "urlopen", side_effect=[head_404, get_timeout]):
            result = checker.check((url, "fixture:1"), None)
        self.assertEqual(result[2], "")
        self.assertEqual(result[4], "URLError")


if __name__ == "__main__":
    unittest.main()
