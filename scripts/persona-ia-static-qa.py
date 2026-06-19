#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_DOCS = [
    "PERSONA_ARCHITECTURE.md",
    "USER_JOURNEYS.md",
    "CONTENT_MAPPING.md",
    "PROFILE_SYSTEM.md",
    "AI_CONTEXT_MODEL.md",
]

PERSONAS = [
    "Student",
    "Worker",
    "Refugee",
    "Highly Skilled Migrant",
    "EU Citizen",
    "Family",
    "Tourist",
    "Entrepreneur",
    "LGBT Newcomer",
]

USER_STATUS_CASES = [
    "student",
    "worker",
    "refugee",
    "highlySkilledMigrant",
    "euCitizen",
    "family",
    "tourist",
    "entrepreneur",
    "lgbtNewcomer",
]

DASHBOARD_REQUIREMENTS = {
    "student": [
        "Universities",
        "MBO",
        "HBO",
        "Research Universities",
        "DUO",
        "Student Housing",
        "Student Finance",
        "Student Insurance",
        "Public Transport Discounts",
        "Dutch Language Courses",
        "Student Jobs",
        "Libraries",
        "Student Communities",
        "Student Events",
        "Study Spaces",
        "City Life",
        "Free Time",
    ],
    "worker": [
        "BSN",
        "DigiD",
        "Work Contracts",
        "Taxes",
        "UWV",
        "Salary",
        "Employment Rights",
        "Health Insurance",
        "Housing",
        "Transport",
        "Pension",
        "Worker Training",
    ],
    "refugee": [
        "IND",
        "Municipality",
        "Housing",
        "Benefits",
        "Integration",
        "Language",
        "Healthcare",
        "Documents",
        "Work Permissions",
        "Education Access",
        "Support Organizations",
    ],
    "family": [
        "Schools",
        "Childcare",
        "Kinderopvang",
        "SVB",
        "Child Benefits",
        "Family Housing",
        "Healthcare",
        "Activities",
        "Municipal Services",
    ],
}

STUDENT_FORBIDDEN = [
    "UWV",
    "Work Contracts",
    "Employment Rights",
    "Pension",
    "Worker Training",
    "IND",
    "Refugee",
    "Benefits",
    "Work Permissions",
    "Support Organizations",
]

errors: list[str] = []


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.exists():
        errors.append(f"Missing file: {relative}")
        return ""
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def section_between(text: str, start_pattern: str, end_pattern: str) -> str:
    start = re.search(start_pattern, text)
    if not start:
        return ""
    end = re.search(end_pattern, text[start.end():])
    if not end:
        return text[start.end():]
    return text[start.end():start.end() + end.start()]


def dashboard_case(home: str, case_name: str, next_case_pattern: str) -> str:
    dashboard = section_between(
        home,
        r"private func dashboard\(for status: UserStatus\) -> HomePersonaDashboard \{\s*switch status \{",
        r"\n    private func action\(",
    )
    return section_between(dashboard, rf"case \.{case_name}\b[^:]*:", next_case_pattern)


for doc in REQUIRED_DOCS:
    text = read(doc)
    for persona in PERSONAS:
        require(persona in text, f"{doc} does not mention {persona}")

user_profile = read("YouNew/Models/UserProfile.swift")
for case_name in USER_STATUS_CASES:
    require(re.search(rf"\bcase {case_name}\b", user_profile) is not None, f"UserStatus missing case {case_name}")

persona_tag = read("YouNew/Models/PersonaTag.swift")
for tag in ["student", "worker", "refugee", "family", "tourist", "entrepreneur", "lgbt", "eu", "nonEU", "highlySkilledMigrant"]:
    require(re.search(rf"\bcase {tag}\b", persona_tag) is not None, f"PersonaTag missing {tag}")
require("assignedTags" in persona_tag, "PersonaContentPolicy.assignedTags is missing")
require("static func sanitizedPendingAIPrompt(_ prompt: String, context: AIContext)" in persona_tag, "PersonaContentPolicy lacks pending AI prompt sanitizer")
require("containsOutsidePersonaTerms(trimmed, for: persona)" in persona_tag, "Pending AI prompt sanitizer does not detect outside-persona terms")
student_safe_prompt = section_between(persona_tag, r"case \(\.student, \.english\):", r"case \(\.student, \.dutch\):")
for required in ["DUO", "universities", "student housing", "insurance", "transport discounts", "Dutch courses", "student jobs", "libraries", "communities", "events", "study spaces", "city life", "free time"]:
    require(required in student_safe_prompt, f"Student safe AI handoff prompt missing {required}")
for forbidden in ["UWV", "IND", "tax", "pension", "refugee", "child benefit", "CJIB", "fine"]:
    require(re.search(rf"\b{re.escape(forbidden)}\b", student_safe_prompt, flags=re.IGNORECASE) is None, f"Student safe AI handoff prompt leaks {forbidden}")

onboarding = read("YouNew/Views/OnboardingQuestionnaireView.swift")
profile_selection = read("YouNew/Views/ProfileSelectionView.swift")
app_state = read("YouNew/ViewModels/AppStateViewModel.swift")
content_view = read("YouNew/App/ContentView.swift")
require("ForEach(UserStatus.allCases)" in onboarding, "Onboarding must ask Who am I? using UserStatus.allCases")
require("ForEach(UserStatus.allCases)" in profile_selection, "Profile settings must use UserStatus.allCases")
require("ProfileType.allCases" not in onboarding, "Onboarding still uses ProfileType.allCases")
require("ProfileType.allCases" not in profile_selection, "Profile settings still uses ProfileType.allCases")
require("appState.selectedUserStatus = persona" in onboarding, "Onboarding does not save selected persona")
student_priority_options = section_between(onboarding, r"case \.student:", r"case \.worker:")
require("studentFinance" in student_priority_options and "studentJobs" in student_priority_options and "studentTransport" in student_priority_options, "Student onboarding priorities are not student-specific")
require('"taxes"' not in student_priority_options and '"work"' not in student_priority_options, "Student onboarding priorities expose worker/tax options")
require("prunePrioritiesForSelectedPersona()" in onboarding, "Onboarding does not prune stale priorities after persona change")
require("appState.requiresPersonaSelection" in content_view, "ContentView can dismiss onboarding without a selected persona")
require("var requiresPersonaSelection: Bool" in app_state and "selectedUserStatus == nil" in app_state, "AppState lacks persona-required launch gate")
complete_questionnaire = section_between(app_state, "func completeQuestionnaire()", r"\n    func reset")
require("hasCompletedQuestionnaire = true" in complete_questionnaire, "Questionnaire completion is not persisted")
require("selectedUserStatusKey" in app_state, "AppState does not define selected persona persistence key")
require("defaults.set(selectedUserStatus.rawValue" in app_state, "AppState does not persist selectedUserStatus")
require("UserStatus(rawValue: savedStatus)" in app_state, "AppState does not restore selectedUserStatus")
require("defaults.removeObject(forKey: Self.selectedUserStatusKey)" in app_state, "AppState does not remove persisted selectedUserStatus on reset/nil")
settings_view = read("YouNew/Views/SettingsView.swift")
profile_status_picker = section_between(settings_view, r"Picker\(L10n\.t\(\"settings\.profile_status\"", r"\.pickerStyle\(\.menu\)")
require("UserStatus?.none" not in profile_status_picker and "status.unsure.title" not in profile_status_picker, "Settings profile picker can clear required persona")
require("newStatus?.correspondingProfileType" in settings_view and "appState.userProfile.profileType = profileType" in settings_view, "Settings profile picker does not sync profile type")
for priority_case in ["studentFinance", "studentTransport", "studentJobs", "workerTraining", "workPermission", "childBenefits", "businessRegistration", "legalSafety"]:
    require(f"case {priority_case}" in user_profile, f"LifePriority missing persona-specific case {priority_case}")
prioritized_sections = section_between(app_state, "var prioritizedGuideSections", r"\n    func destination")
require("MainGuideSection.allCases.filter" not in prioritized_sections, "Persona guide sections append all topic sections after persona priorities")
student_guide_sections = section_between(prioritized_sections, r"case \.student:", r"case \.worker:")
for forbidden in [".workAndTaxes", ".finesAndRules", ".government", ".documents"]:
    require(forbidden not in student_guide_sections, f"Student guide section leaks {forbidden}")
user_path_profile = read("YouNew/Models/UserPathProfile.swift")
student_path_profile = section_between(user_path_profile, "static let student = make", "static let worker = make")
for required in ["Universities / MBO / HBO", "DUO and student finance", "Student housing", "Student insurance", "Public transport discounts", "Dutch language courses", "Student jobs", "Libraries and student communities", "Student events", "City life and free time"]:
    require(required in student_path_profile, f"Student path profile missing {required}")
