#!/usr/bin/env python3
"""Generate source-backed DATA PROJECT dashboard and health artifacts."""

import json
import re
from collections import Counter, defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import urlsplit

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
REPORTS = PROJECT / "reports"
ADMIN_GENERATED = ROOT / "admin-dashboard" / "src" / "generated"
REQUIRED_RECORD_FIELDS = {
    "id", "entity_type", "category", "city_id", "province_id", "coordinates",
    "title", "description", "images", "official_source", "website",
    "related_entity_ids", "last_checked", "verification_status", "ai_summary",
    "review_frequency_days", "search_keywords", "lifecycle_status",
}
GEO_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner", "healthcare", "education", "transport"}
REQUIRED_MEDIA_ROLES = {"hero", "gallery", "thumbnail", "map_preview"}
MEDIA_REQUIRED_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner"}
QUALITY_WEIGHTS = {
    "completeness": 20,
    "verification": 20,
    "source": 20,
    "media": 15,
    "geography": 10,
    "search": 10,
    "ai": 5,
}

# Offline static QA validates governed records without pretending that a network
# audit ran. A scheduled/network job replaces this sentinel by running
# check-external-links.py first; data-health-gate.py --require-network rejects the
# sentinel because it is stale and contains zero inspected URLs.
OFFLINE_LINK_EVIDENCE = {
    "schemaVersion": 2,
    "checkedAt": "1970-01-01T00:00:00+00:00",
    "totalURLs": 0,
    "reachableURLs": 0,
    "confirmedBrokenURLs": 0,
    "accessRestrictedURLs": 0,
    "transientFailures": 0,
    "confirmedBroken": [],
}


def load_json(path: Path, fallback):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return fallback


def is_https(value) -> bool:
    if not isinstance(value, str):
        return False
    parsed = urlsplit(value)
    return parsed.scheme == "https" and bool(parsed.netloc)


def parse_date(value):
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError):
        return None


def normalized(value) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", str(value).casefold()))


def release_sort_key(release):
    version = tuple(int(part) for part in str(release.get("version") or "0.0.0").split("."))
    published_at = release.get("publication_timestamp") or release.get("published_at") or ""
    return published_at, version


def load_batches():
    rows = []
    batch_count = len(list((PROJECT / "batches").glob("**/*.json")))
    try:
        release_ids = effective_release_heads(PROJECT)
        effective_releases = [resolve_release(PROJECT, release_id) for release_id in release_ids]
    except EffectiveReleaseError as error:
        raise SystemExit(f"Data dashboard failed: effective release resolution failed: {error}") from error
    for effective in effective_releases:
        source_label = ", ".join(str(path.relative_to(ROOT)) for path in effective.input_paths)
        for record in effective.records:
            enriched = dict(record)
            enriched["_work_package"] = effective.release.get("work_package")
            enriched["_milestone"] = effective.release.get("milestone")
            enriched["_target_release"] = effective.release_id
            enriched["_batch"] = source_label
            rows.append(enriched)
    return batch_count, rows


def media_ready(record) -> bool:
    images = record.get("images")
    if not isinstance(images, list):
        return False
    if record.get("entity_type") not in MEDIA_REQUIRED_TYPES:
        return all(
            isinstance(image, dict)
            and image.get("verified") is True
            and is_https(image.get("source_page_url"))
            and is_https(image.get("asset_url"))
            and image.get("license")
            and image.get("attribution")
            for image in images
        )
    valid_roles = {
        image.get("role") for image in images
        if isinstance(image, dict)
        and image.get("verified") is True
        and is_https(image.get("source_page_url"))
        and image.get("license")
        and image.get("attribution")
    }
    return REQUIRED_MEDIA_ROLES <= valid_roles


def source_ready(record) -> bool:
    source = record.get("official_source")
    return (
        isinstance(source, dict)
        and source.get("is_official") is True
        and source.get("status") == "verified_opened"
        and is_https(source.get("url"))
    )


def is_current(record) -> bool:
    checked = parse_date(record.get("last_checked"))
    frequency = record.get("review_frequency_days")
    return isinstance(frequency, int) and checked is not None and checked + timedelta(days=frequency) >= date.today()


