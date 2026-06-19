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

                suggestedSearchesSection

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
                    VisualEmptyState(
                        title: L10n.t("search.empty_state", lang),
                        detail: noResultsHelpText,
                        symbol: "magnifyingglass.circle.fill",
                        accent: AppColors.accentBlue,
                        suggestedActions: suggestedSearches.prefix(4).map(\.title)
                    )

                    if !viewModel.recentSearches.isEmpty {
                        SectionHeader(title: L10n.t("search.recent", lang))
                        ForEach(viewModel.recentSearches, id: \.self) { recent in
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
                    ForEach(viewModel.popularQuestions) { answer in
                        NavigationLink(value: AppDestination.searchAnswer(answer.id)) {
                            resultCard(answer: answer)
                                .appCardStyle()
                        }
                        .buttonStyle(.plain)
                    }

                    if let selectedCategory = viewModel.selectedCategory {
                        SectionHeader(title: String(format: L10n.t("search.category_answers", lang), selectedCategory.localized(lang)))
                        ForEach(viewModel.displayedResults) { answer in
                            resultRow(answer: answer)
                        }
                    }

                    SectionHeader(title: L10n.t("beginner.guides.title", lang))
                    ForEach(viewModel.beginnerGuidePopular) { item in
                        beginnerGuideRow(item)
                    }
                } else {
                    if !directResultsCache.isEmpty {
                        SectionHeader(
                            title: directResultsTitle,
                            subtitle: resultCountText(directResultsCache.count)
                        )
                        ForEach(directResultsCache) { result in
                            NavigationLink(value: result.destination) {
                                directResultCard(result)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.displayedResults.isEmpty {
                        noResultsState
                    } else {
                        SectionHeader(
                            title: L10n.t("search.results", lang),
                            subtitle: resultCountText(viewModel.displayedResults.count)
                        )
                        ForEach(viewModel.displayedResults) { answer in
                            resultRow(answer: answer)
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
                .padding(.vertical, Layout.medium)
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
        .onChange(of: viewModel.query) { _, _ in
            scheduleDirectResultsRefresh()
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
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
                        .submitLabel(.search)
                        .onSubmit { viewModel.performSearch() }
                        .autocorrectionDisabled(true)
                        .focused($isSearchFocused)
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
                .appInputStyle()

                Button {
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
                        Button {
                            viewModel.setQuery(suggestion.query)
                        } label: {
                            Label(suggestion.title, systemImage: suggestion.icon)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppColors.glassSurfaceElevated)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppColors.stroke.opacity(0.80), lineWidth: 0.8))
                        }
                        .buttonStyle(AppPressableButtonStyle())
                        .accessibilityIdentifier("search.suggestion.\(suggestion.id)")
                    }
                }
                .padding(.vertical, 2)
            }
        }
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
        }
        .accessibilityIdentifier("search.no_results")
    }

    private func resultCard(answer: SearchAnswer) -> some View {
        let sourceDomain = answer.officialSourceURL.host ?? answer.officialSourceURL.absoluteString
        return VStack(alignment: .leading, spacing: Layout.xSmall) {
            Text(answer.localizedQuestion(lang))
                .font(AppTypography.cardTitle)
                .foregroundStyle(Color.primary)

            Text(answer.localizedShortAnswer(lang))
                .font(AppTypography.body)
                .foregroundStyle(Color.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text(answer.category.localized(lang))
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.accentLight)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(AppColors.accent.opacity(0.10))
                    .clipShape(Capsule())

                Text(answer.isOfficialSource
                     ? L10n.t("search.official_source", lang)
                     : L10n.t("search.trusted_source", lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(answer.isOfficialSource ? AppColors.success : AppColors.warning)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background((answer.isOfficialSource ? AppColors.success : AppColors.warning).opacity(0.10))
                    .clipShape(Capsule())
            }

            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.success)
                Text(answer.officialSourceName)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text(answer.lastUpdated.formattedForAppLanguage(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.secondary)
            }

            Text(sourceDomain)
                .font(AppTypography.metadata)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        let selectedCategory = viewModel.selectedCategory
        var results: [InformationSearchResult] = []

        if selectedCategory == nil || selectedCategory == .general {
            results += viewModel.netherlandsResults.compactMap(netherlandsResult)
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

        let activePersona = appState.selectedUserStatus?.personaTag
        return Array(results
            .filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
            .prefix(8))
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
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: result.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(result.tint)
                .frame(width: 40, height: 40)
                .background(result.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(result.type)
                    .font(AppTypography.metadata)
                    .foregroundStyle(result.tint)
                Text(result.title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                Text(result.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .appCardStyle()
    }

    private func matches(_ query: String, _ values: [String]) -> Bool {
        values.contains { $0.lowercased().contains(query) || query.contains($0.lowercased()) }
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
        case .officialSourcesChecklist: return localized(en: "Official sources", nl: "Officiele bronnen", ru: "Официальные источники")
        case .bankingBasics: return localized(en: "Banking basics", nl: "Bankieren", ru: "Банкинг")
        }
    }

    private func guideSubtitle(_ topic: PracticalGuideTopic) -> String {
        switch topic {
        case .firstStepsNetherlands: return localized(en: "What to handle first after arrival.", nl: "Wat je eerst regelt na aankomst.", ru: "Что сделать первым после приезда.")
        case .municipalityRegistration: return localized(en: "Register your address and check BSN steps.", nl: "Schrijf je adres in en controleer BSN-stappen.", ru: "Зарегистрируйте адрес и проверьте BSN.")
        case .healthcareBasics, .findingHuisarts, .healthInsuranceBasics: return localized(en: "Healthcare orientation with official source checks.", nl: "Zorgorientatie met officiele broncontrole.", ru: "Медицинская ориентация с проверкой источников.")
        case .digidSafety: return localized(en: "Use official DigiD safely.", nl: "Gebruik DigiD veilig.", ru: "Безопасно используйте DigiD.")
        case .transportBasics: return localized(en: "NS, OVpay, OV-chipkaart, buses, trams, metro, bikes, planners, and official sources.", nl: "NS, OVpay, OV-chipkaart, bus, tram, metro, fiets, planners en officiele bronnen.", ru: "NS, OVpay, OV-chipkaart, автобусы, трамваи, метро, велосипеды, планировщики и источники.")
        case .housingBasics: return localized(en: "Rental checks and registration permission.", nl: "Huurcontrole en inschrijfmogelijkheid.", ru: "Проверка аренды и регистрации.")
        case .officialSourcesChecklist: return localized(en: "Verify official domains before acting.", nl: "Controleer officiele domeinen.", ru: "Проверяйте официальные домены.")
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

    @ViewBuilder
    private func resultRow(answer: SearchAnswer) -> some View {
        VStack(alignment: .leading, spacing: Layout.small) {
            NavigationLink(value: AppDestination.searchAnswer(answer.id)) {
                resultCard(answer: answer)
            }
            .buttonStyle(.plain)

            Button {
                openOfficialSource(answer.officialSourceURL)
            } label: {
                Label(L10n.t("beginner.open_official_source", lang), systemImage: "arrow.up.right.square")
            }
            .buttonStyle(SecondaryPremiumButtonStyle())
        }
        .appGlassCardStyle(accent: answer.isOfficialSource ? AppColors.success : AppColors.warning)
        .accessibilityIdentifier("search.result.card")
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

    @ViewBuilder
    private func beginnerGuideRow(_ item: BeginnerGuideItem) -> some View {
        VStack(alignment: .leading, spacing: Layout.xSmall) {
            NavigationLink(value: AppDestination.beginnerGuide(item.id)) {
                VStack(alignment: .leading, spacing: Layout.xSmall) {
                    Text(item.title(lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(item.simpleAnswer(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(String(format: L10n.t("search.official_source_named", lang), item.officialSourceName))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.accent)
                }
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
            }
        }
        .appCardStyle()
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

    private var knmSearchAliases: [String] {
        [
            "knm", "kennis van de nederlandse maatschappij", "knowledge of dutch society",
            "знание нидерландского общества", "inburgering knm", "duo knm",
            "huisarts", "toeslagen", "gemeente", "112"
        ]
    }

    private var dutchCourseSearchAliases: [String] {
        [
            "dutch a1-a2", "dutch a1 a2", "nederlands a1-a2", "nederlands a1 a2",
            "нидерландский a1-a2", "нидерландский a1 a2", "afspraak", "gemeente",
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