for forbidden in ["Register with municipality", "municipality route", "BSN", "DigiD", "UWV", "IND", "Refugee", "taxes", "pension", "worker bureaucracy", "work orientation", "rights resources", ".mapFocus(.government)", ".mapFocus(.healthcare)"]:
    require(forbidden not in student_path_profile, f"Student path profile leaks forbidden content: {forbidden}")
worker_path_profile = section_between(user_path_profile, "static let worker = make", "static let refugee = make")
for required in ["BSN", "DigiD", "Work contracts", "Taxes", "UWV", "Salary", "Employment rights", "Health insurance", "Housing", "Transport", "Pension", "Worker training"]:
    require(required in worker_path_profile, f"Worker path profile missing {required}")
for forbidden in ["DUO", "Universities", "Student housing", "student finance", "IND", "Refugee", "asylum", "Kinderopvang", "Child benefits", "Dutch language", "survivalHub"]:
    require(forbidden not in worker_path_profile, f"Worker path profile leaks forbidden content: {forbidden}")
refugee_path_profile = section_between(user_path_profile, "static let refugee = make", "static let ukrainian = make")
for required in ["IND", "Municipality", "Housing", "Benefits", "Integration", "Language", "Healthcare", "Documents", "Work permissions", "Education access", "Support organizations"]:
    require(required in refugee_path_profile, f"Refugee path profile missing {required}")
for forbidden in ["DUO and student finance", "student housing", "UWV", "Salary", "Pension", "Worker training", "Child benefits", "KvK", "VAT", "Long-term planning", "Legal help"]:
    require(forbidden not in refugee_path_profile, f"Refugee path profile leaks forbidden content: {forbidden}")
family_path_profile = section_between(user_path_profile, "static let family = make", "static let tourist = make")
for required in ["Schools", "Childcare", "Kinderopvang", "SVB", "Child benefits", "Family housing", "Healthcare", "Activities", "Municipal services"]:
    require(required in family_path_profile, f"Family path profile missing {required}")
for forbidden in ["newcomer.recommendedSteps", "BSN", "DigiD", "Work contracts", "UWV", "IND", "Refugee", "DUO", "Student jobs", "KvK", "VAT"]:
    require(forbidden not in family_path_profile, f"Family path profile leaks forbidden content: {forbidden}")

home = read("YouNew/Views/HomeView.swift")
require("dashboard(for: appState.selectedUserStatus ?? .worker)" not in home, "Home defaults to worker when no persona is selected")
home_case_order = {
    "student": r"case \.worker\b",
    "worker": r"case \.refugee\b",
    "refugee": r"case \.family\b",
    "family": r"case \.highlySkilledMigrant\b",
}
for case_name, required_terms in DASHBOARD_REQUIREMENTS.items():
    section = dashboard_case(home, case_name, home_case_order[case_name])
    require(section.strip() != "", f"Home dashboard missing case .{case_name}")
    for term in required_terms:
        require(term in section, f"Home .{case_name} dashboard missing {term}")

student_section = dashboard_case(home, "student", home_case_order["student"])
for forbidden in STUDENT_FORBIDDEN:
    require(forbidden not in student_section, f"Student dashboard leaks forbidden term: {forbidden}")

for case_name in ["student", "worker", "refugee", "family", "tourist", "entrepreneur", "lgbt"]:
    require(re.search(rf"case \.{case_name}\b", home) is not None, f"Home life/dashboard data missing persona branch {case_name}")
require("if shouldShowHistoryAndCultureSection" in home, "Home history/culture section must be persona-gated")
require("if shouldShowAllCategoriesLink" in home, "Home broad categories link must be persona-gated")
require("appState.selectedUserStatus == nil" in section_between(home, "private var shouldShowAllCategoriesLink", r"\n    private var"), "Broad categories link should only appear before persona selection")
student_history_guard = section_between(home, "private var shouldShowHistoryAndCultureSection", r"\n    private func")
for forbidden_case in [".student", ".worker", ".refugee", ".family", ".entrepreneur", ".lgbt", ".highlySkilledMigrant"]:
    require(forbidden_case in student_history_guard, f"History/culture guard does not explicitly handle {forbidden_case}")

root_tab = read("YouNew/App/AppTabView.swift")
for group in ["regularGovernmentItems", "regularLifeItems", "regularLearnItems"]:
    require(f"private var {group}" in root_tab, f"RootTab missing {group}")
    require("appState.selectedUserStatus?.personaTag" in section_between(root_tab, f"private var {group}", r"\n    private var regular|\n    private func"), f"{group} is not persona-scoped")
require("private func isMenuItemVisibleForPersona(_ item: SideMenuItemModel) -> Bool" in root_tab, "RootTab lacks central menu persona filter")
require("RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)" in root_tab, "RootTab menu filter does not use central route policy")
require("guard isMenuItemVisibleForPersona(item) else { return }" in root_tab, "RootTab menu selection can open hidden persona routes")
regular_menu_group = section_between(root_tab, "private func regularMenuGroup", "private func regularGroupTitle")
require("let visibleItems = items.filter(isMenuItemVisibleForPersona)" in regular_menu_group, "Regular-width menu group does not persona-filter menu items")
require("ForEach(visibleItems)" in regular_menu_group, "Regular-width menu group still renders unfiltered menu items")
require("guard isMenuItemVisibleForPersona(item) else { return false }" in root_tab, "Side menu search/list filtering does not apply persona route policy")
require("let visibleItems = items.filter(isMenuItemVisibleForPersona)" in section_between(root_tab, "private func cityMenuGroup", "private func compactCityMenuButton"), "City menu group does not persona-filter menu items")
require("let visibleItems = items.filter(isMenuItemVisibleForPersona)" in section_between(root_tab, r"private func menuRows\(items:", "private var sideCompactCityRow"), "Side menu rows do not persona-filter ad hoc items")
require("if isDestinationVisible(destination)" in section_between(root_tab, "private func sidePillAction", "private var completedMenuSteps"), "Side menu pill actions are not persona-gated")
require("if isDestinationVisible(destination)" in section_between(root_tab, "private func quickAction", "private func compactActionButton"), "Side menu quick actions are not persona-gated")
related_content_engine = read("YouNew/Models/RelatedContentEngine.swift")
netherlands_history_gate = section_between(related_content_engine, r"case \.netherlandsOverview, \.netherlandsHistory", r"case \.cultureAttractions")
require(".student" not in netherlands_history_gate, "Student route policy can still open Netherlands history/KNM overview routes")

more_hub = read("YouNew/Views/MoreHubView.swift")
persona_category_links = section_between(more_hub, "private var personaCategoryLinks", r"\n    private func categoryAction")
require("switch appState.selectedUserStatus?.personaTag" in persona_category_links, "MoreHub category navigator is not persona-scoped")
for case_name in [".student", ".worker", ".refugee", ".family", ".tourist", ".entrepreneur", ".lgbt"]:
    require(case_name in persona_category_links, f"MoreHub category navigator missing {case_name}")
more_student_links = section_between(persona_category_links, r"case \.student:", r"case \.worker")
for forbidden in ["categoryWorkTitle", "categoryWorkSubtitle", "moreRefugee", "IND", "UWV", "Taxes"]:
    require(forbidden not in more_student_links, f"MoreHub Student category leaks {forbidden}")

categories_hub = read("YouNew/Views/CategoriesHubView.swift")
app_category = read("YouNew/Models/AppCategory.swift")
require("AppCategoryRegistry.forPersona(activePersona)" in categories_hub, "CategoriesHub must use persona-scoped categories")
require("AppCategoryRegistry.all" not in categories_hub, "CategoriesHub still renders the broad topic-first category registry")
require("CategoryQuickLink.links(for: activePersona" in categories_hub, "CategoriesHub quick links are not persona-scoped")
require("static func forPersona(_ persona: PersonaTag?)" in app_category, "AppCategoryRegistry missing persona category router")
for case_name in [".student", ".worker", ".refugee", ".family", ".tourist", ".entrepreneur", ".lgbt"]:
    require(case_name in app_category, f"AppCategoryRegistry.forPersona missing {case_name}")
category_student_section = section_between(app_category, r"case \.student:", r"case \.worker")
for required in ["Universities", "MBO", "HBO", "research universities", "DUO", "Student housing", "Student finance", "Dutch language courses", "Libraries", "communities", "events", "free time"]:
    require(required in category_student_section, f"Student category hub missing {required}")
