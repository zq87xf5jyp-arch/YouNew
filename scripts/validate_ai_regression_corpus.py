#!/usr/bin/env python3
"""Validate corpus composition and keep unapproved cases out of release gates."""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "DataProject/ai-evaluation/manifest.json"
CORPUS_PATH = ROOT / "DataProject/ai-evaluation/corpus-v1.jsonl"


def fail(message: str) -> None:
    raise SystemExit(f"AI regression corpus validation failed: {message}")


def load_cases() -> list[dict]:
    cases = []
    for line_number, line in enumerate(CORPUS_PATH.read_text(encoding="utf-8").splitlines(), 1):
        try:
            cases.append(json.loads(line))
        except json.JSONDecodeError as error:
            fail(f"line {line_number} is invalid JSON: {error}")
    return cases


def known_record_ids() -> set[str]:
    result = set()
    for path in (ROOT / "DataProject/batches").glob("**/*.json"):
        document = json.loads(path.read_text(encoding="utf-8"))
        result.update(record["id"] for record in document.get("records", []) if record.get("id"))
    return result


def main() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    cases = load_cases()
    if len(cases) != manifest["totalCases"]:
        fail(f"expected {manifest['totalCases']} cases, found {len(cases)}")
    ids = [case.get("id") for case in cases]
    if len(ids) != len(set(ids)):
        fail("case IDs are not unique")
    for field, expected in (
        ("group", manifest["groups"]),
        ("language", manifest["languages"]),
        ("partition", manifest["partitions"]),
    ):
        actual = Counter(case.get(field) for case in cases)
        if actual != Counter(expected):
            fail(f"{field} distribution differs: {dict(actual)}")

    known_ids = known_record_ids()
    for case in cases:
        for key in ("question", "expected", "contentOrigin", "publicationStatus", "reviewStatus"):
            if key not in case:
                fail(f"{case['id']} is missing {key}")
        expected = case["expected"]
        for key in ("sourceIDs", "jurisdiction", "requiredWarnings", "behavior", "forbiddenClaims"):
            if key not in expected:
                fail(f"{case['id']} expected contract is missing {key}")
        unknown_sources = set(expected["sourceIDs"]) - known_ids
        if unknown_sources:
            fail(f"{case['id']} references unknown source IDs: {sorted(unknown_sources)}")
        if case["contentOrigin"] == "ai_generated_draft" and (
            case["publicationStatus"] != "draft"
            or case["humanApproved"]
            or case["releaseEligible"]
        ):
            fail(f"{case['id']} violates AI draft publication policy")

    approved = sum(case["humanApproved"] is True for case in cases)
    evidence_state = "established" if approved == len(cases) else "not_established"
    print(
        f"AI regression corpus valid: {len(cases)} cases; "
        f"human-approved={approved}; release evidence={evidence_state}"
    )


if __name__ == "__main__":
    main()
