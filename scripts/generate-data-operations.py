#!/usr/bin/env python3
"""Generate WP-17 operational plans without mutating canonical data."""

import hashlib
import json
import re
from collections import Counter, defaultdict
from datetime import date, datetime, timezone
from pathlib import Path

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
OPERATIONS = PROJECT / "operations"
REPORTS = PROJECT / "reports"
MEDIA_REQUIRED_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner"}
MEDIA_ROLES = {"hero", "gallery", "thumbnail", "map_preview"}
URL = re.compile(r'https?://[^\s"<>\\]+')


def load_json(path, fallback=None):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        if fallback is not None:
            return fallback
        raise


def write_json(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_date(value):
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError):
        return None


def percent(numerator, denominator):
    return round(numerator / denominator * 100, 1) if denominator else None


def canonical_input_files():
    files = [
        path for path in PROJECT.rglob("*")
        if path.is_file() and REPORTS not in path.parents
    ]
    for relative in (
        "observability.json",
        "usage-registry.json",
        "freshness-dashboard.json",
        "source-reliability.json",
        "migration-dashboard.json",
    ):
        path = REPORTS / relative
        if path.exists():
            files.append(path)
    files.extend(sorted((REPORTS / "release-manifests").glob("*.json")))
    for name in ("knowledge_data_health.json", "broken_links.csv"):
        path = ROOT / name
        if path.exists():
            files.append(path)
    return sorted(set(files))