for forbidden in ["Work contracts", "UWV", "Taxes", "IND", "Refugee", "Benefits", "Work Permissions"]:
    require(forbidden not in category_student_section, f"Student category hub leaks {forbidden}")

search_vm = read("YouNew/ViewModels/SearchViewModel.swift")
search_view = read("YouNew/Views/SearchView.swift")
search_answer = read("YouNew/Models/SearchAnswer.swift")
require("answers.filter { $0.isVisible(for: activePersona" in search_vm, "Search answers are not persona-filtered")
require("MockBeginnerGuidesData.search(" in search_vm and "activePersona: activePersona" in search_vm, "Beginner guide search is not persona-filtered")
require("var visibleCategories: [SearchCategory]" in search_vm, "SearchViewModel does not expose persona-visible categories")
require("SearchCategory.allCases.filter { $0.isVisible(for: activePersona) }" in search_vm, "Search categories are not filtered by active persona")
require("guard inferredCategory.isVisible(for: activePersona)" in search_vm, "Search query category inference can select cross-persona categories")
require("ForEach(viewModel.visibleCategories)" in search_view, "SearchView still renders all category chips")
require("private var mapSuggestionDestination: AppDestination?" in search_view, "SearchView map suggestion lacks persona-visible destination guard")
require("RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)" in section_between(search_view, "private var mapSuggestionDestination", re.escape("init(viewModel:")), "SearchView map suggestion is not filtered by active persona")
require("NavigationLink(value: mapSuggestionDestination)" in search_view, "SearchView map suggestion still links to raw map focus")
direct_results_builder = section_between(search_view, "private func buildDirectResults()", "private func selectedCategoryAllows")
require(".filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }" in direct_results_builder, "SearchView direct results are not persona-route filtered")
require("func isVisible(for persona: PersonaTag?)" in search_answer, "SearchCategory missing persona visibility policy")
search_category_student = section_between(search_answer, r"case \.student:", r"case \.worker")
for forbidden in [".taxes", ".work", ".immigration", ".legalHelp"]:
    require(forbidden not in search_category_student, f"Student search filter allows {forbidden}")

resource_item = read("YouNew/Models/ResourceLinkItem.swift")
resource_engine = read("YouNew/ViewModels/ResourceRelevanceEngine.swift")
resources_data = read("YouNew/Data/MockResourcesData.swift")
require("let personaTags: Set<PersonaTag>" in resource_item, "ResourceLinkItem missing stored personaTags")
require("PersonaContentPolicy.assignedTags" in resource_item, "ResourceLinkItem does not assign persona tags")
require("func isVisible(for persona: PersonaTag?" in resource_item, "ResourceLinkItem missing persona visibility")
require("all.filter { $0.isVisible(for: status.personaTag" in resource_engine, "ResourceRelevanceEngine ranks before persona filtering")
for resource_title in ["UWV: Employment and benefits", "Belastingdienst: Tax administration", "IND: Residence permits and immigration", "DUO: International student info"]:
    resource_section = section_between(resources_data, re.escape(resource_title), r"\n        \),")
    require("personaTags:" in resource_section, f"Resource missing explicit persona tags: {resource_title}")

checklist_engine = read("YouNew/ViewModels/ProfileChecklistEngine.swift")
checklist_model = read("YouNew/Models/ChecklistItem.swift")
checklist_view = read("YouNew/Views/ChecklistView.swift")
ai_view_model = read("YouNew/ViewModels/AIViewModel.swift")
ai_builder = read("YouNew/Services/AIContextBuilder.swift")
require("isAllowedCategory(item.category" in checklist_engine, "Checklist engine does not enforce persona category visibility")
require("item.relevantProfileTypes" in checklist_engine and "context.status.correspondingProfileType" in checklist_engine, "Checklist engine ignores explicit profile-only checklist items")
require("var personaTags: Set<PersonaTag>" in checklist_model, "ChecklistItem lacks persona tags")
require("func isVisible(for persona: PersonaTag?" in checklist_model, "ChecklistItem lacks persona visibility")
require("var visibleChecklistItems: [ChecklistItem]" in app_state, "AppState lacks persona-visible checklist items")
require("for item in visibleChecklistItems" in app_state, "Prioritized checklist is not based on persona-visible items")
require("guard item.isVisible(for: selectedUserStatus?.personaTag" in app_state, "Checklist toggle can mutate hidden checklist items")
require("private var allItems: [ChecklistItem] { appState.visibleChecklistItems }" in checklist_view, "ChecklistView displays all checklist items instead of persona-visible items")
require("appState.visibleChecklistItems.filter(\\.isCompleted).count" in home and "appState.visibleChecklistItems.count" in home, "Home checklist progress is not persona-filtered")
require("appState.visibleChecklistItems.filter(\\.isCompleted).count" in root_tab and "appState.visibleChecklistItems.count" in root_tab, "Root menu checklist progress is not persona-filtered")
require("appState.visibleChecklistItems.filter(\\.isCompleted).count" in ai_builder, "AI home context checklist progress is not persona-filtered")
require("appState.visibleChecklistItems.filter(\\.isCompleted).count" in ai_view_model, "AI view model checklist snapshot is not persona-filtered")
checklist_student = section_between(checklist_engine, r"case \.student:", r"case \.worker")
for forbidden in [".work", ".taxes", ".registration"]:
    require(forbidden not in checklist_student, f"Student checklist category allows {forbidden}")

help_hub = read("YouNew/Views/HelpHubView.swift")
require("switch activePersona" in help_hub, "HelpHub categories are not persona-scoped")
help_student = section_between(help_hub, r"case \.student:", r"case \.worker")
for required in ["Student housing", "Student insurance", "Public transport discounts", "Dutch language courses", "Libraries and student communities", "City life and free time"]:
    require(required in help_student, f"HelpHub Student path missing {required}")
for forbidden in ["Work contracts", "Taxes", "IND", "UWV", "Refugee"]:
    require(forbidden not in help_student, f"HelpHub Student leaks {forbidden}")

government_hub = read("YouNew/Views/GovernmentHubView.swift")
official_sources_view = read("YouNew/Views/OfficialSourceDirectoryView.swift")
information_hub = read("YouNew/Views/InformationHubView.swift")
require("let personaTags: Set<PersonaTag>" in government_hub, "GovernmentHub services lack persona tags")
require("private var visibleServices" in government_hub and "activePersona" in government_hub, "GovernmentHub services are not persona-filtered")
for service_id in ['id: "ind"', 'id: "duo"', 'id: "uwv"', 'id: "belasting"', 'id: "svb"']:
    service_section = section_between(government_hub, re.escape(service_id), r"\n        GovService|\n    \]")
    require("personaTags:" in service_section, f"GovernmentHub service missing persona tags: {service_id}")
require("personaTags: [.student" in section_between(government_hub, 'id: "duo"', r"\n        GovService"), "GovernmentHub DUO is not tagged for students")
for service_id in ['id: "ind"', 'id: "uwv"', 'id: "belasting"', 'id: "svb"']:
    service_section = section_between(government_hub, re.escape(service_id), r"\n        GovService|\n    \]")
    require(".student" not in service_section, f"GovernmentHub Student can see forbidden service: {service_id}")

nearby_map = read("YouNew/Views/NearbyMapView.swift")
require("guard let persona = appState.selectedUserStatus?.personaTag" in nearby_map, "Nearby map search filters are not persona-scoped")
require("func isVisible(for persona: PersonaTag)" in nearby_map, "Nearby map search actions missing persona visibility policy")
map_student = section_between(nearby_map, r"case \.student:", r"case \.worker")
for required in [".education", ".library", ".studentHelp", ".duo", ".transport"]:
    require(required in map_student, f"Nearby map Student filters missing {required}")
for forbidden in [".uwv", ".documents", ".municipality"]:
    require(forbidden not in map_student, f"Nearby map Student filters allow {forbidden}")

