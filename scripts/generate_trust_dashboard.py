#!/usr/bin/env python3
"""Generate the evidence-aware Trust Dashboard and readiness scorecard."""

from __future__ import annotations

import json
import os
import statistics
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

from effective_release import effective_release_heads, resolve_release
from governance_contract import confidence_score, effective_status


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
REPORTS = PROJECT / "reports"
ADMIN_OUTPUT = ROOT / "admin-dashboard/src/generated/trust-dashboard.json"
PUBLIC_WEB_OUTPUT = ROOT / "admin-dashboard/public-site/src/generated/trust-dashboard.json"


def load_json(path: Path, fallback: Any) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return fallback


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def load_records() -> list[dict[str, Any]]:
    records = []
    for release_id in effective_release_heads(PROJECT):
        records.extend(resolve_release(PROJECT, release_id).records)
    return records


def envelope(record: dict[str, Any]) -> dict[str, Any] | None:
    value = record.get("governance")
    return value if isinstance(value, dict) else None


def metric(
    value: float | int | None,
    numerator: float | int | None,
    denominator: float | int | None,
    formula: str,
    source: str,
    generated_at: str,
    evidence_state: str | None = None,
    formula_version: int = 1,
) -> dict[str, Any]:
    if evidence_state is None:
        evidence_state = "established" if value is not None else "not_established"
    return {
        "value": value,
        "numerator": numerator,
        "denominator": denominator,
        "formula": formula,
        "formulaVersion": formula_version,
        "sourceArtifact": source,
        "generatedAt": generated_at,
        "evidenceState": evidence_state,
    }


def percentage(
    records: list[dict[str, Any]],
    predicate: Callable[[dict[str, Any]], bool],
    formula: str,
    source: str,
    generated_at: str,
) -> dict[str, Any]:
    denominator = len(records)
    if denominator == 0:
        return metric(None, None, None, formula, source, generated_at)
    numerator = sum(predicate(record) for record in records)
    return metric(round(numerator / denominator * 100, 1), numerator, denominator, formula, source, generated_at)


def production_ready(record: dict[str, Any], now: datetime) -> bool:
    governance = envelope(record)
    if not governance:
        return False
    return (
        governance.get("publicationStatus") == "published"
        and effective_status(governance, now) in {"verified", "review_due_soon"}
        and governance.get("jurisdiction", {}).get("applicabilityVerified") is True
        and str(governance.get("officialSourceURL") or "").startswith("https://")
    )


def readiness_dimension(
    components: list[dict[str, Any]],
    formula: str,
    generated_at: str,
    source: str,
) -> dict[str, Any]:
    if not components or any(
        component["evidenceState"] != "established" or component["value"] is None
        for component in components
    ):
        return metric(None, None, None, formula, source, generated_at)
    return metric(
        min(float(component["value"]) for component in components),
        None,
        None,
        formula,
        source,
        generated_at,
    )


