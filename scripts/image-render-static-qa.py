#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"Image render static QA failed: {message}")
    sys.exit(1)


def read(path: str) -> str:
    target = ROOT / path
    if not target.is_file():
        fail(f"Missing file: {path}")
    return target.read_text(encoding="utf-8")


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def compact(text: str) -> str:
    return re.sub(r"\s+", " ", text)


def block_after(text: str, marker: str, length: int = 2400) -> str:
    index = text.find(marker)
    if index == -1:
        fail(f"Missing marker: {marker}")
    return text[index:index + length]


def main() -> None:
    app_content = read("YouNew/Core/Imaging/AppContentImageView.swift")
    app_content_compact = compact(app_content)

    fill_block = block_after(app_content, "case .fill:")
    expect(".scaledToFill()" in fill_block, "AppContentImageView fill mode must use scaledToFill")
    expect(".clipped()" in fill_block, "AppContentImageView fill mode must clip overflow")
    expect(
        ".frame(maxWidth: .infinity, maxHeight: .infinity)" in fill_block,
        "AppContentImageView fill mode must pin image to a stable frame",
    )

    fit_block = block_after(app_content, "case .fit:")
    expect(".scaledToFit()" in fit_block, "AppContentImageView fit mode must use scaledToFit")
    expect(
        ".clipped()" not in fit_block.split("}", 1)[0],
        "AppContentImageView fit mode should not crop protected documentary images",
    )

    expect(
        ".contentImageFrame(aspectRatio)" in app_content,
        "AppContentImageView must apply a stable aspect-ratio frame before clipping",
    )
    expect(
        "targetPixelWidth ?? 1200" in app_content,
        "AppContentImageView must default remote card requests to at least 1200px",
    )
    expect(
        "byPreparingThumbnail(ofSize: targetPixelSize)" in app_content,
        "AppContentImageView must downsample to the requested display target instead of stretching source pixels",
    )

    image_loader = read("YouNew/Core/Imaging/ImageLoader.swift")
    city_success_block = block_after(image_loader, "case .success:")
    for needle in [
        ".resizable()",
        ".aspectRatio(contentMode: .fill)",
        ".frame(maxWidth: .infinity)",
        ".frame(height: height)",
        ".clipped()",
    ]:
        expect(needle in city_success_block, f"CityImageView success path missing {needle}")
    expect(
        "let displayAwareWidth = height * 3.2" in image_loader,
        "CityImageView must request a display-aware image width for hero/card surfaces",
    )

    city_views = read("YouNew/Core/DesignSystem/Components/NetherlandsCityViews.swift")
    attraction_block = block_after(city_views, "struct AttractionCard")
    for needle in [
        "CityImageView(",
        "urlString: attraction.imageURL",
        "height: 160",
        "fallbackURLStrings: resolvedImage.fallbackURLStrings",
        "debugContext: resolvedImage.debugContext",
    ]:
        expect(needle in attraction_block, f"AttractionCard render path missing {needle}")

    culture_view = read("YouNew/Views/CultureAttractionsView.swift")
    culture_card_block = block_after(culture_view, "private func tourismAttractionCard")
    for needle in [
        "CityImageView(",
        "urlString: record.photoURL",
        "height: 148",
        'sourceRegistry: "TourismAttractionCatalog"',
        "targetPixelWidth: 1200",
    ]:
        expect(needle in culture_card_block, f"Tourism catalog card image missing {needle}")

    province_view = read("YouNew/Views/ProvinceDirectoryView.swift")
    expect(
        "CityVerifiedMediaImageView(" in province_view,
        "Province detail surfaces must use CityVerifiedMediaImageView/AppContentImageView",
    )
    expect(
        "contentMode == .fill ? .fill : .fit" in province_view,
        "Province verified media image must preserve explicit fill/fit rendering mode",
    )

    visual_components = read("YouNew/Core/DesignSystem/Components/NetherlandsVisualComponents.swift")
    category_hero_block = block_after(visual_components, "struct CategoryHeroVisual", 9000)
    for needle in [
        "AppContentImageView(",
        "resolvedHeroAsset",
        "fallbackRemoteURLs",
        "fallbackLocalAssetName",
        "fallbackHeroAsset",
        "ContentMediaRegistry.officialSourcesHero",
        "ContentMediaRegistry.municipalityCityHallImage",
        "ContentMediaRegistry.healthcarePharmacyImage",
        "ContentMediaRegistry.transportStationHero",
        "ContentMediaRegistry.cultureHero",
    ]:
        expect(needle in category_hero_block, f"CategoryHeroVisual missing contextual fallback image path {needle}")
    expect(
        "AsyncImage(" not in category_hero_block,
        "CategoryHeroVisual must use AppContentImageView cache/fallback handling instead of raw AsyncImage",
    )
    expect(
        "CuratedPlaceHeroMediaRegistry.bundledEmergencyFallbackAssetName" in category_hero_block,
        "CategoryHeroVisual must fall back to a bundled local image if contextual hero media is unavailable",
    )

    content_media = read("YouNew/Data/ContentMediaRegistry.swift")
    content_mapping_block = block_after(content_media, "static func image(forContentID id: String)", 2600)
    asset_consumers: dict[str, list[str]] = {}
    current_ids: list[str] = []
    for raw_line in content_mapping_block.splitlines():
        line = raw_line.strip()
        if line.startswith("case "):
            current_ids = re.findall(r'"([^"]+)"', line)
        elif line.startswith("return ") and current_ids:
            returned = line.removeprefix("return ").strip()
            if returned != "nil":
                asset_consumers.setdefault(returned, []).extend(current_ids)
            current_ids = []
    for returned, consumers in asset_consumers.items():
        expect(
            len(consumers) == 1,
            f"ContentMediaRegistry.image(forContentID:) maps {returned} to multiple topics: {', '.join(consumers)}",
        )

    generic_visual_files = {
        "YouNew/Views/CategoriesHubView.swift",
        "YouNew/Views/FirstStepsView.swift",
        "YouNew/Views/HistoryKNMHubView.swift",
        "YouNew/Views/OnboardingQuestionnaireView.swift",
        "YouNew/Views/MoreHubView.swift",
        "YouNew/Views/AIAssistantView.swift",
    }
    for path in generic_visual_files:
        text = read(path)
        expect(
            "ContentMediaRegistry.homeAtmosphereHero" not in text,
            f"{path} must not use Amsterdam canal image as a generic fallback",
        )
        expect(
            'return "premium_home_background"' not in text,
            f"{path} must not return premium_home_background as a generic fallback",
        )

    home_view = read("YouNew/Views/HomeView.swift")
    city_moments_block = block_after(home_view, "private var cityMoments", 1500)
    expect(
        "ContentMediaRegistry.homeAtmosphereHero" not in city_moments_block,
        "Home city moments must not reuse Amsterdam canal hero for generic cards",
    )

    forbidden_stretch_patterns = [
        r"\.resizable\(\)\s*\.frame\([^)]*height:[^)]*\)",
    ]
    protected_files = {
        "YouNew/Core/Imaging/AppContentImageView.swift": app_content,
        "YouNew/Core/Imaging/ImageLoader.swift": image_loader,
        "YouNew/Core/DesignSystem/Components/NetherlandsCityViews.swift": city_views,
        "YouNew/Views/CultureAttractionsView.swift": culture_view,
    }
    for path, text in protected_files.items():
        for pattern in forbidden_stretch_patterns:
            for match in re.finditer(pattern, compact(text)):
                snippet = match.group(0)
                if "scaledToFill" not in snippet and "scaledToFit" not in snippet and "aspectRatio" not in snippet:
                    fail(f"{path} has stretch-prone image sizing: {snippet}")

    expect(
        "scaledToFill" in app_content_compact,
        "AppContentImageView must retain aspect-fill rendering support",
    )
    print("Image render static QA passed")


if __name__ == "__main__":
    main()
