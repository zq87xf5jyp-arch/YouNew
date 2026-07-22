#!/usr/bin/env python3
"""Generate read-only DATA PROJECT observability and release evidence."""

import hashlib
import json
from collections import Counter, defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
OBSERVABILITY = PROJECT / "observability"
REPORTS = PROJECT / "reports"
RELEASE_MANIFESTS = REPORTS / "release-manifests"


def load_json(path: Path, fallback=None):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        if fallback is not None:
            return fallback
        raise


def write_json(path: Path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_date(value):
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError):
        return None


def percentage(numerator, denominator):
    if not denominator:
        return None
    return round(numerator / denominator * 100, 1)


def input_files():
    files = [
        path for path in PROJECT.rglob("*")
        if path.is_file() and REPORTS not in path.parents
    ]
    files.extend(path for path in (ROOT / "YouNew").rglob("*.swift") if path.is_file())
    for name in ("knowledge_data_health.json", "broken_links.csv"):
        path = ROOT / name
        if path.exists():
            files.append(path)
    return sorted(set(files))


def input_fingerprint():
    digest = hashlib.sha256()
    for path in input_files():
        digest.update(str(path.relative_to(ROOT)).encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def governed_records():
    records = []
    try:
        effective_releases = [
            resolve_release(PROJECT, release_id)
            for release_id in effective_release_heads(PROJECT)
        ]
    except EffectiveReleaseError as error:
        raise SystemExit(f"Data Observability failed: effective release resolution failed: {error}") from error
    for effective in effective_releases:
        source_label = ", ".join(str(path.relative_to(ROOT)) for path in effective.input_paths)
        for record in effective.records:
            enriched = dict(record)
            enriched["_work_package"] = effective.release.get("work_package")
            enriched["_target_release"] = effective.release_id
            enriched["_batch"] = source_label
            records.append(enriched)
    return records


def consumer_texts(config):
    texts = {}
    paths = {}
    for consumer in config.get("consumers", []):
        matched = set()
        for pattern in consumer.get("paths", []):
            matched.update(path for path in ROOT.glob(pattern) if path.is_file())
        paths[consumer["id"]] = sorted(str(path.relative_to(ROOT)) for path in matched)
        texts[consumer["id"]] = "\n".join(
            path.read_text(encoding="utf-8", errors="ignore") for path in sorted(matched)
        )
    return texts, paths


def build_usage_registry(records, consumer_config, generated_at):
    texts, evidence_paths = consumer_texts(consumer_config)
    explicit_by_entity = defaultdict(list)
    for observation in consumer_config.get("explicit_observations", []):
        explicit_by_entity[observation.get("entity_id")].append(observation)

    entries = []
    for record in records:
        entity_id = record["id"]
        consumers = []
        evidence = []
        for consumer in consumer_config.get("consumers", []):
            consumer_id = consumer["id"]
            if entity_id in texts.get(consumer_id, ""):
                consumers.append(consumer_id)
                evidence.append({
                    "consumer": consumer_id,
                    "method": "exact_stable_id_reference",
                    "paths": evidence_paths.get(consumer_id, []),
                })
        for observation in explicit_by_entity.get(entity_id, []):
            consumer_id = observation.get("consumer")
            if consumer_id and consumer_id not in consumers:
                consumers.append(consumer_id)
            evidence.append({
                "consumer": consumer_id,
                "method": "explicit_observation",
                "evidence": observation.get("evidence"),
            })

        last_used_values = [
            observation.get("last_used")
            for observation in explicit_by_entity.get(entity_id, [])
            if observation.get("last_used")
        ]
        published = record.get("lifecycle_status") == "published"
        entries.append({
            "entity_id": entity_id,
            "work_package": record.get("_work_package"),
            "release_id": record.get("_target_release"),
            "published": published,
            "indexed": any(consumer in consumers for consumer in ("ai", "search")),
            "searchable": "search" in consumers,
            "visible": any(consumer in consumers for consumer in ("home", "places", "guide", "saved", "business")),
            "consumers": sorted(consumers),
            "consumer_count": len(consumers),
            "last_used": max(last_used_values) if last_used_values else None,
            "orphan": published and not consumers,
            "evidence": evidence,
        })

    published_entries = [entry for entry in entries if entry["published"]]
    used_published = [entry for entry in published_entries if entry["consumer_count"] > 0]
    orphan_entries = [entry for entry in published_entries if entry["orphan"]]
    consumer_counts = Counter(
        consumer
        for entry in published_entries
        for consumer in entry["consumers"]
    )
    summary = {
        "status": "not_established" if not published_entries else "measured",
        "published_records": len(published_entries),
        "used_by_any_consumer": len(used_published),
        "data_usage_coverage_percent": percentage(len(used_published), len(published_entries)),
        "orphan_published_records": len(orphan_entries),
        "orphan_data_ratio_percent": percentage(len(orphan_entries), len(published_entries)),
        "consumer_counts": {
            consumer["id"]: consumer_counts[consumer["id"]]
            for consumer in consumer_config.get("consumers", [])
        },
        "note": "No usage percentage is produced until at least one governed record is published.",
    }
    return {
        "schema_version": 1,
        "generated_at": generated_at,
        "measurement_mode": "read_only",
        "detection_method": "exact stable ID references plus explicit observations",
        "summary": summary,
        "entries": entries,
    }


def freshness_rule(record, policy):
    for rule in policy.get("rules", []):
        entity_types = set(rule.get("entity_types") or [])
        work_packages = set(rule.get("work_packages") or [])
        if entity_types and record.get("entity_type") in entity_types:
            return rule
        if work_packages and record.get("_work_package") in work_packages:
            return rule
    return {
        "id": "default",
        "review_days": int(policy.get("default_review_days", 90)),
    }


def build_freshness(records, policy, today):
    rows = []
    for record in records:
        rule = freshness_rule(record, policy)
        checked = parse_date(record.get("last_checked"))
        deadline = checked + timedelta(days=int(rule["review_days"])) if checked else None
        compliant = deadline is not None and deadline >= today
        rows.append({
            "entity_id": record["id"],
            "work_package": record.get("_work_package"),
            "policy_id": rule["id"],
            "last_checked": record.get("last_checked"),
            "review_days": int(rule["review_days"]),
            "review_due": deadline.isoformat() if deadline else None,
            "compliant": compliant,
            "observed_status": record.get("verification_status"),
            "recommended_status": record.get("verification_status") if compliant else policy.get("expiry_action", "needs_review"),
        })
    compliant_count = sum(row["compliant"] for row in rows)
    return {
        "status": "measured" if rows else "not_established",
        "governed_records": len(rows),
        "compliant_records": compliant_count,
        "needs_review_records": len(rows) - compliant_count,
        "freshness_compliance_percent": percentage(compliant_count, len(rows)),
        "entries": rows,
    }


def build_source_reliability(records, policy, freshness_rows):
    broken_report = load_json(ROOT / "knowledge_data_health.json", {})
    broken_urls = {
        item.get("url")
        for item in broken_report.get("confirmedBroken", [])
        if isinstance(item, dict) and item.get("url")
    }
    freshness_by_id = {row["entity_id"]: row["compliant"] for row in freshness_rows}
    grouped = defaultdict(list)
    for record in records:
        source = record.get("official_source") or {}
        url = source.get("url")
        grouped[source.get("publisher") or "Unknown"].append({
            "official": source.get("is_official") is True,
            "valid": bool(url) and url not in broken_urls,
            "fresh": freshness_by_id.get(record["id"], False),
            "stable": bool(url) and url not in broken_urls,
        })

    weights = policy["weights"]
    minimum_sample = int(policy.get("minimum_sample_for_publisher_score", 1))
    publishers = []
    weighted_scores = []
    for publisher, items in sorted(grouped.items()):
        count = len(items)
        components = {
            "officiality": percentage(sum(item["official"] for item in items), count),
            "validity": percentage(sum(item["valid"] for item in items), count),
            "freshness": percentage(sum(item["fresh"] for item in items), count),
            "stability": percentage(sum(item["stable"] for item in items), count),
        }
        provisional = round(sum(components[key] * weights[key] for key in weights) / 100, 1)
        weighted_scores.extend([provisional] * count)
        publishers.append({
            "publisher": publisher,
            "records": count,
            **{f"{key}_percent": value for key, value in components.items()},
            "trust_score": provisional if count >= minimum_sample else None,
            "provisional_score": provisional,
            "sample_limited": count < minimum_sample,
        })

    network = {
        "checked_at": broken_report.get("checkedAt"),
        "total_urls": int(broken_report.get("totalURLs") or 0),
        "reachable": int(broken_report.get("reachableURLs") or 0),
        "confirmed_broken": int(broken_report.get("confirmedBrokenURLs") or 0),
        "access_restricted": int(broken_report.get("accessRestrictedURLs") or 0),
        "transient_failures": int(broken_report.get("transientFailures") or 0),
    }
    return {
        "status": "measured" if records else "not_established",
        "records": len(records),
        "publishers": len(publishers),
        "source_trust_score": round(sum(weighted_scores) / len(weighted_scores), 1) if weighted_scores else None,
        "score_status": "provisional" if records else "not_established",
        "confidence": "limited" if records else "not_established",
        "network_evidence_scope": "aggregate_project_wide",
        "publisher_network_attribution": "unavailable",
        "publisher_scores": publishers,
        "network": network,
        "classification_note": "Access restrictions and transient failures are visible but neutral to trust until confirmed broken. The score remains provisional until URL-level network evidence can be attributed to each publisher.",
    }


def build_migration(registry):
    mappings = registry.get("mappings", [])
    statuses = Counter(mapping.get("status") for mapping in mappings)
    legacy_total = registry.get("legacy_baseline", {}).get("record_count")
    progressed = sum(statuses[status] for status in ("migrated", "verified", "retired"))
    return {
        "status": "not_established" if legacy_total is None else "measured",
        "legacy_release": registry.get("legacy_baseline", {}).get("release_id"),
        "legacy_total": legacy_total,
        "discovered": statuses["discovered"],
        "mapped": statuses["mapped"],
        "migrated": statuses["migrated"],
        "verified": statuses["verified"],
        "retired": statuses["retired"],
        "migration_progress_percent": percentage(progressed, legacy_total),
        "remaining": max(legacy_total - progressed, 0) if isinstance(legacy_total, int) else None,
        "mappings": mappings,
        "note": "Migration progress remains not established until the legacy baseline is counted.",
    }


def build_release_manifests(records, releases, usage_entries, migration, generated_at):
    records_by_release = defaultdict(list)
    for record in records:
        records_by_release[record.get("_target_release")].append(record)
    usage_by_id = {entry["entity_id"]: entry for entry in usage_entries}
    migrated_ids = {
        mapping.get("canonical_id")
        for mapping in migration.get("mappings", [])
        if mapping.get("status") in {"migrated", "verified", "retired"}
    }

    manifests = []
    for release in releases.get("releases", []):
        release_records = records_by_release.get(release.get("id"), [])
        record_ids = {record["id"] for record in release_records}
        consumers = sorted({
            consumer
            for record in release_records
            for consumer in usage_by_id.get(record["id"], {}).get("consumers", [])
        })
        manifest = {
            "schema_version": 1,
            "release_id": release.get("id"),
            "version": release.get("version"),
            "status": release.get("status"),
            "work_package": release.get("work_package"),
            "dataset": release.get("dataset"),
            "milestone": release.get("milestone"),
            "records": {
                "governed": len(release_records),
                "published": sum(record.get("lifecycle_status") == "published" for record in release_records),
                "verified": sum(record.get("verification_status") == "verified" for record in release_records),
                "by_entity_type": dict(sorted(Counter(record.get("entity_type") for record in release_records).items())),
                "by_category": dict(sorted(Counter(record.get("category") for record in release_records).items())),
            },
            "official_sources": len({
                (record.get("official_source") or {}).get("url")
                for record in release_records
                if (record.get("official_source") or {}).get("url")
            }),
            "qa": release.get("qa", {}),
            "qa_gates_passed": sum(value == "passed" for value in release.get("qa", {}).values()),
            "consumers": consumers,
            "migration": {
                "legacy_release": migration.get("legacy_release"),
                "migrated_records_in_release": len(record_ids & migrated_ids),
            },
            "generated_at": generated_at,
        }
        manifests.append(manifest)
        write_json(RELEASE_MANIFESTS / f"{release.get('id')}.json", manifest)
    return manifests


def main():
    generated_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    today = date.today()
    before = input_fingerprint()
    records = governed_records()
    consumers = load_json(OBSERVABILITY / "consumer-registry.json")
    migration_registry = load_json(OBSERVABILITY / "migration-registry.json")
    freshness_policy = load_json(OBSERVABILITY / "freshness-policy.json")
    reliability_policy = load_json(OBSERVABILITY / "source-reliability-policy.json")
    releases = load_json(PROJECT / "releases" / "releases.json")

    usage = build_usage_registry(records, consumers, generated_at)
    freshness = build_freshness(records, freshness_policy, today)
    source_reliability = build_source_reliability(records, reliability_policy, freshness["entries"])
    migration = build_migration(migration_registry)
    release_manifests = build_release_manifests(
        records,
        releases,
        usage["entries"],
        migration,
        generated_at,
    )
    after = input_fingerprint()
    if before != after:
        raise SystemExit("Data Observability violated its read-only input contract")

    observability = {
        "schema_version": 1,
        "generated_at": generated_at,
        "work_package": "WP-16",
        "measurement_mode": "read_only",
        "input_fingerprint": before,
        "data_mutated": False,
        "usage": usage["summary"],
        "migration": {key: value for key, value in migration.items() if key != "mappings"},
        "freshness": {key: value for key, value in freshness.items() if key != "entries"},
        "source_reliability": source_reliability,
        "releases": {
            "tracked": len(release_manifests),
            "qa_ready": sum(manifest["status"] == "qa" and manifest["qa_gates_passed"] == 7 for manifest in release_manifests),
            "published": sum(manifest["status"] == "published" for manifest in release_manifests),
            "manifests": [
                {
                    "release_id": manifest["release_id"],
                    "status": manifest["status"],
                    "records": manifest["records"]["governed"],
                    "qa_gates_passed": manifest["qa_gates_passed"],
                    "consumers": manifest["consumers"],
                }
                for manifest in release_manifests
            ],
        },
    }
    write_json(REPORTS / "usage-registry.json", usage)
    write_json(REPORTS / "migration-dashboard.json", migration)
    write_json(REPORTS / "freshness-dashboard.json", freshness)
    write_json(REPORTS / "source-reliability.json", source_reliability)
    write_json(REPORTS / "observability.json", observability)

    usage_value = observability["usage"]["data_usage_coverage_percent"]
    migration_value = observability["migration"]["migration_progress_percent"]
    lines = [
        "# YouNew Data Observability",
        "",
        f"Generated: `{generated_at}`",
        "",
        "> Read-only measurement layer. This generator never changes entity, verification, lifecycle, or publication state.",
        "",
        "## KPI",
        "",
        "| KPI | Value | Status |",
        "| --- | ---: | --- |",
        f"| Data Usage Coverage | {usage_value if usage_value is not None else '—'} | {observability['usage']['status']} |",
        f"| Orphan Data Ratio | {observability['usage']['orphan_data_ratio_percent'] if observability['usage']['orphan_data_ratio_percent'] is not None else '—'} | {observability['usage']['status']} |",
        f"| Migration Progress | {migration_value if migration_value is not None else '—'} | {observability['migration']['status']} |",
        f"| Freshness Compliance | {observability['freshness']['freshness_compliance_percent']}% | {observability['freshness']['status']} |",
        f"| Source Trust Score | {observability['source_reliability']['source_trust_score']} | {observability['source_reliability']['status']} |",
        "",
        "## Releases",
        "",
        f"- Tracked manifests: {observability['releases']['tracked']}",
        f"- QA-ready: {observability['releases']['qa_ready']}",
        f"- Published: {observability['releases']['published']}",
        "",
        "## Honest denominators",
        "",
        "- Usage remains not established while published governed records equal zero.",
        "- Migration remains not established until the legacy runtime baseline is counted.",
        "- Access restrictions and transient failures do not automatically lower source trust.",
        "",
    ]
    (REPORTS / "observability.md").write_text("\n".join(lines), encoding="utf-8")

    print("Data Observability generated")
    print(f"- Governed records observed: {len(records)}")
    print(f"- Usage coverage: {usage_value if usage_value is not None else 'not established'}")
    print(f"- Migration progress: {migration_value if migration_value is not None else 'not established'}")
    print(f"- Freshness compliance: {observability['freshness']['freshness_compliance_percent']}%")
    print(f"- Release manifests: {len(release_manifests)}")
    print("- Input mutation: none")


if __name__ == "__main__":
    main()
