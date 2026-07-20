#!/usr/bin/env python3
"""Build the deterministic Data Project runtime artifact or a safe QA preview."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
SCHEMA_PATH = PROJECT / "schema" / "entity.schema.json"
RELEASES_PATH = PROJECT / "releases" / "releases.json"
MANIFESTS_DIR = PROJECT / "reports" / "release-manifests"
MIGRATION_PATH = PROJECT / "observability" / "migration-registry.json"
RUNTIME_PATH = ROOT / "YouNew" / "Resources" / "Data" / "younew-runtime-data.json"
PREVIEW_PATH = PROJECT / "reports" / "import-preview.json"
GATES = ("build", "static", "duplicate", "source", "media", "search", "ai")
STABLE_ID = re.compile(r"^[a-z0-9]+(?:[._:-][a-z0-9]+)+$")


class ImportFailure(RuntimeError):
    pass


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ImportFailure(f"Cannot read {path.relative_to(ROOT)}: {error}") from error


def canonical_json(payload) -> str:
    return json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def file_fingerprint(path: Path) -> dict:
    content = path.read_bytes()
    return {
        "path": str(path.relative_to(ROOT)),
        "sha256": hashlib.sha256(content).hexdigest(),
    }


def write_if_changed(path: Path, payload) -> bool:
    content = canonical_json(payload)
    if path.exists() and path.read_text(encoding="utf-8") == content:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return True


def json_type_matches(value, expected: str) -> bool:
    return {
        "null": value is None,
        "object": isinstance(value, dict),
        "array": isinstance(value, list),
        "string": isinstance(value, str),
        "boolean": isinstance(value, bool),
        "integer": isinstance(value, int) and not isinstance(value, bool),
        "number": isinstance(value, (int, float)) and not isinstance(value, bool),
    }[expected]


def validate_schema(value, schema, root_schema, label: str):
    if "$ref" in schema:
        ref = schema["$ref"]
        if not ref.startswith("#/"):
            raise ImportFailure(f"{label}: unsupported schema reference {ref}")
        target = root_schema
        for part in ref[2:].split("/"):
            target = target[part.replace("~1", "/").replace("~0", "~")]
        return validate_schema(value, target, root_schema, label)

    if "oneOf" in schema:
        successes = 0
        for candidate in schema["oneOf"]:
            try:
                validate_schema(value, candidate, root_schema, label)
                successes += 1
            except ImportFailure:
                pass
        if successes != 1:
            raise ImportFailure(f"{label}: value must match exactly one schema variant")
        return

    for index, candidate in enumerate(schema.get("allOf", [])):
        validate_schema(value, candidate, root_schema, f"{label}.allOf[{index}]")

    if "if" in schema:
        try:
            validate_schema(value, schema["if"], root_schema, f"{label}.if")
        except ImportFailure:
            if "else" in schema:
                validate_schema(value, schema["else"], root_schema, f"{label}.else")
        else:
            if "then" in schema:
                validate_schema(value, schema["then"], root_schema, f"{label}.then")

    expected = schema.get("type")
    if expected:
        allowed = expected if isinstance(expected, list) else [expected]
        if not any(json_type_matches(value, item) for item in allowed):
            raise ImportFailure(f"{label}: expected {' or '.join(allowed)}")

    if "enum" in schema and value not in schema["enum"]:
        raise ImportFailure(f"{label}: unsupported value {value!r}")
    if "const" in schema and value != schema["const"]:
        raise ImportFailure(f"{label}: value must equal {schema['const']!r}")
    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            raise ImportFailure(f"{label}: string is too short")
        if schema.get("pattern") and not re.fullmatch(schema["pattern"], value):
            raise ImportFailure(f"{label}: string does not match the stable format")
        if schema.get("format") == "date":
            try:
                date.fromisoformat(value)
            except ValueError as error:
                raise ImportFailure(f"{label}: invalid ISO date") from error
        if schema.get("format") == "uri":
            parsed = urlsplit(value)
            if not parsed.scheme or not parsed.netloc:
                raise ImportFailure(f"{label}: invalid URI")
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if "minimum" in schema and value < schema["minimum"]:
            raise ImportFailure(f"{label}: below minimum")
        if "maximum" in schema and value > schema["maximum"]:
            raise ImportFailure(f"{label}: above maximum")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0):
            raise ImportFailure(f"{label}: too few items")
        if schema.get("uniqueItems"):
            identities = [json.dumps(item, sort_keys=True) for item in value]
            if len(identities) != len(set(identities)):
                raise ImportFailure(f"{label}: items must be unique")
        for index, item in enumerate(value):
            validate_schema(item, schema.get("items", {}), root_schema, f"{label}[{index}]")
    if isinstance(value, dict):
        required = set(schema.get("required", []))
        missing = required - set(value)
        if missing:
            raise ImportFailure(f"{label}: missing fields {sorted(missing)}")
        properties = schema.get("properties", {})
        additional = schema.get("additionalProperties", True)
        if additional is False:
            extras = set(value) - set(properties)
            if extras:
                raise ImportFailure(f"{label}: unknown fields {sorted(extras)}")
        for key, item in value.items():
            child_schema = properties.get(key)
            if child_schema is None and isinstance(additional, dict):
                child_schema = additional
            if child_schema is not None:
                validate_schema(item, child_schema, root_schema, f"{label}.{key}")


def release_catalog():
    releases = read_json(RELEASES_PATH).get("releases", [])
    return {release["id"]: release for release in releases}


def release_manifests():
    manifests = {}
    for path in sorted(MANIFESTS_DIR.glob("*.json")):
        manifest = read_json(path)
        release_id = manifest.get("release_id")
        if release_id:
            manifests[release_id] = (path, manifest)
    return manifests


def batch_catalog():
    result = defaultdict(list)
    for path in sorted((PROJECT / "batches").glob("**/*.json")):
        batch = read_json(path)
        result[batch.get("target_release")].append((path, batch))
    return result


def validate_release(release_id, release, manifest_entry, batches):
    if manifest_entry is None:
        raise ImportFailure(f"Release {release_id} has no generated release manifest")
    _, manifest = manifest_entry
    if manifest.get("release_id") != release_id or manifest.get("version") != release.get("version"):
        raise ImportFailure(f"Release {release_id} manifest does not match releases.json")
    if manifest.get("status") != release.get("status"):
        raise ImportFailure(f"Release {release_id} manifest status does not match releases.json")
    if not batches:
        raise ImportFailure(f"Release {release_id} has no batch JSON")


def validate_gates(path: Path, batch):
    qa = batch.get("qa", {})
    if set(qa) != set(GATES) or any(qa.get(gate) != "passed" for gate in GATES):
        missing = [gate for gate in GATES if qa.get(gate) != "passed"]
        raise ImportFailure(f"{path.relative_to(ROOT)} has incomplete publication gates: {missing}")


def kind_for(entity_type: str) -> str:
    return {
        "government_service": "governmentService",
        "city": "city",
        "place": "place",
        "museum": "museum",
        "restaurant": "restaurant",
        "cafe": "cafe",
        "hotel": "hotel",
        "nature": "park",
        "event": "event",
        "local_partner": "localPartner",
        "housing": "knowledgeTopic",
        "healthcare": "healthcare",
        "education": "university",
        "transport": "transport",
        "document": "knowledgeTopic",
        "knowledge_topic": "knowledgeTopic",
        "media": "place",
    }[entity_type]


def runtime_media(image):
    return {
        "id": image["id"],
        "role": image["role"],
        "assetURL": image["asset_url"],
        "sourcePageURL": image["source_page_url"],
        "license": image["license"],
        "licenseURL": image["license_url"],
        "attribution": image["attribution"],
        "verified": image["verified"],
        "retrievedAt": image["retrieved_at"],
    }


def runtime_entity(record, release_id: str):
    source = record["official_source"]
    images = sorted((runtime_media(item) for item in record["images"]), key=lambda item: (item["role"], item["id"]))
    attributes = {str(key): str(value) for key, value in sorted((record.get("attributes") or {}).items())}
    attributes.update({
        "dataProjectRelease": release_id,
        "editorialEntityType": record["entity_type"],
        "verificationStatus": record["verification_status"],
        "lifecycleStatus": record["lifecycle_status"],
    })
    return {
        "id": record["id"],
        "kind": kind_for(record["entity_type"]),
        "title": record["title"],
        "summary": record["description"],
        "cityId": record["city_id"],
        "provinceId": record["province_id"],
        "category": record["category"],
        "coordinate": record["coordinates"],
        "source": {
            "title": source["title"],
            "publisher": source["publisher"],
            "url": source["url"],
            "checkedAt": source["checked_at"],
            "status": source["status"],
            "isOfficial": source["is_official"],
        },
        "lastChecked": record["last_checked"],
        "images": images,
        "aiSummary": record["ai_summary"],
        "relatedEntityIDs": sorted(record["related_entity_ids"]),
        "attributes": attributes,
        "keywords": sorted(set(record["search_keywords"])),
        "publicationStatus": "published" if record["lifecycle_status"] == "published" else "preview",
        "verificationStatus": record["verification_status"],
    }


def runtime_ids_from_swift():
    ids = set()
    for path in (ROOT / "YouNew").rglob("*.swift"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        ids.update(re.findall(r'\bid:\s*"([a-z0-9][a-z0-9._:-]+)"', text))
        ids.update(re.findall(r'\b(?:service|source)\(\s*"([a-z0-9][a-z0-9._:-]+)"', text))
    return ids


def migration_map():
    registry = read_json(MIGRATION_PATH)
    allowed = set(registry.get("allowed_statuses", []))
    mappings = {}
    for entry in registry.get("mappings", []):
        status = entry.get("status")
        if status not in allowed:
            raise ImportFailure(f"Migration mapping has unsupported status {status!r}")
        legacy_id = entry.get("legacy_id")
        canonical_id = entry.get("canonical_id")
        if not legacy_id or not canonical_id or legacy_id in mappings:
            raise ImportFailure("Migration registry contains an invalid or duplicate legacy ID")
        mappings[legacy_id] = {"canonicalID": canonical_id, "status": status}
    return mappings


def build(args):
    schema = read_json(SCHEMA_PATH)
    releases = release_catalog()
    manifests = release_manifests()
    batches_by_release = batch_catalog()
    if args.release:
        selected_ids = [args.release]
    elif args.all_approved:
        selected_ids = sorted(item_id for item_id, item in releases.items() if item.get("status") == "published")
    else:
        selected_ids = sorted(releases)
    unknown = [item for item in selected_ids if item not in releases]
    if unknown:
        raise ImportFailure(f"Unknown release: {', '.join(unknown)}")

    all_records = {}
    records_by_release = defaultdict(list)
    source_by_id = {}
    imported_batch_paths = []
    city_provinces = {}
    release_summaries = []
    for release_id in selected_ids:
        release = releases[release_id]
        batches = batches_by_release.get(release_id, [])
        validate_release(release_id, release, manifests.get(release_id), batches)
        release_records = []
        for path, batch in batches:
            imported_batch_paths.append(path)
            validate_gates(path, batch)
            if batch.get("publication_status") not in {"qa", "published"}:
                raise ImportFailure(f"{path.relative_to(ROOT)} is not QA-ready")
            for index, record in enumerate(batch.get("records", [])):
                label = f"{path.relative_to(ROOT)} record {index + 1}"
                validate_schema(record, schema, schema, label)
                entity_id = record["id"]
                if not STABLE_ID.fullmatch(entity_id):
                    raise ImportFailure(f"{label} has an unstable ID")
                if entity_id in all_records:
                    raise ImportFailure(f"Duplicate stable ID {entity_id}")
                all_records[entity_id] = record
                source_by_id[entity_id] = label
                release_records.append(record)
                if record["entity_type"] == "city":
                    city_provinces[record["city_id"]] = record["province_id"]
        records_by_release[release_id] = release_records
        release_summaries.append({
            "id": release_id,
            "version": release["version"],
            "status": release["status"],
            "batchCount": len(batches),
            "qaReadyRecordCount": len(release_records),
        })

    all_project_ids = set()
    for batch_entries in batches_by_release.values():
        for _, batch in batch_entries:
            all_project_ids.update(item.get("id") for item in batch.get("records", []))
    known_ids = all_project_ids | runtime_ids_from_swift()
    for entity_id, record in all_records.items():
        unresolved = sorted(set(record["related_entity_ids"]) - known_ids)
        if unresolved:
            raise ImportFailure(f"{entity_id} has unresolved related_entity_ids: {unresolved}")
        city_id = record.get("city_id")
        province_id = record.get("province_id")
        if city_id and city_id in city_provinces and city_provinces[city_id] != province_id:
            raise ImportFailure(f"{entity_id} has city/province mismatch: {city_id}/{province_id}")

    mode = "preview" if args.dry_run else "production"
    blocked_releases = [item["id"] for item in release_summaries if item["status"] != "published"]
    if not args.dry_run and blocked_releases:
        mode = "preview"

    eligible = []
    excluded = []
    for release_id in selected_ids:
        release = releases[release_id]
        for record in records_by_release[release_id]:
            production_ready = (
                release["status"] == "published"
                and record["lifecycle_status"] == "published"
                and record["verification_status"] == "verified"
            )
            preview_ready = record["verification_status"] == "verified" and record["lifecycle_status"] in {"qa", "published"}
            if (mode == "production" and production_ready) or (mode == "preview" and preview_ready):
                eligible.append(runtime_entity(record, release_id))
            else:
                excluded.append({"id": record["id"], "reason": "publication eligibility failed"})

    by_identity = {}
    technical_duplicates = []
    for entity in sorted(eligible, key=lambda item: item["id"]):
        identity = entity["id"]
        if identity in by_identity:
            technical_duplicates.append(identity)
        else:
            by_identity[identity] = entity
    entities = list(by_identity.values())

    mappings = migration_map()
    canonical_ids = set(by_identity)
    bad_mappings = [legacy for legacy, item in mappings.items() if item["status"] in {"migrated", "verified", "retired"} and item["canonicalID"] not in canonical_ids]
    if mode == "production" and bad_mappings:
        raise ImportFailure(f"Migration registry points outside the production artifact: {bad_mappings}")

    legacy_ids = runtime_ids_from_swift()
    legacy_conflicts = []
    for entity in entities:
        candidates = {entity["id"], entity["id"].replace(".", ":", 1)}
        if entity["kind"] == "city" and entity.get("cityId"):
            candidates.add(f"city:{entity['cityId']}")
        matched = sorted(candidates & legacy_ids)
        convention_candidate = f"city:{entity['cityId']}" if entity["kind"] == "city" and entity.get("cityId") else None
        if matched or convention_candidate:
            legacy_conflicts.append({
                "canonicalID": entity["id"],
                "legacyCandidates": matched or [convention_candidate],
                "migrationStatus": "mapped" if any(item in mappings for item in matched) else "discovered",
            })

    newest_date = max((entity["lastChecked"] for entity in entities), default="1970-01-01")
    fingerprint_source = json.dumps(entities, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    manifest_paths = [manifests[item][0] for item in selected_ids]
    input_fingerprint = {
        "schemaVersion": schema.get("$id", "unknown"),
        "schema": file_fingerprint(SCHEMA_PATH),
        "releaseManifests": [file_fingerprint(path) for path in sorted(manifest_paths)],
        "batchFiles": [file_fingerprint(path) for path in sorted(imported_batch_paths)],
    }
    payload = {
        "schemaVersion": 1,
        "mode": mode,
        "generatedAt": f"{newest_date}T00:00:00Z",
        "datasetFingerprint": hashlib.sha256(fingerprint_source.encode("utf-8")).hexdigest(),
        "inputFingerprint": input_fingerprint,
        "releases": release_summaries,
        "publicationPolicy": {
            "productionRequiresReleaseStatus": "published",
            "recordVerificationStatus": "verified",
            "recordLifecycleStatus": "published",
            "allSevenGatesRequired": True,
        },
        "migrationRegistry": mappings,
        "entities": entities,
    }
    output_checksum = hashlib.sha256(canonical_json(payload).encode("utf-8")).hexdigest()
    payload["outputChecksum"] = output_checksum
    report = {
        **payload,
        "output": str(RUNTIME_PATH.relative_to(ROOT)) if mode == "production" else str(PREVIEW_PATH.relative_to(ROOT)),
        "summary": {
            "selectedReleases": len(selected_ids),
            "eligibleRecords": len(entities),
            "excludedRecords": len(excluded),
            "technicalDuplicatesRemoved": len(technical_duplicates),
            "legacyConflictsDiscovered": len(legacy_conflicts),
            "legacyRecordsMapped": len(mappings),
            "brokenRelations": 0,
            "productionBlockedReleases": blocked_releases,
            "productionArtifactChanged": False,
        },
        "excluded": excluded,
        "legacyConflicts": legacy_conflicts,
    }

    if mode == "production":
        changed = write_if_changed(RUNTIME_PATH, payload)
        report["summary"]["productionArtifactChanged"] = changed
    else:
        write_if_changed(PREVIEW_PATH, report)
    return report


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="validate and write only the deterministic preview report")
    parser.add_argument("--release", help="limit validation/import to one Data Release ID")
    parser.add_argument("--all-approved", action="store_true", help="import every release whose governed status is published")
    parser.add_argument("--all", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.release and args.all_approved:
        parser.error("--release and --all-approved are mutually exclusive")
    return args


def main():
    try:
        report = build(parse_args())
    except ImportFailure as error:
        print(f"Data Project import failed: {error}", file=sys.stderr)
        return 1
    summary = report["summary"]
    print(f"Data Project import {report['mode']} passed")
    print(f"- Releases: {summary['selectedReleases']}")
    print(f"- Eligible records: {summary['eligibleRecords']}")
    print(f"- Excluded records: {summary['excludedRecords']}")
    print(f"- Output: {report['output']}")
    if report["mode"] == "preview" and summary["productionBlockedReleases"]:
        print("- Production unchanged; releases are not published: " + ", ".join(summary["productionBlockedReleases"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