guide_content = read("YouNew/Views/GuideContentView.swift")
app_destination_view = read("YouNew/App/Navigation/AppDestinationView.swift")
first_steps_view = read("YouNew/Views/FirstStepsView.swift")
province_directory_view = read("YouNew/Views/ProvinceDirectoryView.swift")
history_knm_hub = read("YouNew/Views/HistoryKNMHubView.swift")
require("let personaTags: Set<PersonaTag>" in guide_content, "Guide articles/sections lack persona tags")
require("func isVisible(for persona: PersonaTag?" in guide_content, "Guide content lacks persona visibility policy")
require("visibleArticles(for persona" in guide_content, "Guide sections do not filter visible articles")
require("GuideContent.section(id: id, activePersona: appState.selectedUserStatus?.personaTag)" in app_destination_view, "Guide section routes do not filter by active persona")
require("GuideContent.article(sectionID: sectionID, articleID: articleID, activePersona: appState.selectedUserStatus?.personaTag)" in app_destination_view, "Guide article routes do not filter by active persona")
require("MockSearchAnswersData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Search answer detail routes do not filter by active persona")
require("MockBeginnerGuidesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Beginner guide detail routes do not filter by active persona")
require("MockResourcesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Resource detail routes do not filter by active persona")
require("MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Institution detail routes do not filter by active persona")
require("MockNewcomerMistakesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Mistake detail routes do not filter by active persona")
require("appState.checklistItems.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Checklist detail routes do not filter by active persona")
require("MockDutchTermsData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Dutch term detail routes do not filter by active persona")
require("MockFineInfoData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Fine detail routes do not filter by active persona")
require("MockLettersData.examples.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Letter detail routes do not filter by active persona")
require("MockRulesGuideData.topics.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Rule topic routes do not filter by active persona")
require("MockRulesGuideData.scenarios.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag" in app_destination_view, "Rule scenario routes do not filter by active persona")
require("@EnvironmentObject private var appState: AppStateViewModel" in first_steps_view, "FirstStepsView does not receive active app profile")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in first_steps_view, "FirstStepsView lacks active persona")
require("private var visibleItems: [FirstStepItem]" in first_steps_view, "FirstStepsView lacks persona-visible item list")
require("RelatedContentEngine.isVisible(destination, for: activePersona)" in section_between(first_steps_view, "private var visibleItems", "var body:"), "FirstStepsView top-level items are not route-filtered")
require("ForEach(visibleItems)" in first_steps_view, "FirstStepsView still renders raw first-step items")
require("if let mapFocus = content.mapFocus," in first_steps_view and "isVisible(.mapFocus(mapFocus))" in first_steps_view, "PracticalGuideView map action is not persona-gated")
require("isVisible(.dutchA1A2Module(dutchModuleID))" in first_steps_view, "PracticalGuideView Dutch module action is not persona-gated")
require("if isVisible(.officialSources)" in first_steps_view, "PracticalGuideView official sources action is not persona-gated")
require("private func isVisible(_ destination: AppDestination) -> Bool" in first_steps_view and "RelatedContentEngine.isVisible(destination, for: activePersona)" in first_steps_view, "PracticalGuideView action gating does not use central persona policy")
province_detail_section = section_between(province_directory_view, "struct ProvinceCityDetailView", "struct CityDetailLayout")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in province_detail_section, "Province detail lacks active persona")
require("if isVisible(.cultureAttractions)" in province_detail_section, "Province detail culture link is not persona-gated")
require("if isVisible(.firstSteps)" in province_detail_section, "Province detail first steps link is not persona-gated")
require("if isVisible(.mapFocus(.province(province.id)))" in province_detail_section, "Province detail map link is not persona-gated")
require("RelatedContentEngine.isVisible(destination, for: activePersona)" in province_detail_section, "Province detail route gating does not use central persona policy")
city_detail_section = section_between(province_directory_view, "struct CityDetailView", "private struct ProvinceRowCard")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in city_detail_section, "City detail lacks active persona")
require("if isVisible(.mapFocus(.city(city.id)))" in city_detail_section, "City detail map link is not persona-gated")
require("isVisible(.practicalGuide(topic))" in city_detail_section, "City detail related guide chips are not persona-gated")
require("RelatedContentEngine.isVisible(destination, for: activePersona)" in city_detail_section, "City detail route gating does not use central persona policy")
require("@EnvironmentObject private var appState: AppStateViewModel" in history_knm_hub, "HistoryKNMHub does not receive active app profile")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in history_knm_hub, "HistoryKNMHub lacks active persona")
require("if isVisible(.knm)" in history_knm_hub, "HistoryKNMHub KNM link is not persona-gated")
require("ForEach(visibleCultureTopics)" in history_knm_hub, "HistoryKNMHub culture topics are not persona-filtered")
require("cultureTopics.filter { isVisible($0.destination) }" in history_knm_hub, "HistoryKNMHub visible culture topics do not use route visibility")
require("RelatedContentEngine.isVisible(destination, for: activePersona)" in history_knm_hub, "HistoryKNMHub route gating does not use central persona policy")
guide_section_policy = section_between(guide_content, "static func assignedPersonaTags", r"\n}\n\nprivate extension GuideSection")
require('case "work":' in guide_section_policy and ".student" not in section_between(guide_section_policy, 'case "work":', 'case "integration":'), "Work guide section is visible to students")
require('case "documents":' in guide_section_policy and ".student" not in section_between(guide_section_policy, 'case "documents":', 'case "housing":'), "Documents guide section is visible to students")
huurtoeslag_section = section_between(guide_content, "static var huurtoeslagArticle", r"\n    static var tenantRightsArticle")
require("personaTags:" in huurtoeslag_section, "Huurtoeslag guide article lacks explicit persona tags")
require(".student" not in huurtoeslag_section, "Student housing path leaks Huurtoeslag tax/benefit article")

institution_model = read("YouNew/Models/Institution.swift")
institutions_view = read("YouNew/Views/InstitutionsView.swift")
institutions_data = read("YouNew/Data/MockInstitutionsData.swift")
require("let personaTags: Set<PersonaTag>" in institution_model, "Institution model lacks persona tags")
require("func isVisible(for persona: PersonaTag?" in institution_model, "Institution model lacks persona visibility")
require("visibleInstitutions" in institutions_view and "isVisible(for: appState.selectedUserStatus?.personaTag" in institutions_view, "InstitutionsView is not persona-filtered")
for institution_name in ['name: "IND"', 'name: "UWV"', 'name: "Belastingdienst"', 'name: "Municipality"']:
    institution_section = section_between(institutions_data, re.escape(institution_name), r"\n        Institution|\n    \]")
    require("personaTags:" in institution_section, f"Institution missing explicit persona tags: {institution_name}")
for forbidden in ['name: "IND"', 'name: "UWV"', 'name: "Belastingdienst"', 'name: "Municipality"']:
    institution_section = section_between(institutions_data, re.escape(forbidden), r"\n        Institution|\n    \]")
    require(".student" not in institution_section, f"Student can see forbidden institution: {forbidden}")
duo_institution = section_between(institutions_data, 'name: "DUO"', r"\n        Institution")
require(".student" in duo_institution, "Student cannot see DUO institution")
require("var personaTags: Set<PersonaTag>" in official_sources_view, "OfficialSourceItem lacks persona tags")
require("func isVisible(for persona: PersonaTag?" in official_sources_view, "OfficialSourceItem lacks persona visibility")
require("allSources.filter { $0.isVisible(for: activePersona" in official_sources_view, "OfficialSourceDirectoryView is not persona-filtered")
require("private var visibleSourceCount" in official_sources_view, "OfficialSourceDirectoryView does not expose a persona-filtered visible source count")
require("subtitle: String(format: L10n.t(\"official_sources.subtitle\", lang), visibleSourceCount)" in official_sources_view, "OfficialSourceDirectoryView subtitle still reports unfiltered source count")
for source_name in ["ind", "duo", "uwv", "belastingdienst", "toeslagen", "svb", "rdw", "cjib"]:
    require(f'lowerName.contains("{source_name}")' in official_sources_view, f"Official source persona override missing {source_name}")
student_official_forbidden = section_between(official_sources_view, 'if lowerName.contains("ind")', 'if lowerName.contains("duo")')
require(".student" not in student_official_forbidden, "Student can see IND official source")
student_tax_source = section_between(official_sources_view, 'if lowerName.contains("belastingdienst")', 'if lowerName.contains("toeslagen")')
require(".student" not in student_tax_source, "Student can see Belastingdienst official source")
require("@EnvironmentObject private var appState: AppStateViewModel" in information_hub, "InformationHub does not receive active app profile")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in information_hub, "InformationHub lacks active persona")
require("visibleItems([" in information_hub, "InformationHub item arrays are not routed through persona visibility")
require("RelatedContentEngine.isVisible($0.destination, for: activePersona)" in information_hub, "InformationHub cards are not filtered by central persona route policy")
require("sectionIfNeeded" in information_hub, "InformationHub can render empty topic sections after persona filtering")
require("private var verifiedVisualAssets" in information_hub and "switch activePersona" in information_hub, "InformationHub media strip is not persona-specific")
student_information_media = section_between(information_hub, r"case \.student:", r"case \.refugee")
require("municipalityCityHallImage" not in student_information_media, "Student InformationHub media strip still shows municipality imagery")

