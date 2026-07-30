#!/usr/bin/env python3
"""Regression tests for independent asset-rights ledger generation."""

from __future__ import annotations

import importlib.util
import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR_PATH = ROOT / "scripts" / "generate-asset-rights-ledger.py"


def load_generator():
    spec = importlib.util.spec_from_file_location("generate_asset_rights_ledger", GENERATOR_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {GENERATOR_PATH}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class AssetRightsLedgerGeneratorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.generator = load_generator()
        cls.ledger = cls.generator.build_ledger()
        cls.records = {record["assetID"]: record for record in cls.ledger["records"]}

    def test_generation_does_not_read_ledger_output(self) -> None:
        original_path = self.generator.LEDGER_PATH
        self.generator.LEDGER_PATH = ROOT / "BuildWeekFix" / "does-not-exist.json"
        try:
            regenerated = self.generator.build_ledger()
        finally:
            self.generator.LEDGER_PATH = original_path
        self.assertEqual(regenerated, self.ledger)

    def test_all_photography_metadata_comes_from_attribution_manifest(self) -> None:
        attributions = json.loads(
            self.generator.ATTRIBUTIONS_PATH.read_text(encoding="utf-8")
        )
        photos = [item for item in attributions if item["id"].startswith("nl_")]
        self.assertEqual(len(photos), 72)
        for attribution in photos:
            record = self.records[attribution["id"]]
            self.assertEqual(record["family"], "netherlands_photography")
            for field in (
                "sourcePageURL",
                "creator",
                "licenseName",
                "licenseURL",
                "attributionRequired",
                "creditLine",
            ):
                self.assertEqual(record[field], attribution[field])

    def test_project_maps_and_flags_are_bound_to_independent_registry(self) -> None:
        evidence = json.loads(
            self.generator.PROJECT_OWNED_EVIDENCE_PATH.read_text(encoding="utf-8")
        )["records"]
        self.assertEqual(len(evidence), 26)
        for source in evidence:
            record = self.records[source["assetID"]]
            self.assertEqual(record["family"], source["family"])
            self.assertEqual(record["ownershipBasis"], "repository_original")
            self.assertIn(self.generator.PROJECT_OWNED_EVIDENCE, record["evidence"])
            self.assertIn(source["evidence"][0], record["evidence"])
            self.assertEqual(
                record["localFiles"],
                [{"path": source["localPath"], "sha1": source["localSHA1"]}],
            )

    def test_every_project_owned_record_has_basis_and_repository_evidence(self) -> None:
        project_owned = [
            record for record in self.ledger["records"] if record["bucket"] == "project_owned"
        ]
        self.assertEqual(len(project_owned), 36)
        for record in project_owned:
            self.assertTrue(record.get("ownershipBasis"), record["assetID"])
            self.assertTrue(record.get("evidence"), record["assetID"])

    def test_derived_city_symbols_keep_exact_sources_and_derivation_evidence(self) -> None:
        derived = [
            record
            for record in self.ledger["records"]
            if record["status"] == "public_domain_derived"
        ]
        exact = [
            record
            for record in self.ledger["records"]
            if record["status"] == "public_domain_byte_exact"
        ]
        self.assertEqual(len(derived), 27)
        self.assertEqual(len(exact), 31)
        evidence = json.loads(
            self.generator.CITY_EVIDENCE_PATH.read_text(encoding="utf-8")
        )["records"]
        evidence_by_id = {record["assetID"]: record for record in evidence}
        for record in derived:
            source = evidence_by_id[record["assetID"]]
            self.assertEqual(record["commons"]["localMatch"], "derived_from_current")
            self.assertEqual(source["sourceLocalSHA1"], source["commonsSHA1"])
            self.assertEqual(
                record["sourceArtifact"],
                {
                    "path": source["sourceLocalPath"],
                    "sha1": source["sourceLocalSHA1"],
                },
            )
            self.assertEqual(source["derivation"]["outputSHA1"], source["localSHA1"])


if __name__ == "__main__":
    unittest.main()
