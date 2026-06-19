#!/usr/bin/env python3
from pathlib import Path
import re
import sys
import unicodedata


ROOT = Path(__file__).resolve().parents[1]
SWIFT_ROOT = ROOT / "YouNew"


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.exists():
        fail(f"missing file: {relative}")
    return path.read_text(encoding="utf-8")


def fail(message: str) -> None:
    print(f"Route/action static QA failed: {message}")
    sys.exit(1)


def expect(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def swift_files_text() -> str:
    return "\n".join(path.read_text(encoding="utf-8", errors="ignore") for path in SWIFT_ROOT.rglob("*.swift"))


def enum_cases(enum_text: str, enum_name: str) -> set[str]:
    body = named_type_body(enum_text, "enum", enum_name)
    cases: set[str] = set()
    for raw_line in body.splitlines():
        line = raw_line.strip()
        if cases and (line.startswith("var ") or line.startswith("func ") or line.startswith("static ")):
            break
        if not line.startswith("case "):
            continue
        line = line.removeprefix("case ")
        for part in split_top_level_commas(line):
            name = part.strip().split("(", 1)[0].split(" ", 1)[0]
            if name:
                cases.add(name)
    return cases


def named_type_body(text: str, kind: str, name: str) -> str:
    match = re.search(rf"\b{re.escape(kind)}\s+{re.escape(name)}\b[^\{{]*\{{", text)
    expect(match is not None, f"missing {kind} {name}")
    open_index = match.end() - 1
    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[open_index + 1:index]
    fail(f"unterminated {kind} {name}")
    return ""


def split_top_level_commas(text: str) -> list[str]:
    parts: list[str] = []
    start = 0
    depth = 0
    for index, char in enumerate(text):
        if char == "(":
            depth += 1
        elif char == ")":
            depth = max(0, depth - 1)
        elif char == "," and depth == 0:
            parts.append(text[start:index])
            start = index + 1
    parts.append(text[start:])
    return parts


def app_destination_view_cases(view_text: str) -> set[str]:
    return set(re.findall(r"case\s+\.([A-Za-z0-9_]+)\b", view_text))


def hardcoded_app_destination_cases(all_text: str) -> set[str]:
    cases = set(re.findall(r"AppDestination\.([A-Za-z0-9_]+)\b", all_text))
    return {
        case
        for case in cases
        if case
        not in {
            "aiRoute",
            "aiRouteID",
            "allKnownAIRouteIDs",
            "swift",
            "self",
            "none",
            "some",
            "init",
        }
    }


def guide_section_ids(guide_text: str) -> set[str]:
    return set(re.findall(r"(?:GuideSection|section)\(\s*id:\s*\"([^\"]+)\"", guide_text))


def knm_module_ids(knm_text: str) -> set[str]:
    return set(re.findall(r"\bmodule\(\s*id:\s*\"([^\"]+)\"", knm_text))


def dutch_course_module_ids(dutch_course_text: str) -> set[str]:
    return set(re.findall(r"\bmodule\(\s*\"([^\"]+)\"", dutch_course_text))


def normalized_lookup_key(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value.strip().lower())
    normalized = "".join(char for char in normalized if not unicodedata.combining(char))
    parts: list[str] = []
    current: list[str] = []
    for char in normalized:
        if char.isalnum():
            current.append(char)
        elif current:
            parts.append("".join(current))
            current = []
    if current:
        parts.append("".join(current))
    return "_".join(parts)


def knowledge_slug(value: str) -> str:
    return normalized_lookup_key(value).replace("_", "-")


def province_ids(province_catalog_text: str) -> set[str]:
    return set(re.findall(r"ProvinceItem\(\s*id:\s*\"([^\"]+)\"", province_catalog_text))


def province_cities(province_catalog_text: str) -> set[tuple[str, str]]:
    return set(re.findall(r"\bcity\(\s*\"([^\"]+)\"\s*,\s*\"[^\"]*\"\s*,\s*\"[^\"]*\"\s*,\s*\"([^\"]+)\"", province_catalog_text))


def main() -> None:
    app_destination = read("YouNew/App/Navigation/AppDestination.swift")
    app_destination_view = read("YouNew/App/Navigation/AppDestinationView.swift")
    root_tab = read("YouNew/App/AppTabView.swift")
    navigation_resolver = read("YouNew/App/Navigation/AppRouter.swift")
    saved_items_store = read("YouNew/Models/SavedItemsStore.swift")
    guide_content = read("YouNew/Views/GuideContentView.swift")
    knm_content = read("YouNew/Data/KNMGuideData.swift")
    dutch_course_content = read("YouNew/Data/DutchA1A2CourseData.swift")
    province_directory_content = read("YouNew/Views/ProvinceDirectoryView.swift")
    more_hub = read("YouNew/Views/MoreHubView.swift")
    settings_view = read("YouNew/Views/SettingsView.swift")
    document_organizer = read("YouNew/Views/DocumentOrganizerView.swift")
    checklist_detail = read("YouNew/Views/ChecklistItemDetailView.swift")
    search_answer_detail = read("YouNew/Views/SearchAnswerDetailView.swift")
    dutch_terms = read("YouNew/Views/DutchTermsView.swift")
    mistakes_library = read("YouNew/Views/MistakesLibraryView.swift")
    letter_detail = read("YouNew/Views/LetterDetailView.swift")
    map_view_model = read("YouNew/ViewModels/MapViewModel.swift")
    place_detail = read("YouNew/Views/PlaceDetailView.swift")
    all_text = swift_files_text()

    destination_cases = enum_cases(app_destination, "AppDestination")
    rendered_cases = app_destination_view_cases(app_destination_view)
    missing_renderers = sorted(destination_cases - rendered_cases)
    expect(not missing_renderers, f"AppDestinationView missing renderers for {missing_renderers}")

    route_id_cases = set(re.findall(r"case\s+\.([A-Za-z0-9_]+)\b", named_function_body(navigation_resolver, "routeID")))
    ai_route_id_cases = set(re.findall(r"case\s+\.([A-Za-z0-9_]+)\b", named_function_body(app_destination, "aiRouteID")))
    missing_route_ids = sorted(destination_cases - route_id_cases - ai_route_id_cases)
    expect(not missing_route_ids, f"AppDestination cases missing stable route IDs {missing_route_ids}")

    referenced_destination_cases = hardcoded_app_destination_cases(all_text)
    unknown_references = sorted(referenced_destination_cases - destination_cases)
    expect(not unknown_references, f"unknown hardcoded AppDestination cases {unknown_references}")

    hardcoded_guide_ids = set(re.findall(r"\.guideSection\(\"([^\"]+)\"\)", all_text))
    defined_guide_ids = guide_section_ids(guide_content)
    missing_guide_ids = sorted(hardcoded_guide_ids - defined_guide_ids)
    expect(not missing_guide_ids, f"hardcoded guideSection ids missing from GuideContent {missing_guide_ids}")

    hardcoded_knm_module_ids = set(re.findall(r"\.knmModule\(\"([^\"]+)\"\)|initialModuleID:\s*\"([^\"]+)\"", all_text))
    hardcoded_knm_module_ids = {value for match in hardcoded_knm_module_ids for value in match if value}
    defined_knm_module_ids = knm_module_ids(knm_content)
    missing_knm_module_ids = sorted(hardcoded_knm_module_ids - defined_knm_module_ids)
    expect(not missing_knm_module_ids, f"hardcoded KNM module ids missing from KNMGuideData {missing_knm_module_ids}")

    hardcoded_dutch_course_module_ids = set(re.findall(r"\.dutchA1A2Module\(\"([^\"]+)\"\)", all_text))
    defined_dutch_course_module_ids = dutch_course_module_ids(dutch_course_content)
    missing_dutch_course_module_ids = sorted(hardcoded_dutch_course_module_ids - defined_dutch_course_module_ids)
    expect(not missing_dutch_course_module_ids, f"hardcoded Dutch A1-A2 module ids missing from DutchA1A2CourseData {missing_dutch_course_module_ids}")

    defined_province_ids = province_ids(province_directory_content)
    normalized_province_ids = {normalized_lookup_key(province_id) for province_id in defined_province_ids}
    normalized_province_route_slugs = {normalized_lookup_key(knowledge_slug(province_id)) for province_id in defined_province_ids}
    expect(
        normalized_province_route_slugs == normalized_province_ids,
        "ProvinceCatalog province lookup keys do not round-trip through route slugs",
    )
    hardcoded_province_ids = set(re.findall(r"\.provinceDetail\(\"([^\"]+)\"\)|\.provinceCities\(\"([^\"]+)\"\)|\.mapFocus\(\.province\(\"([^\"]+)\"\)\)", all_text))
    hardcoded_province_ids = {value for match in hardcoded_province_ids for value in match if value}
    missing_province_ids = sorted(
        province_id
        for province_id in hardcoded_province_ids
        if normalized_lookup_key(province_id) not in normalized_province_ids
    )
    expect(not missing_province_ids, f"hardcoded province ids missing from ProvinceCatalog {missing_province_ids}")

    defined_city_pairs = province_cities(province_directory_content)
    normalized_city_pairs = {
        (normalized_lookup_key(province_id), normalized_lookup_key(city_name))
        for city_name, province_id in defined_city_pairs
    }
    normalized_city_route_pairs = {
        (normalized_lookup_key(knowledge_slug(province_id)), normalized_lookup_key(knowledge_slug(city_name)))
        for city_name, province_id in defined_city_pairs
    }
    expect(
        normalized_city_route_pairs == normalized_city_pairs,
        "ProvinceCatalog city lookup keys do not round-trip through route slugs",
    )
    hardcoded_city_pairs = set(re.findall(r"\.cityDetail\(province:\s*\"([^\"]+)\"\s*,\s*city:\s*\"([^\"]+)\"", all_text))
    missing_city_pairs = sorted(
        f"{province_id}/{city_name}"
        for province_id, city_name in hardcoded_city_pairs
        if (normalized_lookup_key(province_id), normalized_lookup_key(city_name)) not in normalized_city_pairs
    )
    expect(not missing_city_pairs, f"hardcoded city detail routes missing from ProvinceCatalog {missing_city_pairs}")

    defined_city_ids = {f"{province_id}-{city_name}" for city_name, province_id in defined_city_pairs}
    normalized_city_ids = {normalized_lookup_key(city_id) for city_id in defined_city_ids}
    hardcoded_map_city_ids = set(re.findall(r"\.mapFocus\(\.city\(\"([^\"]+)\"\)\)", all_text))
    missing_map_city_ids = sorted(
        city_id
        for city_id in hardcoded_map_city_ids
        if normalized_lookup_key(city_id) not in normalized_city_ids
    )
    expect(not missing_map_city_ids, f"hardcoded map city ids missing from ProvinceCatalog {missing_map_city_ids}")
    expect(
        "case .nlCityDetail(let cityID):" in app_destination_view
        and "ProvinceCatalog.citySpotlight(matching: cityID)" in app_destination_view
        and "CityDetailView(provinceName: spotlight.province.id, cityName: spotlight.city.name)" in app_destination_view,
        "nlCityDetail renderer does not prefer ProvinceCatalog city details",
    )
    expect(
        "case .provinceDetail(let provinceName):" in app_destination_view
        and "if let province = ProvinceCatalog.provinceIfFound(matching: provinceName)" in app_destination_view
        and "ProvinceCityDetailView(provinceName: province.id)" in app_destination_view,
        "provinceDetail renderer does not validate against ProvinceCatalog before rendering",
    )
    expect(
        "case .provinceCities(let provinceName):" in app_destination_view
        and "if let province = ProvinceCatalog.provinceIfFound(matching: provinceName)" in app_destination_view
        and "ProvinceCitiesView(provinceName: province.id)" in app_destination_view,
        "provinceCities renderer does not validate against ProvinceCatalog before rendering",
    )
    expect(
        "case .cityDetail(let province, let city):" in app_destination_view
        and "if let province = ProvinceCatalog.provinceIfFound(matching: province)" in app_destination_view
        and "let city = ProvinceCatalog.cityIfFound(named: city, provinceID: province.id)" in app_destination_view
        and "CityDetailView(provinceName: province.id, cityName: city.name)" in app_destination_view,
        "cityDetail renderer does not validate province/city against ProvinceCatalog before rendering",
    )
    expect("ProvinceCatalog.provinceIfFound(matching: slug)" in navigation_resolver, "AppNavigationResolver province string routes do not resolve through ProvinceCatalog")
    expect("ProvinceCatalog.citySpotlight(matching: slug)" in navigation_resolver, "AppNavigationResolver city string routes do not resolve through ProvinceCatalog")
    expect("guard let spotlight = ProvinceCatalog.citySpotlight(matching: cityID) else { return nil }" in app_destination, "MapFocus city raw values are not validated against ProvinceCatalog")
    expect("self = .city(spotlight.city.id)" in app_destination, "MapFocus city raw values are not canonicalized to ProvinceCatalog city IDs")
    expect("guard let province = ProvinceCatalog.provinceIfFound(matching: provinceID) else { return nil }" in app_destination, "MapFocus province raw values are not validated against ProvinceCatalog")
    expect("self = .province(province.id)" in app_destination, "MapFocus province raw values are not canonicalized to ProvinceCatalog province IDs")
    expect("guard let place = MockNearbyPlacesData.places.first(where: { $0.saveKey == placeID || $0.id.uuidString == placeID }) else { return nil }" in app_destination, "MapFocus place raw values are not validated against nearby place data")
    expect("self = .place(place.saveKey)" in app_destination, "MapFocus place raw values are not canonicalized to nearby place save keys")
    expect(
        "AIAssistantView(mapToolDestination: .mapHub)" in app_destination_view,
        "Assistant app-destination route must open Map through AppDestination.mapHub instead of an ad hoc sheet",
    )
    expect(
        root_tab.count("AIAssistantView(mapToolDestination: .mapHub)") == 3,
        "Root assistant tabs must open the Map tool through AppDestination.mapHub so the Assistant tab stays active",
    )
    expect(
        ".sheet(isPresented: $showMap)" not in app_destination_view and "showMap = true" not in app_destination_view,
        "Assistant app-destination route still presents Map as an untracked sheet",
    )
    expect("ProvinceCatalog.item(id: id).localizedName(lang)" not in app_destination, "MapFocus province localization can fall back to the wrong province")
    expect("guard let province = ProvinceCatalog.provinceIfFound(matching: provinceId) else { return }" in map_view_model, "MapViewModel province focus does not fail closed for unknown province IDs")
    expect("ProvinceCatalog.item(id: provinceId)" not in map_view_model, "MapViewModel province focus can fall back to the wrong province")
    expect(".navigationTitle(place.localizedName(lang))" not in place_detail, "Place detail sheet duplicates its content title in the navigation chrome")
    expect("KNMGuideData.module(with: moduleID) == nil ? nil : .knmModule(moduleID)" in navigation_resolver, "AppNavigationResolver KNM module deep links do not validate module IDs")
    expect("DutchA1A2CourseData.module(with: moduleID) == nil ? nil : .dutchA1A2Module(moduleID)" in navigation_resolver, "AppNavigationResolver Dutch course module deep links do not validate module IDs")
    for required_uuid_route_guard in [
        "uuidDestination(parts, 1, in: MockChecklistData.items.map(\\.id), AppDestination.checklist)",
        "uuidDestination(parts, 1, in: MockDutchTermsData.items.map(\\.id), AppDestination.dutchTerm)",
        "uuidDestination(parts, 1, in: MockFineInfoData.items.map(\\.id), AppDestination.fineInfo)",
        "uuidDestination(parts, 1, in: MockSearchAnswersData.items.map(\\.id), AppDestination.searchAnswer)",
        "uuidDestination(parts, 1, in: MockNewcomerMistakesData.items.map(\\.id), AppDestination.mistake)",
        "uuidDestination(parts, 1, in: MockBeginnerGuidesData.items.map(\\.id), AppDestination.beginnerGuide)",
        "uuidDestination(parts, 1, in: MockRulesGuideData.topics.map(\\.id), AppDestination.ruleTopic)",
        "uuidDestination(parts, 1, in: MockRulesGuideData.scenarios.map(\\.id), AppDestination.ruleScenario)",
        "uuidDestination(parts, 1, in: MockResourcesData.items.map(\\.id), AppDestination.resource)",
        "uuidDestination(parts, 1, in: MockScamWarningsData.items.map(\\.id), AppDestination.scamWarning)",
    ]:
        expect(
            required_uuid_route_guard in navigation_resolver,
            f"AppNavigationResolver static UUID route missing content guard {required_uuid_route_guard}",
        )
    expect("static func provinceIfFound(matching identifier: String)" in province_directory_content, "ProvinceCatalog lacks normalized province matching for string routes")
    expect("normalizedLookupKey(spotlight.city.id) == normalized" in province_directory_content, "ProvinceCatalog city matching does not support normalized route IDs")

    menu_body = named_type_body(root_tab, "enum", "MenuDestination")
    menu_cases = enum_cases(root_tab, "MenuDestination")
    app_destination_body = menu_body.split("var appDestination: AppDestination?", 1)[1]
    menu_app_destination_cases: set[str] = set()
    for raw_line in app_destination_body.splitlines():
        line = raw_line.strip()
        if not line.startswith("case "):
            continue
        case_part = line.removeprefix("case ").split(":", 1)[0]
        for part in split_top_level_commas(case_part):
            match = re.search(r"\.([A-Za-z0-9_]+)", part)
            if match:
                menu_app_destination_cases.add(match.group(1))
    missing_menu_mappings = sorted(menu_cases - menu_app_destination_cases)
    expect(not missing_menu_mappings, f"MenuDestination.appDestination missing cases {missing_menu_mappings}")

    expect("guard isMenuItemVisibleForPersona(item) else { return }" in root_tab, "root menu selection is missing persona visibility guard")
    expect("RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)" in root_tab, "root menu visibility guard does not use persona route visibility")
    expect("homeNavPath = NavigationPath()" in root_tab and "homeNavPath.append(destination)" in root_tab, "menu navigation does not reset and append home path")
    more_category_link_body = named_function_body(more_hub, "categoryLink")
    expect("destination: AppDestination" in more_hub, "More persona category link helper does not accept AppDestination routes")
    expect("NavigationLink(value: destination)" in more_category_link_body, "More persona category links do not route through AppDestination values")
    expect("NavigationLink(destination: destination())" not in more_category_link_body, "More persona category links bypass shared AppDestination routing")
    expect("NavigationLink(destination: destination())" not in more_hub, "MoreHubView still contains direct destination helper navigation")
    expect("{ AppDestinationView(destination:" not in more_hub, "More persona category links embed destination views instead of pushing routes")
    for routed_more_view in [
        "ProfileSelectionView",
        "ResourcesView",
        "FinesAndLettersHubView",
        "LegalHelpView",
        "SettingsView",
        "AboutYouNewView",
        "BeginnerGuidesView",
        "DutchTermsView",
        "OfficialSourceDirectoryView",
        "MistakesLibraryView",
        "LGBTQSupportView",
        "EmotionalSupportView",
        "FinesInfoView",
        "LettersView",
        "EmergencyHubView",
        "DocumentOrganizerView",
        "DutchA1A2View",
        "TransportGuideView",
        "FirstStepsView",
    ]:
        expect(
            f"NavigationLink(destination: {routed_more_view}())" not in more_hub
            and not re.search(rf"\{{\s*{re.escape(routed_more_view)}\(\)\s*\}}", more_hub),
            f"MoreHubView opens route-backed {routed_more_view} directly instead of using AppDestination",
        )
    for required_more_route in [
        "destination: .resourcesHub",
        "destination: .finesAndLettersHub",
        "destination: .legalHelp",
    ]:
        expect(required_more_route in more_hub, f"MoreHubView missing route-backed link {required_more_route}")
    for routed_settings_view in [
        "ProfileSelectionView",
        "SavedTopicsView",
        "RecentlyViewedTopicsView",
        "NearbyMapView",
        "DocumentOrganizerView",
        "AboutYouNewView",
        "OfficialSourceDirectoryView",
        "PrivacyDataControlView",
        "TermsOfUseView",
        "LegalDisclaimerView",
        "SupportFeedbackView",
    ]:
        expect(
            f"NavigationLink(destination: {routed_settings_view}())" not in settings_view,
            f"SettingsView opens route-backed {routed_settings_view} directly instead of using AppDestination",
        )
    expect(
        "NavigationLink(destination:" not in settings_view,
        "SettingsView still contains direct destination navigation",
    )
    for required_settings_route in [
        "NavigationLink(value: AppDestination.profileSelection)",
        "NavigationLink(value: AppDestination.savedTopics)",
        "NavigationLink(value: AppDestination.recentlyViewedTopics)",
        "NavigationLink(value: AppDestination.mapHub)",
        "NavigationLink(value: AppDestination.journeyDocuments)",
        "NavigationLink(value: AppDestination.aboutYouNew)",
        "NavigationLink(value: AppDestination.officialSources)",
        "NavigationLink(value: AppDestination.privacyDataControl)",
        "NavigationLink(value: AppDestination.termsOfUse)",
        "NavigationLink(value: AppDestination.legalDisclaimer)",
        "NavigationLink(value: AppDestination.supportFeedback)",
    ]:
        expect(required_settings_route in settings_view, f"SettingsView missing route-backed link {required_settings_route}")
    expect("Text(id).appCardStyle()" not in settings_view, "Settings saved topics render raw IDs instead of route-backed rows")
    expect(
        "NavigationLink(value: destination)" in settings_view
        and "savedTopicRow(item)" in settings_view
        and "guard let destination = item.destination else { return false }" in settings_view
        and "AppNavigationResolver.destination(for: routeID, visibleFor:" in settings_view
        and "legacyDestination(for topic: String) -> AppDestination?" in settings_view,
        "Settings saved/recent topic rows do not restore valid AppDestination links",
    )
    for route_backed_save_view, expected_destination in [
        (checklist_detail, "destination: .checklist(item.id)"),
        (dutch_terms, "destination: .dutchTerm(term.id)"),
        (mistakes_library, "destination: .mistake(item.id)"),
        (letter_detail, "destination: .letter(letter.title)"),
    ]:
        expect(
            expected_destination in route_backed_save_view,
            f"route-backed saved item is missing persisted navigation metadata {expected_destination}",
        )
    for routed_document_view in ["LettersView", "OfficialSourceDirectoryView"]:
        expect(
            f"NavigationLink(destination: {routed_document_view}())" not in document_organizer,
            f"DocumentOrganizerView opens route-backed {routed_document_view} directly instead of using AppDestination",
        )
        expect(
            not re.search(rf"\.navigationDestination\(isPresented:\s*\$[^\)]*\)\s*\{{\s*{re.escape(routed_document_view)}\(\)\s*\}}", document_organizer),
            f"DocumentOrganizerView pushes route-backed {routed_document_view} through boolean navigation instead of AppDestination",
        )
    for stale_document_state in ["navigateToLetters", "navigateToOfficialSources"]:
        expect(
            stale_document_state not in document_organizer,
            f"DocumentOrganizerView keeps stale route-backed boolean navigation state {stale_document_state}",
        )
    for required_document_route in [
        "NavigationLink(value: AppDestination.lettersList)",
        "NavigationLink(value: AppDestination.officialSources)",
        "routeActionLink(icon: \"envelope\", title: lettersTitle, subtitle: lettersSubtitle, destination: .lettersList)",
        "routeActionLink(icon: \"building.columns\", title: officialTitle, subtitle: officialSubtitle, destination: .officialSources)",
    ]:
        expect(required_document_route in document_organizer, f"DocumentOrganizerView missing route-backed link {required_document_route}")
    expect(
        "NavigationLink(destination: NearbyMapView(initialCategory:" not in checklist_detail,
        "ChecklistItemDetailView opens category-focused map directly instead of using AppDestination.mapFocus",
    )
    expect(
        "NavigationLink(destination: NearbyMapView(initialCategory:" not in search_answer_detail,
        "SearchAnswerDetailView opens category-focused map directly instead of using AppDestination.mapFocus",
    )
    expect(
        "AppDestination.mapFocus(.category(mapCategory(for: item.category)))" in checklist_detail,
        "ChecklistItemDetailView missing category-focused map AppDestination route",
    )
    expect(
        "AppDestination.mapFocus(.category(placeCategory))" in search_answer_detail,
        "SearchAnswerDetailView missing category-focused map AppDestination route",
    )
    expect(
        "case category(PlaceCategory)" in app_destination
        and 'rawValue.hasPrefix("category:")' in app_destination
        and "case .category(let category):" in app_destination
        and "return place.category == category" in app_destination,
        "MapFocus category routes are not encoded and matched",
    )
    expect(
        "case .category(let category):" in map_view_model
        and "selectedCategory = category" in map_view_model,
        "MapViewModel does not apply category-focused map routes",
    )
    expect(
        "case .category(let category):" in read("YouNew/Models/RelatedContentEngine.swift")
        and "$0.category == category && $0.isVisible(for: persona)" in read("YouNew/Models/RelatedContentEngine.swift"),
        "RelatedContentEngine does not validate category-focused map route visibility",
    )
    expect(
        "case .knmModule(let moduleID):" in app_destination_view
        and "if KNMGuideData.module(with: moduleID) != nil" in app_destination_view,
        "AppDestinationView renders KNM module routes without validating the module exists",
    )
    expect(
        "case .dutchA1A2Module(let moduleID):" in app_destination_view
        and "if DutchA1A2CourseData.module(with: moduleID) != nil" in app_destination_view,
        "AppDestinationView renders Dutch A1-A2 module routes without validating the module exists",
    )
    related_content_engine = read("YouNew/Models/RelatedContentEngine.swift")
    expect(
        "case .knmModule(let moduleID):" in related_content_engine
        and "KNMGuideData.module(with: moduleID) != nil" in related_content_engine,
        "RelatedContentEngine treats KNM module routes as visible without module data validation",
    )
    expect(
        "case .dutchA1A2Module(let moduleID):" in related_content_engine
        and "DutchA1A2CourseData.module(with: moduleID) != nil" in related_content_engine,
        "RelatedContentEngine treats Dutch A1-A2 module routes as visible without module data validation",
    )

    persisted_destination_body = named_function_body(saved_items_store, "persistedDestination")
    restored_destination_body = named_function_body(saved_items_store, "destination")
    dropped_persisted_destinations = sorted(
        set(re.findall(r"case\s+\.([A-Za-z0-9_]+)(?:\b|\([^:]*\))\s*:\s*return\s+nil", persisted_destination_body))
    )
    expect(
        not dropped_persisted_destinations,
        f"SavedItemsStore drops persisted destinations for {dropped_persisted_destinations}",
    )
    for required_saved_restore_guard in [
        "restoredUUIDDestination(id, in: MockChecklistData.items.map(\\.id), AppDestination.checklist)",
        "restoredUUIDDestination(id, in: MockDutchTermsData.items.map(\\.id), AppDestination.dutchTerm)",
        "restoredUUIDDestination(id, in: MockFineInfoData.items.map(\\.id), AppDestination.fineInfo)",
        "MockInstitutionsData.items.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) ? .institution(name) : nil",
        "restoredUUIDDestination(id, in: MockSearchAnswersData.items.map(\\.id), AppDestination.searchAnswer)",
        "MockLettersData.examples.contains(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame }) ? .letter(title) : nil",
        "restoredUUIDDestination(id, in: MockNewcomerMistakesData.items.map(\\.id), AppDestination.mistake)",
        "restoredUUIDDestination(id, in: MockBeginnerGuidesData.items.map(\\.id), AppDestination.beginnerGuide)",
        "restoredUUIDDestination(id, in: MockRulesGuideData.topics.map(\\.id), AppDestination.ruleTopic)",
        "restoredUUIDDestination(id, in: MockRulesGuideData.scenarios.map(\\.id), AppDestination.ruleScenario)",
        "restoredUUIDDestination(id, in: MockResourcesData.items.map(\\.id), AppDestination.resource)",
        "ProvinceCatalog.provinceIfFound(matching: provinceName) == nil ? nil : .provinceDetail(provinceName)",
        "ProvinceCatalog.provinceIfFound(matching: provinceName) == nil ? nil : .provinceCities(provinceName)",
        "ProvinceCatalog.cityIfFound(named: city, provinceID: provinceItem.id) != nil",
        "KNMGuideData.module(with: id) == nil ? nil : .knmModule(id)",
        "DutchA1A2CourseData.module(with: id) == nil ? nil : .dutchA1A2Module(id)",
        "ProvinceCatalog.citySpotlight(matching: cityID) == nil && NLCity.all.first(where: { $0.id == cityID || $0.name.caseInsensitiveCompare(cityID) == .orderedSame }) == nil ? nil : .nlCityDetail(cityID)",
        "restoredUUIDDestination(id, in: MockScamWarningsData.items.map(\\.id), AppDestination.scamWarning)",
        "GuideContent.section(id: id) == nil ? nil : .guideSection(id)",
        "GuideContent.article(sectionID: sectionID, articleID: articleID) == nil ? nil : .guideArticle(sectionID: sectionID, articleID: articleID)",
    ]:
        expect(
            required_saved_restore_guard in restored_destination_body,
            f"SavedItemsStore restored destination missing content guard {required_saved_restore_guard}",
        )

    route_ids_body = named_function_body(app_destination, "allKnownAIRouteIDs")
    route_ids = re.findall(r"\"([A-Za-z0-9]+)\"", route_ids_body)
    expect(route_ids, "allKnownAIRouteIDs is empty")
    for route_id in route_ids:
        normalized = route_id.replace("-", "").replace("_", "").replace(" ", "").lower()
        expect(normalized in app_destination.replace("-", "").replace("_", "").replace(" ", "").lower(), f"AI route id {route_id} has no alias coverage")

    practical_guide_topics = enum_cases(app_destination, "PracticalGuideTopic")
    ai_route_body = named_function_body(app_destination, "aiRoute")
    known_route_ids = set(route_ids)
    missing_practical_aliases = sorted(practical_guide_topics - known_route_ids)
    expect(not missing_practical_aliases, f"PracticalGuideTopic raw IDs missing from allKnownAIRouteIDs {missing_practical_aliases}")
    for topic in practical_guide_topics:
        normalized = topic.replace("-", "").replace("_", "").replace(" ", "").lower()
        expect(normalized in ai_route_body.replace("-", "").replace("_", "").replace(" ", "").lower(), f"PracticalGuideTopic raw ID {topic} has no AI route alias")

    print("Route/action static QA passed")
    print(f"- AppDestination cases rendered: {len(destination_cases)}")
    print(f"- Hardcoded AppDestination references checked: {len(referenced_destination_cases)}")
    print(f"- Hardcoded guide section ids checked: {len(hardcoded_guide_ids)}")
    print(f"- Hardcoded KNM module ids checked: {len(hardcoded_knm_module_ids)}")
    print(f"- Hardcoded Dutch A1-A2 module ids checked: {len(hardcoded_dutch_course_module_ids)}")
    print(f"- Hardcoded province ids checked: {len(hardcoded_province_ids)}")
    print(f"- Hardcoded city detail routes checked: {len(hardcoded_city_pairs)}")
    print(f"- Hardcoded map city ids checked: {len(hardcoded_map_city_ids)}")
    print(f"- Practical guide AI route aliases checked: {len(practical_guide_topics)}")
    print(f"- Menu destinations mapped: {len(menu_cases)}")


def named_function_body(text: str, name: str) -> str:
    match = re.search(rf"\bfunc\s+{re.escape(name)}\b[^\{{]*\{{|\bstatic\s+func\s+{re.escape(name)}\b[^\{{]*\{{", text)
    expect(match is not None, f"missing function {name}")
    open_index = match.end() - 1
    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[open_index + 1:index]
    fail(f"unterminated function {name}")
    return ""


if __name__ == "__main__":
    main()
