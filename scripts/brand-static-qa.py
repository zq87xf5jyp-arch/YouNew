#!/usr/bin/env python3
import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message):
    print(f"FAIL: {message}")
    sys.exit(1)


def expect(condition, message):
    if not condition:
        fail(message)


def read(path):
    return path.read_text(encoding="utf-8")


def app_icon_checks():
    icon_set = ROOT / "YouNew/Assets.xcassets/AppIcon.appiconset"
    source = ROOT / "Design/AppIcon/source.svg"
    contents = icon_set / "Contents.json"
    required_sizes = [16, 32, 64, 128, 256, 512, 1024]

    expect(icon_set.is_dir(), "AppIcon.appiconset is missing")
    expect(source.is_file(), "Design/AppIcon/source.svg is missing")
    expect(contents.is_file(), "AppIcon Contents.json is missing")

    catalog = json.loads(read(contents))
    filenames = {image.get("filename") for image in catalog.get("images", [])}

    for size in required_sizes:
        filename = f"icon-{size}.png"
        path = icon_set / filename
        expect(filename in filenames, f"{filename} is not referenced by AppIcon Contents.json")
        expect(path.is_file(), f"{filename} is missing")

        result = subprocess.run(
            ["sips", "-g", "pixelWidth", "-g", "pixelHeight", "-g", "hasAlpha", str(path)],
            check=False,
            capture_output=True,
            text=True,
        )
        expect(result.returncode == 0, f"sips could not read {filename}")
        expect(f"pixelWidth: {size}" in result.stdout, f"{filename} width is not {size}px")
        expect(f"pixelHeight: {size}" in result.stdout, f"{filename} height is not {size}px")
        expect("hasAlpha: no" in result.stdout, f"{filename} has an alpha channel")

    source_text = read(source).lower()
    expect("<svg" in source_text, "App icon source is not SVG")
    # Current concept: Netherlands city portal mark.
    # Compact canal-house skyline with a route line and newcomer node.
    expect("skyline" in source_text or "city" in source_text or "canal-house" in source_text,
           "App icon source does not describe the city/skyline concept")
    for marker in ["orange", "teal", "navy", "route"]:
        expect(marker in source_text, f"App icon source missing brand concept marker: {marker}")
    for forbidden in ["<image", ".png", ".jpg", "placeholder", "stock logo", "flag_of_the_netherlands", "gemeente"]:
        expect(forbidden not in source_text, f"App icon source contains forbidden marker: {forbidden}")


def asset_reference_checks():
    asset_root = ROOT / "YouNew/Assets.xcassets"
    missing = []

    for contents in asset_root.rglob("Contents.json"):
        catalog = json.loads(read(contents))
        for image in catalog.get("images", []):
            filename = image.get("filename")
            if filename and not (contents.parent / filename).is_file():
                missing.append(str((contents.parent / filename).relative_to(ROOT)))

    expect(not missing, f"Missing asset catalog image files: {missing}")


def production_logo_checks():
    roots = [ROOT / "YouNew/Core/DesignSystem/Components", ROOT / "YouNew/Views", ROOT / "YouNew/Core/DesignSystem/Tokens"]
    forbidden = ["placeholder logo", "test logo", "temporary logo", "debug logo", "stock logo"]
    violations = []

    for root in roots:
        for source in root.rglob("*.swift"):
            text = read(source).lower()
            if any(marker in text for marker in forbidden):
                violations.append(str(source.relative_to(ROOT)))

    expect(not violations, f"Production UI references placeholder/test logo text: {violations}")


