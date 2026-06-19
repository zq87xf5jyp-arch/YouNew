#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"Search static QA failed: {message}")
    sys.exit(1)


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8", errors="ignore")


def main() -> None:
    model = read("YouNew/Models/SearchAnswer.swift")
    stable_id = read("YouNew/Core/Extensions/StableRouteID.swift")
    search_data = read("YouNew/Data/MockSearchAnswersData.swift")
    expanded_data = read("YouNew/Data/MockExpandedSearchAnswers.swift")
    search_view = read("YouNew/Views/SearchView.swift")
    view_model = read("YouNew/ViewModels/SearchViewModel.swift")

    expect("static func stableID(_ key: String) -> UUID" in model, "SearchAnswer stable ID helper is missing")
    expect("StableRouteID.uuid(key)" in model, "SearchAnswer stable ID helper must use the shared route ID utility")
    expect("fnv1a64" in stable_id and "0x50" in stable_id and "0x3f" in stable_id, "shared stable ID helper does not set deterministic UUID bytes")

    for path, text in [
        ("YouNew/Data/MockSearchAnswersData.swift", search_data),
        ("YouNew/Data/MockExpandedSearchAnswers.swift", expanded_data),
    ]:
        expect("id: UUID()" not in text, f"{path} still uses random UUIDs for search-answer routes")
        expect("SearchAnswer.stableID(" in text, f"{path} does not use stable search-answer IDs")

    id_keys = re.findall(r"SearchAnswer\.stableID\(\s*\"([^\"]+)\"", search_data + "\n" + expanded_data)
    expect(id_keys, "no literal stable search-answer ID keys found")
    literal_id_keys = [key for key in id_keys if r"\(" not in key]
    duplicates = sorted({key for key in literal_id_keys if literal_id_keys.count(key) > 1})
    expect(not duplicates, f"duplicate literal stable search-answer ID keys: {duplicates}")

    required_queries = [
        "BSN", "DigiD", "huisarts", "gemeente", "taxes", "toeslagen",
        "штраф", "налог", "врач", "жильё", "работа",
        "fiets", "boete", "zorgverzekering", "huur", "werk", "uitkering",
        "KNM", "Знание нидерландского общества",
        "Dutch A1-A2", "afspraak", "de het", "hebben zijn", "отделяемые глаголы",
    ]
    synonym_tests = read("YouNewTests/SearchSynonymTests.swift")
    for query in required_queries:
        expect(query in synonym_tests, f"required valid-content search query is not covered by tests: {query}")

    expect("searchRefreshTask?.cancel()" in view_model, "SearchViewModel does not cancel pending search refresh tasks")
    expect("Task.sleep(nanoseconds: 220_000_000)" in view_model, "SearchViewModel debounce interval changed or is missing")
    expect("directResultsTask?.cancel()" in search_view, "SearchView direct-results task cancellation is missing")
    expect("Task.sleep(nanoseconds: 140_000_000)" in search_view, "Search direct-results debounce interval changed or is missing")
    expect(
        "private func openOfficialSource(_ url: URL)" in search_view
        and "AppURL.validatedWebURL(url)" in search_view
        and "openOfficialSource(answer.officialSourceURL)" in search_view,
        "search result source button is not URL-guarded",
    )
    expect("AppDestination.searchAnswer(answer.id)" in search_view, "search answer row destination is missing")
    expect("AppDestination.beginnerGuide(item.id)" in search_view, "beginner guide result destination is missing")

    print("Search static QA passed")
    print("- Stable search-answer route IDs checked")
    print(f"- Literal stable ID keys checked: {len(id_keys)}")
    print(f"- Valid-content query coverage checked: {len(required_queries)}")
    print("- Search debounce and source navigation guards checked")


if __name__ == "__main__":
    main()
