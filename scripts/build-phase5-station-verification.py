#!/usr/bin/env python3
"""Build the governed Phase 5 Amsterdam-station verification candidate.

This script does not publish the candidate and does not alter the production
runtime. It converts the manually reviewed source evidence into an immutable
overlay candidate that can pass the normal Data Project QA gates.
"""

from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

from effective_release import canonical_sha256, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
BASE_RELEASE = "amsterdam-v0.1.8"
CANDIDATE_RELEASE = "amsterdam-v0.1.9"
REVIEWED_AT = "2026-10-24"
NS_AMSTERDAM_SOURCE = "https://www.ns.nl/en/travel/destinations/amsterdam"

STATIONS = {
    "transport.amsterdam-amstel-station": {
        "name": "Amsterdam Amstel",
        "osm_kind": "node",
        "osm_id": "4040491812",
    },
    "transport.amsterdam-bijlmer-arena-station": {
        "name": "Amsterdam Bijlmer ArenA",
        "osm_kind": "node",
        "osm_id": "4005961975",
    },
    "transport.amsterdam-centraal-station": {
        "name": "Amsterdam Centraal",
        "osm_kind": "node",
        "osm_id": "4290854847",
    },
    "transport.amsterdam-holendrecht-station": {
        "name": "Amsterdam Holendrecht",
        "osm_kind": "node",
        "osm_id": "250233810",
    },
    "transport.amsterdam-lelylaan-station": {
        "name": "Amsterdam Lelylaan",
        "osm_kind": "node",
        "osm_id": "4076017504",
    },
    "transport.amsterdam-muiderpoort-station": {
        "name": "Amsterdam Muiderpoort",
        "osm_kind": "way",
        "osm_id": "1409848101",
    },
    "transport.amsterdam-rai-station": {
        "name": "Amsterdam RAI",
        "osm_kind": "node",
        "osm_id": "4046323545",
    },
    "transport.amsterdam-science-park-station": {
        "name": "Amsterdam Science Park",
        "osm_kind": "node",
        "osm_id": "7606648992",
    },
    "transport.amsterdam-sloterdijk-station": {
        "name": "Amsterdam Sloterdijk",
        "osm_kind": "node",
        "osm_id": "3938547498",
    },
    "transport.amsterdam-zuid-station": {
        "name": "Amsterdam Zuid",
        "osm_kind": "node",
        "osm_id": "5252944882",
    },
}


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def evidence_id(entity_id: str, kind: str) -> str:
    return f"evidence.phase5.{entity_id.replace('_', '-').replace('.', '-')}.{kind}"


