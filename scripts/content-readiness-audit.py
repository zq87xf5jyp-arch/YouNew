#!/usr/bin/env python3
"""Build an evidence-based YouNew content coverage/readiness matrix.

This audit is deliberately read-only. It reconciles the governed DATA PROJECT,
the canonical runtime artifact and the generated public-web artifact. It does
not open URLs and it does not promote content. Network reachability remains the
responsibility of the existing data-health/link-check pipeline.

Definitions used here are emitted in the JSON and Markdown outputs. In short:

* coverage uses repository-owned denominators from coverage-targets.json and
  coverage-dimensions.json;
* production readiness is fail-closed and requires a currently published,
  verified, fresh, sourced practical guide plus the editorial fields requested
  by the content-readiness brief;
* the proposed P1/P2/P3 grouping is an editorial proposal over the existing 36
  governed topic families. It is not written back to canonical content.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from dataclasses import dataclass
from datetime import date, timedelta
from difflib import SequenceMatcher
from functools import lru_cache
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
DATA_PROJECT = ROOT / "DataProject"
BATCHES = DATA_PROJECT / "batches"
RELEASES_PATH = DATA_PROJECT / "releases" / "releases.json"
TARGETS_PATH = DATA_PROJECT / "coverage-targets.json"
DIMENSIONS_PATH = DATA_PROJECT / "coverage-dimensions.json"
STAGING_GUIDES_PATH = DATA_PROJECT / "staging" / "practical-guides-wave-1.json"
ENTITY_SCHEMA_PATH = DATA_PROJECT / "schema" / "entity.schema.json"
FRESHNESS_POLICY_PATH = DATA_PROJECT / "observability" / "freshness-policy.json"
RUNTIME_PATH = ROOT / "YouNew" / "Resources" / "Data" / "younew-runtime-data.json"
PUBLIC_CONTENT_PATH = ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-content.json"
DATA_HEALTH_PATH = DATA_PROJECT / "reports" / "data-health.json"
REVIEWER_REGISTRY_PATH = DATA_PROJECT / "operations" / "reviewer-registry.json"
GUIDE_EVIDENCE_REGISTRY_PATH = DATA_PROJECT / "operations" / "guide-evidence-registry.json"
DEFAULT_JSON_OUTPUT = DATA_PROJECT / "quality" / "content-readiness-matrix.json"
DEFAULT_MARKDOWN_OUTPUT = DATA_PROJECT / "quality" / "content-readiness-matrix.md"

# These are the canonical entity types whose runtime kinds are mapped by the
# public-site generator to a Guide page. Healthcare/transport locations remain
# organizations or places rather than editorial guides.
GUIDE_ENTITY_TYPES = {"government_service", "housing", "document", "knowledge_topic"}
CONTENT_TARGET_KEYS = {"government", "housing", "healthcare", "transport", "education"}
CONTENT_WORK_PACKAGES = {"WP-01", "WP-02", "WP-03", "WP-04", "WP-05"}
USER_PATHS = ("tourist", "student", "expat", "refugee", "worker", "resident")

# Proposed classification, grounded only in keys that already exist in
# coverage-dimensions.json. The brief names registration, BSN, DigiD, health
# insurance, GP, emergency, housing, transport, tax, work, residence, education
# and the newcomer profiles as indispensable. Daily-life and supplementary
# families are separated conservatively below. This mapping is report-only.
PRIORITY_BY_FAMILY = {
    # Government topic families.
    "government-topic-families/identity-registration": 1,
    "government-topic-families/digital-government": 1,
    "government-topic-families/immigration-residency": 1,
    "government-topic-families/citizenship-integration": 1,
    "government-topic-families/taxes": 1,
    "government-topic-families/benefits-allowances": 1,
    "government-topic-families/employment-unemployment": 1,
    "government-topic-families/health-insurance": 1,
    "government-topic-families/education-finance": 1,
    "government-topic-families/housing-local-services": 1,
    "government-topic-families/justice-legal-aid": 1,
    "government-topic-families/safety-emergencies": 1,
    "government-topic-families/business-entrepreneurship": 2,
    "government-topic-families/family-parenthood": 2,
    "government-topic-families/driving-transport": 2,
    "government-topic-families/documents-certificates": 2,
    "government-topic-families/pensions-social-security": 2,
    "government-topic-families/consumer-privacy": 2,
    "government-topic-families/voting-democracy": 3,
    "government-topic-families/death-inheritance": 3,
    # Housing topic families.
    "housing-topic-families/renting": 1,
    "housing-topic-families/tenant-rights": 1,
    "housing-topic-families/utilities": 2,
    "housing-topic-families/home-buying": 3,
    # Healthcare topic families.
    "healthcare-topic-families/primary-care": 1,
    "healthcare-topic-families/health-insurance": 1,
    "healthcare-topic-families/emergency-care": 1,
    "healthcare-topic-families/hospitals-specialists": 2,
    # Transport topic families.
    "transport-topic-families/rail-travel": 1,
    "transport-topic-families/public-transport-payment": 1,
    "transport-topic-families/cycling": 2,
    "transport-topic-families/parking": 3,
    # Education topic families.
    "education-topic-families/higher-education": 1,
    "education-topic-families/duo": 1,
    "education-topic-families/civic-integration": 1,
    "education-topic-families/schools": 2,
}

PLACEHOLDER_PATTERN = re.compile(
    r"\b(?:lorem\s+ipsum|todo|tbd|fixme|placeholder|sample\s+text|fill\s+in|coming\s+soon)\b",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class RecordEnvelope:
    record: dict[str, Any]
    batch_path: Path
    batch_id: str
    work_package: str
    release_id: str
    batch_status: str


def read_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def parse_day(value: Any) -> date | None:
    if not isinstance(value, str):
        return None
    try:
        return date.fromisoformat(value)
    except ValueError:
        return None


def percent(numerator: int, denominator: int, *, cap: bool = False) -> float | None:
    if denominator <= 0:
        return None
    value = numerator * 100 / denominator
    if cap:
        value = min(value, 100.0)
    return round(value, 1)


def normalize_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value.casefold())
    normalized = "".join(character for character in normalized if not unicodedata.combining(character))
    return " ".join(re.findall(r"[a-z0-9]+", normalized))


def slug_from_id(value: str) -> str:
    tail = re.split(r"[.:]", value)[-1]
    return re.sub(r"[^a-z0-9]+", "-", tail.casefold()).strip("-")


def flatten_strings(value: Any) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for child in value.values():
            yield from flatten_strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from flatten_strings(child)


def placeholder_hits(value: Any) -> list[str]:
    hits: set[str] = set()
    for text in flatten_strings(value):
        for match in PLACEHOLDER_PATTERN.finditer(text):
            hits.add(match.group(0).casefold())
    return sorted(hits)


def load_records() -> list[RecordEnvelope]:
    records: list[RecordEnvelope] = []
    for path in sorted(BATCHES.rglob("*.json")):
        batch = read_json(path)
        for record in batch.get("records", []):
            records.append(
                RecordEnvelope(
                    record=record,
                    batch_path=path,
                    batch_id=str(batch.get("batch_id", "")),
                    work_package=str(batch.get("work_package", "")),
                    release_id=str(batch.get("target_release", "")),
                    batch_status=str(batch.get("publication_status", "")),
                )
            )
    return records


def release_catalog() -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in read_json(RELEASES_PATH).get("releases", [])}


def is_effectively_published(envelope: RecordEnvelope, releases: dict[str, dict[str, Any]]) -> bool:
    record = envelope.record
    release = releases.get(envelope.release_id, {})
    return (
        envelope.batch_status in {"qa", "published"}
        and release.get("status") == "published"
        and record.get("lifecycle_status") == "published"
        and record.get("verification_status") == "verified"
    )


@lru_cache(maxsize=1)
def freshness_policy() -> dict[str, Any]:
    return read_json(FRESHNESS_POLICY_PATH)


def effective_review_days(record: dict[str, Any], work_package: str) -> int | None:
    for rule in freshness_policy().get("rules", []):
        if work_package and work_package in rule.get("work_packages", []):
            return rule.get("review_days") if isinstance(rule.get("review_days"), int) else None
        if record.get("entity_type") in rule.get("entity_types", []):
            return rule.get("review_days") if isinstance(rule.get("review_days"), int) else None
    frequency = record.get("review_frequency_days")
    if isinstance(frequency, int):
        return frequency
    default = freshness_policy().get("default_review_days")
    return default if isinstance(default, int) else None


def is_stale(record: dict[str, Any], as_of: date, work_package: str = "") -> bool:
    checked = parse_day(record.get("last_checked"))
    frequency = effective_review_days(record, work_package)
    return checked is None or not isinstance(frequency, int) or checked + timedelta(days=frequency) < as_of


def has_official_record_source(record: dict[str, Any]) -> bool:
    source = record.get("official_source")
    return bool(
        isinstance(source, dict)
        and source.get("is_official") is True
        and source.get("status") == "verified_opened"
        and parse_day(source.get("checked_at")) is not None
        and isinstance(source.get("url"), str)
        and source["url"].startswith("https://")
    )


def verified_images(record: dict[str, Any]) -> list[dict[str, Any]]:
    images = record.get("images")
    if not isinstance(images, list):
        return []
    return [item for item in images if isinstance(item, dict) and item.get("verified") is True]


def guide_source_ids(guide: dict[str, Any]) -> set[str]:
    return {
        str(source.get("id"))
        for source in guide.get("official_sources", [])
        if isinstance(source, dict) and source.get("id")
    }


def sourced_blocks(guide: dict[str, Any]) -> Iterable[dict[str, Any]]:
    summary = guide.get("short_summary")
    if isinstance(summary, dict):
        yield summary
    for singular_key in ("who_this_is_for", "when_you_need_it"):
        block = guide.get(singular_key)
        if isinstance(block, dict):
            yield block
    jurisdiction = guide.get("jurisdiction")
    if isinstance(jurisdiction, dict):
        yield jurisdiction
    for estimate_key in ("estimated_time", "estimated_cost"):
        estimate = guide.get(estimate_key)
        if isinstance(estimate, dict):
            yield estimate
    for key in (
        "prerequisites",
        "required_documents",
        "numbered_steps",
        "warnings",
        "common_mistakes",
        "tips",
        "checklist",
        "faqs",
        "emergency_information",
        "sections",
        "contact_options",
        "next_actions",
    ):
        for item in guide.get(key, []):
            if isinstance(item, dict):
                yield item


def guide_has_complete_source_mapping(guide: dict[str, Any]) -> bool:
    known = guide_source_ids(guide)
    blocks = list(sourced_blocks(guide))
    return bool(blocks) and all(
        isinstance(block.get("source_ids"), list)
        and bool(block["source_ids"])
        and set(map(str, block["source_ids"])).issubset(known)
        for block in blocks
    )


def guide_is_fresh(
    record: dict[str, Any],
    guide: dict[str, Any],
    as_of: date,
    work_package: str,
) -> bool:
    verified = parse_day(guide.get("verified_at"))
    frequency = effective_review_days(record, work_package)
    return bool(
        verified is not None
        and isinstance(frequency, int)
        and verified <= as_of
        and verified + timedelta(days=frequency) >= as_of
    )


@lru_cache(maxsize=1)
def reviewer_registry() -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in read_json(REVIEWER_REGISTRY_PATH).get("reviewers", []) if isinstance(item, dict) and item.get("id")}


@lru_cache(maxsize=1)
def guide_evidence_registry() -> dict[str, dict[str, Any]]:
    return {item["id"]: item for item in read_json(GUIDE_EVIDENCE_REGISTRY_PATH).get("evidence", []) if isinstance(item, dict) and item.get("id")}


def production_readiness_checks(
    envelope: RecordEnvelope,
    releases: dict[str, dict[str, Any]],
    as_of: date,
) -> dict[str, bool]:
    record = envelope.record
    guide = record.get("practical_guide")
    if not isinstance(guide, dict):
        guide = {}
    official_sources = guide.get("official_sources", [])
    guide_sources_ready = bool(official_sources) and all(
        isinstance(source, dict)
        and source.get("is_official") is True
        and source.get("status") == "verified_opened"
        and parse_day(source.get("checked_at")) is not None
        and isinstance(source.get("url"), str)
        and source["url"].startswith("https://")
        for source in official_sources
    )
    reviewer = guide.get("reviewer")
    steps = guide.get("numbered_steps", [])
    faqs = guide.get("faqs", [])
    publication_gate = guide.get("publication_gate")
    gate_checks = publication_gate.get("checks", {}) if isinstance(publication_gate, dict) else {}
    expected_gate_checks = {
        "schema",
        "factual_sources",
        "links",
        "language",
        "media",
        "duplicate_content",
        "accessibility",
    }
    media = verified_images(record)
    registered_reviewer = reviewer_registry().get(reviewer.get("id")) if isinstance(reviewer, dict) else None
    evidence_ids = publication_gate.get("evidence_ids", []) if isinstance(publication_gate, dict) else []
    evidence_records = [guide_evidence_registry().get(item) for item in evidence_ids] if isinstance(evidence_ids, list) else []
    evidence_ready = bool(evidence_records) and all(
        isinstance(item, dict)
        and item.get("status") == "passed"
        and item.get("guide_id") == guide.get("id")
        and item.get("checked_at") == publication_gate.get("checked_at")
        and isinstance(item.get("artifact_path"), str)
        and (ROOT / item["artifact_path"]).is_file()
        and item.get("sha256") == hashlib.sha256((ROOT / item["artifact_path"]).read_bytes()).hexdigest()
        for item in evidence_records
    )
    return {
        "schema_v2": guide.get("schema_version") == 2,
        "effective_publication": is_effectively_published(envelope, releases),
        "published_practical_guide": guide.get("status") == "published",
        "official_parent_source": has_official_record_source(record),
        "official_guide_sources": guide_sources_ready,
        "per_fact_source_mapping": guide_has_complete_source_mapping(guide),
        "reviewer": bool(
            isinstance(reviewer, dict)
            and reviewer.get("id")
            and reviewer.get("name")
            and reviewer.get("role")
            and reviewer.get("reviewer_type")
            and parse_day(reviewer.get("reviewed_at")) is not None
            and isinstance(registered_reviewer, dict)
            and registered_reviewer.get("active") is True
            and all(registered_reviewer.get(key) == reviewer.get(key) for key in ("name", "role", "reviewer_type"))
        ),
        "verified_date": parse_day(guide.get("verified_at")) is not None,
        "fresh": not is_stale(record, as_of, envelope.work_package)
        and guide_is_fresh(record, guide, as_of, envelope.work_package),
        "image": bool(media),
        "image_alt": bool(media) and all(isinstance(item.get("alt"), str) and len(item["alt"].strip()) >= 2 for item in media),
        "who_and_when": isinstance(guide.get("who_this_is_for"), dict)
        and isinstance(guide.get("when_you_need_it"), dict),
        "numbered_steps": bool(steps),
        "tips": bool(guide.get("tips")),
        "checklist": bool(guide.get("checklist")),
        "faq": isinstance(faqs, list) and len(faqs) >= 3,
        "emergency_information": isinstance(guide.get("emergency_information"), list),
        "reading_time": isinstance(guide.get("reading_time_minutes"), int)
        and 1 <= guide["reading_time_minutes"] <= 120,
        "difficulty": guide.get("difficulty") in {"basic", "intermediate", "advanced"},
        "confidence": guide.get("confidence_level") == "high",
        "tags": isinstance(guide.get("tags"), list) and len(guide["tags"]) >= 2,
        "publication_gate": bool(
            isinstance(publication_gate, dict)
            and publication_gate.get("status") == "passed"
            and parse_day(publication_gate.get("checked_at")) is not None
            and expected_gate_checks.issubset(gate_checks)
            and all(gate_checks.get(key) is True for key in expected_gate_checks)
            and isinstance(publication_gate.get("notes"), str)
            and len(publication_gate["notes"].strip()) >= 10
            and evidence_ready
        ),
        "no_placeholders": not placeholder_hits(
            {
                "title": record.get("title"),
                "description": record.get("description"),
                "ai_summary": record.get("ai_summary"),
                "practical_guide": guide,
            }
        ),
    }


def is_production_ready(
    envelope: RecordEnvelope,
    releases: dict[str, dict[str, Any]],
    as_of: date,
) -> bool:
    return all(production_readiness_checks(envelope, releases, as_of).values())


def duplicate_report(values: list[tuple[str, str]], *, near_threshold: float, minimum_length: int) -> dict[str, Any]:
    exact_groups: dict[str, list[str]] = defaultdict(list)
    for item_id, value in values:
        normalized = normalize_text(value)
        if normalized:
            exact_groups[normalized].append(item_id)
    exact = [
        {"normalized": normalized, "ids": sorted(ids)}
        for normalized, ids in sorted(exact_groups.items())
        if len(ids) > 1
    ]

    near: list[dict[str, Any]] = []
    normalized_values = [(item_id, normalize_text(value), value) for item_id, value in values]
    for index, (left_id, left, left_original) in enumerate(normalized_values):
        if len(left) < minimum_length:
            continue
        for right_id, right, right_original in normalized_values[index + 1 :]:
            if left == right or len(right) < minimum_length:
                continue
            ratio = SequenceMatcher(None, left, right).ratio()
            left_tokens = set(left.split())
            right_tokens = set(right.split())
            union = left_tokens | right_tokens
            jaccard = len(left_tokens & right_tokens) / len(union) if union else 0.0
            if ratio >= near_threshold and jaccard >= 0.75:
                near.append(
                    {
                        "left_id": left_id,
                        "left": left_original,
                        "right_id": right_id,
                        "right": right_original,
                        "sequence_ratio": round(ratio, 3),
                        "token_jaccard": round(jaccard, 3),
                    }
                )
    return {"exact_groups": exact, "near_pairs": near}


def practical_drafts() -> list[dict[str, Any]]:
    if not STAGING_GUIDES_PATH.exists():
        return []
    staging = read_json(STAGING_GUIDES_PATH)
    return [item for item in staging.get("guides", []) if isinstance(item, dict)]


def build_family_matrix(
    records: list[RecordEnvelope],
    drafts: list[dict[str, Any]],
    releases: dict[str, dict[str, Any]],
    dimensions: dict[str, Any],
    as_of: date,
) -> list[dict[str, Any]]:
    source_to_drafts: dict[str, set[str]] = defaultdict(set)
    for item in drafts:
        guide = item.get("practical_guide", {})
        guide_id = str(guide.get("id", ""))
        for source_id in item.get("source_entity_ids", []):
            source_to_drafts[str(source_id)].add(guide_id)

    matrix: list[dict[str, Any]] = []
    for axis in dimensions.get("axes", []):
        target_key = axis.get("target_key")
        if target_key not in CONTENT_TARGET_KEYS:
            continue
        field = str(axis.get("field", "category"))
        minimum = int(axis.get("minimum_records_per_value", 1))
        work_package = str(axis.get("work_package", ""))
        for family in axis.get("required_values", []):
            match_values = set(map(str, family.get("match_values", [])))
            matched = [
                envelope
                for envelope in records
                if envelope.work_package == work_package and str(envelope.record.get(field)) in match_values
            ]
            ready = [envelope for envelope in matched if is_production_ready(envelope, releases, as_of)]
            published = [envelope for envelope in matched if is_effectively_published(envelope, releases)]
            full = [
                envelope
                for envelope in matched
                if isinstance(envelope.record.get("practical_guide"), dict)
                and envelope.record["practical_guide"].get("status") == "published"
            ]
            associated_drafts = sorted(
                {
                    draft_id
                    for envelope in matched
                    for draft_id in source_to_drafts.get(str(envelope.record.get("id")), set())
                    if draft_id
                }
            )
            family_id = f"{axis['key']}/{family['key']}"
            matrix.append(
                {
                    "family_id": family_id,
                    "axis": axis["key"],
                    "target_key": target_key,
                    "work_package": work_package,
                    "family_key": family["key"],
                    "label": family["label"],
                    "match_values": sorted(match_values),
                    "priority_proposal": PRIORITY_BY_FAMILY.get(family_id),
                    "coverage_denominator_minimum_records": minimum,
                    "material_records": len(matched),
                    "coverage_numerator_capped": min(len(matched), minimum),
                    "coverage_percent_capped": percent(len(matched), minimum, cap=True),
                    "effective_published_records": len(published),
                    "summary_records": sum(
                        not (
                            isinstance(envelope.record.get("practical_guide"), dict)
                            and envelope.record["practical_guide"].get("status") == "published"
                        )
                        for envelope in matched
                    ),
                    "full_practical_guides": len(full),
                    "production_ready_guides": len(ready),
                    "production_ready_numerator_capped": min(len(ready), minimum),
                    "production_ready_percent_capped": percent(len(ready), minimum, cap=True),
                    "associated_draft_guide_count": len(associated_drafts),
                    "associated_draft_guide_ids": associated_drafts,
                    "empty": len(matched) == 0,
                    "stale_records": sum(is_stale(envelope.record, as_of, envelope.work_package) for envelope in matched),
                    "records_without_official_source": sum(not has_official_record_source(envelope.record) for envelope in matched),
                    "records_without_images": sum(not verified_images(envelope.record) for envelope in matched),
                    "record_ids": sorted(str(envelope.record.get("id")) for envelope in matched),
                }
            )
    return matrix


def build_priority_matrix(family_matrix: list[dict[str, Any]]) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for priority in (1, 2, 3):
        families = [item for item in family_matrix if item.get("priority_proposal") == priority]
        family_denominator = len(families)
        covered_families = sum(
            item["material_records"] >= item["coverage_denominator_minimum_records"] for item in families
        )
        slot_denominator = sum(item["coverage_denominator_minimum_records"] for item in families)
        covered_slots = sum(item["coverage_numerator_capped"] for item in families)
        ready_slots = sum(item["production_ready_numerator_capped"] for item in families)
        result.append(
            {
                "priority": priority,
                "classification_status": "editorial proposal; not canonical metadata",
                "family_denominator": family_denominator,
                "covered_family_numerator": covered_families,
                "family_coverage_percent": percent(covered_families, family_denominator),
                "material_slot_denominator": slot_denominator,
                "covered_material_slot_numerator_capped": covered_slots,
                "material_slot_coverage_percent_capped": percent(covered_slots, slot_denominator),
                "production_ready_slot_numerator_capped": ready_slots,
                "production_ready_percent_capped": percent(ready_slots, slot_denominator),
                "effective_published_records": sum(item["effective_published_records"] for item in families),
                "full_practical_guides": sum(item["full_practical_guides"] for item in families),
                "associated_draft_guides_sum_with_cross_family_overlap": sum(
                    item["associated_draft_guide_count"] for item in families
                ),
                "family_ids": [item["family_id"] for item in families],
            }
        )
    return result


def build_target_matrix(
    records: list[RecordEnvelope],
    releases: dict[str, dict[str, Any]],
    targets: dict[str, Any],
    as_of: date,
) -> list[dict[str, Any]]:
    matrix: list[dict[str, Any]] = []
    for target in targets.get("targets", []):
        if target.get("key") not in CONTENT_TARGET_KEYS:
            continue
        work_package = str(target["work_package"])
        denominator = int(target["target"])
        matched = [envelope for envelope in records if envelope.work_package == work_package]
        published = [envelope for envelope in matched if is_effectively_published(envelope, releases)]
        ready = [envelope for envelope in matched if is_production_ready(envelope, releases, as_of)]
        matrix.append(
            {
                "target_key": target["key"],
                "label": target["label"],
                "work_package": work_package,
                "coverage_denominator_target_records": denominator,
                "material_records": len(matched),
                "coverage_numerator_capped": min(len(matched), denominator),
                "coverage_percent_capped": percent(len(matched), denominator, cap=True),
                "effective_published_records": len(published),
                "public_release_percent": percent(len(published), denominator, cap=True),
                "production_ready_guides": len(ready),
                "production_ready_percent_capped": percent(len(ready), denominator, cap=True),
            }
        )
    return matrix


def build_observed_category_matrix(
    materials: list[RecordEnvelope],
    releases: dict[str, dict[str, Any]],
    as_of: date,
) -> list[dict[str, Any]]:
    grouped: dict[tuple[str, str], list[RecordEnvelope]] = defaultdict(list)
    for envelope in materials:
        grouped[(envelope.work_package, str(envelope.record.get("category", "")))].append(envelope)
    matrix: list[dict[str, Any]] = []
    for (work_package, category), matched in sorted(grouped.items()):
        base_complete = sum(
            bool(envelope.record.get("title"))
            and bool(envelope.record.get("description"))
            and bool(envelope.record.get("ai_summary"))
            and has_official_record_source(envelope.record)
            and parse_day(envelope.record.get("last_checked")) is not None
            and not is_stale(envelope.record, as_of, envelope.work_package)
            and not placeholder_hits(
                {
                    "title": envelope.record.get("title"),
                    "description": envelope.record.get("description"),
                    "ai_summary": envelope.record.get("ai_summary"),
                }
            )
            for envelope in matched
        )
        ready = sum(is_production_ready(envelope, releases, as_of) for envelope in matched)
        matrix.append(
            {
                "work_package": work_package,
                "category": category,
                "observed_material_denominator": len(matched),
                "base_complete_summary_numerator": base_complete,
                "base_summary_completeness_percent": percent(base_complete, len(matched)),
                "effective_published": sum(is_effectively_published(envelope, releases) for envelope in matched),
                "production_ready_guide_numerator": ready,
                "production_ready_within_observed_percent": percent(ready, len(matched)),
                "stale": sum(is_stale(envelope.record, as_of, envelope.work_package) for envelope in matched),
                "without_official_source": sum(not has_official_record_source(envelope.record) for envelope in matched),
                "without_images": sum(not verified_images(envelope.record) for envelope in matched),
                "without_published_steps": sum(
                    not (
                        isinstance(envelope.record.get("practical_guide"), dict)
                        and bool(envelope.record["practical_guide"].get("numbered_steps"))
                    )
                    for envelope in matched
                ),
                "without_published_faq": sum(
                    not (
                        isinstance(envelope.record.get("practical_guide"), dict)
                        and bool(envelope.record["practical_guide"].get("faqs"))
                    )
                    for envelope in matched
                ),
            }
        )
    return matrix


def build_report(as_of: date) -> dict[str, Any]:
    records = load_records()
    releases = release_catalog()
    targets = read_json(TARGETS_PATH)
    dimensions = read_json(DIMENSIONS_PATH)
    drafts = practical_drafts()
    runtime = read_json(RUNTIME_PATH)
    public_content = read_json(PUBLIC_CONTENT_PATH)
    data_health = read_json(DATA_HEALTH_PATH) if DATA_HEALTH_PATH.exists() else {}

    materials = [envelope for envelope in records if envelope.record.get("entity_type") in GUIDE_ENTITY_TYPES]
    effective = [envelope for envelope in records if is_effectively_published(envelope, releases)]
    effective_materials = [envelope for envelope in materials if is_effectively_published(envelope, releases)]
    full_inventory = [
        envelope
        for envelope in materials
        if isinstance(envelope.record.get("practical_guide"), dict)
        and envelope.record["practical_guide"].get("status") == "published"
    ]
    ready = [envelope for envelope in materials if is_production_ready(envelope, releases, as_of)]

    staged_guides = [item.get("practical_guide", {}) for item in drafts]
    staged_draft_guides = [guide for guide in staged_guides if guide.get("status") in {"draft", "qa", "review"}]
    staged_faq_count = sum(len(guide.get("faqs", [])) for guide in staged_draft_guides)
    staged_search_question_count = sum(len(guide.get("common_questions", [])) for guide in staged_draft_guides)

    runtime_entities = runtime.get("entities", [])
    public_entities = public_content.get("entities", [])
    runtime_ids = [str(item.get("id")) for item in runtime_entities]
    public_ids = [str(item.get("id")) for item in public_entities]
    effective_ids = [str(envelope.record.get("id")) for envelope in effective]
    public_guides = [item for item in public_entities if item.get("type") == "guide"]
    public_full_guides = [item for item in public_guides if item.get("contentDepth") == "practical"]
    public_summary_guides = [item for item in public_guides if item.get("contentDepth") == "summary"]

    family_matrix = build_family_matrix(records, drafts, releases, dimensions, as_of)
    priority_matrix = build_priority_matrix(family_matrix)
    target_matrix = build_target_matrix(records, releases, targets, as_of)
    observed_matrix = build_observed_category_matrix(materials, releases, as_of)
    target_denominator = sum(item["coverage_denominator_target_records"] for item in target_matrix)
    target_covered = sum(item["coverage_numerator_capped"] for item in target_matrix)
    target_ready = sum(item["production_ready_guides"] for item in target_matrix)

    id_values = [(str(envelope.record.get("id")), str(envelope.record.get("id"))) for envelope in records]
    title_values = [(str(envelope.record.get("id")), str(envelope.record.get("title", ""))) for envelope in records]
    guide_id_values = [(str(guide.get("id")), str(guide.get("id"))) for guide in staged_guides]
    guide_title_values = [(str(guide.get("id")), str(guide.get("title", ""))) for guide in staged_guides]
    guide_slug_values = [(str(guide.get("id")), str(guide.get("slug", ""))) for guide in staged_guides]

    material_check_failures = Counter()
    for envelope in materials:
        for check, passed in production_readiness_checks(envelope, releases, as_of).items():
            if not passed:
                material_check_failures[check] += 1

    placeholder_records = []
    for envelope in records:
        hits = placeholder_hits(
            {
                "title": envelope.record.get("title"),
                "description": envelope.record.get("description"),
                "ai_summary": envelope.record.get("ai_summary"),
                "practical_guide": envelope.record.get("practical_guide"),
            }
        )
        if hits:
            placeholder_records.append({"id": envelope.record.get("id"), "hits": hits})
    placeholder_drafts = []
    for guide in staged_guides:
        hits = placeholder_hits(guide)
        if hits:
            placeholder_drafts.append({"id": guide.get("id"), "hits": hits})

    family_ids = {item["family_id"] for item in family_matrix}
    unclassified_family_ids = sorted(
        item["family_id"] for item in family_matrix if item.get("priority_proposal") not in {1, 2, 3}
    )
    unused_priority_family_ids = sorted(set(PRIORITY_BY_FAMILY) - family_ids)

    draft_source_ids = {
        str(source_id)
        for item in drafts
        for source_id in item.get("source_entity_ids", [])
        if source_id
    }
    canonical_ids = {str(envelope.record.get("id")) for envelope in records}
    missing_draft_sources = sorted(draft_source_ids - canonical_ids)
    stale_records = [envelope for envelope in records if is_stale(envelope.record, as_of, envelope.work_package)]

    schema = read_json(ENTITY_SCHEMA_PATH)
    supported_audience_profiles = set(
        schema.get("$defs", {})
        .get("practicalGuide", {})
        .get("properties", {})
        .get("audience_profiles", {})
        .get("items", {})
        .get("enum", [])
    )
    profile_coverage: dict[str, Any] = {}
    for profile in USER_PATHS:
        # Only practical guides carry explicit audience metadata.
        published_count = sum(
            profile in (envelope.record.get("practical_guide") or {}).get("audience_profiles", [])
            and is_production_ready(envelope, releases, as_of)
            for envelope in materials
        )
        draft_count = sum(profile in guide.get("audience_profiles", []) for guide in staged_draft_guides)
        profile_coverage[profile] = {
            "production_ready_guides": published_count,
            "draft_guides_with_explicit_profile": draft_count,
            "supported_by_current_schema": profile in supported_audience_profiles,
        }

    report: dict[str, Any] = {
        "schema_version": 1,
        "as_of": as_of.isoformat(),
        "scope": {
            "governed_batches": str(BATCHES.relative_to(ROOT)),
            "canonical_runtime": str(RUNTIME_PATH.relative_to(ROOT)),
            "public_content": str(PUBLIC_CONTENT_PATH.relative_to(ROOT)),
            "staging_guides": str(STAGING_GUIDES_PATH.relative_to(ROOT)),
            "entity_schema": str(ENTITY_SCHEMA_PATH.relative_to(ROOT)),
            "freshness_policy": str(FRESHNESS_POLICY_PATH.relative_to(ROOT)),
            "existing_link_health_report": str(DATA_HEALTH_PATH.relative_to(ROOT)),
            "guide_entity_types": sorted(GUIDE_ENTITY_TYPES),
            "network_check_performed": False,
            "network_note": "URL syntax/status metadata are audited; live reachability is owned by the existing data-health link checker.",
        },
        "definitions": {
            "material_record": "A governed entity whose runtime kind is mapped by the public generator to a guide: government_service, housing, document or knowledge_topic.",
            "summary_record": "A material record without an attached published practical_guide; public/effective publication is reported separately.",
            "full_practical_guide": "A material record with practical_guide.status == published; effective public release is reported separately.",
            "coverage_percent": "Inventory count divided by a repository-owned target/minimum denominator and capped at 100%; surplus does not offset another empty family.",
            "production_ready": "Every fail-closed check is true: effective publication; published practical guide; official parent/guide sources and per-fact source mapping; complete human reviewer and verified date; policy freshness; verified image with alt; who/when, steps, tips, checklist, at least 3 FAQs, emergency information; reading time, difficulty, high confidence, tags; passed publication gate; and no placeholders.",
            "stale": "last_checked plus the matching DataProject freshness-policy SLA is earlier than as_of; guide freshness additionally applies that SLA to verified_at.",
            "near_duplicate": "Non-exact normalized strings with SequenceMatcher ratio >= 0.92 (0.96 for IDs/slugs) and token Jaccard >= 0.75.",
            "priority": "A report-only editorial proposal over existing coverage-dimensions topic-family keys, based on the attached brief; not canonical metadata.",
        },
        "headline": {
            "governed_records": len(records),
            "governed_lifecycle_status_counts": dict(sorted(Counter(envelope.record.get("lifecycle_status") for envelope in records).items())),
            "effective_published_records": len(effective),
            "material_records": len(materials),
            "material_lifecycle_status_counts": dict(sorted(Counter(envelope.record.get("lifecycle_status") for envelope in materials).items())),
            "effective_published_material_records": len(effective_materials),
            "summary_material_records_inventory": len(materials) - len(full_inventory),
            "public_summary_guides": len(public_summary_guides),
            "full_practical_guides_inventory": len(full_inventory),
            "public_full_practical_guides": len(public_full_guides),
            "production_ready_guides": len(ready),
            "staged_draft_or_review_guides": len(staged_draft_guides),
            "published_faq_items": sum(
                len((envelope.record.get("practical_guide") or {}).get("faqs", []))
                for envelope in ready
            ),
            "staged_draft_faq_items": staged_faq_count,
            "staged_search_question_items": staged_search_question_count,
            "governed_related_entity_links": sum(len(envelope.record.get("related_entity_ids", [])) for envelope in records),
            "material_related_entity_links": sum(len(envelope.record.get("related_entity_ids", [])) for envelope in materials),
            "stale_governed_records": sum(
                is_stale(envelope.record, as_of, envelope.work_package) for envelope in records
            ),
            "stale_material_records": sum(
                is_stale(envelope.record, as_of, envelope.work_package) for envelope in materials
            ),
            "empty_governed_topic_families": sum(item["empty"] for item in family_matrix),
            "governed_topic_families_without_effective_publication": sum(
                item["effective_published_records"] == 0 for item in family_matrix
            ),
            "repository_content_target_denominator": target_denominator,
            "repository_content_target_covered_numerator_capped": target_covered,
            "repository_content_target_coverage_percent_capped": percent(target_covered, target_denominator),
            "repository_content_target_production_ready_numerator": target_ready,
            "repository_content_target_production_ready_percent": percent(target_ready, target_denominator),
            "production_readiness_percent_of_100_guide_brief_target": percent(len(ready), 100, cap=True),
            "published_faq_percent_of_300_brief_target": percent(
                sum(len((envelope.record.get("practical_guide") or {}).get("faqs", [])) for envelope in ready),
                300,
                cap=True,
            ),
        },
        "target_matrix": target_matrix,
        "governed_topic_family_matrix": family_matrix,
        "priority_matrix": priority_matrix,
        "priority_classification_validation": {
            "family_denominator": len(family_matrix),
            "classified_family_numerator": len(family_matrix) - len(unclassified_family_ids),
            "unclassified_family_ids": unclassified_family_ids,
            "unused_mapping_family_ids": unused_priority_family_ids,
        },
        "observed_material_category_matrix": observed_matrix,
        "quality_gaps": {
            "material_readiness_check_failure_counts": dict(sorted(material_check_failures.items())),
            "material_records_without_official_parent_source": sum(
                not has_official_record_source(envelope.record) for envelope in materials
            ),
            "material_records_without_verified_images": sum(not verified_images(envelope.record) for envelope in materials),
            "material_records_without_published_steps": sum(
                not (
                    isinstance(envelope.record.get("practical_guide"), dict)
                    and bool(envelope.record["practical_guide"].get("numbered_steps"))
                )
                for envelope in materials
            ),
            "material_records_without_published_faq": sum(
                not (
                    isinstance(envelope.record.get("practical_guide"), dict)
                    and bool(envelope.record["practical_guide"].get("faqs"))
                )
                for envelope in materials
            ),
            "staged_guides_without_reviewer": sum(not guide.get("reviewer") for guide in staged_draft_guides),
            "staged_guides_without_verified_at": sum(not guide.get("verified_at") for guide in staged_draft_guides),
            "staged_guides_without_official_sources": sum(not guide.get("official_sources") for guide in staged_draft_guides),
            "staged_guides_without_numbered_steps": sum(not guide.get("numbered_steps") for guide in staged_draft_guides),
            "staged_guides_without_faq": sum(not guide.get("faqs") for guide in staged_draft_guides),
            "staged_guides_without_source_entity_ids": [
                guide.get("id")
                for item, guide in zip(drafts, staged_guides)
                if not item.get("source_entity_ids")
            ],
            "staged_guides_without_images": len(staged_draft_guides),
            "staged_image_note": "The staging guide envelope has no media field; eventual guide media must come from an attached canonical entity.",
            "scenario_note": "The canonical guide schema has no separate scenario field. numbered_steps is used as the auditable procedural/scenario proxy; no published material has numbered steps.",
            "placeholder_records": placeholder_records,
            "placeholder_staged_guides": placeholder_drafts,
            "missing_staged_source_entity_ids": missing_draft_sources,
            "stale_governed_records": [
                {
                    "id": envelope.record.get("id"),
                    "entity_type": envelope.record.get("entity_type"),
                    "category": envelope.record.get("category"),
                    "work_package": envelope.work_package,
                    "last_checked": envelope.record.get("last_checked"),
                    "freshness_sla_days": effective_review_days(envelope.record, envelope.work_package),
                }
                for envelope in stale_records
            ],
        },
        "duplicates": {
            "canonical_ids": duplicate_report(id_values, near_threshold=0.96, minimum_length=10),
            "canonical_titles": duplicate_report(title_values, near_threshold=0.92, minimum_length=8),
            "staged_guide_ids": duplicate_report(guide_id_values, near_threshold=0.96, minimum_length=10),
            "staged_guide_titles": duplicate_report(guide_title_values, near_threshold=0.92, minimum_length=8),
            "staged_guide_slugs": duplicate_report(guide_slug_values, near_threshold=0.96, minimum_length=8),
            "note": "Runtime/public mirrors are reconciled below and are not counted as source-of-truth duplicates.",
        },
        "runtime_reconciliation": {
            "effective_published_denominator": len(set(effective_ids)),
            "runtime_entity_count": len(runtime_ids),
            "public_entity_count": len(public_ids),
            "duplicate_runtime_ids": sorted(item for item, count in Counter(runtime_ids).items() if count > 1),
            "duplicate_public_ids": sorted(item for item, count in Counter(public_ids).items() if count > 1),
            "effective_missing_from_runtime": sorted(set(effective_ids) - set(runtime_ids)),
            "runtime_not_effectively_published": sorted(set(runtime_ids) - set(effective_ids)),
            "runtime_missing_from_public": sorted(set(runtime_ids) - set(public_ids)),
            "public_not_in_runtime": sorted(set(public_ids) - set(runtime_ids)),
            "runtime_has_practical_guide": sum(isinstance(item.get("practicalGuide"), dict) for item in runtime_entities),
            "public_has_practical_guide": len(public_full_guides),
        },
        "existing_link_health_evidence": {
            "generated_at": data_health.get("generated_at"),
            "checked_at": data_health.get("link_check", {}).get("checked_at"),
            "total": data_health.get("link_check", {}).get("total"),
            "reachable": data_health.get("link_check", {}).get("reachable"),
            "confirmed_broken": data_health.get("link_check", {}).get("confirmed_broken"),
            "access_restricted": data_health.get("link_check", {}).get("access_restricted"),
            "transient_failures": data_health.get("link_check", {}).get("transient_failures"),
            "audit_note": "Imported as historical evidence only; this content-readiness script did not re-open URLs.",
        },
        "user_path_coverage": {
            "denominator_paths_from_brief": len(USER_PATHS),
            "paths_with_at_least_one_production_ready_guide": sum(
                value["production_ready_guides"] > 0 for value in profile_coverage.values()
            ),
            "coverage_percent": percent(
                sum(value["production_ready_guides"] > 0 for value in profile_coverage.values()),
                len(USER_PATHS),
            ),
            "profiles": profile_coverage,
            "taxonomy_gap": (
                "All six brief paths are supported by the current audience_profiles enum, but no published practical guide carries audience metadata."
                if set(USER_PATHS).issubset(supported_audience_profiles)
                else "Some brief paths are not supported by the current audience_profiles enum."
            ),
        },
        "findings": [
            {
                "severity": "critical",
                "confidence": "high",
                "finding": "No production-ready practical guide exists.",
                "evidence": f"0/{len(materials)} governed material records and 0/100 of the brief target pass all fail-closed checks.",
                "impact": "Summary inventory cannot satisfy the requested source-per-step, reviewer, FAQ, UX or full-guide publication contract.",
            },
            {
                "severity": "high",
                "confidence": "high",
                "finding": "QA inventory coverage and public content availability are materially different.",
                "evidence": f"{len(materials)} guide-capable records exist in DataProject, but only {len(public_summary_guides)} summary guides and {len(public_full_guides)} full guides are public.",
                "impact": "Reporting inventory coverage as public readiness would overstate user-visible content.",
            },
            {
                "severity": "high",
                "confidence": "high",
                "finding": "Draft scaffolds remain intentionally fail-closed.",
                "evidence": f"{len(staged_draft_guides)}/{len(staged_draft_guides)} lack reviewer, verified_at, official_sources and numbered_steps.",
                "impact": "They are appropriate research queues, not publishable instructions.",
            },
            {
                "severity": "medium",
                "confidence": "high",
                "finding": "The requested end-to-end audience paths are not measurable as production content.",
                "evidence": f"0/{len(USER_PATHS)} brief paths have a production-ready guide; all audience counts are zero.",
                "impact": "The project cannot yet prove Tourist → Student → Expat → Refugee → Worker → Resident coverage.",
            },
        ],
    }
    reconciliation = report["runtime_reconciliation"]
    audit_integrity_failures: list[str] = []
    if report["duplicates"]["canonical_ids"]["exact_groups"]:
        audit_integrity_failures.append("duplicate canonical IDs")
    if unclassified_family_ids or unused_priority_family_ids:
        audit_integrity_failures.append("priority mapping does not exactly cover governed topic families")
    if any(item["coverage_denominator_target_records"] <= 0 for item in target_matrix):
        audit_integrity_failures.append("non-positive repository target denominator")
    for key in (
        "effective_missing_from_runtime",
        "runtime_not_effectively_published",
        "runtime_missing_from_public",
        "public_not_in_runtime",
        "duplicate_runtime_ids",
        "duplicate_public_ids",
    ):
        if reconciliation[key]:
            audit_integrity_failures.append(f"runtime reconciliation: {key}")
    report["audit_integrity"] = {
        "status": "passed" if not audit_integrity_failures else "failed",
        "failures": audit_integrity_failures,
        "note": "Integrity checks validate the audit grain and mirrors; content-readiness gaps intentionally do not make this script fail.",
    }
    return report


def markdown_table(headers: list[str], rows: list[list[Any]]) -> str:
    def cell(value: Any) -> str:
        if value is None:
            return "—"
        return str(value).replace("|", "\\|").replace("\n", " ")

    lines = ["| " + " | ".join(map(cell, headers)) + " |", "| " + " | ".join("---" for _ in headers) + " |"]
    lines.extend("| " + " | ".join(cell(value) for value in row) + " |" for row in rows)
    return "\n".join(lines)


def render_markdown(report: dict[str, Any]) -> str:
    headline = report["headline"]
    target_rows = [
        [
            item["target_key"],
            item["material_records"],
            item["coverage_denominator_target_records"],
            f"{item['coverage_percent_capped']}%",
            item["effective_published_records"],
            item["production_ready_guides"],
            f"{item['production_ready_percent_capped']}%",
        ]
        for item in report["target_matrix"]
    ]
    family_rows = [
        [
            item["priority_proposal"],
            item["target_key"],
            item["family_key"],
            item["material_records"],
            item["coverage_denominator_minimum_records"],
            f"{item['coverage_percent_capped']}%",
            item["effective_published_records"],
            item["full_practical_guides"],
            item["production_ready_guides"],
            f"{item['production_ready_percent_capped']}%",
            item["associated_draft_guide_count"],
        ]
        for item in report["governed_topic_family_matrix"]
    ]
    priority_rows = [
        [
            f"P{item['priority']}",
            f"{item['covered_family_numerator']}/{item['family_denominator']}",
            f"{item['family_coverage_percent']}%",
            f"{item['covered_material_slot_numerator_capped']}/{item['material_slot_denominator']}",
            f"{item['material_slot_coverage_percent_capped']}%",
            f"{item['production_ready_slot_numerator_capped']}/{item['material_slot_denominator']}",
            f"{item['production_ready_percent_capped']}%",
        ]
        for item in report["priority_matrix"]
    ]
    category_rows = [
        [
            item["work_package"],
            item["category"],
            item["observed_material_denominator"],
            f"{item['base_complete_summary_numerator']}/{item['observed_material_denominator']}",
            f"{item['base_summary_completeness_percent']}%",
            item["effective_published"],
            item["production_ready_guide_numerator"],
            item["without_images"],
            item["without_published_steps"],
            item["without_published_faq"],
        ]
        for item in report["observed_material_category_matrix"]
    ]

    duplicate_counts = report["duplicates"]
    lines = [
        "# YouNew content readiness matrix",
        "",
        f"Evidence date: **{report['as_of']}**. This is a read-only local audit; no live URL check was performed.",
        "",
        "## Outcome",
        "",
        "**NOT PRODUCTION READY for the attached 100%-content brief.** The repository has substantial governed summary inventory, but no practical guide passes the fail-closed production contract.",
        "",
        f"- Governed records: **{headline['governed_records']}**; effectively published: **{headline['effective_published_records']}**.",
        f"- Guide-capable material records: **{headline['material_records']}**; effectively published material records: **{headline['effective_published_material_records']}**.",
        f"- Material lifecycle states: **{json.dumps(headline['material_lifecycle_status_counts'], sort_keys=True)}**.",
        f"- Public guides: **{headline['public_summary_guides']} summary / {headline['public_full_practical_guides']} full**.",
        f"- Editorial scaffolds: **{headline['staged_draft_or_review_guides']} draft/review**; production-ready guides: **{headline['production_ready_guides']}**.",
        f"- Published FAQ: **{headline['published_faq_items']}/300**; staged draft FAQ: **{headline['staged_draft_faq_items']}**; staged search questions (not FAQ): **{headline['staged_search_question_items']}**.",
        f"- Governed topic families with zero inventory records: **{headline['empty_governed_topic_families']}**.",
        f"- Governed topic families with zero effective published records: **{headline['governed_topic_families_without_effective_publication']}/{len(report['governed_topic_family_matrix'])}**.",
        f"- Repository content-target coverage: **{headline['repository_content_target_covered_numerator_capped']}/{headline['repository_content_target_denominator']} ({headline['repository_content_target_coverage_percent_capped']}%)**; production-ready: **{headline['repository_content_target_production_ready_numerator']}/{headline['repository_content_target_denominator']} ({headline['repository_content_target_production_ready_percent']}%)**.",
        f"- Stale governed records: **{headline['stale_governed_records']}**; stale guide-capable records: **{headline['stale_material_records']}**.",
        f"- Audit integrity/reconciliation: **{report['audit_integrity']['status'].upper()}**.",
        "",
        "## Denominators and interpretation",
        "",
        "Coverage is not an invented score. Target-level coverage uses `DataProject/coverage-targets.json`; topic-family coverage uses the minimum-per-family values in `DataProject/coverage-dimensions.json`. Percentages are capped at 100%, so surplus in one family cannot hide an empty family. Production readiness uses the stricter brief contract listed in the JSON `definitions.production_ready` field.",
        "",
        "## Repository target coverage",
        "",
        markdown_table(
            ["Target", "Materials", "Target denominator", "Coverage", "Published", "Ready full guides", "Production ready"],
            target_rows,
        ),
        "",
        "## Proposed priority coverage",
        "",
        "P1/P2/P3 is a report-only editorial proposal over existing topic-family keys. The brief supplies examples but no canonical priority field, so this audit does not write the classification into content.",
        "",
        markdown_table(
            ["Priority", "Covered families", "Family coverage", "Covered slots", "Slot coverage", "Ready slots", "Production ready"],
            priority_rows,
        ),
        "",
        "## Governed topic-family matrix",
        "",
        markdown_table(
            ["P", "Target", "Family", "Materials", "Minimum", "Coverage", "Published", "Full", "Ready", "Ready %", "Draft associations"],
            family_rows,
        ),
        "",
        "## Observed canonical material categories",
        "",
        "This table uses the observed category count as the denominator for summary-field completeness; it does not claim that the observed count is the desired topic coverage target.",
        "",
        markdown_table(
            ["WP", "Category", "Denominator", "Base complete", "Completeness", "Published", "Ready", "No image", "No steps", "No FAQ"],
            category_rows,
        ),
        "",
        "## Quality gaps",
        "",
        f"- Material records without an official parent source: **{report['quality_gaps']['material_records_without_official_parent_source']}/{headline['material_records']}**.",
        f"- Material records without a verified image: **{report['quality_gaps']['material_records_without_verified_images']}/{headline['material_records']}**.",
        f"- Material records without published steps: **{report['quality_gaps']['material_records_without_published_steps']}/{headline['material_records']}**.",
        f"- Material records without published FAQ: **{report['quality_gaps']['material_records_without_published_faq']}/{headline['material_records']}**.",
        f"- Staged guides without reviewer, verified date, official guide sources, steps and FAQ: **{report['quality_gaps']['staged_guides_without_reviewer']}/{headline['staged_draft_or_review_guides']}**, **{report['quality_gaps']['staged_guides_without_verified_at']}/{headline['staged_draft_or_review_guides']}**, **{report['quality_gaps']['staged_guides_without_official_sources']}/{headline['staged_draft_or_review_guides']}**, **{report['quality_gaps']['staged_guides_without_numbered_steps']}/{headline['staged_draft_or_review_guides']}**, **{report['quality_gaps']['staged_guides_without_faq']}/{headline['staged_draft_or_review_guides']}**.",
        f"- Staged guides with no canonical source entity IDs: **{len(report['quality_gaps']['staged_guides_without_source_entity_ids'])}** ({', '.join(report['quality_gaps']['staged_guides_without_source_entity_ids']) or 'none'}).",
        f"- Conservative placeholder hits: canonical **{len(report['quality_gaps']['placeholder_records'])}**, staged guides **{len(report['quality_gaps']['placeholder_staged_guides'])}**.",
        f"- Missing canonical source IDs referenced by scaffolds: **{len(report['quality_gaps']['missing_staged_source_entity_ids'])}** ({', '.join(report['quality_gaps']['missing_staged_source_entity_ids']) or 'none'}).",
        f"- Stale governed records under `freshness-policy.json`: **{len(report['quality_gaps']['stale_governed_records'])}** ({', '.join(item['id'] for item in report['quality_gaps']['stale_governed_records']) or 'none'}).",
        f"- Scenario interpretation: {report['quality_gaps']['scenario_note']}",
        "",
        "## Duplicates",
        "",
        f"- Canonical ID exact groups / near pairs: **{len(duplicate_counts['canonical_ids']['exact_groups'])} / {len(duplicate_counts['canonical_ids']['near_pairs'])}**.",
        f"- Canonical title exact groups / near pairs: **{len(duplicate_counts['canonical_titles']['exact_groups'])} / {len(duplicate_counts['canonical_titles']['near_pairs'])}**.",
        f"- Staged guide ID exact groups / near pairs: **{len(duplicate_counts['staged_guide_ids']['exact_groups'])} / {len(duplicate_counts['staged_guide_ids']['near_pairs'])}**.",
        f"- Staged guide title exact groups / near pairs: **{len(duplicate_counts['staged_guide_titles']['exact_groups'])} / {len(duplicate_counts['staged_guide_titles']['near_pairs'])}**.",
        f"- Staged guide slug exact groups / near pairs: **{len(duplicate_counts['staged_guide_slugs']['exact_groups'])} / {len(duplicate_counts['staged_guide_slugs']['near_pairs'])}**.",
        "",
        "Candidate pairs are evidence for editorial review, not automatic deletion. Full pair details are in the JSON output.",
        "",
        "## Runtime reconciliation",
        "",
        f"- Effective published → runtime: **{len(report['runtime_reconciliation']['effective_missing_from_runtime'])} missing / {len(report['runtime_reconciliation']['runtime_not_effectively_published'])} unexpected**.",
        f"- Runtime → public web: **{len(report['runtime_reconciliation']['runtime_missing_from_public'])} missing / {len(report['runtime_reconciliation']['public_not_in_runtime'])} unexpected**.",
        f"- Practical guides in runtime/public: **{report['runtime_reconciliation']['runtime_has_practical_guide']} / {report['runtime_reconciliation']['public_has_practical_guide']}**.",
        "",
        "## Existing link-health evidence",
        "",
        f"The repository's existing link report checked **{report['existing_link_health_evidence']['total']}** URLs at **{report['existing_link_health_evidence']['checked_at']}**: **{report['existing_link_health_evidence']['confirmed_broken']} confirmed broken**, **{report['existing_link_health_evidence']['access_restricted']} access-restricted**, and **{report['existing_link_health_evidence']['transient_failures']} transient failures**. This audit imported those counts but did not perform a new network check.",
        "",
        "## Audience-path gap",
        "",
        f"Production-ready explicit audience coverage is **{report['user_path_coverage']['paths_with_at_least_one_production_ready_guide']}/{report['user_path_coverage']['denominator_paths_from_brief']} ({report['user_path_coverage']['coverage_percent']}%)**. {report['user_path_coverage']['taxonomy_gap']}",
        "",
        "## Smallest useful remediation",
        "",
        "1. Keep the 20 scaffolds in draft; assign canonical source entities to every scaffold before factual writing.",
        "2. Complete and review one P1 guide end-to-end, including official source IDs for every fact, reviewer, verification date, verified media, steps and FAQ; publish only through the existing release pipeline.",
        "3. Repeat P1 family by family. Do not interpret the 100% minimum-family summary inventory as 100% public or production readiness.",
        "4. Assign and review explicit audience profiles before claiming full user-path coverage.",
        "5. Run the existing live link/data-health check alongside this audit before any release; this script intentionally performs no network mutations or requests.",
        "",
        "## Reproduction",
        "",
        "```bash",
        f"python3 scripts/content-readiness-audit.py --as-of {report['as_of']} --check",
        "```",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--as-of", default=date.today().isoformat(), help="Evidence date in YYYY-MM-DD format")
    parser.add_argument("--json-output", type=Path, default=DEFAULT_JSON_OUTPUT)
    parser.add_argument("--markdown-output", type=Path, default=DEFAULT_MARKDOWN_OUTPUT)
    parser.add_argument("--stdout", action="store_true", help="Also print the full JSON report")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit non-zero only if audit integrity/reconciliation fails; readiness gaps remain report findings",
    )
    args = parser.parse_args()

    try:
        as_of = date.fromisoformat(args.as_of)
    except ValueError:
        parser.error("--as-of must use YYYY-MM-DD")

    report = build_report(as_of)
    args.json_output.parent.mkdir(parents=True, exist_ok=True)
    args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
    args.json_output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    args.markdown_output.write_text(render_markdown(report), encoding="utf-8")

    headline = report["headline"]
    print("YouNew content readiness audit complete")
    print(f"- Governed records: {headline['governed_records']}")
    print(f"- Material records: {headline['material_records']}")
    print(f"- Public guides: {headline['public_summary_guides']} summary / {headline['public_full_practical_guides']} full")
    print(f"- Draft/review guide scaffolds: {headline['staged_draft_or_review_guides']}")
    print(f"- Production-ready guides: {headline['production_ready_guides']}")
    print(f"- Audit integrity: {report['audit_integrity']['status']}")
    print(f"- JSON: {args.json_output}")
    print(f"- Markdown: {args.markdown_output}")
    if args.stdout:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    if args.check and report["audit_integrity"]["status"] != "passed":
        for failure in report["audit_integrity"]["failures"]:
            print(f"AUDIT INTEGRITY FAILURE: {failure}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
