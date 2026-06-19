#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def fail(message):
    print(f"Content QA failed: {message}")
    sys.exit(1)


def main():
    data = read("YouNew/Data/MockNetherlandsUnderstandingData.swift")
    netherlands_data = read("YouNew/Data/NetherlandsData.swift")
    models = read("YouNew/Models/NetherlandsUnderstandingModels.swift")
    root_menu = read("YouNew/App/AppTabView.swift")
    nearby_map = read("YouNew/Views/NearbyMapView.swift")
    transport_data = read("YouNew/Data/TransportGuideData.swift")
    transport_view = read("YouNew/Views/TransportGuideView.swift")
    daily_life_data = read("YouNew/Data/MockDailyLifeData.swift")
    fines_view = read("YouNew/Views/FinesInfoView.swift")
    app_destination_view = read("YouNew/App/Navigation/AppDestinationView.swift")
    search_view = read("YouNew/Views/SearchView.swift")
    home_view = read("YouNew/Views/HomeView.swift")
    more_view = read("YouNew/Views/MoreHubView.swift")
    ai_context_builder = read("YouNew/Services/AIContextBuilder.swift")
    ai_view_model = read("YouNew/ViewModels/AIViewModel.swift")
    ai_safety_rules = read("YouNew/Services/AISafetyRules.swift")
    ai_assistant_view = read("YouNew/Views/AIAssistantView.swift")
    destinations = read("YouNew/App/Navigation/AppDestinationView.swift")
    hub = read("YouNew/Views/InformationHubView.swift")
    app_state = read("YouNew/ViewModels/AppStateViewModel.swift")

    if "struct CityInfoProfile" not in models:
        fail("CityInfoProfile model is missing")
    if "InformationHubView()" not in destinations:
        fail("Information Hub route is not wired")
    if "case .informationHub: return .informationHub" not in root_menu:
        fail("Information Hub destination is not routable")
    if "TODO" in hub or "placeholder" in hub.lower():
        fail("Information Hub contains placeholder text")
    if "switch (section, language)" not in app_state:
        fail("AppStateViewModel.sectionSummary must localize by language")
    for localized_summary in ["Выберите ситуацию", "Kies je situatie", "Select your situation"]:
        if localized_summary not in app_state:
            fail(f"AppStateViewModel.sectionSummary missing localized summary: {localized_summary}")
    for required in [
        "GlobalAIModeLauncher",
        "global.aiLauncher",
        "openGlobalAssistant",
        "case askQuestion",
        "case explainScreen",
        "case nextStep",
        "case findInApp",
        "case translate",
        "case guideMe",
        "AIContextBuilder.automaticContext",
        "AIContextBuilder.automaticPrompt",
    ]:
        if required not in root_menu:
            fail(f"Global contextual AI integration missing {required}")
    for required in [
        "static func automaticContext(",
        "static func practicalGuideContext(",
        "static func knmContext(",
        "static func dutchCourseContext(",
        "static func officialSourcesContext(",
        "Do not give fixed fares",
    ]:
        if required not in ai_context_builder:
            fail(f"AI context builder missing {required}")
    if "switch AISafetyFilter.evaluate(message" not in ai_view_model:
        fail("AIViewModel must evaluate user message safety before sending")
    if "activeContextTitle" not in ai_view_model or "activeContextCard" not in ai_assistant_view:
        fail("AI assistant must show active help context")
    for required in [
        "assistantActionPanel",
        "assistantToolCard(",
        "AppDestination.officialSources",
        "AppDestination.searchList",
        "AppDestination.knm",
        "AppDestination.dutchA1A2",
        "AppDestination.firstSteps",
        "viewModel.suggestedActions",
    ]:
        if required not in ai_assistant_view:
            fail(f"AI assistant multifunction tool missing {required}")
    for localized_disclaimer in [
        'case .russian:\n            return "YouNew предоставляет только информационную помощь. Ответы AI',
        'case .dutch:\n            return "YouNew biedt alleen informatieve hulp. AI-antwoorden',
    ]:
        if localized_disclaimer not in ai_safety_rules:
            fail("AI safety disclaimer must be localized without mixed English in RU/NL")

    required_side_menu = [
        '"sideMenu.subtitle": "Your guide to cities and life in the Netherlands"',
        '"sideMenu.quick.openMap"',
        '"sideMenu.quick.cities"',
        '"sideMenu.quick.firstSteps"',
        '"sideMenu.quick.sources"',
        '"sideMenu.main": "Main"',
        '"sideMenu.main": "Главное"',
        '"sideMenu.main": "Hoofdmenu"',
        '"sideMenu.home"',
        '"sideMenu.map"',
        '"sideMenu.search"',
        '"sideMenu.saved"',
        '"sideMenu.practical": "Practical life"',
        '"sideMenu.practical": "Практическая жизнь"',
        '"sideMenu.practical": "Praktisch leven"',
        '"accessibility.openMenu"',
        '"accessibility.closeMenu"',
    ]
    l10n = read("YouNew/Core/Localization/L10n.swift")
    for needle in required_side_menu:
        if needle not in l10n:
            fail(f"Side menu localization missing {needle}")

    if 'SideMenuItemModel(id: "feedback"' in root_menu and 'isVisible: false' not in root_menu:
        fail("Feedback menu item must stay hidden without a real action")
    for main_item in [
        'SideMenuItemModel(id: "home"',
        'SideMenuItemModel(id: "map"',
        'SideMenuItemModel(id: "search"',
        'SideMenuItemModel(id: "saved"',
    ]:
        if main_item not in root_menu:
            fail(f"Main side menu item missing: {main_item}")
    for forbidden_icon in ["flag", "coatOfArms", "YouNewLogoMark() as SideMenuItem"]:
        if forbidden_icon in root_menu:
            fail(f"Forbidden side menu icon/media usage: {forbidden_icon}")

    compact_items = re.search(r"private var compactTabBarItems: \[FloatingTabBarItem\] \{(.*?)\n    \}", root_menu, re.S)
    if not compact_items or compact_items.group(1).count("FloatingTabBarItem(tab:") != 6:
        fail("Bottom tab count changed from six compact tabs")
    if "if tab == .more {" not in root_menu or "openMenu()" not in root_menu:
        fail("More tab does not open the right-side drawer")
    for route_case in [
        "case .cities: return .cityList",
        "case .provinces: return .provinceList",
        "case .historyNetherlands: return .netherlandsHistory",
        "case .cultureAttractions: return .cultureAttractions",
        "case .officialSources, .sources: return .officialSources",
    ]:
        if route_case not in root_menu:
            fail(f"Visible menu route missing: {route_case}")

    nearby_required = [
        "bottomScrollReserve(safeAreaBottom:",
        "FloatingTabBarMetrics.height",
        "FloatingTabBarMetrics.bottomOffset",
        "AppLayout.bottomNavReserveExtra",
        "LazyHGrid(rows: [GridItem(.fixed(44)",
        "map.search.card",
        "map.search.category.",
        "map.select_city",
        "map.no_auto_send",
        "QuickRouteAction(kind: .sources",
        "NavigationLink(value: destination)",
    ]
    for needle in nearby_required:
        if needle not in nearby_map:
            fail(f"Nearby map layout guard missing {needle}")

    if "categoryFilterBar" in nearby_map:
        fail("Nearby map still uses the old horizontal category filter bar")
    if "AppSpacing.tabBarScrollReserveMap" in nearby_map:
        fail("Nearby map still uses fixed bottom tab reserve")

    required_transport_sections = [
        "transport.overview",
        "transport.trains",
        "transport.busTramMetro",
        "transport.ovChipkaart",
        "transport.ovpay",
        "transport.journeyPlanning",
        "transport.bikes",
        "transport.airports",
        "transport.accessibility",
        "transport.safetyAndRules",
    ]
    for section_id in required_transport_sections:
        if section_id not in transport_data:
            fail(f"Transport guide missing section {section_id}")

    required_transport_sources = [
        "source.ns",
        "source.9292",
        "source.ovpay",
        "source.ovchipkaart",
        "source.gvb",
        "source.ret",
        "source.htm",
        "source.uov",
        "source.schiphol",
    ]
    for source_id in required_transport_sources:
        if source_id not in transport_data:
            fail(f"Transport guide missing source {source_id}")

    for source_url in re.findall(r'AppURL\.make\("([^"]+)"\)', transport_data):
        if not source_url.startswith("https://"):
            fail(f"Transport source URL is not HTTPS: {source_url}")
    for required in ["retrievedAt: \"2026-06-01\"", "verified: true", "searchAliases", "OVpay", "OV-chipkaart", "9292"]:
        if required not in transport_data:
            fail(f"Transport guide metadata missing {required}")
    for required in [
        "costNotes(for:",
        "practicalTips(for:",
        "hints(for:",
        "Cost and payment",
        "Стоимость и оплата",
        "Practical tips",
        "Практические советы",
        "Подсказки",
    ]:
        if required not in transport_data and required not in transport_view:
            fail(f"Transport guide expanded advice block missing {required}")
    for section_id in required_transport_sections:
        for helper in ["costNotes", "practicalTips", "hints"]:
            if f'case "{section_id}":' not in transport_data:
                fail(f"Transport guide expanded helper missing case for {section_id}")
    for unstable_price_claim in ["€", "euro", "costs exactly", "always costs", "guaranteed fare", "фиксированная цена", "всегда стоит"]:
        if unstable_price_claim.lower() in transport_data.lower():
            fail(f"Transport guide contains unsupported fixed-price wording: {unstable_price_claim}")
    for forbidden in ["TODO", "placeholder"]:
        if forbidden.lower() in transport_data.lower() or forbidden.lower() in transport_view.lower():
            fail(f"Transport guide contains {forbidden}")
    for stale_claim in [
        "in 2024 this was",
        "approximately €4.25",
        "Since 2023, statiegeld",
        "since April 2023",
    ]:
        if stale_claim.lower() in daily_life_data.lower():
            fail(f"Daily Life guide contains stale monetary wording: {stale_claim}")
    for stale_fine in ['fine: "€60"', 'fine: "€95"', 'fine: "€75"', 'fine: "€55"']:
        if stale_fine in fines_view:
            fail(f"Fines quick cards contain hardcoded stale amount: {stale_fine}")
    exact_admissions = re.findall(r'admission:\s*"€[^"]*"', netherlands_data)
    if exact_admissions:
        fail(f"City attraction records contain exact admission prices: {exact_admissions[:3]}")

    if "topic == .transportBasics" not in app_destination_view or "TransportGuideView()" not in app_destination_view:
        fail("Transport practical guide does not route to TransportGuideView")
    if "case .transport:" not in nearby_map or "return .practicalGuide(.transportBasics)" not in nearby_map:
        fail("Nearby quick Transport route does not open the transport guide")
    if "destination: .practicalGuide(.transportBasics)" not in home_view:
        fail("Home Transport tile does not open the transport guide")
    if "destination: .practicalGuide(.transportBasics)" not in more_view:
        fail("More hub Transport item does not open the transport guide through the shared route")
    for alias in ["ns", "ovpay", "9292", "транспорт", "поезд", "автобус", "трамвай", "метро", "велосипед"]:
        if alias not in transport_data.lower():
            fail(f"Transport search alias missing {alias}")
    if "TransportGuideData.guide.searchAliases" not in search_view:
        fail("Search does not index transport guide aliases")

    city_profiles = re.findall(r"cityInfo\(\s*cityId:", data)
    if len(city_profiles) < 8:
        fail(f"Expected at least 8 supported city profiles, found {len(city_profiles)}")

    for article_set in ["cultureArticles", "attractionArticles"]:
        if article_set not in data:
            fail(f"{article_set} is missing")
    if "image: ContentMediaRegistry.image(forContentID: id)" not in data:
        fail("Culture/attraction articles are not connected to verified content images")
    if "AppContentImageView(" not in read("YouNew/Views/CultureAttractionsView.swift"):
        fail("Culture & Attractions cards do not render verified article images")

    missing_sources_assert = "validateCityInfoProfiles(profiles).isEmpty"
    if missing_sources_assert not in data:
        fail("City profile source validation is not enforced in DEBUG")

    if "Source unavailable" in hub:
        fail("User-facing hub can expose unavailable source fallback")

    print("Content static QA passed")


if __name__ == "__main__":
    main()
