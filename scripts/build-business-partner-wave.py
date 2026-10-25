#!/usr/bin/env python3
"""Build a bounded 30-account prospecting list from governed public sources."""

import csv
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "admin-dashboard/public-site/src/generated/public-content.json"
BASELINE = ROOT / "DataProject/operations/source-monitor-baseline.json"
OUTPUT_JSON = ROOT / "DataProject/research/business-partners-wave-1.json"
OUTPUT_CSV = ROOT / "DataProject/research/business-partners-wave-1.csv"
OUTPUT_MD = ROOT / "DataProject/research/business-partners-wave-1.md"

SEGMENTS = {
    "restaurants": [
        "restaurant.bak", "restaurant.bougainville", "restaurant.caf-restaurant-amsterdam", "restaurant.choux", "restaurant.de-plantage",
        "restaurant.jansz", "restaurant.moeders", "restaurant.pesca", "restaurant.restaurant-de-kas", "restaurant.rijks",
    ],
    "shops_and_cafes": [
        "cafe.back-to-black", "cafe.bakers-and-roasters", "cafe.bocca-coffee", "cafe.caf-de-jaren", "cafe.de-koffiesalon",
        "cafe.fuku-friedhats", "cafe.koffie-academie", "cafe.lot-sixty-one-coffee-roasters", "cafe.pluk-amsterdam", "cafe.white-label-coffee",
    ],
    "local_services": [
        "local_partner.citizenm-amsterdam-south", "local_partner.everaert-advocaten", "local_partner.funda", "local_partner.ikea-amsterdam", "local_partner.ing-group",
        "local_partner.macbike-amsterdam", "local_partner.tca-taxi-amsterdam", "local_partner.uva-talen", "local_partner.van-der-valk-hotel-amsterdam-amstel", "place.de-hallen-amsterdam",
    ],
}

FIT = {
    "restaurants": "Newcomers look for clear location, booking and cuisine information.",
    "shops_and_cafes": "A reviewed local profile can make a public-facing venue easier to understand and find.",
    "local_services": "The service is relevant to settlement, mobility, housing, language learning or everyday life.",
}


def main() -> None:
    content = json.loads(CONTENT.read_text(encoding="utf-8"))
    entities = {row["id"]: row for row in content["entities"]}
    baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
    sources = {row["entity_id"]: row for row in baseline["sources"]}
    rows = []
    for segment, ids in SEGMENTS.items():
        for entity_id in ids:
            entity = entities.get(entity_id)
            source = sources.get(entity_id)
            if not entity or not source:
                raise SystemExit(f"Missing governed prospect evidence for {entity_id}")
            if source["outcome"] not in {"reachable", "redirected"}:
                raise SystemExit(f"Public business channel is not currently reachable for {entity_id}: {source['outcome']}")
            rows.append({
                "account_name": entity["title"],
                "entity_id": entity_id,
                "segment": segment,
                "city": entity.get("cityId") or "amsterdam",
                "public_business_channel": source["url"],
                "channel_type": "official_website_or_public_contact_page",
                "source_outcome": source["outcome"],
                "source_checked_at": source["checked_at"],
                "fit_hypothesis": FIT[segment],
                "outreach_status": "not_contacted",
                "personal_contact_collected": False,
            })
    if len(rows) != 30:
        raise SystemExit(f"Expected 30 prospects, built {len(rows)}")

    payload = {
        "schema_version": 1,
        "generated_at": "2026-10-23",
        "scope": "Thirty Amsterdam-area accounts selected from the current governed YouNew catalogue; this is a bounded launch list, not an exhaustive Dutch market search.",
        "contact_policy": "Only official public business web channels are stored. No personal email addresses were collected and no outreach was sent.",
        "verification_note": "Source outcome records URL availability only; it does not confirm commercial interest or every business fact.",
        "counts": {"total": len(rows), **{segment: len(ids) for segment, ids in SEGMENTS.items()}},
        "prospects": rows,
    }
    OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with OUTPUT_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=rows[0].keys())
        writer.writeheader(); writer.writerows(rows)

    lines = [
        "# First 30 potential YouNew business partners",
        "",
        "**Status:** research only; no messages sent. **Coverage:** Amsterdam-area accounts already present in the governed YouNew catalogue. **Privacy:** official public business channels only; no personal addresses collected.",
        "",
        "The three launch propositions are: restaurants (reviewed location, cuisine and booking route), shops/cafés (reviewed venue and service facts), and local services (reviewed service area, contact route and relevant conditions). The initial profile review is free; no paid organic ranking is offered.",
        "",
        "| # | Account | Segment | Public business channel | Check | Outreach |",
        "|---:|---|---|---|---|---|",
    ]
    for index, row in enumerate(rows, start=1):
        lines.append(f"| {index} | {row['account_name']} | {row['segment'].replace('_', ' ')} | [official site]({row['public_business_channel']}) | {row['source_outcome']} · 2026-10-23 | not contacted |")
    lines.extend([
        "",
        "## Recommended sequence",
        "",
        "1. Invite a small batch of five organizations to review their existing public profile.",
        "2. Ask for one concrete correction or confirmation, not a sales commitment.",
        "3. Offer the free profile review form and record registration source with UTM parameters.",
        "4. Measure completed profile requests and verified corrections before testing any paid offer.",
    ])
    OUTPUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Built {len(rows)} public-channel prospects: {OUTPUT_JSON}")


if __name__ == "__main__":
    main()
