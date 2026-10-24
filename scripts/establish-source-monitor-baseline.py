#!/usr/bin/env python3
"""Create a URL-monitoring baseline from the reviewed link-check receipt.

This establishes change detection only. It deliberately does not mark record facts
as verified and never writes to governed content records.
"""

import argparse
import json
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ATTEMPTS = ROOT / "DataProject/reports/source-check-attempts.json"
OUTPUT = ROOT / "DataProject/operations/source-monitor-baseline.json"
EXPECTED_RECORDS = 454
OUTCOME_RANK = {"reachable": 0, "redirected": 1, "restricted": 2, "transient_failure": 3}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="Replace the baseline after validation.")
    args = parser.parse_args()

    report = json.loads(ATTEMPTS.read_text(encoding="utf-8"))
    by_record = defaultdict(list)
    for attempt in report.get("attempts", []):
        key = attempt.get("recordKey")
        if key:
            by_record[key].append(attempt)

    if len(by_record) != EXPECTED_RECORDS:
        raise SystemExit(
            f"Refusing partial baseline: expected {EXPECTED_RECORDS} record keys, found {len(by_record)}"
        )

    sources = []
    for entity_id, attempts in sorted(by_record.items()):
        attempts.sort(
            key=lambda row: (
                0 if "official_source.url" in (row.get("location") or "") else 1,
                OUTCOME_RANK.get(row.get("outcome"), 99),
                row.get("url") or "",
            )
        )
        selected = attempts[0]
        sources.append(
            {
                "entity_id": entity_id,
                "url": selected.get("finalURL") or selected.get("url"),
                "original_url": selected.get("url"),
                "outcome": selected.get("outcome"),
                "http_status": selected.get("httpStatus"),
                "checked_at": selected.get("checkedAt"),
            }
        )

    payload = {
        "schema_version": 1,
        "status": "established",
        "checked_at": report.get("checkedAt"),
        "scope": "Canonical URL change detection; this is not factual verification.",
        "source_report": "DataProject/reports/source-check-attempts.json",
        "sources": sources,
        "note": "A reachable URL proves availability only. Factual status remains pending until a reviewer confirms named fields.",
    }

    if not args.write:
        print(json.dumps({"validated_records": len(sources), "would_write": str(OUTPUT)}, indent=2))
        return

    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Established URL-monitoring baseline for {len(sources)} records at {OUTPUT}")


if __name__ == "__main__":
    main()
