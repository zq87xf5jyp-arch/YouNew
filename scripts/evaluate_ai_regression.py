#!/usr/bin/env python3
"""Compare baseline and candidate AI runs with deterministic release gates."""

from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "DataProject/ai-evaluation/manifest.json"
CORPUS_PATH = ROOT / "DataProject/ai-evaluation/corpus-v1.jsonl"
OBJECTIVES = ("source_ids", "citations", "source_status", "jurisdiction", "warnings_behavior", "explainability", "groundedness")


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def load_corpus() -> dict[str, dict[str, Any]]:
    return {
        case["id"]: case
        for case in (
            json.loads(line)
            for line in CORPUS_PATH.read_text(encoding="utf-8").splitlines()
        )
    }


def grade_result(case: dict[str, Any], result: dict[str, Any]) -> dict[str, bool | None]:
    expected = case["expected"]
    selected = set(result.get("selectedRecordIDs", []))
    expected_sources = set(expected["sourceIDs"])
    citations = {
        citation.get("recordID")
        for citation in result.get("citations", [])
        if isinstance(citation, dict) and str(citation.get("url", "")).startswith("https://")
    }
    selected_statuses = set(result.get("selectedStatuses", []))
    expected_jurisdiction = expected["jurisdiction"]
    actual_jurisdiction = result.get("jurisdiction", {})
    warnings = set(result.get("warnings", []))
    trace = result.get("decisionTrace", {})
    subjective = result.get("subjectiveGrade")
    subjective_valid = (
        isinstance(subjective, dict)
        and subjective.get("graderKind") == "independent"
        and subjective.get("blinded") is True
        and subjective.get("humanCalibrated") is True
        and bool(subjective.get("graderID"))
    )
    return {
        "source_ids": expected_sources.issubset(selected) if expected_sources else not selected,
        "citations": selected.issubset(citations),
        "source_status": not bool(
            selected_statuses & {"archived", "disputed", "source_unavailable", "unverified"}
        ),
        "jurisdiction": all(
            actual_jurisdiction.get(key) == value
            for key, value in expected_jurisdiction.items()
        ),
        "warnings_behavior": (
            set(expected["requiredWarnings"]).issubset(warnings)
            and result.get("behavior") == expected["behavior"]
        ),
        "explainability": (
            isinstance(trace.get("rankingFactors"), list)
            and isinstance(trace.get("excludedCandidateReasons"), dict)
            and all(trace.get(key) for key in ("policyVersion", "modelVersion", "contextVersion"))
        ),
        "groundedness": bool(subjective.get("grounded")) if subjective_valid else None,
    }


def percentile_95(values: list[float]) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    index = max(0, min(len(ordered) - 1, int(len(ordered) * 0.95) - 1))
    return ordered[index]


def summarize(cases: dict[str, dict[str, Any]], run: dict[str, Any]) -> dict[str, Any]:
    results = {result["caseID"]: result for result in run.get("results", [])}
    grades: dict[str, dict[str, bool | None]] = {}
    for case_id, case in cases.items():
        result = results.get(case_id)
        grades[case_id] = (
            grade_result(case, result)
            if result is not None and case.get("humanApproved") is True
            else {objective: None for objective in OBJECTIVES}
        )
    objectives = {}
    for objective in OBJECTIVES:
        established = [grade[objective] for grade in grades.values() if grade[objective] is not None]
        objectives[objective] = {
            "passed": sum(value is True for value in established),
            "denominator": len(established),
            "rate": (
                sum(value is True for value in established) / len(established)
                if established else None
            ),
            "evidenceState": "established" if len(established) == len(cases) else "not_established",
        }
    return {
        "objectives": objectives,
        "grades": grades,
        "p95LatencyMs": percentile_95([
            float(result["latencyMs"]) for result in results.values() if "latencyMs" in result
        ]),
        "totalCostUnits": sum(float(result.get("costUnits", 0)) for result in results.values()),
        "resultCount": len(results),
    }


