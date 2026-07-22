import hashlib
import importlib.util
import json
import struct
import sys
import tempfile
import unittest
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "scripts" / "asset-rights-gate.py"
SPEC = importlib.util.spec_from_file_location("asset_rights_gate", MODULE_PATH)
assert SPEC and SPEC.loader
gate = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = gate
SPEC.loader.exec_module(gate)


def png_chunk(chunk_type: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + chunk_type
        + payload
        + struct.pack(">I", zlib.crc32(chunk_type + payload) & 0xFFFFFFFF)
    )


def bmff_box(box_type: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload) + 8) + box_type + payload


def generated_c2pa_png() -> bytes:
    metadata = (
        b"c2pa.claim.v2; c2pa.signature; OpenAI Media Service API; "
        b"OpenAI OpCo, LLC; 432f0c21-7424-479c-84ad-6328658d06ec; "
        b"2026-06-01T00:00:00Z"
    )
    cabx = bmff_box(
        b"jumb",
        bmff_box(b"jumd", b"jumdc2pa\x00") + bmff_box(b"cbor", metadata),
    )
    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", ihdr)
        + png_chunk(b"caBX", cabx)
        + png_chunk(b"IDAT", zlib.compress(b"\x00\x00\x00\x00"))
        + png_chunk(b"IEND", b"")
    )


