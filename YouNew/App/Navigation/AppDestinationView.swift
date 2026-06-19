import SwiftUI

struct AppDestinationView: View {
    let destination: AppDestination
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var documentStore: DocumentStore

    private var lang: AppLanguage { languageManager.appLanguage }

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
        if !RelatedContentEngine.isVisible(destination, for: activePersona) {
            notFoundView
        } else {
            switch destination {
        case .checklist(let id):
            if let item = appState.checklistItems.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                ChecklistItemDetailView(item: item)
            } else {
                notFoundView
            }
        case .dutchTerm(let id): 
            if let term = MockDutchTermsData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                DutchTermDetailView(term: term)
            } else {
                notFoundView
            }
        case .fineInfo(let id):
            if let fine = MockFineInfoData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
                FineInfoDetailView(item: fine)
            } else {
                notFoundView
            }
        case .institution(let name):
            if let institution = MockInstitutionsData.items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
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
            if let item = MockBeginnerGuidesData.items.first(where: { $0.id == id && $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }) {
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
            } else {
                PracticalGuideView(topic: topic)
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
        case .settings: SettingsView()
        case .profileSelection: ProfileSelectionView()
        case .savedTopics: SavedTopicsView()
        case .recentlyViewedTopics: RecentlyViewedTopicsView()
        case .resourcesHub: ResourcesView()
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
            if let section = GuideContent.section(id: id, activePersona: appState.selectedUserStatus?.personaTag) {
                GuideSectionView(section: section)
            } else {
                notFoundView
            }
        case .guideArticle(let sectionID, let articleID):
            if let (article, tint) = GuideContent.article(sectionID: sectionID, articleID: articleID, activePersona: appState.selectedUserStatus?.personaTag) {
                GuideArticleView(article: article, sectionTint: tint)
            } else {
                notFoundView
            }
        }
        }
    }

    private var notFoundView: some View {
        ReleaseRouteFallbackView(destination: destination)
    }
}

private struct ReleaseRouteFallbackView: View {
    let destination: AppDestination
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var isHiddenForProfile: Bool {
        !RelatedContentEngine.isVisible(destination, for: activePersona)
    }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    CategoryHeroVisual(
                        assetName: nil,
                        title: title,
                        subtitle: subtitle,
                        symbol: "arrow.triangle.branch",
                        badgeText: badge,
                        accent: AppColors.cyanGlow,
                        height: 188
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        if isHiddenForProfile {
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

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground()
        .navigationTitle(title)
        .nlNavigationInline()
    }

    private func fallbackLink(title: String, subtitle: String, icon: String, tint: Color, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
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
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .appCardStyle()
        }
        .buttonStyle(.plain)
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
            case .russian: return "Маршрут для профиля \(activeProfileName)"
            case .dutch: return "Route voor \(activeProfileName)"
            case .english: return "\(activeProfileName) route"
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
            case .russian: return "Откройте маршруты и поиск, отфильтрованные под выбранный профиль."
            case .dutch: return "Open routes en zoekresultaten die voor het gekozen profiel zijn gefilterd."
            case .english: return "Open routes and search results filtered for the selected profile."
            }
        }
        switch lang {
        case .russian: return "Ссылка ведёт к обновлённому разделу. Откройте ближайший рабочий раздел ниже."
        case .dutch: return "Deze link verwijst naar bijgewerkte inhoud. Open hieronder de beste actuele sectie."
        case .english: return "This link points to updated content. Open the best current section below."
        }
    }

    private var profileHomeDestination: AppDestination {
        activePersona == nil ? .searchList : .categoriesHub
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
        case .russian: return "Маршруты профиля"
        case .dutch: return "Profielroutes"
        case .english: return "Profile routes"
        }
    }

    private var profileHomeSubtitle: String {
        switch lang {
        case .russian: return "Перейдите к действиям, которые подходят выбранной жизненной ситуации."
        case .dutch: return "Ga naar acties die passen bij de gekozen levenssituatie."
        case .english: return "Go to actions that match the selected life situation."
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
        case .guideSection, .guideArticle:
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
    var body: some View {
        AIAssistantView(mapToolDestination: .mapHub) { }
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
