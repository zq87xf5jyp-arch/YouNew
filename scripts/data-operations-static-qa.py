#!/usr/bin/env python3
"""Validate WP-17 operational planning, safety and KPI contracts."""

import json
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent))

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release  # noqa: E402


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
OPERATIONS = PROJECT / "operations"
REPORTS = PROJECT / "reports"


def load(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"{path.relative_to(ROOT)} is invalid: {error}")


def fail(message):
    print(f"Data Operations static QA failed: {message}")
    raise SystemExit(1)


def require(condition, message):
    if not condition:
        fail(message)


packages = load(PROJECT / "work-packages.json").get("work_packages", [])
wp17 = next((item for item in packages if item.get("id") == "WP-17"), None)
require(wp17 is not None and wp17.get("status") == "active", "WP-17 must exist and be active")
require(set(wp17.get("domains") or []) == {"data_operations", "editorial_workflow"}, "WP-17 ownership is incomplete")

policy = load(OPERATIONS / "operations-policy.json")
require(policy.get("mode") == "plan_then_approve", "operations must use plan-then-approve")
required_approval = {
    "change_entity_lifecycle",
    "change_verification_status",
    "archive_event",
    "replace_source",
    "replace_media",
    "publish_release",
    "rollback_release",
    "create_external_issue",
}
require(set(policy.get("approval_required_actions") or []) == required_approval, "approval-required action contract drifted")
for action in ("publish", "rollback", "delete", "retire", "edit_canonical_data", "create_github_issue"):
    require(action in policy.get("forbidden_automatic_actions", []), f"automatic {action} must be forbidden")

transitions = load(OPERATIONS / "release-transition-policy.json")
require(transitions.get("published_releases_immutable") is True, "published releases must be immutable")
require(transitions.get("rollback_strategy") == "publish_new_patch_release", "rollback must create a patch release")
require(transitions.get("rollback_requires_explicit_approval") is True, "rollback approval is missing")
require(transitions.get("automatic_transition_allowed") is False, "automatic release transitions must be disabled")
publish_transition = next((item for item in transitions.get("allowed_transitions", []) if item.get("from") == "qa" and item.get("to") == "published"), None)
require(publish_transition and "explicit_release_approval" in publish_transition.get("requires", []), "QA-to-published transition lacks explicit approval")

issue_types = load(OPERATIONS / "issue-types.json").get("issue_types", [])
required_types = {
    "broken_link", "source_changed", "wrong_city", "duplicate", "outdated",
    "expired_event", "missing_image", "broken_image", "low_quality_image",
    "missing_license", "orphan_data", "publication_candidate",
}
require({item.get("id") for item in issue_types} == required_types, "issue type registry is incomplete")

usage_events = load(OPERATIONS / "usage-events.json")
require(usage_events.get("collection_enabled") is False, "usage telemetry must not be silently enabled")
require(usage_events.get("events") == [], "usage telemetry must start empty")
require("No personal identifiers" in usage_events.get("privacy_note", ""), "usage telemetry privacy contract is missing")
usage_schema = load(OPERATIONS / "usage-events.schema.json")
require(usage_schema.get("additionalProperties") is False, "usage event schema must reject undeclared personal fields")

baseline = load(OPERATIONS / "source-monitor-baseline.json")
require(baseline.get("status") in {"not_established", "established"}, "source baseline status is invalid")
if baseline.get("status") == "not_established":
    require(baseline.get("sources") == [], "unestablished source baseline must not contain invented rows")

maturity_model = load(OPERATIONS / "maturity-model.json")
require([item.get("level") for item in maturity_model.get("levels", [])] == [1, 2, 3, 4, 5, 6], "maturity levels are incomplete")
require(maturity_model.get("sequential_data_state") is True, "data-state maturity must be sequential")

operations = load(REPORTS / "operations.json")
queue = load(REPORTS / "operations-action-queue.json")
editorial = load(REPORTS / "editorial-dashboard.json")
kpis = load(REPORTS / "data-kpi.json")
maturity = load(REPORTS / "data-maturity.json")
analytics = load(REPORTS / "data-analytics.json")
try:
    expected_release_ids = effective_release_heads(PROJECT)
    effective_releases = [resolve_release(PROJECT, release_id) for release_id in expected_release_ids]
except EffectiveReleaseError as error:
    fail(f"effective release resolution failed: {error}")
expected_entity_sources = {
    entity_id: source
    for effective in effective_releases
    for entity_id, source in effective.record_sources.items()
}
expected_scope = [
    {
        "release_id": effective.release_id,
        "status": effective.release.get("status"),
        "work_package": effective.release.get("work_package"),
        "records": len(effective.records),
        "replacements": effective.replacement_count,
    }
    for effective in effective_releases
]
require(operations.get("work_package") == "WP-17", "operations report has the wrong owner")
require(operations.get("mode") == "plan_then_approve", "generated operations mode drifted")
require(operations.get("canonical_data_mutated") is False, "operations reports a canonical mutation")
require(operations.get("external_issues_created") == 0, "operations created external issues")
require(isinstance(operations.get("input_fingerprint"), str) and len(operations["input_fingerprint"]) == 64, "operations input fingerprint is missing")
governed_scope = operations.get("governed_scope") or {}
require(governed_scope.get("resolution") == "effective_release_heads", "operations must resolve effective release heads")
require(governed_scope.get("effective_releases") == expected_scope, "operations effective release scope is stale or includes superseded releases")
require(governed_scope.get("records") == len(expected_entity_sources), "operations governed record count is incorrect")
require(governed_scope.get("record_sources") == len(expected_entity_sources), "operations record source ownership is incomplete")

