#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
CYRILLIC = re.compile(r"[А-Яа-яЁё]")


def read(path):
    target = ROOT / path
    if not target.exists() and path.startswith("YouNew/Views/"):
        matches = sorted((ROOT / "YouNew/Features").rglob(Path(path).name))
        if len(matches) == 1:
            target = matches[0]
    return target.read_text(encoding="utf-8")


def fail(message):
    print(f"User-visible completeness QA failed: {message}")
    sys.exit(1)


def main():
    app_destination_view = read("YouNew/App/Navigation/AppDestinationView.swift")
    root_menu = read("YouNew/App/AppTabView.swift")
    search = read("YouNew/Views/SearchView.swift")
    l10n = read("YouNew/Core/Localization/L10n.swift")
    translator_view_model = read("YouNew/ViewModels/TranslatorViewModel.swift")
    culture_data = read("YouNew/Data/MockNetherlandsUnderstandingData.swift")
    transport_data = read("YouNew/Data/TransportGuideData.swift")
    knm_data = read("YouNew/Data/KNMGuideData.swift")
    dutch_data = read("YouNew/Data/DutchA1A2CourseData.swift")
    official_sources = read("YouNew/Views/OfficialSourceDirectoryView.swift")
    province_view = read("YouNew/Views/ProvinceDirectoryView.swift")
    netherlands_overview = read("YouNew/Views/NetherlandsOverviewView.swift")
    first_steps = read("YouNew/Views/FirstStepsView.swift")
    info_hub = read("YouNew/Views/InformationHubView.swift")
    search_answer_model = read("YouNew/Models/SearchAnswer.swift")
    letter_model = read("YouNew/Models/LetterExample.swift")
    risk_model = read("YouNew/Models/RiskItem.swift")
    checklist_model = read("YouNew/Models/ChecklistItem.swift")
    fine_model = read("YouNew/Models/FineInfoItem.swift")
    mistake_model = read("YouNew/Models/NewcomerMistake.swift")
    route_report = read("QA/ROUTE_ACTION_SANITY_REPORT.md")
    manual_qa = read("MANUAL_RUNTIME_QA_CHECKLIST.md")
    swift_sources = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in (ROOT / "YouNew").rglob("*.swift")
    )

    for dead_route in [
        "case .scamWarningsList: notFoundView",
        "case .scamWarning: notFoundView",
    ]:
        if dead_route in app_destination_view:
            fail(f"dead visible route remains: {dead_route}")

    required_destinations = [
        "KNMGuideView()",
        "DutchA1A2View()",
        "TransportGuideView()",
        "OfficialSourceDirectoryView()",
        "InformationHubView()",
        "CultureAttractionsView()",
        "NetherlandsHistoryView()",
    ]
    for needle in required_destinations:
        if needle not in app_destination_view:
            fail(f"destination not wired: {needle}")

    for menu_id in ['"knm"', '"dutchA1A2"', '"transport"', '"healthcare"', '"digid"', '"housing"', '"official"']:
        if f"SideMenuItemModel(id: {menu_id}" not in root_menu:
            fail(f"practical menu item missing: {menu_id}")
    if 'SideMenuItemModel(id: "feedback"' in root_menu and "isVisible: false" not in root_menu:
        fail("feedback menu item is visible without a production route")
    if "TranslatorView()" in app_destination_view or "TranslatorView()" in root_menu:
        fail("mock-backed TranslatorView is exposed as a production route")
    if "MockTranslationProvider()" in translator_view_model:
        for forbidden_translator_claim in [
            "Translate Dutch official text",
            "Nederlandse officiële tekst vertalen",
            "Перевод официальных нидерландских текстов",
        ]:
            if forbidden_translator_claim in l10n:
                fail(f"mock-backed translator fallback copy overclaims production translation: {forbidden_translator_claim}")

    for forbidden_service_note in [
        "Each topic now follows the same rhythm",
        "same rhythm",
    ]:
        if forbidden_service_note in swift_sources:
            fail(f"service implementation note is visible in UI source: {forbidden_service_note}")

    settings_view = read("YouNew/Views/SettingsView.swift")
    if "private var displayedProfileName" not in settings_view or "appState.selectedUserStatus?.localized(lang)" not in settings_view:
        fail("Settings profile header must bind its displayed name to selected UserStatus before ProfileType fallback")
    if "private var visibleSourceCount" not in official_sources:
        fail("Official Sources must use one visible-source count for hero and section subtitles")
    if official_sources.count('String(format: L10n.t("official_sources.subtitle", lang), visibleSourceCount)') != 2:
        fail("Official Sources hero and section subtitle counts are not using the same visibleSourceCount source")
    topic_hero_map_match = re.search(r"private var topicHeroAssetName: String\?.*?private var topicHeroAsset: AppImageAsset\?", first_steps, re.S)
    if not topic_hero_map_match:
        fail("Practical guide topic hero asset-name map missing")
    topic_hero_map = topic_hero_map_match.group(0)
    for required_topic_hero in [
        'case .firstStepsNetherlands:\n            return "premium_home_documents"',
        'case .municipalityRegistration:\n            return "home_documents_city_hall"',
        'case .healthcareBasics:\n            return "premium_home_healthcare"',
        'case .findingHuisarts:\n            return "home_healthcare_pharmacy"',
        'case .healthInsuranceBasics:\n            return "premium_home_documents"',
        'case .digidSafety:\n            return "premium_home_language"',
        'case .officialSourcesChecklist:\n            return "home_leiden_canals"',
        'case .bankingBasics:\n            return "premium_home_work"',
    ]:
        if required_topic_hero not in topic_hero_map:
            fail(f"Practical guide hero map missing distinct topic asset: {required_topic_hero}")
    if 'case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics:' in topic_hero_map:
        fail("Practical guide healthcare topics still share one hero image mapping")
    if 'case .firstStepsNetherlands, .municipalityRegistration, .officialSourcesChecklist:' in topic_hero_map:
        fail("Practical guide civic topics still share one hero image mapping")
    if 'private func dashboardInfoTile' in first_steps:
        fail("Practical guide dashboard guard is reading the wrong file")
    more_dashboard_info = re.search(r"private func dashboardInfoTile.*?private func dashboardDestinationCard", read("YouNew/Views/MoreHubView.swift"), re.S)
    if not more_dashboard_info or ".lineLimit(2)" not in more_dashboard_info.group(0):
        fail("More dashboard info tile titles must allow two lines to avoid clipped labels")
    root_regular_row = re.search(r"private func regularRowContent.*?private var regularTabContent", root_menu, re.S)
    if not root_regular_row or root_regular_row.group(0).count(".lineLimit(2)") < 2:
        fail("Regular sidebar rows must allow two-line titles/subtitles to avoid clipped labels")
    root_side_menu_item = re.search(r"private struct SideMenuItem: View.*?#if DEBUG", root_menu, re.S)
    if not root_side_menu_item or root_side_menu_item.group(0).count(".lineLimit(2)") < 2:
        fail("Side menu item titles/subtitles must allow two lines to avoid clipped labels")
    root_side_pill = re.search(r"private func sidePillAction.*?private var completedMenuSteps", root_menu, re.S)
    if not root_side_pill or ".lineLimit(2)" not in root_side_pill.group(0) or "minHeight: 46" not in root_side_pill.group(0):
        fail("Compact side-menu action pills must allow two-line labels for Municipality/Official Sources/Documents-style text")
    official_marker = root_menu.find("private var sideOfficialServicesWidget")
    root_official_services = root_menu[official_marker:official_marker + 1800] if official_marker != -1 else ""
    if root_official_services.count(".lineLimit(2)") < 2:
        fail("Official services side widget title/subtitle must allow two lines to avoid clipped labels")

    for alias in ["knm", "dutch a1-a2", "gemeente", "huisarts", "ovpay", "ns", "bsn", "digid", "afspraak", "de het"]:
        if alias not in search.lower() and alias not in (knm_data + dutch_data + transport_data).lower():
            fail(f"search coverage missing: {alias}")

    forbidden_visible_literals = [
        "Official symbol unavailable",
        "Source unavailable",
        "Resources will appear here",
        "Bronnen verschijnen hier",
        "Ресурсы появятся здесь",
        "Content not found",
        "Coming soon",
        "TODO",
        "FIXME",
        "Lorem",
    ]
    combined = "\n".join([app_destination_view, root_menu, search, l10n, culture_data, province_view, official_sources])
    for needle in forbidden_visible_literals:
        if needle in combined:
            fail(f"forbidden visible placeholder literal found: {needle}")

    for forbidden_model_fallback in [
        "Vertaling volgt binnenkort.",
        "Перевод скоро появится.",
        "Content unavailable in this language.",
        "Inhoud is niet beschikbaar in deze taal.",
    ]:
        if forbidden_model_fallback in search_answer_model + letter_model + risk_model + checklist_model + fine_model + mistake_model:
            fail(f"model fallback can expose placeholder localization: {forbidden_model_fallback}")

    if len(re.findall(r'InfoSourceMetadata\(', culture_data)) < 8:
        fail("culture/history source metadata too thin")
    if len(re.findall(r'transport\.', transport_data)) < 10:
        fail("transport guide content too thin")
    if len(re.findall(r'module\(id:', knm_data)) < 10:
        fail("KNM module count below requirement")
    if len(re.findall(r'\n\s*module\(', dutch_data)) < 10:
        fail("Dutch A1-A2 module count below requirement")
    if "commonMistakesSection" not in first_steps or "dutchWordsSection" not in first_steps:
        fail("practical guides missing common mistakes or useful Dutch words sections")
    if "What to do first" not in info_hub or "New in the Netherlands" not in info_hub:
        fail("connected first-action flows missing from Information Hub")
    if "minimumPracticeQuestions" not in knm_data:
        fail("KNM practice questions are not guaranteed per module")
    if "DutchDialogue" not in read("YouNew/Models/DutchCourseModels.swift") or "Mini-dialogues" not in read("YouNew/Views/DutchA1A2View.swift"):
        fail("Dutch A1-A2 mini-dialogues missing")
    if "Bottom Tab Items" not in route_report or "Right-Side Menu Items" not in route_report:
        fail("route/action sanity report missing required sections")

    guide_content = read("YouNew/Views/GuideContentView.swift")
    guide_sections = set(re.findall(r'GuideSection\(\s*id:\s*"([^"]+)"', guide_content))
    guide_refs = set(re.findall(r'guideSection\("([^"]+)"\)', swift_sources))
    missing_guide_sections = sorted(guide_refs - guide_sections)
    if missing_guide_sections:
        fail(f"guide section routes missing canonical content: {', '.join(missing_guide_sections)}")

    russian_first_localized = re.search(r'localized\(\s*"([^"]*[А-Яа-яЁё][^"]*)"', swift_sources)
    if russian_first_localized:
        fail(f"Russian-first positional localization call found: {russian_first_localized.group(1)[:80]}")

    for forbidden_route_report_text in ["destination exists: no", "Destination exists: no", "TODO", "FIXME", "Coming soon"]:
        if forbidden_route_report_text in route_report:
            fail(f"route/action sanity report contains failing marker: {forbidden_route_report_text}")
    for required_route_section in [
        "Information Hub Cards",
        "Search Result Types",
        "Practical Guide Cards",
        "KNM Module Routes",
        "Dutch A1-A2 Module Routes",
    ]:
        if required_route_section not in route_report:
            fail(f"route/action sanity report missing: {required_route_section}")
    if "not an official DUO exam" not in knm_data + read("YouNew/Views/KNMGuideView.swift"):
        fail("KNM unofficial disclaimer missing")
    if "not an official exam" not in read("YouNew/Views/DutchA1A2View.swift"):
        fail("Dutch A1-A2 unofficial disclaimer missing")
    if "@EnvironmentObject private var languageManager" not in netherlands_overview:
        fail("Netherlands overview is not connected to LanguageManager")
    for forbidden_netherlands_overview_pattern in [
        'Text("Kingdom of the Netherlands")',
        'overviewSection("Key facts")',
        'overviewSection("Country overview")',
        'OverviewStatCard(icon: "🌍", label: "International life", value: "major cities")',
        'OverviewStatCard(icon: "🚲", label: "Bikes", value: "more than residents")',
        "Text(NetherlandsCountry.overview)",
        "ForEach(NetherlandsCountry.fastFacts)",
        'Text("\\(university.city) · founded',
    ]:
        if forbidden_netherlands_overview_pattern in netherlands_overview:
            fail(f"Netherlands overview production screen bypasses localization: {forbidden_netherlands_overview_pattern}")

    for checklist_item in [
        "Dutch A1-A2 opens from right-side Practical menu",
        "KNM",
        "Official Sources",
        "small iPhone",
    ]:
        if checklist_item not in manual_qa:
            fail(f"manual runtime checklist missing: {checklist_item}")

    print("User-visible completeness static QA passed")


if __name__ == "__main__":
    main()
