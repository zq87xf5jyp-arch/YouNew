import SwiftUI

struct AppDestinationView: View {
    let destination: AppDestination
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var documentStore: DocumentStore
    @State private var isPreviewingOutsideProfile = false

    private var lang: AppLanguage { languageManager.appLanguage }
    private var accessScope: PersonaSearchScope {
        isPreviewingOutsideProfile ? .allContentWithOutsidePathWarning : .currentAndUniversal
    }

    var body: some View {
        Group {
            destinationContent
        }
        .onAppear {
            guard RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag) else { return }
            let routeID = AppNavigationResolver.routeID(from: destination)
            appState.addRecentRouteID(routeID)
            appState.markGuideCompleted(routeID: routeID)
        }
    }

    @ViewBuilder
    private var destinationContent: some View {
        let activePersona = appState.selectedUserStatus?.personaTag
        if !RelatedContentEngine.isVisible(destination, for: activePersona) && !isPreviewingOutsideProfile {
            ReleaseRouteFallbackView(destination: destination) {
                isPreviewingOutsideProfile = true
            }
        } else {
            switch destination {
        case .checklist(let id):
            if let item = appState.checklistItems.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope) })
                ?? MockChecklistData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope) }) {
                ChecklistItemDetailView(item: item)
            } else {
                notFoundView
            }
        case .dutchTerm(let id): 
            if let term = MockDutchTermsData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope) }) {
                DutchTermDetailView(term: term)
            } else {
                notFoundView
            }
        case .fineInfo(let id):
            if let fine = MockFineInfoData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope) }) {
                FineInfoDetailView(item: fine)
            } else {
                notFoundView
            }
        case .institution(let name):
            if let institution = MockInstitutionsData.items.first(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame
                    && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope)
            }) {
                InstitutionDetailView(institution: institution)
            } else {
                notFoundView
            }
        case .searchAnswer(let id):
            if let answer = MockSearchAnswersData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                SearchAnswerDetailView(
                    answer: answer,
                    allAnswers: MockSearchAnswersData.items.filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }
                )
            } else {
                notFoundView
            }
        case .letter(let title):
            if let letter = MockLettersData.examples.first(where: { $0.title.caseInsensitiveCompare(title) == .orderedSame && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                LetterDetailView(letter: letter)
            } else {
                notFoundView
            }
        case .mistake(let id):
            if let mistake = MockNewcomerMistakesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                NewcomerMistakeDetailView(item: mistake)
            } else {
                notFoundView
            }
        case .beginnerGuide(let id):
            if let item = MockBeginnerGuidesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: accessScope) }) {
                BeginnerGuideDetailView(item: item)
            } else {
                notFoundView
            }
        case .statusDirection(let status):
            StatusDirectionView(status: status)
        case .ruleTopic(let id):
            if let topic = MockRulesGuideData.topics.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                RuleTopicDetailView(topic: topic)
            } else {
                notFoundView
            }
        case .ruleScenario(let id):
            if let scenario = MockRulesGuideData.scenarios.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                RuleScenarioDetailView(scenario: scenario)
            } else {
                notFoundView
            }
        case .resource(let id):
            if let item = MockResourcesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                ResourceDetailView(item: item)
            } else {
                notFoundView
            }
        case .document(let id):
            if let item = documentStore.items.first(where: { $0.id == id }) {
                SavedDocumentDetailView(document: item)
            } else {
                notFoundView
            }
        case .placeDetail(let id):
            let audience = UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag) ?? .tourist
            if let place = DashboardPlacesData.detailPlace(id: id) {
                PlaceItemDetailView(
                    place: place,
                    relatedPlaces: DashboardPlacesData.visiblePlaces(
                        cityId: place.cityId,
                        audience: audience,
                        limit: nil
                    )
                )
            } else {
                notFoundView
            }
        case .calendarEvent(let id):
            if let event = DashboardCalendarData.detailEvent(id: id) {
                CalendarEventDetailView(event: event)
            } else {
                notFoundView
            }
        case .provinceList:
            ProvinceDirectoryView()
        case .cityList:
            CitiesDirectoryView()
        case .provinceDetail(let provinceName):
            if let province = ProvinceCatalog.provinceIfFound(matching: provinceName) {
                ProvinceCityDetailView(provinceName: province.id)
            } else {
                notFoundView
            }
        case .provinceCities(let provinceName):
            if let province = ProvinceCatalog.provinceIfFound(matching: provinceName) {
                ProvinceCitiesView(provinceName: province.id)
            } else {
                notFoundView
            }
        case .cityDetail(let province, let city):
            if let province = ProvinceCatalog.provinceIfFound(matching: province),
               let city = ProvinceCatalog.cityIfFound(named: city, provinceID: province.id) {
                CityDetailView(provinceName: province.id, cityName: city.name)
            } else {
                notFoundView
            }
        case .placeList(let city):
            HomeExploreListView(listID: "places", cityID: city)
        case .museumList(let city):
            HomeExploreListView(listID: "museums", cityID: city)
        case .natureList(let city):
            HomeExploreListView(listID: "nature", cityID: city)
        case .landmarkList(let city):
            HomeExploreListView(listID: "landmarks", cityID: city)
        case .eventList(let city):
            HomeExploreListView(listID: "events", cityID: city)
        case .restaurantList(let city):
            HomeExploreListView(listID: "restaurants", cityID: city)
        case .cafeList(let city):
            HomeExploreListView(listID: "cafes", cityID: city)
        case .discoveryList(let city, let type):
            HomeExploreListView(listID: type.rawValue, cityID: city)
        case .restaurantDetail(let city, let itemID):
            foodGuideDetail(city: city, itemID: itemID, allowedCategories: [.restaurant, .localFood, .market, .vegetarian, .budget, .fineDining])
        case .cafeDetail(let city, let itemID):
            foodGuideDetail(city: city, itemID: itemID, allowedCategories: [.cafe, .breakfast])
        case .housingSection(let type):
            TypedCategorySectionView(section: .housing(type))
        case .governmentSection(let type):
            TypedCategorySectionView(section: .government(type))
        case .transportSection(let type):
            TypedCategorySectionView(section: .transport(type))
        case .educationSection(let type):
            TypedCategorySectionView(section: .education(type))
        case .workSection(let type):
            TypedCategorySectionView(section: .work(type))
        case .healthSection(let type):
            TypedCategorySectionView(section: .health(type))
        case .leisureSection(let city, let type):
            switch type {
            case .nightlife:
                HomeExploreListView(listID: "nightlife", cityID: city)
            case .weekend:
                HomeExploreListView(listID: "weekend", cityID: city)
            case .family:
                HomeExploreListView(listID: "family-activities", cityID: city)
            case .architecture:
                HomeExploreListView(listID: "architecture", cityID: city)
            }

        case .checklistList:    ChecklistView()
        case .institutionsList: InstitutionsView()
        case .finesList:        FinesInfoView()
        case .lettersList:      LettersView()
        case .dutchTermsList:   DutchTermsView()
        case .searchList:       SearchListRoot()
        case .mistakesList:     MistakesLibraryView()
        case .beginnerGuidesList: BeginnerGuidesView()
        case .survivalHub: SurvivalNavigatorView()
        case .emotionalSupport: EmotionalSupportView()
        case .lgbtqSupport:
            if appState.selectedUserStatus?.personaTag == .lgbt {
                LGBTQSupportView()
            } else {
                notFoundView
            }
        case .mapHub: NearbyMapView()
        case .mapFocus(let focus): NearbyMapView(initialFocus: focus)
        case .assistantHub: AssistantHubRoot()
        case .informationHub: InformationHubView()
        case .firstSteps: FirstStepsView()
        case .knm:
            KNMGuideView()
        case .knmModule(let moduleID):
            if KNMGuideData.module(with: moduleID) != nil {
                KNMGuideView(initialModuleID: moduleID)
            } else {
                notFoundView
            }
        case .dutchA1A2:
            DutchA1A2View()
        case .dutchA1A2Module(let moduleID):
            if DutchA1A2CourseData.module(with: moduleID) != nil {
                DutchA1A2View(initialModuleID: moduleID)
            } else {
                notFoundView
            }
        case .practicalGuide(let topic):
            if topic == .transportBasics {
                TransportGuideView()
                    .accessibilityIdentifier("practicalGuide.\(topic.rawValue)")
            } else {
                PracticalGuideView(topic: topic)
                    .accessibilityIdentifier("practicalGuide.\(topic.rawValue)")
            }
        case .netherlandsOverview:
            NetherlandsOverviewView()
        case .nlCityDetail(let cityID):
            if let spotlight = ProvinceCatalog.citySpotlight(matching: cityID) {
                CityDetailView(provinceName: spotlight.province.id, cityName: spotlight.city.name)
            } else if let city = NLCity.all.first(where: { $0.id == cityID || $0.name.caseInsensitiveCompare(cityID) == .orderedSame }) {
                NetherlandsCityDetailView(city: city)
            } else {
                notFoundView
            }
        case .netherlandsHistory: NetherlandsHistoryView()
        case .cultureAttractions: CultureAttractionsView()
        case .netherlandsCalendar: NetherlandsCalendarView()
        case .settings: SettingsView()
        case .profileSelection: ProfileSelectionView()
        case .savedTopics: SavedTopicsView()
        case .recentlyViewedTopics: RecentlyViewedTopicsView()
        case .resourcesHub: ResourcesView()
        case .lifeTimeline: LifeTimelineView()
        case .documentVault: DocumentOrganizerView()
        case .deadlineCenter: DeadlineCenterView()
        case .verifiedExperts: VerifiedExpertsView()
        case .aiLetterGenerator: AILetterGeneratorView()
        case .discoverNetherlands: DiscoverNetherlandsView()
        case .localPartners: LocalPartnersView()
        case .localPartnerDetail(let id):
            if let partner = MockLocalPartnersData.partner(id: id) {
                LocalPartnerDetailView(partner: partner)
            } else {
                notFoundView
            }
        case .businessGrowth: BusinessGrowthView()
        case .businessLogin: BusinessLoginView()
        case .businessDashboard: BusinessDashboardView()
        case .finesAndLettersHub: FinesAndLettersHubView()
        case .legalHelp: LegalHelpView()
        case .officialSources: OfficialSourceDirectoryView()
        case .aboutYouNew: AboutYouNewView()
        case .supportFeedback: SupportFeedbackView()
        case .privacyDataControl: PrivacyDataControlView()
        case .termsOfUse: TermsOfUseView()
        case .legalDisclaimer: LegalDisclaimerView()
        case .journeyDocuments: DocumentOrganizerView()
        case .scamWarningsList:
            KNMGuideView(initialModuleID: "safety")
        case .scamWarning(let id):
            if let warning = MockScamWarningsData.items.first(where: { $0.id == id }) {
                ScamWarningDetailView(warning: warning)
            } else {
                notFoundView
            }

        case .governmentHub:  GovernmentHubView()
        case .helpHub:        HelpHubView()
        case .languageHub:    LanguageHubView()
        case .historyKNMHub:  HistoryKNMHubView()
        case .emergencyHub:   EmergencyHubView()
        case .categoriesHub:  CategoriesHubView()
        case .dutchHolidays:  DutchHolidaysView()
        case .dutchFigures:   GreatDutchFiguresView()
        case .dutchMonarchy:  DutchMonarchyView()
        case .guideSection(let id):
            if let section = GuideContent.section(id: id, activePersona: appState.selectedUserStatus?.personaTag, scope: accessScope) {
                GuideSectionView(section: section)
            } else {
                notFoundView
            }
        case .guideArticle(let sectionID, let articleID):
            if let (article, tint) = GuideContent.article(
                sectionID: sectionID,
                articleID: articleID,
                activePersona: appState.selectedUserStatus?.personaTag,
                scope: accessScope
            ) {
                GuideArticleView(article: article, sectionTint: tint)
            } else if sectionID == GuideContent.dataProjectSectionID,
                      let item = ContentRepository.shared.item(id: articleID),
                      item.status == .published {
                GuideArticleView(article: GuideContent.dataProjectArticle(from: item), sectionTint: .blue)
            } else {
                notFoundView
            }
        }
        }
    }

    private var notFoundView: some View {
        ReleaseRouteFallbackView(destination: destination, onPreview: nil)
    }

    @ViewBuilder
    private func foodGuideDetail(
        city: CityId,
        itemID: String,
        allowedCategories: Set<FoodGuideCategory>
    ) -> some View {
        let dashboardCity = CityDashboardContentData.city(for: city)
        let audience = UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag)
        if let item = CityDashboardContentData.foodGuideItems(for: dashboardCity, audience: audience, limit: nil)
            .first(where: { $0.id == itemID && allowedCategories.contains($0.category) }) {
            FoodGuideItemDetailView(item: item, city: dashboardCity)
        } else {
            notFoundView
        }
    }
}