class AssetRightsGateTests(unittest.TestCase):
    GENERATED_BYTES = generated_c2pa_png()

    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        self.catalog = self.root / "YouNew" / "Assets.xcassets"
        self.evidence = self.root / "ASSET_CREDITS.md"
        self.evidence.parent.mkdir(parents=True, exist_ok=True)
        self.evidence.write_text("# Asset credits\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def add_asset(
        self,
        asset_id: str,
        data: bytes = b"asset payload",
        catalog_group: str = "",
        catalog_suffix: str = ".imageset",
    ) -> dict:
        relative_directory = Path(catalog_group) / f"{asset_id}{catalog_suffix}"
        directory = self.catalog / relative_directory
        directory.mkdir(parents=True, exist_ok=True)
        filename = f"{asset_id}.png"
        payload = directory / filename
        payload.write_bytes(data)
        contents = {
            "images": [{"filename": filename, "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
        }
        (directory / "Contents.json").write_text(
            json.dumps(contents),
            encoding="utf-8",
        )
        return {
            "assetID": asset_id,
            "localDirectory": f"YouNew/Assets.xcassets/{relative_directory.as_posix()}",
            "localFiles": [
                {
                    "path": f"YouNew/Assets.xcassets/{relative_directory.as_posix()}/{filename}",
                    "sha1": hashlib.sha1(data).hexdigest(),
                }
            ],
            "family": "project_map",
            "bucket": "project_owned",
            "status": "project_owned_documented",
            "sourcePageURL": None,
            "creator": "YouNew project",
            "licenseName": "Project-owned",
            "licenseURL": None,
            "attributionRequired": False,
            "evidence": [
                "BuildWeekFix/PROJECT_OWNED_ASSET_EVIDENCE.json",
                "ASSET_CREDITS.md",
            ],
            "ownershipBasis": "repository_original",
            "note": "Original source and generation history are documented.",
        }

    def ledger(self, records: list[dict]) -> dict:
        by_bucket: dict[str, int] = {}
        by_status: dict[str, int] = {}
        by_family: dict[str, int] = {}
        for record in records:
            for destination, key in (
                (by_bucket, "bucket"),
                (by_status, "status"),
                (by_family, "family"),
            ):
                value = record[key]
                destination[value] = destination.get(value, 0) + 1
        return {
            "schemaVersion": 1,
            "generatedAt": "2026-07-22",
            "scope": "YouNew/Assets.xcassets",
            "disclaimer": "Engineering evidence inventory, not legal advice.",
            "methodology": ["Hash every asset payload and verify repository evidence."],
            "summary": {
                "totalAssets": len(records),
                "byBucket": dict(sorted(by_bucket.items())),
                "byStatus": dict(sorted(by_status.items())),
                "byFamily": dict(sorted(by_family.items())),
            },
            "records": records,
        }

    def make_third_party(self, record: dict, family: str = "netherlands_photography") -> dict:
        record.update(
            {
                "family": family,
                "bucket": "cleared_with_conditions",
                "status": "third_party_attribution_ready",
                "sourcePageURL": "https://commons.wikimedia.org/wiki/File:Example.jpg",
                "creator": "Example Creator",
                "licenseName": "CC BY 4.0",
                "licenseURL": "https://creativecommons.org/licenses/by/4.0",
                "attributionRequired": True,
                "creditLine": "Example Creator; CC BY 4.0",
                "modificationNotice": "Resized and converted for in-app display.",
                "evidence": ["ASSET_CREDITS.md"],
                "note": "Attribution metadata is documented.",
            }
        )
        return record

    def add_evidence_file(self, relative_path: str, content: str = "evidence\n") -> None:
        path = self.root / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def add_generated_evidence(self, source: dict, covered_asset_ids: list[str]) -> None:
        digest = source["localFiles"][0]["sha1"]
        attestation = "\n".join(
            [
                "# Media rights owner attestation",
                "Attestation status: CONFIRMED",
                "Attested by: Ivan Chernikov",
                "Attested on: 2026-07-22",
                *[f"Asset: {asset_id}" for asset_id in covered_asset_ids],
                f"SHA-1: {digest}",
                "",
            ]
        )
        self.add_evidence_file(
            "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
            attestation,
        )
        c2pa = {
            "schemaVersion": 1,
            "evidenceType": "embedded_c2pa_container_metadata",
            "validationLevel": "structural_markers_and_metadata_only",
            "signatureValidated": False,
            "limitation": "Structural and embedded metadata checks only; signature chain is not validated.",
            "records": [
                {
                    "assetID": source["assetID"],
                    "path": source["localFiles"][0]["path"],
                    "sha1": digest,
                    "generator": "OpenAI Media Service API",
                    "provider": "OpenAI OpCo, LLC",
                    "xmpInstanceID": "432f0c21-7424-479c-84ad-6328658d06ec",
                    "createdAt": "2026-06-01T00:00:00Z",
                }
            ],
        }
        self.add_evidence_file(
            "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
            json.dumps(c2pa),
        )

    def make_city_symbol(self, record: dict) -> dict:
        digest = record["localFiles"][0]["sha1"]
        local_path = record["localFiles"][0]["path"]
        source_url = "https://commons.wikimedia.org/wiki/File:Example.svg"
        license_url = "https://creativecommons.org/publicdomain/mark/1.0/"
        record.update(
            {
                "family": "city_symbol",
                "bucket": "cleared",
                "status": "public_domain_byte_exact",
                "sourcePageURL": source_url,
                "creator": "Example Creator",
                "licenseName": "Public domain",
                "licenseURL": license_url,
                "attributionRequired": False,
                "evidence": ["BuildWeekFix/CITY_SYMBOL_RIGHTS.json"],
                "commons": {
                    "localMatch": "current_byte_exact",
                    "remoteCurrentSHA1": digest,
                    "checkedAt": "2026-07-22",
                },
            }
        )
        city_evidence = {
            "schemaVersion": 1,
            "generatedAt": "2026-07-22",
            "source": "Wikimedia Commons API",
            "records": [
                {
                    "assetID": record["assetID"],
                    "sourcePageURL": source_url,
                    "creator": "Example Creator",
                    "licenseName": "Public domain",
                    "licenseURL": license_url,
                    "commonsSHA1": digest,
                    "localPath": local_path,
                    "localSHA1": digest,
                    "retrievedAt": "2026-07-22",
                }
            ],
        }
        self.add_evidence_file(
            "BuildWeekFix/CITY_SYMBOL_RIGHTS.json",
            json.dumps(city_evidence),
        )
        return record

    def add_third_party_asset_evidence(self, record: dict) -> None:
        local_file = record["localFiles"][0]
        payload = {
            "schemaVersion": 1,
            "generatedAt": "2026-07-22",
            "source": "Wikimedia Commons API and byte-exact thumbnail retrieval",
            "records": [
                {
                    "assetID": record["assetID"],
                    "sourcePageURL": record["sourcePageURL"],
                    "originalFileURL": "https://upload.wikimedia.org/original.jpg",
                    "thumbnailURL": "https://upload.wikimedia.org/thumbnail.jpg",
                    "creator": record["creator"],
                    "licenseName": record["licenseName"],
                    "licenseURL": record["licenseURL"],
                    "originalSHA1": "1" * 40,
                    "originalWidth": 2000,
                    "originalHeight": 1200,
                    "localPath": local_file["path"],
                    "localSHA1": local_file["sha1"],
                    "localWidth": 1000,
                    "localHeight": 600,
                    "modificationNotice": record["modificationNotice"],
                    "retrievedAt": "2026-07-22",
                }
            ],
        }
        self.add_evidence_file(
            "BuildWeekFix/THIRD_PARTY_ASSET_EVIDENCE.json",
            json.dumps(payload),
        )

    def add_media_attributions(self, records: list[dict]) -> None:
        payload = []
        for record in records:
            asset_id = record["assetID"]
            category = "app_context"
            for suffix, mapped_category in (
                ("_hero_01", "city_hero"),
                ("_card_01", "city_card"),
                ("_landmark_01", "landmark"),
                ("_province_01", "province"),
            ):
                if asset_id.startswith("nl_") and asset_id.endswith(suffix):
                    category = mapped_category
                    break
            payload.append(
                {
                    "id": asset_id,
                    "title": "File:Example.jpg",
                    "creator": record["creator"],
                    "creditLine": record["creditLine"],
                    "licenseName": record["licenseName"],
                    "licenseURL": record["licenseURL"],
                    "sourcePageURL": record["sourcePageURL"],
                    "attributionRequired": record["attributionRequired"],
                    "category": category,
                    "city": None,
                    "province": None,
                    "landmarkName": None,
                }
            )
        self.add_evidence_file(
            "YouNew/Resources/MediaAttributions.json",
            json.dumps(payload),
        )

    def validate(self, ledger: dict) -> list[str]:
        project_owned_records = [
            record
            for record in ledger.get("records", [])
            if isinstance(record, dict)
            and record.get("ownershipBasis") == "repository_original"
        ]
        if project_owned_records:
            evidence = {
                "schemaVersion": 1,
                "records": [
                    {
                        "assetID": record["assetID"],
                        "family": record["family"],
                        "ownershipBasis": "repository_original",
                        "creator": record["creator"],
                        "localPath": record["localFiles"][0]["path"],
                        "localSHA1": record["localFiles"][0]["sha1"],
                        "evidence": ["ASSET_CREDITS.md"],
                        "note": record["note"],
                    }
                    for record in project_owned_records
                ],
            }
            self.add_evidence_file(
                "BuildWeekFix/PROJECT_OWNED_ASSET_EVIDENCE.json",
                json.dumps(evidence),
            )
        assets = gate.inventory_catalog(self.root, self.catalog)
        return gate.validate_ledger(self.root, ledger, assets)

    def test_zero_unresolved_complete_ledger_passes(self) -> None:
        record = self.add_asset("map_test")

        self.assertEqual(self.validate(self.ledger([record])), [])

    def test_payload_sha_mismatch_fails(self) -> None:
        record = self.add_asset("map_test")
        record["localFiles"][0]["sha1"] = "0" * 40

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("payload SHA-1 mismatch" in error for error in errors))

    def test_missing_catalog_record_fails(self) -> None:
        self.add_asset("map_test")

        errors = self.validate(self.ledger([]))

        self.assertTrue(any("ledger is missing catalog assets" in error for error in errors))

    def test_unresolved_record_blocks_release(self) -> None:
        record = self.add_asset("unknown_background")
        record.update(
            {
                "family": "other_ui_media",
                "bucket": "unresolved",
                "status": "provenance_missing",
                "sourcePageURL": None,
                "creator": None,
                "licenseName": None,
                "licenseURL": None,
                "attributionRequired": None,
                "evidence": [],
                "note": "No reconciled file-level rights record found.",
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("release is blocked: unresolved=1" in error for error in errors))

    def test_forged_summary_fails(self) -> None:
        record = self.add_asset("map_test")
        ledger = self.ledger([record])
        ledger["summary"]["byBucket"] = {"project_owned": 0}

        errors = self.validate(ledger)

        self.assertIn("summary.byBucket does not match records", errors)

    def test_missing_repository_evidence_fails(self) -> None:
        record = self.add_asset("map_test")
        record["evidence"] = ["missing/OWNER_ATTESTATION.md"]

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("evidence file is missing" in error for error in errors))

    def test_arbitrary_evidence_text_cannot_clear_asset(self) -> None:
        record = self.add_asset("map_test")
        record["evidence"] = ["Owner confirms this asset"]

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("evidence file is missing" in error for error in errors))

    def test_absolute_evidence_path_is_rejected_even_when_file_exists(self) -> None:
        record = self.add_asset("map_test")
        record["evidence"] = [str(self.evidence)]

        errors = self.validate(self.ledger([record]))

        self.assertTrue(
            any("evidence path must be repository-relative" in error for error in errors)
        )

    def test_nested_catalog_asset_cannot_be_hidden_from_ledger(self) -> None:
        record = self.add_asset("map_test")
        self.add_asset(
            "hidden_asset",
            catalog_group="Nested/Deep",
            catalog_suffix=".appiconset",
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(
            any("ledger is missing catalog assets: ['hidden_asset']" in error for error in errors)
        )

    def test_duplicate_asset_id_in_nested_groups_fails_inventory(self) -> None:
        self.add_asset("duplicate", catalog_group="First")
        self.add_asset(
            "duplicate",
            catalog_group="Second",
            catalog_suffix=".appiconset",
        )

        with self.assertRaisesRegex(
            gate.RightsGateError,
            "duplicate catalog asset ID: duplicate",
        ):
            gate.inventory_catalog(self.root, self.catalog)

    def test_unreferenced_payload_fails_catalog_inventory(self) -> None:
        self.add_asset("map_test")
        directory = self.catalog / "map_test.imageset"
        (directory / "stray.png").write_bytes(b"not in Contents.json")

        with self.assertRaises(gate.RightsGateError):
            gate.inventory_catalog(self.root, self.catalog)

    def test_city_symbol_is_cross_checked_against_commons_evidence(self) -> None:
        record = self.make_city_symbol(self.add_asset("city_example_flag", b"svg"))

        self.assertEqual(self.validate(self.ledger([record])), [])

    def test_city_symbol_evidence_mismatch_fails(self) -> None:
        record = self.make_city_symbol(self.add_asset("city_example_flag", b"svg"))
        record["creator"] = "Different Creator"

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("evidence creator does not match" in error for error in errors))

    def test_city_symbol_cannot_use_self_consistent_non_commons_license_claim(self) -> None:
        record = self.make_city_symbol(self.add_asset("city_example_flag", b"svg"))
        fake_source = "https://example.invalid/not-commons"
        fake_license = "https://example.invalid/license"
        record.update(
            {
                "sourcePageURL": fake_source,
                "licenseName": "Invented public-domain claim",
                "licenseURL": fake_license,
            }
        )
        evidence_path = self.root / "BuildWeekFix/CITY_SYMBOL_RIGHTS.json"
        evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
        evidence["records"][0].update(
            {
                "sourcePageURL": fake_source,
                "licenseName": "Invented public-domain claim",
                "licenseURL": fake_license,
            }
        )
        evidence_path.write_text(json.dumps(evidence), encoding="utf-8")

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("must be a Wikimedia Commons File page" in error for error in errors))
        self.assertTrue(any("licenseName must be Public domain" in error for error in errors))

    def test_public_domain_status_cannot_clear_unregistered_ui_asset(self) -> None:
        record = self.add_asset("invented_public_domain_ui", b"payload")
        digest = record["localFiles"][0]["sha1"]
        record.update(
            {
                "family": "other_ui_media",
                "bucket": "cleared",
                "status": "public_domain_byte_exact",
                "sourcePageURL": "https://example.invalid/source",
                "creator": "Invented Creator",
                "licenseName": "Invented public-domain claim",
                "licenseURL": "https://example.invalid/license",
                "attributionRequired": False,
                "evidence": ["ASSET_CREDITS.md"],
                "commons": {
                    "localMatch": "current_byte_exact",
                    "remoteCurrentSHA1": digest,
                    "checkedAt": "2026-07-22",
                },
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("limited to governed city_symbol assets" in error for error in errors))

    def test_third_party_status_cannot_clear_asset_outside_attribution_registry(self) -> None:
        record = self.make_third_party(
            self.add_asset("invented_third_party_ui", b"licensed image"),
            family="other_ui_media",
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(
            any("requires coverage in the media attribution registry" in error for error in errors)
        )

    def test_malformed_status_is_reported_without_crashing(self) -> None:
        record = self.add_asset("map_test")
        ledger = self.ledger([record])
        record["status"] = ["not", "a", "status"]

        errors = self.validate(ledger)

        self.assertTrue(any("invalid status" in error for error in errors))

    def test_exact_ui_alias_requires_and_validates_derivation(self) -> None:
        source = self.make_third_party(
            self.add_asset("nl_amsterdam_hero_01", b"licensed image")
        )
        alias = self.make_third_party(
            self.add_asset("app_amsterdam_evening_background", b"licensed image"),
            family="other_ui_media",
        )
        alias["derivedFromAssetID"] = "nl_amsterdam_hero_01"
        alias["derivationKind"] = "exact_copy"
        source["evidence"].append("YouNew/Resources/MediaAttributions.json")
        alias["evidence"].append("YouNew/Resources/MediaAttributions.json")
        self.add_media_attributions([source, alias])

        self.assertEqual(self.validate(self.ledger([source, alias])), [])

    def test_direct_third_party_ui_does_not_require_derivation(self) -> None:
        record = self.make_third_party(
            self.add_asset("home_documents_city_hall", b"licensed image"),
            family="other_ui_media",
        )
        record["evidence"].append("BuildWeekFix/THIRD_PARTY_ASSET_EVIDENCE.json")
        record["evidence"].append("YouNew/Resources/MediaAttributions.json")
        self.add_third_party_asset_evidence(record)
        self.add_media_attributions([record])

        self.assertEqual(self.validate(self.ledger([record])), [])

    def test_photo_metadata_is_cross_checked_against_bundled_attribution(self) -> None:
        record = self.make_third_party(
            self.add_asset("nl_amsterdam_hero_01", b"licensed image")
        )
        record["evidence"].append("YouNew/Resources/MediaAttributions.json")
        self.add_media_attributions([record])
        record["creator"] = "Invented Creator"

        errors = self.validate(self.ledger([record]))

        self.assertTrue(
            any("ledger creator does not match media attribution registry" in error for error in errors)
        )

    def test_unknown_media_attribution_category_cannot_hide_credit(self) -> None:
        record = self.make_third_party(
            self.add_asset("nl_amsterdam_hero_01", b"licensed image")
        )
        record["evidence"].append("YouNew/Resources/MediaAttributions.json")
        self.add_media_attributions([record])
        path = self.root / "YouNew/Resources/MediaAttributions.json"
        payload = json.loads(path.read_text(encoding="utf-8"))
        payload[0]["category"] = "typo_hidden_category"
        path.write_text(json.dumps(payload), encoding="utf-8")

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("unsupported media attribution category" in error for error in errors))

    def test_attributed_photo_cannot_be_reclassified_as_project_owned(self) -> None:
        record = self.make_third_party(
            self.add_asset("nl_amsterdam_hero_01", b"licensed image")
        )
        record["evidence"].append("YouNew/Resources/MediaAttributions.json")
        self.add_media_attributions([record])
        record.update(
            {
                "family": "project_map",
                "bucket": "project_owned",
                "status": "project_owned_documented",
                "sourcePageURL": None,
                "creator": "YouNew project",
                "licenseName": "Project-owned",
                "licenseURL": None,
                "attributionRequired": False,
                "evidence": ["ASSET_CREDITS.md"],
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("must use family=netherlands_photography" in error for error in errors))
        self.assertTrue(any("must be third_party_attribution_ready" in error for error in errors))

    def test_required_ui_alias_without_derivation_is_rejected(self) -> None:
        alias = self.make_third_party(
            self.add_asset("app_amsterdam_evening_background", b"licensed image"),
            family="other_ui_media",
        )

        errors = self.validate(self.ledger([alias]))

        self.assertTrue(any("requires derivedFromAssetID" in error for error in errors))

    def test_project_owned_ui_requires_ownership_basis(self) -> None:
        record = self.add_asset("premium_home_documents")
        record["family"] = "other_ui_media"
        record.pop("ownershipBasis")
        record["evidence"] = ["ASSET_CREDITS.md"]

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("ownershipBasis must be one of" in error for error in errors))

    def test_every_project_owned_family_requires_ownership_basis(self) -> None:
        record = self.add_asset("city_example_flag")
        record["family"] = "city_symbol"
        record.pop("ownershipBasis")
        record["evidence"] = ["ASSET_CREDITS.md"]

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("ownershipBasis must be one of" in error for error in errors))

    def test_generated_project_media_requires_attestation_and_c2pa(self) -> None:
        record = self.add_asset("premium_home_documents")
        record.update(
            {
                "family": "other_ui_media",
                "ownershipBasis": "generated_for_project",
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("MEDIA_RIGHTS_OWNER_ATTESTATION.md" in error for error in errors))
        self.assertTrue(any("C2PA_MEDIA_EVIDENCE.json" in error for error in errors))

    def test_generated_project_media_with_required_evidence_passes(self) -> None:
        record = self.add_asset("premium_home_documents", self.GENERATED_BYTES)
        self.add_generated_evidence(record, ["premium_home_documents"])
        record.update(
            {
                "family": "other_ui_media",
                "ownershipBasis": "generated_for_project",
                "evidence": [
                    "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
                    "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
                ],
            }
        )

        self.assertEqual(self.validate(self.ledger([record])), [])

    def test_generated_metadata_text_without_c2pa_structure_cannot_pass(self) -> None:
        spoofed = (
            b"OpenAI Media Service API; OpenAI OpCo, LLC; "
            b"432f0c21-7424-479c-84ad-6328658d06ec; 2026-06-01T00:00:00Z"
        )
        record = self.add_asset("premium_home_documents", spoofed)
        self.add_generated_evidence(record, ["premium_home_documents"])
        record.update(
            {
                "family": "other_ui_media",
                "ownershipBasis": "generated_for_project",
                "evidence": [
                    "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
                    "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
                ],
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("invalid embedded C2PA/JUMBF structure" in error for error in errors))

    def test_generated_metadata_evidence_must_name_covered_asset(self) -> None:
        record = self.add_asset("premium_home_documents", self.GENERATED_BYTES)
        self.add_generated_evidence(record, ["premium_home_documents"])
        record.update(
            {
                "family": "other_ui_media",
                "ownershipBasis": "generated_for_project",
                "evidence": [
                    "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
                    "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
                ],
            }
        )
        path = self.root / "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json"
        evidence = json.loads(path.read_text(encoding="utf-8"))
        evidence["records"][0]["assetID"] = "different_asset"
        path.write_text(json.dumps(evidence), encoding="utf-8")

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("assetID must match covered source asset" in error for error in errors))

    def test_empty_attestation_cannot_clear_generated_media(self) -> None:
        record = self.add_asset("premium_home_documents", self.GENERATED_BYTES)
        self.add_generated_evidence(record, ["premium_home_documents"])
        self.add_evidence_file(
            "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
            "# Unsigned template\n",
        )
        record.update(
            {
                "family": "other_ui_media",
                "ownershipBasis": "generated_for_project",
                "evidence": [
                    "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
                    "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
                ],
            }
        )

        errors = self.validate(self.ledger([record]))

        self.assertTrue(any("attestation status must be CONFIRMED" in error for error in errors))

    def test_exact_project_owned_alias_inherits_resolved_source(self) -> None:
        shared_fields = {
            "family": "other_ui_media",
            "ownershipBasis": "generated_for_project",
            "evidence": [
                "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md",
                "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json",
            ],
        }
        source = self.add_asset("premium_home_emergency", self.GENERATED_BYTES)
        source.update(shared_fields)
        alias = self.add_asset("home_emergency_ambulance", self.GENERATED_BYTES)
        alias.update(shared_fields)
        alias["derivedFromAssetID"] = "premium_home_emergency"
        alias["derivationKind"] = "exact_copy"
        self.add_generated_evidence(source, ["premium_home_emergency"])

        self.assertEqual(self.validate(self.ledger([source, alias])), [])

if __name__ == "__main__":
    unittest.main()
