#!/usr/bin/env python3
"""Reference policy for YouNew content governance.

The module is deterministic and side-effect free. Clients may recompute a
downgrade from timestamps at display time, but they must never upgrade a record
without a new human verification event.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any


EXCLUDED_AI_STATUSES = {"archived", "disputed", "source_unavailable", "unverified"}
PRIMARY_AI_STATUSES = {"verified", "review_due_soon"}
SECONDARY_AI_STATUSES = {"overdue"}


def parse_instant(value: Any) -> datetime | None:
    if not isinstance(value, str) or not value.strip():
        return None
    normalized = value.strip().replace("Z", "+00:00")
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def review_due_lead_days(review_interval_days: Any) -> int:
    try:
        interval = max(1, int(review_interval_days))
    except (TypeError, ValueError):
        interval = 90
    return max(1, min(14, int(interval * 0.25)))


def effective_status(record: dict[str, Any], now: datetime | None = None) -> str:
    evaluated_at = (now or datetime.now(timezone.utc)).astimezone(timezone.utc)
    declared = str(record.get("verificationStatus") or "unverified")
    publication = str(record.get("publicationStatus") or "draft")

    if publication == "archived" or declared == "archived":
        return "archived"
    if declared == "disputed":
        return "disputed"
    if declared == "source_unavailable":
        return "source_unavailable"

    official_source = str(record.get("officialSourceURL") or "").strip()
    verified_at = parse_instant(record.get("lastVerifiedAt"))
    if declared == "unverified" or not official_source.startswith("https://") or verified_at is None:
        return "unverified"

    validity_start = parse_instant(record.get("validityStart"))
    validity_end = parse_instant(record.get("validityEnd"))
    next_review_at = parse_instant(record.get("nextReviewAt"))
    if validity_start and evaluated_at < validity_start:
        return "unverified"
    if declared == "overdue" or (validity_end and evaluated_at > validity_end):
        return "overdue"
    if next_review_at and evaluated_at > next_review_at:
        return "overdue"

    if declared == "review_due_soon":
        return "review_due_soon"
    if next_review_at:
        lead = timedelta(days=review_due_lead_days(record.get("reviewIntervalDays")))
        if evaluated_at >= next_review_at - lead:
            return "review_due_soon"
    return "verified"


def confidence_breakdown(record: dict[str, Any], now: datetime | None = None) -> dict[str, int]:
    stored = record.get("confidenceBreakdown")
    allowed = {
        "officialSource": {0, 40},
        "humanReviewer": {0, 20},
        "independentReview": {0, 15},
        "freshness": {0, 10},
        "jurisdictionApplicability": {0, 15},
    }
    if isinstance(stored, dict) and all(stored.get(key) in values for key, values in allowed.items()):
        return {key: int(stored[key]) for key in allowed}

    status = effective_status(record, now)
    current_reviewer = str(record.get("reviewedBy") or "").strip()
    history = {
        str(value).strip()
        for value in record.get("reviewerHistory", [])
        if isinstance(value, str) and str(value).strip()
    }
    independent = bool(current_reviewer and any(value != current_reviewer for value in history))
    jurisdiction = record.get("jurisdiction") if isinstance(record.get("jurisdiction"), dict) else {}
    return {
        "officialSource": 40 if str(record.get("officialSourceURL") or "").startswith("https://") else 0,
        "humanReviewer": 20 if current_reviewer else 0,
        "independentReview": 15 if independent else 0,
        "freshness": 10 if status in PRIMARY_AI_STATUSES else 0,
        "jurisdictionApplicability": 15 if jurisdiction.get("applicabilityVerified") is True else 0,
    }


def confidence_score(record: dict[str, Any], now: datetime | None = None) -> int:
    return sum(confidence_breakdown(record, now).values())


def ai_eligibility(record: dict[str, Any], now: datetime | None = None) -> str:
    status = effective_status(record, now)
    if status in EXCLUDED_AI_STATUSES:
        return "excluded"
    if status in SECONDARY_AI_STATUSES:
        return "secondary_only"
    return "primary"


def rank_retrieval_candidates(
    records: list[dict[str, Any]],
    municipality: str | None,
    now: datetime | None = None,
) -> dict[str, Any]:
    """Apply the deterministic governed retrieval policy without model reasoning."""

    evaluated_at = (now or datetime.now(timezone.utc)).astimezone(timezone.utc)
    requested = (municipality or "").strip().casefold()
    primary: list[tuple[tuple[Any, ...], dict[str, Any]]] = []
    secondary: list[tuple[tuple[Any, ...], dict[str, Any]]] = []
    excluded_reasons: dict[str, int] = {}

    def exclude(reason: str) -> None:
        excluded_reasons[reason] = excluded_reasons.get(reason, 0) + 1

    for record in records:
        jurisdiction = record.get("jurisdiction") if isinstance(record.get("jurisdiction"), dict) else {}
        municipality_dependent = jurisdiction.get("municipalityDependent") is True
        candidate_municipalities = {
            str(jurisdiction.get("municipalityCode") or "").strip().casefold(),
            str(jurisdiction.get("municipalityName") or "").strip().casefold(),
        } - {""}
        if municipality_dependent and (not requested or requested not in candidate_municipalities):
            exclude("wrong_municipality")
            continue

        eligibility = ai_eligibility(record, evaluated_at)
        if eligibility == "excluded":
            exclude(effective_status(record, evaluated_at))
            continue

        jurisdiction_rank = 2 if municipality_dependent else (
            1
            if jurisdiction.get("applicabilityVerified") is True
            and jurisdiction.get("level") == "national"
            else 0
        )
        breakdown = record.get("confidenceBreakdown") if isinstance(record.get("confidenceBreakdown"), dict) else {}
        official_rank = 1 if breakdown.get("officialSource") == 40 else 0
        verified_at = parse_instant(record.get("lastVerifiedAt"))
        freshness_rank = verified_at.timestamp() if verified_at else 0
        score_rank = confidence_score(record, evaluated_at)
        stable_id = str(record.get("id") or "")
        rank = (-jurisdiction_rank, -official_rank, -freshness_rank, -score_rank, stable_id)
        target = secondary if eligibility == "secondary_only" else primary
        target.append((rank, record))

    return {
        "primary": [record for _, record in sorted(primary, key=lambda item: item[0])],
        "secondary": [record for _, record in sorted(secondary, key=lambda item: item[0])],
        "excludedCandidateReasons": dict(sorted(excluded_reasons.items())),
        "policyVersion": "retrieval-policy-v1",
    }