private struct ReleaseRouteFallbackView: View {
    let destination: AppDestination
    let onPreview: (() -> Void)?
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var isHiddenForProfile: Bool {
        !RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: 18) {
                    compactHeader

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        if isHiddenForProfile {
                            if let onPreview {
                                Button(action: onPreview) {
                                    fallbackRow(
                                        title: previewTitle,
                                        subtitle: previewSubtitle,
                                        icon: "eye.fill",
                                        tint: AppColors.accent
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("profileGate.preview")
                            }

                            Button(action: goBack) {
                                fallbackRow(
                                    title: goBackTitle,
                                    subtitle: goBackSubtitle,
                                    icon: "chevron.left",
                                    tint: AppColors.textSecondary
                                )
                            }
                            .buttonStyle(.plain)

                            fallbackLink(
                                title: profileHomeTitle,
                                subtitle: profileHomeSubtitle,
                                icon: "person.crop.circle.badge.checkmark",
                                tint: AppColors.success,
                                destination: profileHomeDestination
                            )
                            fallbackLink(
                                title: profileSearchTitle,
                                subtitle: profileSearchSubtitle,
                                icon: AppIcons.search,
                                tint: AppColors.cyanGlow,
                                destination: .searchList
                            )
                        } else {
                            fallbackLink(
                                title: primaryLink.title,
                                subtitle: primaryLink.subtitle,
                                icon: primaryLink.icon,
                                tint: primaryLink.tint,
                                destination: primaryLink.destination
                            )
                            fallbackLink(
                                title: searchTitle,
                                subtitle: searchSubtitle,
                                icon: AppIcons.search,
                                tint: AppColors.cyanGlow,
                                destination: .searchList
                            )
                            fallbackLink(
                                title: guideTitle,
                                subtitle: guideSubtitle,
                                icon: AppIcons.checklist,
                                tint: AppColors.success,
                                destination: .firstSteps
                            )
                            fallbackLink(
                                title: sourcesTitle,
                                subtitle: sourcesSubtitle,
                                icon: AppIcons.officialSource,
                                tint: AppColors.dutchOrange,
                                destination: .officialSources
                            )
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
                .bottomTabSafeAreaPadding()
            }
        }
        .topChromeSafeAreaPadding()
        .appSceneBackground()
        .navigationTitle(navigationTitle)
        .nlNavigationInline()
    }

    private var compactHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: isHiddenForProfile ? "lock.circle.fill" : "arrow.triangle.branch")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isHiddenForProfile ? AppColors.warning : AppColors.cyanGlow)
                    .frame(width: 38, height: 38)
                    .background((isHiddenForProfile ? AppColors.warning : AppColors.cyanGlow).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(currentProfileLine)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(AppColors.card.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func fallbackLink(title: String, subtitle: String, icon: String, tint: Color, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            fallbackRow(title: title, subtitle: subtitle, icon: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }

    private func fallbackRow(title: String, subtitle: String, icon: String, tint: Color) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(14)
        .background(AppColors.cardElevated.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func goBack() {
        dismiss()
    }

    private var badge: String {
        if isHiddenForProfile {
            switch lang {
            case .russian: return "Профиль"
            case .dutch: return "Profiel"
            case .english: return "Profile"
            }
        }
        switch lang {
        case .russian: return "Маршрут"
        case .dutch: return "Route"
        case .english: return "Route"
        }
    }

    private var title: String {
        if isHiddenForProfile {
            switch lang {
            case .russian: return "Материал для другого профиля"
            case .dutch: return "Inhoud voor een ander profiel"
            case .english: return "Content for another profile"
            }
        }
        switch lang {
        case .russian: return "Продолжить"
        case .dutch: return "Verdergaan"
        case .english: return "Continue"
        }
    }

    private var subtitle: String {
        if isHiddenForProfile {
            switch lang {
            case .russian: return "Можно временно открыть материал только для чтения или изменить профиль."
            case .dutch: return "Bekijk de inhoud tijdelijk alleen-lezen of wijzig uw profiel."
            case .english: return "Preview it temporarily in read-only mode or change your profile."
            }
        }
        switch lang {
        case .russian: return "Ссылка ведёт к обновлённому разделу. Откройте ближайший рабочий раздел ниже."
        case .dutch: return "Deze link verwijst naar bijgewerkte inhoud. Open hieronder de beste actuele sectie."
        case .english: return "This link points to updated content. Open the best current section below."
        }
    }

    private var navigationTitle: String {
        if isHiddenForProfile {
            switch lang {
            case .russian: return "Недоступно"
            case .dutch: return "Niet beschikbaar"
            case .english: return "Not available"
            }
        }
        return title
    }

    private var currentProfileLine: String {
        switch lang {
        case .russian: return "Текущий профиль: \(activeProfileName)"
        case .dutch: return "Huidig profiel: \(activeProfileName)"
        case .english: return "Current profile: \(activeProfileName)"
        }
    }

    private var goBackTitle: String {
        switch lang {
        case .russian: return "Назад"
        case .dutch: return "Terug"
        case .english: return "Go back"
        }
    }

    private var previewTitle: String {
        localized(en: "Preview read-only", nl: "Alleen-lezen bekijken", ru: "Посмотреть без изменения профиля")
    }

    private var previewSubtitle: String {
        localized(
            en: "Your current profile stays unchanged. Check eligibility before acting.",
            nl: "Uw huidige profiel blijft ongewijzigd. Controleer eerst of dit voor u geldt.",
            ru: "Текущий профиль не изменится. Перед действиями проверьте применимость информации."
        )
    }

    private var goBackSubtitle: String {
        switch lang {
        case .russian: return "Вернуться к предыдущему экрану."
        case .dutch: return "Ga terug naar het vorige scherm."
        case .english: return "Return to the previous screen."
        }
    }

    private var profileHomeDestination: AppDestination {
        .profileSelection
    }

    private var activeProfileName: String {
        if let status = appState.selectedUserStatus {
            return status.localized(lang)
        }
        switch lang {
        case .russian: return "новичка"
        case .dutch: return "nieuwkomers"
        case .english: return "Newcomer"
        }
    }

    private var profileHomeTitle: String {
        switch lang {
        case .russian: return "Сменить профиль"
        case .dutch: return "Profiel wijzigen"
        case .english: return "Change profile"
        }
    }

    private var profileHomeSubtitle: String {
        switch lang {
        case .russian: return "Выберите другой сценарий пользователя."
        case .dutch: return "Kies een andere gebruikersroute."
        case .english: return "Choose a different user profile."
        }
    }

    private var profileSearchTitle: String {
        switch lang {
        case .russian: return "Поиск по профилю"
        case .dutch: return "Zoeken binnen profiel"
        case .english: return "Search within profile"
        }
    }

    private var profileSearchSubtitle: String {
        switch lang {
        case .russian: return "Результаты ограничены релевантными темами этого профиля."
        case .dutch: return "Resultaten blijven beperkt tot relevante onderwerpen voor dit profiel."
        case .english: return "Results stay limited to relevant topics for this profile."
        }
    }

    private var primaryLink: (title: String, subtitle: String, icon: String, tint: Color, destination: AppDestination) {
        switch destination {
        case .checklist, .beginnerGuide:
            return (
                guideTitle,
                guideSubtitle,
                AppIcons.checklist,
                AppColors.success,
                .firstSteps
            )
        case .dutchTerm:
            return (
                localized(en: "Dutch terms", nl: "Nederlandse termen", ru: "Нидерландские термины"),
                localized(en: "Common official words with plain explanations.", nl: "Officiële woorden met duidelijke uitleg.", ru: "Официальные слова с понятными объяснениями."),
                "text.book.closed.fill",
                AppColors.softBlue,
                .dutchTermsList
            )
        case .fineInfo, .ruleTopic, .ruleScenario:
            return (
                localized(en: "Rules and fines", nl: "Regels en boetes", ru: "Правила и штрафы"),
                localized(en: "Traffic, parking, public transport, documents, and common penalties.", nl: "Verkeer, parkeren, OV, documenten en veelvoorkomende boetes.", ru: "Транспорт, парковка, документы и частые штрафы."),
                "exclamationmark.triangle.fill",
                AppColors.dutchOrange,
                .finesList
            )
        case .institution:
            return (
                localized(en: "Government services", nl: "Overheidsdiensten", ru: "Государственные службы"),
                localized(en: "Municipality, IND, DUO, UWV, Belastingdienst, police, and legal help.", nl: "Gemeente, IND, DUO, UWV, Belastingdienst, politie en juridische hulp.", ru: "Gemeente, IND, DUO, UWV, Belastingdienst, полиция и юрпомощь."),
                "building.columns.fill",
                AppColors.cyanGlow,
                .governmentHub
            )
        case .searchAnswer:
            return (
                searchTitle,
                searchSubtitle,
                AppIcons.search,
                AppColors.cyanGlow,
                .searchList
            )
        case .letter, .document:
            return (
                localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                localized(en: "Letters, forms, official source checks, and next actions.", nl: "Brieven, formulieren, broncontrole en vervolgstappen.", ru: "Письма, формы, проверка источников и следующие шаги."),
                "doc.text.fill",
                AppColors.softBlue,
                .journeyDocuments
            )
        case .mistake:
            return (
                localized(en: "Common mistakes", nl: "Veelgemaakte fouten", ru: "Частые ошибки"),
                localized(en: "Beginner mistakes and safer alternatives.", nl: "Beginnersfouten en veiligere alternatieven.", ru: "Ошибки новичков и безопасные альтернативы."),
                "lightbulb.fill",
                AppColors.warning,
                .mistakesList
            )
        case .resource:
            return (
                sourcesTitle,
                sourcesSubtitle,
                AppIcons.officialSource,
                AppColors.dutchOrange,
                .officialSources
            )
        case .nlCityDetail, .cityDetail:
            return (
                localized(en: "Cities", nl: "Steden", ru: "Города"),
                localized(en: "Open the city directory and choose the current city page.", nl: "Open de stedengids en kies de actuele stadspagina.", ru: "Откройте список городов и выберите актуальную страницу."),
                "building.2.fill",
                AppColors.softBlue,
                .cityList
            )
        case .guideSection, .guideArticle, .workSection, .healthSection:
            return (
                localized(en: "Guide sections", nl: "Gidssecties", ru: "Разделы гида"),
                localized(en: "Open the organized category hub.", nl: "Open de georganiseerde categoriehub.", ru: "Откройте упорядоченные категории."),
                "square.grid.2x2.fill",
                AppColors.success,
                .categoriesHub
            )
        default:
            return (
                localized(en: "Guide and support", nl: "Gids en hulp", ru: "Гид и поддержка"),
                localized(en: "Open the main information hub.", nl: "Open de hoofdgids.", ru: "Откройте главный информационный раздел."),
                AppIcons.info,
                AppColors.cyanGlow,
                .informationHub
            )
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private var searchTitle: String {
        switch lang {
        case .russian: return "Искать в приложении"
        case .dutch: return "Zoeken in de app"
        case .english: return "Search the app"
        }
    }

    private var searchSubtitle: String {
        switch lang {
        case .russian: return "Найдите город, документ, услугу или официальный ответ."
        case .dutch: return "Vind een stad, document, dienst of officieel antwoord."
        case .english: return "Find a city, document, service, or official answer."
        }
    }

    private var guideTitle: String {
        switch lang {
        case .russian: return "Первые шаги"
        case .dutch: return "Eerste stappen"
        case .english: return "First steps"
        }
    }

    private var guideSubtitle: String {
        switch lang {
        case .russian: return "Регистрация, DigiD, страховка, транспорт и жилье."
        case .dutch: return "Registratie, DigiD, zorgverzekering, vervoer en wonen."
        case .english: return "Registration, DigiD, insurance, transport, and housing."
        }
    }

    private var sourcesTitle: String {
        switch lang {
        case .russian: return "Официальные источники"
        case .dutch: return "Officiele bronnen"
        case .english: return "Official sources"
        }
    }

    private var sourcesSubtitle: String {
        switch lang {
        case .russian: return "Проверенные сайты правительства, муниципалитетов и служб."
        case .dutch: return "Geverifieerde websites van overheid, gemeenten en diensten."
        case .english: return "Verified government, municipality, and service websites."
        }
    }
}

private struct AssistantHubRoot: View {
    @State private var assistantPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $assistantPath) {
            AIAssistantView(
                mapToolDestination: .mapHub,
                onOpenMap: { },
                onNavigate: { assistantPath.append($0) }
            )
            .navigationDestination(for: AppDestination.self) { AppDestinationView(destination: $0) }
        }
    }
}

private struct SearchListRoot: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        SearchView(viewModel: viewModel)
            .onAppear {
                viewModel.activePersona = appState.selectedUserStatus?.personaTag
                viewModel.personaSearchScope = .currentAndUniversal
            }
            .onChange(of: appState.selectedUserStatus) { _, status in
                viewModel.activePersona = status?.personaTag
            }
    }
}

private struct ScamWarningDetailView: View {
    let warning: ScamWarning
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Label {
                        Text(warning.category.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                    } icon: {
                        Image(systemName: warning.category.systemImageName)
                            .foregroundStyle(AppColors.accent)
                    }
                    Text(warning.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.top, AppSpacing.medium)

                infoSection(
                    icon: "info.circle.fill",
                    title: lang == .russian ? "Как это работает" : lang == .dutch ? "Hoe het werkt" : "How it works",
                    body: warning.howItWorks
                )

                if !warning.warningSignals.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Label(
                            lang == .russian ? "Признаки мошенничества" : lang == .dutch ? "Waarschuwingssignalen" : "Warning signals",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.warning)

                        ForEach(warning.warningSignals, id: \.self) { signal in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.warning)
                                    .font(.system(size: 14))
                                    .padding(.top, 2)
                                Text(signal)
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                        }
                    }
                    .padding(AppSpacing.medium)
                    .background(AppColors.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                }

                infoSection(
                    icon: "checkmark.shield.fill",
                    title: lang == .russian ? "Что делать" : lang == .dutch ? "Wat te doen" : "What to do",
                    body: warning.whatToDo
                )

                infoSection(
                    icon: "building.columns.fill",
                    title: lang == .russian ? "Куда сообщить" : lang == .dutch ? "Melden bij" : "Report to",
                    body: warning.reportTo
                )

                if let url = warning.reportURL {
                    Link(destination: url) {
                        Label(
                            lang == .russian ? "Сообщить онлайн" : lang == .dutch ? "Online melden" : "Report online",
                            systemImage: "arrow.up.right.square"
                        )
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.screenHorizontal)
        }
        .appSceneBackground(.general)
        .navigationTitle(warning.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func infoSection(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(body)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.medium)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 12))
    }
}
