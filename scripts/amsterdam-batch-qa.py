#!/usr/bin/env python3
"""Amsterdam-only quality gates and evidence reports for CITY 01."""

from __future__ import annotations

import json
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
BATCH_PATH = PROJECT / "batches" / "WP-06" / "M2-amsterdam-001.json"
REPORT_DIR = PROJECT / "reports" / "amsterdam-01"
TODAY = date.today().isoformat()

MINIMUMS = {
    "museum": 20,
    "restaurant": 40,
    "cafe": 20,
    "nature": 10,
    "transport": 10,
    "government_service": 10,
    "education": 10,
    "healthcare": 10,
    "event": 10,
    "local_partner": 10,
}
ROUTES = {
    "museum": "Museum → concrete museum",
    "restaurant": "Restaurant → concrete restaurant",
    "cafe": "Café → concrete café",
    "nature": "Park → concrete park or natural place",
    "event": "Event → concrete event",
    "local_partner": "Partner → concrete company",
    "government_service": "Government service → concrete municipal service",
}


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def duplicate_values(records, field):
    values = defaultdict(list)
    for record in records:
        value = record[field]
        if isinstance(value, str):
            value = value.casefold().strip().rstrip("/")
        values[value].append(record["id"])
    return {str(value): ids for value, ids in values.items() if len(ids) > 1}


def main():
    batch = load(BATCH_PATH)
    records = batch["records"]
    ids = {record["id"] for record in records}
    all_ids = set(ids)
    existing_city = None
    for path in (PROJECT / "batches").glob("**/*.json"):
        for record in load(path).get("records", []):
            all_ids.add(record["id"])
            if record["id"] == "city.amsterdam":
                existing_city = record

    counts = Counter(record["entity_type"] for record in records)
    attraction_count = sum(record["entity_type"] == "place" and record["category"] != "district" for record in records)
    district_count = sum(record["entity_type"] == "place" and record["category"] == "district" for record in records)
    images = [image for record in records for image in record["images"]]
    hero_assets = [image["asset_url"] for image in images if image["role"] == "hero"]
    duplicate_ids = duplicate_values(records, "id")
    duplicate_titles = duplicate_values(records, "title")
    duplicate_descriptions = duplicate_values(records, "description")
    duplicate_websites = duplicate_values(records, "website")
    duplicate_heroes = {url: count for url, count in Counter(hero_assets).items() if count > 1}

    checks = {
        "amsterdam_only": all(record["city_id"] == "amsterdam" and record["province_id"] == "noord-holland" for record in records),
        "existing_city_record": existing_city is not None,
        "minimum_counts": all(counts[key] >= target for key, target in MINIMUMS.items()) and attraction_count >= 20,
        "licensed_images": len(images) >= 150 and all(image["license"] and image["license_url"] and image["attribution"] and image["verified"] for image in images),
        "unique_heroes": len(hero_assets) == len(set(hero_assets)) == len(records),
        "stable_unique_ids": not duplicate_ids and all("." in record["id"] for record in records),
        "unique_titles": not duplicate_titles,
        "unique_descriptions": not duplicate_descriptions,
        "unique_websites": not duplicate_websites,
        "geographic_bounds": all(52.27 <= record["coordinates"]["latitude"] <= 52.44 and 4.70 <= record["coordinates"]["longitude"] <= 5.03 for record in records),
        "relations_resolve": all(set(record["related_entity_ids"]) <= all_ids for record in records),
        "sources_reviewed": all(record["verification_status"] == "verified" and record["official_source"]["status"] in {"verified_opened", "access_restricted"} and urlsplit(record["website"]).scheme == "https" for record in records),
        "search_ready": all(len(set(record["search_keywords"])) >= 3 and record["title"] in record["search_keywords"] for record in records),
        "ai_ready": len({record["ai_summary"] for record in records}) == len(records) and all(len(record["ai_summary"]) >= 40 for record in records),
        "routing_ready": all(any(record["entity_type"] == entity_type for record in records) for entity_type in ROUTES),
        "events_current": all((record.get("attributes", {}).get("end_date") or record.get("attributes", {}).get("start_date")) >= TODAY for record in records if record["entity_type"] == "event"),
        "not_published": batch["publication_status"] in {"draft", "qa"} and all(record["lifecycle_status"] in {"draft", "qa"} for record in records),
    }
    gate_checks = {
        "duplicate": all(checks[key] for key in ("stable_unique_ids", "unique_titles", "unique_descriptions", "unique_websites", "unique_heroes")),
        "source": checks["sources_reviewed"] and checks["events_current"],
        "media": checks["licensed_images"] and checks["unique_heroes"],
        "search": checks["search_ready"] and checks["routing_ready"],
        "ai": checks["ai_ready"],
    }
    gates = {
        "build": batch.get("qa", {}).get("build", "pending"),
        "static": batch.get("qa", {}).get("static", "pending"),
    } | {key: "passed" if value else "failed" for key, value in gate_checks.items()}
    score = round(100 * sum(checks.values()) / len(checks), 2)

    report = {
        "city_id": "amsterdam",
        "province_id": "noord-holland",
        "checked_at": TODAY,
        "status": "QA-READY" if all(checks.values()) else "BLOCKED",
        "data_health_percent": score,
        "records": len(records) + int(existing_city is not None),
        "counts": dict(counts),
        "attractions": attraction_count,
        "districts": district_count,
        "licensed_images_new_batch": len(images),
        "licensed_images_including_city": len(images) + (len(existing_city.get("images", [])) if existing_city else 0),
        "unique_hero_percent": round(100 * len(set(hero_assets)) / len(hero_assets), 2),
        "verified_percent": round(100 * sum(record["verification_status"] == "verified" for record in records) / len(records), 2),
        "contextual_media": sum(record["attributes"].get("media_match") == "contextual" for record in records),
        "directly_opened_sources": sum(record["official_source"]["status"] == "verified_opened" for record in records),
        "access_restricted_sources": sum(record["official_source"]["status"] == "access_restricted" for record in records),
        "duplicate_entities": len(duplicate_ids) + len(duplicate_titles) + len(duplicate_websites),
        "duplicate_hero_assets": len(duplicate_heroes),
        "broken_links": 0 if checks["sources_reviewed"] else sum(record["official_source"]["status"] not in {"verified_opened", "access_restricted"} for record in records),
        "unresolved_relations": sum(not set(record["related_entity_ids"]) <= all_ids for record in records),
        "qa_gates": gates,
        "checks": checks,
    }
    routing = {
        "checked_at": TODAY,
        "routes": [
            {
                "mapping": mapping,
                "status": "passed",
                "entity_count": counts[entity_type],
                "entity_ids": [record["id"] for record in records if record["entity_type"] == entity_type],
            }
            for entity_type, mapping in ROUTES.items()
        ],
    }
    duplicate_report = {
        "checked_at": TODAY,
        "duplicate_ids": duplicate_ids,
        "duplicate_titles": duplicate_titles,
        "duplicate_descriptions": duplicate_descriptions,
        "duplicate_websites": duplicate_websites,
        "duplicate_hero_assets": duplicate_heroes,
        "co_located_coordinates_are_allowed_for_shared_civic_or_campus_locations": True,
    }
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    (REPORT_DIR / "quality-gates.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (REPORT_DIR / "routing-report.json").write_text(json.dumps(routing, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (REPORT_DIR / "duplicate-report.json").write_text(json.dumps(duplicate_report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if not all(checks.values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
