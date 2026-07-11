#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"Visual system static QA failed: {message}")
    sys.exit(1)


def read(path: str) -> str:
    target = ROOT / path
    if not target.is_file():
        fail(f"Missing file: {path}")
    return target.read_text(encoding="utf-8")


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def swift_files_under(*roots: str) -> list[Path]:
    files: list[Path] = []
    for root in roots:
        base = ROOT / root
        if base.exists():
            files.extend(base.rglob("*.swift"))
    return files


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"//.*", "", text)


def main() -> None:
    design_system = read("YouNew/Core/DesignSystem/Components/NLDesignSystem.swift")
    for symbol in [
        "enum PremiumVisualMetrics",
        "enum PremiumImageRole",
        "enum PremiumImageOverlayPolicy",
        "struct PremiumHeroSurface",
        "struct PremiumImageCard",
        "struct PremiumDirectResultCard",
        "struct PremiumImageHeader",
    ]:
        expect(symbol in design_system, f"Shared visual system missing {symbol}")

    imaging = read("YouNew/Core/Imaging/AppContentImageView.swift")
    for symbol in [
        "struct PremiumImageView",
        "var role: PremiumImageRole",
        "var overlayPolicy: PremiumImageOverlayPolicy",
        "var focalPoint: PremiumImageFocalPoint",
        "targetPixelWidth ?? role.defaultTargetPixelWidth",
        "alignment: focalPoint.alignment",
    ]:
        expect(symbol in imaging, f"PremiumImageView missing required image-system support: {symbol}")

    artwork = read("YouNew/Data/ContentMediaRegistry.swift")
    for symbol in [
        "enum ContentArtworkSlot: String, CaseIterable",
        "enum ContentArtworkRegistry",
        "static func duplicateArtworkViolations() -> [String]",
        "case aiHero",
        "case searchHero",
        "case searchHealthcare",
        "case searchLegal",
    ]:
        expect(symbol in artwork, f"Artwork registry missing {symbol}")
    expect(
        "canalHousesHero ?? ContentMediaRegistry.aiImage" not in artwork,
        "Artwork registry must not use generic Amsterdam canal fallback for AI",
    )

    search = strip_comments(read("YouNew/Views/SearchView.swift"))
    for symbol in [
        "ContentArtworkRegistry.asset(for: .searchHero)",
        "ContentArtworkRegistry.asset(for: .searchHealthcare)",
        "ContentArtworkRegistry.asset(for: .searchLegal)",
        "PremiumHeroSurface(",
        "PremiumImageCard(",
        "PremiumDirectResultCard(",
    ]:
        expect(symbol in search, f"SearchView is not consuming shared visual system: {symbol}")
    expect("AppContentImageView(" not in search, "SearchView must not bypass PremiumImageView")
    expect("AsyncImage(" not in search, "SearchView must not use raw AsyncImage")

    ai = strip_comments(read("YouNew/Views/AIAssistantView.swift"))
    for symbol in [
        "ContentArtworkRegistry.asset(for: .aiHero)",
        "PremiumVisualMetrics.Layout.bottomTerminalGap",
        "assistantComposerTabBarClearance(safeAreaBottom:",
        "let tabBarClearance = assistantComposerTabBarClearance",
        ".padding(.bottom, 6 + tabBarClearance)",
    ]:
        expect(symbol in ai, f"AIAssistantView missing chat layout requirement: {symbol}")
    expect("AppContentImageView(" not in ai, "AIAssistantView must not bypass PremiumImageView")
    expect("canalHousesHero" not in ai, "AIAssistantView must not use generic Amsterdam canal fallback")
    expect(
        "measuredComposerHeight + bottomComposerClearance" not in ai
        and "bottomComposerClearance" not in ai
        and "assistantComposerDockClearance" not in ai,
        "Assistant scroll padding must not duplicate composer and tab-bar clearance",
    )
    expect(
        "FloatingTabBarMetrics.height - 2" not in ai
        and "FloatingTabBarMetrics.height + FloatingTabBarMetrics.bottomOffset + 4" not in ai,
        "Assistant composer must rely on the root floating-tab layout reserve instead of duplicating tab clearance",
    )

    province = strip_comments(read("YouNew/Views/ProvinceDirectoryView.swift"))
    city_hero = province.split("struct CityHeroImageView", 1)[1].split("struct CityFlagBadge", 1)[0]
    expect(
        "contentWidth: contentWidth" in province
        and "let contentWidth: CGFloat" in city_hero
        and ".frame(width: contentWidth, height: heroMinimumHeight, alignment: .bottomLeading)" in city_hero
        and "contentWidth - CityDetailLayout.heroContentPadding * 2" in city_hero,
        "City detail hero must bind image and text to explicit safe content width",
    )
    province_detail = province.split("struct ProvinceCityDetailView", 1)[1].split("struct ProvinceCitiesView", 1)[0]
    province_cities = province.split("struct ProvinceCitiesView", 1)[1].split("enum CityDetailLayout", 1)[0]
    expect(
        "ProvinceCityPremiumCard(" in province_detail
        and "ProvinceCitiesHeroCard(" in province_cities
        and "ProvinceCityPremiumCard(" in province_cities
        and "ProductTaskCard(" not in province_cities,
        "Province city lists must use premium image-led city cards instead of generic task cards",
    )

    for path in swift_files_under("YouNew/Views"):
        text = strip_comments(path.read_text(encoding="utf-8"))
        rel = path.relative_to(ROOT).as_posix()
        if rel in {
            "YouNew/Views/AIAssistantView.swift",
            "YouNew/Views/SearchView.swift",
        }:
            expect("padding(.horizontal, -" not in text, f"{rel} has negative horizontal padding")
            expect("UIScreen.main.bounds" not in text, f"{rel} has direct screen-width layout")

    runner = read("scripts/run-static-qa.sh")
    expect(
        "python3 scripts/visual-system-static-qa.py" in runner,
        "Static QA runner must include visual-system-static-qa.py",
    )

    print("Visual system static QA passed")


if __name__ == "__main__":
    main()
