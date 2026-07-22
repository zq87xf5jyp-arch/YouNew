#!/usr/bin/env python3
"""Build the deterministic Data Project runtime artifact or a safe QA preview."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from collections import defaultdict
from datetime import date, timedelta
from pathlib import Path
from urllib.parse import urlsplit

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
SCHEMA_PATH = PROJECT / "schema" / "entity.schema.json"
RELEASES_PATH = PROJECT / "releases" / "releases.json"
MANIFESTS_DIR = PROJECT / "reports" / "release-manifests"
MIGRATION_PATH = PROJECT / "observability" / "migration-registry.json"
RUNTIME_PATH = ROOT / "YouNew" / "Resources" / "Data" / "younew-runtime-data.json"
PREVIEW_PATH = PROJECT / "reports" / "import-preview.json"
REVIEWER_REGISTRY_PATH = PROJECT / "operations" / "reviewer-registry.json"
GUIDE_EVIDENCE_REGISTRY_PATH = PROJECT / "operations" / "guide-evidence-registry.json"
GATES = ("build", "static", "duplicate", "source", "media", "search", "ai")
STABLE_ID = re.compile(r"^[a-z0-9]+(?:[._:-][a-z0-9]+)+$")
PUBLIC_ASSET_PATH = re.compile(r"^/images/[A-Za-z0-9](?:[A-Za-z0-9._/-]*[A-Za-z0-9])?\.(?:avif|gif|jpe?g|png|svg|webp)$", re.IGNORECASE)
EMAIL_ADDRESS = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
PHONE_NUMBER = re.compile(r"^\+?[0-9][0-9 .()/-]{4,30}$")
SUPPORTED_GUIDE_LOCALES = {"en", "nl", "ru", "uk", "pl"}
PUBLIC_GUIDE_CATEGORIES = {"government", "housing", "healthcare", "transport", "education", "work", "integration", "emergency", "finance", "business"}
PUBLIC_SITE_ASSETS = ROOT / "admin-dashboard" / "public-site" / "public"


class ImportFailure(RuntimeError):
    pass


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ImportFailure(f"Cannot read {path.relative_to(ROOT)}: {error}") from error


def safe_https_url(value) -> bool:
    if not isinstance(value, str) or len(value) > 2048:
        return False
    parsed = urlsplit(value)
    return bool(
        parsed.scheme == "https"
        and parsed.hostname
        and parsed.username is None
        and parsed.password is None
    )


def visible_text(value) -> str:
    if not isinstance(value, str):
        return ""
    return "".join(character for character in value if unicodedata.category(character) not in {"Cc", "Cf", "Cs"}).strip()


def reviewer_catalog_from_registry(registry):
    if registry.get("schema_version") != 1 or registry.get("policy", {}).get("automated_reviewers_allowed") is not False:
        raise ImportFailure("Reviewer registry policy is missing or unsafe")
    reviewers = registry.get("reviewers")
    if not isinstance(reviewers, list):
        raise ImportFailure("Reviewer registry reviewers must be an array")
    catalog = {}
    for reviewer in reviewers:
        reviewer_id = reviewer.get("id") if isinstance(reviewer, dict) else None
        if not isinstance(reviewer_id, str) or len(reviewer_id) > 160 or not STABLE_ID.fullmatch(reviewer_id) or reviewer_id in catalog:
            raise ImportFailure("Reviewer registry contains a missing or duplicate reviewer ID")
        if reviewer.get("reviewer_type") not in {"human_editor", "subject_matter_expert", "official_owner"}:
            raise ImportFailure(f"Reviewer registry entry {reviewer_id} is not an allowed human reviewer type")
        if not visible_text(reviewer.get("name")) or not visible_text(reviewer.get("role")):
            raise ImportFailure(f"Reviewer registry entry {reviewer_id} lacks a visible name or role")
        if not isinstance(reviewer.get("active"), bool):
            raise ImportFailure(f"Reviewer registry entry {reviewer_id} active must be boolean")
        locales = reviewer.get("locales")
        if not isinstance(locales, list) or not locales or len(locales) != len(set(locales)) or any(locale not in SUPPORTED_GUIDE_LOCALES for locale in locales):
            raise ImportFailure(f"Reviewer registry entry {reviewer_id} has invalid or duplicate locales")
        categories = reviewer.get("categories")
        if (
            not isinstance(categories, list)
            or not categories
            or len(categories) != len(set(categories))
            or any(not isinstance(category, str) or (category != "*" and not re.fullmatch(r"[a-z0-9][a-z0-9_:-]{1,79}", category)) for category in categories)
        ):
            raise ImportFailure(f"Reviewer registry entry {reviewer_id} has invalid or duplicate categories")
        catalog[reviewer_id] = reviewer
    return catalog


def registered_reviewers():
    return reviewer_catalog_from_registry(read_json(REVIEWER_REGISTRY_PATH))


def public_route_slug_for_id(entity_id: str) -> str:
    identifier_slug = "-".join(entity_id.split(".")[1:])
    normalized = unicodedata.normalize("NFKD", identifier_slug)
    without_marks = "".join(character for character in normalized if unicodedata.category(character) != "Mn")
    return re.sub(r"[^a-z0-9]+", "-", without_marks.lower()).strip("-")[:96].rstrip("-")


def resolved_public_asset(value):
    if not isinstance(value, str) or not PUBLIC_ASSET_PATH.fullmatch(value) or "//" in value or "/../" in value or value.endswith("/.."):
        return None
    candidate = (PUBLIC_SITE_ASSETS / value.removeprefix("/")).resolve()
    try:
        candidate.relative_to(PUBLIC_SITE_ASSETS.resolve())
    except ValueError:
        return None
    return candidate if candidate.is_file() else None


def registered_guide_evidence():
    registry = read_json(GUIDE_EVIDENCE_REGISTRY_PATH)
    if registry.get("schema_version") != 1 or registry.get("policy", {}).get("unresolved_evidence_blocks_publication") is not True:
        raise ImportFailure("Guide evidence registry policy is missing or unsafe")
    evidence_items = registry.get("evidence")
    if not isinstance(evidence_items, list):
        raise ImportFailure("Guide evidence registry evidence must be an array")
    catalog = {}
    for item in evidence_items:
        evidence_id = item.get("id") if isinstance(item, dict) else None
        if not evidence_id or evidence_id in catalog:
            raise ImportFailure("Guide evidence registry contains a missing or duplicate evidence ID")
        relative_path = item.get("artifact_path")
        if not isinstance(relative_path, str) or Path(relative_path).is_absolute():
            raise ImportFailure(f"Guide evidence {evidence_id} has an unsafe artifact path")
        artifact_path = (ROOT / relative_path).resolve()
        try:
            artifact_path.relative_to(ROOT.resolve())
        except ValueError as error:
            raise ImportFailure(f"Guide evidence {evidence_id} escapes the repository") from error
        if not artifact_path.is_file():
            raise ImportFailure(f"Guide evidence {evidence_id} artifact is missing")
        digest = hashlib.sha256(artifact_path.read_bytes()).hexdigest()
        if item.get("sha256") != digest:
            raise ImportFailure(f"Guide evidence {evidence_id} digest does not match its artifact")
        catalog[evidence_id] = item
    return catalog


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
        if "maxLength" in schema and len(value) > schema["maxLength"]:
            raise ImportFailure(f"{label}: string is too long")
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
        if "maxItems" in schema and len(value) > schema["maxItems"]:
            raise ImportFailure(f"{label}: too many items")
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
    is_overlay = bool(release.get("overlay_path"))
    if manifest_entry is None:
        if not is_overlay or release.get("status") == "published":
            raise ImportFailure(f"Release {release_id} has no generated release manifest")
    else:
        _, manifest = manifest_entry
        if manifest.get("release_id") != release_id or manifest.get("version") != release.get("version"):
            raise ImportFailure(f"Release {release_id} manifest does not match releases.json")
        if manifest.get("status") != release.get("status"):
            raise ImportFailure(f"Release {release_id} manifest status does not match releases.json")
    if not batches and not is_overlay:
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
    result = {
        "id": image["id"],
        "role": image["role"],
        "assetURL": image["asset_url"],
        "sourcePageURL": image["source_page_url"],
        "license": image["license"],
        "licenseURL": image["license_url"],
        "attribution": image["attribution"],
        "alt": image.get("alt", ""),
        "verified": image["verified"],
        "retrievedAt": image["retrieved_at"],
    }
    if image.get("public_asset_path"):
        result["publicAssetPath"] = image["public_asset_path"]
    return result


def runtime_coordinate(coordinates):
    if coordinates is None:
        return None
    return {
        key: int(value) if isinstance(value, float) and value.is_integer() else value
        for key, value in coordinates.items()
    }


def runtime_sourced_block(block):
    return {
        "id": block["id"],
        "text": block["text"],
        "sourceIDs": list(block["source_ids"]),
    }


def runtime_practical_guide(guide):
    jurisdiction = guide["jurisdiction"]
    estimated_time = guide["estimated_time"]
    estimated_cost = guide["estimated_cost"]
    reviewer = guide["reviewer"]
    seo = guide["seo"]
    return {
        "schemaVersion": guide["schema_version"],
        "id": guide["id"],
        "slug": guide["slug"],
        "locale": guide["locale"],
        "title": guide["title"],
        "shortSummary": runtime_sourced_block(guide["short_summary"]),
        "audienceProfiles": list(guide["audience_profiles"]),
        "whoThisIsFor": runtime_sourced_block(guide["who_this_is_for"]),
        "whenYouNeedIt": runtime_sourced_block(guide["when_you_need_it"]),
        "applicability": {
            "cityIDs": list(guide["applicability"]["city_ids"]),
            "provinceIDs": list(guide["applicability"]["province_ids"]),
        },
        "jurisdiction": {
            "level": jurisdiction["level"],
            "countryCode": jurisdiction["country_code"],
            "municipalityDependent": jurisdiction["municipality_dependent"],
            "note": jurisdiction["note"],
            "sourceIDs": list(jurisdiction["source_ids"]),
        },
        "prerequisites": [runtime_sourced_block(item) for item in guide["prerequisites"]],
        "requiredDocuments": [runtime_sourced_block(item) for item in guide["required_documents"]],
        "estimatedTime": {
            "state": estimated_time["state"],
            "value": estimated_time["value"],
            "note": estimated_time["note"],
            "sourceIDs": list(estimated_time["source_ids"]),
        },
        "estimatedCost": {
            "state": estimated_cost["state"],
            "value": estimated_cost["value"],
            "note": estimated_cost["note"],
            "currency": estimated_cost["currency"],
            "sourceIDs": list(estimated_cost["source_ids"]),
        },
        "numberedSteps": [
            {
                "id": item["id"],
                "position": item["position"],
                "title": item["title"],
                "body": item["body"],
                "sourceIDs": list(item["source_ids"]),
                "municipalityDependent": item["municipality_dependent"],
            }
            for item in guide["numbered_steps"]
        ],
        "warnings": [runtime_sourced_block(item) for item in guide["warnings"]],
        "commonMistakes": [runtime_sourced_block(item) for item in guide["common_mistakes"]],
        "tips": [runtime_sourced_block(item) for item in guide["tips"]],
        "checklist": [runtime_sourced_block(item) for item in guide["checklist"]],
        "faqs": [
            {
                "id": item["id"],
                "question": item["question"],
                "answer": item["answer"],
                "sourceIDs": list(item["source_ids"]),
            }
            for item in guide["faqs"]
        ],
        "emergencyInformation": [runtime_sourced_block(item) for item in guide["emergency_information"]],
        "sections": [
            {
                "id": item["id"],
                "title": item["title"],
                "body": item["body"],
                "sourceIDs": list(item["source_ids"]),
            }
            for item in guide["sections"]
        ],
        "officialSources": [
            {
                "id": item["id"],
                "title": item["title"],
                "publisher": item["publisher"],
                "url": item["url"],
                "isOfficial": item["is_official"],
                "checkedAt": item["checked_at"],
                "status": item["status"],
            }
            for item in guide["official_sources"]
        ],
        "contactOptions": [
            {
                "id": item["id"],
                "kind": item["kind"],
                "label": item["label"],
                "value": item["value"],
                "sourceIDs": list(item["source_ids"]),
            }
            for item in guide["contact_options"]
        ],
        "relatedGuideIDs": list(guide["related_guide_ids"]),
        "nextActions": [runtime_sourced_block(item) for item in guide["next_actions"]],
        "verifiedAt": guide["verified_at"],
        "updatedAt": guide["updated_at"],
        "reviewer": {
            "id": reviewer["id"],
            "name": reviewer["name"],
            "role": reviewer["role"],
            "reviewerType": reviewer["reviewer_type"],
            "reviewedAt": reviewer["reviewed_at"],
        },
        "readingTimeMinutes": guide["reading_time_minutes"],
        "difficulty": guide["difficulty"],
        "confidenceLevel": guide["confidence_level"],
        "tags": list(guide["tags"]),
        "publicationGate": {
            "status": guide["publication_gate"]["status"],
            "checkedAt": guide["publication_gate"]["checked_at"],
            "checks": dict(guide["publication_gate"]["checks"]),
            "notes": guide["publication_gate"]["notes"],
            "evidenceIDs": list(guide["publication_gate"]["evidence_ids"]),
        },
        "disclaimer": guide["disclaimer"],
        "status": guide["status"],
        "seo": {
            "title": seo["title"],
            "description": seo["description"],
            "canonicalPath": seo["canonical_path"],
        },
        "synonyms": list(guide["synonyms"]),
        "commonQuestions": list(guide["common_questions"]),
    }


def validate_published_practical_guide(record, label: str, reviewer_catalog_override=None, evidence_catalog_override=None):
    guide = record.get("practical_guide")
    if guide is None:
        return
    if guide["id"] != record["id"]:
        raise ImportFailure(f"{label}.practical_guide.id must equal the canonical entity ID")
    if guide["status"] != "published":
        return
    if guide["schema_version"] != 2:
        raise ImportFailure(f"{label}.practical_guide must use schema_version 2 before publication")
    if guide["locale"] != "en":
        raise ImportFailure(f"{label}.practical_guide locale is not yet supported by the published web route contract")
    if record["lifecycle_status"] != "published" or record["verification_status"] != "verified":
        raise ImportFailure(f"{label}: a published practical guide requires a published, verified parent record")
    if record["entity_type"] not in {"government_service", "housing", "document", "knowledge_topic"}:
        raise ImportFailure(f"{label}.practical_guide is attached to an unsupported parent entity type")
    public_web_category = (record.get("attributes") or {}).get("publicWebCategory")
    if public_web_category not in PUBLIC_GUIDE_CATEGORIES:
        raise ImportFailure(f"{label}.practical_guide requires an explicit supported attributes.publicWebCategory")
    if guide["title"] != record["title"]:
        raise ImportFailure(f"{label}.practical_guide.title must equal the canonical entity title")
    expected_slug = public_route_slug_for_id(record["id"])
    if not expected_slug or guide["slug"] != expected_slug:
        raise ImportFailure(f"{label}.practical_guide.slug must equal deterministic public slug {expected_slug!r}")
    if guide["seo"]["canonical_path"].rstrip("/") != f"/guides/{expected_slug}":
        raise ImportFailure(f"{label}.practical_guide SEO canonical path must equal its deterministic public route")
    if guide["confidence_level"] != "high":
        raise ImportFailure(f"{label}.practical_guide requires high confidence before publication")
    gate = guide["publication_gate"]
    required_gate_checks = {"schema", "factual_sources", "links", "language", "media", "duplicate_content", "accessibility"}
    if gate["status"] != "passed" or set(gate["checks"]) != required_gate_checks or not all(gate["checks"].values()):
        raise ImportFailure(f"{label}.practical_guide publication gate has not passed every required check")
    if not visible_text(gate.get("notes")) or not gate.get("evidence_ids"):
        raise ImportFailure(f"{label}.practical_guide publication gate lacks notes or evidence IDs")
    evidence_catalog = evidence_catalog_override if evidence_catalog_override is not None else registered_guide_evidence()
    resolved_checks = set()
    for evidence_id in gate["evidence_ids"]:
        evidence = evidence_catalog.get(evidence_id)
        if (
            not evidence
            or evidence.get("status") != "passed"
            or evidence.get("guide_id") != guide["id"]
            or evidence.get("checked_at") != gate["checked_at"]
        ):
            raise ImportFailure(f"{label}.practical_guide evidence {evidence_id} is unresolved or does not match the guide gate")
        resolved_checks.update(evidence.get("checks", []))
    if resolved_checks != required_gate_checks:
        raise ImportFailure(f"{label}.practical_guide evidence does not cover every required gate check")
    if not record["images"]:
        raise ImportFailure(f"{label}.practical_guide requires at least one verified, accessible media asset")
    for image in record["images"]:
        if (
            image["verified"] is not True
            or not visible_text(image.get("alt"))
            or not safe_https_url(image.get("asset_url"))
            or not safe_https_url(image.get("source_page_url"))
            or not safe_https_url(image.get("license_url"))
            or resolved_public_asset(image.get("public_asset_path")) is None
        ):
            raise ImportFailure(f"{label}.practical_guide media {image['id']} is unverified, inaccessible, or lacks a safe local public asset and alt text")

    source_ids = [item["id"] for item in guide["official_sources"]]
    if len(source_ids) != len(set(source_ids)):
        raise ImportFailure(f"{label}.practical_guide has duplicate official source IDs")
    for source in guide["official_sources"]:
        if source["is_official"] is not True or source["status"] != "verified_opened":
            raise ImportFailure(f"{label}.practical_guide source {source['id']} is not an opened official source")
        if not safe_https_url(source.get("url")):
            raise ImportFailure(f"{label}.practical_guide source {source['id']} must use a safe HTTPS URL")
        if date.fromisoformat(source["checked_at"]) > date.today():
            raise ImportFailure(f"{label}.practical_guide source {source['id']} has a future check date")

    verified_at = date.fromisoformat(guide["verified_at"])
    updated_at = date.fromisoformat(guide["updated_at"])
    reviewed_at = date.fromisoformat(guide["reviewer"]["reviewed_at"])
    gate_checked_at = date.fromisoformat(gate["checked_at"])
    if verified_at > date.today() or updated_at > date.today():
        raise ImportFailure(f"{label}.practical_guide has a future verification or update date")
    if updated_at > verified_at:
        raise ImportFailure(f"{label}.practical_guide was updated after its last verification")
    if not (updated_at <= reviewed_at <= verified_at):
        raise ImportFailure(f"{label}.practical_guide reviewer date must fall between update and verification")
    if not (updated_at <= gate_checked_at <= verified_at):
        raise ImportFailure(f"{label}.practical_guide publication gate date must fall between update and verification")
    if date.fromisoformat(record["last_checked"]) > verified_at:
        raise ImportFailure(f"{label}.practical_guide predates its parent record verification")
    if verified_at + timedelta(days=record["review_frequency_days"]) < date.today():
        raise ImportFailure(f"{label}.practical_guide exceeds the parent record review frequency")
    for source in guide["official_sources"]:
        source_checked_at = date.fromisoformat(source["checked_at"])
        if not (updated_at <= source_checked_at <= verified_at):
            raise ImportFailure(f"{label}.practical_guide source {source['id']} must be checked between content update and verification")

    reviewer = guide["reviewer"]
    reviewers = reviewer_catalog_override if reviewer_catalog_override is not None else registered_reviewers()
    registered = reviewers.get(reviewer["id"])
    if not registered or registered.get("active") is not True:
        raise ImportFailure(f"{label}.practical_guide reviewer is not active in the human reviewer registry")
    for key in ("name", "role", "reviewer_type"):
        if registered.get(key) != reviewer.get(key):
            raise ImportFailure(f"{label}.practical_guide reviewer {key} does not match the registry")
    if guide["locale"] not in registered.get("locales", []):
        raise ImportFailure(f"{label}.practical_guide reviewer is not authorized for locale {guide['locale']}")
    categories = registered.get("categories", [])
    if "*" not in categories and record["category"] not in categories:
        raise ImportFailure(f"{label}.practical_guide reviewer is not authorized for category {record['category']}")

    jurisdiction = guide["jurisdiction"]
    if jurisdiction["level"] == "undetermined" or jurisdiction["municipality_dependent"] is None:
        raise ImportFailure(f"{label}.practical_guide requires a resolved jurisdiction")
    if jurisdiction["municipality_dependent"] and not jurisdiction["note"]:
        raise ImportFailure(f"{label}.practical_guide must explain municipality-dependent instructions")
    city_ids = guide["applicability"]["city_ids"]
    province_ids = guide["applicability"]["province_ids"]
    municipal_steps = any(item["municipality_dependent"] for item in guide["numbered_steps"])
    if jurisdiction["level"] == "municipal" and not city_ids:
        raise ImportFailure(f"{label}.practical_guide municipal jurisdiction requires applicable city IDs")
    if jurisdiction["level"] == "provincial" and not province_ids:
        raise ImportFailure(f"{label}.practical_guide provincial jurisdiction requires applicable province IDs")
    if jurisdiction["level"] == "mixed" and not (city_ids or province_ids):
        raise ImportFailure(f"{label}.practical_guide mixed jurisdiction requires city or province applicability")
    if (jurisdiction["municipality_dependent"] or municipal_steps) and not city_ids:
        raise ImportFailure(f"{label}.practical_guide municipality-dependent content requires applicable city IDs")
    if jurisdiction["level"] == "national" and (jurisdiction["municipality_dependent"] or municipal_steps):
        raise ImportFailure(f"{label}.practical_guide national jurisdiction cannot contain municipality-dependent instructions")

    sourced_items = [
        guide["short_summary"], guide["who_this_is_for"], guide["when_you_need_it"],
        guide["jurisdiction"], guide["estimated_time"], guide["estimated_cost"],
    ]
    for key in (
        "prerequisites", "required_documents", "numbered_steps", "warnings", "common_mistakes",
        "tips", "checklist", "faqs", "emergency_information", "sections", "contact_options", "next_actions",
    ):
        sourced_items.extend(guide[key])
    allowed_source_ids = set(source_ids)
    for item in sourced_items:
        item_source_ids = item.get("source_ids", [])
        item_id = item.get("id", item.get("level", item.get("state", "value")))
        if not item_source_ids:
            raise ImportFailure(f"{label}.practical_guide factual item {item_id!r} has no source_ids")
        unknown = sorted(set(item_source_ids) - allowed_source_ids)
        if unknown:
            raise ImportFailure(f"{label}.practical_guide factual item {item_id!r} has unknown source_ids: {unknown}")

    positions = [item["position"] for item in guide["numbered_steps"]]
    if positions != list(range(1, len(positions) + 1)):
        raise ImportFailure(f"{label}.practical_guide numbered_steps must use contiguous positions starting at 1")
    content_ids = [
        item["id"]
        for key in (
            "prerequisites", "required_documents", "numbered_steps", "warnings", "common_mistakes",
            "tips", "checklist", "faqs", "emergency_information", "sections", "contact_options", "next_actions",
        )
        for item in guide[key]
    ]
    if len(content_ids) != len(set(content_ids)):
        raise ImportFailure(f"{label}.practical_guide content block IDs must be unique")
    for contact in guide["contact_options"]:
        value = visible_text(contact.get("value"))
        if contact["kind"] == "url" and not safe_https_url(value):
            raise ImportFailure(f"{label}.practical_guide contact {contact['id']} must use safe HTTPS")
        if contact["kind"] == "email" and (len(value) > 254 or not EMAIL_ADDRESS.fullmatch(value)):
            raise ImportFailure(f"{label}.practical_guide contact {contact['id']} has an invalid email address")
        if contact["kind"] == "phone" and (not PHONE_NUMBER.fullmatch(value) or sum(character.isdigit() for character in value) < 6):
            raise ImportFailure(f"{label}.practical_guide contact {contact['id']} has an invalid phone number")
    if guide["id"] in guide["related_guide_ids"]:
        raise ImportFailure(f"{label}.practical_guide cannot relate to itself")
    for estimate_key in ("estimated_time", "estimated_cost"):
        estimate = guide[estimate_key]
        if not visible_text(estimate.get("note")):
            raise ImportFailure(f"{label}.practical_guide {estimate_key} requires an authored explanatory note")
        if estimate["state"] == "known" and not visible_text(estimate.get("value")):
            raise ImportFailure(f"{label}.practical_guide {estimate_key} is known but has no value")
        if estimate["state"] != "known" and (estimate.get("value") is not None or not visible_text(estimate.get("note"))):
            raise ImportFailure(f"{label}.practical_guide {estimate_key} must explain a non-known value")
        if estimate_key == "estimated_cost":
            if estimate["state"] == "known" and not estimate.get("currency"):
                raise ImportFailure(f"{label}.practical_guide known estimated_cost requires a currency")
            if estimate["state"] != "known" and estimate.get("currency") is not None:
                raise ImportFailure(f"{label}.practical_guide non-known estimated_cost cannot assert a currency")
    if guide["seo"]["title"].casefold().endswith("| younew"):
        raise ImportFailure(f"{label}.practical_guide SEO title must be unbranded because the web layout adds the brand")


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
    result = {
        "id": record["id"],
        "kind": kind_for(record["entity_type"]),
        "title": record["title"],
        "summary": record["description"],
        "cityId": record["city_id"],
        "provinceId": record["province_id"],
        "category": record["category"],
        # Integral JSON floats (for example 52.0) must serialize identically in
        # Python and JavaScript so the checked runtime checksum stays portable.
        "coordinate": runtime_coordinate(record["coordinates"]),
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
    guide = record.get("practical_guide")
    if guide is not None and guide["status"] == "published":
        result["practicalGuide"] = runtime_practical_guide(guide)
    return result


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
        try:
            selected_ids = effective_release_heads(PROJECT, statuses={"published"})
        except EffectiveReleaseError as error:
            raise ImportFailure(f"Effective release resolution failed: {error}") from error
    else:
        try:
            selected_ids = effective_release_heads(PROJECT)
        except EffectiveReleaseError as error:
            raise ImportFailure(f"Effective release resolution failed: {error}") from error
    unknown = [item for item in selected_ids if item not in releases]
    if unknown:
        raise ImportFailure(f"Unknown release: {', '.join(unknown)}")

    all_records = {}
    records_by_release = defaultdict(list)
    source_by_id = {}
    imported_batch_paths = []
    effective_release_paths = []
    city_provinces = {}
    release_summaries = []
    for release_id in selected_ids:
        release = releases[release_id]
        batches = batches_by_release.get(release_id, [])
        validate_release(release_id, release, manifests.get(release_id), batches)
        try:
            effective = resolve_release(PROJECT, release_id)
        except EffectiveReleaseError as error:
            raise ImportFailure(f"Effective release {release_id} is invalid: {error}") from error
        release_records = []
        for path in effective.batch_paths:
            imported_batch_paths.append(path)
            batch = read_json(path)
            validate_gates(path, batch)
            if batch.get("publication_status") not in {"qa", "published"}:
                raise ImportFailure(f"{path.relative_to(ROOT)} is not QA-ready")
        if effective.overlay is not None:
            overlay_path = Path(release["overlay_path"])
            if not overlay_path.is_absolute():
                overlay_path = ROOT / overlay_path
            validate_gates(overlay_path, effective.overlay)
            if effective.overlay.get("status") not in {"qa", "published"}:
                raise ImportFailure(f"{overlay_path.relative_to(ROOT)} is not QA-ready")
            effective_release_paths.extend(path for path in effective.input_paths if path not in effective.batch_paths)
        for record in effective.records:
            entity_id = record["id"]
            label = effective.record_sources[entity_id]
            try:
                label = str(Path(label.split(" record ", 1)[0]).relative_to(ROOT)) + label[len(label.split(" record ", 1)[0]):]
            except (ValueError, IndexError):
                pass
            validate_schema(record, schema, schema, label)
            validate_published_practical_guide(record, label)
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
            "batchCount": len(effective.batch_paths),
            "replacementCount": effective.replacement_count,
            "qaReadyRecordCount": len(release_records),
        })

    all_project_ids = set()
    for batch_entries in batches_by_release.values():
        for _, batch in batch_entries:
            all_project_ids.update(item.get("id") for item in batch.get("records", []))
    known_ids = all_project_ids | runtime_ids_from_swift()
    public_route_groups = {
        "government_service": "guide", "housing": "guide", "document": "guide", "knowledge_topic": "guide",
        "city": "city",
        "healthcare": "organization", "education": "organization", "local_partner": "organization",
        "place": "place", "museum": "place", "restaurant": "place", "cafe": "place", "hotel": "place",
        "nature": "place", "event": "place", "transport": "place", "media": "place",
    }
    route_candidates = defaultdict(list)
    for record in all_records.values():
        route_candidates[(public_route_groups[record["entity_type"]], public_route_slug_for_id(record["id"]))].append(record)
    for (route_group, route_slug), candidates in route_candidates.items():
        published_guides = [record for record in candidates if record.get("practical_guide", {}).get("status") == "published"]
        if published_guides and len(candidates) > 1:
            conflicting_ids = sorted(record["id"] for record in candidates)
            raise ImportFailure(f"Published practical guide route /{route_group}s/{route_slug} collides across canonical IDs: {conflicting_ids}")

    for entity_id, record in all_records.items():
        unresolved = sorted(set(record["related_entity_ids"]) - known_ids)
        if unresolved:
            raise ImportFailure(f"{entity_id} has unresolved related_entity_ids: {unresolved}")
        guide = record.get("practical_guide")
        if guide is not None and guide["status"] == "published":
            unresolved_guides = sorted(set(guide["related_guide_ids"]) - all_project_ids)
            if unresolved_guides:
                raise ImportFailure(f"{entity_id} has unresolved practical guide relations: {unresolved_guides}")
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
    manifest_paths = [manifests[item][0] for item in selected_ids if item in manifests]
    input_fingerprint = {
        "schemaVersion": schema.get("$id", "unknown"),
        "schema": file_fingerprint(SCHEMA_PATH),
        "releaseManifests": [file_fingerprint(path) for path in sorted(manifest_paths)],
        "batchFiles": [file_fingerprint(path) for path in sorted(set(imported_batch_paths))],
        "effectiveReleaseFiles": [file_fingerprint(path) for path in sorted(set(effective_release_paths))],
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