def geography_ready(record) -> bool:
    if record.get("entity_type") not in GEO_TYPES:
        return True
    coordinate = record.get("coordinates")
    if not isinstance(coordinate, dict) or not record.get("province_id"):
        return False
    latitude = coordinate.get("latitude")
    longitude = coordinate.get("longitude")
    return (
        isinstance(latitude, (int, float))
        and isinstance(longitude, (int, float))
        and 50.7 <= latitude <= 53.7
        and 3.2 <= longitude <= 7.3
    )


def record_quality(record) -> float:
    checks = {
        "completeness": len(REQUIRED_RECORD_FIELDS & set(record)) / len(REQUIRED_RECORD_FIELDS),
        "verification": 1.0 if record.get("verification_status") == "verified" and is_current(record) else 0.0,
        "source": 1.0 if source_ready(record) else 0.0,
        "media": 1.0 if media_ready(record) else 0.0,
        "geography": 1.0 if geography_ready(record) else 0.0,
        "search": 1.0 if len(set(record.get("search_keywords") or [])) >= 3 else 0.0,
        "ai": 1.0 if len(str(record.get("ai_summary") or "").strip()) >= 40 else 0.0,
    }
    return round(sum(checks[key] * weight for key, weight in QUALITY_WEIGHTS.items()), 1)


def average_quality(records) -> float:
    if not records:
        return 0.0
    return round(sum(record_quality(record) for record in records) / len(records), 1)


def coverage_percent(records, predicate):
    if not records:
        return None
    return round(sum(bool(predicate(record)) for record in records) / len(records) * 100, 1)


def is_blocked(record) -> bool:
    source = record.get("official_source") or {}
    return record.get("verification_status") == "rejected" or source.get("status") in {"access_restricted", "rejected"}


def expired_event(record) -> bool:
    if record.get("entity_type") != "event":
        return False
    attributes = record.get("attributes") or {}
    active_through = parse_date(attributes.get("end_date") or attributes.get("endDate") or attributes.get("start_date") or attributes.get("startDate"))
    return active_through is None or active_through < date.today()


def duplicate_count(records) -> int:
    identities = []
    websites = []
    media_ids = []
    for record in records:
        identities.append((record.get("entity_type"), normalized(record.get("title")), record.get("city_id")))
        if record.get("website"):
            websites.append(str(record["website"]).rstrip("/").casefold())
        for image in record.get("images") or []:
            if isinstance(image, dict) and image.get("id"):
                media_ids.append(image["id"])
    return sum(count - 1 for count in Counter(identities + websites + media_ids).values() if count > 1)


