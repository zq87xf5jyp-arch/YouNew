#!/usr/bin/env python3
"""Validate quantitative and qualitative Coverage Dashboard contracts."""

import json
import re
from collections import Counter
from pathlib import Path

from effective_release import EffectiveReleaseError, effective_release_heads, resolve_release


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
GENERATOR_SOURCE = (ROOT / "scripts" / "generate-data-dashboard.py").read_text(encoding="utf-8")
DASHBOARD_JSON = PROJECT / "reports" / "dashboard.json"
DASHBOARD_MD = PROJECT / "reports" / "dashboard.md"
DIMENSIONS = {
    "verification",
    "official_source",
    "freshness",
    "relationships",
    "geography",
    "media",
    "search",
    "ai",
    "publication",
}


def fail(message: str) -> None:
    print(f"Data Dashboard static QA failed: {message}")
    raise SystemExit(1)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


for offline_contract in (
    "OFFLINE_LINK_EVIDENCE",
    '"checkedAt": "1970-01-01T00:00:00+00:00"',
    '"totalURLs": 0',
    "load_json(ROOT / \"knowledge_data_health.json\", OFFLINE_LINK_EVIDENCE)",
):
    require(offline_contract in GENERATOR_SOURCE, f"offline link-evidence contract missing {offline_contract}")

require(
    '"YouNew/Resources/Data/younew-runtime-data.json:"' in GENERATOR_SOURCE,
    "governed runtime link failures must not be classified as legacy",
)


dashboard = json.loads(DASHBOARD_JSON.read_text(encoding="utf-8"))
markdown = DASHBOARD_MD.read_text(encoding="utf-8")
records_by_package = Counter()
entity_types = Counter()
entity_types_by_package = Counter()
media_assets = 0
media_assets_by_package = Counter()
all_records = []
try:
    effective_releases = [
        resolve_release(PROJECT, release_id)
        for release_id in effective_release_heads(PROJECT)
    ]
except EffectiveReleaseError as error:
    fail(f"effective release resolution failed: {error}")

for effective in effective_releases:
    work_package = effective.release.get("work_package")
    records_by_package[work_package] += len(effective.records)
    for record in effective.records:
        scoped_record = dict(record)
        scoped_record["_work_package"] = work_package
        all_records.append(scoped_record)
        entity_types[record.get("entity_type")] += 1
        entity_types_by_package[(work_package, record.get("entity_type"))] += 1
        media_assets += len(record.get("images") or [])
        media_assets_by_package[work_package] += len(record.get("images") or [])

packages = dashboard.get("work_packages")
require(isinstance(packages, list) and len(packages) == 17, "dashboard must contain WP-01 through WP-17")
require({item.get("id") for item in packages} == {f"WP-{number:02d}" for number in range(1, 18)}, "work package IDs are incomplete")
for package in packages:
    package_id = package["id"]
    record_count = records_by_package[package_id]
    require(package.get("records") == record_count, f"{package_id} record count does not match governed effective releases")
    dimensions = package.get("coverage_dimensions")
    require(isinstance(dimensions, dict) and set(dimensions) == DIMENSIONS, f"{package_id} coverage dimensions are incomplete")
    for key, value in dimensions.items():
        require(value is None or isinstance(value, (int, float)), f"{package_id}.{key} must be numeric or not applicable")
        require(value is None or 0 <= value <= 100, f"{package_id}.{key} must be between 0 and 100")
    if record_count == 0:
        require(all(value is None for value in dimensions.values()), f"{package_id} must not invent coverage for an empty dataset")
    else:
        for key in ("verification", "official_source", "freshness", "relationships", "search", "ai", "publication"):
            require(dimensions[key] is not None, f"{package_id}.{key} coverage is missing")

targets = json.loads((PROJECT / "coverage-targets.json").read_text(encoding="utf-8"))["targets"]
coverage_by_key = {item.get("key"): item for item in dashboard.get("coverage") or []}
require(set(coverage_by_key) == {target["key"] for target in targets}, "coverage target rows are incomplete")
for target in targets:
    row = coverage_by_key[target["key"]]
    package_id = target["work_package"]
    expected = media_assets if target["entity_types"] == ["*media_assets"] else sum(entity_types_by_package[(package_id, entity_type)] for entity_type in target["entity_types"])
    require(row.get("current") == expected, f"{target['key']} current count does not match governed records")
    require(row.get("target") == target["target"], f"{target['key']} target drifted from coverage-targets.json")
    expected_percent = round(expected / target["target"] * 100, 1)
    require(row.get("coverage_percent") == expected_percent, f"{target['key']} coverage percentage is incorrect")

