#!/usr/bin/env python3
"""Static accessibility release checks for critical YouNew surfaces."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require_contains(relative_path: str, needle: str, failures: list[str]) -> None:
    source = read(relative_path)
    if needle not in source:
        failures.append(f"{relative_path}: missing `{needle}`")


def require_count_at_least(relative_path: str, needle: str, minimum: int, failures: list[str]) -> None:
    source = read(relative_path)
    count = source.count(needle)
    if count < minimum:
        failures.append(f"{relative_path}: expected at least {minimum} `{needle}` entries, found {count}")


def main() -> int:
    failures: list[str] = []

    critical_contracts = {
        "YouNew/Views/SearchView.swift": [
            '.accessibilityIdentifier("search.input")',
            '.accessibilityIdentifier("search.submit")',
            '.accessibilityLabel(L10n.t("common.search", lang))',
            '.accessibilityLabel(L10n.t("common.clear", lang))',
            '"search.result.card"',
            '.accessibilityIdentifier("search.intro.card")',
        ],
        "YouNew/Views/AIAssistantView.swift": [
            '.accessibilityIdentifier("assistant.input")',
            '.accessibilityIdentifier(viewModel.isLoading ? "assistant.cancel" : "assistant.send")',
            '.accessibilityLabel(viewModel.isLoading ? cancelResponseLabel : L10n.t("common.send", lang))',
            '.accessibilityIdentifier("assistant.retry")',
            '.accessibilityIdentifier("assistant.clearConversation")',
            '.accessibilityIdentifier("assistant.hero")',
            '.accessibilityIdentifier("assistant.response.structured")',
        ],
        "YouNew/Views/NearbyMapView.swift": [
            '.accessibilityIdentifier("map.screen")',
            '.accessibilityLabel(L10n.t("map.use_location", lang))',
            '.accessibilityLabel(L10n.t("map.select_city", lang))',
            '.accessibilityIdentifier("map.chip.row")',
            '.accessibilityIdentifier("map.search.card")',
            '.accessibilityLabel(String(format: L10n.t("map.places_count_accessibility", lang), title, count))',
        ],
        "YouNew/App/AppTabView.swift": [
            '.accessibilityLabel(item.tab == .more ? L10n.t("accessibility.openMenu", lang) : item.title)',
            '.accessibilityAddTraits(selectedTab == item.tab ? .isSelected : [])',
            '.accessibilityIdentifier("tab.\\(item.tab)")',
            '.accessibilityIdentifier("rightMenu.close")',
            '.accessibilityIdentifier("floating.assistant.button")',
        ],
        "YouNew/Core/Imaging/AppContentImageView.swift": [
            ".accessibilityLabel(accessibilityLabel ?? asset?.displayTitle(language) ?? fallbackCategory.symbol)",
            ".accessibilityLabel(accessibilityLabel ?? asset?.displayTitle(language) ?? fallbackTitle)",
            '.accessibilityLabel(imageUnavailableText)',
            '.accessibilityLabel(L10n.t("image.openSource", language))',
        ],
        "YouNew/Core/DesignSystem/Components/AppAtmosphereBackground.swift": [
            ".accessibilityHidden(true)",
        ],
        "YouNew/Core/DesignSystem/Components/YouNewBrandLogo.swift": [
            ".accessibilityHidden(true)",
        ],
    }

    for relative_path, needles in critical_contracts.items():
        for needle in needles:
            require_contains(relative_path, needle, failures)

    require_count_at_least("YouNew/Views/NearbyMapView.swift", ".accessibilityLabel(", 10, failures)
    require_count_at_least("YouNew/App/AppTabView.swift", ".accessibilityIdentifier(", 12, failures)
    require_count_at_least("YouNew/Core/Imaging/AppContentImageView.swift", ".accessibilityLabel(", 4, failures)

    runner = read("scripts/run-static-qa.sh")
    if "python3 scripts/accessibility-static-qa.py" not in runner:
        failures.append("scripts/run-static-qa.sh: accessibility-static-qa.py is not wired into the release gate")

    if failures:
        print("Accessibility static QA failed:")
        for failure in failures:
            print(f" - {failure}")
        return 1

    print("Accessibility static QA passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