document_model = read("YouNew/Models/DocumentItem.swift")
document_store = read("YouNew/ViewModels/DocumentStore.swift")
document_view = read("YouNew/Views/DocumentOrganizerView.swift")
require("var personaTags: Set<PersonaTag>" in document_model, "DocumentCategory lacks persona tags")
require("func isVisible(for status: UserStatus?)" in document_model, "DocumentCategory lacks persona visibility")
require("func visibleCategories(for status: UserStatus?)" in document_store, "DocumentStore lacks persona-visible category list")
require("DocumentCategory.allCases.filter { $0.isVisible(for: status) }" in document_store, "DocumentStore visible categories are not persona-filtered")
require("switch status?.personaTag" in document_store, "Document suggestions are not routed by persona")
student_document_suggestions = section_between(document_store, r"case \.student:", r"case \.worker:")
for required in [".duoLetters", ".schoolUniversity", ".healthInsurance", ".rentalContract"]:
    require(required in student_document_suggestions, f"Student document suggestions missing {required}")
for forbidden in [".bsn", ".digid", ".workContract", ".payslip", ".uwvLetters", ".indResidence", ".belastingdienstLetters", ".cjibFines"]:
    require(forbidden not in student_document_suggestions, f"Student document suggestions leak {forbidden}")
student_document_tags = section_between(document_model, r"case \.duoLetters:", r"case \.uwvLetters:")
require(".student" in student_document_tags, "DUO document category is not tagged for students")
for forbidden_category in ["case .uwvLetters:", "case .workContract, .payslip:", "case .indResidence:", "case .belastingdienstLetters:", "case .cjibFines:"]:
    category_section = section_between(document_model, re.escape(forbidden_category), r"\n        case ")
    require(".student" not in category_section, f"Student can see forbidden document category {forbidden_category}")
require("status: appState.selectedUserStatus" in document_view, "Document detail picker does not receive active persona")
require("ForEach(visibleCategories)" in document_view, "Document detail picker still renders all document categories")
require("DocumentCategory.allCases.filter { $0.isVisible(for: status) }" in document_view, "Document detail visible categories are not persona-filtered")

mistake_model = read("YouNew/Models/NewcomerMistake.swift")
mistakes_view = read("YouNew/Views/MistakesLibraryView.swift")
require("let personaTags: Set<PersonaTag>" in mistake_model, "NewcomerMistake lacks persona tags")
require("func isVisible(for persona: PersonaTag?" in mistake_model, "NewcomerMistake lacks persona visibility")
require("private static func assignedPersonaTags" in mistake_model, "NewcomerMistake lacks category persona policy")
require("visibleItems" in mistakes_view and "isVisible(for: appState.selectedUserStatus?.personaTag" in mistakes_view, "MistakesLibraryView is not persona-filtered")
mistake_student_work = section_between(mistake_model, r"case \.work:", r"case \.taxes:")
require(".student" not in mistake_student_work, "Student can see work mistakes")
mistake_student_taxes = section_between(mistake_model, r"case \.taxes:", r"case \.education:")
require(".student" not in mistake_student_taxes, "Student can see tax mistakes")

fine_model = read("YouNew/Models/FineInfoItem.swift")
letter_model = read("YouNew/Models/LetterExample.swift")
dutch_term_model = read("YouNew/Models/DutchTerm.swift")
rule_model = read("YouNew/Models/RuleGuideModels.swift")
fines_view = read("YouNew/Views/FinesInfoView.swift")
survival_view = read("YouNew/Views/SurvivalNavigatorView.swift")
dutch_terms_view = read("YouNew/Views/DutchTermsView.swift")
letters_view = read("YouNew/Views/LettersView.swift")
related_engine = read("YouNew/Models/RelatedContentEngine.swift")
knowledge_index = read("YouNew/Services/KnowledgeIndex.swift")
search_result_mapping = section_between(knowledge_index, ".map { item, score, fields in", "KnowledgeIndexBuilder")
require("let visibleNeighbors = graph.neighbors(of: item.id, in: itemsByID)" in search_result_mapping, "KnowledgeIndex search does not build a persona-visible graph neighbor list")
require(".filter { $0.isVisible(for: persona, scope: searchScope) }" in search_result_mapping, "KnowledgeIndex graph neighbors are not filtered by active persona")
require("graphNeighbors: visibleNeighbors" in search_result_mapping, "KnowledgeIndex search still attaches unfiltered graph neighbors")
for relative, text in [
    ("FineInfoItem", fine_model),
    ("LetterExample", letter_model),
    ("DutchTerm", dutch_term_model),
    ("RuleGuideModels", rule_model),
]:
    require("personaTags" in text, f"{relative} lacks personaTags")
    require("func isVisible(for persona: PersonaTag?" in text, f"{relative} lacks persona visibility")
require("case .tax:" in fine_model and ".student" not in section_between(fine_model, r"case \.tax:", r"case \.municipalityRegistration"), "Student can see tax fine guidance")
require("if haystack.contains(\"belasting\")" in letter_model and ".student" not in section_between(letter_model, 'if haystack.contains("belasting")', 'if haystack.contains("cjib")'), "Student can see Belastingdienst letters")
require("case .work:" in dutch_term_model and ".student" not in section_between(dutch_term_model, r"case \.work:", r"case \.immigration:"), "Student can see work glossary terms")
require("case .immigration:" in dutch_term_model and ".student" not in section_between(dutch_term_model, r"case \.immigration:", r"case \.financial:"), "Student can see immigration glossary terms")
require("case \"Work violations\":" in rule_model and ".student" not in section_between(rule_model, 'case "Work violations":', 'case "Tourist mistakes":'), "Student can see work rule topics")
require("case \"ID/passport obligations\"" in rule_model and ".student" not in section_between(rule_model, 'case "ID/passport obligations"', 'case "Public transport fines":'), "Student can see ID/passport rule topics")
require("visibleTopics" in fines_view and "visibleScenarios" in fines_view and "isVisible(for: activePersona" in fines_view, "FinesInfoView does not filter rules/scenarios by persona")
require("visibleScenarios" in survival_view and "isVisible(for: activePersona" in survival_view, "SurvivalNavigatorView scenarios are not persona-filtered")
require("MockDutchTermsData.items.filter { $0.isVisible(for: activePersona" in dutch_terms_view, "DutchTermsView list is not persona-filtered")
require("visibleExamples" in letters_view and "MockLettersData.examples.filter { $0.isVisible(for: activePersona" in letters_view, "LettersView list is not persona-filtered")
require("static func isVisible(_ destination: AppDestination, for persona: PersonaTag?)" in related_engine, "RelatedContentEngine lacks destination persona filter")
require("case .checklist(let id):" in related_engine and "MockChecklistData.items.contains" in related_engine, "RelatedContentEngine does not filter checklist destinations")
app_screens_section = section_between(knowledge_index, "private static func appScreens", "private static func screen")
require("tags: Set<PersonaTag>" in section_between(knowledge_index, "private static func screen", "private static func knowledgeTopics"), "KnowledgeIndex app-screen helper does not accept explicit persona tags")
for screen_id in ["screen:search", "screen:officialSources", "screen:journeyDocuments", "screen:fines", "screen:letters", "hub:government", "hub:help", "hub:languagehub"]:
    screen_section = section_between(app_screens_section, re.escape(screen_id), r"\n            screen|\n        \]")
    require("tags:" in screen_section, f"KnowledgeIndex app screen missing explicit persona tags: {screen_id}")
student_hidden_screen_ids = ["screen:journeyDocuments", "screen:fines", "screen:letters", "hub:government", "hub:help"]
for screen_id in student_hidden_screen_ids:
    screen_section = section_between(app_screens_section, re.escape(screen_id), r"\n            screen|\n        \]")
    require(".student" not in screen_section, f"Student search index can see hidden app screen {screen_id}")
for related_view in [
    "YouNew/Views/SearchAnswerDetailView.swift",
    "YouNew/Views/InstitutionDetailView.swift",
    "YouNew/Views/LetterDetailView.swift",
    "YouNew/Views/ChecklistItemDetailView.swift",
    "YouNew/Views/DutchTermsView.swift",
]:
    text = read(related_view)
    require("RelatedContentEngine.isVisible($0.destination" in text, f"{related_view} related content is not persona-filtered")
for model_ref in ["fine.personaTags", "institution.personaTags", "term.personaTags", "letter.personaTags", "mistake.personaTags", "rule.personaTags", "scenario.personaTags"]:
    require(model_ref in knowledge_index, f"KnowledgeIndex does not use explicit {model_ref}")
