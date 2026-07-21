#!/usr/bin/env python3
"""Validate the non-publishable first-wave practical-guide staging collection."""

from __future__ import annotations

import copy
import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT / "DataProject" / "schema" / "entity.schema.json"
STAGING_PATH = ROOT / "DataProject" / "staging" / "practical-guides-wave-1.json"
IMPORTER_PATH = ROOT / "scripts" / "import-data-project.py"
EXPECTED_TITLES = (
    "Registering at a municipality",
    "Getting a BSN",
    "Applying for DigiD",
    "Finding a huisarts",
    "Dutch health insurance",
    "Renting a home",
    "Reporting housing defects",
    "Using public transport",
    "Finding work",
    "Understanding an employment contract",
    "Taxes and allowances",
    "Opening a Dutch bank account",
    "Emergency numbers and urgent help",
    "Residence permits",
    "Dutch integration exams",
    "Studying in the Netherlands",
    "Student housing",
    "Moving to another municipality",
    "Reporting discrimination",
    "Starting a business",
)
EXPLICIT_GAP_TITLES = {
    "Finding work": "No governed QA record covers the end-to-end task of finding work.",
    "Opening a Dutch bank account": "No governed QA record covers opening a Dutch bank account.",
    "Student housing": "No governed QA record covers student-specific housing.",
}
CONTENT_ARRAYS = (
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
    "official_sources",
    "contact_options",
    "related_guide_ids",
    "next_actions",
)


def fail(message: str):
    raise SystemExit(f"Practical guide QA failed: {message}")


def expect(condition: bool, message: str):
    if not condition:
        fail(message)


def expect_schema_rejection(importer, candidate, schema, label: str):
    try:
        importer.validate_schema(candidate, schema["$defs"]["practicalGuide"], schema, label)
    except importer.ImportFailure:
        return
    fail(f"schema bounds accepted {label}")


def load(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"Cannot read {path.relative_to(ROOT)}: {error}")


