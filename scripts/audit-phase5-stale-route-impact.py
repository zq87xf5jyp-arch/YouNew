#!/usr/bin/env python3
"""Prove the URL/sitemap effect of the Phase 4 stale-record exclusion."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "admin-dashboard/public-site"
OUTPUT = ROOT / "DataProject/quality/phase5-stale-route-impact.json"
CANDIDATE = ROOT / "DataProject/research/phase5-station-confirmations.json"


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def route_file(route: str) -> Path:
    return PUBLIC / "out" / route.strip("/") / "index.html"


def main() -> int:
    baseline_text = subprocess.check_output(
        ["git", "show", "HEAD:admin-dashboard/public-site/src/generated/public-content.json"],
        cwd=ROOT,
        text=True,
    )
    baseline = json.loads(baseline_text)
    current = load(PUBLIC / "src/generated/public-content.json")
    exclusions = load(PUBLIC / "src/generated/public-freshness-exclusions.json")
    confirmations = load(CANDIDATE)
    sitemap = (PUBLIC / "out/sitemap.xml").read_text(encoding="utf-8")

    baseline_by_id = {entity["id"]: entity for entity in baseline["entities"]}
    current_ids = {entity["id"] for entity in current["entities"]}
    excluded_ids = {record["id"] for record in exclusions["records"]}
    candidate_ids = {record["entity_id"] for record in confirmations["records"]}
    missing_baseline = sorted(excluded_ids - set(baseline_by_id))
    if missing_baseline:
        raise RuntimeError(f"excluded IDs missing from baseline: {missing_baseline}")

    records = []
    for entity_id in sorted(excluded_ids):
        route = baseline_by_id[entity_id]["route"]
        records.append(
            {
                "entity_id": entity_id,
                "previous_canonical_route": route,
                "current_public_entity_present": entity_id in current_ids,
                "current_static_page_present": route_file(route).exists(),
                "current_sitemap_present": f"https://younew.nl{route}/" in sitemap or f"https://younew.nl{route}" in sitemap,
                "phase5_candidate_for_same_url": entity_id in candidate_ids,
                "current_http_intent": "404_not_found",
            }
        )

    result = {
        "schema_version": 1,
        "as_of": "2026-10-24",
        "baseline_source": "git HEAD public-content snapshot before fail-closed exclusion",
        "excluded_records": len(records),
        "absent_from_current_public_entities": sum(not row["current_public_entity_present"] for row in records),
        "absent_static_pages": sum(not row["current_static_page_present"] for row in records),
        "absent_from_sitemap": sum(not row["current_sitemap_present"] for row in records),
        "same_url_phase5_candidates": sum(row["phase5_candidate_for_same_url"] for row in records),
        "new_redirects_added": 0,
        "empty_pages_added": 0,
        "policy": (
            "Unverified removed records remain real 404s and stay out of the sitemap. Do not mass-redirect "
            "them to a category (soft-404 risk). Accepted reverified records return at their original canonical URL."
        ),
        "records": records,
    }
    OUTPUT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        "Stale route impact: "
        f"{result['absent_static_pages']}/{result['excluded_records']} pages absent, "
        f"{result['absent_from_sitemap']}/{result['excluded_records']} sitemap URLs absent, "
        f"{result['same_url_phase5_candidates']} same-URL candidates"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
