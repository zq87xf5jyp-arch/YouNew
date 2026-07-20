#!/usr/bin/env python3
"""Fail CI when generated DATA PROJECT health evidence is incomplete or unhealthy."""

import argparse
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "DataProject" / "reports" / "data-health.json"
REQUIRED_ISSUES = {
    "governed_broken_links",
    "legacy_runtime_broken_links",
    "expired_events",
    "missing_media",
    "duplicates",
    "unverified_sources",
    "missing_last_checked",
    "missing_coordinates",
    "missing_ai_summary",
    "outdated_records",
}
REQUIRED_LINK_FIELDS = {
    "checked_at",
    "total",
    "reachable",
    "confirmed_broken",
    "access_restricted",
    "transient_failures",
}


def fail(message: str) -> None:
    print(f"Data Health gate failed: {message}")
    raise SystemExit(1)


def load_report() -> dict:
    try:
        payload = json.loads(REPORT.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"{REPORT.relative_to(ROOT)} is unavailable or invalid: {error}")
    if not isinstance(payload, dict):
        fail("report root must be an object")
    return payload


def parse_timestamp(value, label: str) -> datetime:
    try:
        timestamp = datetime.fromisoformat(value)
    except (TypeError, ValueError):
        fail(f"{label} must be an ISO-8601 timestamp")
    if timestamp.tzinfo is None:
        fail(f"{label} must include a timezone")
    return timestamp.astimezone(timezone.utc)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--require-network",
        action="store_true",
        help="Require link evidence generated within the last 36 hours.",
    )
    args = parser.parse_args()

    report = load_report()
    issues = report.get("issues")
    if not isinstance(issues, dict) or set(issues) != REQUIRED_ISSUES:
        fail("issue inventory must contain every required Data Health check exactly once")
    if any(not isinstance(value, int) or value < 0 for value in issues.values()):
        fail("issue counts must be non-negative integers")

    calculated_total = sum(issues.values())
    if report.get("issues_total") != calculated_total:
        fail("issues_total does not match the issue inventory")
    expected_status = "healthy" if calculated_total == 0 else "attention_required"
    if report.get("status") != expected_status:
        fail(f"status must be {expected_status} for {calculated_total} issue(s)")

    link_check = report.get("link_check")
    if not isinstance(link_check, dict) or set(link_check) != REQUIRED_LINK_FIELDS:
        fail("link_check evidence is incomplete")
    for field in REQUIRED_LINK_FIELDS - {"checked_at"}:
        if not isinstance(link_check[field], int) or link_check[field] < 0:
            fail(f"link_check.{field} must be a non-negative integer")
    classified = (
        link_check["reachable"]
        + link_check["confirmed_broken"]
        + link_check["access_restricted"]
        + link_check["transient_failures"]
    )
    if classified != link_check["total"]:
        fail("link-check classifications do not add up to total")
    if link_check["confirmed_broken"] != issues["governed_broken_links"] + issues["legacy_runtime_broken_links"]:
        fail("confirmed broken links do not match Data Health issue counts")

    checked_at = parse_timestamp(link_check["checked_at"], "link_check.checked_at")
    if args.require_network:
        age = datetime.now(timezone.utc) - checked_at
        if age < timedelta(minutes=-5) or age > timedelta(hours=36):
            fail(f"network evidence is stale or future-dated ({checked_at.isoformat()})")
        if link_check["total"] == 0:
            fail("network audit did not inspect any URLs")

    if calculated_total:
        details = ", ".join(f"{key}={value}" for key, value in issues.items() if value)
        fail(details)

    print("Data Health gate passed")
    print(f"- Structural issues: {calculated_total}")
    print(f"- Link evidence: {link_check['total']} URLs, {link_check['confirmed_broken']} confirmed broken")
    if args.require_network:
        print(f"- Network evidence checked at: {checked_at.isoformat()}")


if __name__ == "__main__":
    main()
