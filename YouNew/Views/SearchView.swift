import SwiftUI
import Combine

private enum Layout {
    static let xSmall: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let screenHorizontal: CGFloat = 18
    static let sectionGap: CGFloat = 24
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @Environment(\.openURL) private var openURL
    @State private var invalidLinkMessage: String?
    @State private var directResultsCache: [InformationSearchResult] = []
    @State private var directResultsTask: Task<Void, Never>?
    @FocusState private var isSearchFocused: Bool

    private var lang: AppLanguage { languageManager.appLanguage }
    private var mapSuggestionCategory: PlaceCategory? {
        let q = viewModel.query.lowercased()
        if q.contains("gemeente") || q.contains("муницип") { return .municipality }
        if q.contains("аптек") || q.contains("pharmacy") { return .pharmacy }
        if q.contains("больниц") || q.contains("hospital") { return .healthcare }
        if q.contains("юрид") || q.contains("legal") { return .legalHelp }
        if q.contains("транспорт") || q.contains("transport") { return .transport }
        return nil
    }
    private var mapSuggestionFocus: MapFocus? {
        guard let mapSuggestionCategory else { return nil }
        switch mapSuggestionCategory {
        case .transport, .transportOffice, .bikeRepair:
            return .transport
        case .healthcare, .hospital, .huisarts, .pharmacy, .nightPharmacy:
            return .healthcare
        case .municipality, .ind, .uwv, .immigrationSupport, .expatCenter, .legalHelp, .police:
            return .government
        case .education, .duo, .studentHelp, .library, .communitySupport:
            return .education
        default:
            return nil
        }
    }
    private var mapSuggestionDestination: AppDestination? {
        guard let mapSuggestionFocus else { return nil }
        let destination = AppDestination.mapFocus(mapSuggestionFocus)
        return RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag) ? destination : nil
    }

    init(viewModel: SearchViewModel, initialQuery: String = "") {
        self.viewModel = viewModel
        if !initialQuery.isEmpty {
            viewModel.setQuery(initialQuery)
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                ResponsiveContentContainer(maxWidth: 920) {
                    LazyVStack(alignment: .leading, spacing: Layout.sectionGap) {
                        Color.clear
                            .frame(height: 0)
                            .id("searchTop")

                        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            searchSharedHeroSurface
                            suggestedSearchesSection
                        }

                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xSmall) {
                        searchFilterChip(title: L10n.t("common.all", lang), selected: viewModel.selectedCategory == nil) {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(viewModel.visibleCategories) { category in
                            searchFilterChip(title: category.localized(lang), selected: viewModel.selectedCategory == category) {
                                viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                if let mapSuggestionCategory, let mapSuggestionDestination {
                    NavigationLink(value: mapSuggestionDestination) {
                        InfoCard(
                            title: L10n.t("search.map_suggestion_title", lang),
                            subtitle: mapSuggestionCategory.localized(lang),
                            detail: L10n.t("search.map_suggestion_detail", lang),
                            icon: "map.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if !viewModel.recentSearches.isEmpty {
                        SectionHeader(title: L10n.t("search.recent", lang))
                        ForEach(viewModel.recentSearches.prefix(4), id: \.self) { recent in
                            Button {
                                viewModel.setQuery(recent)
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(AppColors.textTertiary)
                                    Text(recent)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.textTertiary)
                                }
                                .appCardStyle()
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SectionHeader(title: L10n.t("search.popular", lang))
                    ForEach(viewModel.popularQuestions.prefix(4)) { answer in
                        NavigationLink(value: AppDestination.searchAnswer(answer.id)) {
                            resultCard(answer: answer)
                        }
                        .buttonStyle(.plain)
                    }

                    if let selectedCategory = viewModel.selectedCategory {
                        SectionHeader(title: String(format: L10n.t("search.category_answers", lang), selectedCategory.localized(lang)))
                        ForEach(Array(viewModel.displayedResults.enumerated()), id: \.element.id) { index, answer in
                            resultRow(answer: answer, exposesPrimaryIdentifier: index == 0)
                        }
                    }

                    SectionHeader(title: L10n.t("beginner.guides.title", lang))
                    ForEach(viewModel.beginnerGuidePopular.prefix(3)) { item in
                        beginnerGuideRow(item)
                    }
                } else {
                    if !directResultsCache.isEmpty {
                        SectionHeader(
                            title: directResultsTitle,
                            subtitle: resultCountText(directResultsCache.count)
                        )
                        ForEach(Array(directResultsCache.enumerated()), id: \.element.id) { index, result in
                            if let externalURL = result.externalURL {
                                Button {
                                    openOfficialSource(externalURL)
                                } label: {
                                    directResultCard(result)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier(index == 0 ? "search.result.card" : "search.directResult.button.\(result.id)")
                            } else {
                                NavigationLink(value: result.destination) {
                                    directResultCard(result)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier(index == 0 ? "search.result.card" : "search.directResult.link.\(result.id)")
                            }
                        }
                    }

                    if viewModel.displayedResults.isEmpty && directResultsCache.isEmpty {
                        noResultsState
                    } else if !viewModel.displayedResults.isEmpty {
                        SectionHeader(
                            title: L10n.t("search.results", lang),
                            subtitle: resultCountText(viewModel.displayedResults.count)
                        )
                        ForEach(Array(viewModel.displayedResults.enumerated()), id: \.element.id) { index, answer in
                            resultRow(answer: answer, exposesPrimaryIdentifier: directResultsCache.isEmpty && index == 0)
                        }
                    }

                    if !viewModel.beginnerGuideResults.isEmpty {
                        SectionHeader(
                            title: L10n.t("beginner.guides.title", lang),
                            subtitle: resultCountText(viewModel.beginnerGuideResults.count)
                        )
                        ForEach(viewModel.beginnerGuideResults.prefix(6)) { item in
                            beginnerGuideRow(item)
                        }
                    }
                }

                AIAskButton(
                    title: searchAITitle,
                    context: AIContextBuilder.searchContext(
                        query: viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : viewModel.query,
                        language: lang,
                        appState: appState
                    ),
                    prompt: searchAIPrompt
                )

                if let invalidLinkMessage {
                    Text(invalidLinkMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(Color.red)
                        .appCardStyle()
                }

                    OutdatedInfoReportCard()

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, Layout.screenHorizontal)
                .padding(.top, Layout.small)
                .padding(.bottom, Layout.medium)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                pinnedSearchBar
            }
            .nlScrollDismissesKeyboardInteractively()
            .onReceive(router.searchScrollTop) { _ in
                isSearchFocused = false
                withAnimation(.easeInOut(duration: 0.24)) {
                    scrollProxy.scrollTo("searchTop", anchor: .top)
                }
            }
            .onChange(of: viewModel.query) { _, _ in
                scheduleDirectResultsRefresh()
                scrollToSearchTop(scrollProxy)
            }
            .onChange(of: viewModel.selectedCategory) { _, _ in
                refreshDirectResults()
                scrollToSearchTop(scrollProxy)
            }
        }
        .animation(AppAnimations.standard, value: viewModel.selectedCategory)
        .onAppear {
            viewModel.language = lang
            refreshDirectResults()
        }
        .onChange(of: lang) { _, newLanguage in
            viewModel.language = newLanguage
            refreshDirectResults()
        }
        .onDisappear {
            directResultsTask?.cancel()
        }
        .appSceneBackground(.search)
        .navigationTitle(L10n.t("search.nav_title", lang))
    }

    private var pinnedSearchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppSpacing.small) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.accentLight)
                    TextField(L10n.t("search.placeholder", lang), text: $viewModel.query)
                        .font(AppTypography.body)
                        .frame(minHeight: 44)
                        .submitLabel(.search)
                        .onSubmit {
                            isSearchFocused = false
                            viewModel.performSearch()
                        }
                        .autocorrectionDisabled(true)
                        .focused($isSearchFocused)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isSearchFocused = true
                        }
                        .accessibilityLabel(L10n.t("search.placeholder", lang))
                        .accessibilityIdentifier("search.input")
                    if !viewModel.query.isEmpty {
                        Button {
                            viewModel.query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textTertiary)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.t("common.clear", lang))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchFocused = true
                }
                .appInputStyle()

                Button {
                    isSearchFocused = false
                    viewModel.performSearch()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .accessibilityIdentifier("search.submit")
                .accessibilityLabel(L10n.t("common.search", lang))
            }
            .padding(.horizontal, Layout.screenHorizontal)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(AppColors.navyDeep)

            Rectangle()
                .fill(AppColors.stroke.opacity(0.35))
                .frame(height: 0.5)
        }
    }

    private var suggestedSearchesSection: some View {
        VStack(alignment: .leading, spacing: Layout.xSmall) {
            Text(suggestedSearchesTitle)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.textTertiary)
                .tracking(0.5)
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.xSmall) {
                    ForEach(Array(suggestedSearches.enumerated()), id: \.offset) { _, suggestion in
                        let applySuggestion = {
                            viewModel.setQuery(suggestion.query)
                            refreshDirectResults()
                            isSearchFocused = false
                        }

                        Button(action: applySuggestion) {
                            ProductTaskCard(
                                title: suggestion.title,
                                subtitle: suggestion.query,
                                symbol: suggestion.icon,
                                accent: searchAccent(for: suggestion.query),
                                minHeight: 132
                            )
                            .frame(width: 240)
                        }
                        .buttonStyle(.plain)
                        .highPriorityGesture(TapGesture().onEnded(applySuggestion))
                        .accessibilityIdentifier("search.suggestion.\(suggestion.id)")
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var searchIntroCard: some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            GradientIconBadge(symbol: "checkmark.shield.fill", color: AppColors.cyanGlow, size: 54)

            VStack(alignment: .leading, spacing: 6) {
                Text(searchHeroTitle)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(searchHeroSubtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .appGlassCardStyle(padding: AppSpacing.medium, cornerRadius: AppCornerRadius.large, accent: AppColors.cyanGlow)
        .accessibilityIdentifier("search.intro.card")
    }

    private var searchSharedHeroSurface: some View {
        PremiumHeroSurface(
            title: searchHeroTitle,
            subtitle: searchHeroSubtitle,
            badge: searchHeroBadge,
            badgeSystemImage: "checkmark.shield.fill",
            asset: searchHeroAsset,
            language: lang,
            fallbackCategory: .search,
            accent: AppColors.cyanGlow,
            focalPoint: .center,
            accessibilityIdentifier: "search.premium.hero"
        )
    }

    private var noResultsState: some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            VisualEmptyState(
                title: L10n.t("search.no_results", lang),
                detail: noResultsHelpText,
                symbol: "questionmark.text.page.fill",
                accent: AppColors.accentBlue,
                suggestedActions: suggestedSearches.prefix(4).map(\.title)
            )
            suggestedSearchesSection
            noResultsRecoverySection
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("search.no_results")
    }

    private var noResultsRecoverySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: noResultsRecoveryTitle, subtitle: noResultsRecoverySubtitle)

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(noResultsRecoveryActions) { action in
                    NavigationLink(value: action.destination) {
                        SearchRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("search.no_results.action.\(action.id)")
                }
            }
        }
    }

    private func resultCard(answer: SearchAnswer) -> some View {
        let sourceDomain = answer.officialSourceURL.host ?? answer.officialSourceURL.absoluteString
        return PremiumImageCard(
            title: answer.localizedQuestion(lang),
            subtitle: answer.localizedShortAnswer(lang),
            asset: searchAsset(for: answer.category),
            language: lang,
            symbol: searchSymbol(for: answer.category),
            accent: searchAccent(for: answer.category),
            fallbackCategory: searchFallbackCategory(for: answer.category)
        ) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppSpacing.xSmall) {
                    searchCategoryBadge(for: answer)
                    searchTrustBadge(for: answer)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    searchCategoryBadge(for: answer)
                    searchTrustBadge(for: answer)
                }
            }
        }
        .accessibilityLabel("\(answer.localizedQuestion(lang)), \(answer.officialSourceName), \(sourceDomain), \(answer.lastUpdated.formattedForAppLanguage(lang))")
    }

    private func searchCategoryBadge(for answer: SearchAnswer) -> some View {
        PremiumBadge(
            text: answer.category.localized(lang),
            systemImage: searchSymbol(for: answer.category),
            color: searchAccent(for: answer.category)
        )
    }

    private func searchTrustBadge(for answer: SearchAnswer) -> some View {
        PremiumBadge(
            text: answer.isOfficialSource ? L10n.t("search.official_source", lang) : L10n.t("search.trusted_source", lang),
            systemImage: answer.isOfficialSource ? "checkmark.shield.fill" : "info.circle.fill",
            color: answer.isOfficialSource ? AppColors.success : AppColors.warning
        )
    }

    private func refreshDirectResults() {
        directResultsTask?.cancel()
        directResultsCache = buildDirectResults()
    }

    private func scheduleDirectResultsRefresh() {
        directResultsTask?.cancel()

        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            directResultsCache = []
            return
        }

        directResultsTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 140_000_000)
            guard !Task.isCancelled else { return }
            directResultsCache = buildDirectResults()
        }
    }

    private func buildDirectResults() -> [InformationSearchResult] {
        let q = viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else { return [] }
        let normalized = q.lowercased()
        let allowsKNMResults = matches(normalized, knmSearchAliases)
        let selectedCategory = viewModel.selectedCategory ?? directIntentCategory(for: normalized)
        var results: [InformationSearchResult] = []

        if let essentialResult = essentialDirectResult(for: normalized, selectedCategory: selectedCategory) {
            results.append(essentialResult)
        }

        if selectedCategory == nil || selectedCategory == .general {
            results += viewModel.netherlandsResults.compactMap(netherlandsResult)
        }

        for section in InformationArchitecture.canonicalSections
            where shouldSearchIASection(section, selectedCategory: selectedCategory) &&
            matches(normalized, iaSectionSearchValues(section)) {
            let destination = iaDestination(for: section)
            if RelatedContentEngine.isVisible(destination, for: appState.selectedUserStatus?.personaTag) {
                results.append(InformationSearchResult(
                    id: "ia-section-\(section.rawValue)",
                    type: localized(en: "Section", nl: "Sectie", ru: "Раздел"),
                    title: section.title(lang),
                    subtitle: iaSectionSubtitle(section),
                    icon: section.symbol,
                    tint: section.accent,
                    destination: destination,
                    externalURL: nil
                ))
            }
        }

        for topic in PracticalGuideTopic.allSearchable
            where selectedCategoryAllows(topic, selectedCategory: selectedCategory) &&
            matches(normalized, [guideTitle(topic), guideTypeLabel, topic.rawValue] + guideSearchAliases(topic)) {
            results.append(InformationSearchResult(
                id: "guide-\(topic.rawValue)",
                type: guideTypeLabel,
                title: guideTitle(topic),
                subtitle: guideSubtitle(topic),
                icon: guideIcon(topic),
                tint: AppColors.success,
                destination: .practicalGuide(topic)
            ))
        }

        if allowsKNMResults && selectedCategoryAllowsEducation(selectedCategory) {
            results.append(InformationSearchResult(
                id: "knm",
                type: knmTypeLabel,
                title: "KNM",
                subtitle: localized(en: "Knowledge of Dutch Society modules and practice questions.", nl: "Kennis van de Nederlandse Maatschappij met oefenvragen.", ru: "Знание нидерландского общества: модули и тренировка."),
                icon: "graduationcap.fill",
                tint: AppColors.cyanGlow,
                destination: .knm
            ))
        }

        if allowsKNMResults && selectedCategoryAllowsEducation(selectedCategory) {
            for module in KNMGuideData.modules where matches(normalized, [module.title.value(lang), module.summary.value(lang), module.id] + module.searchAliases) {
                results.append(InformationSearchResult(
                    id: "knm-\(module.id)",
                    type: knmTypeLabel,
                    title: module.title.value(lang),
                    subtitle: module.summary.value(lang),
                    icon: module.icon,
                    tint: module.accent.color,
                    destination: .knmModule(module.id)
                ))
            }
        }

        if shouldSearchDutchCourse(normalized, selectedCategory: selectedCategory) {
            results.append(InformationSearchResult(
                id: "dutch-a1-a2",
                type: dutchCourseTypeLabel,
                title: localized(en: "Dutch A1-A2", nl: "Nederlands A1-A2", ru: "Нидерландский A1-A2"),
                subtitle: localized(en: "Words, phrases, grammar, flashcards, and mini tests.", nl: "Woorden, zinnen, grammatica, flashcards en minitoetsen.", ru: "Слова, фразы, грамматика, карточки и мини-тесты."),
                icon: "text.book.closed.fill",
                tint: AppColors.emerald,
                destination: .dutchA1A2
            ))

            for module in DutchA1A2CourseData.modules where matches(normalized, [module.title.value(lang), module.summary.value(lang), module.id] + module.searchAliases + module.lessons.flatMap { lesson in
                [lesson.title.value(lang), lesson.explanation.value(lang)] + lesson.vocabulary.flatMap { [$0.nl, $0.ru, $0.en ?? ""] } + lesson.phrases.flatMap { [$0.nl, $0.ru, $0.en ?? ""] }
            }) {
                results.append(InformationSearchResult(
                    id: "dutch-a1-a2-\(module.id)",
                    type: dutchCourseTypeLabel,
                    title: module.title.value(lang),
                    subtitle: module.summary.value(lang),
                    icon: module.icon,
                    tint: AppColors.emerald,
                    destination: .dutchA1A2Module(module.id)
                ))
            }
        }

        if shouldSearchCultureArticles(normalized, selectedCategory: selectedCategory) {
            for article in (MockNetherlandsUnderstandingData.cultureArticles + MockNetherlandsUnderstandingData.attractionArticles) where matches(normalized, [article.title.value(lang), article.summary.value(lang)] + article.tags + article.relatedPlaceIds) {
                results.append(InformationSearchResult(
                    id: "article-\(article.id)",
                    type: article.type == .attraction ? attractionTypeLabel : articleTypeLabel,
                    title: article.title.value(lang),
                    subtitle: article.summary.value(lang),
                    icon: article.symbol,
                    tint: article.type == .attraction ? AppColors.dutchOrange : AppColors.emerald,
                    destination: .cultureAttractions
                ))
            }
        }

        let selectedAudience = UserContentCategory.from(persona: appState.selectedUserStatus?.personaTag) ?? .tourist
        let selectedCity = CityDashboardContentData.city(for: appState.selectedCity)
        if shouldSearchCityPlanning(selectedCategory) {
            let travelLinks = CityDashboardContentData.travelLinks(for: selectedCity)
                .filter { travelLinkIsVisible($0, city: selectedCity, audience: selectedAudience, selectedCategory: selectedCategory) }

            for link in travelLinks where matches(normalized, travelLinkSearchValues(link, city: selectedCity)) {
                let result = searchResult(for: link, city: selectedCity)
                if !results.contains(where: { $0.id == result.id }) {
                    results.append(result)
                }
            }

            let foodGuide = CityDashboardContentData.foodGuideItems(for: selectedCity, audience: selectedAudience, limit: nil)
                .filter { foodGuideSearchCategoryAllows($0, selectedCategory: selectedCategory) }
            for item in foodGuide where matches(normalized, foodGuideSearchValues(item, city: selectedCity)) {
                let result = searchResult(for: item)
                if !results.contains(where: { $0.id == result.id }) {
                    results.append(result)
                }
            }
        }

        let places = DashboardPlacesData.visiblePlaces(cityId: selectedCity.name, audience: selectedAudience, limit: nil)
        for place in places where shouldSearchPlaces(selectedCategory) && matches(normalized, [place.title, place.shortTitle ?? "", place.description, place.cityId, place.address ?? "", "places", "visit", "museum", "museums", "landmark", "park", "attraction", "attractions", "places to visit"] + place.category.map(\.rawValue)) {
            results.append(InformationSearchResult(
                id: "visit-place-\(place.id)",
                type: localized(en: "Places", nl: "Plekken", ru: "Места"),
                title: place.title,
                subtitle: place.description,
                icon: place.primaryCategory.symbol,
                tint: place.primaryCategory.accent,
                destination: place.destination,
                externalURL: nil
            ))
        }

        let events = DashboardCalendarData.upcomingEvents(cityId: selectedCity.name, audience: selectedAudience, limit: nil)
        for event in events where shouldSearchCalendar(selectedCategory) && matches(normalized, [event.title, event.localTitle ?? "", event.description ?? "", event.impact ?? "", "holiday", "holidays", "calendar", "event", "events", "public holiday", "king day", "kings day"]) {
            results.append(InformationSearchResult(
                id: "calendar-event-\(event.id)",
                type: localized(en: "Calendar", nl: "Kalender", ru: "Календарь"),
                title: event.title,
                subtitle: event.impact ?? event.type.title(lang),
                icon: event.type.symbol,
                tint: event.type.accent,
                destination: .calendarEvent(event.id),
                externalURL: nil
            ))
        }

        let activePersona = appState.selectedUserStatus?.personaTag
        return Array(results
            .filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
            .prefix(8))
    }

    private func directIntentCategory(for normalized: String) -> SearchCategory? {
        if matches(normalized, ["fine", "fines", "boete", "boetes", "cjib", "traffic ticket", "penalty", "штраф", "штрафы"]) {
            return .fines
        }
        if matches(normalized, dutchCourseSearchAliases) {
            return .education
        }
        if matches(normalized, knmSearchAliases) {
            return .education
        }
        return nil
    }

    private func essentialDirectResult(for normalized: String, selectedCategory: SearchCategory?) -> InformationSearchResult? {
        let categoryAllowsRegistration = selectedCategory == nil || selectedCategory == .registration || selectedCategory == .general
        if categoryAllowsRegistration,
           matches(normalized, ["bsn", "burgerservicenummer", "brp", "registration", "register address", "gemeente"]) {
            return InformationSearchResult(
                id: "essential-bsn-registration",
                type: localized(en: "Registration", nl: "Registratie", ru: "Регистрация"),
                title: localized(en: "BSN and municipality registration", nl: "BSN en gemeente-inschrijving", ru: "BSN и регистрация в gemeente"),
                subtitle: localized(en: "Register your address and check the official BSN steps.", nl: "Schrijf je adres in en controleer de officiële BSN-stappen.", ru: "Зарегистрируйте адрес и проверьте официальные шаги для BSN."),
                icon: "number.circle.fill",
                tint: AppColors.softBlue,
                destination: .practicalGuide(.municipalityRegistration),
                externalURL: nil
            )
        }

        let categoryAllowsDigiD = selectedCategory == nil || selectedCategory == .digid || selectedCategory == .general
        if categoryAllowsDigiD,
           matches(normalized, ["digid", "digital identity", "government login", "login"]) {
            return InformationSearchResult(
                id: "essential-digid-safety",
                type: localized(en: "DigiD", nl: "DigiD", ru: "DigiD"),
                title: localized(en: "DigiD safety", nl: "DigiD-veiligheid", ru: "DigiD и безопасность"),
                subtitle: localized(en: "Use official DigiD channels and protect your login.", nl: "Gebruik officiële DigiD-kanalen en bescherm je login.", ru: "Используйте официальные каналы DigiD и защищайте вход."),
                icon: "lock.shield.fill",
                tint: AppColors.violet,
                destination: .practicalGuide(.digidSafety),
                externalURL: nil
            )
        }

        return nil
    }

    private func shouldSearchCityPlanning(_ selectedCategory: SearchCategory?) -> Bool {
        selectedCategory == nil || selectedCategory == .general || selectedCategory == .housing || selectedCategory == .transport || selectedCategory == .emergency
    }

    private func shouldSearchIASection(_ section: IASection, selectedCategory: SearchCategory?) -> Bool {
        guard let selectedCategory else { return true }
        switch section {
        case .startHere, .places, .foodLifestyle, .calendarEvents, .aiAssistant:
            return selectedCategory == .general
        case .transport:
            return selectedCategory == .transport
        case .emergency:
            return selectedCategory == .emergency
        case .documentsGovernment:
            return [.registration, .digid, .taxes, .fines, .immigration].contains(selectedCategory)
        case .housing:
            return selectedCategory == .housing
        case .healthcare:
            return selectedCategory == .healthInsurance
        case .workStudy:
            return [.work, .education].contains(selectedCategory)
        }
    }

    private func iaDestination(for section: IASection) -> AppDestination {
        switch section {
        case .startHere:
            return .firstSteps
        case .places:
            return .mapFocus(.city(cityDashboardCityName))
        case .transport:
            return .practicalGuide(.transportBasics)
        case .emergency:
            return .emergencyHub
        case .documentsGovernment:
            return .journeyDocuments
        case .housing:
            return .practicalGuide(.housingBasics)
        case .healthcare:
            return .practicalGuide(.healthcareBasics)
        case .workStudy:
            return .institutionsList
        case .foodLifestyle:
            return .mapFocus(.city(cityDashboardCityName))
        case .calendarEvents:
            return .netherlandsCalendar
        case .aiAssistant:
            return .assistantHub
        }
    }

    private var cityDashboardCityName: String {
        CityDashboardContentData.city(for: appState.selectedCity).name
    }

    private func iaSectionSearchValues(_ section: IASection) -> [String] {
        switch section {
        case .startHere:
            return ["start", "first steps", "begin", "where to start", "начать", "первые шаги", "begin hier"]
        case .places:
            return ["places", "city guide", "map", "museum", "museums", "attractions", "места", "куда пойти", "plekken"]
        case .transport:
            return ["transport", "tram", "train", "bus", "metro", "bike", "fiets", "транспорт", "поезд"]
        case .emergency:
            return ["emergency", "112", "police", "ambulance", "urgent", "экстренно", "полиция", "noodhulp"]
        case .documentsGovernment:
            return ["documents", "government", "bsn", "digid", "gemeente", "ind", "official", "документы", "государство"]
        case .housing:
            return ["housing", "rent", "address", "deposit", "landlord", "жилье", "жильё", "huur", "wonen"]
        case .healthcare:
            return ["healthcare", "health insurance", "huisarts", "pharmacy", "doctor", "медицина", "страховка", "zorg"]
        case .workStudy:
            return ["work", "study", "student", "university", "job", "duo", "uwv", "работа", "учеба", "studie"]
        case .foodLifestyle:
            return ["food", "restaurant", "restaurants", "cafe", "cafes", "coffee", "lifestyle", "еда", "кафе"]
        case .calendarEvents:
            return ["calendar", "events", "holiday", "holidays", "king's day", "праздники", "события", "kalender"]
        case .aiAssistant:
            return ["ai", "assistant", "ask", "help me", "ai assistant", "ии", "ассистент"]
        }
    }

    private func iaSectionSubtitle(_ section: IASection) -> String {
        switch section {
        case .startHere:
            return localized(en: "First steps and the safest next action.", nl: "Eerste stappen en de veiligste volgende actie.", ru: "Первые шаги и безопасное следующее действие.")
        case .places:
            return localized(en: "City places, map, attractions, and local orientation.", nl: "Plekken, kaart, attracties en lokale oriëntatie.", ru: "Места, карта, достопримечательности и ориентация.")
        case .transport:
            return localized(en: "OV, cycling, routes, tickets, and transport rules.", nl: "OV, fietsen, routes, tickets en vervoersregels.", ru: "OV, велосипед, маршруты, билеты и правила.")
        case .emergency:
            return localized(en: "112, police, urgent healthcare, and crisis help.", nl: "112, politie, spoedzorg en crisishulp.", ru: "112, полиция, срочная медицина и кризисная помощь.")
        case .documentsGovernment:
            return localized(en: "BSN, DigiD, gemeente, IND, official letters, and sources.", nl: "BSN, DigiD, gemeente, IND, brieven en bronnen.", ru: "BSN, DigiD, gemeente, IND, письма и источники.")
        case .housing:
            return localized(en: "Rent, address, contracts, deposits, and housing safety.", nl: "Huur, adres, contracten, borg en woonveiligheid.", ru: "Аренда, адрес, договоры, депозит и безопасность жилья.")
        case .healthcare:
            return localized(en: "Insurance, huisarts, pharmacy, hospital, and urgent care.", nl: "Verzekering, huisarts, apotheek, ziekenhuis en spoedzorg.", ru: "Страховка, huisarts, аптека, больница и срочная помощь.")
        case .workStudy:
            return localized(en: "Work, student path, institutions, DUO, UWV, and rights.", nl: "Werk, studiepad, instellingen, DUO, UWV en rechten.", ru: "Работа, учеба, учреждения, DUO, UWV и права.")
        case .foodLifestyle:
            return localized(en: "Restaurants, cafes, markets, daily life, and city habits.", nl: "Restaurants, cafés, markten, dagelijks leven en stadsgewoonten.", ru: "Рестораны, кафе, рынки, быт и городские привычки.")
        case .calendarEvents:
            return localized(en: "Public holidays, events, closures, and city impacts.", nl: "Feestdagen, events, sluitingen en stedelijke impact.", ru: "Праздники, события, закрытия и влияние на город.")
        case .aiAssistant:
            return localized(en: "Ask with your city, profile, section, places, and calendar context.", nl: "Vraag met stad, profiel, sectie, plekken en kalendercontext.", ru: "Спросить с учетом города, профиля, раздела, мест и календаря.")
        }
    }

    private func shouldSearchPlaces(_ selectedCategory: SearchCategory?) -> Bool {
        selectedCategory == nil || selectedCategory == .general
    }

    private func shouldSearchCalendar(_ selectedCategory: SearchCategory?) -> Bool {
        selectedCategory == nil || selectedCategory == .general || selectedCategory == .transport || selectedCategory == .education
    }

    private func travelLinkIsVisible(_ link: TravelLinkItem, city: DashboardCity, audience: UserContentCategory, selectedCategory: SearchCategory?) -> Bool {
        guard link.cityId.caseInsensitiveCompare(city.id.rawValue) == .orderedSame else { return false }
        guard AppURL.validatedWebURL(link.url) != nil else { return false }
        guard link.audience.contains(audience) || link.audience.contains(.general) else { return false }

        switch link.kind {
        case .booking:
            return selectedCategory == nil || selectedCategory == .general || selectedCategory == .housing
        case .restaurants, .cafes, .places, .officialGuide:
            return selectedCategory == nil || selectedCategory == .general
        case .maps:
            return selectedCategory == nil || selectedCategory == .general || selectedCategory == .transport
        }
    }

    private func foodGuideSearchCategoryAllows(_ item: FoodGuideItem, selectedCategory: SearchCategory?) -> Bool {
        guard AppURL.validatedWebURL(item.externalUrl) != nil else { return false }
        guard item.cityId == CityDashboardContentData.city(for: appState.selectedCity).id else { return false }
        return selectedCategory == nil || selectedCategory == .general
    }

    private func travelLinkSearchValues(_ link: TravelLinkItem, city: DashboardCity) -> [String] {
        let cityName = city.name
        switch link.kind {
        case .booking:
            return [link.title, link.subtitle, "booking", "booking.com", "hotel", "hotels", "stay", "stays", "accommodation", "apartments", "hotels in \(cityName)", cityName]
        case .restaurants:
            return [link.title, link.subtitle, "restaurant", "restaurants", "food", "eat", "dinner", "lunch", "restaurants in \(cityName)", cityName]
        case .cafes:
            return [link.title, link.subtitle, "cafe", "cafes", "coffee", "breakfast", "coffee in \(cityName)", cityName]
        case .places:
            return [link.title, link.subtitle, "places", "visit", "museum", "museums", "landmarks", "attractions", "places in \(cityName)", cityName]
        case .officialGuide:
            return [link.title, link.subtitle, "official", "visitor", "guide", "city info", "tourism", cityName]
        case .maps:
            return [link.title, link.subtitle, "transport", "public transport", "routes", "tickets", "map", "maps", cityName]
        }
    }

    private func foodGuideSearchValues(_ item: FoodGuideItem, city: DashboardCity) -> [String] {
        var values = [item.title, item.shortTitle ?? "", item.description, item.query ?? "", item.category.rawValue, city.name]
        switch item.category {
        case .restaurant:
            values += ["restaurant", "restaurants", "food", "eat", "dinner", "lunch"]
        case .cafe:
            values += ["cafe", "cafes", "coffee", "breakfast"]
        case .breakfast:
            values += ["breakfast", "brunch", "coffee"]
        case .localFood:
            values += ["local food", "dutch food", "food"]
        case .market:
            values += ["market", "markets", "food market"]
        case .vegetarian:
            values += ["vegetarian", "vegan"]
        case .budget:
            values += ["budget", "cheap eats", "food"]
        case .fineDining:
            values += ["fine dining", "restaurant", "restaurants"]
        }
        return values
    }

    private func searchResult(for link: TravelLinkItem, city: DashboardCity) -> InformationSearchResult {
        let title: String
        switch link.kind {
        case .booking:
            title = localized(en: "Hotels in \(city.name)", nl: "Hotels in \(city.name)", ru: "Отели в \(city.name)")
        default:
            title = link.title
        }

        return InformationSearchResult(
            id: "travel-link-\(link.id)",
            type: link.kind == .booking ? "Booking.com" : localized(en: "Travel links", nl: "Reislinks", ru: "Travel links"),
            title: title,
            subtitle: link.subtitle,
            icon: link.kind.symbol,
            tint: link.kind.accent,
            destination: .officialSources,
            externalURL: link.url
        )
    }

    private func searchResult(for item: FoodGuideItem) -> InformationSearchResult {
        InformationSearchResult(
            id: "food-guide-\(item.id)",
            type: item.category == .cafe ? localized(en: "Cafés", nl: "Cafés", ru: "Кафе") : localized(en: "Food guide", nl: "Eetgids", ru: "Гид по еде"),
            title: item.title,
            subtitle: item.description,
            icon: item.icon,
            tint: foodGuideTint(item.category),
            destination: .officialSources,
            externalURL: item.externalUrl
        )
    }

    private func foodGuideTint(_ category: FoodGuideCategory) -> Color {
        switch category {
        case .restaurant, .fineDining: return AppColors.dutchOrange
        case .cafe, .breakfast: return AppColors.warning
        case .localFood, .market: return AppColors.emerald
        case .vegetarian: return AppColors.success
        case .budget: return AppColors.softBlue
        }
    }

    private func selectedCategoryAllows(_ topic: PracticalGuideTopic, selectedCategory: SearchCategory?) -> Bool {
        guard let selectedCategory else { return true }
        switch topic {
        case .firstStepsNetherlands, .officialSourcesChecklist, .bankingBasics:
            return selectedCategory == .general
        case .municipalityRegistration:
            return selectedCategory == .registration
        case .digidSafety:
            return selectedCategory == .digid
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics:
            return selectedCategory == .healthInsurance
        case .transportBasics:
            return selectedCategory == .transport
        case .housingBasics:
            return selectedCategory == .housing
        }
    }

    private func selectedCategoryAllowsEducation(_ selectedCategory: SearchCategory?) -> Bool {
        selectedCategory == nil || selectedCategory == .education
    }

    private func shouldSearchDutchCourse(_ normalized: String, selectedCategory: SearchCategory?) -> Bool {
        guard selectedCategoryAllowsEducation(selectedCategory) else { return false }
        return matches(normalized, dutchCourseSearchAliases)
    }

    private func shouldSearchCultureArticles(_ normalized: String, selectedCategory: SearchCategory?) -> Bool {
        guard selectedCategory == nil || selectedCategory == .general else { return false }
        return normalized.count >= 4
    }

    private func netherlandsResult(_ result: NetherlandsSearchResult) -> InformationSearchResult? {
        switch result.kind {
        case .city:
            guard let city = result.city else { return nil }
            return InformationSearchResult(
                id: result.id,
                type: directTypeCity,
                title: city.name,
                subtitle: city.shortDescription,
                icon: "building.2.fill",
                tint: AppColors.softBlue,
                destination: .nlCityDetail(city.id)
            )
        case .province:
            guard let province = result.province else { return nil }
            return InformationSearchResult(
                id: result.id,
                type: directTypeProvince,
                title: province.name,
                subtitle: "\(province.capital) • \(province.population)",
                icon: "map.fill",
                tint: AppColors.routeLine,
                destination: .provinceDetail(province.id)
            )
        case .country:
            return InformationSearchResult(
                id: result.id,
                type: localized(en: "Country", nl: "Land", ru: "Страна"),
                title: localized(en: "Kingdom of the Netherlands", nl: "Koninkrijk der Nederlanden", ru: "Королевство Нидерланды"),
                subtitle: NetherlandsCountry.tagline,
                icon: "flag.fill",
                tint: AppColors.dutchOrange,
                destination: .netherlandsOverview
            )
        }
    }

    private func directResultCard(_ result: InformationSearchResult) -> some View {
        PremiumDirectResultCard(
            type: result.type,
            title: result.title,
            subtitle: result.subtitle,
            symbol: result.icon,
            asset: searchAsset(for: result.title + " " + result.subtitle),
            accent: result.tint,
            language: lang
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("search.directResult.card.\(result.id)")
    }

    private func matches(_ query: String, _ values: [String]) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedQuery.count >= 2 else { return false }

        return values.contains { rawValue in
            let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard value.count >= 2 else { return false }
            if value == normalizedQuery { return true }
            if normalizedQuery.count >= 3, value.contains(normalizedQuery) { return true }
            if value.count >= 3, normalizedQuery.contains(value) { return true }
            return false
        }
    }

    private func guideTitle(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return localized(en: "First steps in the Netherlands", nl: "Eerste stappen in Nederland", ru: "Первые шаги в Нидерландах")
        case .municipalityRegistration: return localized(en: "Municipality registration", nl: "Inschrijving bij gemeente", ru: "Регистрация в муниципалитете")
        case .healthcareBasics: return localized(en: "Healthcare basics", nl: "Basiszorg", ru: "Базовая медицина")
        case .findingHuisarts: return localized(en: "Find a huisarts", nl: "Huisarts vinden", ru: "Поиск huisarts")
        case .healthInsuranceBasics: return localized(en: "Health insurance", nl: "Zorgverzekering", ru: "Медицинская страховка")
        case .digidSafety: return localized(en: "DigiD safety", nl: "DigiD-veiligheid", ru: "DigiD и безопасность")
        case .transportBasics: return localized(en: "Transport in the Netherlands", nl: "Vervoer in Nederland", ru: "Транспорт в Нидерландах")
        case .housingBasics: return localized(en: "Housing basics", nl: "Wonen basis", ru: "Жильё")
        case .officialSourcesChecklist: return localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники")
        case .bankingBasics: return localized(en: "Banking basics", nl: "Bankieren", ru: "Банкинг")
        }
    }

    private func guideSubtitle(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return localized(en: "What to handle first after arrival.", nl: "Wat je eerst regelt na aankomst.", ru: "Что сделать первым после приезда.")
        case .municipalityRegistration: return localized(en: "Register your address and check BSN steps.", nl: "Schrijf je adres in en controleer BSN-stappen.", ru: "Зарегистрируйте адрес и проверьте BSN.")
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return localized(en: "Healthcare orientation with official source checks.", nl: "Zorgoriëntatie met officiële broncontrole.", ru: "Медицинская ориентация с проверкой источников.")
        case .digidSafety: return localized(en: "Use official DigiD safely.", nl: "Gebruik DigiD veilig.", ru: "Безопасно используйте DigiD.")
        case .transportBasics: return localized(en: "NS, OVpay, OV-chipkaart, buses, trams, metro, bikes, planners, and official sources.", nl: "NS, OVpay, OV-chipkaart, bus, tram, metro, fiets, planners en officiële bronnen.", ru: "NS, OVpay, OV-chipkaart, автобусы, трамваи, метро, велосипеды, планировщики и источники.")
        case .housingBasics: return localized(en: "Rental checks and registration permission.", nl: "Huurcontrole en inschrijfmogelijkheid.", ru: "Проверка аренды и регистрации.")
        case .officialSourcesChecklist: return localized(en: "Verify official domains before acting.", nl: "Controleer officiële domeinen.", ru: "Проверяйте официальные домены.")
        case .bankingBasics: return localized(en: "IBAN, payments, and secure banking.", nl: "IBAN, betalingen en veilig bankieren.", ru: "IBAN, платежи и безопасный банк.")
        }
    }

    private func guideIcon(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return AppIcons.checklist
        case .municipalityRegistration: return "person.badge.plus.fill"
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return "cross.case.fill"
        case .digidSafety: return "lock.shield.fill"
        case .transportBasics: return "tram.fill"
        case .housingBasics: return "house.lodge.fill"
        case .officialSourcesChecklist: return AppIcons.officialSource
        case .bankingBasics: return "creditcard.fill"
        }
    }

    private func guideSearchAliases(_ topic: PracticalGuideTopic) -> [String] {
        switch topic {
        case .firstStepsNetherlands:
            return ["arrival", "first steps", "newcomer", "moving to the netherlands", "start", "beginner"]
        case .municipalityRegistration:
            return ["bsn", "burgerservicenummer", "brp", "registration", "register address", "municipality", "gemeente", "personal records database"]
        case .healthcareBasics:
            return ["healthcare", "doctor", "huisarts", "gp", "pharmacy", "zorg"]
        case .findingHuisarts:
            return ["huisarts", "family doctor", "gp", "doctor registration", "health center"]
        case .healthInsuranceBasics:
            return ["health insurance", "zorgverzekering", "basic insurance", "premium", "own risk", "eigen risico"]
        case .digidSafety:
            return ["digid", "digital identity", "digital login", "activation code", "government login"]
        case .transportBasics:
            return TransportGuideData.guide.searchAliases + ["public transport", "ov-chipkaart", "ovpay", "ns", "9292", "train", "bus", "metro", "tram"]
        case .housingBasics:
            return ["housing", "rent", "huur", "rental contract", "deposit", "landlord", "tenant rights"]
        case .officialSourcesChecklist:
            return ["official source", "government.nl", "rijksoverheid", "verify source", "official website"]
        case .bankingBasics:
            return ["bank", "iban", "bank account", "payments", "debit card"]
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var noResultsRecoveryTitle: String {
        localized(en: "Try a practical route", nl: "Probeer een praktische route", ru: "Попробуйте практичный маршрут")
    }

    private var noResultsRecoverySubtitle: String {
        localized(
            en: "If the wording is unclear, start from source-labeled resources, nearby help, or documents.",
            nl: "Als de woorden niet duidelijk zijn, begin met betrouwbare bronnen, hulp dichtbij of documenten.",
            ru: "Если формулировка не сработала, начните с проверенных ресурсов, помощи рядом или документов."
        )
    }

    private var noResultsRecoveryActions: [SearchRecoveryAction] {
        [
            SearchRecoveryAction(
                id: "resources",
                title: L10n.t("resources.title", lang),
                subtitle: localized(en: "Browse trusted links by situation.", nl: "Bekijk betrouwbare links per situatie.", ru: "Откройте проверенные ссылки по ситуации."),
                icon: "books.vertical.fill",
                tint: AppColors.cyanGlow,
                destination: .resourcesHub
            ),
            SearchRecoveryAction(
                id: "official",
                title: L10n.t("settings.sources", lang),
                subtitle: localized(en: "Check government and official portals.", nl: "Controleer overheidssites en officiële portalen.", ru: "Проверьте государственные и официальные порталы."),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                destination: .officialSources
            ),
            SearchRecoveryAction(
                id: "nearby",
                title: "Places",
                subtitle: localized(en: "Find municipality, health, legal, and support places.", nl: "Vind gemeente, zorg, juridisch en hulp dichtbij.", ru: "Найдите gemeente, медицину, юридическую помощь и поддержку."),
                icon: "map.fill",
                tint: AppColors.softBlue,
                destination: .mapHub
            ),
            SearchRecoveryAction(
                id: "documents",
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Prepare letters, proof, and next-step notes.", nl: "Bereid brieven, bewijs en notities voor.", ru: "Подготовьте письма, подтверждения и заметки."),
                icon: "doc.text.fill",
                tint: AppColors.dutchOrange,
                destination: .journeyDocuments
            )
        ]
        .filter { RelatedContentEngine.isVisible($0.destination, for: appState.selectedUserStatus?.personaTag) }
    }

    @ViewBuilder
    private func resultRow(answer: SearchAnswer, exposesPrimaryIdentifier: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            NavigationLink(value: AppDestination.searchAnswer(answer.id)) {
                resultCard(answer: answer)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(exposesPrimaryIdentifier ? "search.result.card" : "search.result.card.\(answer.id)")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("search.result.link.\(answer.id)")

            Button {
                openOfficialSource(answer.officialSourceURL)
            } label: {
                Label(L10n.t("beginner.open_official_source", lang), systemImage: "arrow.up.right.square")
            }
            .buttonStyle(SecondaryPremiumButtonStyle())
            .accessibilityIdentifier("search.result.source.\(answer.id)")
        }
        .appGlassCardStyle(accent: answer.isOfficialSource ? AppColors.success : AppColors.warning)
        .accessibilityIdentifier("search.result.container.\(answer.id)")
    }

    private func searchFilterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(selected ? Color.white : AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? AppColors.accentLight : AppColors.glassSurfaceElevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? Color.clear : AppColors.stroke, lineWidth: 1))
        }
        .buttonStyle(AppPressableButtonStyle())
    }

    private func openOfficialSource(_ url: URL) {
        guard let safeURL = AppURL.validatedWebURL(url) else {
            invalidLinkMessage = L10n.t("search.invalid_link", lang)
            return
        }
        invalidLinkMessage = nil
        openURL(safeURL)
    }

    private func scrollToSearchTop(_ scrollProxy: ScrollViewProxy) {
        guard !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        withAnimation(.easeOut(duration: 0.18)) {
            scrollProxy.scrollTo("searchTop", anchor: .top)
        }
    }

    @ViewBuilder
    private func beginnerGuideRow(_ item: BeginnerGuideItem) -> some View {
        VStack(alignment: .leading, spacing: Layout.xSmall) {
            NavigationLink(value: AppDestination.beginnerGuide(item.id)) {
                HStack(alignment: .top, spacing: 12) {
                    PremiumImageHeader(
                        title: item.title(lang),
                        asset: guideAsset(for: item.category),
                        language: lang,
                        symbol: guideIcon(item.category),
                        accent: guideAccent(for: item.category),
                        height: 82,
                        width: 88,
                        cornerRadius: 18,
                        fallbackCategory: guideFallbackCategory(for: item.category)
                    )
                    .layoutPriority(0)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title(lang))
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                        Text(item.simpleAnswer(lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                        Text(String(format: L10n.t("search.official_source_named", lang), item.officialSourceName))
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.accent)
                            .lineLimit(1)
                    }
                    .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
            }
            .buttonStyle(.plain)

            if let sourceURL = item.officialSourceURL {
                Button {
                    openOfficialSource(sourceURL)
                } label: {
                    Label(L10n.t("beginner.open_official_source", lang), systemImage: "arrow.up.right.square")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
            }

            if !item.relatedTopics.isEmpty {
                Text(L10n.t("beginner.related_topics", lang) + ": " + item.relatedTopics.prefix(3).map { relatedTopicDisplayTitle($0) }.joined(separator: ", "))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                NavigationLink(value: AppDestination.searchList) {
                    Label(beginnerRelatedFallbackTitle, systemImage: "magnifyingglass")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("search.beginner.related.empty")
            }
        }
    }

    private var searchHeroAsset: AppImageAsset? {
        ContentArtworkRegistry.asset(for: .searchHero)
    }

    private var searchHeroTitle: String {
        localized(en: "Search the Netherlands with confidence", nl: "Zoek in Nederland met vertrouwen", ru: "Ищите по Нидерландам уверенно")
    }

    private var searchHeroSubtitle: String {
        localized(
            en: "Official answers, nearby help, documents, transport, housing, and city guidance in one verified place.",
            nl: "Officiële antwoorden, hulp dichtbij, documenten, vervoer, wonen en stadsgidsen op een betrouwbare plek.",
            ru: "Официальные ответы, помощь рядом, документы, транспорт, жильё и городские подсказки в одном месте."
        )
    }

    private var searchHeroBadge: String {
        localized(en: "Source-aware guidance", nl: "Bronbewuste gids", ru: "Навигация с учетом источников")
    }

    private func searchAsset(for category: SearchCategory) -> AppImageAsset? {
        switch category {
        case .healthInsurance:
            return ContentArtworkRegistry.asset(for: .searchHealthcare)
        case .work:
            return ContentArtworkRegistry.asset(for: .searchWork)
        case .housing:
            return ContentArtworkRegistry.asset(for: .searchHousing)
        case .transport:
            return ContentArtworkRegistry.asset(for: .searchTransport)
        case .emergency:
            return ContentArtworkRegistry.asset(for: .searchEmergency)
        case .registration, .digid, .immigration, .taxes, .fines:
            return ContentArtworkRegistry.asset(for: .searchRegistration)
        case .legalHelp:
            return ContentArtworkRegistry.asset(for: .searchLegal)
        case .education:
            return ContentArtworkRegistry.asset(for: .searchEducation)
        case .general:
            return searchHeroAsset
        }
    }

    private func guideAsset(for category: BeginnerGuideCategory) -> AppImageAsset? {
        switch category {
        case .identity, .municipality, .immigration, .taxes, .fines, .benefits:
            return ContentArtworkRegistry.asset(for: .searchRegistration)
        case .work:
            return ContentArtworkRegistry.asset(for: .searchWork)
        case .education:
            return ContentArtworkRegistry.asset(for: .searchEducation)
        case .healthcare, .health, .safety:
            return ContentArtworkRegistry.asset(for: .searchHealthcare)
        case .housing:
            return ContentArtworkRegistry.asset(for: .searchHousing)
        case .transport:
            return ContentArtworkRegistry.asset(for: .searchTransport)
        case .legalHelp:
            return ContentArtworkRegistry.asset(for: .searchLegal)
        case .dailyLife:
            return searchHeroAsset
        }
    }

    private func searchAsset(for query: String) -> AppImageAsset? {
        let value = query.lowercased()
        if value.contains("health") || value.contains("zorg") || value.contains("мед") { return ContentArtworkRegistry.asset(for: .searchHealthcare) }
        if value.contains("transport") || value.contains("train") || value.contains("ov") || value.contains("транспорт") { return ContentArtworkRegistry.asset(for: .searchTransport) }
        if value.contains("housing") || value.contains("rent") || value.contains("жиль") { return ContentArtworkRegistry.asset(for: .searchHousing) }
        if value.contains("work") || value.contains("job") || value.contains("работ") { return ContentArtworkRegistry.asset(for: .searchWork) }
        if value.contains("document") || value.contains("bsn") || value.contains("digid") || value.contains("док") { return ContentArtworkRegistry.asset(for: .searchRegistration) }
        if value.contains("legal") || value.contains("jurid") || value.contains("прав") { return ContentArtworkRegistry.asset(for: .searchLegal) }
        if value.contains("map") || value.contains("city") || value.contains("город") { return ContentArtworkRegistry.asset(for: .searchMap) }
        return searchHeroAsset
    }

    private func searchAccent(for category: SearchCategory) -> Color {
        switch category {
        case .healthInsurance: return AppColors.success
        case .work: return AppColors.softBlue
        case .housing: return AppColors.cyanGlow
        case .transport: return AppColors.routeLine
        case .emergency: return AppColors.dutchOrange
        case .registration, .digid, .immigration, .taxes, .fines, .legalHelp: return AppColors.violet
        case .education: return AppColors.accentLight
        case .general: return AppColors.accentBlue
        }
    }

    private func guideAccent(for category: BeginnerGuideCategory) -> Color {
        switch category {
        case .healthcare, .health, .safety:
            return AppColors.success
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .work:
            return AppColors.softBlue
        case .education:
            return AppColors.accentLight
        case .legalHelp, .fines:
            return AppColors.warning
        default:
            return AppColors.violet
        }
    }

    private func searchAccent(for query: String) -> Color {
        let value = query.lowercased()
        if value.contains("health") || value.contains("zorg") || value.contains("мед") { return AppColors.success }
        if value.contains("transport") || value.contains("train") || value.contains("ov") || value.contains("транспорт") { return AppColors.routeLine }
        if value.contains("housing") || value.contains("rent") || value.contains("жиль") { return AppColors.cyanGlow }
        if value.contains("work") || value.contains("job") || value.contains("работ") { return AppColors.softBlue }
        if value.contains("document") || value.contains("bsn") || value.contains("digid") || value.contains("док") { return AppColors.violet }
        return AppColors.accentBlue
    }

    private func searchFallbackCategory(for category: SearchCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .healthInsurance:
            return .healthcare
        case .work:
            return .work
        case .housing:
            return .housing
        case .transport:
            return .transport
        case .emergency:
            return .emergency
        case .registration, .digid, .immigration, .taxes, .fines:
            return .government
        case .legalHelp:
            return .documents
        case .education:
            return .dutchA1A2
        case .general:
            return .search
        }
    }

    private func guideFallbackCategory(for category: BeginnerGuideCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .identity, .fines, .legalHelp:
            return .documents
        case .municipality, .immigration, .taxes, .benefits:
            return .government
        case .work:
            return .work
        case .education:
            return .dutchA1A2
        case .healthcare, .health:
            return .healthcare
        case .housing:
            return .housing
        case .transport:
            return .transport
        case .safety:
            return .emergency
        case .dailyLife:
            return .integration
        }
    }

    private func searchSymbol(for category: SearchCategory) -> String {
        switch category {
        case .registration: return "person.badge.plus.fill"
        case .digid: return "lock.shield.fill"
        case .immigration: return "globe.europe.africa.fill"
        case .taxes: return "banknote.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .healthInsurance: return "cross.case.fill"
        case .work: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .housing: return "house.lodge.fill"
        case .transport: return "tram.fill"
        case .legalHelp: return "scale.3d"
        case .emergency: return "phone.badge.waveform.fill"
        case .general: return "magnifyingglass"
        }
    }

    private func guideIcon(_ category: BeginnerGuideCategory) -> String {
        switch category {
        case .identity: return "lock.shield.fill"
        case .municipality: return "building.columns.fill"
        case .immigration: return "globe.europe.africa.fill"
        case .work: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .healthcare, .health: return "cross.case.fill"
        case .housing: return "house.lodge.fill"
        case .transport: return "tram.fill"
        case .taxes: return "banknote.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .legalHelp: return "scale.3d"
        case .safety: return "checkmark.shield.fill"
        case .dailyLife: return "sparkles.rectangle.stack.fill"
        case .benefits: return "heart.text.square.fill"
        }
    }

    private func relatedTopicDisplayTitle(_ topic: String) -> String {
        let localizationKey = "beginner.topic.\(topic)"
        let localizedTitle = L10n.t(localizationKey, lang)

        if localizedTitle != localizationKey {
            return localizedTitle
        }

        return topic
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private func resultCountText(_ count: Int) -> String {
        String(format: L10n.t("search.found", lang), count)
    }

    private var suggestedSearchesTitle: String {
        switch lang {
        case .russian: return "Попробуйте"
        case .dutch: return "Probeer"
        case .english: return "Try searching"
        }
    }

    private var directResultsTitle: String {
        switch lang {
        case .russian: return "Разделы приложения"
        case .dutch: return "App-onderdelen"
        case .english: return "App results"
        }
    }

    private var directTypeCity: String {
        switch lang {
        case .russian: return "Город"
        case .dutch: return "Stad"
        case .english: return "City"
        }
    }

    private var directTypeProvince: String {
        switch lang {
        case .russian: return "Провинция"
        case .dutch: return "Provincie"
        case .english: return "Province"
        }
    }

    private var attractionTypeLabel: String {
        switch lang {
        case .russian: return "Достопримечательность"
        case .dutch: return "Attractie"
        case .english: return "Attraction"
        }
    }

    private var articleTypeLabel: String {
        switch lang {
        case .russian: return "Статья"
        case .dutch: return "Artikel"
        case .english: return "Article"
        }
    }

    private var guideTypeLabel: String {
        switch lang {
        case .russian: return "Гайд"
        case .dutch: return "Gids"
        case .english: return "Guide"
        }
    }

    private var knmTypeLabel: String {
        switch lang {
        case .russian: return "KNM"
        case .dutch: return "KNM"
        case .english: return "KNM"
        }
    }

    private var dutchCourseTypeLabel: String {
        switch lang {
        case .russian: return "Нидерландский"
        case .dutch: return "Nederlands"
        case .english: return "Dutch"
        }
    }

    private var beginnerRelatedFallbackTitle: String {
        switch lang {
        case .russian: return "Найти похожие темы"
        case .dutch: return "Zoek verwante onderwerpen"
        case .english: return "Find related topics"
        }
    }

    private var knmSearchAliases: [String] {
        [
            "knm", "kennis van de nederlandse maatschappij", "knowledge of dutch society",
            "знание нидерландского общества", "inburgering knm", "duo knm",
            "huisarts", "toeslagen", "gemeente", "112"
        ]
    }

    private var dutchCourseSearchAliases: [String] {
        [
            "dutch a1", "dutch a2", "dutch a1-a2", "dutch a1 a2",
            "nederlands a1", "nederlands a2", "nederlands a1-a2", "nederlands a1 a2",
            "нидерландский a1", "нидерландский a2", "нидерландский a1-a2", "нидерландский a1 a2", "afspraak", "gemeente",
            "huisarts", "trein", "ov-chipkaart", "werk", "huur", "verzekering",
            "de het", "hebben zijn", "separable verbs", "отделяемые глаголы",
            "слова", "грамматика", "woorden", "grammatica"
        ]
    }

    private var noResultsHelpText: String {
        switch lang {
        case .russian: return "Попробуйте более простые слова или выберите один из частых запросов ниже."
        case .dutch: return "Probeer eenvoudigere woorden of kies een veelgebruikte zoekopdracht hieronder."
        case .english: return "Try simpler words or choose one of the common searches below."
        }
    }

    private var suggestedSearches: [(id: String, title: String, query: String, icon: String)] {
        switch lang {
        case .russian:
            return [
                ("bsn", "BSN", "BSN", "number"),
                ("digid", "DigiD", "DigiD", "key.fill"),
                ("insurance", "Страховка", "медстраховка", "cross.case.fill"),
                ("knm", "KNM", "KNM", "graduationcap.fill"),
                ("dutch", "A1-A2", "нидерландский A1", "text.book.closed.fill"),
                ("fine", "Штраф", "штраф", "exclamationmark.triangle.fill"),
                ("letter", "Письмо gemeente", "письмо gemeente", "envelope.fill"),
                ("rent", "Аренда", "депозит аренда", "house.fill")
            ]
        case .dutch:
            return [
                ("bsn", "BSN", "BSN", "number"),
                ("digid", "DigiD", "DigiD", "key.fill"),
                ("insurance", "Zorgverzekering", "zorgverzekering", "cross.case.fill"),
                ("knm", "KNM", "KNM", "graduationcap.fill"),
                ("dutch", "A1-A2", "Nederlands A1", "text.book.closed.fill"),
                ("fine", "Boete", "boete", "exclamationmark.triangle.fill"),
                ("letter", "Gemeentebrief", "gemeente brief", "envelope.fill"),
                ("rent", "Huurwaarborg", "huur borg", "house.fill")
            ]
        case .english:
            return [
                ("bsn", "BSN", "BSN", "number"),
                ("digid", "DigiD", "DigiD", "key.fill"),
                ("insurance", "Health insurance", "health insurance", "cross.case.fill"),
                ("knm", "KNM", "KNM", "graduationcap.fill"),
                ("dutch", "A1-A2", "Dutch A1", "text.book.closed.fill"),
                ("fine", "Fine", "fine", "exclamationmark.triangle.fill"),
                ("letter", "Gemeente letter", "gemeente letter", "envelope.fill"),
                ("rent", "Rental deposit", "rental deposit", "house.fill")
            ]
        }
    }

    private var searchAITitle: String {
        switch lang {
        case .russian: return "Объяснить простыми словами"
        case .dutch: return "Leg eenvoudig uit"
        case .english: return "Explain in simple language"
        }
    }

    private var searchAIPrompt: String {
        let q = viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            switch lang {
            case .russian: return "Помогите мне найти то, что мне нужно как новоприбывшему."
            case .dutch: return "Help me vinden wat ik nodig heb als nieuwkomer."
            case .english: return "Help me find what I need as a newcomer."
            }
        }
        switch lang {
        case .russian: return "Объясните «\(q)» просто и покажите следующий шаг."
        case .dutch: return "Leg «\(q)» eenvoudig uit en laat de volgende stap zien."
        case .english: return "Explain «\(q)» simply and show the next step."
        }
    }
}

private struct InformationSearchResult: Identifiable {
    let id: String
    let type: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
    let externalURL: URL?

    init(
        id: String,
        type: String,
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        destination: AppDestination,
        externalURL: URL? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.destination = destination
        self.externalURL = externalURL
    }
}

private struct SearchRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct SearchRecoveryActionCard: View {
    let action: SearchRecoveryAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.tint,
            minHeight: 104
        )
    }
}

private extension PracticalGuideTopic {
    static let allSearchable: [PracticalGuideTopic] = [
        .firstStepsNetherlands,
        .municipalityRegistration,
        .digidSafety,
        .healthInsuranceBasics,
        .findingHuisarts,
        .transportBasics,
        .housingBasics,
        .officialSourcesChecklist,
        .bankingBasics
    ]
}
