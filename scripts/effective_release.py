#!/usr/bin/env python3
"""Fail-closed resolution for immutable Data Project patch-release overlays."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import urlsplit


GATES = ("build", "static", "duplicate", "source", "media", "search", "ai")
QA_RESULTS = {"pending", "passed", "failed", "not_applicable"}
HASH = re.compile(r"^[0-9a-f]{64}$")
STABLE_ID = re.compile(r"^[a-z0-9]+(?:[._:-][a-z0-9]+)+$")
SEMVER = re.compile(r"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$")
ENTITY_REQUIRED_FIELDS = {
    "id", "entity_type", "category", "city_id", "province_id", "coordinates",
    "title", "description", "images", "official_source", "website",
    "related_entity_ids", "last_checked", "review_frequency_days",
    "verification_status", "ai_summary", "search_keywords", "lifecycle_status",
}
OVERLAY_REQUIRED_FIELDS = {
    "schema_version", "release_id", "version", "status", "work_package", "dataset",
    "base_release_id", "supersedes", "base_batch_sha256", "qa", "evidence",
    "replacements",
}
REPLACEMENT_REQUIRED_FIELDS = {
    "entity_id", "original_canonical_sha256", "replacement_canonical_sha256",
    "reason", "evidence_refs", "record",
}
EVIDENCE_KINDS = {"url_check", "replacement_review"}


class EffectiveReleaseError(ValueError):
    """Raised when an effective release cannot be proven safe and deterministic."""


@dataclass(frozen=True)
class EffectiveRelease:
    release_id: str
    release: dict[str, Any]
    records: tuple[dict[str, Any], ...]
    record_sources: dict[str, str]
    batch_paths: tuple[Path, ...]
    input_paths: tuple[Path, ...]
    replacement_count: int
    overlay: dict[str, Any] | None = None


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def canonical_sha256(value: Any) -> str:
    return hashlib.sha256(canonical_json_bytes(value)).hexdigest()


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise EffectiveReleaseError(f"{path} is not valid readable JSON: {error}") from error
    if not isinstance(value, dict):
        raise EffectiveReleaseError(f"{path} must contain a JSON object")
    return value


def _expect(condition: bool, message: str) -> None:
    if not condition:
        raise EffectiveReleaseError(message)


def _parse_date(value: Any, label: str) -> date:
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError) as error:
        raise EffectiveReleaseError(f"{label} must be an ISO date (YYYY-MM-DD)") from error


def _is_https(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    parsed = urlsplit(value)
    return parsed.scheme == "https" and bool(parsed.netloc)


def _repo_path(project: Path, value: Any, label: str) -> Path:
    _expect(isinstance(value, str) and value, f"{label} must be a repository-relative path")
    relative = Path(value)
    _expect(not relative.is_absolute(), f"{label} must not be absolute")
    repository = project.resolve().parent
    resolved = (repository / relative).resolve()
    try:
        resolved.relative_to(project.resolve())
    except ValueError as error:
        raise EffectiveReleaseError(f"{label} must stay inside DataProject") from error
    return resolved


def release_catalog(project: Path) -> dict[str, dict[str, Any]]:
    registry = _load_json(project / "releases" / "releases.json")
    releases: dict[str, dict[str, Any]] = {}
    for index, release in enumerate(registry.get("releases", [])):
        _expect(isinstance(release, dict), f"release registry item {index + 1} must be an object")
        release_id = release.get("id")
        _expect(isinstance(release_id, str) and release_id, f"release registry item {index + 1} has no ID")
        _expect(release_id not in releases, f"duplicate Data Release ID {release_id}")
        releases[release_id] = release
    return releases


def _batch_catalog(project: Path) -> dict[str, list[tuple[Path, dict[str, Any]]]]:
    result: dict[str, list[tuple[Path, dict[str, Any]]]] = {}
    for path in sorted((project / "batches").glob("**/*.json")):
        batch = _load_json(path)
        release_id = batch.get("target_release")
        _expect(isinstance(release_id, str) and release_id, f"{path} has no target_release")
        result.setdefault(release_id, []).append((path, batch))
    return result


def _semver(value: Any, label: str) -> tuple[int, int, int]:
    match = SEMVER.fullmatch(str(value))
    _expect(match is not None, f"{label} must use semantic versioning")
    assert match is not None
    return tuple(int(item) for item in match.groups())


def validate_release_graph(project: Path) -> dict[str, dict[str, Any]]:
    releases = release_catalog(project)
    successors: dict[str, list[str]] = {}
    for release_id, release in releases.items():
        base_id = release.get("base_release_id")
        supersedes = release.get("supersedes")
        has_overlay = "overlay_path" in release
        overlay_fields_present = base_id is not None or supersedes is not None or has_overlay
        if not overlay_fields_present:
            continue
        _expect(base_id == supersedes and isinstance(base_id, str), f"overlay release {release_id} must have matching base_release_id and supersedes")
        _expect(base_id in releases, f"overlay release {release_id} has unknown base release {base_id}")
        _expect(base_id != release_id, f"overlay release {release_id} cannot supersede itself")
        base = releases[base_id]
        _expect(release.get("work_package") == base.get("work_package"), f"overlay release {release_id} changes work package")
        _expect(release.get("dataset") == base.get("dataset"), f"overlay release {release_id} changes dataset")
        base_version = _semver(base.get("version"), f"release {base_id}.version")
        patch_version = _semver(release.get("version"), f"release {release_id}.version")
        _expect(patch_version[:2] == base_version[:2] and patch_version[2] > base_version[2], f"overlay release {release_id} must be a later patch of {base_id}")
        _expect(bool(release.get("acceptance_lock_path")), f"overlay release {release_id} has no acceptance_lock_path")
        _expect(bool(release.get("base_batch_sha256")), f"overlay release {release_id} has no base_batch_sha256")
        successors.setdefault(base_id, []).append(release_id)

    for start in releases:
        seen: set[str] = set()
        current = start
        while releases[current].get("base_release_id") is not None:
            _expect(current not in seen, f"release overlay cycle includes {current}")
            seen.add(current)
            current = releases[current]["base_release_id"]

    for base_id, release_ids in successors.items():
        active = [
            release_id for release_id in release_ids
            if releases[release_id].get("status") in {"planned", "qa", "published"}
        ]
        _expect(len(active) <= 1, f"base release {base_id} has ambiguous active overlays: {sorted(active)}")
    return releases


def effective_release_heads(
    project: Path,
    statuses: Iterable[str] = ("planned", "qa", "published"),
) -> list[str]:
    releases = validate_release_graph(project)
    allowed = set(statuses)
    selected = {
        release_id for release_id, release in releases.items()
        if release.get("status") in allowed
    }
    superseded = {
        release.get("supersedes") for release_id, release in releases.items()
        if release_id in selected and release.get("supersedes") in selected
    }
    return sorted(selected - superseded)


def _validate_acceptance_lock(
    project: Path,
    release: dict[str, Any],
    base_release_id: str,
    base_batches: list[tuple[Path, dict[str, Any]]],
) -> Path:
    lock_path = _repo_path(project, release.get("acceptance_lock_path"), f"release {release['id']}.acceptance_lock_path")
    lock = _load_json(lock_path)
    _expect(
        set(lock) == {"schema_version", "release_id", "accepted_at", "approver", "artifacts"},
        f"{lock_path} has unknown or missing fields",
    )
    _expect(lock.get("schema_version") == 1, f"{lock_path} has unsupported schema_version")
    _expect(lock.get("release_id") == base_release_id, f"{lock_path} locks the wrong release")
    try:
        accepted_at = datetime.fromisoformat(lock.get("accepted_at"))
    except (TypeError, ValueError) as error:
        raise EffectiveReleaseError(f"{lock_path}.accepted_at must be an ISO-8601 timestamp") from error
    _expect(accepted_at.tzinfo is not None, f"{lock_path}.accepted_at must include a timezone")
    _expect(bool(str(lock.get("approver") or "").strip()), f"{lock_path} has no approver")
    artifacts = lock.get("artifacts")
    _expect(isinstance(artifacts, list) and artifacts, f"{lock_path} has no locked artifacts")

    expected_paths = {path.resolve() for path, _ in base_batches}
    locked_paths: set[Path] = set()
    for index, artifact in enumerate(artifacts):
        label = f"{lock_path} artifact {index + 1}"
        _expect(isinstance(artifact, dict), f"{label} must be an object")
        _expect(set(artifact) == {"path", "sha256", "record_count"}, f"{label} has unknown or missing fields")
        path = _repo_path(project, artifact.get("path"), f"{label}.path")
        _expect(path not in locked_paths, f"{lock_path} locks {path} more than once")
        locked_paths.add(path)
        expected_hash = artifact.get("sha256")
        _expect(isinstance(expected_hash, str) and HASH.fullmatch(expected_hash) is not None, f"{label}.sha256 is invalid")
        _expect(path.exists(), f"locked artifact {path} is missing")
        _expect(file_sha256(path) == expected_hash, f"immutable accepted artifact drifted: {path}")
        batch = next((item for item_path, item in base_batches if item_path.resolve() == path), None)
        _expect(batch is not None, f"{lock_path} contains a non-base artifact {path}")
        _expect(artifact.get("record_count") == len(batch.get("records", [])), f"{label}.record_count does not match the batch")
    _expect(locked_paths == expected_paths, f"{lock_path} must lock every and only the base release batches")
    return lock_path


def _validate_overlay_metadata(
    path: Path,
    overlay: dict[str, Any],
    release: dict[str, Any],
    base_release_id: str,
) -> None:
    _expect(set(overlay) == OVERLAY_REQUIRED_FIELDS, f"{path} must contain exactly {sorted(OVERLAY_REQUIRED_FIELDS)}")
    _expect(overlay.get("schema_version") == 1, f"{path} has unsupported schema_version")
    for field, registry_field in (
        ("release_id", "id"),
        ("version", "version"),
        ("status", "status"),
        ("work_package", "work_package"),
        ("dataset", "dataset"),
        ("base_release_id", "base_release_id"),
        ("supersedes", "supersedes"),
        ("base_batch_sha256", "base_batch_sha256"),
        ("qa", "qa"),
    ):
        _expect(overlay.get(field) == release.get(registry_field), f"{path}.{field} does not match releases.json")
    _expect(overlay.get("base_release_id") == base_release_id, f"{path} has the wrong base release")
    base_hash = overlay.get("base_batch_sha256")
    _expect(isinstance(base_hash, str) and HASH.fullmatch(base_hash) is not None, f"{path}.base_batch_sha256 is invalid")
    qa = overlay.get("qa")
    _expect(isinstance(qa, dict) and set(qa) == set(GATES), f"{path}.qa must contain all seven gates")
    _expect(all(value in QA_RESULTS for value in qa.values()), f"{path}.qa contains an unsupported result")
    if overlay.get("status") == "published":
        _expect(all(qa[gate] == "passed" for gate in GATES), f"published overlay {path} has incomplete QA")


def _validate_evidence(path: Path, overlay: dict[str, Any]) -> dict[str, dict[str, Any]]:
    evidence = overlay.get("evidence")
    _expect(isinstance(evidence, list) and evidence, f"{path}.evidence must not be empty")
    result: dict[str, dict[str, Any]] = {}
    for index, item in enumerate(evidence):
        label = f"{path}.evidence[{index}]"
        _expect(isinstance(item, dict), f"{label} must be an object")
        _expect(set(item) == {"id", "kind", "url", "checked_at", "note"}, f"{label} has unknown or missing fields")
        evidence_id = item.get("id")
        _expect(isinstance(evidence_id, str) and STABLE_ID.fullmatch(evidence_id) is not None, f"{label}.id is invalid")
        _expect(evidence_id not in result, f"duplicate overlay evidence ID {evidence_id}")
        _expect(item.get("kind") in EVIDENCE_KINDS, f"{label}.kind is invalid")
        _expect(_is_https(item.get("url")), f"{label}.url must be HTTPS")
        _expect(_parse_date(item.get("checked_at"), f"{label}.checked_at") <= date.today(), f"{label}.checked_at is in the future")
        _expect(bool(str(item.get("note") or "").strip()), f"{label}.note is empty")
        result[evidence_id] = item
    return result


def resolve_release(
    project: Path,
    release_id: str,
    *,
    _releases: dict[str, dict[str, Any]] | None = None,
    _batches: dict[str, list[tuple[Path, dict[str, Any]]]] | None = None,
    _stack: tuple[str, ...] = (),
) -> EffectiveRelease:
    project = project.resolve()
    releases = _releases or validate_release_graph(project)
    batches = _batches or _batch_catalog(project)
    _expect(release_id in releases, f"unknown Data Release {release_id}")
    _expect(release_id not in _stack, f"release overlay cycle includes {release_id}")
    release = releases[release_id]
    overlay_path_value = release.get("overlay_path")

    if overlay_path_value is None:
        entries = batches.get(release_id, [])
        _expect(bool(entries), f"release {release_id} has no batch JSON")
        records: list[dict[str, Any]] = []
        sources: dict[str, str] = {}
        paths: list[Path] = []
        for path, batch in entries:
            paths.append(path)
            batch_records = batch.get("records")
            _expect(isinstance(batch_records, list) and batch_records, f"{path} has no records")
            for index, record in enumerate(batch_records):
                _expect(isinstance(record, dict), f"{path} record {index + 1} must be an object")
                entity_id = record.get("id")
                _expect(isinstance(entity_id, str) and STABLE_ID.fullmatch(entity_id) is not None, f"{path} record {index + 1} has invalid ID")
                _expect(entity_id not in sources, f"release {release_id} has duplicate entity ID {entity_id}")
                records.append(record)
                sources[entity_id] = f"{path} record {index + 1}"
        return EffectiveRelease(
            release_id=release_id,
            release=release,
            records=tuple(records),
            record_sources=sources,
            batch_paths=tuple(paths),
            input_paths=tuple(paths),
            replacement_count=0,
        )

    base_release_id = release.get("base_release_id")
    _expect(isinstance(base_release_id, str), f"overlay release {release_id} has no base_release_id")
    base = resolve_release(
        project,
        base_release_id,
        _releases=releases,
        _batches=batches,
        _stack=(*_stack, release_id),
    )
    _expect(len(base.batch_paths) == 1, f"overlay release {release_id} requires exactly one immutable base batch")
    _expect(file_sha256(base.batch_paths[0]) == release.get("base_batch_sha256"), f"release {release_id} base_batch_sha256 does not match its base batch")
    lock_path = _validate_acceptance_lock(project, release, base_release_id, list(zip(base.batch_paths, [_load_json(path) for path in base.batch_paths])))

    overlay_path = _repo_path(project, overlay_path_value, f"release {release_id}.overlay_path")
    overlay = _load_json(overlay_path)
    _validate_overlay_metadata(overlay_path, overlay, release, base_release_id)
    evidence = _validate_evidence(overlay_path, overlay)

    records_by_id = {record["id"]: record for record in base.records}
    _expect(len(records_by_id) == len(base.records), f"base release {base_release_id} contains duplicate entity IDs")
    replacements = overlay.get("replacements")
    _expect(isinstance(replacements, list) and replacements, f"{overlay_path}.replacements must not be empty")
    replacement_ids: set[str] = set()
    replacement_sources = dict(base.record_sources)
    for index, replacement in enumerate(replacements):
        label = f"{overlay_path}.replacements[{index}]"
        _expect(isinstance(replacement, dict), f"{label} must be an object")
        _expect(set(replacement) == REPLACEMENT_REQUIRED_FIELDS, f"{label} has unknown or missing fields")
        entity_id = replacement.get("entity_id")
        _expect(entity_id in records_by_id, f"{label} references unknown base entity {entity_id}")
        _expect(entity_id not in replacement_ids, f"duplicate overlay replacement for {entity_id}")
        replacement_ids.add(entity_id)
        original = records_by_id[entity_id]
        original_hash = replacement.get("original_canonical_sha256")
        replacement_hash = replacement.get("replacement_canonical_sha256")
        _expect(isinstance(original_hash, str) and HASH.fullmatch(original_hash) is not None, f"{label}.original_canonical_sha256 is invalid")
        _expect(isinstance(replacement_hash, str) and HASH.fullmatch(replacement_hash) is not None, f"{label}.replacement_canonical_sha256 is invalid")
        _expect(canonical_sha256(original) == original_hash, f"{label} original canonical hash does not match the immutable base entity")
        record = replacement.get("record")
        _expect(isinstance(record, dict), f"{label}.record must be a full entity object")
        _expect(ENTITY_REQUIRED_FIELDS <= set(record), f"{label}.record is partial; missing {sorted(ENTITY_REQUIRED_FIELDS - set(record))}")
        _expect(record.get("id") == entity_id, f"{label}.record changes the stable entity ID")
        _expect(canonical_sha256(record) == replacement_hash, f"{label} replacement canonical hash is invalid")
        _expect(canonical_sha256(record) != original_hash, f"{label} does not change the entity")
        _expect(bool(str(replacement.get("reason") or "").strip()), f"{label}.reason is empty")
        refs = replacement.get("evidence_refs")
        _expect(isinstance(refs, list) and refs, f"{label}.evidence_refs must not be empty")
        _expect(len(refs) == len(set(refs)) and all(ref in evidence for ref in refs), f"{label} has duplicate or unresolved evidence references")
        records_by_id[entity_id] = record
        replacement_sources[entity_id] = f"{overlay_path} replacement {index + 1}"

    effective_records = tuple(records_by_id[record["id"]] for record in base.records)
    _expect(len(effective_records) == len(base.records), f"overlay release {release_id} changed the effective record count")
    return EffectiveRelease(
        release_id=release_id,
        release=release,
        records=effective_records,
        record_sources=replacement_sources,
        batch_paths=base.batch_paths,
        input_paths=(*base.input_paths, lock_path, overlay_path),
        replacement_count=len(replacements),
        overlay=overlay,
    )