def official_symbol_checks():
    logo_source = read(ROOT / "Design/AppIcon/source.svg")
    for marker in ["city_leiden_flag", "city_leiden_coat_of_arms", "Flag_of_Leiden", "Leiden_wapen"]:
        expect(marker not in logo_source, f"App logo source references official Leiden symbol marker: {marker}")

    media_registry = read(ROOT / "YouNew/Data/VerifiedPlaceMediaRegistry.swift")
    expect("Flag of Leiden.svg" in media_registry, "Leiden flag Wikimedia source is missing")
    expect("Leiden wapen.svg" in media_registry, "Leiden coat-of-arms Wikimedia source is missing")
    expect("AppIcon" not in media_registry, "Official media registry references AppIcon")
    expect("YouNewLogo" not in media_registry, "Official media registry references YouNewLogo")

    asset_root = ROOT / "YouNew/Assets.xcassets"
    misplaced = []
    for svg in asset_root.rglob("*.svg"):
        relative = str(svg.relative_to(ROOT))
        is_official_family = "_flag.imageset" in relative or "_coat_of_arms.imageset" in relative
        is_map_asset = "map_" in relative or "netherlands_map" in relative
        if not is_official_family and not is_map_asset and ("flag" in relative or "coat_of_arms" in relative):
            misplaced.append(relative)

    expect(not misplaced, f"Official symbol-like files outside symbol asset families: {misplaced}")


def localization_checks():
    strings_path = ROOT / "YouNew/ru.lproj/Localizable.strings"
    text = read(strings_path)
    expected = {
        "tab.home": "Главная",
        "tab.search": "Поиск",
        "tab.map": "Places",
        "tab.saved": "Сохран.",
        "tab.explain": "Помощь",
        "tab.more": "Ещё",
    }

    for key, value in expected.items():
        pattern = rf'"{re.escape(key)}"\s*=\s*"{re.escape(value)}";'
        expect(re.search(pattern, text), f"Russian tab label {key} is not compact value {value}")
        expect(len(value) <= 7, f"Russian tab label {key} is longer than 7 characters")

    required_menu_keys = [
        "common.menu", "common.close", "common.back", "menu.title", "menu.subtitle",
        "menu.home", "menu.map", "menu.search", "menu.saved", "menu.history",
        "menu.cultureAttractions", "menu.cities", "menu.help", "menu.settings",
        "menu.sources", "menu.about", "menu.language", "menu.version",
    ]
    for locale in ["en", "ru", "nl"]:
        locale_text = read(ROOT / f"YouNew/{locale}.lproj/Localizable.strings")
        for key in required_menu_keys:
            expect(f'"{key}"' in locale_text, f"{locale} localization missing {key}")

    expect('"menu.home" = "Главная";' in text, "Russian menu home label is not localized")
    expect('"menu.sources" = "Источники";' in text, "Russian menu sources label is not localized")