require("item.personaTags" in section_between(knowledge_index, "private static func checklist", "private static func fines"), "KnowledgeIndex does not use checklist personaTags")

legal_model = read("YouNew/Models/LegalInfoItem.swift")
risk_model = read("YouNew/Models/RiskItem.swift")
daily_life_model = read("YouNew/Models/DailyLifeTip.swift")
scam_model = read("YouNew/Models/ScamWarning.swift")
legal_view = read("YouNew/Views/LegalInfoView.swift")
risks_view = read("YouNew/Views/RisksView.swift")
for relative, text in [
    ("LegalInfoItem", legal_model),
    ("RiskItem", risk_model),
    ("DailyLifeTip", daily_life_model),
    ("ScamWarning", scam_model),
]:
    require("personaTags" in text, f"{relative} lacks personaTags")
    require("func isVisible(for persona: PersonaTag?" in text, f"{relative} lacks persona visibility")
require("case .tax:" in legal_model and ".student" not in section_between(legal_model, r"case \.tax:", r"case \.benefits:"), "Student can see legal tax content")
require("case .work:" in legal_model and ".student" not in section_between(legal_model, r"case \.work:", r"case \.tax:"), "Student can see legal work content")
require("case .immigration:" in legal_model and ".student" not in section_between(legal_model, r"case \.immigration:", r"case \.municipality"), "Student can see legal immigration content")
require("MockLegalInfoData.items.filter { $0.isVisible(for: activePersona" in legal_view, "LegalInfoView list is not persona-filtered")
require("visibleCategories" in legal_view and "isVisible(for: activePersona" in legal_view, "LegalInfoView categories are not persona-filtered")
require("visibleSections" in risks_view and "MockRisksData.items.contains" in risks_view, "RisksView sections are not persona-filtered")
require("RiskCard(item: item)" in risks_view and "isVisible(for: activePersona" in risks_view, "RisksView items are not persona-filtered")
for model_ref in ["risk.personaTags", "scam.personaTags", "item.personaTags", "tip.personaTags"]:
    require(model_ref in knowledge_index, f"KnowledgeIndex does not use explicit {model_ref}")

expansion_models = read("YouNew/Models/ExpansionModels.swift")
mock_search_answers = read("YouNew/Data/MockSearchAnswersData.swift")
for model_name in ["ReminderItem", "SurvivalGuideItem", "DocumentReferenceItem", "KnowledgeTopic", "LifeScenario", "OfficialServiceDirectoryItem"]:
    model_section = section_between(expansion_models, rf"struct {model_name}", r"\nstruct |\nenum ")
    require("personaTags" in model_section, f"{model_name} lacks personaTags")
    require("func isVisible(for persona: PersonaTag?" in model_section, f"{model_name} lacks persona visibility")
for model_ref in ["topic.personaTags", "scenario.personaTags", "service.personaTags", "document.personaTags", "reminder.personaTags", "item.personaTags"]:
    require(model_ref in knowledge_index, f"KnowledgeIndex does not use expansion {model_ref}")
require("personaTags: topic.personaTags" in mock_search_answers, "Expansion knowledge-topic SearchAnswer entries do not inherit persona tags")
require("personaTags: scenario.personaTags" in mock_search_answers, "Expansion life-scenario SearchAnswer entries do not inherit persona tags")

survival_guide_view = read("YouNew/Views/SurvivalGuideView.swift")
favorites_view = read("YouNew/Views/FavoritesView.swift")
require("visibleItems" in survival_guide_view and "MockExpansionData.survivalGuide.filter { $0.isVisible(for: activePersona" in survival_guide_view, "SurvivalGuideView does not filter expansion survival items by persona")
require("AIContextBuilder.survivalGuideContext(language: lang, appState: appState)" in survival_guide_view, "SurvivalGuideView AI context does not receive active profile")
require("visibleSavedItems" in favorites_view and "RelatedContentEngine.isVisible(destination, for: activePersona)" in favorites_view, "FavoritesView saved items are not persona-filtered")

ai_context = read("YouNew/Models/AIContext.swift")
ai_builder = read("YouNew/Services/AIContextBuilder.swift")
ai_client = read("YouNew/Services/AIClient.swift")
ai_service = read("YouNew/Services/AIService.swift")
ai_response_composer = read("YouNew/Services/AIResponseComposer.swift")
official_sources_view = read("YouNew/Views/OfficialSourceDirectoryView.swift")
require("return PersonaContentPolicy.assignedTags(" in official_sources_view, "OfficialSourceDirectory fallback persona tags are computed but not returned")
require("let activePersonaTag: PersonaTag?" in ai_context, "AIContext lacks activePersonaTag")
require("personaSearchScope" in ai_context, "AIContext lacks personaSearchScope")
official_context = section_between(ai_builder, "static func officialSourcesContext", r"\n    // MARK: - Home")
require("switch activePersona" in official_context, "AI official-sources context is not persona-routed")
for persona_case in [".student", ".worker", ".refugee", ".family", ".highlySkilledMigrant", ".eu", ".nonEU", ".tourist", ".entrepreneur", ".lgbt"]:
    require(f"case {persona_case}:" in official_context, f"AI official-sources context missing {persona_case}")
student_official_context = section_between(official_context, r"case \.student:", r"case \.worker:")
for required in ["DUO", "Study in NL", "OV-chipkaart", "Do not start with tax, UWV, IND"]:
    require(required in student_official_context, f"Student AI official context missing {required}")
for forbidden in ["Belastingdienst", 'OfficialSource(title: "UWV"', 'OfficialSource(title: "IND"']:
    require(forbidden not in student_official_context, f"Student AI official context leaks {forbidden}")
require("activePersonaTag: appState?.selectedUserStatus?.personaTag" in ai_builder or "activePersonaTag: activePersona" in ai_builder, "AIContextBuilder does not set activePersonaTag")
require("let activePersona = appState?.selectedUserStatus?.personaTag" in ai_builder, "AIContextBuilder expansion search does not read active persona")
for expansion_filter in ["$0.isVisible(for: activePersona, scope: .currentAndUniversal)", "topic.personaTags", "scenario.personaTags", "service.personaTags"]:
    require(expansion_filter in ai_builder or expansion_filter in knowledge_index, f"Missing AI/search expansion persona filter: {expansion_filter}")
require("let activePersonaTag: String?" in ai_client, "AI client retrieval payload lacks activePersonaTag")
require("activePersonaTag = context.activePersonaTag?.rawValue" in ai_client, "AI client does not serialize activePersonaTag")
require("let personaSearchScope: String" in ai_client, "AI client retrieval payload lacks personaSearchScope")
require("personaSearchScope = context.personaSearchScope.rawValue" in ai_client, "AI client does not serialize personaSearchScope")
require("personaSafeResponse(response, context: context)" in ai_service, "AIService does not sanitize backend responses by persona before returning")
require("private func personaSafeResponse(_ response: AIResponse, context: AIContext)" in ai_service, "AIService lacks persona-safe response sanitizer")
require("AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag)" in ai_service, "AIService sanitizer does not use persona-visible navigation")
require("private func personaSafeNextStep" in ai_service and 'destinationID: "search"' in ai_service, "AIService does not replace hidden backend next steps with search")
require("private func personaSafeDestinationID" in ai_service and 'return "search"' in ai_service, "AIService does not replace hidden backend app destinations with search")
require("quickActions = response.quickActions.filter" in ai_service, "AIService does not filter backend quick actions")
require("safeRouteID(from: primary.item.route, fallback: primary.item.routeID, context: context)" in ai_response_composer, "AIResponseComposer app destination is not persona-route checked")
require("nextStep(for: primary, language: language, context: context)" in ai_response_composer, "AIResponseComposer next step is not built with persona context")
require("destinationID: safeRouteID(from: result.item.route, fallback: result.item.routeID, context: context)" in ai_response_composer, "AIResponseComposer next step destination is not persona-safe")
require(".filter { isActionVisible($0, context: context) }" in ai_response_composer, "AIResponseComposer quick actions are not filtered by persona-visible route")
require("AppNavigationResolver.destination(for: destinationID) == nil ? nil : destinationID" in ai_response_composer, "AIResponseComposer safe route check does not validate live destinations")
app_navigation_resolver = read("YouNew/App/Navigation/AppRouter.swift")
ai_assistant_view = read("YouNew/Views/AIAssistantView.swift")
require("static func destination(for rawID: String?, visibleFor persona: PersonaTag?)" in app_navigation_resolver, "AppNavigationResolver lacks persona-visible destination resolver")
require("RelatedContentEngine.isVisible(destination, for: persona)" in app_navigation_resolver, "Persona-visible navigation resolver does not use central route policy")
require("AppNavigationResolver.destination(for: rawID, visibleFor: appState.selectedUserStatus?.personaTag)" in ai_assistant_view, "AIAssistant response destination is not persona-filtered")
require("AppNavigationResolver.destination(for: response.appDestinationID, visibleFor: appState.selectedUserStatus?.personaTag)" in ai_assistant_view, "AIAssistant app destination card is not persona-filtered")
require("AppNavigationResolver.destination(for: action.destinationID, visibleFor: appState.selectedUserStatus?.personaTag)" in ai_assistant_view, "AIAssistant quick actions are not persona-filtered")
require("PersonaContentPolicy.sanitizedPendingAIPrompt(prompt, context: context)" in ai_assistant_view, "AIAssistant applies pending app-authored prompts without persona sanitizing")
require("private func isToolVisible(_ destination: AppDestination) -> Bool" in ai_assistant_view, "AIAssistant fixed tool grid lacks persona-visible route helper")
require("RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag)" in section_between(ai_assistant_view, "private func isToolVisible", "private func assistantToolCard"), "AIAssistant fixed tool grid does not use central persona route policy")
require("if isToolVisible(.knm)" in ai_assistant_view, "AIAssistant KNM tool is not persona-gated")
require("if isToolVisible(.firstSteps)" in ai_assistant_view, "AIAssistant First Steps tool is not persona-gated")

