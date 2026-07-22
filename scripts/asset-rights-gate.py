#!/usr/bin/env python3
"""Validate the asset-rights ledger against the shipped Xcode asset catalog.

This is an offline, deterministic release gate. It verifies catalog coverage,
payload SHA-1 values, evidence references, status-specific metadata, and
recomputed summary counts. A structurally valid ledger still fails while any
asset remains in the ``unresolved`` bucket.

The gate validates evidence completeness; it is not a legal opinion and does
not infer ownership or a license from the presence of a file in the repository.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
import zlib
from collections import Counter
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_LEDGER = ROOT / "BuildWeekFix" / "ASSET_RIGHTS_STATUS.json"
DEFAULT_CATALOG = ROOT / "YouNew" / "Assets.xcassets"
CATALOG_SUFFIXES = {".imageset", ".appiconset"}
SHA1_PATTERN = re.compile(r"^[0-9a-f]{40}$")

STATUS_BUCKETS = {
    "provenance_missing": "unresolved",
    "owner_attestation_required": "unresolved",
    "source_ownership_conflict": "unresolved",
    "public_domain_byte_exact": "cleared",
    "project_owned_documented": "project_owned",
    "third_party_attribution_ready": "cleared_with_conditions",
}

ALLOWED_FAMILIES = {
    "other_ui_media",
    "app_icon",
    "city_symbol",
    "province_flag",
    "project_map",
    "netherlands_photography",
}

DERIVATION_KINDS = {"exact_copy", "modified_copy"}

REQUIRED_EXACT_DERIVATIONS = {
    "app_amsterdam_evening_background": "nl_amsterdam_hero_01",
    "home_emergency_ambulance": "premium_home_emergency",
    "home_language_classroom": "premium_home_language",
    "home_work_zuidas": "premium_home_work",
}

OWNERSHIP_BASES = {
    "generated_for_project",
    "owner_attestation",
    "repository_original",
}
OWNER_ATTESTATION_EVIDENCE = "BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md"
C2PA_EVIDENCE = "BuildWeekFix/C2PA_MEDIA_EVIDENCE.json"
CITY_SYMBOL_EVIDENCE = "BuildWeekFix/CITY_SYMBOL_RIGHTS.json"
THIRD_PARTY_ASSET_EVIDENCE = "BuildWeekFix/THIRD_PARTY_ASSET_EVIDENCE.json"
PROJECT_OWNED_ASSET_EVIDENCE = "BuildWeekFix/PROJECT_OWNED_ASSET_EVIDENCE.json"
MEDIA_ATTRIBUTIONS_EVIDENCE = "YouNew/Resources/MediaAttributions.json"
DIRECT_COMMONS_UI_ASSETS = {
    "home_documents_city_hall",
    "home_healthcare_pharmacy",
    "home_leiden_canals",
}
ATTRIBUTED_UI_ASSETS = DIRECT_COMMONS_UI_ASSETS | {
    "app_amsterdam_evening_background",
}
NETHERLANDS_PHOTOGRAPHY_ID_PATTERN = re.compile(
    r"^nl_[a-z0-9_]+_(?:hero|card|province|landmark)_01$"
)
UUID_PATTERN = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
    re.IGNORECASE,
)

ALLOWED_THIRD_PARTY_LICENSES = {
    "CC BY 2.0": ("https://creativecommons.org/licenses/by/2.0", True),
    "CC BY 3.0": ("https://creativecommons.org/licenses/by/3.0", True),
    "CC BY 4.0": ("https://creativecommons.org/licenses/by/4.0", True),
    "CC BY-SA 2.0": ("https://creativecommons.org/licenses/by-sa/2.0", True),
    "CC BY-SA 2.5": ("https://creativecommons.org/licenses/by-sa/2.5", True),
    "CC BY-SA 3.0": ("https://creativecommons.org/licenses/by-sa/3.0", True),
    "CC BY-SA 3.0 de": ("https://creativecommons.org/licenses/by-sa/3.0/de/deed.en", True),
    "CC BY-SA 3.0 nl": ("https://creativecommons.org/licenses/by-sa/3.0/nl/deed.en", True),
    "CC BY-SA 4.0": ("https://creativecommons.org/licenses/by-sa/4.0", True),
    "CC0": ("https://creativecommons.org/publicdomain/zero/1.0/", False),
}
ALLOWED_ATTRIBUTION_CATEGORIES = {
    "app_context",
    "city_hero",
    "city_card",
    "landmark",
    "province",
}


@dataclass(frozen=True)
class CatalogAsset:
    asset_id: str
    directory: str
    files: dict[str, str]


class RightsGateError(Exception):
    """Raised when the ledger cannot be read or the catalog cannot be inventoried."""


def sha1(path: Path) -> str:
    digest = hashlib.sha1()  # noqa: S324 - Commons revision identity uses SHA-1.
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_c2pa_payloads(data: bytes) -> list[bytes]:
    """Return CRC-checked caBX chunks from a structurally valid PNG."""
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("source is not a PNG")
    offset = 8
    chunk_types: list[bytes] = []
    payloads: list[bytes] = []
    saw_iend = False
    while offset < len(data):
        if offset + 12 > len(data):
            raise ValueError("truncated PNG chunk")
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        chunk_type = data[offset + 4 : offset + 8]
        payload_start = offset + 8
        payload_end = payload_start + length
        crc_end = payload_end + 4
        if crc_end > len(data):
            raise ValueError("PNG chunk length exceeds file size")
        payload = data[payload_start:payload_end]
        expected_crc = struct.unpack(">I", data[payload_end:crc_end])[0]
        actual_crc = zlib.crc32(chunk_type + payload) & 0xFFFFFFFF
        if expected_crc != actual_crc:
            raise ValueError(f"PNG chunk CRC mismatch: {chunk_type!r}")
        chunk_types.append(chunk_type)
        if chunk_type == b"caBX":
            payloads.append(payload)
        offset = crc_end
        if chunk_type == b"IEND":
            saw_iend = True
            break
    if not saw_iend:
        raise ValueError("PNG has no IEND chunk")
    if offset != len(data):
        raise ValueError("PNG contains trailing bytes after IEND")
    if not chunk_types or chunk_types[0] != b"IHDR":
        raise ValueError("PNG does not begin with IHDR")
    if b"IDAT" not in chunk_types:
        raise ValueError("PNG has no IDAT chunk")
    return payloads


def bmff_boxes(data: bytes) -> list[tuple[bytes, bytes]]:
    """Parse a complete sequence of ISO BMFF/JUMBF boxes."""
    boxes: list[tuple[bytes, bytes]] = []
    offset = 0
    while offset < len(data):
        if offset + 8 > len(data):
            raise ValueError("truncated JUMBF box header")
        size = struct.unpack(">I", data[offset : offset + 4])[0]
        box_type = data[offset + 4 : offset + 8]
        header_size = 8
        if size == 1:
            if offset + 16 > len(data):
                raise ValueError("truncated extended JUMBF box header")
            size = struct.unpack(">Q", data[offset + 8 : offset + 16])[0]
            header_size = 16
        if size == 0:
            size = len(data) - offset
        if size < header_size or offset + size > len(data):
            raise ValueError(f"invalid JUMBF box size for {box_type!r}")
        boxes.append(
            (
                box_type,
                data[offset + header_size : offset + size],
            )
        )
        offset += size
    return boxes


def validate_jumbf_structure(data: bytes) -> None:
    top_level = bmff_boxes(data)
    if len(top_level) != 1 or top_level[0][0] != b"jumb":
        raise ValueError("caBX must contain exactly one top-level jumb box")

    def validate_superbox(payload: bytes) -> None:
        children = bmff_boxes(payload)
        if not children or children[0][0] != b"jumd":
            raise ValueError("every jumb superbox must begin with a jumd description box")
        for box_type, child_payload in children[1:]:
            if box_type == b"jumb":
                validate_superbox(child_payload)

    validate_superbox(top_level[0][1])


def relative_path(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError as error:
        raise RightsGateError(f"path escapes repository root: {path}") from error


def referenced_filenames(value: object) -> set[str]:
    filenames: set[str] = set()
    if isinstance(value, dict):
        for key, child in value.items():
            if key == "filename" and isinstance(child, str) and child.strip():
                filenames.add(child)
            else:
                filenames.update(referenced_filenames(child))
    elif isinstance(value, list):
        for child in value:
            filenames.update(referenced_filenames(child))
    return filenames


def safe_payload_path(directory: Path, filename: str) -> Path:
    relative = Path(filename)
    if relative.is_absolute() or ".." in relative.parts:
        raise RightsGateError(f"unsafe asset filename in {directory}: {filename}")
    payload = (directory / relative).resolve()
    try:
        payload.relative_to(directory.resolve())
    except ValueError as error:
        raise RightsGateError(f"asset filename escapes {directory}: {filename}") from error
    return payload


def inventory_catalog(root: Path, catalog: Path) -> dict[str, CatalogAsset]:
    if not catalog.is_dir():
        raise RightsGateError(f"asset catalog is missing: {relative_path(catalog, root)}")

    assets: dict[str, CatalogAsset] = {}
    asset_directories = sorted(
        path
        for path in catalog.rglob("*")
        if path.is_dir() and path.suffix in CATALOG_SUFFIXES
    )
    for directory in asset_directories:
        asset_id = directory.stem
        if asset_id in assets:
            raise RightsGateError(f"duplicate catalog asset ID: {asset_id}")

        contents_path = directory / "Contents.json"
        try:
            contents = json.loads(contents_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise RightsGateError(
                f"invalid asset manifest {relative_path(contents_path, root)}: {error}"
            ) from error

        filenames = referenced_filenames(contents)
        files: dict[str, str] = {}
        for filename in sorted(filenames):
            payload = safe_payload_path(directory, filename)
            if not payload.is_file():
                raise RightsGateError(
                    f"asset {asset_id} references missing payload {relative_path(payload, root)}"
                )
            files[relative_path(payload, root)] = sha1(payload)

        physical_files = {
            relative_path(path, root)
            for path in directory.rglob("*")
            if path.is_file() and path.name != "Contents.json" and not path.name.startswith(".")
        }
        if physical_files != set(files):
            missing_from_manifest = sorted(physical_files - set(files))
            missing_from_disk = sorted(set(files) - physical_files)
            details = []
            if missing_from_manifest:
                details.append(f"unreferenced payloads={missing_from_manifest}")
            if missing_from_disk:
                details.append(f"missing payloads={missing_from_disk}")
            raise RightsGateError(f"asset {asset_id} manifest mismatch: {', '.join(details)}")

        if not files:
            raise RightsGateError(f"asset {asset_id} has no payload file")

        assets[asset_id] = CatalogAsset(
            asset_id=asset_id,
            directory=relative_path(directory, root),
            files=files,
        )
    return assets


def load_ledger(path: Path) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RightsGateError(f"rights ledger is unavailable or invalid: {path}: {error}") from error
    if not isinstance(payload, dict):
        raise RightsGateError("rights ledger root must be an object")
    return payload


def is_nonempty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def is_https_url(value: object) -> bool:
    if not is_nonempty_string(value):
        return False
    parsed = urlparse(str(value))
    return parsed.scheme == "https" and bool(parsed.netloc) and not parsed.username and not parsed.password


def is_commons_file_url(value: object) -> bool:
    if not is_https_url(value):
        return False
    parsed = urlparse(str(value))
    return parsed.hostname == "commons.wikimedia.org" and parsed.path.startswith("/wiki/File:")


def validate_evidence(root: Path, asset_id: str, evidence: object, errors: list[str]) -> list[str]:
    if not isinstance(evidence, list) or not all(is_nonempty_string(item) for item in evidence):
        errors.append(f"{asset_id}: evidence must be an array of non-empty strings")
        return []

    valid_items: list[str] = []
    for item in (str(value) for value in evidence):
        relative = Path(item)
        if relative.is_absolute():
            errors.append(f"{asset_id}: evidence path must be repository-relative: {item}")
            continue
        path = root / relative
        try:
            path.resolve().relative_to(root.resolve())
        except ValueError:
            errors.append(f"{asset_id}: evidence path escapes repository root: {item}")
            continue
        if not path.is_file():
            errors.append(f"{asset_id}: evidence file is missing: {item}")
            continue
        valid_items.append(item)
    return valid_items


def validate_media_attributions(
    root: Path,
    record_by_id: dict[str, dict],
    catalog_asset_ids: set[str],
    errors: list[str],
) -> None:
    """Cross-check every governed photo against the registry bundled into the app."""
    expected_ids = {
        asset_id
        for asset_id in catalog_asset_ids
        if NETHERLANDS_PHOTOGRAPHY_ID_PATTERN.fullmatch(asset_id)
    } | (ATTRIBUTED_UI_ASSETS & catalog_asset_ids)
    if not expected_ids:
        return

    path = root / MEDIA_ATTRIBUTIONS_EVIDENCE
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"media attribution registry cannot be read: {error}")
        return
    if not isinstance(payload, list):
        errors.append("media attribution registry must be an array")
        return

    attribution_by_id: dict[str, dict] = {}
    for index, item in enumerate(payload):
        if not isinstance(item, dict):
            errors.append(f"media attribution[{index}] must be an object")
            continue
        asset_id = item.get("id")
        if not is_nonempty_string(asset_id):
            errors.append(f"media attribution[{index}].id is required")
            continue
        asset_id = str(asset_id)
        if asset_id in attribution_by_id:
            errors.append(f"duplicate media attribution ID: {asset_id}")
            continue
        attribution_by_id[asset_id] = item

        source_url = item.get("sourcePageURL")
        if not is_commons_file_url(source_url):
            errors.append(f"{asset_id}: attribution sourcePageURL must be a Wikimedia Commons File page")

        for field in ("title", "creator", "licenseName", "creditLine"):
            if not is_nonempty_string(item.get(field)):
                errors.append(f"{asset_id}: attribution {field} is required")
        if not isinstance(item.get("attributionRequired"), bool):
            errors.append(f"{asset_id}: attributionRequired must be boolean")

        category = item.get("category")
        if category not in ALLOWED_ATTRIBUTION_CATEGORIES:
            errors.append(f"{asset_id}: unsupported media attribution category: {category}")
        expected_category = "app_context"
        for suffix, mapped_category in (
            ("_hero_01", "city_hero"),
            ("_card_01", "city_card"),
            ("_landmark_01", "landmark"),
            ("_province_01", "province"),
        ):
            if asset_id.startswith("nl_") and asset_id.endswith(suffix):
                expected_category = mapped_category
                break
        if category != expected_category:
            errors.append(
                f"{asset_id}: media attribution category must be {expected_category}, got {category}"
            )

        license_name = item.get("licenseName")
        license_url = item.get("licenseURL")
        attribution_required = item.get("attributionRequired")
        allowed = ALLOWED_THIRD_PARTY_LICENSES.get(str(license_name))
        if allowed is not None:
            expected_url, expected_attribution = allowed
            if license_url != expected_url:
                errors.append(
                    f"{asset_id}: {license_name} must use canonical licenseURL {expected_url}"
                )
            if attribution_required is not expected_attribution:
                errors.append(
                    f"{asset_id}: {license_name} requires attributionRequired={str(expected_attribution).lower()}"
                )
        elif license_name == "Public domain":
            expected_url = f"{source_url}#Licensing"
            if license_url != expected_url:
                errors.append(
                    f"{asset_id}: Public domain evidence must link to the source page Licensing section"
                )
            if attribution_required is not False:
                errors.append(f"{asset_id}: Public domain requires attributionRequired=false")
        else:
            errors.append(f"{asset_id}: unsupported third-party license: {license_name}")

        credit = str(item.get("creditLine") or "")
        for field in ("creator", "licenseName"):
            value = str(item.get(field) or "")
            if value and value not in credit:
                errors.append(f"{asset_id}: attribution creditLine does not name {field}")

    actual_ids = set(attribution_by_id)
    if actual_ids != expected_ids:
        missing = sorted(expected_ids - actual_ids)
        extra = sorted(actual_ids - expected_ids)
        if missing:
            errors.append(f"media attribution registry is missing catalog assets: {missing}")
        if extra:
            errors.append(f"media attribution registry contains unexpected assets: {extra}")

    for asset_id in sorted(expected_ids & actual_ids & set(record_by_id)):
        record = record_by_id[asset_id]
        attribution = attribution_by_id[asset_id]
        expected_family = (
            "netherlands_photography"
            if NETHERLANDS_PHOTOGRAPHY_ID_PATTERN.fullmatch(asset_id)
            else "other_ui_media"
        )
        if record.get("family") != expected_family:
            errors.append(f"{asset_id}: attribution-governed asset must use family={expected_family}")
        if record.get("status") != "third_party_attribution_ready":
            errors.append(f"{asset_id}: attribution-governed asset must be third_party_attribution_ready")
        for field in (
            "sourcePageURL",
            "creator",
            "licenseName",
            "licenseURL",
            "attributionRequired",
            "creditLine",
        ):
            if record.get(field) != attribution.get(field):
                errors.append(f"{asset_id}: ledger {field} does not match media attribution registry")
        evidence = record.get("evidence")
        if not isinstance(evidence, list) or MEDIA_ATTRIBUTIONS_EVIDENCE not in evidence:
            errors.append(f"{asset_id}: ledger must cite {MEDIA_ATTRIBUTIONS_EVIDENCE}")


def validate_local_files(
    asset_id: str,
    value: object,
    catalog_asset: CatalogAsset,
    errors: list[str],
) -> None:
    if not isinstance(value, list) or not value:
        errors.append(f"{asset_id}: localFiles must be a non-empty array")
        return

    ledger_files: dict[str, str] = {}
    for index, item in enumerate(value):
        if not isinstance(item, dict) or set(item) != {"path", "sha1"}:
            errors.append(f"{asset_id}: localFiles[{index}] must contain only path and sha1")
            continue
        path = item.get("path")
        digest = item.get("sha1")
        if not is_nonempty_string(path):
            errors.append(f"{asset_id}: localFiles[{index}].path is empty")
            continue
        if not isinstance(digest, str) or SHA1_PATTERN.fullmatch(digest) is None:
            errors.append(f"{asset_id}: localFiles[{index}].sha1 is not a lowercase SHA-1")
            continue
        if path in ledger_files:
            errors.append(f"{asset_id}: duplicate localFiles path: {path}")
            continue
        ledger_files[str(path)] = digest

    if ledger_files != catalog_asset.files:
        missing = sorted(set(catalog_asset.files) - set(ledger_files))
        extra = sorted(set(ledger_files) - set(catalog_asset.files))
        changed = sorted(
            path
            for path in set(ledger_files) & set(catalog_asset.files)
            if ledger_files[path] != catalog_asset.files[path]
        )
        if missing:
            errors.append(f"{asset_id}: ledger is missing catalog payloads: {missing}")
        if extra:
            errors.append(f"{asset_id}: ledger contains non-catalog payloads: {extra}")
        if changed:
            errors.append(f"{asset_id}: payload SHA-1 mismatch: {changed}")


def labeled_markdown_value(text: str, label: str) -> str | None:
    match = re.search(rf"(?im)^\s*{re.escape(label)}\s*:\s*(.+?)\s*$", text)
    return match.group(1).strip() if match else None


def validate_owner_attestation(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    path = root / OWNER_ATTESTATION_EVIDENCE
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as error:
        errors.append(f"{asset_id}: owner attestation cannot be read: {error}")
        return

    if labeled_markdown_value(text, "Attestation status") != "CONFIRMED":
        errors.append(f"{asset_id}: owner attestation status must be CONFIRMED")

    attester = labeled_markdown_value(text, "Attested by")
    placeholder_tokens = {"", "TODO", "TBD", "NAME", "OWNER", "<NAME>"}
    if attester is None or attester.strip().upper() in placeholder_tokens:
        errors.append(f"{asset_id}: owner attestation requires a named attester")

    attested_on = labeled_markdown_value(text, "Attested on")
    try:
        attested_date = date.fromisoformat(attested_on or "")
    except ValueError:
        errors.append(f"{asset_id}: owner attestation date must use YYYY-MM-DD")
    else:
        if attested_date > date.today():
            errors.append(f"{asset_id}: owner attestation date cannot be in the future")

    covered_asset_id = str(record.get("derivedFromAssetID") or asset_id)
    if covered_asset_id not in text:
        errors.append(
            f"{asset_id}: owner attestation does not identify covered asset {covered_asset_id}"
        )
    local_hashes = {
        item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict) and is_nonempty_string(item.get("sha1"))
    }
    missing_hashes = sorted(digest for digest in local_hashes if digest not in text)
    if missing_hashes:
        errors.append(
            f"{asset_id}: owner attestation does not cover current SHA-1 values: {missing_hashes}"
        )


def validate_project_owned_asset_evidence(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    path = root / PROJECT_OWNED_ASSET_EVIDENCE
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{asset_id}: project-owned evidence cannot be read: {error}")
        return
    if not isinstance(payload, dict) or payload.get("schemaVersion") != 1:
        errors.append(f"{asset_id}: project-owned evidence schemaVersion must be 1")
        return
    entries = payload.get("records")
    if not isinstance(entries, list):
        errors.append(f"{asset_id}: project-owned evidence records must be an array")
        return
    matches = [
        item
        for item in entries
        if isinstance(item, dict) and item.get("assetID") == asset_id
    ]
    if len(matches) != 1:
        errors.append(
            f"{asset_id}: project-owned evidence must contain exactly one matching record"
        )
        return

    evidence = matches[0]
    for field in ("family", "ownershipBasis", "creator", "note"):
        if evidence.get(field) != record.get(field):
            errors.append(f"{asset_id}: project-owned evidence {field} does not match ledger")
    if evidence.get("ownershipBasis") != "repository_original":
        errors.append(f"{asset_id}: project-owned registry must use repository_original")
    source_evidence = evidence.get("evidence")
    if not isinstance(source_evidence, list) or not source_evidence:
        errors.append(f"{asset_id}: project-owned registry requires repository evidence paths")
    else:
        ledger_evidence = record.get("evidence")
        for item in source_evidence:
            if not isinstance(ledger_evidence, list) or item not in ledger_evidence:
                errors.append(f"{asset_id}: ledger omits project-owned evidence path {item}")

    local_files = {
        item.get("path"): item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict)
    }
    if local_files.get(evidence.get("localPath")) != evidence.get("localSHA1"):
        errors.append(f"{asset_id}: project-owned evidence local path/SHA-1 does not match ledger")


def validate_c2pa_evidence(root: Path, record: dict, errors: list[str]) -> None:
    """Validate byte-linked C2PA structure/metadata, not the cryptographic signature chain."""
    asset_id = record["assetID"]
    path = root / C2PA_EVIDENCE
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{asset_id}: C2PA evidence cannot be read: {error}")
        return

    if not isinstance(payload, dict) or payload.get("schemaVersion") != 1:
        errors.append(f"{asset_id}: C2PA evidence schemaVersion must be 1")
        return
    if payload.get("evidenceType") != "embedded_c2pa_container_metadata":
        errors.append(f"{asset_id}: C2PA evidenceType must describe embedded container metadata")
    if payload.get("validationLevel") != "structural_markers_and_metadata_only":
        errors.append(f"{asset_id}: C2PA validationLevel must be structural_markers_and_metadata_only")
    if payload.get("signatureValidated") is not False:
        errors.append(f"{asset_id}: offline gate must not claim cryptographic C2PA signature validation")
    if not is_nonempty_string(payload.get("limitation")):
        errors.append(f"{asset_id}: C2PA evidence must state its validation limitation")
    entries = payload.get("records")
    if not isinstance(entries, list):
        errors.append(f"{asset_id}: C2PA evidence records must be an array")
        return

    local_hashes = {
        item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict) and is_nonempty_string(item.get("sha1"))
    }
    for digest in sorted(local_hashes):
        candidates = [
            entry
            for entry in entries
            if isinstance(entry, dict) and entry.get("sha1") == digest
        ]
        if not candidates:
            errors.append(f"{asset_id}: C2PA evidence has no record for SHA-1 {digest}")
            continue

        valid_candidate = False
        candidate_errors: list[str] = []
        for entry in candidates:
            entry_errors: list[str] = []
            expected_evidence_asset_id = str(record.get("derivedFromAssetID") or asset_id)
            if entry.get("assetID") != expected_evidence_asset_id:
                entry_errors.append(
                    f"assetID must match covered source asset {expected_evidence_asset_id}"
                )
            if entry.get("generator") != "OpenAI Media Service API":
                entry_errors.append("generator must be OpenAI Media Service API")
            if entry.get("provider") != "OpenAI OpCo, LLC":
                entry_errors.append("provider must be OpenAI OpCo, LLC")
            if not isinstance(entry.get("xmpInstanceID"), str) or UUID_PATTERN.fullmatch(entry["xmpInstanceID"]) is None:
                entry_errors.append("xmpInstanceID must be a UUID")
            if not is_nonempty_string(entry.get("createdAt")):
                entry_errors.append("createdAt is required")

            evidence_file = entry.get("path")
            if not is_nonempty_string(evidence_file):
                entry_errors.append("path is required")
            else:
                source_path = root / str(evidence_file)
                try:
                    source_path.resolve().relative_to(root.resolve())
                except ValueError:
                    entry_errors.append("path escapes repository root")
                else:
                    if not source_path.is_file():
                        entry_errors.append("path does not exist")
                    elif sha1(source_path) != digest:
                        entry_errors.append("path SHA-1 does not match evidence")
                    else:
                        source_bytes = source_path.read_bytes()
                        try:
                            c2pa_payloads = png_c2pa_payloads(source_bytes)
                            if len(c2pa_payloads) != 1:
                                raise ValueError("PNG must contain exactly one caBX chunk")
                            validate_jumbf_structure(c2pa_payloads[0])
                        except ValueError as error:
                            entry_errors.append(f"invalid embedded C2PA/JUMBF structure: {error}")
                            c2pa_payloads = []
                        embedded_payload = c2pa_payloads[0] if c2pa_payloads else b""
                        for marker in (b"jumdc2pa", b"c2pa.claim.v2", b"c2pa.signature"):
                            if marker not in embedded_payload:
                                entry_errors.append(
                                    f"required C2PA/JUMBF marker is absent from caBX: {marker.decode('ascii')}"
                                )
                        for field in ("generator", "provider", "xmpInstanceID", "createdAt"):
                            value = entry.get(field)
                            if is_nonempty_string(value) and str(value).encode("utf-8") not in embedded_payload:
                                entry_errors.append(f"{field} is not embedded in the caBX payload")

            if not entry_errors:
                valid_candidate = True
                break
            candidate_errors.extend(entry_errors)

        if not valid_candidate:
            errors.append(
                f"{asset_id}: invalid C2PA evidence for SHA-1 {digest}: "
                + "; ".join(sorted(set(candidate_errors)))
            )


def validate_city_symbol_evidence(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    path = root / CITY_SYMBOL_EVIDENCE
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{asset_id}: city-symbol evidence cannot be read: {error}")
        return

    if not isinstance(payload, dict) or payload.get("schemaVersion") != 1:
        errors.append(f"{asset_id}: city-symbol evidence schemaVersion must be 1")
        return
    if payload.get("source") != "Wikimedia Commons API":
        errors.append(f"{asset_id}: city-symbol evidence source must be Wikimedia Commons API")
    entries = payload.get("records")
    if not isinstance(entries, list):
        errors.append(f"{asset_id}: city-symbol evidence records must be an array")
        return
    matches = [
        item
        for item in entries
        if isinstance(item, dict) and item.get("assetID") == asset_id
    ]
    if len(matches) != 1:
        errors.append(
            f"{asset_id}: city-symbol evidence must contain exactly one matching record"
        )
        return

    evidence = matches[0]
    for field in ("sourcePageURL", "creator", "licenseName", "licenseURL"):
        if evidence.get(field) != record.get(field):
            errors.append(f"{asset_id}: city-symbol evidence {field} does not match ledger")

    local_files = {
        item.get("path"): item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict)
    }
    evidence_path_value = evidence.get("localPath")
    evidence_sha1 = evidence.get("localSHA1")
    if local_files.get(evidence_path_value) != evidence_sha1:
        errors.append(f"{asset_id}: city-symbol evidence local path/SHA-1 does not match ledger")

    commons = record.get("commons")
    if isinstance(commons, dict):
        if commons.get("localMatch") != "current_byte_exact":
            errors.append(f"{asset_id}: reconciled city symbol must be current_byte_exact")
        if commons.get("remoteCurrentSHA1") != evidence.get("commonsSHA1"):
            errors.append(f"{asset_id}: city-symbol Commons SHA-1 does not match evidence")
        if commons.get("checkedAt") != evidence.get("retrievedAt"):
            errors.append(f"{asset_id}: city-symbol checkedAt does not match evidence")


def validate_third_party_asset_evidence(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    path = root / THIRD_PARTY_ASSET_EVIDENCE
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        errors.append(f"{asset_id}: third-party evidence cannot be read: {error}")
        return

    if not isinstance(payload, dict) or payload.get("schemaVersion") != 1:
        errors.append(f"{asset_id}: third-party evidence schemaVersion must be 1")
        return
    entries = payload.get("records")
    if not isinstance(entries, list):
        errors.append(f"{asset_id}: third-party evidence records must be an array")
        return
    matches = [
        item
        for item in entries
        if isinstance(item, dict) and item.get("assetID") == asset_id
    ]
    if len(matches) != 1:
        errors.append(
            f"{asset_id}: third-party evidence must contain exactly one matching record"
        )
        return

    evidence = matches[0]
    for field in (
        "sourcePageURL",
        "creator",
        "licenseName",
        "licenseURL",
        "modificationNotice",
    ):
        if evidence.get(field) != record.get(field):
            errors.append(f"{asset_id}: third-party evidence {field} does not match ledger")
    for field in ("originalFileURL", "thumbnailURL"):
        if not is_https_url(evidence.get(field)):
            errors.append(f"{asset_id}: third-party evidence {field} must be an HTTPS URL")
    if not isinstance(evidence.get("originalSHA1"), str) or SHA1_PATTERN.fullmatch(evidence["originalSHA1"]) is None:
        errors.append(f"{asset_id}: third-party evidence originalSHA1 is invalid")

    local_files = {
        item.get("path"): item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict)
    }
    if local_files.get(evidence.get("localPath")) != evidence.get("localSHA1"):
        errors.append(f"{asset_id}: third-party evidence local path/SHA-1 does not match ledger")
    for field in ("originalWidth", "originalHeight", "localWidth", "localHeight"):
        if not isinstance(evidence.get(field), int) or evidence[field] <= 0:
            errors.append(f"{asset_id}: third-party evidence {field} must be a positive integer")
    if not is_nonempty_string(evidence.get("retrievedAt")):
        errors.append(f"{asset_id}: third-party evidence retrievedAt is required")


def validate_project_owned(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    evidence = validate_evidence(root, asset_id, record.get("evidence"), errors)
    if not evidence:
        errors.append(f"{asset_id}: project-owned asset requires repository evidence")
    if not is_nonempty_string(record.get("creator")):
        errors.append(f"{asset_id}: project-owned asset requires creator")
    if record.get("licenseName") != "Project-owned":
        errors.append(f"{asset_id}: project-owned asset must use licenseName=Project-owned")
    if record.get("attributionRequired") is not False:
        errors.append(f"{asset_id}: project-owned asset must declare attributionRequired=false")
    if record.get("sourcePageURL") is not None or record.get("licenseURL") is not None:
        errors.append(f"{asset_id}: project-owned asset must not invent source or license URLs")

    ownership_basis = record.get("ownershipBasis")
    if ownership_basis not in OWNERSHIP_BASES:
        errors.append(
            f"{asset_id}: ownershipBasis must be one of {sorted(OWNERSHIP_BASES)}"
        )
        return

    if ownership_basis in {"generated_for_project", "owner_attestation"}:
        if record.get("family") not in {"app_icon", "other_ui_media"}:
            errors.append(
                f"{asset_id}: {ownership_basis} is limited to app_icon or other_ui_media"
            )
        if OWNER_ATTESTATION_EVIDENCE not in evidence:
            errors.append(
                f"{asset_id}: {ownership_basis} requires {OWNER_ATTESTATION_EVIDENCE}"
            )
        else:
            validate_owner_attestation(root, record, errors)

    if ownership_basis == "generated_for_project" and C2PA_EVIDENCE not in evidence:
        errors.append(
            f"{asset_id}: generated_for_project requires {C2PA_EVIDENCE}"
        )
    elif ownership_basis == "generated_for_project":
        validate_c2pa_evidence(root, record, errors)

    if ownership_basis == "repository_original":
        if record.get("family") not in {"project_map", "province_flag"}:
            errors.append(
                f"{asset_id}: repository_original is limited to governed project maps and province flags"
            )
        if PROJECT_OWNED_ASSET_EVIDENCE not in evidence:
            errors.append(
                f"{asset_id}: repository_original requires {PROJECT_OWNED_ASSET_EVIDENCE}"
            )
        else:
            validate_project_owned_asset_evidence(root, record, errors)

def validate_public_domain(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    if record.get("family") != "city_symbol":
        errors.append(
            f"{asset_id}: public_domain_byte_exact is limited to governed city_symbol assets"
        )
    evidence = validate_evidence(root, asset_id, record.get("evidence"), errors)
    if not evidence:
        errors.append(f"{asset_id}: public-domain asset requires evidence")
    for field in ("sourcePageURL", "licenseURL"):
        if not is_https_url(record.get(field)):
            errors.append(f"{asset_id}: {field} must be an HTTPS URL")
    for field in ("creator", "licenseName"):
        if not is_nonempty_string(record.get(field)):
            errors.append(f"{asset_id}: {field} is required")
    if record.get("attributionRequired") is not False:
        errors.append(f"{asset_id}: public-domain byte-exact record must declare attributionRequired=false")

    commons = record.get("commons")
    if not isinstance(commons, dict):
        errors.append(f"{asset_id}: public-domain byte-exact record requires Commons evidence")
        return
    if commons.get("localMatch") not in {"current_byte_exact", "historical_byte_exact"}:
        errors.append(f"{asset_id}: Commons evidence is not byte-exact")
    remote_sha1 = commons.get("remoteCurrentSHA1")
    local_hashes = {
        item.get("sha1")
        for item in record.get("localFiles", [])
        if isinstance(item, dict)
    }
    if commons.get("localMatch") == "current_byte_exact" and remote_sha1 not in local_hashes:
        errors.append(f"{asset_id}: current Commons SHA-1 does not match a local payload")
    if not is_nonempty_string(commons.get("checkedAt")):
        errors.append(f"{asset_id}: Commons evidence lacks checkedAt")

    if record.get("family") == "city_symbol":
        if not is_commons_file_url(record.get("sourcePageURL")):
            errors.append(f"{asset_id}: city symbol sourcePageURL must be a Wikimedia Commons File page")
        if record.get("licenseName") != "Public domain":
            errors.append(f"{asset_id}: city symbol licenseName must be Public domain")
        if record.get("licenseURL") != "https://creativecommons.org/publicdomain/mark/1.0/":
            errors.append(
                f"{asset_id}: city symbol must use the canonical Creative Commons Public Domain Mark URL"
            )
        if CITY_SYMBOL_EVIDENCE not in evidence:
            errors.append(f"{asset_id}: city symbol requires {CITY_SYMBOL_EVIDENCE}")
        else:
            validate_city_symbol_evidence(root, record, errors)


def validate_third_party(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    if not (
        NETHERLANDS_PHOTOGRAPHY_ID_PATTERN.fullmatch(asset_id)
        or asset_id in ATTRIBUTED_UI_ASSETS
    ):
        errors.append(
            f"{asset_id}: third_party_attribution_ready requires coverage in the media attribution registry"
        )
    evidence = validate_evidence(root, asset_id, record.get("evidence"), errors)
    if not evidence:
        errors.append(f"{asset_id}: third-party asset requires repository evidence")
    for field in ("sourcePageURL", "licenseURL"):
        if not is_https_url(record.get(field)):
            errors.append(f"{asset_id}: {field} must be an HTTPS URL")
    for field in ("creator", "licenseName", "creditLine", "modificationNotice"):
        if not is_nonempty_string(record.get(field)):
            errors.append(f"{asset_id}: {field} is required")
    if not isinstance(record.get("attributionRequired"), bool):
        errors.append(f"{asset_id}: attributionRequired must be boolean")
    credit = str(record.get("creditLine") or "")
    creator = str(record.get("creator") or "")
    license_name = str(record.get("licenseName") or "")
    if creator and creator not in credit:
        errors.append(f"{asset_id}: creditLine does not name creator")
    if license_name and license_name not in credit:
        errors.append(f"{asset_id}: creditLine does not name license")

    if asset_id in DIRECT_COMMONS_UI_ASSETS:
        if THIRD_PARTY_ASSET_EVIDENCE not in evidence:
            errors.append(f"{asset_id}: direct Commons UI asset requires {THIRD_PARTY_ASSET_EVIDENCE}")
        else:
            validate_third_party_asset_evidence(root, record, errors)


def validate_derivations(record_by_id: dict[str, dict], errors: list[str]) -> None:
    for asset_id, record in sorted(record_by_id.items()):
        required_source_id = REQUIRED_EXACT_DERIVATIONS.get(asset_id)
        has_derivation = (
            required_source_id is not None
            or "derivedFromAssetID" in record
            or "derivationKind" in record
        )
        if not has_derivation:
            continue

        source_id = record.get("derivedFromAssetID")
        kind = record.get("derivationKind")
        if not is_nonempty_string(source_id):
            errors.append(f"{asset_id}: remediated asset requires derivedFromAssetID")
            continue
        if kind not in DERIVATION_KINDS:
            errors.append(
                f"{asset_id}: derivationKind must be one of {sorted(DERIVATION_KINDS)}"
            )
        if required_source_id is not None and source_id != required_source_id:
            errors.append(
                f"{asset_id}: derivedFromAssetID must be {required_source_id}, got {source_id}"
            )
        if required_source_id is not None and kind != "exact_copy":
            errors.append(f"{asset_id}: approved remediation requires derivationKind=exact_copy")
        if source_id == asset_id:
            errors.append(f"{asset_id}: derivedFromAssetID cannot reference itself")
            continue

        source = record_by_id.get(str(source_id))
        if not source:
            errors.append(f"{asset_id}: derived source is absent from ledger: {source_id}")
            continue
        if source.get("status") not in {
            "public_domain_byte_exact",
            "project_owned_documented",
            "third_party_attribution_ready",
        }:
            errors.append(f"{asset_id}: derived source is not rights-cleared: {source_id}")

        for field in (
            "sourcePageURL",
            "creator",
            "licenseName",
            "licenseURL",
            "attributionRequired",
        ):
            if record.get(field) != source.get(field):
                errors.append(
                    f"{asset_id}: derived metadata {field} must match {source_id}"
                )

        if kind == "exact_copy":
            alias_hashes = {
                item.get("sha1")
                for item in record.get("localFiles", [])
                if isinstance(item, dict)
            }
            source_hashes = {
                item.get("sha1")
                for item in source.get("localFiles", [])
                if isinstance(item, dict)
            }
            if not alias_hashes or not alias_hashes <= source_hashes:
                errors.append(
                    f"{asset_id}: exact_copy SHA-1 does not match derived source {source_id}"
                )


def validate_unresolved(root: Path, record: dict, errors: list[str]) -> None:
    asset_id = record["assetID"]
    status = record["status"]
    evidence = validate_evidence(root, asset_id, record.get("evidence"), errors)
    if status in {"owner_attestation_required", "source_ownership_conflict"} and not evidence:
        errors.append(f"{asset_id}: {status} must identify the evidence that remains insufficient")


def count_string_field(records: list[object], field: str) -> dict[str, int]:
    counts = Counter(
        value
        for record in records
        if isinstance(record, dict)
        for value in [record.get(field)]
        if is_nonempty_string(value)
    )
    return dict(sorted(counts.items()))


def validate_ledger(root: Path, ledger: dict, assets: dict[str, CatalogAsset]) -> list[str]:
    errors: list[str] = []

    if ledger.get("schemaVersion") != 1:
        errors.append("schemaVersion must be 1")
    if ledger.get("scope") != "YouNew/Assets.xcassets":
        errors.append("scope must be YouNew/Assets.xcassets")
    if not is_nonempty_string(ledger.get("generatedAt")):
        errors.append("generatedAt is required")
    if not is_nonempty_string(ledger.get("disclaimer")):
        errors.append("disclaimer is required")
    methodology = ledger.get("methodology")
    if not isinstance(methodology, list) or not methodology or not all(is_nonempty_string(item) for item in methodology):
        errors.append("methodology must be a non-empty string array")

    records = ledger.get("records")
    if not isinstance(records, list):
        return errors + ["records must be an array"]

    record_by_id: dict[str, dict] = {}
    for index, record in enumerate(records):
        if not isinstance(record, dict):
            errors.append(f"records[{index}] must be an object")
            continue
        asset_id = record.get("assetID")
        if not is_nonempty_string(asset_id):
            errors.append(f"records[{index}].assetID is required")
            continue
        asset_id = str(asset_id)
        if asset_id in record_by_id:
            errors.append(f"duplicate ledger asset ID: {asset_id}")
            continue
        record_by_id[asset_id] = record

    missing_records = sorted(set(assets) - set(record_by_id))
    extra_records = sorted(set(record_by_id) - set(assets))
    if missing_records:
        errors.append(f"ledger is missing catalog assets: {missing_records}")
    if extra_records:
        errors.append(f"ledger contains assets outside the catalog: {extra_records}")

    validate_media_attributions(root, record_by_id, set(assets), errors)

    for asset_id in sorted(set(assets) & set(record_by_id)):
        asset = assets[asset_id]
        record = record_by_id[asset_id]
        if record.get("localDirectory") != asset.directory:
            errors.append(
                f"{asset_id}: localDirectory must be {asset.directory}, got {record.get('localDirectory')}"
            )
        validate_local_files(asset_id, record.get("localFiles"), asset, errors)

        family = record.get("family")
        if not isinstance(family, str) or family not in ALLOWED_FAMILIES:
            errors.append(f"{asset_id}: invalid family {family}")
        status = record.get("status")
        bucket = record.get("bucket")
        expected_bucket = STATUS_BUCKETS.get(status) if isinstance(status, str) else None
        if expected_bucket is None:
            errors.append(f"{asset_id}: invalid status {status}")
            continue
        if bucket != expected_bucket:
            errors.append(f"{asset_id}: status {status} requires bucket {expected_bucket}")
        if not is_nonempty_string(record.get("note")) and status != "third_party_attribution_ready":
            errors.append(f"{asset_id}: note is required")

        if status == "project_owned_documented":
            validate_project_owned(root, record, errors)
        elif status == "public_domain_byte_exact":
            validate_public_domain(root, record, errors)
        elif status == "third_party_attribution_ready":
            validate_third_party(root, record, errors)
        else:
            validate_unresolved(root, record, errors)

    validate_derivations(record_by_id, errors)

    summary = ledger.get("summary")
    if not isinstance(summary, dict):
        errors.append("summary must be an object")
    else:
        expected_total = len(records)
        expected_bucket_counts = count_string_field(records, "bucket")
        expected_status_counts = count_string_field(records, "status")
        expected_family_counts = count_string_field(records, "family")
        if summary.get("totalAssets") != expected_total:
            errors.append(f"summary.totalAssets must be recomputed as {expected_total}")
        if summary.get("byBucket") != expected_bucket_counts:
            errors.append("summary.byBucket does not match records")
        if summary.get("byStatus") != expected_status_counts:
            errors.append("summary.byStatus does not match records")
        if summary.get("byFamily") != expected_family_counts:
            errors.append("summary.byFamily does not match records")

    unresolved = sorted(
        asset_id
        for asset_id, record in record_by_id.items()
        if record.get("bucket") == "unresolved"
    )
    if unresolved:
        errors.append(
            f"release is blocked: unresolved={len(unresolved)} assets: {', '.join(unresolved)}"
        )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Enforce zero unresolved rights records for the Xcode asset catalog.")
    parser.add_argument("--ledger", type=Path, default=DEFAULT_LEDGER)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    args = parser.parse_args()

    try:
        assets = inventory_catalog(ROOT, args.catalog)
        ledger = load_ledger(args.ledger)
    except RightsGateError as error:
        print(f"Asset rights gate failed: {error}")
        return 1

    errors = validate_ledger(ROOT, ledger, assets)
    if errors:
        print("Asset rights gate failed")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Asset rights gate passed")
    print(f"- Catalog assets: {len(assets)}")
    print("- Unresolved rights records: 0")
    print(f"- Ledger: {relative_path(args.ledger, ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