def compare(
    cases: dict[str, dict[str, Any]],
    baseline_run: dict[str, Any],
    candidate_run: dict[str, Any],
    manifest: dict[str, Any],
) -> dict[str, Any]:
    blockers = []
    baseline_meta = baseline_run["run"]
    candidate_meta = candidate_run["run"]
    if baseline_meta.get("candidateKind") != "baseline" or candidate_meta.get("candidateKind") != "candidate":
        blockers.append("run_kind_mismatch")
    if baseline_meta.get("environmentDigest") != candidate_meta.get("environmentDigest"):
        blockers.append("environment_mismatch")
    if baseline_meta.get("corpusVersion") != candidate_meta.get("corpusVersion"):
        blockers.append("corpus_version_mismatch")

    baseline = summarize(cases, baseline_run)
    candidate = summarize(cases, candidate_run)
    objective_deltas = {}
    for objective in OBJECTIVES:
        baseline_rate = baseline["objectives"][objective]["rate"]
        candidate_rate = candidate["objectives"][objective]["rate"]
        delta = (
            candidate_rate - baseline_rate
            if baseline_rate is not None and candidate_rate is not None
            else None
        )
        objective_deltas[objective] = delta
        if delta is None:
            blockers.append(f"{objective}_not_established")
        elif delta < -(manifest["blockingRules"]["maximumObjectiveDropPercentagePoints"] / 100):
            blockers.append(f"{objective}_regression_over_1pp")

    critical_regressions = []
    for case_id, case in cases.items():
        if not case.get("critical"):
            continue
        for objective in OBJECTIVES:
            if baseline["grades"][case_id][objective] is True and candidate["grades"][case_id][objective] is not True:
                critical_regressions.append({"caseID": case_id, "objective": objective})
    if critical_regressions:
        blockers.append("critical_regression")

    minimum = manifest["blockingRules"]["groundednessCitationJurisdictionRefusalMinimum"]
    for objective in ("citations", "jurisdiction", "warnings_behavior", "groundedness"):
        rate = candidate["objectives"][objective]["rate"]
        if rate is None or rate < minimum:
            blockers.append(f"{objective}_below_98_percent")

    latency_regression = None
    if baseline["p95LatencyMs"] and candidate["p95LatencyMs"] is not None:
        latency_regression = candidate["p95LatencyMs"] / baseline["p95LatencyMs"] - 1
    cost_regression = None
    if baseline["totalCostUnits"]:
        cost_regression = candidate["totalCostUnits"] / baseline["totalCostUnits"] - 1
    exception_threshold = manifest["blockingRules"]["latencyOrCostRegressionExceptionThreshold"]
    if (
        (latency_regression is not None and latency_regression > exception_threshold)
        or (cost_regression is not None and cost_regression > exception_threshold)
    ) and not candidate_meta.get("exceptionADR"):
        blockers.append("latency_or_cost_exception_adr_required")

    blockers = sorted(set(blockers))
    return {
        "schemaVersion": 1,
        "baselineRunID": baseline_meta.get("runID"),
        "candidateRunID": candidate_meta.get("runID"),
        "baseline": {key: value for key, value in baseline.items() if key != "grades"},
        "candidate": {key: value for key, value in candidate.items() if key != "grades"},
        "objectiveDeltas": objective_deltas,
        "criticalRegressions": critical_regressions,
        "latencyRegression": latency_regression,
        "costRegression": cost_regression,
        "blockers": blockers,
        "releaseGate": "PASS" if not blockers else "BLOCK",
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = compare(
        load_corpus(),
        load_json(args.baseline),
        load_json(args.candidate),
        load_json(MANIFEST_PATH),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"AI regression gate: {report['releaseGate']}; blockers={len(report['blockers'])}")
    raise SystemExit(0 if report["releaseGate"] == "PASS" else 1)


if __name__ == "__main__":
    main()
