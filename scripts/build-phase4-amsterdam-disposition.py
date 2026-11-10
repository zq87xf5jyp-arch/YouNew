#!/usr/bin/env python3
"""Create a fail-closed disposition for the 170 stale published records.

This is a publication safety control, not a factual re-verification shortcut.
Source availability and official-source identity are retained as review evidence,
but no record becomes current until named fields are checked by a reviewer.
"""

from __future__ import annotations

import csv
import json
import sys
from collections import Counter
from datetime import date, timedelta
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "DataProject"
sys.path.insert(0, str(ROOT / "scripts"))

from effective_release import effective_release_heads, resolve_release  # noqa: E402


AS_OF = date(2026, 10, 23)
AS_OF_TEXT = AS_OF.isoformat()
OUTPUT_JSON = DATA / "quality" / "phase4-amsterdam-stale-disposition.json"
OUTPUT_CSV = DATA / "quality" / "phase4-amsterdam-stale-disposition.csv"
OUTPUT_MD = DATA / "quality" / "phase4-amsterdam-stale-disposition.md"
EXCLUSION_JSON = ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-freshness-exclusions.json"
PUBLIC_JSON = ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-content.json"
SOURCE_BASELINE = DATA / "operations" / "source-monitor-baseline.json"

CRITICAL_TYPES = {
    "government_service", "healthcare", "transport", "local_partner",
    "restaurant", "cafe", "university", "education",
}
CRITICAL_CATEGORIES = {
    "identity", "immigration", "housing", "healthcare", "transport",
    "emergency", "food-drink", "local-services", "education", "finance",
}
TYPE_WEIGHT = {
    "government_service": 60,
    "healthcare": 55,
    "transport": 50,
    "local_partner": 46,
    "restaurant": 42,
    "cafe": 40,
    "university": 38,
    "museum": 28,
    "place": 20,
    "park": 16,
}


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def review_due(record: dict) -> date:
    checked = date.fromisoformat(record["last_checked"])
    return checked + timedelta(days=int(record["review_frequency_days"]))


def main() -> None:
    records: list[dict] = []
    for release_id in effective_release_heads(DATA):
        effective = resolve_release(DATA, release_id)
        for record in effective.records:
            if record.get("lifecycle_status") != "published":
                continue
            due = review_due(record)
            if record.get("verification_status") != "outdated" and due >= AS_OF:
                continue
            records.append({**record, "_release_id": release_id, "_review_due": due.isoformat()})

    if len(records) != 170:
        raise SystemExit(f"Expected the Phase 3 baseline of 170 stale published records, found {len(records)}")

    public = {row["id"]: row for row in load(PUBLIC_JSON)["entities"]}
    baseline = {row["entity_id"]: row for row in load(SOURCE_BASELINE)["sources"]}
    disposition = []
    for record in records:
        entity_id = record["id"]
        entity_type = record.get("entity_type") or "unknown"
        category = record.get("category") or "unknown"
        critical = entity_type in CRITICAL_TYPES or category in CRITICAL_CATEGORIES
        observation = baseline.get(entity_id, {})
        public_record = public.get(entity_id, {})
        overdue_days = (AS_OF - date.fromisoformat(record["_review_due"])).days
        score = (100 if critical else 0) + TYPE_WEIGHT.get(entity_type, 10) + min(overdue_days, 60)
        disposition.append({
            "entity_id": entity_id,
            "title": record.get("title") or entity_id,
            "entity_type": entity_type,
            "category": category,
            "release_id": record["_release_id"],
            "classification": "critical" if critical else "secondary",
            "priority_score": score,
            "last_checked": record.get("last_checked"),
            "review_due": record["_review_due"],
            "days_overdue": overdue_days,
            "official_source_url": record.get("official_source", {}).get("url"),
            "official_source_publisher": record.get("official_source", {}).get("publisher"),
            "source_is_declared_official": record.get("official_source", {}).get("is_official") is True,
            "source_observation": observation.get("outcome") or "not_observed",
            "source_http_status": observation.get("http_status"),
            "source_observed_at": observation.get("checked_at"),
            "public_route_before_exclusion": public_record.get("route"),
            "verification_status": "awaiting_fact_review",
            "confirmed_fields": [],
            "verified_at": None,
            "reviewer": None,
            "disposition": "temporarily_exclude_from_public_output",
            "reason": "Freshness SLA expired; source reachability alone does not confirm the published facts.",
        })

    disposition.sort(key=lambda row: (-row["priority_score"], row["title"].casefold(), row["entity_id"]))
    for rank, row in enumerate(disposition, start=1):
        row["priority_rank"] = rank
        row["priority_review_wave"] = "first_50" if rank <= 50 else "backlog"

    counts = Counter(row["classification"] for row in disposition)
    observations = Counter(row["source_observation"] for row in disposition[:50])
    payload = {
        "schema_version": 1,
        "as_of": AS_OF_TEXT,
        "baseline": "Phase 3 effective published catalog",
        "total_problem_records": 170,
        "critical_records": counts["critical"],
        "secondary_records": counts["secondary"],
        "priority_reviewed_for_source_identity_and_observation": 50,
        "confirmed_current": 0,
        "temporarily_excluded_from_public_output": 170,
        "source_observation_counts_first_50": dict(sorted(observations.items())),
        "proof_rule": "Only field-level review against an authoritative source may set confirmed_current. URL reachability never refreshes a record.",
        "records": disposition,
    }
    OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    fields = [
        "priority_rank", "priority_review_wave", "entity_id", "title", "entity_type", "category",
        "classification", "priority_score", "last_checked", "review_due", "days_overdue",
        "official_source_url", "official_source_publisher", "source_observation", "source_http_status",
        "source_observed_at", "public_route_before_exclusion", "verification_status", "disposition",
    ]
    with OUTPUT_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(disposition)

    exclusion = {
        "schemaVersion": 1,
        "asOf": AS_OF_TEXT,
        "policy": "fail_closed_until_field_level_reverification",
        "source": "DataProject/quality/phase4-amsterdam-stale-disposition.json",
        "count": 170,
        "records": [{
            "id": row["entity_id"],
            "classification": row["classification"],
            "reason": "freshness_sla_expired",
            "reviewDue": row["review_due"],
        } for row in disposition],
    }
    EXCLUSION_JSON.write_text(json.dumps(exclusion, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Phase 4 Amsterdam stale-record disposition",
        "",
        f"As of {AS_OF_TEXT}: **170** stale published records were classified; **{counts['critical']} critical** and **{counts['secondary']} secondary**.",
        "",
        "- Confirmed current after field-level review in Phase 4: **0**",
        "- Temporarily excluded from generated public output: **170**",
        "- First source-review wave: **50**",
        "- No database row was deleted and no date was refreshed from HTTP availability alone.",
        "",
        "## First 50",
        "",
        "| # | Record | Class | Type | Source observation | Due |",
        "|---:|---|---|---|---|---|",
    ]
    for row in disposition[:50]:
        lines.append(
            f"| {row['priority_rank']} | `{row['entity_id']}` | {row['classification']} | {row['entity_type']} | {row['source_observation']} | {row['review_due']} |"
        )
    OUTPUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(json.dumps({
        "total": len(disposition),
        "critical": counts["critical"],
        "secondary": counts["secondary"],
        "confirmed_current": 0,
        "temporarily_excluded": len(disposition),
        "first_50_source_observations": dict(sorted(observations.items())),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
