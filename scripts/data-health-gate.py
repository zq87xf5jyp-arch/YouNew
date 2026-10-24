#!/usr/bin/env python3
"""Fail CI when generated DATA PROJECT health evidence is incomplete or unhealthy."""

import argparse
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "DataProject" / "reports" / "data-health.json"
PUBLIC_EXCLUSIONS = ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-freshness-exclusions.json"
PUBLIC_CONTENT = ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-content.json"
PUBLIC_PROVENANCE = ROOT / "admin-dashboard" / "public-site" / "public" / "data" / "content-provenance.json"
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


def load_json(path: Path, label: str) -> dict:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"{label} is unavailable or invalid: {error}")
    if not isinstance(payload, dict):
        fail(f"{label} root must be an object")
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
    parser.add_argument(
        "--public-safe",
        action="store_true",
        help="Accept source freshness debt only when every stale record is explicitly excluded from the public artifact.",
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

    if calculated_total and not args.public_safe:
        details = ", ".join(f"{key}={value}" for key, value in issues.items() if value)
        fail(details)

    excluded_count = 0
    if args.public_safe:
        non_freshness_issues = {key: value for key, value in issues.items() if key != "outdated_records" and value}
        if non_freshness_issues:
            fail("public-safe mode cannot waive non-freshness issues: " + ", ".join(f"{key}={value}" for key, value in non_freshness_issues.items()))
        exclusions = load_json(PUBLIC_EXCLUSIONS, "public freshness exclusions")
        content = load_json(PUBLIC_CONTENT, "filtered public content")
        provenance = load_json(PUBLIC_PROVENANCE, "public content provenance")
        records = exclusions.get("records")
        if exclusions.get("schemaVersion") != 1 or exclusions.get("policy") != "fail_closed_until_field_level_reverification" or not isinstance(records, list):
            fail("public freshness exclusion contract is invalid")
        excluded_ids = [record.get("id") for record in records if isinstance(record, dict)]
        if len(excluded_ids) != len(records) or len(set(excluded_ids)) != exclusions.get("count"):
            fail("public freshness exclusions are incomplete or duplicated")
        excluded_count = len(excluded_ids)
        # The production deny-list may intentionally be stricter than the
        # current freshness report while a newly reverified release is still
        # awaiting human acceptance.  It must never be smaller: that would let
        # stale records escape the fail-closed boundary.  Equality resumes
        # when the accepted release and its public exclusions are promoted
        # together.
        if issues["outdated_records"] > excluded_count:
            fail("outdated source count exceeds fail-closed public exclusions")
        public_ids = {record.get("id") for record in content.get("entities", []) if isinstance(record, dict)}
        if public_ids.intersection(excluded_ids):
            fail("a freshness-excluded record is still present in public content")
        counts = provenance.get("counts") or {}
        if counts.get("acceptedRecords") != len(public_ids) or counts.get("freshnessExcludedRecords") != excluded_count or counts.get("sourceRecords") != len(public_ids) + excluded_count:
            fail("public provenance does not exactly partition accepted and freshness-excluded records")

    print("Data Health gate passed" if not args.public_safe else "Public publication health gate passed")
    print(f"- Structural issues: {calculated_total if not args.public_safe else calculated_total - issues['outdated_records']}")
    if args.public_safe:
        print(f"- Source freshness debt safely excluded from public output: {excluded_count}")
        guarded_candidates = excluded_count - issues["outdated_records"]
        if guarded_candidates:
            print(f"- Reverified candidates still guarded pending release acceptance: {guarded_candidates}")
    print(f"- Link evidence: {link_check['total']} URLs, {link_check['confirmed_broken']} confirmed broken")
    if args.require_network:
        print(f"- Network evidence checked at: {checked_at.isoformat()}")


if __name__ == "__main__":
    main()
