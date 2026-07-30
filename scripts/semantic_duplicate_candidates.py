#!/usr/bin/env python3
"""Offline, review-only semantic duplicate candidate detector.

The script never downloads a model. It requires a locally provisioned model
directory, a matching YouNew provenance marker and an allowlisted
safetensors/ONNX artifact digest.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
import math
import os
from datetime import datetime, timezone
from itertools import combinations
from pathlib import Path
from typing import Any, Iterable, Sequence


ROOT = Path(__file__).resolve().parents[1]
MODEL_CONFIG_PATH = ROOT / "DataProject/governance/semantic-duplicate-model.json"
DEFAULT_OUTPUT = ROOT / "DataProject/reports/semantic-duplicate-candidates.json"
PROVENANCE_MARKER = ".younew-model-provenance.json"


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def sha256_file(path: Path, chunk_size: int = 1024 * 1024) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(chunk_size):
            digest.update(chunk)
    return digest.hexdigest()


def validate_model_directory(model_path: Path, config: dict[str, Any]) -> dict[str, Any]:
    if not model_path.is_dir():
        raise ValueError(f"model path is not a directory: {model_path}")
    forbidden = tuple(config["runtime"]["forbiddenFileSuffixes"])
    unsafe = [
        str(path.relative_to(model_path))
        for path in model_path.rglob("*")
        if path.is_file() and path.suffix.casefold() in forbidden
    ]
    if unsafe:
        raise ValueError(f"forbidden model files present: {', '.join(sorted(unsafe))}")

    marker_path = model_path / PROVENANCE_MARKER
    if not marker_path.is_file():
        raise ValueError(f"missing {PROVENANCE_MARKER}")
    marker = read_json(marker_path)
    for key in ("repository", "revision"):
        if marker.get(key) != config.get(key):
            raise ValueError(f"model provenance {key} mismatch")

    verified = []
    for artifact in config["artifacts"]:
        artifact_path = model_path / artifact["path"]
        if not artifact_path.is_file():
            raise ValueError(f"missing model artifact {artifact['path']}")
        if artifact_path.stat().st_size != artifact["sizeBytes"]:
            raise ValueError(f"model artifact size mismatch for {artifact['path']}")
        actual_digest = sha256_file(artifact_path)
        if actual_digest != artifact["sha256"]:
            raise ValueError(f"model artifact digest mismatch for {artifact['path']}")
        verified.append({
            "path": artifact["path"],
            "sha256": actual_digest,
            "sizeBytes": artifact_path.stat().st_size
        })
    return {"marker": marker, "artifacts": verified}


def load_records(paths: Iterable[Path]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    seen: set[str] = set()
    for path in sorted(paths):
        document = read_json(path)
        candidates = document.get("records", []) if isinstance(document, dict) else []
        for record in candidates:
            record_id = record.get("id")
            if isinstance(record_id, str) and record_id not in seen:
                records.append(record)
                seen.add(record_id)
    return records


def record_text(record: dict[str, Any]) -> str:
    guide = record.get("practical_guide") if isinstance(record.get("practical_guide"), dict) else {}
    blocks: list[str] = [
        str(record.get("title") or ""),
        str(record.get("description") or ""),
        str(record.get("ai_summary") or ""),
        str(record.get("entity_type") or ""),
        str(record.get("category") or ""),
        str(guide.get("title") or ""),
    ]
    for key in ("search_keywords", "synonyms", "tags"):
        value = record.get(key) if key in record else guide.get(key)
        if isinstance(value, list):
            blocks.extend(str(item) for item in value if isinstance(item, str))
    for step in guide.get("numbered_steps", []) if isinstance(guide.get("numbered_steps"), list) else []:
        if isinstance(step, dict):
            blocks.extend(str(step.get(key) or "") for key in ("title", "text", "description"))
    return "passage: " + " | ".join(" ".join(block.split()) for block in blocks if block.strip())


def normalized_text(record: dict[str, Any]) -> str:
    return " ".join(record_text(record).casefold().split())


def jurisdiction_key(record: dict[str, Any]) -> tuple[str, bool, str | None]:
    governance = record.get("governance") if isinstance(record.get("governance"), dict) else {}
    jurisdiction = governance.get("jurisdiction") if isinstance(governance.get("jurisdiction"), dict) else {}
    municipality = (
        jurisdiction.get("municipalityCode")
        or jurisdiction.get("municipalityName")
        or record.get("city_id")
    )
    dependent = jurisdiction.get("municipalityDependent")
    if not isinstance(dependent, bool):
        dependent = True
    level = str(jurisdiction.get("level") or ("municipal" if municipality else "unknown"))
    return level, dependent, str(municipality).casefold() if municipality else None


def compatible_pair(left: dict[str, Any], right: dict[str, Any]) -> bool:
    if left.get("entity_type") != right.get("entity_type"):
        return False
    left_level, left_dependent, left_municipality = jurisdiction_key(left)
    right_level, right_dependent, right_municipality = jurisdiction_key(right)
    if left_municipality or right_municipality:
        if left_municipality == right_municipality:
            return True
        return (
            left_level == "national" and not left_dependent
        ) or (
            right_level == "national" and not right_dependent
        )
    return True


def compatible_pairs(records: Sequence[dict[str, Any]]):
    for left_index, right_index in combinations(range(len(records)), 2):
        left = records[left_index]
        right = records[right_index]
        if compatible_pair(left, right) and normalized_text(left) != normalized_text(right):
            yield left_index, right_index


def cosine_similarity(left: Sequence[float], right: Sequence[float]) -> float:
    if len(left) != len(right) or not left:
        raise ValueError("embeddings must have the same non-zero dimensions")
    dot = sum(a * b for a, b in zip(left, right))
    left_norm = math.sqrt(sum(value * value for value in left))
    right_norm = math.sqrt(sum(value * value for value in right))
    if left_norm == 0 or right_norm == 0:
        return 0.0
    return dot / (left_norm * right_norm)


def candidate_rows(
    records: Sequence[dict[str, Any]],
    embeddings: Sequence[Sequence[float]],
    threshold: float,
) -> list[dict[str, Any]]:
    candidates = []
    for left_index, right_index in compatible_pairs(records):
        similarity = cosine_similarity(embeddings[left_index], embeddings[right_index])
        if similarity >= threshold:
            left = records[left_index]
            right = records[right_index]
            candidates.append({
                "leftRecordID": left["id"],
                "rightRecordID": right["id"],
                "similarity": round(similarity, 6),
                "reviewTaskReason": "possible_duplicate",
                "automaticAction": "none",
                "humanDecision": None
            })
    return sorted(candidates, key=lambda row: (-row["similarity"], row["leftRecordID"], row["rightRecordID"]))


def encode_locally(model_path: Path, texts: list[str], expected_version: str):
    actual_version = importlib.metadata.version("sentence-transformers")
    if actual_version != expected_version:
        raise RuntimeError(
            f"sentence-transformers version mismatch: expected {expected_version}, got {actual_version}"
        )
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    from sentence_transformers import SentenceTransformer  # type: ignore

    model = SentenceTransformer(
        str(model_path),
        local_files_only=True,
        trust_remote_code=False,
    )
    return model.encode(
        texts,
        batch_size=32,
        show_progress_bar=False,
        normalize_embeddings=True,
    ).tolist()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-path", type=Path)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--preflight-only", action="store_true")
    args = parser.parse_args()

    config = read_json(MODEL_CONFIG_PATH)
    if args.preflight_only:
        print(
            f"Semantic duplicate policy preflight passed: "
            f"{config['repository']}@{config['revision']}; "
            f"threshold={config['candidatePolicy']['threshold']}"
        )
        return
    if args.model_path is None:
        raise SystemExit("--model-path is required; automatic model download is forbidden")

    verification = validate_model_directory(args.model_path.resolve(), config)
    batch_paths = (ROOT / "DataProject/batches").glob("**/*.json")
    records = load_records(batch_paths)
    texts = [record_text(record) for record in records]
    embeddings = encode_locally(
        args.model_path.resolve(),
        texts,
        config["runtime"]["sentenceTransformersVersion"],
    )
    threshold = float(config["candidatePolicy"]["threshold"])
    candidates = candidate_rows(records, embeddings, threshold)
    report = {
        "schemaVersion": 1,
        "generatedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "evidenceState": "candidate_review_only",
        "model": {
            "repository": config["repository"],
            "revision": config["revision"],
            "verification": verification,
        },
        "recordCount": len(records),
        "compatiblePairCount": sum(1 for _ in compatible_pairs(records)),
        "threshold": threshold,
        "automaticMergeAllowed": False,
        "automaticDeleteAllowed": False,
        "candidates": candidates,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(candidates)} review-only candidates to {args.output}")


if __name__ == "__main__":
    main()
