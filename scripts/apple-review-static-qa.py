#!/usr/bin/env python3
import plistlib
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = ROOT / "YouNew"


def fail(message: str) -> None:
    print(f"Apple review static QA failed: {message}")
    sys.exit(1)


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def swift_text() -> str:
    return "\n".join(read(path) for path in sorted(APP_ROOT.rglob("*.swift")))


def privacy_reasons(manifest: dict, category: str) -> set[str]:
    for item in manifest.get("NSPrivacyAccessedAPITypes", []):
        if item.get("NSPrivacyAccessedAPIType") == category:
            return set(item.get("NSPrivacyAccessedAPITypeReasons", []))
    return set()


def info_plist_value(project_text: str, key: str) -> str:
    match = re.search(rf"{re.escape(key)}\s*=\s*\"([^\"]+)\";", project_text)
    return match.group(1) if match else ""


def main() -> None:
    source = swift_text()
    project = read(ROOT / "YouNew.xcodeproj/project.pbxproj")
    manifest_path = APP_ROOT / "PrivacyInfo.xcprivacy"

    expect(manifest_path.exists(), "PrivacyInfo.xcprivacy is missing")
    manifest = plistlib.loads(manifest_path.read_bytes())
    expect(manifest.get("NSPrivacyTracking") is False, "privacy manifest must declare tracking as false")
    expect(manifest.get("NSPrivacyTrackingDomains") == [], "privacy manifest tracking domains must be empty")
    expect(manifest.get("NSPrivacyCollectedDataTypes") == [], "privacy manifest must not declare collected data")

    if "UserDefaults" in source:
        expect(
            "CA92.1" in privacy_reasons(manifest, "NSPrivacyAccessedAPICategoryUserDefaults"),
            "UserDefaults usage requires privacy reason CA92.1",
        )
    expect(
        "C617.1" in privacy_reasons(manifest, "NSPrivacyAccessedAPICategoryFileTimestamp"),
        "file timestamp privacy reason C617.1 is missing",
    )
    expect(
        "PBXFileSystemSynchronizedRootGroup" in project and "path = YouNew;" in project,
        "app sources are not covered by the synchronized project group",
    )

    ai_safety_filter = read(APP_ROOT / "Services/AISafetyFilter.swift")
    expect(
        'debugLog("PII whitelist hit \\(safePattern.label) in input \\(message)")' not in ai_safety_filter
        and 'debugLog("Detected PII pattern \\(pattern.label) in input \\(message)")' not in ai_safety_filter
        and "print(message)" not in ai_safety_filter,
        "AI safety filter must not log raw user input when sensitive personal data is detected",
    )

    location_checked = False
    if "CLLocationManager" in source or "requestWhenInUseAuthorization" in source:
        location_checked = True
        location_purpose = info_plist_value(project, "INFOPLIST_KEY_NSLocationWhenInUseUsageDescription")
        expect(location_purpose, "location permission purpose string is missing")
        expect("not stored" in location_purpose.lower(), "location purpose string must state storage behavior")

        location_service = read(APP_ROOT / "Services/LocationService.swift")
        expect(
            "shouldRequestLocationAfterAuthorization = true" in location_service
            and "manager.requestWhenInUseAuthorization()" in location_service,
            "location request must remember to fetch after authorization",
        )
        authorization_handler = location_service.split("locationManagerDidChangeAuthorization", 1)[-1]
        expect("requestLocation()" in authorization_handler, "location authorization handler does not request location")

        map_view = read(APP_ROOT / "Views/NearbyMapView.swift")
        expect("status == .denied || status == .restricted" in map_view, "map view lacks denied/restricted location state")
        expect("UIApplication.openSettingsURLString" in map_view, "map view lacks Settings route for denied location")
        expect("Button(locationOpenSettingsLabel)" in map_view, "map view lacks localized Settings button")
        expect(
            "Button(locationOpenSettingsLabel)" in map_view
            and ".frame(minHeight: AppButtonMetrics.minTouchSize)" in map_view.split("Button(locationOpenSettingsLabel)", 1)[1],
            "location Settings button does not enforce minimum touch height",
        )

        map_model = read(APP_ROOT / "ViewModels/MapViewModel.swift")
        expect("case .denied, .restricted:" in map_model, "map model must handle denied/restricted location")

    navigation_components = read(APP_ROOT / "Core/DesignSystem/Components/NavigationUIComponents.swift")
    institution_chip = navigation_components.split("struct InstitutionChip", 1)[-1].split("struct QuickActionButton", 1)[0]
    expect(
        ".frame(minHeight: AppButtonMetrics.minTouchSize)" in institution_chip,
        "InstitutionChip must enforce the shared minimum touch height",
    )

    app_spacing = read(APP_ROOT / "Core/DesignSystem/Tokens/AppSpacing.swift")
    root_tab = read(APP_ROOT / "App/AppTabView.swift")
    expect("enum GlobalAILauncherMetrics" in app_spacing, "global AI launcher clearance metrics are missing")
    expect(
        "GlobalAILauncherMetrics.contentReserve(" not in root_tab,
        "global AI launcher must not add permanent height to root content",
    )
    expect(
        "bottomPadding + collapsedHeight + contentGap + (isExpanded ? expandedMenuHeight : 0)" in app_spacing,
        "global AI launcher content reserve must account for collapsed and expanded launcher height",
    )
    expect(
        "static let expandedMenuHeight: CGFloat = 430" in app_spacing,
        "global AI launcher expanded reserve must cover two-line localized mode labels",
    )
    expect(
        "shouldShowContextualAIButton ? 76 : 0" not in root_tab,
        "root content reserve still uses the old fixed 76pt AI launcher clearance",
    )
    expect(
        "private var shouldShowContextualAIButton: Bool" in root_tab
        and "static func shouldShowContextualAIButton(selectedTab: AppTab, isMenuPresented: Bool) -> Bool" in root_tab
        and "!isMenuPresented" in root_tab
        and "selectedTab != .more" in root_tab
        and "selectedTab != .saved" in root_tab,
        "global AI launcher must hide while the menu, More tab, or Saved tab is active",
    )
    expect(
        ".safeAreaInset(edge: .bottom, spacing: 0)" in root_tab
        and ".overlay(alignment: .bottomTrailing) { contextualAIButton }" in root_tab
        and "contextualAIContentReserve" not in root_tab,
        "tab bar must use bottom safe-area inset while the AI launcher remains a non-layout overlay",
    )
    expect(
        ".zIndex(20)" in root_tab.split("private var contextualAIButton", 1)[1].split("private var shouldShowContextualAIButton", 1)[0],
        "global AI launcher overlay z-index must be explicit",
    )
    expect(
        ".zIndex(50)" in root_tab.split("RightSideMenuOverlay", 1)[1].split(".overlay(alignment: .bottomTrailing)", 1)[0],
        "side menu overlay must stay above the global AI launcher",
    )
    for function_name in ["handleTabSelection", "resetTabToRoot", "openMenu", "closeMenu", "openGlobalAssistant"]:
        function_block = root_tab.split(f"private func {function_name}", 1)[1].split("\n    private ", 1)[0]
        expect(
            "isGlobalAIModeLauncherExpanded = false" in function_block,
            f"global AI launcher must collapse during {function_name}",
        )
    launcher_block = root_tab.split("private struct GlobalAIModeLauncher", 1)[1].split("private struct RouteNodeGlyph", 1)[0]
    expect(
        "Label(mode.title(language), systemImage: mode.symbol)" in launcher_block
        and ".lineLimit(2)" in launcher_block
        and ".frame(minHeight: 46, alignment: .trailing)" in launcher_block,
        "global AI launcher mode labels must support two lines with a stable minimum height",
    )

    visual_components = read(APP_ROOT / "Core/DesignSystem/Components/NetherlandsVisualComponents.swift")
    expect(
        "let resolvedHeight = min(max(height, 220), 320)" in visual_components,
        "CategoryHeroVisual must clamp hero card height to the 220-320pt regression-safe range",
    )
    expect(
        ".frame(height: resolvedHeight, alignment: .bottomLeading)" in visual_components
        and ".frame(maxWidth: .infinity, alignment: .bottomLeading)" in visual_components,
        "CategoryHeroVisual must keep image content inside a fixed-height bounded hero card",
    )
    more_view = read(APP_ROOT / "Views/MoreHubView.swift")
    more_hero = more_view.split("private var moreHeroSection", 1)[1].split("private var quickActionsSection", 1)[0]
    expect(
        ".frame(height: 220, alignment: .bottomLeading)" in more_hero
        and ".frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)" in more_hero
        and "more.hero.bounds" in more_hero,
        "More screen hero must stay in the 220-320pt target range",
    )
    assistant_view = read(APP_ROOT / "Views/AIAssistantView.swift")
    expect(
        "PremiumVisualMetrics.Hero.regularHeight" in assistant_view
        and "PremiumVisualMetrics.Layout.bottomTerminalGap" in assistant_view
        and "assistantComposerTabBarClearance" in assistant_view
        and "FloatingTabBarMetrics.height - 2" not in assistant_view
        and "measuredComposerHeight + PremiumVisualMetrics.Layout.bottomTerminalGap" in assistant_view
        and ".padding(.bottom, 6 + tabBarClearance)" in assistant_view,
        "AI Assistant hero and composer must keep first-screen cards clear of overlays",
    )

    home_view = read(APP_ROOT / "Views/HomeView.swift")
    welcome_hero = home_view.split("private func welcomeHeroSection", 1)[1].split("private var heroQuickIntelligence", 1)[0]
    expect(
        ".frame(maxWidth: .infinity, minHeight: heroHeight, alignment: .bottomLeading)" in welcome_hero,
        "Home hero must use a minimum height so long localized/Dynamic Type content can grow instead of overlapping",
    )
    hero_city_actions = read(APP_ROOT / "Views/HomeHeroComponents.swift")
    hero_city_actions_callsite = home_view.split("HomeHeroCityActions(", 1)[1].split("            }\n            .padding(.horizontal", 1)[0]
    expect(
        "AppDestination.nlCityDetail(cityDashboard.routeCityId)" in hero_city_actions_callsite
        and "home.hero.exploreCity" in hero_city_actions,
        "Home hero Explore city CTA must target selected city detail and expose a stable runtime identifier",
    )
    expect(
        ".magneticEffect()" not in hero_city_actions,
        "Home hero Explore city CTA must not use magneticEffect because it can misroute taps to the persona card below",
    )
    expect(
        ".contentShape(Rectangle())" in hero_city_actions
        and ".zIndex(2)" in hero_city_actions,
        "Home hero Explore city CTA must own its hit target and remain above neighboring hero content",
    )
    home_map_card = read(APP_ROOT / "Views/HomeMapComponents.swift")
    expect(
        ".frame(maxWidth: .infinity, minHeight: dynamicTypeSize.isAccessibilitySize ? 500 : 420)" in home_map_card,
        "Home Netherlands Map card must use a minimum height for long localized headers and controls",
    )

    cities_view = read(APP_ROOT / "Views/CitiesDirectoryView.swift")
    expect(
        'CategoryHeroVisual(\n            assetName: "home_leiden_canals"' in cities_view,
        "Cities directory hero must stay on the shared flexible CategoryHeroVisual component",
    )

    map_hub = read(APP_ROOT / "Views/NetherlandsInteractiveMapView.swift")
    map_header = map_hub.split("private var mapHeaderHorizontal", 1)[1].split("private var mapLegend", 1)[0]
    expect(
        'Text(headerTitle)' in map_header
        and map_header.count(".fixedSize(horizontal: false, vertical: true)") >= 4
        and ".lineLimit(2)" in map_header
        and ".lineLimit(3)" in map_header,
        "Netherlands map header must wrap localized title/subtitle text instead of crowding controls",
    )

    province_view = read(APP_ROOT / "Views/ProvinceDirectoryView.swift")
    city_hero = province_view.split("struct CityHeroImageView", 1)[1].split("struct CityFlagBadge", 1)[0]
    expect(
        "@Environment(\\.dynamicTypeSize) private var dynamicTypeSize" in city_hero
        and "let contentWidth: CGFloat" in city_hero
        and ".frame(width: contentWidth, height: heroMinimumHeight, alignment: .bottomLeading)" in city_hero
        and "private var heroMinimumHeight: CGFloat" in city_hero,
        "City detail hero must use Dynamic Type-aware height and explicit content width instead of overflowing infinity layout",
    )
    expect(
        ".frame(height: CityDetailLayout.heroHeight)" not in city_hero,
        "City detail hero still uses a fixed height that can clip long localized hero content",
    )

    camera_checked = False
    if "VNDocumentCameraViewController" in source or "UIImagePickerController.isSourceTypeAvailable(.camera)" in source:
        camera_checked = True
        camera_purpose = info_plist_value(project, "INFOPLIST_KEY_NSCameraUsageDescription")
        expect(camera_purpose, "camera permission purpose string is missing")
        expect("locally on your device" in camera_purpose.lower(), "camera purpose string must state local storage")

        document_view = read(APP_ROOT / "Views/DocumentOrganizerView.swift")
        expect(
            "UIImagePickerController.isSourceTypeAvailable(.camera)" in document_view
            and "Bundle.main.object(forInfoDictionaryKey: \"NSCameraUsageDescription\")" in document_view,
            "document scanner must guard camera availability and purpose string before presenting",
        )
        expect("VNDocumentCameraViewController" in document_view, "document scanner controller is missing")
        expect(".completeFileProtection" in document_view, "scanned PDF write must use file protection")
        expect("values.isExcludedFromBackup = true" in document_view, "scanned temporary files must be excluded from backup")

    photo_patterns = [
        r"\bPHPicker",
        r"\bPhotosPicker",
        r"\bPHPhotoLibrary",
        r"\.photoLibrary",
        r"UIImagePickerController\.SourceType\.photoLibrary",
    ]
    photo_hits = [pattern for pattern in photo_patterns if re.search(pattern, source)]
    expect(not photo_hits, f"photo-library API usage needs review before release: {photo_hits}")

    print("Apple review static QA passed")
    print(f"- Privacy manifest categories checked: {len(manifest.get('NSPrivacyAccessedAPITypes', []))}")
    print(f"- Location permission paths checked: {'yes' if location_checked else 'no'}")
    print(f"- Camera scanner permission paths checked: {'yes' if camera_checked else 'no'}")
    print("- AI sensitive-input logging checked")
    print("- Photo library API usage checked: 0")


if __name__ == "__main__":
    main()
