#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"Route ID stability static QA failed: {message}")
    sys.exit(1)


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8", errors="ignore")


def stable_keys(text: str, prefix: str) -> list[str]:
    return re.findall(rf'StableRouteID\.uuid\(\s*"{re.escape(prefix)}([^"]+)"', text)


def main() -> None:
    stable_id = read("YouNew/Core/Extensions/StableRouteID.swift")
    search_model = read("YouNew/Models/SearchAnswer.swift")
    checklist = read("YouNew/Data/MockChecklistData.swift")
    fines = read("YouNew/Data/MockFineInfoData.swift")
    dutch_terms = read("YouNew/Data/MockDutchTermsData.swift")
    rules = read("YouNew/Data/MockRulesGuideData.swift")
    mistakes = read("YouNew/Data/MockNewcomerMistakesData.swift")
    resource_model = read("YouNew/Models/ResourceLinkItem.swift")
    resources = read("YouNew/Data/MockResourcesData.swift")
    beginner_guides = read("YouNew/Data/MockBeginnerGuidesData.swift")
    scam_warning_model = read("YouNew/Models/ScamWarning.swift")
    scam_warnings = read("YouNew/Data/MockScamWarningsData.swift")
    legal_info = read("YouNew/Data/MockLegalInfoData.swift")
    daily_life_model = read("YouNew/Models/DailyLifeTip.swift")
    daily_life = read("YouNew/Data/MockDailyLifeData.swift")
    search_data = read("YouNew/Data/MockSearchAnswersData.swift")
    expanded_search_data = read("YouNew/Data/MockExpandedSearchAnswers.swift")
    expansion_models = read("YouNew/Models/ExpansionModels.swift")
    nearby_place_model = read("YouNew/Models/NearbyPlace.swift")

    expect("enum StableRouteID" in stable_id, "shared StableRouteID utility is missing")
    expect("fnv1a64" in stable_id and "UUID(uuid:" in stable_id, "StableRouteID is not deterministic UUID generation")
    expect("StableRouteID.uuid(key)" in search_model, "SearchAnswer.stableID does not use StableRouteID")

    expect("id: UUID()" not in checklist, "checklist item routes still use random UUIDs")
    expect("id: UUID()" not in fines, "fine info routes still use random UUIDs")
    expect("id: UUID()" not in dutch_terms, "Dutch term routes still use random UUIDs")
    expect("id: UUID()" not in rules, "Rules Guide routes still use random UUIDs")
    expect("id: UUID()" not in mistakes, "Newcomer mistake routes still use random UUIDs")
    expect("let id = UUID()" not in resource_model, "resource routes still use random UUIDs in the model")
    expect("id: UUID()" not in resources, "resource routes still use random UUIDs")
    expect("id: UUID()" not in beginner_guides, "Beginner Guide routes still use random UUIDs")
    expect("self.id = UUID()" not in scam_warning_model, "ScamWarning still assigns random route IDs internally")
    expect("id: UUID()" not in scam_warnings, "Scam Warning routes still use random UUIDs")
    expect("id: UUID()" not in legal_info, "Legal Info knowledge items still use random UUIDs")
    expect("self.id = UUID()" not in daily_life_model, "Daily Life tips still assign random knowledge IDs internally")
    expect("id: UUID()" not in daily_life, "Daily Life knowledge items still use random UUIDs")
    expect("id: UUID()" not in search_data, "search answer routes still use random UUIDs")
    expect("id: UUID()" not in expanded_search_data, "expanded search answer routes still use random UUIDs")
    expect("let id = UUID()" not in expansion_models, "Expansion static knowledge models still use random UUIDs")
    expect("let id = UUID()" not in nearby_place_model, "Nearby map place routes still use random UUIDs")

    checklist_keys = stable_keys(checklist, "checklist:")
    expect(len(checklist_keys) == 13, f"expected 13 stable checklist route keys, found {len(checklist_keys)}")
    duplicate_checklist_keys = sorted({key for key in checklist_keys if checklist_keys.count(key) > 1})
    expect(not duplicate_checklist_keys, f"duplicate stable checklist route keys: {duplicate_checklist_keys}")

    for key in checklist_keys:
        expect(key.strip(), "empty checklist route key")
        expect(" " not in key, f"checklist route key contains spaces: {key}")

    fine_keys = stable_keys(fines, "fine:")
    expect(len(fine_keys) == 10, f"expected 10 stable fine route keys, found {len(fine_keys)}")
    duplicate_fine_keys = sorted({key for key in fine_keys if fine_keys.count(key) > 1})
    expect(not duplicate_fine_keys, f"duplicate stable fine route keys: {duplicate_fine_keys}")
    for key in fine_keys:
        expect(key.strip(), "empty fine route key")
        expect(" " not in key, f"fine route key contains spaces: {key}")

    dutch_term_keys = stable_keys(dutch_terms, "dutch-term:")
    expect(len(dutch_term_keys) == 37, f"expected 37 stable Dutch term route keys, found {len(dutch_term_keys)}")
    duplicate_dutch_term_keys = sorted({key for key in dutch_term_keys if dutch_term_keys.count(key) > 1})
    expect(not duplicate_dutch_term_keys, f"duplicate stable Dutch term route keys: {duplicate_dutch_term_keys}")
    for key in dutch_term_keys:
        expect(key.strip(), "empty Dutch term route key")
        expect(" " not in key, f"Dutch term route key contains spaces: {key}")

    topic_count = len(re.findall(r"^\s*topic\(", rules, flags=re.MULTILINE))
    scenario_count = len(re.findall(r"^\s*scenario\(", rules, flags=re.MULTILINE))
    expect(topic_count == 15, f"expected 15 Rules Guide topic routes, found {topic_count}")
    expect(scenario_count == 9, f"expected 9 Rules Guide scenario routes, found {scenario_count}")
    expect('StableRouteID.uuid("rule-topic:\\(stableRouteKey(title))")' in rules, "Rules Guide topics do not use stable route IDs")
    expect('StableRouteID.uuid("rule-scenario:\\(stableRouteKey(title))")' in rules, "Rules Guide scenarios do not use stable route IDs")
    expect("private static func stableRouteKey" in rules, "Rules Guide stable route key helper is missing")

    mistake_count = len(re.findall(r"^\s*mistake\(", mistakes, flags=re.MULTILINE))
    expect(mistake_count == 17, f"expected 17 Newcomer mistake routes, found {mistake_count}")
    expect('StableRouteID.uuid("mistake:\\(stableRouteKey(title))")' in mistakes, "Newcomer mistakes do not use stable route IDs")
    expect("private static func stableRouteKey" in mistakes, "Newcomer mistake stable route key helper is missing")

    resource_keys = stable_keys(resources, "resource:")
    expect(len(resource_keys) == 15, f"expected 15 stable resource route keys, found {len(resource_keys)}")
    duplicate_resource_keys = sorted({key for key in resource_keys if resource_keys.count(key) > 1})
    expect(not duplicate_resource_keys, f"duplicate stable resource route keys: {duplicate_resource_keys}")
    expect("let id: UUID" in resource_model and "id: UUID = UUID()" in resource_model, "ResourceLinkItem does not accept explicit stable IDs")
    for key in resource_keys:
        expect(key.strip(), "empty resource route key")
        expect(" " not in key, f"resource route key contains spaces: {key}")

    beginner_guide_keys = stable_keys(beginner_guides, "beginner-guide:")
    expect(len(beginner_guide_keys) == 23, f"expected 23 stable Beginner Guide route keys, found {len(beginner_guide_keys)}")
    duplicate_beginner_guide_keys = sorted({key for key in beginner_guide_keys if beginner_guide_keys.count(key) > 1})
    expect(not duplicate_beginner_guide_keys, f"duplicate stable Beginner Guide route keys: {duplicate_beginner_guide_keys}")
    for key in beginner_guide_keys:
        expect(key.strip(), "empty Beginner Guide route key")
        expect(" " not in key, f"Beginner Guide route key contains spaces: {key}")

    scam_warning_keys = stable_keys(scam_warnings, "scam-warning:")
    expect(len(scam_warning_keys) == 21, f"expected 21 stable Scam Warning route keys, found {len(scam_warning_keys)}")
    duplicate_scam_warning_keys = sorted({key for key in scam_warning_keys if scam_warning_keys.count(key) > 1})
    expect(not duplicate_scam_warning_keys, f"duplicate stable Scam Warning route keys: {duplicate_scam_warning_keys}")
    expect("id: UUID = UUID()" in scam_warning_model, "ScamWarning does not accept explicit stable IDs")
    for key in scam_warning_keys:
        expect(key.strip(), "empty Scam Warning route key")
        expect(" " not in key, f"Scam Warning route key contains spaces: {key}")

    legal_info_count = len(re.findall(r"^\s*item\(", legal_info, flags=re.MULTILINE))
    expect(legal_info_count == 28, f"expected 28 Legal Info knowledge items, found {legal_info_count}")
    expect('StableRouteID.uuid("legal-info:\\(stableKnowledgeKey(englishTitle))")' in legal_info, "Legal Info items do not use stable knowledge IDs")
    expect("private static func stableKnowledgeKey" in legal_info, "Legal Info stable knowledge key helper is missing")

    daily_life_count = len(re.findall(r"^\s*DailyLifeTip\(", daily_life, flags=re.MULTILINE))
    expect(daily_life_count == 33, f"expected 33 Daily Life knowledge items, found {daily_life_count}")
    expect('StableRouteID.uuid("daily-life:\\(Self.stableKnowledgeKey(title))")' in daily_life_model, "Daily Life tips do not use stable knowledge IDs")
    expect("private static func stableKnowledgeKey" in daily_life_model, "Daily Life stable knowledge key helper is missing")

    expansion_prefixes = [
        "expansion.reminder.",
        "expansion.survival.",
        "expansion.document.",
        "expansion.municipality.",
        "expansion.knowledge.",
        "expansion.scenario.",
        "expansion.service.",
        "expansion.province.",
        "expansion.city.",
        "expansion.roadmap.",
        "expansion.search-result.",
    ]
    for prefix in expansion_prefixes:
        expect(f'StableRouteID.uuid("{prefix}' in expansion_models, f"Expansion model missing stable ID prefix: {prefix}")

    expect('StableRouteID.uuid("nearby-place:\\(saveKey)")' in nearby_place_model, "NearbyPlace does not derive stable IDs from saveKey")

    print("Route ID stability static QA passed")
    print(f"- Stable checklist route IDs checked: {len(checklist_keys)}")
    print(f"- Stable fine route IDs checked: {len(fine_keys)}")
    print(f"- Stable Dutch term route IDs checked: {len(dutch_term_keys)}")
    print(f"- Stable Rules Guide topic route IDs checked: {topic_count}")
    print(f"- Stable Rules Guide scenario route IDs checked: {scenario_count}")
    print(f"- Stable Newcomer mistake route IDs checked: {mistake_count}")
    print(f"- Stable resource route IDs checked: {len(resource_keys)}")
    print(f"- Stable Beginner Guide route IDs checked: {len(beginner_guide_keys)}")
    print(f"- Stable Scam Warning route IDs checked: {len(scam_warning_keys)}")
    print(f"- Stable Legal Info knowledge IDs checked: {legal_info_count}")
    print(f"- Stable Daily Life knowledge IDs checked: {daily_life_count}")
    print(f"- Stable Expansion knowledge/search IDs checked: {len(expansion_prefixes)} model types")
    print("- Stable nearby map place IDs checked")
    print("- Stable search-answer route IDs checked")
    print("- Shared deterministic route ID utility checked")


if __name__ == "__main__":
    main()
