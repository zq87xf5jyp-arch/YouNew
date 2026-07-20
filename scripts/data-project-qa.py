#!/usr/bin/env python3
"""Offline publication-gate checks for YouNew Data Project batches."""

import json
import re
import sys
from collections import Counter
from datetime import date, timedelta
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
GATES = ("build", "static", "duplicate", "source", "media", "search", "ai")
ENTITY_TYPES = {
    "government_service", "city", "place", "museum", "restaurant", "cafe",
    "hotel", "nature", "event", "local_partner", "housing", "healthcare",
    "education", "transport", "document", "knowledge_topic", "media",
}
LIFECYCLE_STATUSES = {"draft", "qa", "published", "retired"}
VERIFICATION_STATUSES = {"pending", "needs_review", "verified", "outdated", "rejected"}
SOURCE_STATUSES = {"pending", "verified_opened", "access_restricted", "rejected"}
IMAGE_ROLES = {"hero", "gallery", "thumbnail", "map_preview", "category_cover"}
REQUIRED_FIELDS = {
    "id", "entity_type", "category", "city_id", "province_id", "coordinates",
    "title", "description", "images", "official_source", "website",
    "related_entity_ids", "last_checked", "verification_status", "ai_summary",
    "review_frequency_days", "search_keywords", "lifecycle_status",
}
GEO_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner", "healthcare", "education", "transport"}
MEDIA_ROLES = {"hero", "gallery", "thumbnail", "map_preview"}
MEDIA_REQUIRED_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner"}
FORBIDDEN_TEXT = ("todo", "placeholder", "lorem ipsum", "generated placeholder")


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"{path.relative_to(ROOT)} is not valid JSON: {error}")


def fail(message: str):
    print(f"Data Project QA failed: {message}")
    raise SystemExit(1)


def expect(condition: bool, message: str):
    if not condition:
        fail(message)


def is_https(value) -> bool:
    if not isinstance(value, str):
        return False
    parsed = urlsplit(value)
    return parsed.scheme == "https" and bool(parsed.netloc)


def parse_date(value, label: str):
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError):
        fail(f"{label} must be an ISO date (YYYY-MM-DD)")


def normalized(value: str) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", value.casefold()))


