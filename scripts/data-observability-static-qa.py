#!/usr/bin/env python3
"""Validate WP-16 read-only observability contracts and generated evidence."""

import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
OBSERVABILITY = PROJECT / "observability"
REPORTS = PROJECT / "reports"


def load(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"{path.relative_to(ROOT)} is invalid: {error}")


def fail(message):
    print(f"Data Observability static QA failed: {message}")
    raise SystemExit(1)


def require(condition, message):
    if not condition:
        fail(message)


packages = load(PROJECT / "work-packages.json").get("work_packages", [])
wp16 = next((item for item in packages if item.get("id") == "WP-16"), None)
require(wp16 is not None, "WP-16 is missing")
require(wp16.get("status") == "active", "WP-16 must be active")
require(set(wp16.get("domains") or []) == {"data_observability", "data_releases"}, "WP-16 domain ownership is incomplete")

consumer_registry = load(OBSERVABILITY / "consumer-registry.json")
migration_registry = load(OBSERVABILITY / "migration-registry.json")
freshness_policy = load(OBSERVABILITY / "freshness-policy.json")
reliability_policy = load(OBSERVABILITY / "source-reliability-policy.json")
release_schema = load(OBSERVABILITY / "release-manifest.schema.json")
for name, payload in (
    ("consumer registry", consumer_registry),
    ("migration registry", migration_registry),
    ("freshness policy", freshness_policy),
    ("source reliability policy", reliability_policy),
):
    require(payload.get("measurement_mode") == "read_only", f"{name} is not read-only")

consumer_ids = [item.get("id") for item in consumer_registry.get("consumers", [])]
required_consumers = {"ai", "search", "home", "places", "guide", "saved", "business", "api"}
require(set(consumer_ids) == required_consumers and len(consumer_ids) == len(set(consumer_ids)), "consumer registry is incomplete or duplicated")
for consumer in consumer_registry["consumers"]:
    require(bool(consumer.get("paths")), f"consumer {consumer.get('id')} has no evidence paths")

allowed_migration = set(migration_registry.get("allowed_statuses") or [])
require(allowed_migration == {"discovered", "mapped", "migrated", "verified", "retired"}, "migration statuses drifted")
legacy_total = migration_registry.get("legacy_baseline", {}).get("record_count")
require(legacy_total is None or isinstance(legacy_total, int) and legacy_total >= 0, "legacy baseline count is invalid")
mappings = migration_registry.get("mappings") or []
legacy_ids = [item.get("legacy_id") for item in mappings]
canonical_ids = [item.get("canonical_id") for item in mappings]
require(len(legacy_ids) == len(set(legacy_ids)), "legacy IDs are duplicated")
require(len(canonical_ids) == len(set(canonical_ids)), "canonical migration IDs are duplicated")
require(all(item.get("status") in allowed_migration for item in mappings), "migration registry contains an invalid status")

rules = freshness_policy.get("rules") or []
require(freshness_policy.get("expiry_action") == "needs_review", "expired data must become needs_review")
require(rules and all(isinstance(rule.get("review_days"), int) and rule["review_days"] > 0 for rule in rules), "freshness SLA rules are invalid")
require(any(rule.get("entity_types") == ["event"] and rule.get("review_days") == 1 for rule in rules), "daily event SLA is missing")
require(any(rule.get("entity_types") == ["city"] and rule.get("review_days") == 365 for rule in rules), "yearly city SLA is missing")

weights = reliability_policy.get("weights") or {}
require(set(weights) == {"officiality", "validity", "freshness", "stability"}, "source reliability dimensions drifted")
require(sum(weights.values()) == 100, "source reliability weights must total 100")
classification = reliability_policy.get("network_classification") or {}
require(classification.get("access_restricted") == "neutral_retry_required", "access restrictions must remain trust-neutral")
require(classification.get("transient_failure") == "neutral_retry_required", "transient failures must remain trust-neutral")
require(release_schema.get("title") == "YouNew Data Release Manifest", "release manifest schema is missing")

records = {}
release_owner = {}
for path in sorted((PROJECT / "batches").glob("**/*.json")):
    batch = load(path)
    for record in batch.get("records", []):
        records[record["id"]] = record
        release_owner[record["id"]] = batch.get("target_release")

observability = load(REPORTS / "observability.json")
usage = load(REPORTS / "usage-registry.json")
migration = load(REPORTS / "migration-dashboard.json")
freshness = load(REPORTS / "freshness-dashboard.json")
reliability = load(REPORTS / "source-reliability.json")
require(observability.get("work_package") == "WP-16", "observability report has the wrong owner")
require(observability.get("measurement_mode") == "read_only", "observability report is not read-only")
require(observability.get("data_mutated") is False, "observability reports a data mutation")
require(isinstance(observability.get("input_fingerprint"), str) and len(observability["input_fingerprint"]) == 64, "input fingerprint is missing")