ai_workflow = read("YouNew/Services/AIWorkflowEngine.swift")
ai_view_model = read("YouNew/ViewModels/AIViewModel.swift")
nearby_place = read("YouNew/Models/NearbyPlace.swift")
map_view_model = read("YouNew/ViewModels/MapViewModel.swift")
nearby_map_view = read("YouNew/Views/NearbyMapView.swift")
require("visibleChecklistItems = MockChecklistData.items" in ai_workflow, "AI workflow next checklist does not build a persona-visible checklist pool")
require("isVisible(for: context.activePersonaTag, scope: context.personaSearchScope)" in ai_workflow, "AI workflow next checklist does not filter by AI persona context")
require("visibleCompletedCount" in ai_workflow and "visibleChecklistItems.count" in ai_workflow, "AI workflow checklist progress counts all personas")
require("static func visibleActions(_ actions: [AIResponseAction], context: AIContext)" in ai_workflow, "AI workflow lacks persona-visible action filter")
require("AppNavigationResolver.destination(for: destinationID) != nil" in ai_workflow, "AI workflow action filter does not validate live destinations")
require("static func visibleDestinationID(_ destinationID: String?, context: AIContext)" in ai_workflow, "AI workflow lacks persona-visible fallback destination")
require("visibleDestinationID(" in section_between(ai_workflow, "static func questionResponse", "static func finalResponse"), "AI workflow questions do not persona-filter fallback destinations")
require("visibleActions(" in section_between(ai_workflow, "static func questionResponse", "static func finalResponse"), "AI workflow questions do not persona-filter quick actions")
require("visibleActions(" in section_between(ai_workflow, "static func finalResponse", "static func nextChecklistResponse"), "AI workflow final response does not persona-filter quick actions")
require("visibleDestinationID(composed.appDestinationID" in ai_workflow, "AI workflow final app destination is not persona-filtered")
require("visibleActions(deduplicateActions([" in section_between(ai_workflow, "static func nextChecklistResponse", "static func workflowGuidance"), "AI workflow next checklist actions are not persona-filtered")
require("context.activePersonaTag?.rawValue" in section_between(ai_view_model, "private static func buildCacheKey", "private func cachedResponse"), "AI answer cache key does not include active persona")
require("context.secondaryPersonaTags.map" in section_between(ai_view_model, "private static func buildCacheKey", "private func cachedResponse"), "AI answer cache key does not include secondary personas")
require("context.personaSearchScope.rawValue" in section_between(ai_view_model, "private static func buildCacheKey", "private func cachedResponse"), "AI answer cache key does not include persona search scope")
require("func displayedQuickPrompts(for language: AppLanguage)" in ai_view_model, "AIViewModel does not expose persona-safe displayed prompts")
require("viewModel.displayedQuickPrompts(for: lang)" in ai_assistant_view, "AIAssistantView still combines generic prompt starters")
require("private func personaQuickPrompts(for persona: PersonaTag, language: AppLanguage)" in ai_view_model, "AIViewModel lacks persona-specific prompt starters")
default_prompt_section = section_between(ai_view_model, "private func fallbackQuickPrompts", "private func personaQuickPrompts")
for forbidden_prompt in ["Explain this fine", "CJIB", "BSN, DigiD, and taxes", "boete", "belasting"]:
    require(forbidden_prompt not in default_prompt_section, f"Default AI prompts leak topic-first content: {forbidden_prompt}")
student_prompt_section = section_between(ai_view_model, r"case \(\.student, \.english\):", r"case \(\.student, \.dutch\):")
for required in ["DUO", "student housing", "student insurance", "study Dutch"]:
    require(required in student_prompt_section, f"Student AI prompts missing {required}")
for forbidden_prompt in ["tax", "UWV", "IND", "CJIB", "fine", "work contract"]:
    require(re.search(rf"\b{re.escape(forbidden_prompt)}\b", student_prompt_section, flags=re.IGNORECASE) is None, f"Student AI prompts leak {forbidden_prompt}")
transport_prompt_section = section_between(ai_view_model, r"case \.transport:", r"case \.province, \.city:")
require("context.activePersonaTag == .student" in transport_prompt_section, "Transport AI prompts are not student-specific")
for required in ["student transport discounts", "DUO travel product", "route to campus"]:
    require(required in transport_prompt_section, f"Student transport prompts missing {required}")
student_transport_branch = section_between(transport_prompt_section, "if context.activePersonaTag == .student", re.escape("return prompts("))
require("fines" not in student_transport_branch.lower() and "boetes" not in student_transport_branch.lower(), "Student transport prompts mention fines")
require("private func personaSafeResponse(_ response: AIResponse, context: AIContext)" in ai_view_model, "AIViewModel does not sanitize cached/local responses by persona")
require("applyAIResponse(response, language: language, replyingTo: userMessage.id, context: context)" in ai_view_model, "AIViewModel backend responses are not applied with persona context")
require("appendCachedResponse(cachedResponse, language: language, replyingTo: userMessage.id, context: context)" in ai_view_model, "AIViewModel cached responses are not replayed with persona context")
require("AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag)" in ai_view_model, "AIViewModel response sanitizer does not use persona-visible navigation")
require("quickActions.append(.openScreen(title: localizedSearchTitle" in ai_view_model, "AIViewModel does not add safe search action when cached actions are filtered")
require("var personaTags: Set<PersonaTag>" in nearby_place, "NearbyPlace lacks personaTags")
require("func isVisible(for persona: PersonaTag?" in nearby_place, "NearbyPlace lacks persona visibility")
require("case .duo, .studentHelp:" in nearby_place and "return [.student]" in section_between(nearby_place, r"case \.duo, \.studentHelp:", r"case \.uwv:"), "Student map places are not isolated")
require("case .uwv:" in nearby_place and ".student" not in section_between(nearby_place, r"case \.uwv:", r"case \.ind"), "Student can see UWV map places")
require("case .ind, .immigrationSupport:" in nearby_place and ".student" not in section_between(nearby_place, r"case \.ind, \.immigrationSupport:", r"case \.expatCenter:"), "Student can see IND/immigration map places")
require("place.personaTags" in knowledge_index, "KnowledgeIndex nearby-place entries do not use explicit place personaTags")
require("@Published var activePersona: PersonaTag?" in map_view_model, "MapViewModel does not track active persona")
require("$0.city == selectedCity && $0.isVisible(for: activePersona)" in map_view_model, "MapViewModel city places are not persona-filtered")
require("&& $0.isVisible(for: activePersona)" in map_view_model, "MapViewModel place focus can restore outside-persona places")
require(".onChange(of: appState.selectedUserStatus)" in nearby_map_view, "NearbyMapView does not update map persona after profile changes")
require("viewModel.activePersona = appState.selectedUserStatus?.personaTag" in nearby_map_view, "NearbyMapView does not initialize map persona")
require("$0.city == province.capital && $0.isVisible(for: activePersona)" in nearby_map_view, "NearbyMapView province point counts are not persona-filtered")
settings_view = read("YouNew/Views/SettingsView.swift")
require("visibleMapCategories" in settings_view and "$0.isVisible(for: activePersona)" in settings_view, "Settings map categories are not persona-filtered")
lgbtq_model = read("YouNew/Models/LGBTQSupportModels.swift")
lgbtq_vm = read("YouNew/ViewModels/LGBTQSupportViewModel.swift")
lgbtq_view = read("YouNew/Views/LGBTQSupportView.swift")
app_destination = read("YouNew/App/Navigation/AppDestinationView.swift")
language_hub = read("YouNew/Views/LanguageHubView.swift")
require("var personaTags: Set<PersonaTag> { [.lgbt] }" in lgbtq_model, "LGBTQ support items lack explicit LGBT persona tags")
require("func isVisible(for persona: PersonaTag?" in lgbtq_model, "LGBTQ support items lack persona visibility")
require("@Published var activePersona: PersonaTag?" in lgbtq_vm and "personaVisibleItems" in lgbtq_vm, "LGBTQ support view model does not track active persona")
require("allItems.filter { $0.isVisible(for: activePersona" in lgbtq_vm, "LGBTQ support view model does not filter loaded items by persona")
require("viewModel.activePersona = appState.selectedUserStatus?.personaTag" in lgbtq_view, "LGBTQ support view does not initialize active persona")
require("case .lgbtqSupport:" in app_destination and "appState.selectedUserStatus?.personaTag == .lgbt" in section_between(app_destination, r"case \.lgbtqSupport:", r"case \.mapHub:"), "LGBTQ support route is not gated to LGBT persona")
require("personaTags: item.personaTags" in section_between(knowledge_index, "private static func lgbtqSupport", "private static func nearbyPlaces"), "KnowledgeIndex LGBTQ entries do not use explicit item personaTags")
require("@EnvironmentObject private var appState: AppStateViewModel" in language_hub, "LanguageHub does not receive active app profile")
require("private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }" in language_hub, "LanguageHub lacks active persona")
require("if isVisible(.knm)" in language_hub, "LanguageHub KNM row is not persona-gated")
require("ForEach(visibleResourceCards)" in language_hub, "LanguageHub resource cards are not persona-filtered")
require("resourceCards.filter { isVisible($0.destination) }" in language_hub, "LanguageHub visible resource cards do not use route visibility")
require("RelatedContentEngine.isVisible(destination, for: activePersona)" in language_hub, "LanguageHub route visibility does not use central persona policy")

