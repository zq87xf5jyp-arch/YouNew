#!/usr/bin/env python3
"""Regenerate the asset-rights ledger from catalog bytes and evidence records."""

from __future__ import annotations

import argparse
import importlib.util
import json
import sys
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = ROOT / "BuildWeekFix" / "ASSET_RIGHTS_STATUS.json"
CATALOG_PATH = ROOT / "YouNew" / "Assets.xcassets"
CITY_EVIDENCE_PATH = ROOT / "BuildWeekFix" / "CITY_SYMBOL_RIGHTS.json"
THIRD_PARTY_EVIDENCE_PATH = ROOT / "BuildWeekFix" / "THIRD_PARTY_ASSET_EVIDENCE.json"
PROJECT_OWNED_EVIDENCE_PATH = ROOT / "BuildWeekFix" / "PROJECT_OWNED_ASSET_EVIDENCE.json"
ATTRIBUTIONS_PATH = ROOT / "YouNew" / "Resources" / "MediaAttributions.json"

OWNER_ATTESTATION = "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md"
C2PA_EVIDENCE = "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json"
CITY_EVIDENCE = "BuildWeekFix/CITY_SYMBOL_RIGHTS.json"
THIRD_PARTY_EVIDENCE = "BuildWeekFix/THIRD_PARTY_ASSET_EVIDENCE.json"
PROJECT_OWNED_EVIDENCE = "BuildWeekFix/PROJECT_OWNED_ASSET_EVIDENCE.json"
ATTRIBUTIONS_EVIDENCE = "YouNew/Resources/MediaAttributions.json"
ATTRIBUTION_GUIDE = "MEDIA_ATTRIBUTION.md"

GENERATED_ASSETS = {
    "premium_home_documents",
    "premium_home_emergency",
    "premium_home_healthcare",
    "premium_home_housing",
    "premium_home_language",
    "premium_home_work",
}

GENERATED_ALIASES = {
    "home_emergency_ambulance": "premium_home_emergency",
    "home_language_classroom": "premium_home_language",
    "home_work_zuidas": "premium_home_work",
}

DIRECT_COMMONS_UI_ASSETS = {
    "home_documents_city_hall",
    "home_healthcare_pharmacy",
    "home_leiden_canals",
}