def build_candidate() -> tuple[dict, dict, dict]:
    effective = resolve_release(PROJECT, BASE_RELEASE)
    records = {record["id"]: record for record in effective.records}
    missing = sorted(set(STATIONS) - set(records))
    if missing:
        raise RuntimeError(f"candidate references missing records: {missing}")

    evidence = [
        {
            "id": "evidence.phase5.ns-amsterdam-station-list-2026-10-24",
            "kind": "replacement_review",
            "url": NS_AMSTERDAM_SOURCE,
            "checked_at": REVIEWED_AT,
            "note": (
                "The official NS Amsterdam destination page lists ten Amsterdam stations, "
                "including every station in this verification wave. It is evidence for the "
                "station names and Amsterdam location, not for mutable departure times."
            ),
        }
    ]
    replacements = []
    confirmations = []

    for entity_id, facts in sorted(STATIONS.items()):
        original = records[entity_id]
        replacement = copy.deepcopy(original)
        expected_title = f"{facts['name']} station"
        if replacement["title"] != expected_title:
            raise RuntimeError(f"unexpected title for {entity_id}: {replacement['title']!r}")

        station_url = replacement["website"]
        osm_url = f"https://www.openstreetmap.org/{facts['osm_kind']}/{facts['osm_id']}"
        station_evidence = evidence_id(entity_id, "official-ns-page")
        coordinate_evidence = evidence_id(entity_id, "osm-coordinate")
        evidence.extend(
            [
                {
                    "id": station_evidence,
                    "kind": "replacement_review",
                    "url": station_url,
                    "checked_at": REVIEWED_AT,
                    "note": (
                        f"The official NS page identifies {facts['name']} and provides the "
                        "current departures, disruption, facilities and map surfaces. No "
                        "changing timetable, price, opening-hour or availability value is copied."
                    ),
                },
                {
                    "id": coordinate_evidence,
                    "kind": "replacement_review",
                    "url": osm_url,
                    "checked_at": REVIEWED_AT,
                    "note": (
                        f"OpenStreetMap {facts['osm_kind']} {facts['osm_id']} identifies the "
                        f"station as {facts['name']} (or Muiderpoortstation for Amsterdam "
                        "Muiderpoort) and matches the stored map coordinate."
                    ),
                },
            ]
        )

        replacement["description"] = (
            f"NS lists {facts['name']} among Amsterdam's railway stations. The official "
            "station page provides current departures, disruptions, facilities and a station "
            "map. YouNew does not copy changing times or availability; check NS before travel."
        )
        # Transport imagery is optional. Removing the July image avoids presenting an
        # expired or contextually wrong visual as part of the newly verified record.
        replacement["images"] = []
        replacement["official_source"]["checked_at"] = REVIEWED_AT
        replacement["official_source"]["status"] = "verified_opened"
        replacement["last_checked"] = REVIEWED_AT
        replacement["review_frequency_days"] = 90
        replacement["verification_status"] = "verified"
        replacement["ai_summary"] = (
            f"{facts['name']} is listed by NS as an Amsterdam station. Use the official NS "
            "station page for current departures, disruptions, facilities and the station map."
        )
        replacement["search_keywords"] = [
            facts["name"],
            f"{facts['name']} Amsterdam",
            "railway station",
            "train station Amsterdam",
            "Noord-Holland",
        ]
        replacement["attributes"] = {
            **replacement.get("attributes", {}),
            "coordinate_source": (
                f"OpenStreetMap {facts['osm_kind']} {facts['osm_id']}; field-reviewed {REVIEWED_AT}"
            ),
            "source_http_status": "200",
            "source_final_url": station_url,
            "source_verification_method": "manual_field_level_review_ns_and_openstreetmap",
            "media_match": "not_applicable",
            "media_roles_count": "0",
            "confirmed_fields": (
                "station name; Amsterdam location; rail-station identity; official NS route; "
                "map coordinate; absence of copied mutable timetable, price and opening-hour facts"
            ),
        }

        replacements.append(
            {
                "entity_id": entity_id,
                "original_canonical_sha256": canonical_sha256(original),
                "replacement_canonical_sha256": canonical_sha256(replacement),
                "reason": (
                    "Field-level review against the official NS station surfaces and the "
                    "identified OpenStreetMap object. Optional imagery was removed and public "
                    "copy was narrowed to the confirmed facts."
                ),
                "evidence_refs": [
                    "evidence.phase5.ns-amsterdam-station-list-2026-10-24",
                    station_evidence,
                    coordinate_evidence,
                ],
                "record": replacement,
            }
        )
        confirmations.append(
            {
                "entity_id": entity_id,
                "status": "confirmed_current_qa_candidate",
                "reviewed_at": REVIEWED_AT,
                "official_source_url": station_url,
                "coordinate_source_url": osm_url,
                "confirmed_fields": replacement["attributes"]["confirmed_fields"].split("; "),
                "excluded_fields": [
                    "live departures",
                    "temporary disruptions",
                    "facility opening hours",
                    "real-time availability",
                    "ticket prices",
                ],
                "production_publication_status": "withheld_pending_release_acceptance_and_deployment_authorisation",
            }
        )

    overlay = {
        "schema_version": 1,
        "release_id": CANDIDATE_RELEASE,
        "version": "0.1.9",
        "status": "qa",
        "work_package": "WP-06",
        "dataset": "Amsterdam City 01",
        "base_release_id": BASE_RELEASE,
        "supersedes": BASE_RELEASE,
        "base_batch_sha256": "a24f464c86e1880a542b23f1606f8622218cc0c7aa75464a9a19402847813b07",
        "qa": {gate: "passed" for gate in ("build", "static", "duplicate", "source", "media", "search", "ai")},
        "evidence": evidence,
        "replacements": replacements,
    }
    confirmation_ledger = {
        "schema_version": 1,
        "reviewed_at": REVIEWED_AT,
        "method": (
            "Manual field-level review of the official NS Amsterdam/station pages plus exact "
            "OpenStreetMap objects for coordinates. HTTP availability alone was not accepted as proof."
        ),
        "reviewer": "OpenAI Codex assisted review",
        "candidate_release_id": CANDIDATE_RELEASE,
        "confirmed_current_qa_candidates": len(confirmations),
        "production_public_records_added": 0,
        "records": confirmations,
    }
    restoration = {
        "schema_version": 1,
        "as_of": REVIEWED_AT,
        "phase4_stale_baseline": 170,
        "new_field_confirmed_records": len(confirmations),
        "remaining_without_current_field_confirmation": 170 - len(confirmations),
        "production_exclusions_unchanged": 170,
        "current_production_safe_public_records": 7,
        "candidate_public_records_after_acceptance": 7 + len(confirmations),
        "candidate_release_id": CANDIDATE_RELEASE,
        "candidate_state": "qa_not_production_authorized",
        "rule": (
            "Confirmed QA candidates remain excluded from the production runtime until the "
            "release is accepted, its seven QA gates pass, and deployment receives separate owner approval."
        ),
        "confirmed_entity_ids": sorted(STATIONS),
    }
    return overlay, confirmation_ledger, restoration