entries = usage.get("entries") or []
require(len(entries) == len(records), "usage registry must contain every governed entity")
require(len({entry.get("entity_id") for entry in entries}) == len(entries), "usage registry entity IDs are duplicated")
for entry in entries:
    entity_id = entry.get("entity_id")
    require(entity_id in records, f"usage registry contains unknown entity {entity_id}")
    require(set(entry.get("consumers") or []) <= required_consumers, f"{entity_id} has an unknown consumer")
    require(entry.get("consumer_count") == len(entry.get("consumers") or []), f"{entity_id} consumer count is incorrect")
    require(entry.get("published") == (records[entity_id].get("lifecycle_status") == "published"), f"{entity_id} publication observation is incorrect")
    require(entry.get("orphan") == (entry["published"] and entry["consumer_count"] == 0), f"{entity_id} orphan flag is incorrect")

published = sum(record.get("lifecycle_status") == "published" for record in records.values())
usage_summary = usage.get("summary") or {}
require(usage_summary.get("published_records") == published, "usage denominator does not match published records")
if published == 0:
    require(usage_summary.get("status") == "not_established", "zero published records must yield not_established usage")
    require(usage_summary.get("data_usage_coverage_percent") is None, "usage must not invent a percentage without a denominator")
    require(usage_summary.get("orphan_data_ratio_percent") is None, "orphan ratio must not invent a percentage without a denominator")

require(migration.get("legacy_total") == legacy_total, "migration baseline drifted from its registry")
if legacy_total is None:
    require(migration.get("status") == "not_established", "unknown legacy baseline must yield not_established migration")
    require(migration.get("migration_progress_percent") is None, "migration must not invent a percentage without a denominator")
    require(migration.get("remaining") is None, "migration must not invent a remaining count without a baseline")

freshness_entries = freshness.get("entries") or []
require(len(freshness_entries) == len(records), "freshness dashboard must contain every governed entity")
require(freshness.get("governed_records") == len(records), "freshness denominator is incorrect")
require(freshness.get("compliant_records", 0) + freshness.get("needs_review_records", 0) == len(records), "freshness partition is incomplete")
for entry in freshness_entries:
    require(entry.get("entity_id") in records, "freshness dashboard contains an unknown entity")
    if not entry.get("compliant"):
        require(entry.get("recommended_status") == "needs_review", "expired records must recommend needs_review")

require(reliability.get("classification_note"), "source reliability classification note is missing")
require(reliability.get("score_status") == "provisional", "source trust must remain provisional with aggregate-only network evidence")
require(reliability.get("confidence") == "limited", "source trust confidence must expose its current limitation")
require(reliability.get("publisher_network_attribution") == "unavailable", "publisher network attribution must not be invented")
network = reliability.get("network") or {}
require(network.get("confirmed_broken", 0) >= 0, "network evidence is invalid")
require(all(row.get("sample_limited") == (row.get("records", 0) < reliability_policy["minimum_sample_for_publisher_score"]) for row in reliability.get("publisher_scores") or []), "publisher sample limits are incorrect")

release_registry = load(PROJECT / "releases" / "releases.json").get("releases", [])
manifest_paths = sorted((REPORTS / "release-manifests").glob("*.json"))
require(len(manifest_paths) == len(release_registry), "release manifest count is incorrect")
release_by_id = {release["id"]: release for release in release_registry}
for path in manifest_paths:
    manifest = load(path)
    release_id = manifest.get("release_id")
    require(release_id in release_by_id, f"unknown generated release manifest {release_id}")
    expected_records = sum(owner == release_id for owner in release_owner.values())
    require(manifest.get("records", {}).get("governed") == expected_records, f"{release_id} governed record count is incorrect")
    require(manifest.get("qa") == release_by_id[release_id].get("qa"), f"{release_id} QA evidence drifted")
    require(manifest.get("status") == release_by_id[release_id].get("status"), f"{release_id} status drifted")
    require(manifest.get("generated_at") == observability.get("generated_at"), f"{release_id} snapshot timestamp drifted")

script = (ROOT / "scripts" / "generate-data-observability.py").read_text(encoding="utf-8")
for forbidden in ("lifecycle_status =", "verification_status =", "publication_status =", "published_at ="):
    require(forbidden not in script, f"generator contains a forbidden mutation pattern: {forbidden}")
require("before = input_fingerprint()" in script and "after = input_fingerprint()" in script, "generator does not prove its read-only input contract")

print("Data Observability static QA passed")
print(f"- Consumers: {len(consumer_ids)}")
print(f"- Governed usage rows: {len(entries)}")
print(f"- Freshness rows: {len(freshness_entries)}")
print(f"- Release manifests: {len(manifest_paths)}")
print("- Read-only contract: enforced")
