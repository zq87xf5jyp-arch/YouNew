#!/usr/bin/env python3
"""Regression checks for the governed Data Project importer and runtime bridge."""

import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace


ROOT = Path(__file__).resolve().parents[1]
IMPORTER_PATH = ROOT / "scripts" / "import-data-project.py"
PREVIEW_PATH = ROOT / "DataProject" / "reports" / "import-preview.json"
RUNTIME_PATH = ROOT / "YouNew" / "Resources" / "Data" / "younew-runtime-data.json"
RELEASES_PATH = ROOT / "DataProject" / "releases" / "releases.json"


def expect(condition, message):
    if not condition:
        raise SystemExit(f"Data Project import QA failed: {message}")


def run(*arguments):
    subprocess.run([sys.executable, str(IMPORTER_PATH), *arguments], cwd=ROOT, check=True, capture_output=True, text=True)


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def file_sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


run("--release", "cities-v0.1.0", "--dry-run")
first = file_sha(PREVIEW_PATH)
run("--release", "cities-v0.1.0", "--dry-run")
expect(file_sha(PREVIEW_PATH) == first, "identical inputs did not produce an identical preview")

preview = load(PREVIEW_PATH)
entities = preview["entities"]
release = next(item for item in load(RELEASES_PATH)["releases"] if item["id"] == "cities-v0.1.0")
is_published = release["status"] == "published"
expected_city_ids = {
    "city.amsterdam", "city.rotterdam", "city.den-haag", "city.utrecht", "city.eindhoven"
}
expect(preview["mode"] == "preview", "dry-run escaped preview mode")
expect({item["id"] for item in entities} == expected_city_ids, "cities preview does not preserve the five stable IDs")
expect(all(item["verificationStatus"] == "verified" for item in entities), "unverified preview entity included")
expected_publication = "published" if is_published else "preview"
expect(all(item["publicationStatus"] == expected_publication for item in entities), "record publication status does not match release governance")
expect(len(entities) == len({item["id"] for item in entities}), "technical duplicate reached preview")
expect(all(item["cityId"] and item["provinceId"] for item in entities), "city/province integrity failed")
expect(preview["summary"]["brokenRelations"] == 0, "preview contains broken relations")
expect(preview["summary"]["legacyConflictsDiscovered"] == 5, "five city legacy conflicts were not reported")
expect(len(preview["inputFingerprint"]["releaseManifests"]) == 1, "release manifest fingerprint missing")
expect(len(preview["inputFingerprint"]["batchFiles"]) == 1, "batch fingerprint missing")

payload = {key: value for key, value in preview.items() if key not in {"output", "summary", "excluded", "legacyConflicts"}}
checksum = payload.pop("outputChecksum")
spec = importlib.util.spec_from_file_location("data_project_importer", IMPORTER_PATH)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
expect(hashlib.sha256(module.canonical_json(payload).encode("utf-8")).hexdigest() == checksum, "output checksum is invalid")

runtime = load(RUNTIME_PATH)
expect(runtime["mode"] == "production", "runtime artifact is not production-scoped")
runtime_ids = {item["id"] for item in runtime["entities"]}

# Rebuild the published effective heads in memory. This validates the shipped
# runtime against overlay-resolved production data without mutating the checkout.
captured = {}
original_write = module.write_if_changed


def capture_runtime(path, value):
    if path == RUNTIME_PATH:
        captured["runtime"] = value
        return value != runtime
    return original_write(path, value)


module.write_if_changed = capture_runtime
try:
    module.build(SimpleNamespace(release=None, all_approved=True, all=False, dry_run=False))
finally:
    module.write_if_changed = original_write

expected_runtime = captured.get("runtime")
expect(isinstance(expected_runtime, dict), "deterministic production payload was not captured")
semantic_fields = {
    "schemaVersion", "mode", "generatedAt", "datasetFingerprint", "releases",
    "publicationPolicy", "migrationRegistry", "entities",
}
expect(
    {key: runtime.get(key) for key in semantic_fields}
    == {key: expected_runtime.get(key) for key in semantic_fields},
    "shipped production data does not match the published effective release heads",
)
expect(runtime_ids == {item["id"] for item in expected_runtime["entities"]}, "production IDs do not match published effective release heads")
expect(all(item["publicationStatus"] == "published" for item in runtime["entities"]), "non-published record entered the production artifact")
expect(len(runtime["entities"]) == len(runtime_ids), "production artifact contains duplicate IDs")

loader = (ROOT / "YouNew" / "Services" / "DataProjectRuntimeLoader.swift").read_text(encoding="utf-8")
database = (ROOT / "YouNew" / "Data" / "NetherlandsData.swift").read_text(encoding="utf-8")
saved = (ROOT / "YouNew" / "Models" / "SavedItemsStore.swift").read_text(encoding="utf-8")
expect('artifact.mode == "production"' in loader, "runtime loader does not enforce production mode")
expect('record.publicationStatus == "published"' in loader, "runtime loader does not enforce publication status")
expect("using legacy fallback" in loader, "corrupted dataset fallback is missing")
expect("runtime.entities + remainingLegacy" in database, "canonical-first duplicate prevention is missing")
expect("canonicalID(for:" in database and "canonicalID(for:" in saved, "saved legacy-to-canonical resolution is missing")

print("Data Project import QA passed")
print("- Deterministic preview: passed")
print("- Schema/release/publication gates: passed by importer")
print("- Stable IDs, duplicates, geography and relations: passed")
print("- Production approval/exclusion and corrupted-data fallback: passed")
print("- Runtime Search/AI bridge and Saved migration wiring: present")