app_state = read("YouNew/ViewModels/AppStateViewModel.swift")
home_view = read("YouNew/Views/HomeView.swift")
root_tab = read("YouNew/App/AppTabView.swift")
require("func visibleRecentlyViewedTopics()" in app_state, "AppState lacks persona-filtered recent topic helper")
require("func visibleRecentRouteIDs()" in app_state, "AppState lacks persona-filtered recent route helper")
require("func visibleCompletedGuideIDs()" in app_state, "AppState lacks persona-filtered completed guide helper")
require("displayTitle(forRecentlyViewedTopic" in app_state and "isVisible(for: selectedUserStatus?.personaTag" in app_state, "Recently viewed titles can leak outside current persona")
require("RelatedContentEngine.isVisible(destination, for: persona)" in app_state, "Recent route IDs are not filtered through related-content visibility")
visible_completed_guides = section_between(app_state, "func visibleCompletedGuideIDs()", r"\n    func resetPersonalState")
require("AppNavigationResolver.destination(for: routeID, visibleFor: persona) != nil" in visible_completed_guides, "Completed guide IDs are not filtered through persona-visible navigation")
require("recentRouteIDs: appState?.visibleRecentRouteIDs()" in ai_builder, "AI context uses raw recent route IDs")
require("visibleChecklistItems = appState?.checklistItems.filter" in ai_builder, "AI context checklist progress is not persona-filtered")
require("completedGuideIDs: appState?.visibleCompletedGuideIDs()" in ai_builder, "AI context build uses raw completed guide IDs")
require("let visibleSavedItems = SavedItemsStore.shared.savedItems.filter" in ai_builder, "AI context enrichment lacks persona-visible saved item fallback")
require("savedItemIDs: context.savedItemIDs.isEmpty ? Array(visibleSavedItems.prefix(12).map(\\.id))" in ai_builder, "AI context enrichment uses raw saved item IDs")
require("savedItemKinds: context.savedItemKinds.isEmpty ? Array(Set(visibleSavedItems.map { $0.kind.rawValue })).sorted()" in ai_builder, "AI context enrichment uses raw saved item kinds")
require("completedGuideIDs: context.completedGuideIDs.isEmpty ? appState.visibleCompletedGuideIDs()" in ai_builder, "AI context enrichment uses raw completed guide IDs")
require("visibleRecentlyViewedTopics().prefix(3)" in home_view, "Home recent bookmarks use raw recent topics")
require("visibleRecentlyViewedTopics().prefix(3)" in root_tab, "Root tab recent preview uses raw recent topics")
require("if !RelatedContentEngine.isVisible(destination, for: activePersona)" in app_destination, "AppDestinationView lacks central persona route gate")
require("guard RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag) else { return }" in app_destination, "AppDestinationView records hidden routes in history/completion")
require("case .finesList, .scamWarningsList, .scamWarning:" in related_engine and ".student" not in section_between(related_engine, r"case \.finesList, \.scamWarningsList, \.scamWarning:", r"case \.lettersList"), "Student can open fine/scam route families")
require("case .lgbtqSupport:" in related_engine and "return persona == .lgbt" in section_between(related_engine, r"case \.lgbtqSupport:", r"case \.mapHub:"), "LGBTQ route family is not restricted to LGBT persona")
require("case .statusDirection(let status):" in related_engine and "status.personaTag == persona" in related_engine, "Status direction routes can cross personas")
require("private static func isMapFocus(_ focus: MapFocus, visibleFor persona: PersonaTag?)" in related_engine, "RelatedContentEngine lacks persona gate for map focus routes")
map_focus_policy = section_between(related_engine, "private static func isMapFocus", "private static func isPersona")
government_map_focus = section_between(map_focus_policy, r"case \.government:", r"case \.education:")
healthcare_map_focus = section_between(map_focus_policy, r"case \.healthcare:", r"case \.government:")
education_map_focus = section_between(map_focus_policy, r"case \.education:", r"case \.emergency:")
require(".student" not in government_map_focus, "Student can open government map focus")
require(".student" not in healthcare_map_focus, "Student can open generic healthcare map focus")
require(".student" in education_map_focus, "Student cannot open education/library map focus")
fallback_section = section_between(app_destination, "private struct ReleaseRouteFallbackView", "private struct AssistantHubRoot")
hidden_fallback_section = section_between(fallback_section, "if isHiddenForProfile {", "} else {")
require("isHiddenForProfile" in fallback_section and "!RelatedContentEngine.isVisible(destination, for: activePersona)" in fallback_section, "Route fallback cannot detect hidden persona routes")
require("profileHomeTitle" in hidden_fallback_section and "profileSearchTitle" in hidden_fallback_section, "Hidden route fallback does not use profile-safe actions")
for forbidden_fallback_text in ["Rules and fines", "Common mistakes", "Government services", "Documents", "Dutch terms"]:
    require(forbidden_fallback_text not in hidden_fallback_section, f"Hidden route fallback can expose forbidden topic text: {forbidden_fallback_text}")

for relative in ["YouNew/Models/KnowledgeItem.swift", "YouNew/Models/SearchAnswer.swift", "YouNew/Models/BeginnerGuideItem.swift"]:
    text = read(relative)
    require("let personaTags: Set<PersonaTag>" in text, f"{relative} missing stored personaTags")
    require("PersonaContentPolicy.assignedTags" in text, f"{relative} does not assign persona tags")

leaky_stored_defaults = []
for relative in ["YouNew/Models/KnowledgeItem.swift", "YouNew/Models/SearchAnswer.swift", "YouNew/Models/BeginnerGuideItem.swift"]:
    if re.search(r"let personaTags: Set<PersonaTag>\s*=\s*\[\]", read(relative)):
        leaky_stored_defaults.append(relative)
require(not leaky_stored_defaults, f"Stored personaTags still default to empty in {', '.join(leaky_stored_defaults)}")

if errors:
    print("PERSONA IA STATIC QA FAILED")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("PERSONA IA STATIC QA PASSED")
print(f"Checked {len(REQUIRED_DOCS)} docs, {len(USER_STATUS_CASES)} user statuses, dashboard requirements, persona tags, AI context, and search filters.")