require(dashboard.get("summary", {}).get("media_assets") == media_assets, "summary media asset count is incorrect")
require(coverage_by_key["images"].get("current") == media_assets, "image coverage must count embedded media across all work packages")

breadth_config = json.loads((PROJECT / "coverage-dimensions.json").read_text(encoding="utf-8"))
axes = breadth_config.get("axes") or []
axes_by_key = {axis["key"]: axis for axis in axes}
breadth_by_key = {item.get("key"): item for item in dashboard.get("breadth_coverage") or []}
require(set(breadth_by_key) == set(axes_by_key), "breadth coverage rows are incomplete")
targets_by_key = {target["key"]: target for target in targets}


def normalized(value) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", str(value).casefold()))


for axis in axes:
    row = breadth_by_key[axis["key"]]
    target = targets_by_key[axis["target_key"]]
    relevant_types = set(target["entity_types"])
    observed = {
        normalized(record.get(axis["field"]))
        for record in all_records
        if record.get("_work_package") == axis["work_package"] and record.get("entity_type") in relevant_types and record.get(axis["field"])
    }
    required_values = axis.get("required_values") or axes_by_key[axis["required_values_from"]]["required_values"]
    minimum_records = int(axis.get("minimum_records_per_value", 1))
    expected_covered = []
    expected_missing = []
    expected_counts = []
    expected_underfilled = []
    for value in required_values:
        matches = {normalized(item) for item in value.get("match_values") or [value["key"]]}
        count = sum(
            normalized(record.get(axis["field"])) in matches
            for record in all_records
            if record.get("_work_package") == axis["work_package"] and record.get("entity_type") in relevant_types
        )
        destination = expected_covered if count else expected_missing
        destination.append(value["key"])
        expected_counts.append((value["key"], count))
        if count < minimum_records:
            expected_underfilled.append((value["key"], count, minimum_records - count))
    require(row.get("covered") == len(expected_covered), f"{axis['key']} covered breadth count is incorrect")
    require(row.get("target") == len(required_values), f"{axis['key']} breadth target is incorrect")
    require(row.get("coverage_percent") == round(len(expected_covered) / len(required_values) * 100, 1), f"{axis['key']} breadth percentage is incorrect")
    require([value.get("key") for value in row.get("covered_values") or []] == expected_covered, f"{axis['key']} covered values are incorrect")
    require([value.get("key") for value in row.get("missing_values") or []] == expected_missing, f"{axis['key']} missing values are incorrect")
    require(row.get("minimum_records_per_value") == minimum_records, f"{axis['key']} minimum depth is incorrect")
    require([(value.get("key"), value.get("count")) for value in row.get("value_counts") or []] == expected_counts, f"{axis['key']} value counts are incorrect")
    depth_target = len(required_values) * minimum_records
    depth_covered = sum(min(count, minimum_records) for _, count in expected_counts)
    require(row.get("depth_target") == depth_target, f"{axis['key']} depth target is incorrect")
    require(row.get("depth_covered") == depth_covered, f"{axis['key']} depth covered is incorrect")
    require(row.get("depth_coverage_percent") == round(depth_covered / depth_target * 100, 1), f"{axis['key']} depth percentage is incorrect")
    require([(value.get("key"), value.get("count"), value.get("needed")) for value in row.get("underfilled_values") or []] == expected_underfilled, f"{axis['key']} underfilled values are incorrect")

require("## Coverage dimensions" in markdown, "human-readable dashboard has no qualitative coverage section")
require("## Breadth coverage" in markdown, "human-readable dashboard has no topical or geographic breadth section")
require("Depth target" in markdown and "Underfilled" in markdown, "human-readable dashboard has no depth coverage columns")
for heading in ("Verified", "Official source", "Fresh", "Connected", "Geo", "Media", "Search", "AI", "Published"):
    require(heading in markdown, f"human-readable coverage table is missing {heading}")

print("Data Dashboard static QA passed")
print(f"- Volume targets checked: {len(targets)}")
print(f"- Breadth axes checked: {len(axes)}")
print(f"- Coverage dimensions checked: {len(packages)} work packages × {len(DIMENSIONS)} dimensions")