def fingerprint():
    digest = hashlib.sha256()
    for path in canonical_input_files():
        digest.update(str(path.relative_to(ROOT)).encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def relative_source_label(value):
    """Keep effective-release ownership evidence stable across CI workspaces."""
    prefix = f"{ROOT.resolve()}/"
    return value[len(prefix):] if isinstance(value, str) and value.startswith(prefix) else value


def governed_records():
    """Resolve the current governed heads and retain per-record source ownership."""
    try:
        release_ids = effective_release_heads(PROJECT)
        effective_releases = [resolve_release(PROJECT, release_id) for release_id in release_ids]
    except EffectiveReleaseError as error:
        raise SystemExit(f"Data Operations failed: effective release resolution failed: {error}") from error

    records = []
    source_ownership = {}
    release_scope = []
    for effective in effective_releases:
        release_scope.append({
            "release_id": effective.release_id,
            "status": effective.release.get("status"),
            "work_package": effective.release.get("work_package"),
            "records": len(effective.records),
            "replacements": effective.replacement_count,
        })
        for record in effective.records:
            entity_id = record["id"]
            if entity_id in source_ownership:
                raise SystemExit(f"Data Operations failed: duplicate effective entity ID {entity_id}")
            source = relative_source_label(effective.record_sources[entity_id])
            enriched = dict(record)
            enriched["_work_package"] = effective.release.get("work_package")
            enriched["_release_id"] = effective.release_id
            enriched["_source"] = source
            records.append(enriched)
            source_ownership[entity_id] = source
    return records, release_scope, source_ownership


def record_urls(value):
    """Yield governed HTTP(S) URLs from all record fields, including media."""
    if isinstance(value, str):
        for match in URL.finditer(value):
            yield match.group(0).rstrip(".,;)]")
    elif isinstance(value, list):
        for item in value:
            yield from record_urls(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from record_urls(item)


def issue(issue_type, priority, entity_id=None, release_id=None, evidence=None, proposed_action=None):
    identity = entity_id or release_id or "project"
    return {
        "id": f"ops.{issue_type}.{identity}",
        "type": issue_type,
        "priority": priority,
        "entity_id": entity_id,
        "release_id": release_id,
        "status": "open",
        "evidence": evidence,
        "proposed_action": proposed_action,
        "approval_required": True,
        "external_issue_created": False,
    }


def build_queues(records, source_ownership, freshness, usage, release_manifests, health, baseline):
    records_by_id = {record["id"]: record for record in records}
    url_owners = defaultdict(set)
    for record in records:
        for url in record_urls(record):
            url_owners[url].add(record["id"])
    queue = []

    for row in freshness.get("entries", []):
        entity_id = row.get("entity_id")
        if entity_id in records_by_id and not row.get("compliant"):
            queue.append(issue(
                "outdated",
                "medium",
                entity_id=entity_id,
                evidence={
                    "review_due": row.get("review_due"),
                    "policy_id": row.get("policy_id"),
                    "source": source_ownership[entity_id],
                },
                proposed_action="editor_review_then_set_needs_review_if_confirmed",
            ))

    for broken in health.get("confirmedBroken", []):
        if not isinstance(broken, dict):
            continue
        for entity_id in sorted(url_owners.get(broken.get("url"), set())):
            queue.append(issue(
                "broken_link",
                "high",
                entity_id=entity_id,
                evidence={
                    "url": broken.get("url"),
                    "status": broken.get("status"),
                    "source": source_ownership[entity_id],
                },
                proposed_action="review_replacement_source",
            ))

    today = date.today()
    image_url_owner = defaultdict(list)
    for record in records:
        if record.get("entity_type") == "event":
            attributes = record.get("attributes") or {}
            end_date = parse_date(attributes.get("end_date") or attributes.get("start_date"))
            if end_date and end_date < today:
                queue.append(issue(
                    "expired_event",
                    "high",
                    entity_id=record["id"],
                    evidence={"event_end": end_date.isoformat()},
                    proposed_action="editor_review_then_archive",
                ))

        images = record.get("images") or []
        if record.get("entity_type") in MEDIA_REQUIRED_TYPES:
            roles = {image.get("role") for image in images if isinstance(image, dict)}
            if not MEDIA_ROLES <= roles:
                queue.append(issue(
                    "missing_image",
                    "medium",
                    entity_id=record["id"],
                    evidence={"missing_roles": sorted(MEDIA_ROLES - roles)},
                    proposed_action="source_and_verify_required_media",
                ))
        for image in images:
            if not isinstance(image, dict):
                continue
            asset_url = image.get("asset_url")
            if asset_url:
                image_url_owner[asset_url].append(record["id"])
            if not image.get("license") or not image.get("license_url") or not image.get("attribution"):
                queue.append(issue(
                    "missing_license",
                    "critical",
                    entity_id=record["id"],
                    evidence={"media_id": image.get("id")},
                    proposed_action="block_publication_and_review_license",
                ))

    for entry in usage.get("entries", []):
        entity_id = entry.get("entity_id")
        if entity_id in records_by_id and entry.get("orphan"):
            queue.append(issue(
                "orphan_data",
                "low",
                entity_id=entity_id,
                evidence={
                    "consumers": entry.get("consumers"),
                    "source": source_ownership[entity_id],
                },
                proposed_action="assign_consumer_or_document_intentional_orphan",
            ))

    for manifest in release_manifests:
        if manifest.get("status") == "qa" and manifest.get("qa_gates_passed") == 7:
            queue.append(issue(
                "publication_candidate",
                "medium",
                release_id=manifest.get("release_id"),
                evidence={
                    "records": manifest.get("records", {}).get("governed"),
                    "qa_gates_passed": 7,
                },
                proposed_action="request_explicit_release_approval",
            ))

    baseline_sources = {
        row.get("entity_id"): row.get("url")
        for row in baseline.get("sources", [])
        if row.get("entity_id") and row.get("url")
    }
    changed_sources = []
    if baseline.get("status") == "established":
        for entity_id, old_url in baseline_sources.items():
            record = records_by_id.get(entity_id)
            new_url = (record.get("official_source") or {}).get("url") if record else None
            if new_url and new_url != old_url:
                changed_sources.append({"entity_id": entity_id, "from": old_url, "to": new_url})
                queue.append(issue(
                    "source_changed",
                    "medium",
                    entity_id=entity_id,
                    evidence={
                        "from": old_url,
                        "to": new_url,
                        "source": source_ownership[entity_id],
                    },
                    proposed_action="review_redirect_and_update_baseline",
                ))

    unique = {}
    for item in queue:
        unique[item["id"]] = item
    queue = sorted(unique.values(), key=lambda item: (["critical", "high", "medium", "low"].index(item["priority"]), item["id"]))
    return queue, {
        "status": "measured" if baseline.get("status") == "established" else "not_established",
        "baseline_checked_at": baseline.get("checked_at"),
        "tracked_sources": len(baseline_sources),
        "changed_sources": changed_sources,
        "note": "URL change detection starts after a reviewed source baseline is established.",
    }, image_url_owner


def build_scheduler(freshness, queue):
    upcoming = Counter()
    today = date.today()
    for row in freshness.get("entries", []):
        due = parse_date(row.get("review_due"))
        if due is None:
            continue
        days = (due - today).days
        if days < 0:
            upcoming["overdue"] += 1
        elif days <= 7:
            upcoming["next_7_days"] += 1
        elif days <= 30:
            upcoming["next_30_days"] += 1
        else:
            upcoming["later"] += 1
    return {
        "status": "measured",
        "overdue": upcoming["overdue"],
        "next_7_days": upcoming["next_7_days"],
        "next_30_days": upcoming["next_30_days"],
        "later": upcoming["later"],
        "expired_events": sum(item["type"] == "expired_event" for item in queue),
        "automatic_mutations": 0,
    }


def build_analytics(events_registry):
    events = events_registry.get("events") or []
    by_consumer = Counter(event.get("consumer") for event in events)
    by_entity = Counter(event.get("entity_id") for event in events)
    return {
        "status": "measured" if events_registry.get("collection_enabled") and events else "not_established",
        "collection_enabled": events_registry.get("collection_enabled") is True,
        "events": len(events),
        "entities_used": len(by_entity),
        "by_consumer": dict(sorted(by_consumer.items())),
        "top_entities": [
            {"entity_id": entity_id, "uses": count}
            for entity_id, count in by_entity.most_common(20)
        ],
        "privacy_note": events_registry.get("privacy_note"),
    }


def weighted_dimension(work_packages, key):
    numerator = 0.0
    denominator = 0
    for package in work_packages:
        records = int(package.get("records") or 0)
        value = (package.get("coverage_dimensions") or {}).get(key)
        if records and isinstance(value, (int, float)):
            numerator += value * records
            denominator += records
    return round(numerator / denominator, 1) if denominator else None


def build_kpis(dashboard, observability):
    summary = dashboard.get("summary") or {}
    breadth = dashboard.get("breadth_coverage") or []
    work_packages = dashboard.get("work_packages") or []
    full_breadth = sum(item.get("coverage_percent") == 100 for item in breadth)
    return {
        "coverage": {
            "value": percent(full_breadth, len(breadth)),
            "definition": "Configured breadth axes at 100% / all configured breadth axes",
            "numerator": full_breadth,
            "denominator": len(breadth),
        },
        "freshness": {
            "value": observability.get("freshness", {}).get("freshness_compliance_percent"),
            "definition": "Governed records within their category-specific SLA",
        },
        "verification": {
            "value": percent(summary.get("verified", 0), summary.get("records", 0)),
            "definition": "Verified governed records / all governed records",
        },
        "publication": {
            "value": percent(summary.get("published", 0), summary.get("records", 0)),
            "definition": "Published governed records / all governed records",
        },
        "search": {
            "value": weighted_dimension(work_packages, "search"),
            "definition": "Governed records with search-ready metadata",
        },
        "ai": {
            "value": weighted_dimension(work_packages, "ai"),
            "definition": "Governed records with AI-ready summaries",
        },
        "media": {
            "value": weighted_dimension(work_packages, "media"),
            "definition": "Media-required governed records with complete verified roles",
            "status": "not_established" if weighted_dimension(work_packages, "media") is None else "measured",
        },
        "usage": {
            "value": observability.get("usage", {}).get("data_usage_coverage_percent"),
            "definition": "Published governed records used by at least one consumer",
            "status": observability.get("usage", {}).get("status"),
        },
        "source_trust": {
            "value": observability.get("source_reliability", {}).get("source_trust_score"),
            "definition": "Weighted officiality, validity, freshness and stability",
            "status": observability.get("source_reliability", {}).get("score_status"),
        },
    }


def build_maturity(model, dashboard, observability, operational_ready):
    summary = dashboard.get("summary") or {}
    records = int(summary.get("records") or 0)
    verified = int(summary.get("verified") or 0)
    published = int(summary.get("published") or 0)
    usage_measured = observability.get("usage", {}).get("status") == "measured"
    data_conditions = {
        "collected": records > 0,
        "verified": records > 0 and verified == records,
        "published": published > 0,
        "observed": published > 0 and usage_measured,
        "operational": False,
        "intelligent": False,
    }
    data_level = 0
    data_rows = []
    sequential_open = True
    for item in model.get("levels", []):
        achieved = sequential_open and data_conditions[item["id"]]
        if achieved:
            data_level = item["level"]
        else:
            sequential_open = False
        data_rows.append({**item, "status": "achieved" if achieved else "not_achieved"})

    capability_status = {
        "collected": "achieved",
        "verified": "achieved",
        "published": "achieved",
        "observed": "achieved",
        "operational": "in_progress" if operational_ready else "planned",
        "intelligent": "planned",
    }
    capability_rows = [
        {**item, "status": capability_status[item["id"]]}
        for item in model.get("levels", [])
    ]
    return {
        "capability_maturity": {
            "current_level": 4,
            "next_level": 5,
            "status": "between_observed_and_operational",
            "levels": capability_rows,
        },
        "data_state_maturity": {
            "current_level": data_level,
            "status": data_rows[data_level - 1]["id"] if data_level else "not_established",
            "levels": data_rows,
        },
        "note": model.get("note"),
    }


def main():
    generated_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    before = fingerprint()
    policy = load_json(OPERATIONS / "operations-policy.json")
    records, release_scope, source_ownership = governed_records()
    dashboard = load_json(REPORTS / "dashboard.json")
    observability = load_json(REPORTS / "observability.json")
    freshness = load_json(REPORTS / "freshness-dashboard.json")
    usage = load_json(REPORTS / "usage-registry.json")
    health = load_json(ROOT / "knowledge_data_health.json", {})
    baseline = load_json(OPERATIONS / "source-monitor-baseline.json")
    events = load_json(OPERATIONS / "usage-events.json")
    maturity_model = load_json(OPERATIONS / "maturity-model.json")
    release_manifests = [
        load_json(path) for path in sorted((REPORTS / "release-manifests").glob("*.json"))
    ]

    queue, source_monitor, image_url_owner = build_queues(
        records, source_ownership, freshness, usage, release_manifests, health, baseline
    )
    scheduler = build_scheduler(freshness, queue)
    analytics = build_analytics(events)
    kpis = build_kpis(dashboard, observability)
    maturity = build_maturity(maturity_model, dashboard, observability, True)
    priority_counts = Counter(item["priority"] for item in queue)
    type_counts = Counter(item["type"] for item in queue)

    release_manager = {
        "status": "measured",
        "publication_candidates": [
            item for item in queue if item["type"] == "publication_candidate"
        ],
        "automatic_transitions": 0,
        "rollback_strategy": load_json(OPERATIONS / "release-transition-policy.json").get("rollback_strategy"),
        "approval_required": True,
    }
    media_monitor = {
        "status": "not_established" if not any(record.get("images") for record in records) else "measured",
        "media_assets": sum(len(record.get("images") or []) for record in records),
        "missing_image_issues": type_counts["missing_image"],
        "broken_image_issues": type_counts["broken_image"],
        "missing_license_issues": type_counts["missing_license"],
        "duplicate_asset_urls": sum(len(owners) > 1 for owners in image_url_owner.values()),
        "low_quality_detection": "not_established",
    }
    operations = {
        "schema_version": 1,
        "generated_at": generated_at,
        "work_package": "WP-17",
        "mode": policy.get("mode"),
        "input_fingerprint": before,
        "canonical_data_mutated": False,
        "external_issues_created": 0,
        "governed_scope": {
            "resolution": "effective_release_heads",
            "effective_releases": release_scope,
            "records": len(records),
            "record_sources": len(source_ownership),
        },
        "scheduler": scheduler,
        "link_monitor": {
            "urls_checked": int(health.get("totalURLs") or 0),
            "confirmed_broken": int(health.get("confirmedBrokenURLs") or 0),
            "queue_items": type_counts["broken_link"],
        },
        "source_monitor": source_monitor,
        "media_monitor": media_monitor,
        "release_manager": release_manager,
        "review_queue": {
            "items": len(queue),
            "by_priority": {key: priority_counts[key] for key in policy.get("queue_priorities", [])},
            "by_type": dict(sorted(type_counts.items())),
        },
        "analytics": analytics,
        "data_kpi": kpis,
        "maturity": maturity,
    }

    write_json(REPORTS / "operations.json", operations)
    write_json(REPORTS / "operations-action-queue.json", {
        "schema_version": 1,
        "generated_at": generated_at,
        "mode": "plan_only",
        "items": queue,
    })
    write_json(REPORTS / "editorial-dashboard.json", {
        "schema_version": 1,
        "generated_at": generated_at,
        "outdated": type_counts["outdated"],
        "broken_links": type_counts["broken_link"],
        "expired_events": type_counts["expired_event"],
        "media_replacements": type_counts["missing_image"] + type_counts["broken_image"] + type_counts["low_quality_image"],
        "license_blocks": type_counts["missing_license"],
        "publication_candidates": type_counts["publication_candidate"],
        "total_queue": len(queue),
    })
    write_json(REPORTS / "update-scheduler.json", scheduler)
    write_json(REPORTS / "source-monitor.json", source_monitor)
    write_json(REPORTS / "media-monitor.json", media_monitor)
    write_json(REPORTS / "release-manager.json", release_manager)
    write_json(REPORTS / "data-analytics.json", analytics)
    write_json(REPORTS / "data-kpi.json", kpis)
    write_json(REPORTS / "data-maturity.json", maturity)

    after = fingerprint()
    if before != after:
        raise SystemExit("Data Operations violated its canonical read-only planning contract")

    lines = [
        "# YouNew Data Operations",
        "",
        f"Generated: `{generated_at}`",
        "",
        "> Plan-then-approve operations layer. Detection and local queues are automatic; canonical changes, publication, rollback and external issues require explicit approval.",
        "",
        "## Today",
        "",
        f"- Outdated: {type_counts['outdated']}",
        f"- Broken links: {type_counts['broken_link']}",
        f"- Expired events: {type_counts['expired_event']}",
        f"- Media replacements: {type_counts['missing_image'] + type_counts['broken_image'] + type_counts['low_quality_image']}",
        f"- License blocks: {type_counts['missing_license']}",
        f"- Publication candidates: {type_counts['publication_candidate']}",
        f"- Total review queue: {len(queue)}",
        "",
        "## Maturity",
        "",
        f"- Platform capability: Level {maturity['capability_maturity']['current_level']} → Level {maturity['capability_maturity']['next_level']} in progress",
        f"- Governed data state: Level {maturity['data_state_maturity']['current_level']} ({maturity['data_state_maturity']['status']})",
        "",
        "## Safety",
        "",
        "- Canonical data mutated: no",
        "- Releases published automatically: no",
        "- External issues created automatically: no",
        "",
    ]
    (REPORTS / "operations.md").write_text("\n".join(lines), encoding="utf-8")
    print("Data Operations generated")
    print(f"- Review queue: {len(queue)}")
    print(f"- Publication candidates: {type_counts['publication_candidate']}")
    print(f"- Capability maturity: Level {maturity['capability_maturity']['current_level']} → {maturity['capability_maturity']['next_level']}")
    print(f"- Data state maturity: Level {maturity['data_state_maturity']['current_level']}")
    print("- Canonical mutations: none")
    print("- External issues: none")


if __name__ == "__main__":
    main()
