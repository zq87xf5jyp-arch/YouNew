#!/usr/bin/env python3
"""Build the non-publishing Priority-1 practical-guide editorial handoff.

The handoff joins the canonical 20 guide scaffolds with the two official-source
research dossiers. It deliberately does not write to runtime data, releases, or
the practical-guide staging collection. Use ``--write`` to refresh the checked-in
quality evidence and ``--check`` to fail if it is stale or non-deterministic.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
SCAFFOLDS_PATH = ROOT / "DataProject/staging/practical-guides-wave-1.json"
GOVERNMENT_PATH = (
    ROOT
    / "DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json"
)
DAILY_PATH = ROOT / "DataProject/research/priority-1-daily/priority-1-dossiers.json"
SCHEMA_PATH = ROOT / "DataProject/schema/entity.schema.json"
OUTPUT_JSON = ROOT / "DataProject/quality/priority-1-editorial-handoff.json"
OUTPUT_MD = ROOT / "DataProject/quality/priority-1-editorial-handoff.md"

WORKFLOW = [
    {
        "order": 1,
        "stage": "Draft",
        "entry_criteria": "Canonical scaffold exists and research remains non-publishing.",
        "exit_criteria": (
            "All factual blocks retain fact IDs and official source IDs; required schema v2 "
            "fields are drafted; locality and volatility gaps are explicit."
        ),
    },
    {
        "order": 2,
        "stage": "QA",
        "entry_criteria": "Draft exit criteria are met.",
        "exit_criteria": (
            "Schema, factual sources, links, language, media, duplicate-content, and "
            "accessibility checks all pass with recorded evidence."
        ),
    },
    {
        "order": 3,
        "stage": "Reviewer",
        "entry_criteria": "QA gate passed; no unresolved factual or locality blocker remains.",
        "exit_criteria": (
            "A named human editor or relevant subject-matter reviewer records identity, role, "
            "review date, and approval."
        ),
    },
    {
        "order": 4,
        "stage": "Publish",
        "entry_criteria": (
            "Reviewer approval and a passed publication gate exist; verified dates and "
            "official links are current."
        ),
        "exit_criteria": "Importer accepts the guide without bypassing fail-closed checks.",
    },
]

LOCALITY_TERMS = (
    "municip",
    "gemeente",
    "local",
    "region",
    "provider",
    "practice",
    "operator",
    "institution",
    "location",
    "city",
)


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise SystemExit(f"Missing required input: {path.relative_to(ROOT)}") from error
    except json.JSONDecodeError as error:
        raise SystemExit(f"Invalid JSON in {path.relative_to(ROOT)}: {error}") from error
    if not isinstance(value, dict):
        raise SystemExit(f"Expected an object in {path.relative_to(ROOT)}")
    return value


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def unique(values: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def require_unique(items: list[dict[str, Any]], key: str, label: str) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for item in items:
        item_id = item.get(key)
        if not isinstance(item_id, str) or not item_id:
            raise SystemExit(f"{label} contains an item without {key}")
        if item_id in result:
            raise SystemExit(f"Duplicate {label} {key}: {item_id}")
        result[item_id] = item
    return result


def source_ref_ids(fact: dict[str, Any]) -> list[str]:
    refs = fact.get("source_ids", [])
    if not isinstance(refs, list) or any(not isinstance(value, str) for value in refs):
        raise SystemExit(f"Fact {fact.get('id', '<unknown>')} has invalid source_ids")
    return unique(refs)


def normalized_fact(fact: dict[str, Any]) -> dict[str, Any]:
    normalized: dict[str, Any] = {
        "fact_id": fact["id"],
        "statement": fact["statement"],
        "source_ids": source_ref_ids(fact),
        "jurisdiction": fact.get("jurisdiction"),
        "research_status": fact.get("fact_status", "sourced_research_draft"),
    }
    for field in ("caveat", "caveats", "reverify_by", "valid_for_calendar_year"):
        if field in fact:
            normalized[field] = fact[field]
    return normalized


def normalized_source(source: dict[str, Any]) -> dict[str, Any]:
    normalized: dict[str, Any] = {
        "source_id": source["id"],
        "title": source.get("title"),
        "publisher": source.get("publisher"),
        "url": source.get("url"),
        "jurisdiction": source.get("jurisdiction"),
        "verified_at": source.get("verified_at"),
    }
    for field in ("language", "source_class", "verification_status", "page_last_updated"):
        if field in source:
            normalized[field] = source[field]
    return normalized


def validate_references(
    *,
    facts: list[dict[str, Any]],
    sources: list[dict[str, Any]],
    context: str,
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    fact_by_id = require_unique(facts, "id", f"{context} facts")
    source_by_id = require_unique(sources, "id", f"{context} sources")
    for fact in facts:
        if not fact.get("statement"):
            raise SystemExit(f"{context} fact {fact['id']} has no statement")
        refs = source_ref_ids(fact)
        if not refs:
            raise SystemExit(f"{context} fact {fact['id']} has no source IDs")
        unknown = [source_id for source_id in refs if source_id not in source_by_id]
        if unknown:
            raise SystemExit(f"{context} fact {fact['id']} references unknown sources: {unknown}")
        for source_id in refs:
            supported = source_by_id[source_id].get("supports_fact_ids", [])
            if supported and fact["id"] not in supported:
                raise SystemExit(
                    f"{context} source {source_id} does not map back to fact {fact['id']}"
                )
    for source in sources:
        url = source.get("url")
        if not isinstance(url, str) or not url.startswith("https://"):
            raise SystemExit(f"{context} source {source['id']} has no HTTPS URL")
        unknown_facts = [
            fact_id for fact_id in source.get("supports_fact_ids", []) if fact_id not in fact_by_id
        ]
        if unknown_facts:
            raise SystemExit(
                f"{context} source {source['id']} references unknown facts: {unknown_facts}"
            )
    return fact_by_id, source_by_id


def published_required_fields(schema: dict[str, Any]) -> list[str]:
    guide_schema = schema.get("$defs", {}).get("practicalGuide")
    if not isinstance(guide_schema, dict):
        raise SystemExit("Schema has no $defs.practicalGuide")
    fields = list(guide_schema.get("required", []))
    for condition in guide_schema.get("allOf", []):
        if condition.get("if", {}).get("properties", {}).get("status", {}).get("const") == "published":
            fields.extend(condition.get("then", {}).get("required", []))
    fields = unique(str(value) for value in fields)
    if not fields:
        raise SystemExit("Could not derive practical-guide publication fields from schema")
    return fields


def value_state(field: str, guide: dict[str, Any]) -> tuple[str, bool, int | None]:
    if field not in guide:
        return "missing", False, None
    value = guide[field]
    if field == "schema_version":
        return ("schema_v2" if value == 2 else f"schema_v{value}"), value == 2, None
    if field == "status":
        return str(value), False, None
    if value is None:
        return "null", False, None
    if isinstance(value, list):
        count = len(value)
        minimum = 3 if field == "faqs" else 2 if field == "tags" else 1
        return ("populated" if count >= minimum else "empty_or_below_minimum"), count >= minimum, count
    if isinstance(value, dict):
        if not value:
            return "empty", False, 0
        if field in {"estimated_time", "estimated_cost"}:
            refs = value.get("source_ids")
            ready = value.get("state") in {"known", "varies", "not_applicable"} and bool(refs)
            return ("sourced" if ready else "unknown_or_unsourced"), ready, len(refs or [])
        if field == "applicability":
            return "present", True, None
        if field == "publication_gate":
            checks = value.get("checks") or {}
            ready = value.get("status") == "passed" and bool(checks) and all(checks.values())
            return ("passed" if ready else "not_passed"), ready, None
        return "present", True, None
    if isinstance(value, str):
        ready = bool(value.strip())
        if field == "confidence_level":
            ready = value == "high"
        return ("populated" if ready else "empty_or_not_publishable"), ready, None
    return "present", True, None


def schema_readiness(guide: dict[str, Any], required_fields: list[str]) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []
    for field in required_fields:
        state, ready, count = value_state(field, guide)
        check: dict[str, Any] = {"field": field, "state": state, "ready": ready}
        if count is not None:
            check["count"] = count
        checks.append(check)
    ready_count = sum(1 for check in checks if check["ready"])
    missing_fields = [check["field"] for check in checks if not check["ready"]]
    return {
        "target_schema_version": 2,
        "ready": False,
        "ready_check_count": ready_count,
        "total_check_count": len(checks),
        "missing_or_unready_count": len(missing_fields),
        "missing_or_unready_fields": missing_fields,
        "checks": checks,
    }


def locality_evidence(jurisdiction: Any, gaps: list[str], variants: list[str]) -> dict[str, Any]:
    haystack = " ".join([str(jurisdiction or ""), *gaps]).lower()
    required = bool(variants) or any(term in haystack for term in LOCALITY_TERMS)
    return {
        "required": required,
        "researched_variants": variants,
        "complete": False if required else True,
        "note": (
            "Local execution, provider availability, or institution-specific instructions remain "
            "outside a single national procedure."
            if required
            else "No locality-specific branch was identified in the current dossier."
        ),
    }


def find_research(
    guide_id: str,
    government: dict[str, Any],
    daily: dict[str, Any],
) -> dict[str, Any] | None:
    for topic in government.get("topic_dossiers", []):
        if guide_id in topic.get("target_guide_ids", []):
            fact_by_id, source_by_id = validate_references(
                facts=government.get("facts", []),
                sources=government.get("sources", []),
                context="government dossier",
            )
            requested_fact_ids = unique(
                [*topic.get("national_fact_ids", []), *topic.get("municipal_fact_ids", [])]
            )
            unknown = [fact_id for fact_id in requested_fact_ids if fact_id not in fact_by_id]
            if unknown:
                raise SystemExit(f"Government topic {topic['id']} references unknown facts: {unknown}")
            facts = [normalized_fact(fact_by_id[fact_id]) for fact_id in requested_fact_ids]
            source_ids = sorted(unique(ref for fact in facts for ref in fact["source_ids"]))
            sources = [normalized_source(source_by_id[source_id]) for source_id in source_ids]
            return {
                "kind": "government_topic",
                "research_id": topic["id"],
                "input_path": str(GOVERNMENT_PATH.relative_to(ROOT)),
                "verified_at": government.get("verified_at"),
                "jurisdiction": topic.get("jurisdiction"),
                "facts": facts,
                "sources": sources,
                "gaps": list(topic.get("publication_blockers", [])),
                "municipal_variants_researched": list(topic.get("municipal_variants_researched", [])),
            }
    for dossier in daily.get("dossiers", []):
        if dossier.get("guide_id") == guide_id:
            _, source_by_id = validate_references(
                facts=dossier.get("facts", []),
                sources=dossier.get("sources", []),
                context=f"daily dossier {dossier.get('id')}",
            )
            facts = [normalized_fact(fact) for fact in dossier.get("facts", [])]
            source_ids = sorted(unique(ref for fact in facts for ref in fact["source_ids"]))
            sources = [normalized_source(source_by_id[source_id]) for source_id in source_ids]
            return {
                "kind": "daily_topic",
                "research_id": dossier["id"],
                "input_path": str(DAILY_PATH.relative_to(ROOT)),
                "verified_at": dossier.get("verified_at"),
                "jurisdiction": dossier.get("jurisdiction"),
                "facts": facts,
                "sources": sources,
                "gaps": list(dossier.get("gaps", [])),
                "municipal_variants_researched": [],
            }
    return None


def build_handoff() -> dict[str, Any]:
    scaffolds = load_json(SCAFFOLDS_PATH)
    government = load_json(GOVERNMENT_PATH)
    daily = load_json(DAILY_PATH)
    schema = load_json(SCHEMA_PATH)
    required_fields = published_required_fields(schema)

    if scaffolds.get("status") != "draft":
        raise SystemExit("Practical-guide scaffold collection must remain draft")
    if government.get("status") != "research_draft" or government.get("publication_authorized") is not False:
        raise SystemExit("Government dossier is not a fail-closed research draft")
    if daily.get("status") != "research_draft" or daily.get("publication_policy", {}).get("publishable") is not False:
        raise SystemExit("Daily dossier is not a fail-closed research draft")

    scaffold_items = scaffolds.get("guides", [])
    if not isinstance(scaffold_items, list) or len(scaffold_items) != 20:
        raise SystemExit(f"Expected exactly 20 guide scaffolds, found {len(scaffold_items)}")
    guide_ids = [item.get("practical_guide", {}).get("id") for item in scaffold_items]
    if any(not isinstance(guide_id, str) for guide_id in guide_ids):
        raise SystemExit("A practical-guide scaffold is missing its canonical ID")
    if len(set(guide_ids)) != len(guide_ids):
        raise SystemExit("Practical-guide scaffold IDs are not unique")
    if any(item.get("practical_guide", {}).get("status") != "draft" for item in scaffold_items):
        raise SystemExit("Every practical-guide scaffold must remain draft")

    known_ids = set(guide_ids)
    research_target_ids = {
        guide_id
        for topic in government.get("topic_dossiers", [])
        for guide_id in topic.get("target_guide_ids", [])
    } | {dossier.get("guide_id") for dossier in daily.get("dossiers", [])}
    unknown_targets = sorted(value for value in research_target_ids if value not in known_ids)
    if unknown_targets:
        raise SystemExit(f"Research dossiers target unknown guide IDs: {unknown_targets}")

    queue: list[dict[str, Any]] = []
    for item in scaffold_items:
        guide = item["practical_guide"]
        guide_id = guide["id"]
        research = find_research(guide_id, government, daily)
        readiness = schema_readiness(guide, required_fields)
        scaffold_gaps = list(item.get("publication_gaps", []))
        research_gaps = [] if research is None else list(research["gaps"])
        unresolved_gaps = unique([*scaffold_gaps, *research_gaps])
        facts = [] if research is None else research["facts"]
        sources = [] if research is None else research["sources"]
        source_ids = [source["source_id"] for source in sources]
        variants = [] if research is None else research["municipal_variants_researched"]
        locality = locality_evidence(
            None if research is None else research["jurisdiction"], unresolved_gaps, variants
        )

        faq_count = len(guide.get("faqs", []))
        step_count = len(guide.get("numbered_steps", []))
        asset_count = 0
        blockers: list[dict[str, Any]] = [
            {
                "code": "human_review_required",
                "category": "review",
                "detail": "No named human reviewer and review record are attached.",
            },
            {
                "code": "guide_media_with_alt_required",
                "category": "media",
                "detail": (
                    "No dedicated guide asset with verified provenance and non-empty alt text is "
                    "attached to this scaffold."
                ),
            },
            {
                "code": "schema_v2_incomplete",
                "category": "schema",
                "detail": (
                    f"{readiness['missing_or_unready_count']} of "
                    f"{readiness['total_check_count']} publication checks are not ready."
                ),
            },
        ]
        if research is None:
            blockers.append(
                {
                    "code": "official_research_dossier_missing",
                    "category": "research",
                    "detail": "No matching official-source research dossier is present.",
                }
            )
        if unresolved_gaps:
            blockers.append(
                {
                    "code": "unresolved_research_or_publication_gaps",
                    "category": "research",
                    "detail": f"{len(unresolved_gaps)} documented gaps remain unresolved.",
                }
            )
        if locality["required"]:
            blockers.append(
                {
                    "code": "locality_or_provider_branch_incomplete",
                    "category": "locality",
                    "detail": locality["note"],
                }
            )

        queue.append(
            {
                "guide_id": guide_id,
                "slug": guide["slug"],
                "title": guide["title"],
                "locale": guide["locale"],
                "queue_status": "research_draft" if research else "blocked",
                "publication_authorized": False,
                "scaffold_status": guide.get("status"),
                "source_entity_ids": list(item.get("source_entity_ids", [])),
                "research_input": (
                    None
                    if research is None
                    else {
                        "kind": research["kind"],
                        "research_id": research["research_id"],
                        "path": research["input_path"],
                        "verified_at": research["verified_at"],
                        "jurisdiction": research["jurisdiction"],
                    }
                ),
                "fact_count": len(facts),
                "fact_ids": [fact["fact_id"] for fact in facts],
                "facts": facts,
                "source_count": len(sources),
                "source_ids": source_ids,
                "sources": sources,
                "unresolved_gaps": unresolved_gaps,
                "locality_readiness": locality,
                "schema_v2_readiness": readiness,
                "missing_work": {
                    "faq_answer_records": {
                        "current": faq_count,
                        "minimum": 3,
                        "missing": max(0, 3 - faq_count),
                        "note": "Unsourced common_questions do not count as answered FAQ records.",
                    },
                    "numbered_steps": {
                        "current": step_count,
                        "minimum": 1,
                        "missing": max(0, 1 - step_count),
                        "note": "Research facts are not interpreted as procedural steps automatically.",
                    },
                    "guide_assets_with_alt": {
                        "current": asset_count,
                        "minimum": 1,
                        "missing": 1,
                        "note": "A candidate image does not count until provenance and alt text pass QA.",
                    },
                },
                "blockers": blockers,
                "next_allowed_stage": "Draft" if research else None,
            }
        )

    missing_research = [
        {
            "guide_id": item["guide_id"],
            "title": item["title"],
            "reason": "No matching official-source dossier exists in either research input.",
        }
        for item in queue
        if item["queue_status"] == "blocked"
    ]
    unique_fact_ids = sorted({fact_id for item in queue for fact_id in item["fact_ids"]})
    unique_source_ids = sorted({source_id for item in queue for source_id in item["source_ids"]})
    summary = {
        "guide_count": len(queue),
        "research_draft_count": sum(item["queue_status"] == "research_draft" for item in queue),
        "blocked_count": sum(item["queue_status"] == "blocked" for item in queue),
        "publication_authorized_count": 0,
        "guide_fact_assignment_count": sum(item["fact_count"] for item in queue),
        "unique_fact_count": len(unique_fact_ids),
        "guide_source_assignment_count": sum(item["source_count"] for item in queue),
        "unique_source_count": len(unique_source_ids),
        "faq_answer_records_missing": sum(
            item["missing_work"]["faq_answer_records"]["missing"] for item in queue
        ),
        "numbered_steps_missing": sum(
            item["missing_work"]["numbered_steps"]["missing"] for item in queue
        ),
        "guide_assets_with_alt_missing": sum(
            item["missing_work"]["guide_assets_with_alt"]["missing"] for item in queue
        ),
        "schema_v2_ready_count": sum(item["schema_v2_readiness"]["ready"] for item in queue),
        "human_reviews_missing": len(queue),
    }

    inputs = [SCAFFOLDS_PATH, GOVERNMENT_PATH, DAILY_PATH, SCHEMA_PATH]
    return {
        "handoff_id": "priority-1-practical-guides-editorial-handoff-2026-07-20",
        "schema_version": 1,
        "generated_for": "2026-07-20",
        "status": "research_draft",
        "publication_authorized": False,
        "purpose": (
            "Auditable, deterministic editorial queue joining canonical guide scaffolds to "
            "official-source research without publishing or interpreting research facts as steps."
        ),
        "source_policy": {
            "official_sources_only": True,
            "facts_require_source_ids": True,
            "fail_closed": True,
            "human_review_required": True,
        },
        "input_files": [
            {"path": str(path.relative_to(ROOT)), "sha256": sha256(path)} for path in inputs
        ],
        "workflow_name": "Draft→QA→Reviewer→Publish",
        "workflow": WORKFLOW,
        "summary": summary,
        "missing_research_topics": missing_research,
        "unique_fact_ids": unique_fact_ids,
        "unique_source_ids": unique_source_ids,
        "queue": queue,
    }


def markdown(handoff: dict[str, Any]) -> str:
    summary = handoff["summary"]
    lines = [
        "# Priority-1 editorial handoff",
        "",
        f"Generated for: `{handoff['generated_for']}`",
        "",
        "> **Non-publishing evidence.** Every item is `research_draft` or `blocked`; publication "
        "is not authorized. Research facts are not converted into procedural steps by this handoff.",
        "",
        "## Executive status",
        "",
        f"- Canonical guide scaffolds: **{summary['guide_count']}**",
        f"- Research drafts: **{summary['research_draft_count']}**",
        f"- Blocked without a matching dossier: **{summary['blocked_count']}**",
        f"- Schema v2 publication-ready guides: **{summary['schema_v2_ready_count']}**",
        f"- Unique sourced facts available for drafting: **{summary['unique_fact_count']}**",
        f"- Unique official source IDs: **{summary['unique_source_count']}**",
        f"- Answered FAQ records still missing: **{summary['faq_answer_records_missing']}**",
        f"- Numbered steps still missing: **{summary['numbered_steps_missing']}**",
        f"- Guide assets with verified alt text still missing: **{summary['guide_assets_with_alt_missing']}**",
        f"- Human reviews still missing: **{summary['human_reviews_missing']}**",
        "",
        "Assignment counts can exceed unique counts because a sourced fact or source can support more "
        "than one guide.",
        "",
        "## Workflow",
        "",
        f"`{handoff['workflow_name']}`",
        "",
    ]
    for stage in handoff["workflow"]:
        lines.extend(
            [
                f"{stage['order']}. **{stage['stage']}**",
                f"   - Entry: {stage['entry_criteria']}",
                f"   - Exit: {stage['exit_criteria']}",
            ]
        )

    lines.extend(["", "## Missing official research", ""])
    if handoff["missing_research_topics"]:
        for item in handoff["missing_research_topics"]:
            lines.append(f"- `{item['guide_id']}` — {item['title']}: {item['reason']}")
    else:
        lines.append("No guide is missing a matching research dossier.")

    lines.extend(
        [
            "",
            "## Queue summary",
            "",
            "| Guide | Status | Facts | Sources | Schema checks ready | FAQ missing | Steps missing | Assets missing |",
            "|---|---:|---:|---:|---:|---:|---:|---:|",
        ]
    )
    for item in handoff["queue"]:
        readiness = item["schema_v2_readiness"]
        missing = item["missing_work"]
        lines.append(
            f"| `{item['guide_id']}` | {item['queue_status']} | {item['fact_count']} | "
            f"{item['source_count']} | {readiness['ready_check_count']}/{readiness['total_check_count']} | "
            f"{missing['faq_answer_records']['missing']} | {missing['numbered_steps']['missing']} | "
            f"{missing['guide_assets_with_alt']['missing']} |"
        )

    lines.extend(["", "## Per-guide audit", ""])
    for item in handoff["queue"]:
        lines.extend(
            [
                f"### {item['title']}",
                "",
                f"- Canonical ID: `{item['guide_id']}`",
                f"- Queue status: `{item['queue_status']}`",
                f"- Publication authorized: `{str(item['publication_authorized']).lower()}`",
                f"- Research input: "
                + (
                    f"`{item['research_input']['research_id']}`"
                    if item["research_input"]
                    else "none"
                ),
                f"- Fact IDs ({item['fact_count']}): "
                + (", ".join(f"`{value}`" for value in item["fact_ids"]) or "none"),
                f"- Source IDs ({item['source_count']}): "
                + (", ".join(f"`{value}`" for value in item["source_ids"]) or "none"),
                f"- Schema v2 missing/unready fields ({item['schema_v2_readiness']['missing_or_unready_count']}): "
                + ", ".join(f"`{value}`" for value in item["schema_v2_readiness"]["missing_or_unready_fields"]),
                "- Blockers:",
            ]
        )
        for blocker in item["blockers"]:
            lines.append(f"  - `{blocker['code']}`: {blocker['detail']}")
        lines.append("- Unresolved gaps:")
        if item["unresolved_gaps"]:
            for gap in item["unresolved_gaps"]:
                lines.append(f"  - {gap}")
        else:
            lines.append("  - None recorded; this does not replace QA or human review.")
        lines.append("")

    lines.extend(["## Input evidence", ""])
    for item in handoff["input_files"]:
        lines.append(f"- `{item['path']}` — SHA-256 `{item['sha256']}`")
    lines.extend(
        [
            "",
            "## Allowed next action",
            "",
            "Editors may draft sourced schema v2 fields from the recorded facts, keeping every fact ID and "
            "source ID attached. No item may skip QA or named human review, and no status in this file is a "
            "publication status.",
            "",
        ]
    )
    return "\n".join(lines)


def serialized_outputs() -> tuple[str, str]:
    handoff = build_handoff()
    json_text = json.dumps(handoff, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    md_text = markdown(handoff)
    return json_text, md_text


def write_outputs(json_text: str, md_text: str) -> None:
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(json_text, encoding="utf-8")
    OUTPUT_MD.write_text(md_text, encoding="utf-8")
    print(f"Wrote {OUTPUT_JSON.relative_to(ROOT)}")
    print(f"Wrote {OUTPUT_MD.relative_to(ROOT)}")


def check_output(path: Path, expected: str) -> bool:
    if not path.exists():
        print(f"STALE: missing {path.relative_to(ROOT)}", file=sys.stderr)
        return False
    actual = path.read_text(encoding="utf-8")
    if actual != expected:
        print(f"STALE: regenerate {path.relative_to(ROOT)}", file=sys.stderr)
        return False
    print(f"OK: {path.relative_to(ROOT)}")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="Write deterministic JSON and Markdown evidence")
    mode.add_argument("--check", action="store_true", help="Check evidence matches current inputs")
    args = parser.parse_args()

    first_json, first_md = serialized_outputs()
    second_json, second_md = serialized_outputs()
    if (first_json, first_md) != (second_json, second_md):
        print("NON-DETERMINISTIC: consecutive in-memory builds differ", file=sys.stderr)
        return 2

    if args.write:
        write_outputs(first_json, first_md)
        return 0
    return 0 if all(
        [check_output(OUTPUT_JSON, first_json), check_output(OUTPUT_MD, first_md)]
    ) else 1


if __name__ == "__main__":
    raise SystemExit(main())