items = queue.get("items") or []
require(queue.get("mode") == "plan_only", "action queue must be plan-only")
require(len(items) == editorial.get("total_queue"), "editorial queue count is inconsistent")
require(len({item.get("id") for item in items}) == len(items), "operation queue IDs are duplicated")
for item in items:
    require(item.get("type") in required_types, f"unknown operation issue type {item.get('type')}")
    require(item.get("approval_required") is True, f"{item.get('id')} must require approval")
    require(item.get("external_issue_created") is False, f"{item.get('id')} created an external issue")
    require(item.get("status") == "open", f"{item.get('id')} has an invalid queue status")
    entity_id = item.get("entity_id")
    if entity_id is not None:
        require(entity_id in expected_entity_sources, f"{item.get('id')} references a superseded or unknown entity")
        if item.get("type") in {"broken_link", "source_changed", "outdated", "orphan_data"}:
            source = (item.get("evidence") or {}).get("source")
            expected_source = expected_entity_sources[entity_id]
            require(
                isinstance(source, str) and source.endswith(expected_source.split(str(ROOT.resolve()) + "/")[-1]),
                f"{item.get('id')} does not retain effective record source ownership",
            )

release_candidates = [item for item in items if item.get("type") == "publication_candidate"]
release_manifests = [load(path) for path in sorted((REPORTS / "release-manifests").glob("*.json"))]
expected_candidates = [
    manifest for manifest in release_manifests
    if manifest.get("status") == "qa" and manifest.get("qa_gates_passed") == 7
]
require(len(release_candidates) == len(expected_candidates), "publication candidate queue is incorrect")
require(operations.get("release_manager", {}).get("automatic_transitions") == 0, "release manager performed an automatic transition")
require(operations.get("release_manager", {}).get("approval_required") is True, "release manager approval contract is missing")

dashboard = load(REPORTS / "dashboard.json")
summary = dashboard.get("summary") or {}
require(kpis.get("verification", {}).get("value") == 100.0, "verification KPI is incorrect")
record_count = summary.get("records", 0)
published_count = summary.get("published", 0)
expected_publication = round(published_count / record_count * 100, 1) if record_count else None
require(kpis.get("publication", {}).get("value") == expected_publication, "publication KPI is incorrect")
if published_count:
    require(isinstance(kpis.get("usage", {}).get("value"), (int, float)), "usage KPI must be measured after publication")
else:
    require(kpis.get("usage", {}).get("value") is None, "usage KPI must remain unset without published data")
media_kpi = kpis.get("media", {})
if media_kpi.get("value") is None:
    require(media_kpi.get("status") == "not_established", "unset media KPI must report not_established")
else:
    require(isinstance(media_kpi.get("value"), (int, float)) and 0 <= media_kpi["value"] <= 100, "measured media KPI is invalid")
    require(media_kpi.get("status") == "measured", "media KPI with a denominator must report measured")
require(kpis.get("source_trust", {}).get("status") == "provisional", "source trust KPI must expose its provisional status")
require(kpis.get("coverage", {}).get("denominator") == len(dashboard.get("breadth_coverage") or []), "coverage KPI denominator is incorrect")

capability = maturity.get("capability_maturity") or {}
data_state = maturity.get("data_state_maturity") or {}
require(capability.get("current_level") == 4 and capability.get("next_level") == 5, "capability maturity must remain between Observed and Operational")
expected_data_level = 4 if published_count else 2
require(data_state.get("current_level") == expected_data_level, "data-state maturity does not match publication state")
require(analytics.get("status") == "not_established", "analytics must remain not established before telemetry is enabled")
require(analytics.get("events") == 0, "analytics must not invent usage events")

script = (ROOT / "scripts" / "generate-data-operations.py").read_text(encoding="utf-8")
for forbidden in ("lifecycle_status =", "verification_status =", "publication_status =", "published_at =", "api.github.com"):
    require(forbidden not in script, f"operations generator contains a forbidden mutation pattern: {forbidden}")
require("before = fingerprint()" in script and "after = fingerprint()" in script, "operations generator does not enforce its input fingerprint")
require("effective_release_heads(PROJECT)" in script, "operations generator does not resolve effective release heads")
require("effective.record_sources" in script, "operations generator does not retain effective record source ownership")
require('(PROJECT / "batches").glob' not in script, "operations generator must not read superseded raw batches directly")

print("Data Operations static QA passed")
print(f"- Review queue items: {len(items)}")
print(f"- Publication candidates: {len(release_candidates)}")
print(f"- Capability maturity: Level {capability.get('current_level')} → {capability.get('next_level')}")
print(f"- Data-state maturity: Level {data_state.get('current_level')}")
print("- Automatic canonical mutations: 0")
print("- External issues created: 0")