def main() -> None:
    generated_override = os.getenv("GOVERNANCE_GENERATED_AT")
    if generated_override:
        now = datetime.fromisoformat(generated_override.replace("Z", "+00:00")).astimezone(timezone.utc)
    else:
        now = datetime.now(timezone.utc)
    generated_at = now.replace(microsecond=0).isoformat().replace("+00:00", "Z")
    records = load_records()
    governed = [record for record in records if envelope(record)]
    source_reliability = load_json(REPORTS / "source-reliability.json", {})
    data_health = load_json(REPORTS / "data-health.json", {})
    targets = load_json(PROJECT / "coverage-targets.json", {"targets": []})
    registry = load_json(PROJECT / "governance/municipality-registry.json", {})
    topic_policy = load_json(PROJECT / "governance/municipality-topic-policy.json", {})
    research = load_json(PROJECT / "research/user-outcome-study-status.json", {})
    ai_manifest = load_json(PROJECT / "ai-evaluation/manifest.json", {})
    semantic_report = load_json(REPORTS / "semantic-duplicate-candidates.json", None)

    statuses = {
        record["id"]: effective_status(envelope(record), now)
        for record in governed
    }
    verified = percentage(
        records,
        lambda record: record.get("id") in statuses
        and statuses[record["id"]] in {"verified", "review_due_soon"},
        "governed verified or review_due_soon records / canonical records",
        "DataProject/schema/content-governance.schema.json",
        generated_at,
    )
    fresh = percentage(
        records,
        lambda record: record.get("id") in statuses
        and statuses[record["id"]] in {"verified", "review_due_soon"},
        "fresh governed records / canonical records",
        "DataProject/governance/status-policy.json",
        generated_at,
    )
    public_coverage = percentage(
        records,
        lambda record: record.get("lifecycle_status") == "published",
        "legacy/public canonical records / canonical records",
        "DataProject/releases/releases.json",
        generated_at,
    )
    governed_public = percentage(
        records,
        lambda record: production_ready(record, now),
        "production-ready governed public records / canonical records",
        "DataProject/schema/content-governance.schema.json",
        generated_at,
    )
    ai_coverage = percentage(
        records,
        lambda record: production_ready(record, now)
        and len(str(record.get("ai_summary") or "").strip()) >= 40,
        "AI-summary records eligible for governed retrieval / canonical records",
        "DataProject/governance/status-policy.json",
        generated_at,
    )

    scores = [confidence_score(envelope(record), now) for record in governed]
    average_confidence = metric(
        round(statistics.mean(scores), 1) if scores else None,
        sum(scores) if scores else None,
        len(scores) if scores else None,
        "mean governed record evidence coverage index; not probability",
        "DataProject/governance/status-policy.json",
        generated_at,
    )
    median_confidence = metric(
        round(statistics.median(scores), 1) if scores else None,
        None,
        len(scores) if scores else None,
        "median governed record evidence coverage index; not probability",
        "DataProject/governance/status-policy.json",
        generated_at,
    )

    target_denominator = sum(int(target.get("target") or 0) for target in targets.get("targets", []))
    inventory_coverage = metric(
        round(len(records) / target_denominator * 100, 1) if target_denominator else None,
        len(records),
        target_denominator or None,
        "canonical inventory records / existing coverage-target total",
        "DataProject/coverage-targets.json",
        generated_at,
    )
    production_ready_coverage = metric(
        round(sum(production_ready(record, now) for record in records) / target_denominator * 100, 1)
        if target_denominator else None,
        sum(production_ready(record, now) for record in records),
        target_denominator or None,
        "production-ready records / existing coverage-target total",
        "DataProject/coverage-targets.json",
        generated_at,
    )

    municipality_global = metric(
        None,
        None,
        None,
        "production-ready municipality-topic cells / official registry municipality-topic cells",
        "DataProject/governance/municipality-registry.json",
        generated_at,
        evidence_state="not_established" if not registry.get("denominatorEstablished") else "established",
    )
    pilot_municipalities = registry.get("pilotScope", {}).get("municipalityCodes", [])
    pilot_topics = topic_policy.get("requiredTopicFamilies", [])
    pilot_denominator = len(pilot_municipalities) * len(pilot_topics)
    pilot_ready = 0
    for topic in pilot_topics:
        if any(
            record.get("id") in set(topic.get("candidateRecordIDs", []))
            and production_ready(record, now)
            and (
                envelope(record).get("jurisdiction", {}).get("municipalityCode") in pilot_municipalities
                or envelope(record).get("jurisdiction", {}).get("municipalityDependent") is False
            )
            for record in records
        ):
            pilot_ready += 1
    municipality_pilot = metric(
        round(pilot_ready / pilot_denominator * 100, 1) if pilot_denominator else None,
        pilot_ready,
        pilot_denominator or None,
        "production-ready pilot municipality-topic cells / pilot required cells",
        "DataProject/governance/municipality-topic-policy.json",
        generated_at,
    )

    source_trust = metric(
        source_reliability.get("source_trust_score"),
        None,
        source_reliability.get("records"),
        "separate publisher/source reliability score; not record confidence",
        "DataProject/reports/source-reliability.json",
        generated_at,
        evidence_state=(
            "provisional"
            if source_reliability.get("score_status") == "provisional"
            else "established" if source_reliability.get("source_trust_score") is not None
            else "not_established"
        ),
    )
    semantic_candidates = metric(
        len(semantic_report.get("candidates", [])) if semantic_report else None,
        len(semantic_report.get("candidates", [])) if semantic_report else None,
        semantic_report.get("compatiblePairCount") if semantic_report else None,
        "review-only candidates with cosine similarity >= 0.90",
        "DataProject/reports/semantic-duplicate-candidates.json",
        generated_at,
    )
    review_queue = metric(
        None,
        None,
        None,
        "open Supabase review tasks",
        "public.content_review_tasks",
        generated_at,
    )

    critical_ids = {
        record_id
        for topic in pilot_topics
        if topic.get("critical")
        for record_id in topic.get("candidateRecordIDs", [])
    }
    critical_records = [record for record in records if record.get("id") in critical_ids]
    critical_acceptable = percentage(
        critical_records,
        lambda record: production_ready(record, now),
        "production-ready critical records / required critical records",
        "DataProject/governance/municipality-topic-policy.json",
        generated_at,
    )
    reachable_official = percentage(
        records,
        lambda record: (
            isinstance(record.get("official_source"), dict)
            and record["official_source"].get("is_official") is True
            and record["official_source"].get("status") == "verified_opened"
        ),
        "legacy opened official sources / canonical records",
        "DataProject/reports/source-reliability.json",
        generated_at,
    )

    research_metric = metric(
        round(research.get("validCompletedObservations", 0) / research.get("plannedObservations", 20) * 100, 1)
        if research.get("plannedObservations") else None,
        research.get("validCompletedObservations"),
        research.get("plannedObservations"),
        "valid completed observations / 20 planned observations",
        research.get("sourceArtifact", "docs/user-validation/RESEARCH_PROTOCOL.md"),
        generated_at,
        evidence_state=research.get("evidenceState", "not_established"),
    )
    ai_dimension = metric(
        None,
        0,
        ai_manifest.get("totalCases"),
        "minimum pass rate among critical AI objectives",
        "DataProject/ai-evaluation/manifest.json",
        generated_at,
    )
    ux_dimension = metric(
        None,
        None,
        20,
        "minimum completion, within-time, source-open and no-human-help rates",
        "DataProject/research/user-outcome-study-status.json",
        generated_at,
    )
    governance_dimension = metric(
        None,
        None,
        None,
        "minimum owner, freshness, version-history and review-SLA compliance",
        "public.content_governance_health_summary",
        generated_at,
    )
    dimensions = {
        "trust": readiness_dimension(
            [critical_acceptable, reachable_official, median_confidence],
            "minimum critical acceptable status, reachable official sources and median confidence",
            generated_at,
            "DataProject/reports/trust-dashboard.json",
        ),
        "knowledge": readiness_dimension(
            [production_ready_coverage, municipality_global],
            "minimum production-ready topic and municipality coverage",
            generated_at,
            "DataProject/reports/trust-dashboard.json",
        ),
        "ai": ai_dimension,
        "ux": ux_dimension,
        "governance": governance_dimension,
        "research": research_metric,
    }
    established_values = [
        dimension["value"]
        for dimension in dimensions.values()
        if dimension["evidenceState"] == "established" and dimension["value"] is not None
    ]
    all_established = len(established_values) == len(dimensions)
    overall = metric(
        min(established_values) if all_established else None,
        None,
        None,
        "minimum of all established readiness dimensions",
        "DataProject/reports/trust-dashboard.json",
        generated_at,
    )

    top_risks = []
    for record in critical_records:
        if not production_ready(record, now):
            top_risks.append({
                "priority": 3,
                "type": "critical_municipality_coverage_missing",
                "recordID": record["id"],
                "title": record.get("title"),
                "evidenceState": "established",
            })
    broken_count = data_health.get("issues", {}).get("governed_broken_links")
    if broken_count:
        top_risks.append({
            "priority": 5,
            "type": "repeated_or_broken_sources",
            "count": broken_count,
            "evidenceState": "established",
        })

    dashboard = {
        "schemaVersion": 1,
        "title": "YouNew Trust Dashboard",
        "generatedAt": generated_at,
        "currentReleaseAuthority": "NO_GO",
        "releaseAuthorityReason": (
            "End-to-end validation and the User Outcome study are not complete; "
            "critical governance, AI and municipality denominators are not established."
        ),
        "metrics": {
            "verified": verified,
            "fresh": fresh,
            "overdue": metric(
                sum(status == "overdue" for status in statuses.values()),
                sum(status == "overdue" for status in statuses.values()),
                len(governed) if governed else None,
                "overdue governed records / governed records",
                "DataProject/governance/status-policy.json",
                generated_at,
            ),
            "disputed": metric(
                sum(status == "disputed" for status in statuses.values()),
                sum(status == "disputed" for status in statuses.values()),
                len(governed) if governed else None,
                "disputed governed records",
                "DataProject/governance/status-policy.json",
                generated_at,
            ),
            "sourceUnavailable": metric(
                sum(status == "source_unavailable" for status in statuses.values()),
                sum(status == "source_unavailable" for status in statuses.values()),
                len(governed) if governed else None,
                "source-unavailable governed records",
                "DataProject/governance/status-policy.json",
                generated_at,
            ),
            "reviewQueue": review_queue,
            "aiCoverage": ai_coverage,
            "publicCoverage": public_coverage,
            "governedPublicCoverage": governed_public,
            "municipalityCoverage": municipality_global,
            "pilotMunicipalityCoverage": municipality_pilot,
            "averageConfidence": average_confidence,
            "medianConfidence": median_confidence,
            "sourceTrustScore": source_trust,
            "semanticDuplicateCandidates": semantic_candidates,
        },
        "knowledgeCoverage": {
            "inventory": inventory_coverage,
            "verified": verified,
            "productionReady": production_ready_coverage,
            "public": public_coverage,
            "municipalityTopic": municipality_global,
            "pilotMunicipalityTopic": municipality_pilot,
        },
        "readiness": {
            "dimensions": dimensions,
            "overall": overall,
            "hardGates": {
                "contentGovernance": False,
                "ai": False,
                "userOutcome": False,
            },
            "status": "NO_GO",
        },
        "topRiskAreas": sorted(top_risks, key=lambda risk: (risk["priority"], risk.get("recordID", ""))),
        "limitations": [
            "Missing ContentGovernanceEnvelope is treated as unverified.",
            "The national municipality denominator is not established.",
            "Supabase review-queue metrics are unavailable until the additive migration is approved and applied.",
            "Semantic model dependencies are not fully locked and no calibrated report exists.",
            "All 1,000 AI evaluation cases still require human approval.",
        ],
    }
    write_json(REPORTS / "trust-dashboard.json", dashboard)
    write_json(ADMIN_OUTPUT, dashboard)
    write_json(PUBLIC_WEB_OUTPUT, dashboard)

    lines = [
        "# YouNew Trust Dashboard",
        "",
        f"Generated: `{generated_at}`",
        "",
        f"Release authority: **{dashboard['currentReleaseAuthority']}**",
        "",
        dashboard["releaseAuthorityReason"],
        "",
        "## Readiness",
        "",
        "| Dimension | Value | Evidence |",
        "| --- | ---: | --- |",
    ]
    for key, value in dimensions.items():
        rendered = "not established" if value["value"] is None else f"{value['value']}%"
        lines.append(f"| {key.title()} | {rendered} | {value['evidenceState']} |")
    lines += [
        f"| Overall | {'not established' if overall['value'] is None else str(overall['value']) + '%'} | {overall['evidenceState']} |",
        "",
        "## Critical limitations",
        "",
    ]
    lines.extend(f"- {item}" for item in dashboard["limitations"])
    (REPORTS / "trust-dashboard.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        f"Trust Dashboard generated: records={len(records)}, governed={len(governed)}, "
        f"overall={overall['evidenceState']}, release=NO_GO"
    )


if __name__ == "__main__":
    main()
