#!/usr/bin/env python3
"""Build the non-publishable BRP + Amsterdam governed vertical candidate."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json"
OUTPUT = ROOT / "DataProject/staging/brp-amsterdam-governance-candidate.json"
GENERATED_AT = "2026-07-30T12:00:00Z"
FACT_IDS = ("REG-001", "REG-002", "REG-003", "REG-004", "REG-005", "REG-008", "REG-009")
SOURCE_IDS = ("src.gov.brp-resident", "src.nww.rni-register", "src.amsterdam.first-registration")


def fail(message: str) -> None:
    raise SystemExit(f"BRP governance candidate generation failed: {message}")


def by_id(items: list[dict[str, Any]], label: str) -> dict[str, dict[str, Any]]:
    mapped = {str(item.get("id")): item for item in items}
    if len(mapped) != len(items):
        fail(f"{label} contains duplicate IDs")
    return mapped


def generate() -> dict[str, Any]:
    source_bytes = SOURCE.read_bytes()
    packet = json.loads(source_bytes)
    facts = by_id(packet.get("facts", []), "facts")
    sources = by_id(packet.get("sources", []), "sources")

    missing_facts = [fact_id for fact_id in FACT_IDS if fact_id not in facts]
    missing_sources = [source_id for source_id in SOURCE_IDS if source_id not in sources]
    if missing_facts or missing_sources:
        fail(f"missing facts={missing_facts}, sources={missing_sources}")

    selected_facts = [facts[fact_id] for fact_id in FACT_IDS]
    selected_sources = [sources[source_id] for source_id in SOURCE_IDS]
    if any(fact.get("fact_status") != "sourced_research_draft" for fact in selected_facts):
        fail("selected fact escaped sourced_research_draft state")
    if any(source.get("verification_status") != "verified_opened" for source in selected_sources):
        fail("selected source is not an opened official-source research record")

    source_digest = f"sha256:{hashlib.sha256(source_bytes).hexdigest()}"
    confidence_breakdown = {
        "officialSource": 40,
        "humanReviewer": 0,
        "independentReview": 0,
        "freshness": 0,
        "jurisdictionApplicability": 0,
    }
    governance = {
        "id": "guide.registering-at-a-municipality",
        "title": "Registering at a municipality — BRP + Amsterdam candidate",
        "contentType": "practical_guide",
        "jurisdiction": {
            "countryCode": "NL",
            "level": "mixed",
            "municipalityDependent": True,
            "applicabilityVerified": False,
            "provinceCode": "PV27",
            "provinceName": "Noord-Holland",
            "municipalityCode": "GM0363",
            "municipalityName": "Amsterdam",
        },
        "officialSourceURL": sources["src.gov.brp-resident"]["url"],
        "sourceTitle": sources["src.gov.brp-resident"]["title"],
        "sourcePublisher": sources["src.gov.brp-resident"]["publisher"],
        "lastVerifiedAt": None,
        "nextReviewAt": None,
        "reviewIntervalDays": 30,
        "contentOwner": None,
        "reviewedBy": None,
        "verificationStatus": "unverified",
        "confidenceLevel": "low",
        "validityStart": None,
        "validityEnd": None,
        "changeNotes": "Mechanical migration of existing sourced research into a governed review candidate; no publication authority.",
        "version": 1,
        "updatedAt": GENERATED_AT,
        "publicationStatus": "draft",
        "reviewState": "needs_review",
        "criticality": "critical",
        "contentOrigin": "migrated",
        "originReference": str(SOURCE.relative_to(ROOT)),
        "originCapturedAt": GENERATED_AT,
        "originArtifactDigest": source_digest,
        "confidenceScore": sum(confidence_breakdown.values()),
        "confidenceScoreVersion": 1,
        "confidenceBreakdown": confidence_breakdown,
    }

    return {
        "schemaVersion": 1,
        "candidateID": "brp-amsterdam-governance-v1",
        "status": "draft",
        "publicationAuthorized": False,
        "generatedAt": GENERATED_AT,
        "transformation": {
            "identifier": "brp-amsterdam-governance-projection-v1",
            "actorType": "service",
            "parentVersion": 0,
            "timestamp": GENERATED_AT,
            "sourceArtifact": str(SOURCE.relative_to(ROOT)),
            "sourceArtifactDigest": source_digest,
        },
        "governance": governance,
        "sourceEntityIDs": [
            "government.brp-registration",
            "government.rni-registration",
            "government_service.first-registration-in-amsterdam",
        ],
        "sourceCitations": selected_sources,
        "nationalFacts": [fact for fact in selected_facts if fact["jurisdiction"] == "national"],
        "municipalityVariations": {
            "Amsterdam": [fact for fact in selected_facts if fact["jurisdiction"] == "municipal:amsterdam"]
        },
        "publicationBlockers": [
            "Separate human review event is absent.",
            "Server-side publication approval is absent.",
            "Jurisdiction applicability evidence is not approved in the new workflow.",
            "Freshness evidence has not been re-established under the governance contract.",
            "User Outcome Gate has not run.",
        ],
    }


def main() -> int:
    payload = generate()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Generated non-publishable BRP + Amsterdam candidate: {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