def source_guard_checks():
    app_icons = read(ROOT / "YouNew/Core/DesignSystem/Tokens/AppIcons.swift")
    app_spacing = read(ROOT / "YouNew/Core/DesignSystem/Tokens/AppSpacing.swift")
    app_radius = read(ROOT / "YouNew/Core/DesignSystem/Tokens/AppCornerRadius.swift")
    app_shadows = read(ROOT / "YouNew/Core/DesignSystem/Tokens/AppShadows.swift")
    app_brand = read(ROOT / "YouNew/Core/DesignSystem/Components/AppBrandSystem.swift")
    app_background = read(ROOT / "YouNew/Core/DesignSystem/Components/AppAtmosphereBackground.swift")
    nav_components = read(ROOT / "YouNew/Core/DesignSystem/Components/NavigationUIComponents.swift")

    expect("minimumTouchTarget: CGFloat = 44" in app_icons, "AppIcons minimum touch target is not 44pt")
    expect("enum AppButtonMetrics" in app_spacing, "Shared AppButtonMetrics token enum is missing")
    for token in ["minTouchSize", "horizontalPadding", "verticalPadding", "iconSize"]:
        expect(token in app_spacing, f"AppButtonMetrics missing {token}")
    expect("static let button: CGFloat = 16" in app_radius, "AppRadius.button token is missing")
    expect("static let card: CGFloat = 24" in app_radius, "AppRadius.card token is missing")
    expect("AppButtonMetrics.minTouchSize" in app_shadows, "Button styles do not use shared min touch metric")
    expect("AppRadius.button" in app_shadows, "Button styles do not use shared button radius")
    expect("PrimaryPremiumButtonStyle()" in app_brand, "PrimaryButton does not use shared premium button style")
    expect("accessibilityLabel(title)" in app_brand, "PrimaryButton is missing accessibility label")
    expect("L10n.t(\"common.back\"" in nav_components and "L10n.t(\"common.close\"" in nav_components, "Back/close labels are not localized through common keys")
    expect("AppAmbientMotionLayer" in app_background, "App-wide ambient visual layer is missing")
    expect("accessibilityReduceMotion" in app_background, "Ambient visuals do not respect Reduce Motion")
    expect("accessibilityReduceTransparency" in app_background, "Ambient visuals do not respect Reduce Transparency")
    expect("AppCardContourOverlay" in app_shadows, "Shared card contour visual effect is missing")
    expect("TimelineView(.animation)" in app_background and "TimelineView(.animation)" in app_shadows, "Visual effects are not wired through shared animated layers")

    for symbol in ["homeActive", "mapActive", "moreActive", "bookmark.fill", "house.fill", "map.fill", "static let back"]:
        expect(symbol in app_icons, f"Bottom tab icon mapping missing {symbol}")

    history_view = read(ROOT / "YouNew/Views/NetherlandsHistoryView.swift")
    expect(".accessibilityLabel" in history_view, "History timeline/source controls lack accessibility labels")
    expect("AppSymbolBadge" in history_view, "History timeline does not use shared icon badge style")
    expect("HistoryMediaRegistry.images" in history_view, "History page does not render verified image registry")

    root_tab = read(ROOT / "YouNew/App/AppTabView.swift")
    expect("AppIcons.Metrics.minimumTouchTarget" in root_tab, "Bottom tabs do not use shared touch target token")
    expect("accessibilityAddTraits" in root_tab and ".isSelected" in root_tab, "Selected bottom tab accessibility trait is missing")
    expect("RightSideMenuOverlay" in root_tab, "Right-side menu overlay is missing")
    expect("transition(.move(edge: .trailing)" in root_tab, "Right-side menu does not slide from the right")
    expect("rightMenu.close" in root_tab, "Right-side menu close button accessibility identifier is missing")
    expect("rightMenu.overlay" in root_tab, "Right-side menu overlay close target is missing")
    expect("topLeadingRadius" in root_tab and "topTrailingRadius: 0" in root_tab, "Right-side menu panel does not use right-edge drawer geometry")
    expect("case .historyNetherlands: return .netherlandsHistory" in root_tab or "action: .destination(.netherlandsHistory)" in root_tab, "History menu route is missing")
    expect("case .cities: return .cityList" in root_tab and "case .provinces: return .provinceList" in root_tab, "Cities/provinces menu route is missing")
    expect("case .officialSources, .sources: return .officialSources" in root_tab or "action: .destination(.officialSources)" in root_tab, "Sources menu route is missing")

    production_sources = "\n".join(
        read(path)
        for root in [ROOT / "YouNew/Views", ROOT / "YouNew/Core/DesignSystem/Components"]
        for path in root.rglob("*.swift")
    )
    expect(".navigationBarBackButtonHidden(true)" not in production_sources, "Production screens must not hide the native back button")
    expect("AppNavigationBackButton" in production_sources, "Reusable back button helper is missing")