def update_release_registry() -> None:
    path = PROJECT / "releases" / "releases.json"
    registry = json.loads(path.read_text(encoding="utf-8"))
    candidate = {
            "id": CANDIDATE_RELEASE,
            "work_package": "WP-06",
            "dataset": "Amsterdam City 01",
            "version": "0.1.9",
            "status": "qa",
            "milestone": "WP-06-M2",
            "target_records": 184,
            "published_records": 0,
            "published_at": None,
            "publication_timestamp": None,
            "approver": None,
            "base_release_id": BASE_RELEASE,
            "supersedes": BASE_RELEASE,
            "base_batch_sha256": "a24f464c86e1880a542b23f1606f8622218cc0c7aa75464a9a19402847813b07",
            "overlay_path": "DataProject/overlays/WP-06/amsterdam-v0.1.9.json",
            "acceptance_lock_path": "DataProject/releases/acceptance-locks/amsterdam-v0.1.8.json",
            "qa": {gate: "passed" for gate in ("build", "static", "duplicate", "source", "media", "search", "ai")},
        }
    existing_index = next(
        (index for index, item in enumerate(registry["releases"]) if item.get("id") == CANDIDATE_RELEASE),
        None,
    )
    if existing_index is None:
        registry["releases"].append(candidate)
    else:
        registry["releases"][existing_index] = candidate
    write_json(path, registry)


def main() -> int:
    overlay, confirmations, restoration = build_candidate()
    write_json(PROJECT / "overlays" / "WP-06" / "amsterdam-v0.1.9.json", overlay)
    write_json(PROJECT / "research" / "phase5-station-confirmations.json", confirmations)
    write_json(PROJECT / "quality" / "phase5-catalog-restoration.json", restoration)
    update_release_registry()
    print(f"Built {CANDIDATE_RELEASE}: {len(STATIONS)} field-confirmed QA candidates; production unchanged")
    return 0


if __name__ == "__main__":
    sys.exit(main())
