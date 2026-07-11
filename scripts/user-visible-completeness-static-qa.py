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
    navigation_components = read("YouNew/Core/DesignSystem/Components/NavigationUIComponents.swift")
    translator_view_model = read("YouNew/ViewModels/TranslatorViewModel.swift")
    translator_view = read("YouNew/Views/TranslatorView.swift")
    culture_data = read("YouNew/Data/MockNetherlandsUnderstandingData.swift")
    culture_view = read("YouNew/Views/CultureAttractionsView.swift")
    transport_data = read("YouNew/Data/TransportGuideData.swift")
    transport_view = read("YouNew/Views/TransportGuideView.swift")
    knm_data = read("YouNew/Data/KNMGuideData.swift")
    knm_view = read("YouNew/Views/KNMGuideView.swift")
    dutch_data = read("YouNew/Data/DutchA1A2CourseData.swift")
    dutch_a1a2_view = read("YouNew/Views/DutchA1A2View.swift")
    official_sources = read("YouNew/Views/OfficialSourceDirectoryView.swift")
    resources_view = read("YouNew/Views/ResourcesView.swift")
    more_hub = read("YouNew/Views/MoreHubView.swift")
    cities_view = read("YouNew/Views/CitiesDirectoryView.swift")
    checklist_view = read("YouNew/Views/ChecklistView.swift")
    status_direction_view = read("YouNew/Views/StatusDirectionView.swift")
    fines_view = read("YouNew/Views/FinesInfoView.swift")
    document_organizer = read("YouNew/Views/DocumentOrganizerView.swift")
    legal_info = read("YouNew/Views/LegalInfoView.swift")
    dutch_terms = read("YouNew/Views/DutchTermsView.swift")
    netherlands_history = read("YouNew/Views/NetherlandsHistoryView.swift")
    lgbtq_support = read("YouNew/Views/LGBTQSupportView.swift")
    nearby_map = read("YouNew/Views/NearbyMapView.swift")
    letters = read("YouNew/Views/LettersView.swift")
    mistakes = read("YouNew/Views/MistakesLibraryView.swift")
    place_detail = read("YouNew/Views/PlaceDetailView.swift")
    province_view = read("YouNew/Views/ProvinceDirectoryView.swift")
    netherlands_overview = read("YouNew/Views/NetherlandsOverviewView.swift")
    first_steps = read("YouNew/Views/FirstStepsView.swift")
    beginner_guide_detail = read("YouNew/Views/BeginnerGuideDetailView.swift")
    info_hub = read("YouNew/Views/InformationHubView.swift")
    guide_content = read("YouNew/Views/GuideContentView.swift")
    emergency_hub = read("YouNew/Views/EmergencyHubView.swift")
    favorites_view = read("YouNew/Views/FavoritesView.swift")
    saved_item_detail = read("YouNew/Views/SavedItemDetailViews.swift")
    search_answer_detail = read("YouNew/Views/SearchAnswerDetailView.swift")
    settings_view = read("YouNew/Views/SettingsView.swift")
    home_view = read("YouNew/Views/HomeView.swift")
    places_discovery_view = read("YouNew/Views/PlacesDiscoveryView.swift")
    app_content = read("YouNew/Core/DesignSystem/Tokens/AppContent.swift")
    app_content_image_view = read("YouNew/Core/Imaging/AppContentImageView.swift")
    en_strings = read("YouNew/en.lproj/Localizable.strings")
    nl_strings = read("YouNew/nl.lproj/Localizable.strings")
    ru_strings = read("YouNew/ru.lproj/Localizable.strings")
    search_answer_model = read("YouNew/Models/SearchAnswer.swift")
    letter_model = read("YouNew/Models/LetterExample.swift")
    risk_model = read("YouNew/Models/RiskItem.swift")
    checklist_model = read("YouNew/Models/ChecklistItem.swift")
    fine_model = read("YouNew/Models/FineInfoItem.swift")
    mistake_model = read("YouNew/Models/NewcomerMistake.swift")
    nearby_place_model = read("YouNew/Models/NearbyPlace.swift")
    newcomer_place_model = read("YouNew/Models/NewcomerPlace.swift")
    map_view_model = read("YouNew/ViewModels/MapViewModel.swift")
    local_partners_view = read("YouNew/Views/LocalPartnersView.swift")
    verified_place_media_registry = read("YouNew/Data/VerifiedPlaceMediaRegistry.swift")
    user_profile_model = read("YouNew/Models/UserProfile.swift")
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
    for forbidden_place_placeholder in [
        "Opening hours unavailable",
        "No opening hours in app",
        "Approx. %.1f km",
    ]:
        if forbidden_place_placeholder in nearby_place_model + newcomer_place_model + map_view_model:
            fail(f"Places visible placeholder copy remains: {forbidden_place_placeholder}")
    if "In selected city" not in map_view_model:
        fail("Places distance copy must avoid displaying misleading 0.0 km for city-center matches")
    for fake_partner_signal in [
        "ratingDigit",
        "reviewCount",
        'Label("4.\\(',
        "distanceText",
    ]:
        if fake_partner_signal in local_partners_view:
            fail(f"Local Partners must not display fabricated ratings, review counts, or distances: {fake_partner_signal}")
    for unfinished_partner_dashboard_copy in [
        "future update",
        'badge: "Future"',
    ]:
        if unfinished_partner_dashboard_copy in local_partners_view:
            fail(f"Local Partners dashboard must hide unfinished features: {unfinished_partner_dashboard_copy}")
    if "private var fallbackCaptionText" not in app_content_image_view:
        fail("App content image fallback must explain the verified visual context instead of showing a dead unavailable state")
    premium_image_match = re.search(r"struct PremiumImageView: View.*?struct AppContentImageView: View", app_content_image_view, re.S)
    if not premium_image_match:
        fail("PremiumImageView implementation missing")
    premium_image_source = premium_image_match.group(0)
    if "GeometryReader { proxy in" not in premium_image_source:
        fail("PremiumImageView must bound rendered images to the actual card size")
    if ".frame(width: proxy.size.width, height: proxy.size.height)" not in premium_image_source:
        fail("PremiumImageView must frame image content with finite proxy dimensions")
    for forbidden_image_fallback in [
        '"image.unavailable" = "Image unavailable"',
        '"image.unavailable" = "Afbeelding niet beschikbaar"',
        '"image.unavailable" = "Изображение недоступно"',
        '"city.no_image_available" = "No image available"',
        '"city.no_image_available" = "Geen beeld beschikbaar"',
        '"city.no_image_available" = "Изображение недоступно"',
        '"city.asset_missing" = "Verified image unavailable"',
        '"city.asset_missing" = "Geverifieerde afbeelding niet beschikbaar"',
        '"city.asset_missing" = "Проверенное изображение недоступно"',
        '"city.flag_pending" = "Official flag unavailable"',
        '"city.flag_pending" = "Officiele vlag niet beschikbaar"',
        '"city.flag_pending" = "Официальный флаг недоступен"',
        '"city.coat_pending" = "Official coat of arms unavailable"',
        '"city.coat_pending" = "Officieel wapen niet beschikbaar"',
        '"city.coat_pending" = "Официальный герб недоступен"',
        '"city.hero_pending" = "City hero unavailable"',
        '"city.hero_pending" = "Stadsbeeld niet beschikbaar"',
        '"city.hero_pending" = "Изображение города недоступно"',
    ]:
        if forbidden_image_fallback in en_strings + nl_strings + ru_strings:
            fail(f"Image fallback still exposes unavailable copy: {forbidden_image_fallback}")
    for forbidden_media_credit_placeholder in [
        "will appear when official assets are available",
        "verschijnt zodra officiele assets beschikbaar zijn",
        "появится, когда официальные материалы будут доступны",
    ]:
        if forbidden_media_credit_placeholder in verified_place_media_registry:
            fail(f"Verified media credit fallback still reads like unfinished content: {forbidden_media_credit_placeholder}")

    if "private var displayedProfileName" not in settings_view or "appState.selectedUserStatus?.localized(lang)" not in settings_view:
        fail("Settings profile header must bind its displayed name to selected UserStatus before ProfileType fallback")
    if 'nationalityPlaceholder: "Not set"' in user_profile_model:
        fail("Default profile must not prefill user-facing fields with technical 'Not set' copy")
    for forbidden_unfinished_microcopy in [
        "Date not set",
        "Datum niet ingesteld",
        "Дата не указана",
        '?? "not set"',
        "We do not show an empty directory",
        "We tonen geen lege gids",
        "Мы не показываем пустой каталог",
        '"empty.no_results": "No results found."',
        '"empty.no_results": "Geen resultaten gevonden."',
        '"empty.no_results": "Ничего не найдено."',
        '"empty.no_nearby_places": "No support points found nearby."',
        '"empty.no_nearby_places": "Geen steunpunten in de buurt gevonden."',
        '"empty.no_nearby_places": "Поблизости не найдено точек поддержки."',
        '"search.no_results": "No results found"',
        '"search.no_results": "Geen resultaten gevonden"',
        '"fines.no_items": "No items found."',
        '"fines.no_items": "Geen items gevonden."',
        '"fines.no_items": "Ничего не найдено."',
        '"fines.no_items" = "No items in this category."',
        '"fines.no_items" = "Geen items in deze categorie."',
        '"fines.no_items" = "В этой категории пока нет элементов."',
        '"legal.no_results": "No legal info found."',
        '"legal.no_results": "Geen juridische informatie gevonden."',
        '"legal.no_results": "Юридическая информация не найдена."',
        '"legal.no_results" = "No results found.',
        '"legal.no_results" = "Geen resultaten.',
        '"legal.no_results" = "Ничего не найдено.',
        "This section is expanding",
        "Dit onderdeel wordt uitgebreid",
        "Этот раздел расширяется",
        "No recent translations yet",
        "Nog geen recente vertalingen",
        "Недавних переводов пока нет",
        "No matching terms found",
        "Geen overeenkomende termen gevonden",
        "Совпадающих терминов не найдено",
        "No terms found. Try a different search.",
        "Geen termen gevonden. Probeer een andere zoekopdracht.",
        "Термины не найдены. Попробуйте другой запрос.",
        "No matching resources",
        "Geen passende bronnen",
        "Подходящих ресурсов нет",
        "No matching mistakes in this filter",
        "Geen passende fouten in dit filter",
        "В этом фильтре нет подходящих ошибок",
        '"resources.no_resources" = "No resources available"',
        '"resources.no_resources" = "Geen bronnen beschikbaar"',
        '"resources.no_resources" = "Ресурсы пока недоступны"',
        '"map.no_places_title": "No places nearby"',
        '"map.no_places_title": "Geen locaties in de buurt"',
        '"map.no_places_title": "Нет мест поблизости"',
        '"map.no_places_subtitle": "No places found in this area."',
        '"map.no_places_subtitle": "Geen locaties gevonden in dit gebied."',
        '"map.no_places_subtitle": "В этой зоне мест не найдено."',
        '"search.empty_state": "Search for anything about life in the Netherlands"',
        '"search.empty_state": "Zoek naar alles over het leven in Nederland"',
        '"search.empty_state": "Ищите что угодно о жизни в Нидерландах"',
        '"official_sources.no_match": "No official sources found."',
        '"official_sources.no_match": "Geen officiële bronnen gevonden."',
        '"official_sources.no_match": "Официальные источники не найдены."',
        '"official_sources.no_match" = "No institutions match your search."',
        '"official_sources.no_match" = "Geen instanties gevonden voor je zoekopdracht."',
        '"official_sources.no_match" = "Организации по вашему запросу не найдены."',
        "The feedback feature will be available in the next update",
        "De feedbackfunctie verschijnt in de volgende update",
        "Функция обратной связи появится в следующем обновлении",
        "Document metadata can be exported from Privacy and data.",
        "Documentmetadata kan worden geëxporteerd via Privacy en gegevensbeheer.",
        "Метаданные документов можно экспортировать в разделе приватности и данных.",
        "Planned premium features",
        "Geplande premiumfuncties",
        "Будущие премиум-возможности",
        "No SDK integrated",
        "Geen SDK geïntegreerd",
        "SDK не подключён",
        "Prepared events: onboarding completion, resource views, searches, reminder usage.",
        "Voorbereide events: onboarding voltooid, resource-weergaven, zoekopdrachten, reminder-gebruik.",
        "Подготовленные события: завершение онбординга, просмотры ресурсов, поиски, напоминания.",
    ]:
        if forbidden_unfinished_microcopy in swift_sources + l10n + en_strings + nl_strings + ru_strings:
            fail(f"unfinished empty/default microcopy is visible: {forbidden_unfinished_microcopy}")
    for required_ai_disclaimer in [
        "does not replace legal, medical or financial professionals",
        "vervangt geen juridische, medische of financiële professional",
        "не заменяет юридических, медицинских или финансовых специалистов",
    ]:
        if required_ai_disclaimer not in l10n + en_strings + nl_strings + ru_strings:
            fail(f"AI disclaimer missing professional-boundary copy: {required_ai_disclaimer}")
    translator_recent_match = re.search(r'if !viewModel\.recent\.isEmpty \{.*?SectionHeader\(title: L10n\.t\("translator\.recent"', translator_view, re.S)
    if not translator_recent_match:
        fail("Translator must hide the Recent section until there are real recent translations")
    leisure_items_match = re.search(r"private var leisureItems: \[HomeExploreItem\] \{.*?private var educationItems", home_view, re.S)
    if not leisure_items_match:
        fail("Home leisure section missing from completeness QA")
    if 'id: "culture"' in leisure_items_match.group(0) or 'title: localizedText(en: "Culture"' in leisure_items_match.group(0):
        fail("Home must not duplicate Culture in Leisure and Discover Netherlands")
    home_body_match = re.search(r"var body: some View \{.*?private var productHomeHero", home_view, re.S)
    if not home_body_match:
        fail("Home body missing from completeness QA")
    home_body = home_body_match.group(0)
    for forbidden_home_dashboard_section in [
        "lifeTimelinePreviewSection",
        "smartChecklistPreviewSection",
        "documentsDeadlinesPreviewSection",
        "personalDashboardSection",
        "homeActionCommandCenter",
    ]:
        if forbidden_home_dashboard_section in home_body:
            fail(f"Home body must remain country-first and not show dashboard section: {forbidden_home_dashboard_section}")
    for forbidden_home_cta_copy in [
        "Set profile and checklist.",
        "Profiel en checklist.",
        "Профиль и чеклист.",
        "Timeline, checklists, documents, deadlines, and AI",
        "Timeline, checklist, documenten, deadlines en AI",
        "Timeline, checklist, документы, дедлайны и AI",
        "Below: next step, Timeline",
        "Hieronder: volgende stap, Timeline",
        "Ниже: следующий шаг, Timeline",
    ]:
        if forbidden_home_cta_copy in home_view:
            fail(f"Home must not surface workspace/dashboard copy on the country-first entry screen: {forbidden_home_cta_copy}")
    if "private var visibleSourceCount" not in official_sources:
        fail("Official Sources must use one visible-source count for hero and section subtitles")
    if official_sources.count('String(format: L10n.t("official_sources.subtitle", lang), visibleSourceCount)') != 2:
        fail("Official Sources hero and section subtitle counts are not using the same visibleSourceCount source")
    more_body_match = re.search(r"var body: some View \{.*?// MARK: - Quick Actions Strip", more_hub, re.S)
    if not more_body_match:
        fail("More body missing from completeness QA")
    more_body = more_body_match.group(0)
    for forbidden_more_dashboard_section in [
        "personalGuideDashboardSection",
        "moreHeroSection",
    ]:
        if forbidden_more_dashboard_section in more_body:
            fail(f"More must remain a calm directory, not a dashboard/hero stack: {forbidden_more_dashboard_section}")
    quick_actions_match = re.search(r"private var quickActionsSection: some View \{.*?private var profileSection", more_hub, re.S)
    if not quick_actions_match:
        fail("More quick actions section missing from completeness QA")
    quick_actions_source = quick_actions_match.group(0)
    if "more.quick.find_site" in quick_actions_source or "find_site" in quick_actions_source:
        fail("More quick actions must not duplicate Official Sources with a separate find-site CTA")
    if quick_actions_source.count("QuickActionChipLabel(") > 2:
        fail("More quick actions must stay focused at two actions or fewer")
    home_visual_card_match = re.search(r"private func homeExploreVisualCard.*?private var compactAISection", home_view, re.S)
    if not home_visual_card_match:
        fail("Home explore visual card missing from completeness QA")
    home_visual_card_source = home_visual_card_match.group(0)
    for required_home_visual_path in [
        "PremiumImageView(",
        "asset: homeExploreImage(for: item)",
        "fallbackCategory: homeExploreFallbackCategory(for: item)",
        ".frame(height: 86)",
        ".clipped()",
    ]:
        if required_home_visual_path not in home_visual_card_source:
            fail(f"Home explore cards must keep a bounded visual image surface: {required_home_visual_path}")
    home_image_map_match = re.search(r"private func homeExploreImage.*?private func homeExploreFallbackCategory", home_view, re.S)
    if not home_image_map_match:
        fail("Home explore image map missing from completeness QA")
    home_image_map_source = home_image_map_match.group(0)
    for required_home_image_case in [
        '"transport"',
        '"healthcare"',
        '"government"',
        '"housing"',
        '"restaurants"',
        '"nature"',
        '"events"',
        '"universities"',
    ]:
        if required_home_image_case not in home_image_map_source:
            fail(f"Home explore image map missing thematic category: {required_home_image_case}")
    home_body_match = re.search(r"var body: some View \{.*?private var productHomeHero", home_view, re.S)
    if not home_body_match or ".safeAreaInset(edge: .top" not in home_body_match.group(0):
        fail("Home must reserve top safe-area space so content never starts under the status bar or Dynamic Island")
    places_support_card_match = re.search(r"private func supportCard\(\s*title: String.*?private func supportCardImage", places_discovery_view, re.S)
    if not places_support_card_match:
        fail("Places support card missing from completeness QA")
    places_support_card = places_support_card_match.group(0)
    for required_places_card_guard in [
        ".frame(maxWidth: .infinity, minHeight: usesAccessibilityLayout ? 284 : 232, alignment: .topLeading)",
        ".clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))",
        ".clipped()",
        ".lineLimit(2)",
    ]:
        if required_places_card_guard not in places_support_card:
            fail(f"Places support cards must remain stable and non-overlapping: {required_places_card_guard}")
    if "maxHeight:" in places_support_card:
        fail("Places support cards must not use a fixed maxHeight that clips or overlays long content")
    places_body_match = re.search(r"var body: some View \{.*?private func configure", places_discovery_view, re.S)
    if not places_body_match or ".safeAreaInset(edge: .top" not in places_body_match.group(0):
        fail("Places must reserve top safe-area space above the search/filter stack")
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
    more_dashboard_info = re.search(r"private func dashboardInfoTile.*?private func dashboardDestinationCard", more_hub, re.S)
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
    if "private var noResultsRecoverySection" not in search or "SearchRecoveryActionCard" not in search:
        fail("Search no-results state must offer route-backed recovery actions")
    for action_id, destination in [
        ("resources", ".resourcesHub"),
        ("official", ".officialSources"),
        ("nearby", ".mapHub"),
        ("documents", ".journeyDocuments"),
    ]:
        if not re.search(rf'SearchRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', search, re.S):
            fail(f"Search no-results recovery action missing: {action_id} -> {destination}")
    if '"search.no_results.action.\\(action.id)"' not in search:
        fail("Search no-results recovery actions need stable accessibility identifiers")
    for required_beginner_search_fallback in [
        '"search.beginner.related.empty"',
        "private var beginnerRelatedFallbackTitle",
        "NavigationLink(value: AppDestination.searchList)",
    ]:
        if required_beginner_search_fallback not in search:
            fail(f"Search beginner guide result fallback missing: {required_beginner_search_fallback}")
    if "private var emptyDocumentsDashboard" not in document_organizer or "DocumentStarterCategoryCard" not in document_organizer:
        fail("Documents empty state must offer a starter dashboard instead of plain empty text")
    for required_document_empty_action in [
        '"documents.empty.dashboard"',
        '"documents.empty.scan"',
        '"documents.empty.import"',
        "NavigationLink(value: AppDestination.lettersList)",
        '"documents.empty.letters"',
        "NavigationLink(value: AppDestination.officialSources)",
        '"documents.empty.sources"',
        "documentStore.suggestedCategories(for: appState.selectedUserStatus).prefix(4)",
    ]:
        if required_document_empty_action not in document_organizer:
            fail(f"Documents empty dashboard missing: {required_document_empty_action}")
    if "private var noResultsDashboard" not in legal_info or "LegalRecoveryActionCard" not in legal_info:
        fail("Legal Info no-results state must offer route-backed recovery actions")
    for action_id, destination in [
        ("search", ".searchList"),
        ("sources", ".officialSources"),
        ("legal-help", ".legalHelp"),
    ]:
        if not re.search(rf'LegalRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', legal_info, re.S):
            fail(f"Legal Info no-results recovery action missing: {action_id} -> {destination}")
    for required_legal_empty_action in [
        '"legal.empty.dashboard"',
        '"legal.empty.reset"',
        '"legal.empty.action.\\(action.id)"',
        "searchText = \"\"",
        "selectedCategory = nil",
    ]:
        if required_legal_empty_action not in legal_info:
            fail(f"Legal Info no-results dashboard missing: {required_legal_empty_action}")
    legal_recovery_match = re.search(r"private var legalRecoveryActions.*?private func localized", legal_info, re.S)
    if legal_recovery_match and re.search(r"\.filter\s*\{\s*RelatedContentEngine\.isVisible\(\$0\.destination", legal_recovery_match.group(0), re.S):
        fail("Legal Info recovery actions must remain visible when results are unavailable")
    if "private var noTermsDashboard" not in dutch_terms or "DutchTermRecoveryActionCard" not in dutch_terms:
        fail("Dutch Terms no-results state must offer route-backed recovery actions")
    for action_id, destination in [
        ("course", ".dutchA1A2"),
        ("search", ".searchList"),
        ("sources", ".officialSources"),
    ]:
        if not re.search(rf'DutchTermRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', dutch_terms, re.S):
            fail(f"Dutch Terms no-results recovery action missing: {action_id} -> {destination}")
    for required_terms_empty_action in [
        '"dutchTerms.empty.dashboard"',
        '"dutchTerms.empty.reset"',
        '"dutchTerms.empty.action.\\(action.id)"',
        "searchText = \"\"",
        "selectedCategory = nil",
    ]:
        if required_terms_empty_action not in dutch_terms:
            fail(f"Dutch Terms no-results dashboard missing: {required_terms_empty_action}")
    term_recovery_match = re.search(r"private var termRecoveryActions.*?private func localized", dutch_terms, re.S)
    if term_recovery_match and re.search(r"\.filter\s*\{\s*RelatedContentEngine\.isVisible\(\$0\.destination", term_recovery_match.group(0), re.S):
        fail("Dutch Terms recovery actions must remain visible when results are unavailable")
    if "private var noSourcesDashboard" not in official_sources or "OfficialSourceRecoveryActionCard" not in official_sources:
        fail("Official Sources no-results state must offer route-backed recovery actions")
    for action_id, destination in [
        ("search", ".searchList"),
        ("map", ".mapHub"),
        ("documents", ".journeyDocuments"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'OfficialSourceRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', official_sources, re.S):
            fail(f"Official Sources no-results recovery action missing: {action_id} -> {destination}")
    for required_sources_empty_action in [
        '"officialSources.empty.dashboard"',
        '"officialSources.empty.reset"',
        '"officialSources.empty.action.\\(action.id)"',
        "searchText = \"\"",
    ]:
        if required_sources_empty_action not in official_sources:
            fail(f"Official Sources no-results dashboard missing: {required_sources_empty_action}")
    if "private var noPlacesDashboard" not in nearby_map or "MapRecoveryActionCard" not in nearby_map:
        fail("Nearby Map empty place state must offer route-backed recovery actions")
    for action_id, destination in [
        ("search", ".searchList"),
        ("sources", ".officialSources"),
        ("documents", ".journeyDocuments"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'MapRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', nearby_map, re.S):
            fail(f"Nearby Map empty recovery action missing: {action_id} -> {destination}")
    for required_map_empty_action in [
        '"map.empty.dashboard"',
        '"map.empty.reset"',
        '"map.empty.action.\\(action.id)"',
        "viewModel.searchText = \"\"",
        "viewModel.clearFilters()",
        "viewModel.applyCityCenter()",
    ]:
        if required_map_empty_action not in nearby_map:
            fail(f"Nearby Map empty dashboard missing: {required_map_empty_action}")
    for required_route_fallback in [
        "private var routeHintFallback",
        '"map.routeFallback.dashboard"',
        "destination: .searchList",
        "destination: .officialSources",
        "destination: .journeyDocuments",
    ]:
        if required_route_fallback not in nearby_map:
            fail(f"Nearby Map route fallback missing: {required_route_fallback}")
    if "return AnyView(EmptyView())" in nearby_map:
        fail("Nearby Map route guide must show fallback actions instead of EmptyView")
    if "private var emptyLettersDashboard" not in letters or "LetterRecoveryActionCard" not in letters:
        fail("Letters empty state must offer route-backed recovery actions")
    for action_id, destination in [
        ("documents", ".journeyDocuments"),
        ("sources", ".officialSources"),
        ("search", ".searchList"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'LetterRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', letters, re.S):
            fail(f"Letters empty recovery action missing: {action_id} -> {destination}")
    for required_letters_empty_action in [
        '"letters.empty.dashboard"',
        '"letters.empty.action.\\(action.id)"',
    ]:
        if required_letters_empty_action not in letters:
            fail(f"Letters empty dashboard missing: {required_letters_empty_action}")
    letter_recovery_match = re.search(r"private var emptyLetterActions.*?private func localized", letters, re.S)
    if letter_recovery_match and re.search(r"\.filter\s*\{\s*RelatedContentEngine\.isVisible\(\$0\.destination", letter_recovery_match.group(0), re.S):
        fail("Letters empty recovery actions must remain visible when examples are unavailable")
    if "private var emptyMistakesDashboard" not in mistakes or "MistakeRecoveryActionCard" not in mistakes:
        fail("Mistakes empty state must offer route-backed recovery actions")
    if 'title: L10n.t("fines.no_items", lang)' in mistakes:
        fail("Mistakes empty state must use mistakes-specific copy, not fines.no_items")
    for action_id, destination in [
        ("scams", ".scamWarningsList"),
        ("sources", ".officialSources"),
        ("search", ".searchList"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'MistakeRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', mistakes, re.S):
            fail(f"Mistakes empty recovery action missing: {action_id} -> {destination}")
    for required_mistakes_empty_action in [
        '"mistakes.empty.dashboard"',
        '"mistakes.empty.reset"',
        '"mistakes.empty.action.\\(action.id)"',
        "selectedCategory = nil",
    ]:
        if required_mistakes_empty_action not in mistakes:
            fail(f"Mistakes empty dashboard missing: {required_mistakes_empty_action}")
    mistake_recovery_match = re.search(r"private var emptyMistakeActions.*?private func localized", mistakes, re.S)
    if mistake_recovery_match and re.search(r"\.filter\s*\{\s*RelatedContentEngine\.isVisible\(\$0\.destination", mistake_recovery_match.group(0), re.S):
        fail("Mistakes recovery actions must remain visible when results are unavailable")
    if "private var historyEmptyDashboard" not in netherlands_history or "HistoryRecoveryActionCard" not in netherlands_history:
        fail("Netherlands History empty state must offer route-backed recovery actions")
    for action_id, destination in [
        ("knm", ".knm"),
        ("culture", ".cultureAttractions"),
        ("terms", ".dutchTermsList"),
        ("sources", ".officialSources"),
    ]:
        if not re.search(rf'HistoryRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', netherlands_history, re.S):
            fail(f"Netherlands History empty recovery action missing: {action_id} -> {destination}")
    for required_history_empty_action in [
        '"history.empty.dashboard"',
        '"history.empty.retry"',
        '"history.empty.action.\\(action.id)"',
        "Task { await viewModel.retry() }",
    ]:
        if required_history_empty_action not in netherlands_history:
            fail(f"Netherlands History empty dashboard missing: {required_history_empty_action}")
    for forbidden_history_empty_copy in [
        "History content is unavailable",
        "Geschiedenis is niet beschikbaar",
        "История пока недоступна",
    ]:
        if forbidden_history_empty_copy in netherlands_history:
            fail(f"Netherlands History empty state still exposes unavailable copy: {forbidden_history_empty_copy}")
    if "private func supportEmptyDashboard" not in lgbtq_support or "LGBTQRecoveryActionCard" not in lgbtq_support:
        fail("LGBTQ Support empty state must offer route-backed recovery actions")
    for action_id, destination in [
        ("map", ".mapFocus(.category(.lgbtqSupport))"),
        ("legal", ".legalHelp"),
        ("sources", ".officialSources"),
        ("search", ".searchList"),
    ]:
        if not re.search(rf'LGBTQRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', lgbtq_support, re.S):
            fail(f"LGBTQ Support empty recovery action missing: {action_id} -> {destination}")
    for required_lgbtq_empty_action in [
        '"lgbtq.empty.dashboard"',
        '"lgbtq.empty.retry"',
        '"lgbtq.empty.reset"',
        '"lgbtq.empty.action.\\(action.id)"',
        "Task { await viewModel.load() }",
        "viewModel.resetFilters()",
    ]:
        if required_lgbtq_empty_action not in lgbtq_support:
            fail(f"LGBTQ Support empty dashboard missing: {required_lgbtq_empty_action}")
    for forbidden_lgbtq_empty_copy in [
        '"lgbtq.empty.title" = "No resources available"',
        '"lgbtq.empty.title" = "Geen bronnen beschikbaar"',
        '"lgbtq.empty.title" = "Ресурсы недоступны"',
        '"lgbtq.empty.subtitle" = "The local support directory is unavailable right now."',
        '"lgbtq.empty.subtitle" = "De lokale ondersteuningsgids is nu niet beschikbaar."',
        '"lgbtq.empty.subtitle" = "Локальный каталог поддержки сейчас недоступен."',
    ]:
        if forbidden_lgbtq_empty_copy in en_strings + nl_strings + ru_strings:
            fail(f"LGBTQ empty state still exposes unavailable copy: {forbidden_lgbtq_empty_copy}")
    if "private var emptyResourcesDashboard" not in resources_view or "ResourceRecoveryActionCard" not in resources_view:
        fail("Resources empty state must offer route-backed recovery actions")
    for action_id, destination in [
        ("official", ".officialSources"),
        ("search", ".searchList"),
        ("documents", ".journeyDocuments"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'ResourceRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', resources_view, re.S):
            fail(f"Resources empty recovery action missing: {action_id} -> {destination}")
    for required_resources_empty_action in [
        '"resources.empty.dashboard"',
        '"resources.empty.action.\\(action.id)"',
        "hasVisibleResources",
        "groupedResources.values.contains { !$0.isEmpty }",
    ]:
        if required_resources_empty_action not in resources_view:
            fail(f"Resources empty dashboard missing: {required_resources_empty_action}")
    if "private var emptySupportDashboard" not in more_hub or "EmotionalSupportRecoveryActionCard" not in more_hub:
        fail("Emotional Support empty state must offer route-backed recovery actions")
    for action_id, destination in [
        ("map", ".mapFocus(.category(.communitySupport))"),
        ("search", ".searchList"),
        ("sources", ".officialSources"),
        ("legal", ".legalHelp"),
    ]:
        if not re.search(rf'EmotionalSupportRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', more_hub, re.S):
            fail(f"Emotional Support empty recovery action missing: {action_id} -> {destination}")
    for required_emotional_empty_action in [
        '"emotionalSupport.empty.dashboard"',
        '"emotionalSupport.empty.action.\\(action.id)"',
    ]:
        if required_emotional_empty_action not in more_hub:
            fail(f"Emotional Support empty dashboard missing: {required_emotional_empty_action}")
    if "private var noCityResultsDashboard" not in cities_view or "CityRecoveryActionCard" not in cities_view:
        fail("Cities no-results state must offer route-backed recovery actions")
    for action_id, destination in [
        ("provinces", ".provinceList"),
        ("map", ".mapHub"),
        ("search", ".searchList"),
        ("sources", ".officialSources"),
    ]:
        if not re.search(rf'CityRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', cities_view, re.S):
            fail(f"Cities no-results recovery action missing: {action_id} -> {destination}")
    for required_cities_empty_action in [
        '"cities.empty.dashboard"',
        '"cities.empty.reset"',
        '"cities.empty.action.\\(action.id)"',
        'searchText = ""',
    ]:
        if required_cities_empty_action not in cities_view:
            fail(f"Cities no-results dashboard missing: {required_cities_empty_action}")
    if "private var checklistCompleteDashboard" not in checklist_view or "ChecklistRecoveryActionCard" not in checklist_view:
        fail("Checklist completed state must offer route-backed next actions")
    for action_id, destination in [
        ("first-steps", ".firstSteps"),
        ("documents", ".journeyDocuments"),
        ("sources", ".officialSources"),
        ("search", ".searchList"),
    ]:
        if not re.search(rf'ChecklistRecoveryAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', checklist_view, re.S):
            fail(f"Checklist completed recovery action missing: {action_id} -> {destination}")
    for required_checklist_complete_action in [
        '"checklist.complete.dashboard"',
        '"checklist.complete.action.\\(action.id)"',
    ]:
        if required_checklist_complete_action not in checklist_view:
            fail(f"Checklist completed dashboard missing: {required_checklist_complete_action}")
    if "private var statusNextActionsSection" not in status_direction_view or "StatusDirectionActionCard" not in status_direction_view:
        fail("Status Direction screen must offer route-backed next actions")
    for action_id, destination in [
        ("checklist", "direction.nextScreenDestination"),
        ("first-steps", ".firstSteps"),
        ("sources", ".officialSources"),
        ("resources", ".resourcesHub"),
    ]:
        if not re.search(rf'StatusDirectionAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', status_direction_view, re.S):
            fail(f"Status Direction next action missing: {action_id} -> {destination}")
    for required_status_action in [
        '"statusDirection.actions.dashboard"',
        '"statusDirection.action.\\(action.id)"',
    ]:
        if required_status_action not in status_direction_view:
            fail(f"Status Direction actions dashboard missing: {required_status_action}")
    if "private var relatedContentFallback" not in navigation_components or "RelatedContentFallbackCard" not in navigation_components:
        fail("RelatedContentSection must show a route-backed fallback when related items are empty")
    for action_id, destination in [
        ("search", ".searchList"),
        ("sources", ".officialSources"),
        ("first-steps", ".firstSteps"),
        ("resources", ".resourcesHub"),
    ]:
        if not re.search(rf'RelatedContentFallbackAction\(\s*id:\s*"{action_id}".*?destination:\s*{re.escape(destination)}', navigation_components, re.S):
            fail(f"RelatedContentSection fallback action missing: {action_id} -> {destination}")
    for required_related_empty_action in [
        '"relatedContent.empty.dashboard"',
        '"relatedContent.empty.action.\\(action.id)"',
    ]:
        if required_related_empty_action not in navigation_components:
            fail(f"RelatedContentSection fallback missing: {required_related_empty_action}")
    if "private var noMistakesFallback" not in navigation_components:
        fail("CommonMistakesSection must show a fallback when no mistakes match the current profile")
    for required_mistakes_empty_action in [
        '"commonMistakes.empty.dashboard"',
        "destination: .mistakesList",
        "destination: .officialSources",
    ]:
        if required_mistakes_empty_action not in navigation_components:
            fail(f"CommonMistakesSection fallback missing: {required_mistakes_empty_action}")
    if "private var relatedGuidesFallback" not in place_detail:
        fail("Place detail must keep related guidance visible when a place has no direct related links")
    for required_place_related_action in [
        '"place.relatedGuides.dashboard"',
        '"place.relatedGuides.empty"',
        "destination: .searchList",
        "destination: .officialSources",
        "destination: .journeyDocuments",
    ]:
        if required_place_related_action not in place_detail:
            fail(f"Place detail related-guides fallback missing: {required_place_related_action}")
    if "private var dutchTermsFallback" not in beginner_guide_detail:
        fail("Beginner guide detail must keep Dutch-term guidance visible when no direct term matches")
    for required_beginner_related_action in [
        '"beginnerGuide.relatedTopics.dashboard"',
        '"beginnerGuide.dutchTerms.dashboard"',
        '"beginnerGuide.dutchTerms.empty"',
        "destination: .searchList",
        "destination: .dutchTermsList",
        "destination: .dutchTerm(term.id)",
    ]:
        if required_beginner_related_action not in beginner_guide_detail:
            fail(f"Beginner guide related guidance missing: {required_beginner_related_action}")
    if "private func ruleNavigationRow" not in fines_view:
        fail("Fine rule detail related topics must be route-backed action rows, not passive text")
    for required_fines_related_action in [
        '"fines.rule.relatedTopics.dashboard"',
        "destination: .searchList",
        "destination: .finesList",
        "destination: .officialSources",
        "private var relatedTopicActionSubtitle",
        "private var relatedFallbackTitle",
    ]:
        if required_fines_related_action not in fines_view:
            fail(f"Fine rule related topics missing: {required_fines_related_action}")
    if "private var relatedFallbackRows" not in dutch_a1a2_view:
        fail("Dutch A1-A2 lesson related topics must stay visible when no direct destination is linked")
    for required_dutch_lesson_related_action in [
        '"dutchA1A2.lesson.related.dashboard"',
        '"dutchA1A2.lesson.related.empty"',
        "destination: .dutchTermsList",
        "destination: .searchList",
        "destination: .dutchA1A2",
    ]:
        if required_dutch_lesson_related_action not in dutch_a1a2_view:
            fail(f"Dutch A1-A2 lesson related fallback missing: {required_dutch_lesson_related_action}")
    if "private func cityRelatedActionChip" not in province_view:
        fail("City profile related articles must be route-backed chips, not passive labels")
    for required_city_related_action in [
        '"city.relatedArticles.dashboard"',
        "destination: .cultureAttractions",
        "destination: .netherlandsHistory",
        "destination: .officialSources",
        "cultureRelatedTitle",
        "historyRelatedTitle",
        "officialSourcesRelatedTitle",
    ]:
        if required_city_related_action not in province_view:
            fail(f"City related articles fallback missing: {required_city_related_action}")
    for required_city_history_fallback in [
        "private var historySourceURL",
        '"city.history.empty.actions"',
        "NavigationLink(value: AppDestination.officialSources)",
        "NavigationLink(value: AppDestination.searchList)",
        "Use official sources or search to continue.",
    ]:
        if required_city_history_fallback not in province_view:
            fail(f"City history fallback missing: {required_city_history_fallback}")
    if "Historical background unavailable" in province_view:
        fail("City history fallback must guide the user instead of saying historical background is unavailable")
    for forbidden_city_symbol_copy in [
        "Verified local symbol not available",
        "Geverifieerd lokaal symbool niet beschikbaar",
        "Проверенный местный символ недоступен",
        "Official coat of arms unavailable",
        "Officieel wapen niet beschikbaar",
        "Официальный герб недоступен",
    ]:
        if forbidden_city_symbol_copy in province_view:
            fail(f"City symbol fallback still exposes unavailable copy: {forbidden_city_symbol_copy}")
    if "private func sourceFallbackRows" not in culture_view:
        fail("Culture article source blocks must show fallback actions when no valid source URL is available")
    for required_culture_source_action in [
        '"culture.article.sources.dashboard"',
        '"culture.article.sources.empty"',
        "destination: .officialSources",
        "destination: .cultureAttractions",
        "AppURL.validatedWebURL(source.url)",
    ]:
        if required_culture_source_action not in culture_view:
            fail(f"Culture article source fallback missing: {required_culture_source_action}")
    if "private var sourceFallbackRows" not in knm_view or "private func sourceButton" not in knm_view:
        fail("KNM source lists must filter valid source URLs and show fallback actions")
    for required_knm_source_action in [
        '"knm.sources"',
        '"knm.sources.empty"',
        "destination: .officialSources",
        "destination: .knm",
        "destination: .searchList",
        "AppURL.validatedWebURL(URL(string: source.url))",
    ]:
        if required_knm_source_action not in knm_view:
            fail(f"KNM source fallback missing: {required_knm_source_action}")
    if "private var transportSourceFallbackRows" not in transport_view or "private func transportSourceButton" not in transport_view:
        fail("Transport guide source list must filter valid URLs and show fallback actions")
    for required_transport_source_action in [
        '"transport.sources.dashboard"',
        '"transport.sources.empty"',
        "destination: .officialSources",
        "destination: .mapFocus(.category(.transport))",
        "destination: .searchList",
        "AppURL.validatedWebURL(source.url)",
    ]:
        if required_transport_source_action not in transport_view:
            fail(f"Transport source fallback missing: {required_transport_source_action}")
    if "private var sourceFallbackRows" not in guide_content or "private func sourceButton" not in guide_content:
        fail("Guide article source section must filter valid URLs and show fallback actions")
    for required_guide_article_source_action in [
        '"guide.article.sources.dashboard"',
        '"guide.article.sources.empty"',
        "destination: .officialSources",
        "destination: .searchList",
        "destination: .resourcesHub",
        "AppURL.validatedWebURL(URL(string: link.urlString))",
    ]:
        if required_guide_article_source_action not in guide_content:
            fail(f"Guide article source fallback missing: {required_guide_article_source_action}")
    if "if !article.links.isEmpty" in guide_content:
        fail("Guide article source section must stay visible even when article links are empty")
    for required_emergency_action in [
        '"emergency.primary.call"',
        '"emergency.primary.source"',
        '"emergency.contact.call.\\(contact.id)"',
        '"emergency.contact.source.\\(contact.id)"',
        "Text(contact.sourceTitle)",
        "Label(callButtonTitle, systemImage: \"phone.fill\")",
    ]:
        if required_emergency_action not in emergency_hub:
            fail(f"Emergency hub action missing: {required_emergency_action}")
    starter_pack_save = re.search(r"private func saveStarterPack\(\).*?static func starterPackAnswers", favorites_view, re.S)
    if not starter_pack_save or "if !savedStore.isSaved(item.id)" not in starter_pack_save.group(0):
        fail("Saved starter pack button must add missing items without toggling already-saved items off")
    for required_saved_empty_action in [
        '"saved.empty.dashboard"',
        '"saved.empty.action.\\(action.id)"',
        '"saved.empty.saveStarterPack"',
        "destination: .officialSources",
        "destination: .journeyDocuments",
        "destination: .mapHub",
        "destination: .cityList",
    ]:
        if required_saved_empty_action not in favorites_view:
            fail(f"Saved empty dashboard action missing: {required_saved_empty_action}")
    for required_search_detail_fallback in [
        "private var relatedQuestionsFallback",
        "private var peopleAlsoSearchFallback",
        '"search.answer.relatedQuestions.dashboard"',
        '"search.answer.relatedQuestions.empty"',
        '"search.answer.peopleAlsoSearch.dashboard"',
        '"search.answer.peopleAlsoSearch.empty"',
        "CommonMistakesSection(mistakes: commonMistakes)",
        "destination: .searchList",
        "destination: .officialSources",
        "destination: .resourcesHub",
        "destination: .mapFocus(.category(placeCategory))",
    ]:
        if required_search_detail_fallback not in search_answer_detail:
            fail(f"Search answer detail fallback missing: {required_search_detail_fallback}")
    for forbidden_search_detail_gap in [
        "if !relatedAnswers.isEmpty",
        "if !peopleAlsoSearch.isEmpty",
        "if !commonMistakes.isEmpty",
    ]:
        if forbidden_search_detail_gap in search_answer_detail:
            fail(f"Search answer detail still hides a useful section when empty: {forbidden_search_detail_gap}")
    for forbidden_search_detail_copy in [
        "No direct related questions",
        "Geen directe gerelateerde vragen",
        "Прямых связанных вопросов нет",
    ]:
        if forbidden_search_detail_copy in search_answer_detail:
            fail(f"Search answer detail fallback still exposes passive copy: {forbidden_search_detail_copy}")

    forbidden_visible_literals = [
        "Official symbol unavailable",
        "Source unavailable",
        "Resources will appear here",
        "Bronnen verschijnen hier",
        "Ресурсы появятся здесь",
        "will appear here",
        "verschijnen hier",
        "появятся здесь",
        "Content not found",
        "Coming soon",
        "TODO",
        "FIXME",
        "Lorem",
    ]
    combined = "\n".join([app_destination_view, root_menu, search, l10n, culture_data, province_view, official_sources, netherlands_overview])
    visible_views_with_home = "\n".join([combined, read("YouNew/Views/HomeView.swift"), settings_view, app_content])
    for needle in forbidden_visible_literals:
        if needle in visible_views_with_home:
            fail(f"forbidden visible placeholder literal found: {needle}")

    for forbidden_empty_copy in [
        '"empty.no_reminders": "No upcoming reminders yet."',
        '"empty.no_reminders": "Nog geen aankomende herinneringen."',
        '"empty.no_reminders": "Пока нет предстоящих напоминаний."',
        '"empty.no_letter_summaries": "No saved letter summaries yet."',
        '"empty.no_letter_summaries": "Nog geen opgeslagen briefoverzichten."',
        '"empty.no_letter_summaries": "Пока нет сохранённых сводок писем."',
        '"empty.no_reminders" = "No upcoming reminders yet."',
        '"empty.no_reminders" = "Nog geen aankomende herinneringen."',
        '"empty.no_reminders" = "Пока нет предстоящих напоминаний."',
        '"empty.no_letter_summaries" = "No saved letter summaries yet."',
        '"empty.no_letter_summaries" = "Nog geen opgeslagen briefoverzichten."',
        '"empty.no_letter_summaries" = "Пока нет сохранённых сводок писем."',
        '"empty.no_saved_items": "Nothing saved yet."',
        '"empty.no_saved_items": "Nog niets opgeslagen."',
        '"empty.no_saved_items": "Пока ничего не сохранено."',
        '"empty.no_saved_items" = "Nothing saved yet."',
        '"empty.no_saved_items" = "Nog niets opgeslagen."',
        '"empty.no_saved_items" = "Пока ничего не сохранено."',
        '"settings.recent.empty": "Nothing opened yet"',
        '"settings.recent.empty": "Nog niets geopend"',
        '"settings.recent.empty": "Пока пусто"',
        '"settings.recent.empty" = "Nothing opened yet";',
        '"settings.recent.empty" = "Nog niets geopend";',
        '"settings.recent.empty" = "Пока пусто";',
        '"letters.no_saved_examples": "No saved letter examples yet."',
        '"letters.no_saved_examples": "Nog geen opgeslagen briefvoorbeelden."',
        '"letters.no_saved_examples": "Пока нет сохранённых примеров писем."',
        '"letters.no_saved_examples" = "No saved examples";',
        '"letters.no_saved_examples" = "Geen opgeslagen voorbeelden";',
        '"letters.no_saved_examples" = "Нет сохранённых примеров";',
    ]:
        if forbidden_empty_copy in l10n + en_strings + nl_strings + ru_strings:
            fail(f"passive empty-state copy still present: {forbidden_empty_copy}")
    for forbidden_saved_screen_copy in [
        'return "No saved items yet"',
        'return "Nog niets opgeslagen"',
        'return "Пока ничего не сохранено"',
    ]:
        if forbidden_saved_screen_copy in favorites_view + settings_view:
            fail(f"passive saved empty-state copy still present: {forbidden_saved_screen_copy}")
    for required_saved_document_action in [
        "NavigationLink(value: AppDestination.journeyDocuments)",
        '"saved.document.openDocuments"',
        "private var openDocumentsTitle",
    ]:
        if required_saved_document_action not in saved_item_detail:
            fail(f"Saved document detail must route empty notes back to Documents: {required_saved_document_action}")
    for forbidden_saved_document_copy in [
        "No notes available.",
        "Geen notities beschikbaar.",
        "Заметки отсутствуют.",
    ]:
        if forbidden_saved_document_copy in saved_item_detail:
            fail(f"Saved document detail still exposes passive note fallback: {forbidden_saved_document_copy}")

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