def content_image_checks():
    model = ROOT / "YouNew/Models/AppImageAsset.swift"
    component = ROOT / "YouNew/Core/Imaging/AppContentImageView.swift"
    registry = ROOT / "YouNew/Data/HistoryMediaRegistry.swift"

    expect(model.is_file(), "AppImageAsset model is missing")
    expect(component.is_file(), "Reusable AppContentImageView is missing")
    expect(registry.is_file(), "HistoryMediaRegistry is missing")

    registry_text = read(registry)
    expect("Wikimedia Commons" in registry_text, "History image registry does not use Wikimedia source metadata")
    expect("license:" in registry_text, "History image registry is missing license metadata")
    expect("attribution:" in registry_text, "History image registry is missing attribution metadata")
    for forbidden in ["google.com", "gstatic.com", "unsplash.com", "pexels.com", "placeholder"]:
        expect(forbidden not in registry_text.lower(), f"History image registry contains forbidden image source: {forbidden}")

    entries = []
    for chunk in registry_text.split("        AppImageAsset(")[1:]:
        entry = chunk.split("\n        )", 1)[0]
        entries.append(entry)
    expect(entries, "History image registry has no AppImageAsset entries")

    for entry in entries:
        id_match = re.search(r'id:\s*"([^"]+)"', entry)
        source_match = re.search(r'sourceURL:\s*URL\(string:\s*"([^"]+)"\)', entry)
        title_match = re.search(r'title:\s*"([^"]+)"', entry)
        source_name_match = re.search(r'sourceName:\s*"([^"]+)"', entry)
        creator_match = re.search(r'creator:\s*"([^"]+)"', entry)
        license_match = re.search(r'license:\s*"([^"]+)"', entry)
        attribution_match = re.search(r'attribution:\s*"([^"]+)"', entry)
        width_match = re.search(r'width:\s*(\d+)', entry)
        height_match = re.search(r'height:\s*(\d+)', entry)
        retrieved_match = re.search(r'retrievedAt:\s*"([^"]+)"', entry)

        image_id = id_match.group(1) if id_match else "<missing id>"
        expect(id_match and image_id.strip(), "History image has empty or missing id")
        expect(title_match and title_match.group(1).strip(), f"{image_id} is missing title")
        expect(source_name_match and source_name_match.group(1).strip(), f"{image_id} is missing sourceName")
        expect(creator_match and creator_match.group(1).strip(), f"{image_id} is missing creator")
        expect(license_match and license_match.group(1).strip(), f"{image_id} is missing license")
        expect(attribution_match and attribution_match.group(1).strip(), f"{image_id} is missing attribution")
        expect(width_match and int(width_match.group(1)) > 0, f"{image_id} is missing width")
        expect(height_match and int(height_match.group(1)) > 0, f"{image_id} is missing height")
        expect(retrieved_match and retrieved_match.group(1).strip(), f"{image_id} is missing retrievedAt")
        expect("verified: true" in entry, f"{image_id} must be verified true")
        expect("type: .timeline" in entry, f"{image_id} must use type .timeline")

        expect(source_match, f"{image_id} is missing exact sourceURL")
        source_url = source_match.group(1)
        expect(source_url.startswith("https://commons.wikimedia.org/wiki/File:"), f"{image_id} sourceURL is not exact Commons File page: {source_url}")
        expect("/wiki/Category:" not in source_url, f"{image_id} sourceURL is a Commons category")
        expect("/wiki/Special:" not in source_url, f"{image_id} sourceURL is a generic/special Commons page")
        expect("search" not in source_url.lower(), f"{image_id} sourceURL appears to be a search URL")
        expect("?" not in source_url, f"{image_id} sourceURL must not contain query parameters")
        for forbidden_marker in ["AppIcon", "YouNewLogo", "_flag", "_coat_of_arms", "Flag_of_", "wapen"]:
            expect(forbidden_marker not in entry, f"{image_id} appears to reference logo or official symbol asset: {forbidden_marker}")


def history_media_static_qa():
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts/history-media-static-qa.py")],
        check=False,
        capture_output=True,
        text=True,
    )
    expect(result.returncode == 0, result.stdout.strip() or result.stderr.strip() or "History media static QA failed")


def main():
    app_icon_checks()
    asset_reference_checks()
    production_logo_checks()
    official_symbol_checks()
    localization_checks()
    source_guard_checks()
    content_image_checks()
    history_media_static_qa()
    print("Brand static QA passed")


if __name__ == "__main__":
    main()