def load_importer():
    spec = importlib.util.spec_from_file_location("data_project_importer", IMPORTER_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def governed_records():
    records = {}
    for path in sorted((ROOT / "DataProject" / "batches").glob("**/*.json")):
        batch = load(path)
        for record in batch.get("records", []):
            records[record["id"]] = record
    return records


def validate_importer_projection(importer, schema, records):
    governed_source_record = records["government.bsn"]
    checked_at = governed_source_record["last_checked"]
    source = {"id": "source.fixture", **governed_source_record["official_source"]}
    guide = {
        "schema_version": 2,
        "id": "guide.qa-fixture",
        "slug": "qa-fixture",
        "locale": "en",
        "title": "Practical guide QA fixture",
        "short_summary": {"id": "summary", "text": "Test-only sourced summary.", "source_ids": ["source.fixture"]},
        "audience_profiles": ["expat"],
        "who_this_is_for": {"id": "audience", "text": "Test-only audience explanation.", "source_ids": ["source.fixture"]},
        "when_you_need_it": {"id": "when", "text": "Test-only applicability explanation.", "source_ids": ["source.fixture"]},
        "applicability": {"city_ids": [], "province_ids": []},
        "jurisdiction": {
            "level": "national",
            "country_code": "NL",
            "municipality_dependent": False,
            "note": "Test-only jurisdiction value.",
            "source_ids": ["source.fixture"],
        },
        "prerequisites": [{"id": "prereq.one", "text": "Test-only prerequisite.", "source_ids": ["source.fixture"]}],
        "required_documents": [{"id": "document.one", "text": "Test-only required document.", "source_ids": ["source.fixture"]}],
        "estimated_time": {
            "state": "known",
            "value": "Test-only value",
            "note": "Test-only timing note.",
            "source_ids": ["source.fixture"],
        },
        "estimated_cost": {
            "state": "not_applicable",
            "value": None,
            "note": "Test-only value",
            "currency": None,
            "source_ids": ["source.fixture"],
        },
        "numbered_steps": [{
            "id": "step.one",
            "position": 1,
            "title": "Test step",
            "body": "This is test-only projection content.",
            "source_ids": ["source.fixture"],
            "municipality_dependent": False,
        }],
        "warnings": [{"id": "warning.one", "text": "Test-only warning.", "source_ids": ["source.fixture"]}],
        "common_mistakes": [{"id": "mistake.one", "text": "Test-only common mistake.", "source_ids": ["source.fixture"]}],
        "tips": [{"id": "tip.one", "text": "Use the official test fixture.", "source_ids": ["source.fixture"]}],
        "checklist": [{"id": "check.one", "text": "Complete the test-only step.", "source_ids": ["source.fixture"]}],
        "faqs": [
            {"id": "faq.one", "question": "What is this fixture?", "answer": "It is a test-only guide fixture.", "source_ids": ["source.fixture"]},
            {"id": "faq.two", "question": "Is this user-visible?", "answer": "No, it exists only inside automated tests.", "source_ids": ["source.fixture"]},
            {"id": "faq.three", "question": "Does it use a source?", "answer": "Yes, every answer cites the fixture source.", "source_ids": ["source.fixture"]},
        ],
        "emergency_information": [{"id": "emergency.one", "text": "Test-only emergency context.", "source_ids": ["source.fixture"]}],
        "sections": [{"id": "section.one", "title": "Test context", "body": "This is test-only contextual information.", "source_ids": ["source.fixture"]}],
        "official_sources": [source],
        "contact_options": [{"id": "contact.one", "kind": "url", "label": "Test contact", "value": "https://example.com/contact", "source_ids": ["source.fixture"]}],
        "related_guide_ids": ["housing.renting-a-home-in-amsterdam"],
        "next_actions": [{"id": "next.one", "text": "Test-only next action.", "source_ids": ["source.fixture"]}],
        "verified_at": checked_at,
        "updated_at": checked_at,
        "reviewer": {
            "id": "reviewer.qa-fixture-human",
            "name": "QA Fixture Human",
            "role": "Test editor",
            "reviewer_type": "human_editor",
            "reviewed_at": checked_at,
        },
        "reading_time_minutes": 4,
        "difficulty": "basic",
        "confidence_level": "high",
        "tags": ["quality assurance", "test fixture"],
        "publication_gate": {
            "status": "passed",
            "checked_at": checked_at,
            "checks": {
                "schema": True,
                "factual_sources": True,
                "links": True,
                "language": True,
                "media": True,
                "duplicate_content": True,
                "accessibility": True,
            },
            "notes": "Test-only gate evidence.",
            "evidence_ids": ["evidence.qa-fixture"],
        },
        "disclaimer": "Test-only disclaimer, never user-visible.",
        "seo": {
            "title": "Practical guide QA fixture",
            "description": "Test-only metadata used to verify fail-closed practical-guide projection.",
            "canonical_path": "/guides/qa-fixture",
        },
        "synonyms": ["QA fixture"],
        "common_questions": ["Does the practical guide projection pass QA?"],
        "status": "published",
    }
    record = {
        "id": "guide.qa-fixture",
        "entity_type": "knowledge_topic",
        "category": "quality_assurance",
        "city_id": None,
        "province_id": None,
        "coordinates": {"latitude": 52.0, "longitude": 4.0},
        "title": "Practical guide QA fixture",
        "description": "Test-only canonical record for practical-guide importer verification.",
        "images": [{
            "id": "media.qa-fixture.hero",
            "role": "hero",
            "source_page_url": "https://example.com/fixture-source-page",
            "asset_url": "https://example.com/fixture-image.jpg",
            "public_asset_path": "/images/og-younew.jpg",
            "license": "Test-only fixture license",
            "license_url": "https://example.com/fixture-license",
            "attribution": "Test-only fixture attribution",
            "alt": "Test-only accessible fixture image",
            "verified": True,
            "retrieved_at": checked_at,
        }],
        "official_source": {key: value for key, value in source.items() if key != "id"},
        "website": source["url"],
        "related_entity_ids": [],
        "last_checked": checked_at,
        "review_frequency_days": 400,
        "verification_status": "verified",
        "ai_summary": "Test-only canonical summary for practical-guide importer verification.",
        "search_keywords": ["fixture", "guide", "quality"],
        "lifecycle_status": "published",
        "attributes": {"publicWebCategory": "healthcare"},
        "practical_guide": guide,
    }
    reviewers = {
        "reviewer.qa-fixture-human": {
            "id": "reviewer.qa-fixture-human",
            "name": "QA Fixture Human",
            "role": "Test editor",
            "reviewer_type": "human_editor",
            "active": True,
            "locales": ["en"],
            "categories": ["*"],
        }
    }
    reviewer_registry = {
        "schema_version": 1,
        "policy": {"automated_reviewers_allowed": False},
        "reviewers": list(reviewers.values()),
    }
    expect(importer.reviewer_catalog_from_registry(reviewer_registry) == reviewers, "valid human reviewer registry did not resolve")
    invalid_registry = copy.deepcopy(reviewer_registry)
    invalid_registry["reviewers"][0]["locales"] = "en"
    try:
        importer.reviewer_catalog_from_registry(invalid_registry)
    except importer.ImportFailure:
        pass
    else:
        fail("reviewer registry accepted a string in place of the locales array")
    invalid_registry = copy.deepcopy(reviewer_registry)
    invalid_registry["reviewers"][0]["categories"] = "*"
    try:
        importer.reviewer_catalog_from_registry(invalid_registry)
    except importer.ImportFailure:
        pass
    else:
        fail("reviewer registry accepted a string in place of the categories array")
    evidence = {
        "evidence.qa-fixture": {
            "id": "evidence.qa-fixture",
            "guide_id": "guide.qa-fixture",
            "status": "passed",
            "checked_at": checked_at,
            "checks": ["schema", "factual_sources", "links", "language", "media", "duplicate_content", "accessibility"],
        }
    }
    importer.validate_schema(record, schema, schema, "published guide projection fixture")
    importer.validate_published_practical_guide(record, "published guide projection fixture", reviewers, evidence)
    projected = importer.runtime_entity(record, "qa-fixture-v1.0.0")
    expect(projected["practicalGuide"]["numberedSteps"][0]["sourceIDs"] == ["source.fixture"], "runtime projection lost per-fact source IDs")
    expect(projected["coordinate"] == {"latitude": 52, "longitude": 4}, "integral coordinate floats were not normalized for cross-language checksum stability")

    broken = copy.deepcopy(record)
    broken["practical_guide"]["numbered_steps"][0]["source_ids"] = ["source.missing"]
    try:
        importer.validate_published_practical_guide(broken, "broken source fixture", reviewers, evidence)
    except importer.ImportFailure:
        pass
    else:
        fail("published guide with an unresolved per-fact source ID passed importer validation")

    unsupported_locale = copy.deepcopy(record)
    unsupported_locale["practical_guide"]["locale"] = "nl"
    try:
        importer.validate_published_practical_guide(unsupported_locale, "unsupported locale fixture", reviewers, evidence)
    except importer.ImportFailure:
        pass
    else:
        fail("published guide escaped the English-only public route contract")

    invalid_cases = []

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["official_sources"][0]["url"] = "ftp://example.com/fixture"
    invalid_cases.append(("non-HTTPS guide source", invalid))

    invalid = copy.deepcopy(record)
    invalid["images"][0]["alt"] = "\u0000\u200b"
    invalid_cases.append(("control-only media alt", invalid))

    invalid = copy.deepcopy(record)
    invalid["images"][0]["public_asset_path"] = "/images/missing-fixture.webp"
    invalid_cases.append(("missing local public media asset", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["official_sources"][0]["checked_at"] = "2026-07-17"
    invalid_cases.append(("source older than content update", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["estimated_cost"].update({"state": "not_applicable", "value": "500", "currency": "EUR"})
    invalid_cases.append(("contradictory cost state", invalid))

    invalid = copy.deepcopy(record)
    invalid["entity_type"] = "city"
    invalid_cases.append(("unsupported guide parent", invalid))

    invalid = copy.deepcopy(record)
    invalid["attributes"].pop("publicWebCategory")
    invalid_cases.append(("missing canonical public web category", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["jurisdiction"].update({"level": "provincial", "municipality_dependent": False})
    invalid["practical_guide"]["applicability"] = {"city_ids": [], "province_ids": []}
    invalid_cases.append(("provincial guide without province", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["reviewer"]["id"] = "reviewer.unregistered"
    invalid_cases.append(("unregistered human reviewer", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["publication_gate"]["evidence_ids"] = ["evidence.unresolved"]
    invalid_cases.append(("unresolved QA evidence", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["slug"] = "different-guide-slug"
    invalid["practical_guide"]["seo"]["canonical_path"] = "/guides/different-guide-slug"
    invalid_cases.append(("non-deterministic public guide slug", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["contact_options"][0].update({"kind": "email", "value": "not-an-email"})
    invalid_cases.append(("invalid contact email", invalid))

    invalid = copy.deepcopy(record)
    invalid["practical_guide"]["contact_options"][0].update({"kind": "phone", "value": "123"})
    invalid_cases.append(("invalid contact phone", invalid))

    for case_label, invalid_record in invalid_cases:
        try:
            importer.validate_published_practical_guide(invalid_record, case_label, reviewers, evidence)
        except importer.ImportFailure:
            pass
        else:
            fail(f"published guide accepted {case_label}")

    max_bound_cases = []

    oversized = copy.deepcopy(guide)
    oversized["title"] = "x" * 121
    max_bound_cases.append(("oversized guide title", oversized))

    oversized = copy.deepcopy(guide)
    oversized["numbered_steps"] = [
        {**guide["numbered_steps"][0], "id": f"step.{index}", "position": index}
        for index in range(1, 27)
    ]
    max_bound_cases.append(("oversized guide step list", oversized))

    oversized = copy.deepcopy(guide)
    oversized["applicability"]["city_ids"] = [f"city.{index:03d}" for index in range(41)]
    max_bound_cases.append(("more than 40 applicability city IDs", oversized))

    oversized = copy.deepcopy(guide)
    oversized["applicability"]["province_ids"] = [f"province.{index:03d}" for index in range(13)]
    max_bound_cases.append(("more than 12 applicability province IDs", oversized))

    oversized = copy.deepcopy(guide)
    oversized["applicability"]["city_ids"] = ["city." + ("x" * 156)]
    max_bound_cases.append(("applicability city ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["applicability"]["province_ids"] = ["province." + ("x" * 152)]
    max_bound_cases.append(("applicability province ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["jurisdiction"]["source_ids"] = [f"source.{index:03d}" for index in range(13)]
    max_bound_cases.append(("more than 12 jurisdiction source IDs", oversized))

    oversized = copy.deepcopy(guide)
    oversized["jurisdiction"]["source_ids"] = ["source." + ("x" * 154)]
    max_bound_cases.append(("jurisdiction source ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["jurisdiction"]["note"] = "x" * 5001
    max_bound_cases.append(("jurisdiction note over 5000 characters", oversized))

    for estimate_key in ("estimated_time", "estimated_cost"):
        oversized = copy.deepcopy(guide)
        oversized[estimate_key]["source_ids"] = [f"source.{index:03d}" for index in range(13)]
        max_bound_cases.append((f"more than 12 {estimate_key} source IDs", oversized))

        oversized = copy.deepcopy(guide)
        oversized[estimate_key]["value"] = "x" * 241
        oversized[estimate_key]["state"] = "known"
        if estimate_key == "estimated_cost":
            oversized[estimate_key]["currency"] = "EUR"
        max_bound_cases.append((f"{estimate_key} value over 240 characters", oversized))

        oversized = copy.deepcopy(guide)
        oversized[estimate_key]["note"] = "x" * 1001
        max_bound_cases.append((f"{estimate_key} note over 1000 characters", oversized))

    oversized_ids = (
        ("guide FAQ ID", ("faqs", 0)),
        ("numbered step ID", ("numbered_steps", 0)),
        ("guide section ID", ("sections", 0)),
        ("contact option ID", ("contact_options", 0)),
    )
    for id_label, (collection, index) in oversized_ids:
        oversized = copy.deepcopy(guide)
        oversized[collection][index]["id"] = "block." + ("x" * 155)
        max_bound_cases.append((f"{id_label} over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["official_sources"][0]["id"] = "source." + ("x" * 154)
    max_bound_cases.append(("official guide source ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["reviewer"]["id"] = "reviewer." + ("x" * 152)
    max_bound_cases.append(("reviewer ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["related_guide_ids"] = ["guide." + ("x" * 155)]
    max_bound_cases.append(("related guide ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["id"] = "guide." + ("x" * 155)
    max_bound_cases.append(("practical guide ID over 160 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["slug"] = "x" * 121
    max_bound_cases.append(("practical guide slug over 120 characters", oversized))

    oversized = copy.deepcopy(guide)
    oversized["publication_gate"]["evidence_ids"] = ["evidence." + ("x" * 152)]
    max_bound_cases.append(("publication evidence ID over 160 characters", oversized))

    for label, candidate in max_bound_cases:
        expect_schema_rejection(importer, candidate, schema, label)

    root_bound_cases = []
    oversized_record = copy.deepcopy(record)
    oversized_record["id"] = "guide." + ("x" * 155)
    root_bound_cases.append(("canonical entity ID over 160 characters", oversized_record))
    oversized_record = copy.deepcopy(record)
    oversized_record["images"][0]["id"] = "media." + ("x" * 155)
    root_bound_cases.append(("media ID over 160 characters", oversized_record))
    oversized_record = copy.deepcopy(record)
    oversized_record["images"][0]["alt"] = "x" * 301
    root_bound_cases.append(("media alt over 300 characters", oversized_record))
    oversized_record = copy.deepcopy(record)
    oversized_record["images"][0]["public_asset_path"] = "/images/" + ("x" * 230) + ".webp"
    root_bound_cases.append(("public media path over 240 characters", oversized_record))
    for label, candidate in root_bound_cases:
        try:
            importer.validate_schema(candidate, schema, schema, label)
        except importer.ImportFailure:
            pass
        else:
            fail(f"schema bounds accepted {label}")

    draft = copy.deepcopy(record)
    draft["practical_guide"]["status"] = "draft"
    expect("practicalGuide" not in importer.runtime_entity(draft, "qa-fixture-v1.0.0"), "draft practical guide reached runtime projection")


def main():
    importer = load_importer()
    schema = load(SCHEMA_PATH)
    staging = load(STAGING_PATH)
    records = governed_records()

    expect(set(staging) == {"schema_version", "collection_id", "purpose", "status", "guides"}, "staging envelope changed")
    expect(staging["schema_version"] == 1, "unsupported staging schema version")
    expect(staging["collection_id"] == "practical-guides-wave-1", "unexpected collection ID")
    expect(staging["status"] == "draft", "first-wave staging collection must remain draft")
    guides = staging["guides"]
    expect(isinstance(guides, list) and len(guides) == 20, "first wave must contain exactly 20 guide scaffolds")

    titles = tuple(item.get("practical_guide", {}).get("title") for item in guides)
    expect(titles == EXPECTED_TITLES, "first-wave topics or their order changed")
    ids = [item["practical_guide"]["id"] for item in guides]
    slugs = [item["practical_guide"]["slug"] for item in guides]
    expect(len(ids) == len(set(ids)), "guide IDs are not unique")
    expect(len(slugs) == len(set(slugs)), "guide slugs are not unique")

    for index, item in enumerate(guides, start=1):
        label = f"{STAGING_PATH.relative_to(ROOT)} guide {index}"
        expect(set(item) == {"source_entity_ids", "publication_gaps", "practical_guide"}, f"{label} has unknown envelope fields")
        guide = item["practical_guide"]
        importer.validate_schema(guide, schema["$defs"]["practicalGuide"], schema, f"{label}.practical_guide")
        expect(guide["status"] == "draft", f"{label} escaped draft status")
        expect(guide["short_summary"] is None, f"{label} contains an unreviewed summary")
        expect(guide["jurisdiction"] is None, f"{label} asserts an unreviewed jurisdiction")
        expect(all(guide.get(field, []) == [] for field in CONTENT_ARRAYS), f"{label} contains unreviewed practical content")
        expect(guide.get("who_this_is_for") is None and guide.get("when_you_need_it") is None, f"{label} contains unreviewed audience/use-case copy")
        expect(guide.get("reading_time_minutes") is None and guide.get("difficulty") is None, f"{label} invents reading metadata")
        expect(guide.get("confidence_level") is None and guide.get("publication_gate") is None, f"{label} invents confidence or QA evidence")
        expect(guide.get("tags", []) == [], f"{label} contains unreviewed tags")
        expect(guide["verified_at"] is None and guide["updated_at"] is None, f"{label} invents editorial dates")
        expect(guide["reviewer"] is None, f"{label} invents a reviewer")
        expect(guide["disclaimer"] is None and guide["seo"] is None, f"{label} contains publishable presentation fields")
        expect(guide["estimated_time"] == {"state": "unknown", "value": None, "note": None, "source_ids": []}, f"{label} invents a time estimate")
        expect(guide["estimated_cost"] == {"state": "unknown", "value": None, "note": None, "currency": None, "source_ids": []}, f"{label} invents a cost estimate")
        expect(len(item["publication_gaps"]) >= 4, f"{label} does not document publication gaps")

        source_entity_ids = item["source_entity_ids"]
        expect(len(source_entity_ids) == len(set(source_entity_ids)), f"{label} repeats a governed source entity")
        for entity_id in source_entity_ids:
            expect(entity_id in records, f"{label} references unknown governed entity {entity_id}")
            record = records[entity_id]
            expect(record["lifecycle_status"] in {"qa", "published"}, f"{label} references non-QA entity {entity_id}")
            expect(record["verification_status"] == "verified", f"{label} references unverified entity {entity_id}")
            expect(record["entity_type"] != "local_partner", f"{label} treats a commercial partner as editorial evidence")
            source = record["official_source"]
            expect(source["is_official"] is True and source["status"] == "verified_opened", f"{label} references entity {entity_id} without an opened official source")

        explicit_gap = EXPLICIT_GAP_TITLES.get(guide["title"])
        if explicit_gap:
            expect(source_entity_ids == [], f"{label} must not substitute an adjacent record for its missing topic")
            expect(explicit_gap in item["publication_gaps"], f"{label} does not state its governed-content gap")

    # Regression proof: changing a scaffold status alone can never make it publishable.
    incomplete = copy.deepcopy(guides[0]["practical_guide"])
    incomplete["status"] = "published"
    try:
        importer.validate_schema(incomplete, schema["$defs"]["practicalGuide"], schema, "incomplete published guide")
    except importer.ImportFailure:
        pass
    else:
        fail("published-guide schema accepted an incomplete draft scaffold")

    validate_importer_projection(importer, schema, records)

    print("Practical guide QA passed")
    print("- Draft scaffolds: 20")
    print("- Published practical guides in staging: 0")
    print("- Governed QA entity references and opened official sources: validated")
    print("- Explicit content gaps: finding work, bank account, student housing")
    print("- Incomplete published-guide fail-closed check: passed")
    print("- Published projection and per-fact source-ID checks: passed")
    print("- Unrouted locale publication check: passed")
    print("- Reviewer/evidence registry, HTTPS, chronology, jurisdiction, estimates and parent-type checks: passed")
    print("- Schema maxLength/maxItems performance bounds: passed (29 focused cases)")


if __name__ == "__main__":
    main()