def write_json(path: Path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    manifest = load_json(PROJECT / "work-packages.json", {"work_packages": []})
    release_registry = load_json(PROJECT / "releases" / "releases.json", {"runtime": {}, "releases": []})
    targets = load_json(PROJECT / "coverage-targets.json", {"targets": []})
    breadth_config = load_json(PROJECT / "coverage-dimensions.json", {"axes": []})
    runtime_health = load_json(ROOT / "knowledge_data_health.json", OFFLINE_LINK_EVIDENCE)
    confirmed_broken = runtime_health.get("confirmedBroken") or []
    governed_location_prefixes = (
        "DataProject/",
        "effective-release:",
        "YouNew/Resources/Data/younew-runtime-data.json:",
        "source_registry.json:",
        "admin-dashboard/public-site/src/generated/public-content.json:",
        "admin-dashboard/public-site/public/data/search-index.json:",
        "admin-dashboard/public-site/public/data/content-provenance.json:",
    )
    governed_broken_links = sum(
        isinstance(item, dict)
        and str(item.get("location") or "").startswith(governed_location_prefixes)
        for item in confirmed_broken
    )
    legacy_broken_links = max(int(runtime_health.get("confirmedBrokenURLs") or 0) - governed_broken_links, 0)
    batch_count, records = load_batches()
    published = [record for record in records if record.get("lifecycle_status") == "published"]
    by_package = defaultdict(list)
    for record in records:
        by_package[record.get("_work_package")].append(record)

    releases_by_wp = defaultdict(list)
    for release in release_registry.get("releases", []):
        releases_by_wp[release.get("work_package")].append(release)
    published_effective_ids = set(effective_release_heads(PROJECT, statuses={"published"}))
    pending_effective_ids = set(effective_release_heads(PROJECT, statuses={"planned", "qa"}))

    package_metrics = []
    for package in manifest.get("work_packages", []):
        package_records = by_package.get(package.get("id"), [])
        package_published = [record for record in package_records if record.get("lifecycle_status") == "published"]
        geographic_records = [record for record in package_records if record.get("entity_type") in GEO_TYPES]
        media_records = [record for record in package_records if record.get("entity_type") in MEDIA_REQUIRED_TYPES]
        package_releases = releases_by_wp.get(package.get("id"), [])
        current_candidates = [release for release in package_releases if release.get("id") in published_effective_ids]
        next_candidates = [release for release in package_releases if release.get("id") in pending_effective_ids]
        current_release = max(current_candidates, key=release_sort_key)["version"] if current_candidates else None
        next_release = max(next_candidates, key=release_sort_key)["version"] if next_candidates else None
        package_metrics.append({
            "id": package.get("id"),
            "name": package.get("name"),
            "status": package.get("status"),
            "records": len(package_records),
            "published": len(package_published),
            "verified": sum(record.get("verification_status") == "verified" for record in package_records),
            "needs_review": sum(record.get("verification_status") in {"pending", "needs_review"} for record in package_records),
            "outdated": sum(record.get("verification_status") == "outdated" or not is_current(record) for record in package_records),
            "blocked": sum(is_blocked(record) for record in package_records),
            "quality_score": average_quality(package_records),
            "coverage_dimensions": {
                "verification": coverage_percent(package_records, lambda record: record.get("verification_status") == "verified"),
                "official_source": coverage_percent(package_records, source_ready),
                "freshness": coverage_percent(package_records, is_current),
                "relationships": coverage_percent(package_records, lambda record: bool(record.get("related_entity_ids"))),
                "geography": coverage_percent(geographic_records, geography_ready),
                "media": coverage_percent(media_records, media_ready),
                "search": coverage_percent(package_records, lambda record: len(set(record.get("search_keywords") or [])) >= 3),
                "ai": coverage_percent(package_records, lambda record: len(str(record.get("ai_summary") or "").strip()) >= 40),
                "publication": coverage_percent(package_records, lambda record: record.get("lifecycle_status") == "published"),
            },
            "current_release": current_release,
            "next_release": next_release,
        })

    coverage = []
    for target in targets.get("targets", []):
        target_records = by_package.get(target.get("work_package"), [])
        if target.get("entity_types") == ["*media_assets"]:
            current = sum(len(record.get("images") or []) for record in records)
        else:
            entity_types = set(target.get("entity_types") or [])
            current = sum(record.get("entity_type") in entity_types for record in target_records)
        goal = int(target.get("target") or 0)
        coverage.append({
            "key": target.get("key"),
            "label": target.get("label"),
            "work_package": target.get("work_package"),
            "current": current,
            "target": goal,
            "coverage_percent": round((current / goal) * 100, 1) if goal else 0.0,
        })

    targets_by_key = {target.get("key"): target for target in targets.get("targets", [])}
    axes_by_key = {axis.get("key"): axis for axis in breadth_config.get("axes", [])}
    breadth_coverage = []
    for axis in breadth_config.get("axes", []):
        target = targets_by_key.get(axis.get("target_key"), {})
        required_values = axis.get("required_values")
        if required_values is None:
            required_values = axes_by_key.get(axis.get("required_values_from"), {}).get("required_values", [])
        relevant_types = set(target.get("entity_types") or [])
        axis_records = [
            record for record in by_package.get(axis.get("work_package"), [])
            if record.get("entity_type") in relevant_types
        ]
        observed = {normalized(record.get(axis.get("field"))) for record in axis_records if record.get(axis.get("field"))}
        minimum_records = int(axis.get("minimum_records_per_value", 1))
        covered = []
        missing = []
        value_counts = []
        underfilled = []
        for required in required_values:
            matches = {normalized(value) for value in required.get("match_values") or [required.get("key")]}
            count = sum(normalized(record.get(axis.get("field"))) in matches for record in axis_records)
            value = {"key": required.get("key"), "label": required.get("label"), "count": count}
            destination = covered if observed & matches else missing
            destination.append(value)
            value_counts.append(value)
            if count < minimum_records:
                underfilled.append({**value, "needed": minimum_records - count})
        target_count = len(required_values)
        depth_target = target_count * minimum_records
        depth_covered = sum(min(value["count"], minimum_records) for value in value_counts)
        breadth_coverage.append({
            "key": axis.get("key"),
            "label": axis.get("label"),
            "target_key": axis.get("target_key"),
            "dataset": target.get("label"),
            "work_package": axis.get("work_package"),
            "field": axis.get("field"),
            "covered": len(covered),
            "target": target_count,
            "coverage_percent": round(len(covered) / target_count * 100, 1) if target_count else 0.0,
            "minimum_records_per_value": minimum_records,
            "depth_covered": depth_covered,
            "depth_target": depth_target,
            "depth_coverage_percent": round(depth_covered / depth_target * 100, 1) if depth_target else 0.0,
            "value_counts": value_counts,
            "covered_values": covered,
            "missing_values": missing,
            "underfilled_values": underfilled,
        })

    health_issues = {
        "governed_broken_links": governed_broken_links,
        "legacy_runtime_broken_links": legacy_broken_links,
        "expired_events": sum(expired_event(record) for record in records),
        "missing_media": sum(not media_ready(record) for record in records),
        "duplicates": duplicate_count(records),
        "unverified_sources": sum(not source_ready(record) for record in records),
        "missing_last_checked": sum(parse_date(record.get("last_checked")) is None for record in records),
        "missing_coordinates": sum(not geography_ready(record) for record in records if record.get("entity_type") in GEO_TYPES),
        "missing_ai_summary": sum(len(str(record.get("ai_summary") or "").strip()) < 40 for record in records),
        "outdated_records": sum(record.get("verification_status") == "outdated" or not is_current(record) for record in records),
    }
    total_health_issues = sum(health_issues.values())
    health_status = "not_established" if not records else "healthy" if total_health_issues == 0 else "attention_required"
    generated_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    planned_release = next((release for release in release_registry.get("releases", []) if release.get("status") in {"planned", "qa"}), None)

    dashboard = {
        "schema_version": 1,
        "generated_at": generated_at,
        "scope": "DATA PROJECT governed records only; legacy runtime data is excluded until audited and migrated.",
        "runtime_release": release_registry.get("runtime", {}),
        "next_release": planned_release,
        "summary": {
            "batches": batch_count,
            "records": len(records),
            "published": len(published),
            "verified": sum(record.get("verification_status") == "verified" for record in records),
            "needs_review": sum(record.get("verification_status") in {"pending", "needs_review"} for record in records),
            "outdated": sum(record.get("verification_status") == "outdated" or not is_current(record) for record in records),
            "blocked": sum(is_blocked(record) for record in records),
            "media_assets": sum(len(record.get("images") or []) for record in records),
            "quality_score": average_quality(records),
        },
        "coverage": coverage,
        "breadth_coverage": breadth_coverage,
        "work_packages": package_metrics,
        "data_health": {
            "status": health_status,
            "issues_total": total_health_issues,
            "issues": health_issues,
            "link_check": {
                "checked_at": runtime_health.get("checkedAt"),
                "total": int(runtime_health.get("totalURLs") or 0),
                "reachable": int(runtime_health.get("reachableURLs") or 0),
                "confirmed_broken": int(runtime_health.get("confirmedBrokenURLs") or 0),
                "access_restricted": int(runtime_health.get("accessRestrictedURLs") or 0),
                "transient_failures": int(runtime_health.get("transientFailures") or 0),
            },
        },
    }

    write_json(REPORTS / "dashboard.json", dashboard)
    write_json(REPORTS / "data-health.json", dashboard["data_health"] | {"generated_at": generated_at})
    write_json(ADMIN_GENERATED / "data-project-dashboard.json", dashboard)

    lines = [
        "# YouNew Data Dashboard",
        "",
        f"Generated: `{generated_at}`",
        "",
        "> Counts include only governed DATA PROJECT records. Legacy runtime data remains unversioned until audited and migrated.",
        "",
        "## Release",
        "",
        f"- Runtime: `{dashboard['runtime_release'].get('release_id', 'unknown')}` / `{dashboard['runtime_release'].get('version', 'unknown')}`",
        f"- Next: `{planned_release.get('id')}` ({planned_release.get('status')})" if planned_release else "- Next: not planned",
        "",
        "## Status",
        "",
        "| Records | Published | Verified | Needs review | Outdated | Blocked | Media | Quality |",
        "| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
        f"| {len(records)} | {len(published)} | {dashboard['summary']['verified']} | {dashboard['summary']['needs_review']} | {dashboard['summary']['outdated']} | {dashboard['summary']['blocked']} | {dashboard['summary']['media_assets']} | {dashboard['summary']['quality_score']}% |",
        "",
        "## Coverage",
        "",
        "| Category | Current | Target | Coverage |",
        "| --- | ---: | ---: | ---: |",
    ]
    lines.extend(f"| {item['label']} | {item['current']} | {item['target']} | {item['coverage_percent']}% |" for item in coverage)
    lines += [
        "",
        "## Breadth coverage",
        "",
        "> Breadth measures which required topics or provinces are represented. Depth measures progress toward the configured minimum number of records inside every required value.",
        "",
        "| Dataset | Dimension | Breadth | Breadth target | Breadth | Depth | Depth target | Depth | Underfilled |",
        "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |",
    ]
    lines.extend(
        f"| {item['dataset']} | {item['label']} | {item['covered']} | {item['target']} | {item['coverage_percent']}% | {item['depth_covered']} | {item['depth_target']} | {item['depth_coverage_percent']}% | {', '.join('{} ({}/{})'.format(value['label'], value['count'], item['minimum_records_per_value']) for value in item['underfilled_values']) or '—'} |"
        for item in breadth_coverage
    )
    lines += [
        "",
        "## Work package quality",
        "",
        "| WP | Dataset | Records | Published | Quality | Current release | Next release |",
        "| --- | --- | ---: | ---: | ---: | --- | --- |",
    ]
    lines.extend(
        f"| {item['id']} | {item['name']} | {item['records']} | {item['published']} | {item['quality_score']}% | {item['current_release'] or '—'} | {item['next_release'] or '—'} |"
        for item in package_metrics
    )
    lines += [
        "",
        "## Coverage dimensions",
        "",
        "> Volume answers how much data exists. These dimensions answer how completely that data is verified, current, connected and ready for use.",
        "",
        "| WP | Verified | Official source | Fresh | Connected | Geo | Media | Search | AI | Published |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]

    def metric(value):
        return "—" if value is None else f"{value}%"

    lines.extend(
        "| {id} | {verification} | {official_source} | {freshness} | {relationships} | {geography} | {media} | {search} | {ai} | {publication} |".format(
            id=item["id"],
            **{key: metric(value) for key, value in item["coverage_dimensions"].items()},
        )
        for item in package_metrics
    )
    lines += [
        "",
        "## Data Health",
        "",
        f"Status: **{health_status}** · Issues: **{total_health_issues}**",
        f"Link check: **{dashboard['data_health']['link_check']['reachable']} reachable** / {dashboard['data_health']['link_check']['total']} total · {dashboard['data_health']['link_check']['access_restricted']} restricted · {dashboard['data_health']['link_check']['transient_failures']} transient",
        "",
    ]
    lines.extend(f"- {key.replace('_', ' ').title()}: {value}" for key, value in health_issues.items())
    (REPORTS / "dashboard.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("Data Dashboard generated")
    print(f"- Records: {len(records)} ({len(published)} published)")
    print(f"- Quality score: {dashboard['summary']['quality_score']}%")
    print(f"- Data health: {health_status} ({total_health_issues} issues)")


if __name__ == "__main__":
    main()