def runtime_entity_ids():
    ids = set()
    for path in (ROOT / "YouNew").rglob("*.swift"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        ids.update(re.findall(r'\bid:\s*"([a-z0-9][a-z0-9._:-]+)"', text))
        ids.update(re.findall(r'\b(?:service|source)\(\s*"([a-z0-9][a-z0-9._:-]+)"', text))
    return ids


def validate_manifest():
    manifest = load_json(PROJECT / "work-packages.json")
    packages = manifest.get("work_packages", [])
    expected_ids = {f"WP-{number:02d}" for number in range(1, 18)}
    actual_ids = {item.get("id") for item in packages}
    expect(actual_ids == expected_ids, "work-packages.json must define WP-01 through WP-17 exactly once")
    expect(tuple(manifest.get("required_gates", [])) == GATES, "publication gates or their order changed")
    allowed = set(manifest.get("allowed_statuses", []))
    for package in packages:
        expect(package.get("status") in allowed, f"{package.get('id')} has an invalid status")
        expect(bool(package.get("domains")), f"{package.get('id')} has no owned domain")
    return actual_ids


def validate_governance(package_ids):
    releases = load_json(PROJECT / "releases" / "releases.json")
    release_ids = set()
    for release in releases.get("releases", []):
        release_id = release.get("id")
        expect(release_id and release_id not in release_ids, f"duplicate Data Release ID {release_id}")
        release_ids.add(release_id)
        expect(release.get("work_package") in package_ids, f"release {release_id} has unknown work package")
        expect(re.fullmatch(r"\d+\.\d+\.\d+", str(release.get("version"))) is not None, f"release {release_id} must use semantic versioning")
        expect(release.get("status") in {"planned", "qa", "published", "retired"}, f"release {release_id} has invalid status")
        qa = release.get("qa", {})
        expect(set(qa) == set(GATES), f"release {release_id} must contain all seven QA gates")
        if release.get("status") == "published":
            expect(all(qa[gate] == "passed" for gate in GATES), f"published release {release_id} has incomplete QA")
            expect(bool(release.get("published_at")), f"published release {release_id} has no publication date")

    milestones = {}
    for path in sorted((PROJECT / "milestones").glob("**/*.json")):
        milestone = load_json(path)
        milestone_id = milestone.get("id")
        expect(milestone_id and milestone_id not in milestones, f"duplicate milestone ID {milestone_id}")
        expect(milestone.get("work_package") in package_ids, f"milestone {milestone_id} has unknown work package")
        expect(milestone.get("target_release") in release_ids, f"milestone {milestone_id} has unknown target release")
        expect(milestone.get("status") in {"planned", "active", "qa", "complete"}, f"milestone {milestone_id} has invalid status")
        expect(int(milestone.get("target_records", 0)) > 0, f"milestone {milestone_id} has no record target")
        milestones[milestone_id] = milestone

    targets = load_json(PROJECT / "coverage-targets.json")
    keys = [target.get("key") for target in targets.get("targets", [])]
    expect(len(keys) == len(set(keys)) and keys, "coverage targets must have unique keys")
    targets_by_key = {target.get("key"): target for target in targets.get("targets", [])}
    for target in targets.get("targets", []):
        expect(target.get("work_package") in package_ids, f"coverage target {target.get('key')} has unknown work package")
        expect(int(target.get("target", 0)) > 0, f"coverage target {target.get('key')} must be positive")

    breadth = load_json(PROJECT / "coverage-dimensions.json")
    axes = breadth.get("axes", [])
    axis_keys = [axis.get("key") for axis in axes]
    expect(len(axis_keys) == len(set(axis_keys)) and axis_keys, "coverage breadth axes must have unique keys")
    axes_by_key = {axis.get("key"): axis for axis in axes}
    for axis in axes:
        axis_key = axis.get("key")
        target = targets_by_key.get(axis.get("target_key"))
        expect(target is not None, f"coverage axis {axis_key} has unknown target_key")
        expect(axis.get("work_package") == target.get("work_package"), f"coverage axis {axis_key} belongs to the wrong work package")
        expect(axis.get("field") in {"category", "province_id", "city_id"}, f"coverage axis {axis_key} has unsupported field")
        expect(int(axis.get("minimum_records_per_value", 1)) > 0, f"coverage axis {axis_key} must have a positive minimum depth")
        has_values = isinstance(axis.get("required_values"), list)
        has_reference = isinstance(axis.get("required_values_from"), str)
        expect(has_values != has_reference, f"coverage axis {axis_key} must define values or exactly one reference")
        if has_reference:
            source = axes_by_key.get(axis["required_values_from"])
            expect(source is not None and isinstance(source.get("required_values"), list), f"coverage axis {axis_key} has an invalid values reference")
            required_values = source["required_values"]
        else:
            required_values = axis["required_values"]
        expect(bool(required_values), f"coverage axis {axis_key} has no required values")
        value_keys = [value.get("key") for value in required_values]
        expect(len(value_keys) == len(set(value_keys)) and all(value_keys), f"coverage axis {axis_key} has duplicate or empty value keys")
        for value in required_values:
            expect(bool(str(value.get("label") or "").strip()), f"coverage axis {axis_key} value {value.get('key')} has no label")
            matches = value.get("match_values") or [value.get("key")]
            expect(isinstance(matches, list) and all(isinstance(item, str) and item for item in matches), f"coverage axis {axis_key} value {value.get('key')} has invalid matches")
    return {release["id"]: release for release in releases.get("releases", [])}, milestones


def validate_media(record, label: str, published: bool, media_id_owner: dict):
    images = record["images"]
    expect(isinstance(images, list), f"{label}.images must be an array")
    roles = set()
    for image in images:
        expect(isinstance(image, dict), f"{label} has a malformed media entry")
        required = {"id", "role", "source_page_url", "asset_url", "license", "license_url", "attribution", "verified", "retrieved_at"}
        expect(required <= set(image), f"{label} media is missing {sorted(required - set(image))}")
        media_id = image["id"]
        expect(media_id not in media_id_owner, f"media ID {media_id} is reused by {media_id_owner.get(media_id)} and {record['id']}")
        media_id_owner[media_id] = record["id"]
        expect(image["role"] in IMAGE_ROLES, f"{label} media {media_id} has invalid role {image['role']}")
        roles.add(image["role"])
        for field in ("source_page_url", "asset_url", "license_url"):
            expect(is_https(image[field]), f"{label} media {media_id} has invalid {field}")
        expect(bool(str(image["license"]).strip()), f"{label} media {media_id} has no license")
        expect(bool(str(image["attribution"]).strip()), f"{label} media {media_id} has no attribution")
        parse_date(image["retrieved_at"], f"{label} media {media_id}.retrieved_at")
        if published:
            expect(image["verified"] is True, f"published {label} media {media_id} is not verified")
    if published and record["entity_type"] in MEDIA_REQUIRED_TYPES:
        expect(MEDIA_ROLES <= roles, f"published {label} is missing media roles {sorted(MEDIA_ROLES - roles)}")


def validate_record(record, label: str, media_id_owner: dict):
    expect(isinstance(record, dict), f"{label} must be an object")
    expect(REQUIRED_FIELDS <= set(record), f"{label} is missing {sorted(REQUIRED_FIELDS - set(record))}")
    entity_id = record["id"]
    expect(re.fullmatch(r"[a-z0-9]+(?:[._:-][a-z0-9]+)+", entity_id) is not None, f"{label} has an unstable ID")
    expect(record["entity_type"] in ENTITY_TYPES, f"{label} has invalid entity_type {record['entity_type']}")
    expect(record["lifecycle_status"] in LIFECYCLE_STATUSES, f"{label} has invalid lifecycle_status")
    expect(record["verification_status"] in VERIFICATION_STATUSES, f"{label} has invalid verification_status")
    published = record["lifecycle_status"] == "published"
    expect(len(record["description"].strip()) >= 40, f"{label} description is too short")
    expect(len(record["ai_summary"].strip()) >= 40, f"{label} AI summary is too short")
    expect(isinstance(record["search_keywords"], list) and len(set(record["search_keywords"])) >= 3, f"{label} needs at least three unique search keywords")
    expect(entity_id not in record["related_entity_ids"], f"{label} links to itself")
    checked = parse_date(record["last_checked"], f"{label}.last_checked")
    expect(checked <= date.today(), f"{label}.last_checked is in the future")
    frequency = record["review_frequency_days"]
    expect(isinstance(frequency, int) and 1 <= frequency <= 400, f"{label}.review_frequency_days must be 1...400")
    source = record["official_source"]
    expect(isinstance(source, dict), f"{label}.official_source must be an object")
    source_fields = {"title", "publisher", "url", "is_official", "checked_at", "status"}
    expect(source_fields <= set(source), f"{label}.official_source is incomplete")
    expect(is_https(source["url"]), f"{label} source must be an exact HTTPS page")
    expect(source["status"] in SOURCE_STATUSES, f"{label} source has invalid status")
    expect(isinstance(source["is_official"], bool), f"{label} source is_official must be boolean")
    expect(parse_date(source["checked_at"], f"{label}.official_source.checked_at") <= date.today(), f"{label} source check is in the future")
    if record["website"] is not None:
        expect(is_https(record["website"]), f"{label}.website must use HTTPS")
    if record["entity_type"] in GEO_TYPES:
        coordinate = record["coordinates"]
        expect(isinstance(coordinate, dict), f"{label} requires coordinates")
        expect(50.7 <= coordinate.get("latitude", 0) <= 53.7, f"{label} latitude is outside the Netherlands")
        expect(3.2 <= coordinate.get("longitude", 0) <= 7.3, f"{label} longitude is outside the Netherlands")
        expect(bool(record["province_id"]), f"{label} requires province_id")
    if record["entity_type"] == "event":
        attributes = record.get("attributes") or {}
        active_through = attributes.get("end_date") or attributes.get("start_date")
        event_date = parse_date(active_through, f"{label}.attributes.end_date/start_date")
        if published:
            expect(event_date >= date.today(), f"published {label} event is expired")
    combined_text = " ".join([record["title"], record["description"], record["ai_summary"]]).casefold()
    expect(not any(marker in combined_text for marker in FORBIDDEN_TEXT), f"{label} contains placeholder text")
    if published:
        expect(record["verification_status"] == "verified", f"published {label} is not verified")
        expect(checked + timedelta(days=frequency) >= date.today(), f"published {label} exceeds its review frequency")
        expect(source["status"] == "verified_opened" and source["is_official"] is True, f"published {label} lacks an opened official source")
    validate_media(record, label, published, media_id_owner)


def main():
    package_ids = validate_manifest()
    releases, milestones = validate_governance(package_ids)
    batch_files = sorted((PROJECT / "batches").glob("**/*.json")) if (PROJECT / "batches").exists() else []
    entity_owner = {}
    title_owner = {}
    website_owner = {}
    media_id_owner = {}
    relations = []
    published_by_release = Counter()

    for path in batch_files:
        batch = load_json(path)
        label = str(path.relative_to(ROOT))
        expect(batch.get("work_package") in package_ids, f"{label} has an unknown work package")
        milestone_id = batch.get("milestone")
        release_id = batch.get("target_release")
        expect(milestone_id in milestones, f"{label} has an unknown milestone")
        expect(release_id in releases, f"{label} has an unknown target release")
        expect(milestones[milestone_id]["work_package"] == batch["work_package"], f"{label} milestone belongs to another work package")
        expect(milestones[milestone_id]["target_release"] == release_id, f"{label} milestone and release do not match")
        expect(releases[release_id]["work_package"] == batch["work_package"], f"{label} release belongs to another work package")
        expect(batch.get("publication_status") in LIFECYCLE_STATUSES, f"{label} has an invalid publication status")
        qa = batch.get("qa", {})
        expect(set(qa) == set(GATES), f"{label} must contain all seven QA gates")
        expect(all(value in {"pending", "passed", "failed", "not_applicable"} for value in qa.values()), f"{label} has an invalid QA result")
        evidence = batch.get("qa_evidence", {})
        if any(qa[gate] == "passed" for gate in GATES):
            expect(isinstance(evidence, dict), f"{label} must document QA evidence")
            expect(parse_date(evidence.get("checked_at"), f"{label}.qa_evidence.checked_at") <= date.today(), f"{label} QA evidence is dated in the future")
            for gate in GATES:
                if qa[gate] == "passed":
                    expect(bool(str(evidence.get(gate) or "").strip()), f"{label} has no evidence for passed {gate} QA")
        if batch["publication_status"] == "published":
            expect(all(qa[gate] == "passed" for gate in GATES), f"published {label} has an incomplete publication gate")
        records = batch.get("records")
        expect(isinstance(records, list) and records, f"{label} must contain at least one record")
        for index, record in enumerate(records):
            record_label = f"{label} record {index + 1}"
            validate_record(record, record_label, media_id_owner)
            if batch["publication_status"] == "published":
                expect(record["lifecycle_status"] == "published", f"published {label} contains a non-published record")
            if record["lifecycle_status"] == "published":
                expect(batch["publication_status"] == "published", f"{record_label} is published inside a non-published batch")
                published_by_release[release_id] += 1
            entity_id = record["id"]
            expect(entity_id not in entity_owner, f"duplicate entity ID {entity_id} in {entity_owner.get(entity_id)} and {label}")
            entity_owner[entity_id] = label
            title_key = (record["entity_type"], normalized(record["title"]), record.get("city_id"))
            expect(title_key not in title_owner, f"probable duplicate title {record['title']} in {title_owner.get(title_key)} and {label}")
            title_owner[title_key] = label
            if record["website"]:
                website_key = record["website"].rstrip("/").casefold()
                expect(website_key not in website_owner, f"duplicate canonical website {record['website']}")
                website_owner[website_key] = entity_id
            relations.extend((entity_id, related) for related in record["related_entity_ids"])

    known_ids = runtime_entity_ids() | set(entity_owner)
    for entity_id, related_id in relations:
        expect(related_id in known_ids, f"{entity_id} has unresolved relation {related_id}")

    for release_id, release in releases.items():
        expect(release.get("published_records") == published_by_release[release_id], f"release {release_id} published_records does not match its batches")

    print("Data Project QA passed")
    print("- Work packages: 17")
    print(f"- Milestones: {len(milestones)}")
    print(f"- Data Releases: {len(releases)}")
    print(f"- Batches: {len(batch_files)}")
    print(f"- Records: {len(entity_owner)}")
    print("- Publication gates: build, static, duplicate, source, media, search, AI")


if __name__ == "__main__":
    main()
