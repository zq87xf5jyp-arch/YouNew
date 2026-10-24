#!/usr/bin/env python3
"""Build the Phase 5 manual contact-channel review queue without outreach."""

from __future__ import annotations

import csv
import json
from io import StringIO
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "DataProject/research/business-partner-verification-wave-1.json"
OUTPUT_BASE = ROOT / "DataProject/research/phase5-contact-channel-review"
REVIEW_DATE = "2026-10-24"
PURPOSE_CONTEXT_NAMES = {"Bocca Coffee", "TCA Taxi Amsterdam", "De Hallen Amsterdam"}


def write(path: Path, value: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding="utf-8")


def main() -> int:
    source = json.loads(SOURCE.read_text(encoding="utf-8"))
    candidates = [
        prospect for prospect in source["prospects"]
        if prospect.get("permitted_first_action") == "manual_channel_and_legal_review_before_any_contact"
    ]
    rows = []
    for prospect in candidates:
        purpose_context = prospect["account_name"] in PURPOSE_CONTEXT_NAMES
        rows.append(
            {
                "account_name": prospect["account_name"],
                "entity_id": prospect["entity_id"],
                "segment": prospect["segment"],
                "official_source_url": prospect["official_source_final_url"],
                "public_routes": prospect["public_contact_routes"],
                "route_assessment": (
                    "specific_business_or_partnership_context_observed_requires_manual_terms_and_purpose_review"
                    if purpose_context else "general_contact_route_only_not_marketing_permission"
                ),
                "permitted_now": "inbound_only_no_outreach",
                "legal_basis_status": "not_established",
                "contact_readiness": "hold_do_not_contact",
                "reviewed_at": REVIEW_DATE,
                "next_evidence_required": (
                    "Human reviewer must confirm that the exact published route expressly invites this type of proposal and record the applicable terms, purpose and objection mechanism."
                    if purpose_context else
                    "Prior consent or a route consciously published for receiving this specific commercial proposal; a general contact page is insufficient."
                ),
                "message_sent": False,
                "personal_contact_collected": False,
            }
        )

    payload = {
        "schema_version": 1,
        "reviewed_at": REVIEW_DATE,
        "scope": "Fourteen Phase 4 prospects waiting for channel/legal assessment",
        "legal_note": "Operational risk classification, not legal advice.",
        "authoritative_references": [
            "https://autoriteitpersoonsgegevens.nl/en/themes/internet-and-smart-devices/advertising/digital-direct-marketing",
            "https://autoriteitpersoonsgegevens.nl/nl/onderwerpen/internet-telefoon-tv-en-post/direct-marketing",
            "https://www.acm.nl/nl/verkoop-aan-consumenten/reclame-en-verleiden/spam-voorkomen-uw-reclame",
            "https://wetten.overheid.nl/BWBR0009950/#Hoofdstuk11_Artikel11.7",
        ],
        "summary": {
            "reviewed": len(rows),
            "ready_for_lawful_first_contact": 0,
            "specific_purpose_context_requires_human_validation": sum(
                row["account_name"] in PURPOSE_CONTEXT_NAMES for row in rows
            ),
            "general_contact_only": sum(row["account_name"] not in PURPOSE_CONTEXT_NAMES for row in rows),
            "messages_sent": 0,
            "personal_contacts_collected": 0,
        },
        "records": rows,
    }
    write(OUTPUT_BASE.with_suffix(".json"), json.dumps(payload, ensure_ascii=False, indent=2) + "\n")

    buffer = StringIO()
    writer = csv.DictWriter(buffer, fieldnames=[
        "account_name", "entity_id", "segment", "official_source_url", "public_routes",
        "route_assessment", "permitted_now", "legal_basis_status", "contact_readiness",
        "reviewed_at", "next_evidence_required", "message_sent", "personal_contact_collected",
    ])
    writer.writeheader()
    for row in rows:
        writer.writerow({**row, "public_routes": " | ".join(row["public_routes"])})
    write(OUTPUT_BASE.with_suffix(".csv"), buffer.getvalue())

    lines = [
        "# Phase 5 contact-channel review",
        "",
        f"Review date: {REVIEW_DATE}. Operational classification, not legal advice.",
        "",
        "## Result",
        "",
        f"- Reviewed: **{len(rows)}**",
        "- Ready for lawful first contact now: **0**",
        f"- Specific business/partnership context observed, still requiring human terms/purpose review: **{payload['summary']['specific_purpose_context_requires_human_validation']}**",
        f"- General contact route only: **{payload['summary']['general_contact_only']}**",
        "- Messages sent / personal contacts collected: **0 / 0**",
        "",
        "A public contact form or address is not treated as permission. Digital commercial contact remains on hold until prior consent or an exact purpose-published route is evidenced. Inbound registrations and organic distribution remain allowed.",
        "",
        "## Queue",
        "",
        "| Company | Segment | Assessment | Permitted now |",
        "|---|---|---|---|",
    ]
    for row in rows:
        lines.append(
            f"| {row['account_name']} | {row['segment']} | {row['route_assessment']} | {row['permitted_now']} |"
        )
    lines.extend(
        [
            "",
            "## Sources",
            "",
            "- Autoriteit Persoonsgegevens: digital direct marketing, including company-addressed marketing and prior-consent rule.",
            "- ACM: spam prevention and consent requirements.",
            "- Telecommunicatiewet article 11.7.",
            "",
        ]
    )
    write(OUTPUT_BASE.with_suffix(".md"), "\n".join(lines))
    print(f"Built contact-channel review: {len(rows)} reviewed, 0 ready, 0 sent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
