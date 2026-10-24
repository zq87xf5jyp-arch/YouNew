#!/usr/bin/env python3
"""Build the first 50-record freshness review wave without inventing facts."""

import json
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "DataProject"
AS_OF = "2026-10-23"
CONFIRMATIONS = DATA / "research/freshness-wave-1-confirmations.json"
FRESHNESS = DATA / "reports/freshness-dashboard.json"
AUDIT_MATRIX = DATA / "quality/content-readiness-matrix.json"
ATTEMPTS = DATA / "reports/source-check-attempts.json"
PUBLIC = ROOT / "admin-dashboard/public-site/src/generated/public-content.json"
OUTPUT_JSON = DATA / "quality/freshness-review-wave-1.json"
OUTPUT_MD = DATA / "quality/freshness-review-wave-1.md"

HIGH_INTENT_TYPES = {
    "city": 35,
    "governmentService": 30,
    "government_service": 30,
    "housing": 28,
    "healthcare": 25,
    "restaurant": 22,
    "cafe": 20,
    "localPartner": 20,
    "local_partner": 20,
    "hotel": 18,
    "museum": 15,
    "place": 12,
}
CANDIDATE_QUOTAS = {
    "governmentService": 8,
    "healthcare": 7,
    "restaurant": 10,
    "cafe": 7,
    "localPartner": 5,
    "transport": 5,
    "university": 3,
}
OUTCOME_PRIORITY = {"reachable": 0, "redirected": 1, "restricted": 2, "transient_failure": 3}


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def best_source_attempts():
    grouped = defaultdict(list)
    for row in load(ATTEMPTS).get("attempts", []):
        if row.get("recordKey"):
            grouped[row["recordKey"]].append(row)
    best = {}
    for key, rows in grouped.items():
        rows.sort(
            key=lambda row: (
                0 if "official_source.url" in (row.get("location") or "") else 1,
                OUTCOME_PRIORITY.get(row.get("outcome"), 99),
            )
        )
        best[key] = rows[0]
    return best


def main() -> None:
    freshness = load(FRESHNESS)
    freshness_by_id = {row["entity_id"]: row for row in freshness["entries"]}
    audited_stale = load(AUDIT_MATRIX)["quality_gaps"]["stale_governed_records"]
    stale = {
        row["id"]: {
            **row,
            **freshness_by_id.get(row["id"], {}),
        }
        for row in audited_stale
    }
    if len(stale) != 415:
        raise SystemExit(f"Expected audited baseline of 415 stale records, found {len(stale)}")

    confirmations = {row["entity_id"]: row for row in load(CONFIRMATIONS)["records"]}
    public = load(PUBLIC)
    public_by_id = {row["id"]: row for row in public["entities"]}
    attempts = best_source_attempts()

    selected = []
    for entity_id, confirmation in confirmations.items():
        stale_row = stale.get(entity_id)
        if not stale_row:
            raise SystemExit(f"Confirmed record {entity_id} was not in the 415-record audited baseline")
        entity = public_by_id.get(entity_id, {})
        selected.append(
            {
                "rank": 0,
                "entity_id": entity_id,
                "title": entity.get("title", entity_id),
                "entity_type": entity.get("sourceKind", stale_row.get("entity_type", "unknown")),
                "public_route": entity.get("route"),
                "baseline_review_due": stale_row.get("review_due"),
                "status": "confirmed_current",
                "source_url": confirmation["source_url"],
                "source_reachability": "manually_opened",
                "reviewed_at": confirmation["reviewed_at"],
                "reviewer": confirmation["reviewer"],
                "confirmed_fields": confirmation["confirmed_fields"],
                "notes": confirmation["notes"],
            }
        )

    candidates = []
    for entity_id, stale_row in stale.items():
        if entity_id in confirmations:
            continue
        entity = public_by_id.get(entity_id, {})
        attempt = attempts.get(entity_id, {})
        entity_type = entity.get("sourceKind", stale_row.get("entity_type", "unpublished"))
        score = (100 if entity else 0) + HIGH_INTENT_TYPES.get(entity_type, 5)
        if attempt.get("outcome") in {"reachable", "redirected"}:
            score += 8
        candidates.append((
            -score,
            entity.get("title", entity_id).casefold(),
            {
                "rank": 0,
                "entity_id": entity_id,
                "title": entity.get("title", entity_id),
                "entity_type": entity_type,
                "public_route": entity.get("route"),
                "baseline_review_due": stale_row.get("review_due"),
                "status": (
                    "source_reachable_fact_review_pending"
                    if attempt.get("outcome") in {"reachable", "redirected"}
                    else "source_restricted_fact_review_pending"
                    if attempt.get("outcome") == "restricted"
                    else "source_unavailable"
                ),
                "source_url": attempt.get("finalURL") or attempt.get("url"),
                "source_reachability": attempt.get("outcome") or "not_checked",
                "reviewed_at": None,
                "reviewer": None,
                "confirmed_fields": [],
                "notes": "Queued for field-level editorial review; source reachability is not factual confirmation.",
            },
        ))

    candidates.sort(key=lambda item: (item[0], item[1]))
    pending = []
    picked = set()
    for entity_type, quota in CANDIDATE_QUOTAS.items():
        matches = [item[2] for item in candidates if item[2]["entity_type"] == entity_type]
        for row in matches[:quota]:
            pending.append(row)
            picked.add(row["entity_id"])
    for _, _, row in candidates:
        if len(pending) >= 45:
            break
        if row["entity_id"] not in picked:
            pending.append(row)
            picked.add(row["entity_id"])
    selected.extend(pending)
    for rank, row in enumerate(selected, start=1):
        row["rank"] = rank

    if len(selected) != 50:
        raise SystemExit(f"Expected a 50-record wave, built {len(selected)}")

    counts = Counter(row["status"] for row in selected)
    payload = {
        "schema_version": 1,
        "as_of": AS_OF,
        "baseline_stale_records": len(stale),
        "selection_size": len(selected),
        "confirmed_current": counts["confirmed_current"],
        "fact_review_pending": len(selected) - counts["confirmed_current"],
        "remaining_outside_wave": len(stale) - len(selected),
        "policy": "DataProject/operations/freshness-review-policy.json",
        "selection_method": "Published records first, then high-intent entity type and source reachability. Reachability is never treated as factual verification.",
        "status_counts": dict(sorted(counts.items())),
        "records": selected,
    }
    OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Freshness review wave 1",
        "",
        f"As of {AS_OF}. Baseline stale inventory: **{len(stale)}**. Selected: **50**. Confirmed by field-level review: **{counts['confirmed_current']}**. Pending: **{len(selected) - counts['confirmed_current']}**.",
        "",
        "> A reachable URL is not factual confirmation. Pending rows retain their stale status until a reviewer records the source, date, reviewer and confirmed fields.",
        "",
        "| # | Entity | Type | Status | Source |",
        "|---:|---|---|---|---|",
    ]
    for row in selected:
        source = row["source_url"] or "—"
        link = f"[source]({source})" if source.startswith("http") else "—"
        lines.append(f"| {row['rank']} | `{row['entity_id']}` | {row['entity_type']} | {row['status']} | {link} |")
    OUTPUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps(payload | {"records": "omitted"}, indent=2))


if __name__ == "__main__":
    main()
