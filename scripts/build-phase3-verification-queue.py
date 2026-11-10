#!/usr/bin/env python3
"""Build Phase 3's evidence-safe freshness queue and the next 50-record wave.

The queue is an editorial work list. HTTP reachability is recorded as a source
observation only and can never change a record's factual verification state.
"""

from __future__ import annotations

import csv
import json
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "DataProject"
AS_OF = "2026-10-23"
AUDIT_MATRIX = DATA / "quality/content-readiness-matrix.json"
FRESHNESS = DATA / "reports/freshness-dashboard.json"
PUBLIC = ROOT / "admin-dashboard/public-site/src/generated/public-content.json"
BASELINE = DATA / "operations/source-monitor-baseline.json"
WAVE_ONE = DATA / "quality/freshness-review-wave-1.json"
CONFIRMATIONS = DATA / "research/freshness-wave-1-confirmations.json"
WAVE_TWO_JSON = DATA / "quality/freshness-review-wave-2.json"
WAVE_TWO_MD = DATA / "quality/freshness-review-wave-2.md"
QUEUE_JSON = DATA / "operations/source-verification-queue.json"
QUEUE_CSV = DATA / "operations/source-verification-queue.csv"
QUEUE_MD = DATA / "operations/source-verification-queue.md"

TYPE_WEIGHTS = {
    "governmentservice": 36,
    "government_service": 36,
    "healthcare": 32,
    "housing": 30,
    "transport": 28,
    "university": 26,
    "restaurant": 24,
    "cafe": 22,
    "localpartner": 20,
    "local_partner": 20,
    "hotel": 18,
    "museum": 15,
    "place": 12,
}
HIGH_INTENT_CATEGORIES = {
    "identity": 18,
    "immigration": 18,
    "housing": 17,
    "healthcare": 16,
    "transport": 15,
    "work": 14,
    "education": 13,
    "finance": 12,
    "food-drink": 10,
}
WAVE_TWO_QUOTAS = {
    "governmentservice": 10,
    "healthcare": 8,
    "transport": 7,
    "restaurant": 8,
    "cafe": 5,
    "localpartner": 5,
    "university": 2,
}


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def normalized_type(value: str | None) -> str:
    return (value or "unknown").replace("-", "").replace("_", "").casefold()