def load_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def load_gate_module():
    path = ROOT / "scripts" / "asset-rights-gate.py"
    spec = importlib.util.spec_from_file_location("asset_rights_gate", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load validator: {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def keyed_records(payload: object, path: Path, key: str = "assetID") -> dict[str, dict]:
    if not isinstance(payload, dict) or not isinstance(payload.get("records"), list):
        raise RuntimeError(f"evidence has no records array: {path}")
    records: dict[str, dict] = {}
    for item in payload["records"]:
        if not isinstance(item, dict) or not isinstance(item.get(key), str):
            raise RuntimeError(f"invalid record in {path}")
        value = item[key]
        if value in records:
            raise RuntimeError(f"duplicate {key}={value} in {path}")
        records[value] = item
    return records


def attribution_records(payload: object) -> dict[str, dict]:
    if not isinstance(payload, list):
        raise RuntimeError(f"attribution manifest must be an array: {ATTRIBUTIONS_PATH}")
    records: dict[str, dict] = {}
    for item in payload:
        if not isinstance(item, dict) or not isinstance(item.get("id"), str):
            raise RuntimeError(f"invalid attribution in {ATTRIBUTIONS_PATH}")
        if item["id"] in records:
            raise RuntimeError(f"duplicate attribution id={item['id']}")
        records[item["id"]] = item
    return records


def catalog_fields(asset) -> dict:
    return {
        "assetID": asset.asset_id,
        "localDirectory": asset.directory,
        "localFiles": [
            {"path": path, "sha1": digest}
            for path, digest in sorted(asset.files.items())
        ],
    }


def city_symbol_record(asset, evidence: dict) -> dict:
    return {
        **catalog_fields(asset),
        "family": "city_symbol",
        "bucket": "cleared",
        "status": "public_domain_byte_exact",
        "sourcePageURL": evidence["sourcePageURL"],
        "creator": evidence["creator"],
        "licenseName": evidence["licenseName"],
        "licenseURL": evidence["licenseURL"],
        "attributionRequired": False,
        "evidence": [CITY_EVIDENCE],
        "commons": {
            "localMatch": "current_byte_exact",
            "remoteCurrentSHA1": evidence["commonsSHA1"],
            "checkedAt": evidence["retrievedAt"],
        },
        "note": "Catalog payload is byte-exact with the current Wikimedia Commons file recorded in CITY_SYMBOL_RIGHTS.json.",
    }


def project_owned_record(
    asset,
    *,
    family: str,
    creator: str,
    ownership_basis: str,
    evidence: list[str],
    note: str,
) -> dict:
    return {
        **catalog_fields(asset),
        "family": family,
        "bucket": "project_owned",
        "status": "project_owned_documented",
        "sourcePageURL": None,
        "creator": creator,
        "licenseName": "Project-owned",
        "licenseURL": None,
        "attributionRequired": False,
        "evidence": evidence,
        "ownershipBasis": ownership_basis,
        "note": note,
    }


def generated_record(asset) -> dict:
    record = project_owned_record(
        asset,
        family="other_ui_media",
        creator="YouNew project (generated with OpenAI Media Service API)",
        ownership_basis="generated_for_project",
        evidence=[OWNER_ATTESTATION, C2PA_EVIDENCE],
        note="Owner confirmation and byte-linked C2PA/JUMBF structural metadata are recorded; the offline gate does not claim cryptographic signature validation.",
    )
    return record


def project_authored_record(asset, evidence: dict) -> dict:
    required_fields = (
        "family",
        "ownershipBasis",
        "creator",
        "localPath",
        "localSHA1",
        "evidence",
        "note",
    )
    missing_fields = [field for field in required_fields if not evidence.get(field)]
    if missing_fields:
        raise RuntimeError(
            f"project-owned evidence is incomplete for {asset.asset_id}: {missing_fields}"
        )
    if evidence["family"] not in {"project_map", "province_flag"}:
        raise RuntimeError(f"project-owned evidence has invalid family: {asset.asset_id}")
    if evidence["ownershipBasis"] != "repository_original":
        raise RuntimeError(f"project-owned evidence has invalid ownershipBasis: {asset.asset_id}")
    if not isinstance(evidence["evidence"], list) or not all(
        isinstance(item, str) and item for item in evidence["evidence"]
    ):
        raise RuntimeError(f"project-owned evidence has invalid evidence paths: {asset.asset_id}")
    expected_files = {evidence["localPath"]: evidence["localSHA1"]}
    if asset.files != expected_files:
        raise RuntimeError(
            f"project-owned evidence path/SHA-1 does not match catalog payload: {asset.asset_id}"
        )
    return project_owned_record(
        asset,
        family=evidence["family"],
        creator=evidence["creator"],
        ownership_basis=evidence["ownershipBasis"],
        evidence=[PROJECT_OWNED_EVIDENCE, *evidence["evidence"]],
        note=evidence["note"],
    )


def attributed_record(
    asset,
    attribution: dict,
    *,
    family: str,
    modification_notice: str,
) -> dict:
    return {
        **catalog_fields(asset),
        "family": family,
        "bucket": "cleared_with_conditions",
        "status": "third_party_attribution_ready",
        "sourcePageURL": attribution["sourcePageURL"],
        "creator": attribution["creator"],
        "licenseName": attribution["licenseName"],
        "licenseURL": attribution["licenseURL"],
        "attributionRequired": attribution["attributionRequired"],
        "creditLine": attribution["creditLine"],
        "modificationNotice": modification_notice,
        "evidence": [ATTRIBUTIONS_EVIDENCE, ATTRIBUTION_GUIDE],
    }


def netherlands_photo_record(asset, attribution: dict) -> dict:
    return attributed_record(
        asset,
        attribution,
        family="netherlands_photography",
        modification_notice="Resized and, where needed, cropped; distributed as JPEG for app display.",
    )


def direct_commons_record(asset, attribution: dict, evidence: dict) -> dict:
    record = attributed_record(
        asset,
        attribution,
        family="other_ui_media",
        modification_notice=evidence["modificationNotice"],
    )
    record["evidence"] = [THIRD_PARTY_EVIDENCE, *record["evidence"]]
    record["note"] = "Official Commons thumbnail bytes and attribution metadata are recorded for release."
    return record


def app_icon_record(asset) -> dict:
    record = project_owned_record(
        asset,
        family="app_icon",
        creator="YouNew project",
        ownership_basis="owner_attestation",
        evidence=[
            "Design/AppIcon/source.svg",
            "scripts/generate-app-icons.py",
            "scripts/generate-app-icons.swift",
            OWNER_ATTESTATION,
        ],
        note="Owner confirmation covers the vector source, deterministic generators, and current icon outputs.",
    )
    return record


def counts(records: list[dict], field: str) -> dict[str, int]:
    return dict(sorted(Counter(record[field] for record in records).items()))


def build_ledger() -> dict:
    gate = load_gate_module()
    assets = gate.inventory_catalog(ROOT, CATALOG_PATH)

    city_payload = load_json(CITY_EVIDENCE_PATH)
    city_by_id = keyed_records(city_payload, CITY_EVIDENCE_PATH)
    third_party_by_id = keyed_records(
        load_json(THIRD_PARTY_EVIDENCE_PATH),
        THIRD_PARTY_EVIDENCE_PATH,
    )
    project_owned_payload = load_json(PROJECT_OWNED_EVIDENCE_PATH)
    if not isinstance(project_owned_payload, dict) or project_owned_payload.get("schemaVersion") != 1:
        raise RuntimeError(f"invalid project-owned evidence schema: {PROJECT_OWNED_EVIDENCE_PATH}")
    project_owned_by_id = keyed_records(project_owned_payload, PROJECT_OWNED_EVIDENCE_PATH)
    attributions = attribution_records(load_json(ATTRIBUTIONS_PATH))

    city_asset_ids = {asset_id for asset_id in assets if asset_id.startswith("city_")}
    source_groups = (
        set(city_by_id),
        set(project_owned_by_id),
        set(attributions),
        {"AppIcon"},
        GENERATED_ASSETS,
        set(GENERATED_ALIASES),
    )
    duplicate_source_ids = sorted(
        asset_id
        for asset_id in set().union(*source_groups)
        if sum(asset_id in group for group in source_groups) != 1
    )
    if duplicate_source_ids:
        raise RuntimeError(f"asset IDs occur in multiple independent sources: {duplicate_source_ids}")
    expected_asset_ids = (
        set().union(*source_groups)
    )
    if expected_asset_ids != set(assets):
        missing = sorted(set(assets) - expected_asset_ids)
        unexpected = sorted(expected_asset_ids - set(assets))
        raise RuntimeError(
            "independent source records do not exactly cover the catalog; "
            f"missing={missing}, unexpected={unexpected}"
        )
    if set(city_by_id) != city_asset_ids:
        raise RuntimeError("CITY_SYMBOL_RIGHTS.json does not exactly cover catalog city symbols")
    photo_ids = {asset_id for asset_id in attributions if asset_id.startswith("nl_")}
    app_context_ids = set(attributions) - photo_ids
    if len(photo_ids) != 72:
        raise RuntimeError("MediaAttributions.json must govern exactly 72 Netherlands-pack photographs")
    if app_context_ids != DIRECT_COMMONS_UI_ASSETS | {"app_amsterdam_evening_background"}:
        raise RuntimeError("MediaAttributions.json has unexpected non-photography coverage")
    project_family_counts = Counter(
        evidence.get("family") for evidence in project_owned_by_id.values()
    )
    if project_family_counts != Counter({"project_map": 14, "province_flag": 12}):
        raise RuntimeError(
            "PROJECT_OWNED_ASSET_EVIDENCE.json must govern 14 maps and 12 province flags"
        )
    if set(DIRECT_COMMONS_UI_ASSETS) != set(third_party_by_id):
        raise RuntimeError("THIRD_PARTY_ASSET_EVIDENCE.json has unexpected coverage")

    records: list[dict] = []
    for asset_id, asset in sorted(assets.items()):
        if asset_id in city_by_id:
            record = city_symbol_record(asset, city_by_id[asset_id])
        elif asset_id == "AppIcon":
            record = app_icon_record(asset)
        elif asset_id in GENERATED_ASSETS:
            record = generated_record(asset)
        elif asset_id in GENERATED_ALIASES:
            record = generated_record(asset)
            record["derivedFromAssetID"] = GENERATED_ALIASES[asset_id]
            record["derivationKind"] = "exact_copy"
        elif asset_id in DIRECT_COMMONS_UI_ASSETS:
            record = direct_commons_record(
                asset,
                attributions[asset_id],
                third_party_by_id[asset_id],
            )
        elif asset_id == "app_amsterdam_evening_background":
            record = attributed_record(
                asset,
                attributions[asset_id],
                family="other_ui_media",
                modification_notice="Exact byte copy of nl_amsterdam_hero_01 for compatibility; no additional modification.",
            )
            record.update(
                {
                    "derivedFromAssetID": "nl_amsterdam_hero_01",
                    "derivationKind": "exact_copy",
                    "note": "Compatibility alias inherits the independently attributed source record and byte identity.",
                }
            )
        elif asset_id in project_owned_by_id:
            record = project_authored_record(asset, project_owned_by_id[asset_id])
        elif asset_id in attributions and asset_id.startswith("nl_"):
            record = netherlands_photo_record(asset, attributions[asset_id])
        else:
            raise RuntimeError(f"catalog asset has no independently governed source record: {asset_id}")
        records.append(record)

    generated_at = city_payload.get("generatedAt") if isinstance(city_payload, dict) else None
    ledger = {
        "schemaVersion": 1,
        "generatedAt": generated_at,
        "scope": "YouNew/Assets.xcassets",
        "disclaimer": "Engineering evidence inventory, not legal advice. Trademark, official-emblem, personality, and jurisdiction-specific restrictions may still apply.",
        "methodology": [
            "Inventoried every Xcode asset payload and recomputed its SHA-1 from current repository bytes.",
            "Reconciled all 58 city symbols to byte-exact Wikimedia Commons API records in CITY_SYMBOL_RIGHTS.json.",
            "Imported photography credits from the manifest-backed in-app attribution registry.",
            "Verified three direct Commons UI thumbnails against their official width=1920 URLs and recorded original/local SHA-1 values.",
            "Bound all 26 project-owned map and province-flag payloads to the independent path/SHA-1 ownership registry.",
            "Linked AppIcon and generated YouNew artwork to owner confirmation plus byte-linked C2PA/JUMBF structural metadata without claiming offline signature validation.",
            "Required exact-copy aliases to match both the approved source ID and source payload SHA-1.",
        ],
        "summary": {
            "totalAssets": len(records),
            "byBucket": counts(records, "bucket"),
            "byStatus": counts(records, "status"),
            "byFamily": counts(records, "family"),
        },
        "records": records,
    }
    errors = gate.validate_ledger(ROOT, ledger, assets)
    if errors:
        raise RuntimeError("generated ledger failed validation:\n- " + "\n- ".join(errors))
    return ledger


def rendered_ledger() -> str:
    return json.dumps(build_ledger(), ensure_ascii=False, indent=2) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if the ledger is stale.")
    args = parser.parse_args()

    try:
        rendered = rendered_ledger()
    except (KeyError, OSError, RuntimeError, json.JSONDecodeError) as error:
        print(f"Asset-rights ledger generation failed: {error}")
        return 1

    if args.check:
        current = LEDGER_PATH.read_text(encoding="utf-8") if LEDGER_PATH.is_file() else ""
        if current != rendered:
            print(f"Asset-rights ledger is stale: {LEDGER_PATH.relative_to(ROOT)}")
            return 1
        print("Asset-rights ledger is current")
        return 0

    LEDGER_PATH.write_text(rendered, encoding="utf-8")
    print(f"Wrote {LEDGER_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
