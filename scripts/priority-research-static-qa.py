#!/usr/bin/env python3
"""Fail closed over the unpublished Priority-1 official-source research packets."""

from __future__ import annotations

import json
from datetime import date
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parents[1]
GOVERNMENT = ROOT / "DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json"
DAILY = ROOT / "DataProject/research/priority-1-daily/priority-1-dossiers.json"
SCAFFOLDS = ROOT / "DataProject/staging/practical-guides-wave-1.json"
ALLOWED_SOURCE_HOSTS = {
    "9292.nl",
    "business.gov.nl",
    "duo.nl",
    "ind.nl",
    "www.amsterdam.nl",
    "www.belastingdienst.nl",
    "www.digid.nl",
    "www.dnb.nl",
    "www.duo.nl",
    "www.government.nl",
    "www.hetcak.nl",
    "www.huurcommissie.nl",
    "www.kvk.nl",
    "www.netherlandsworldwide.nl",
    "www.ns.nl",
    "www.nza.nl",
    "www.politie.nl",
    "www.rijksoverheid.nl",
    "www.uwv.nl",
    "www.volkshuisvestingnederland.nl",
    "www.zorginstituutnederland.nl",
}


def fail(message: str):
    raise SystemExit(f"Priority research QA failed: {message}")


def expect(condition: bool, message: str):
    if not condition:
        fail(message)


def load(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read {path.relative_to(ROOT)}: {error}")


def valid_date(value: str, label: str):
    try:
        parsed = date.fromisoformat(value)
    except (TypeError, ValueError):
        fail(f"{label} is not an ISO date")
    expect(parsed <= date.today(), f"{label} is in the future")


def validate_source(source: dict, fact_ids: set[str], label: str):
    source_id = source.get("id")
    expect(isinstance(source_id, str) and source_id, f"{label} has no stable source ID")
    url = urlparse(source.get("url", ""))
    expect(url.scheme == "https" and not url.username and not url.password, f"{label} does not use a safe HTTPS URL")
    expect(url.hostname in ALLOWED_SOURCE_HOSTS, f"{label} uses an unapproved source host {url.hostname!r}")
    valid_date(source.get("verified_at"), f"{label}.verified_at")
    supports = source.get("supports_fact_ids")
    expect(isinstance(supports, list) and supports, f"{label} supports no facts")
    expect(len(supports) == len(set(supports)), f"{label} repeats supported fact IDs")
    expect(set(supports) <= fact_ids, f"{label} references unknown fact IDs")


def validate_fact(fact: dict, source_ids: set[str], label: str):
    expect(isinstance(fact.get("id"), str) and fact["id"], f"{label} has no stable fact ID")
    expect(isinstance(fact.get("statement"), str) and len(fact["statement"].strip()) >= 20, f"{label} has no substantive statement")
    references = fact.get("source_ids")
    expect(isinstance(references, list) and references, f"{label} has no source IDs")
    expect(set(references) <= source_ids, f"{label} references unknown source IDs")


def validate_bidirectional(sources: list[dict], facts: list[dict], label: str):
    fact_ids = [fact.get("id") for fact in facts]
    source_ids = [source.get("id") for source in sources]
    expect(len(fact_ids) == len(set(fact_ids)), f"{label} repeats fact IDs")
    expect(len(source_ids) == len(set(source_ids)), f"{label} repeats source IDs")
    fact_id_set = set(fact_ids)
    source_id_set = set(source_ids)
    for source in sources:
        validate_source(source, fact_id_set, f"{label} source {source.get('id')}")
    for fact in facts:
        validate_fact(fact, source_id_set, f"{label} fact {fact.get('id')}")
    supported_pairs = {(source["id"], fact_id) for source in sources for fact_id in source["supports_fact_ids"]}
    referenced_pairs = {(source_id, fact["id"]) for fact in facts for source_id in fact["source_ids"]}
    expect(supported_pairs == referenced_pairs, f"{label} source-to-fact mapping is not bidirectional")


def main():
    government = load(GOVERNMENT)
    daily = load(DAILY)
    scaffolds = load(SCAFFOLDS)
    scaffold_ids = {item["practical_guide"]["id"] for item in scaffolds["guides"]}

    expect(government.get("status") == "research_draft", "government packet escaped research_draft")
    expect(government.get("reviewer") is None, "government packet invents a reviewer")
    expect(government.get("publication_authorized") is False, "government packet authorizes publication")
    valid_date(government.get("verified_at"), "government.verified_at")
    validate_bidirectional(government.get("sources", []), government.get("facts", []), "government packet")
    government_guide_ids = {
        guide_id
        for topic in government.get("topic_dossiers", [])
        for guide_id in topic.get("target_guide_ids", [])
    }
    expect(all(topic.get("status") == "research_draft" for topic in government.get("topic_dossiers", [])), "government topic escaped research_draft")

    expect(daily.get("status") == "research_draft", "daily packet escaped research_draft")
    expect(daily.get("publication_policy", {}).get("publishable") is False, "daily packet claims publishability")
    valid_date(daily.get("verified_at"), "daily.verified_at")
    daily_guide_ids = set()
    total_daily_sources = 0
    total_daily_facts = 0
    for dossier in daily.get("dossiers", []):
        label = f"daily dossier {dossier.get('guide_id')}"
        expect(dossier.get("status") == "research_draft", f"{label} escaped research_draft")
        valid_date(dossier.get("verified_at"), f"{label}.verified_at")
        expect(isinstance(dossier.get("gaps"), list) and dossier["gaps"], f"{label} hides its publication gaps")
        validate_bidirectional(dossier.get("sources", []), dossier.get("facts", []), label)
        daily_guide_ids.add(dossier.get("guide_id"))
        total_daily_sources += len(dossier.get("sources", []))
        total_daily_facts += len(dossier.get("facts", []))

    researched = government_guide_ids | daily_guide_ids
    expect(researched <= scaffold_ids, "research packet references a guide outside the canonical scaffold queue")
    expect(len(researched) == len(government_guide_ids) + len(daily_guide_ids), "guide research appears in both packets")

    print("Priority research QA passed")
    print(f"- Research-backed guide topics: {len(researched)}/{len(scaffold_ids)}")
    print(f"- Government: {len(government_guide_ids)} topics, {len(government['facts'])} facts, {len(government['sources'])} official sources")
    print(f"- Daily life: {len(daily_guide_ids)} topics, {total_daily_facts} facts, {total_daily_sources} source records")
    print(f"- Still without a dedicated research dossier: {', '.join(sorted(scaffold_ids - researched))}")
    print("- Publication authorization: false; human reviewer: absent")
    print("- Bidirectional fact/source mapping and official-host allowlist: passed")


if __name__ == "__main__":
    main()