def main() -> None:
    stale_rows = load(AUDIT_MATRIX)["quality_gaps"]["stale_governed_records"]
    if len(stale_rows) != 415:
        raise SystemExit(f"Expected the audited 415-record baseline, found {len(stale_rows)}")

    freshness = {row["entity_id"]: row for row in load(FRESHNESS)["entries"]}
    public = {row["id"]: row for row in load(PUBLIC)["entities"]}
    sources = {row["entity_id"]: row for row in load(BASELINE)["sources"]}
    wave_one = {row["entity_id"]: row for row in load(WAVE_ONE)["records"]}
    confirmed = {row["entity_id"]: row for row in load(CONFIRMATIONS)["records"]}

    if len(confirmed) != 5:
        raise SystemExit(f"Expected 5 field-confirmed records, found {len(confirmed)}")
    remaining = [row for row in stale_rows if row["id"] not in confirmed]
    if len(remaining) != 410:
        raise SystemExit(f"Expected 410 pending records after confirmations, found {len(remaining)}")

    candidates = []
    for stale in remaining:
        entity_id = stale["id"]
        entity = public.get(entity_id, {})
        source = sources.get(entity_id, {})
        raw_type = entity.get("sourceKind") or stale.get("entity_type") or "unknown"
        entity_type = normalized_type(raw_type)
        category = stale.get("category") or (entity.get("categorySlugs") or [""])[0]
        published = bool(entity)
        source_outcome = source.get("outcome") or "not_checked"
        score = (
            (100 if published else 0)
            + TYPE_WEIGHTS.get(entity_type, 8)
            + HIGH_INTENT_CATEGORIES.get(category, 0)
            + (6 if source_outcome in {"reachable", "redirected"} else 0)
        )
        reasons = []
        if published:
            reasons.append("published_user_facing_record")
        if entity_type in TYPE_WEIGHTS:
            reasons.append("high_intent_entity_type")
        if category in HIGH_INTENT_CATEGORIES:
            reasons.append("high_intent_category")
        if source_outcome in {"reachable", "redirected"}:
            reasons.append("source_openable_for_editorial_review")
        elif source_outcome in {"restricted", "transient_failure"}:
            reasons.append("source_access_needs_manual_follow_up")
        candidates.append({
            "entity_id": entity_id,
            "title": entity.get("title") or entity_id,
            "entity_type": raw_type,
            "normalized_entity_type": entity_type,
            "category": category,
            "public_route": entity.get("route"),
            "baseline_last_checked": stale.get("last_checked") or freshness.get(entity_id, {}).get("last_checked"),
            "baseline_review_due": freshness.get(entity_id, {}).get("review_due"),
            "priority_score": score,
            "priority_reasons": reasons,
            "source_url": source.get("url"),
            "source_observation": source_outcome,
            "source_http_status": source.get("http_status"),
            "source_observed_at": source.get("checked_at"),
            "verification_status": "awaiting_fact_review",
            "verified_at": None,
            "reviewer": None,
            "confirmed_fields": [],
            "verification_requirement": "Open an authoritative source and confirm named fields; URL availability alone is insufficient.",
        })

    candidates.sort(key=lambda row: (-row["priority_score"], row["title"].casefold(), row["entity_id"]))
    wave_two: list[dict] = []
    selected_ids: set[str] = set()
    for entity_type, quota in WAVE_TWO_QUOTAS.items():
        matches = [
            row for row in candidates
            if row["normalized_entity_type"] == entity_type
            and row["entity_id"] not in wave_one
        ]
        for row in matches[:quota]:
            wave_two.append(row)
            selected_ids.add(row["entity_id"])
    for row in candidates:
        if len(wave_two) >= 50:
            break
        if row["entity_id"] in wave_one or row["entity_id"] in selected_ids:
            continue
        wave_two.append(row)
        selected_ids.add(row["entity_id"])
    if len(wave_two) != 50:
        raise SystemExit(f"Expected a 50-record second wave, built {len(wave_two)}")

    for rank, row in enumerate(wave_two, start=1):
        row["rank"] = rank
        row["queue_phase"] = "wave_2"

    queue = []
    wave_two_ids = {row["entity_id"] for row in wave_two}
    for row in candidates:
        if row["entity_id"] in wave_one:
            phase = "wave_1_pending"
        elif row["entity_id"] in wave_two_ids:
            phase = "wave_2"
        else:
            phase = "backlog"
        queue.append({**row, "queue_phase": phase})
    queue.sort(key=lambda row: (
        {"wave_1_pending": 0, "wave_2": 1, "backlog": 2}[row["queue_phase"]],
        -row["priority_score"],
        row["entity_id"],
    ))
    for position, row in enumerate(queue, start=1):
        row["queue_position"] = position

    wave_counts = Counter(row["source_observation"] for row in wave_two)
    wave_payload = {
        "schema_version": 1,
        "as_of": AS_OF,
        "baseline_stale_records": 415,
        "already_confirmed_current": 5,
        "pending_before_wave": 410,
        "selection_size": 50,
        "selection_method": "Exclude wave 1, then prioritize published high-intent records by type and category. Source reachability is only an editorial convenience signal.",
        "source_observation_counts": dict(sorted(wave_counts.items())),
        "verification_status_counts": {"awaiting_fact_review": 50},
        "records": wave_two,
    }
    WAVE_TWO_JSON.write_text(json.dumps(wave_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    queue_counts = Counter(row["queue_phase"] for row in queue)
    queue_payload = {
        "schema_version": 1,
        "as_of": AS_OF,
        "audited_stale_baseline": 415,
        "confirmed_current_excluded": 5,
        "pending_total": 410,
        "phase_counts": dict(sorted(queue_counts.items())),
        "allowed_verification_statuses": [
            "awaiting_fact_review", "in_review", "confirmed_current",
            "conflict_found", "source_restricted", "retired_with_evidence",
        ],
        "policy": "DataProject/operations/freshness-review-policy.json",
        "proof_rule": "A source must be authoritative and named fields must be reviewed. HTTP success alone never confirms facts.",
        "confirmed_registry": "DataProject/research/freshness-wave-1-confirmations.json",
        "records": queue,
    }
    QUEUE_JSON.write_text(json.dumps(queue_payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    fieldnames = [
        "queue_position", "queue_phase", "entity_id", "title", "entity_type", "category",
        "public_route", "priority_score", "source_url", "source_observation", "source_http_status",
        "source_observed_at", "verification_status", "verified_at", "reviewer",
    ]
    with QUEUE_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(queue)

    wave_lines = [
        "# Freshness review wave 2",
        "",
        f"As of {AS_OF}. The audited baseline was **415** stale records; **5** are field-confirmed and **410** remain pending. This wave prepares the next **50** for real review.",
        "",
        "> None of these 50 records is marked fresh. An HTTP response is only a source observation; an editor must confirm named fields against an authoritative source.",
        "",
        "| # | Record | Type | Category | Source observation | Priority |",
        "|---:|---|---|---|---|---:|",
    ]
    for row in wave_two:
        wave_lines.append(
            f"| {row['rank']} | `{row['entity_id']}` | {row['entity_type']} | {row['category'] or '—'} | {row['source_observation']} | {row['priority_score']} |"
        )
    WAVE_TWO_MD.write_text("\n".join(wave_lines) + "\n", encoding="utf-8")

    QUEUE_MD.write_text("\n".join([
        "# Source verification queue",
        "",
        f"Generated {AS_OF}. Pending factual review: **410** records.",
        "",
        f"- Wave 1 pending: **{queue_counts['wave_1_pending']}**",
        f"- Wave 2 prepared: **{queue_counts['wave_2']}**",
        f"- Later backlog: **{queue_counts['backlog']}**",
        "- Confirmed-current registry (excluded from this queue): **5**",
        "",
        "The machine-readable JSON and CSV hold the full queue. Moving a row to `confirmed_current` requires an authoritative source, review date, reviewer, and explicit confirmed fields.",
    ]) + "\n", encoding="utf-8")

    print(json.dumps({
        "pending_total": len(queue),
        "phase_counts": dict(queue_counts),
        "wave_2_source_observations": dict(wave_counts),
        "outputs": [str(WAVE_TWO_JSON), str(QUEUE_JSON), str(QUEUE_CSV)],
    }, indent=2))


if __name__ == "__main__":
    main()
