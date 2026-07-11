import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Netherlands History & Civic Learning View

struct NetherlandsHistoryView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var viewModel = NetherlandsUnderstandingViewModel()
    @State private var appeared = false
    @State private var showingSources = false
    @State private var expandedPeriodID: String?

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    headerSection

                    switch viewModel.state {
                    case .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.large)
                    case .loaded:
                        guidedHistorySection
                        if !viewModel.monarchyCards.isEmpty {
                            civicCardsSection(
                                title: CivicLearningSection.monarchy.title(lang),
                                symbol: CivicLearningSection.monarchy.symbol,
                                color: AppColors.dutchOrange,
                                cards: viewModel.monarchyCards
                            )
                        }
                        if !viewModel.politicsCards.isEmpty {
                            civicCardsSection(
                                title: CivicLearningSection.politics.title(lang),
                                symbol: CivicLearningSection.politics.symbol,
                                color: AppColors.violet,
                                cards: viewModel.politicsCards
                            )
                        }
                        if !viewModel.societyCards.isEmpty {
                            civicCardsSection(
                                title: CivicLearningSection.society.title(lang),
                                symbol: CivicLearningSection.society.symbol,
                                color: AppColors.emerald,
                                cards: viewModel.societyCards
                            )
                        }
                        if !viewModel.glossary.isEmpty {
                            glossarySection
                        }
                        if !viewModel.quiz.isEmpty {
                            quizSection
                        }
                        sourcesSection
                    case .empty:
                        historyEmptyDashboard
                    case .failed:
                        loadErrorView
                    }

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve + 36)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.documents)
        .navigationTitle(pageTitle)
        .nlNavigationInline()
        .sheet(isPresented: $showingSources) {
            NetherlandsHistorySourcesView(language: lang)
        }
        .task { await viewModel.load() }
        .onAppear {
            withAnimation(AppAnimations.cardReveal.delay(0.08)) { appeared = true }
        }
    }

    // MARK: - Error State

    private var loadErrorView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.warning)
                Text(loadErrorTitle)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Text(loadErrorMessage)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Task { await viewModel.load() }
            } label: {
                Label(loadErrorRetry, systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(AppColors.accent)
        }
        .appCardStyle()
    }

    private var loadErrorTitle: String {
        switch lang {
        case .russian: return "Не удалось загрузить"
        case .dutch:   return "Laden mislukt"
        case .english: return "Failed to load"
        }
    }

    private var loadErrorMessage: String {
        switch lang {
        case .russian: return "Проверьте подключение к интернету и попробуйте снова."
        case .dutch:   return "Controleer je internetverbinding en probeer opnieuw."
        case .english: return "Check your internet connection and try again."
        }
    }

    private var loadErrorRetry: String {
        switch lang {
        case .russian: return "Повторить"
        case .dutch:   return "Opnieuw proberen"
        case .english: return "Retry"
        }
    }

    // MARK: - Empty State

    private var historyEmptyDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppColors.cyanGlow)
                    .frame(width: 52, height: 52)
                    .background(AppColors.cyanGlow.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(localized(en: "Use connected history paths", nl: "Gebruik verbonden geschiedenispaden", ru: "Используйте связанные исторические маршруты"))
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(localized(en: "Retry loading, or continue through KNM, culture, Dutch terms, and official sources below.", nl: "Probeer opnieuw te laden of ga hieronder verder via KNM, cultuur, Nederlandse termen en officiële bronnen.", ru: "Повторите загрузку или продолжите через KNM, культуру, нидерландские термины и официальные источники ниже."))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                Task { await viewModel.retry() }
            } label: {
                Label(loadErrorRetry, systemImage: "arrow.clockwise")
                    .font(AppTypography.bodyStrong)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            .accessibilityIdentifier("history.empty.retry")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 10)], spacing: 10) {
                ForEach(historyEmptyActions) { action in
                    NavigationLink(value: action.destination) {
                        HistoryRecoveryActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("history.empty.action.\(action.id)")
                }
            }
        }
        .appCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("history.empty.dashboard")
    }

    private var historyEmptyActions: [HistoryRecoveryAction] {
        [
            HistoryRecoveryAction(
                id: "knm",
                icon: "graduationcap.fill",
                title: localized(en: "KNM guide", nl: "KNM-gids", ru: "Гайд KNM"),
                subtitle: localized(en: "Civic themes for the exam", nl: "Burgerschapsthema's voor het examen", ru: "Темы общества для экзамена"),
                color: AppColors.violet,
                destination: .knm
            ),
            HistoryRecoveryAction(
                id: "culture",
                icon: "building.columns.fill",
                title: localized(en: "Culture", nl: "Cultuur", ru: "Культура"),
                subtitle: localized(en: "Places, customs, daily context", nl: "Plaatsen, gewoonten en dagelijkse context", ru: "Места, привычки и повседневный контекст"),
                color: AppColors.dutchOrange,
                destination: .cultureAttractions
            ),
            HistoryRecoveryAction(
                id: "terms",
                icon: "text.magnifyingglass",
                title: localized(en: "Dutch terms", nl: "Nederlandse termen", ru: "Термины"),
                subtitle: localized(en: "Useful civic words", nl: "Handige burgerwoorden", ru: "Полезные слова о стране"),
                color: AppColors.softBlue,
                destination: .dutchTermsList
            ),
            HistoryRecoveryAction(
                id: "sources",
                icon: "checkmark.shield.fill",
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Verify facts before acting", nl: "Controleer feiten voordat je handelt", ru: "Проверьте факты перед действием"),
                color: AppColors.success,
                destination: .officialSources
            )
        ]
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 14) {
            NLHistoryAtomGraphic()
                .frame(width: 68, height: 68)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 10) {
                Text(pageTitle)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(headerSubtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    historyHeroPill(localized(en: "5 min", nl: "5 min", ru: "5 мин"), localized(en: "Guided path", nl: "Begeleid pad", ru: "Понятный путь"), AppColors.cyanGlow)
                    historyHeroPill("9", localized(en: "Periods", nl: "Periodes", ru: "Периодов"), AppColors.dutchOrange)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColors.navyDeep.opacity(0.82), AppColors.cyanGlow.opacity(0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.cyanGlow.opacity(0.36), AppColors.violet.opacity(0.18)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.9
                )
        )
    }

    // MARK: - Timeline

    private var guidedHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            guidedHistoryIntro

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(historyJourneyPeriods.enumerated()), id: \.element.id) { index, period in
                    HistoryJourneyPeriodSurface(
                        period: period,
                        language: lang,
                        isFirst: index == 0,
                        isLast: index == historyJourneyPeriods.count - 1,
                        isExpanded: expandedPeriodID == period.id,
                        onToggle: {
                            withAnimation(AppAnimations.softSpring) {
                                expandedPeriodID = expandedPeriodID == period.id ? nil : period.id
                            }
                        }
                    )
                }
            }
        }
    }

    private var guidedHistoryIntro: some View {
        VStack(alignment: .leading, spacing: 10) {
            NLSectionHeader(title: timelineTitle)

            Text(historyJourneyIntro)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 118), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                historyOverviewMetric(
                    "9",
                    localized(en: "Periods", nl: "Periodes", ru: "Периодов"),
                    localized(en: "From Roman border to modern democracy", nl: "Van Romeinse grens tot moderne democratie", ru: "От римской границы до современной демократии"),
                    AppColors.cyanGlow
                )
                historyOverviewMetric(
                    "3",
                    localized(en: "Facts each", nl: "Feiten per periode", ru: "Факта в каждом"),
                    localized(en: "Only what a newcomer should remember", nl: "Alleen wat nieuwkomers moeten onthouden", ru: "Только то, что важно запомнить новичку"),
                    AppColors.dutchOrange
                )
                historyOverviewMetric(
                    "35%",
                    localized(en: "Max image", nl: "Maximale afbeelding", ru: "Максимум для изображения"),
                    localized(en: "Images support the story, never replace it", nl: "Beelden ondersteunen het verhaal", ru: "Изображения помогают истории, а не заменяют её"),
                    AppColors.emerald
                )
            }
        }
        .appCardStyle()
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: timelineTitle)
            ForEach(viewModel.timeline) { item in
                civicTimelineRow(item)
            }
        }
    }

    private func civicTimelineRow(_ item: CivicTimelineItem) -> some View {
        let isExpanded = viewModel.expandedTimelineIDs.contains(item.id)
        return Button {
            viewModel.toggleTimelineExpansion(item.id)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .center, spacing: AppSpacing.small) {
                    AppSymbolBadge(symbol: item.symbol, color: AppColors.cyanGlow, size: 50)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title(lang))
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.80)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.period(lang))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                        .rotationEffect(isExpanded ? .degrees(180) : .zero)
                }
                .padding(PremiumVisualMetrics.Card.padding)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .appGlassCardStyle(accent: AppColors.cyanGlow)

                if isExpanded {
                    ProductInfoBlock(
                        title: item.title(lang),
                        bodyText: "\(item.details(lang))\n\n\(item.whyItMatters(lang))",
                        symbol: "text.book.closed.fill",
                        accent: AppColors.cyanGlow
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.title(lang)), \(item.period(lang))")
        .animation(AppAnimations.softSpring, value: isExpanded)
    }

    private func historyHeroPill(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(color.opacity(0.18), lineWidth: 0.7))
    }

    private func historyOverviewMetric(_ value: String, _ title: String, _ subtitle: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(size: 10.5, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Civic Info Cards Section

    private func civicCardsSection(
        title: String,
        symbol: String,
        color: Color,
        cards: [CivicInfoCardItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }

            ForEach(cards) { card in
                civicInfoBlock(card)
            }
        }
    }

    private func civicInfoBlock(_ card: CivicInfoCardItem) -> some View {
        let isExpanded = viewModel.expandedCardIDs.contains(card.id)
        let accent = civicInfoAccent(for: card)
        return Button {
            viewModel.toggleCardExpansion(card.id)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                ProductTaskCard(
                    title: card.title(lang),
                    subtitle: card.summary(lang),
                    symbol: card.symbol,
                    accent: accent,
                    minHeight: 88
                )

                if isExpanded {
                    ProductInfoBlock(
                        title: card.title(lang),
                        bodyText: card.detail(lang),
                        symbol: card.symbol,
                        accent: accent
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(AppAnimations.softSpring, value: isExpanded)
    }

    private func civicInfoAccent(for item: CivicInfoCardItem) -> Color {
        switch item.section {
        case .history: return AppColors.cyanGlow
        case .monarchy: return AppColors.dutchOrange
        case .politics: return AppColors.violet
        case .society: return AppColors.emerald
        case .glossary: return AppColors.softBlue
        case .quiz: return AppColors.success
        }
    }

    // MARK: - Glossary

    private var glossarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: glossaryTitle)
            ForEach(viewModel.glossary) { term in
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(term.displayTerm(lang))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                        Text(term.dutchTerm)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.accentLight)
                            .lineLimit(1)
                    }
                    .frame(minWidth: 80, alignment: .leading)

                    Text(term.definition(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .appCardStyle()
            }
        }
    }

    private var quizSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: CivicLearningSection.quiz.title(lang))
            ForEach(viewModel.quiz) { question in
                civicQuizBlock(question)
            }
        }
    }

    private func civicQuizBlock(_ question: CivicQuizQuestion) -> some View {
        let selectedIndex = viewModel.selectedQuizAnswers[question.id]
        let options = question.options(lang)
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductInfoBlock(
                title: CivicLearningSection.quiz.title(lang),
                bodyText: question.question(lang),
                symbol: "questionmark.circle.fill",
                accent: AppColors.success
            )

            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    viewModel.answer(question, index: index)
                } label: {
                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        Image(systemName: civicQuizIcon(index, selectedIndex: selectedIndex, question: question))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(civicQuizIconColor(index, selectedIndex: selectedIndex, question: question))
                            .padding(.top, 2)
                        Text(option)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(civicQuizBackground(index, selectedIndex: selectedIndex, question: question))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if selectedIndex != nil {
                ProductInfoBlock(
                    title: localized(en: "Explanation", nl: "Uitleg", ru: "Пояснение"),
                    bodyText: question.explanation(lang),
                    symbol: "text.bubble.fill",
                    accent: AppColors.cyanGlow
                )
            }
        }
    }

    private func civicQuizIcon(_ index: Int, selectedIndex: Int?, question: CivicQuizQuestion) -> String {
        guard let selectedIndex else { return "circle" }
        if index == question.correctIndex { return "checkmark.circle.fill" }
        if index == selectedIndex { return "xmark.circle.fill" }
        return "circle"
    }

    private func civicQuizIconColor(_ index: Int, selectedIndex: Int?, question: CivicQuizQuestion) -> Color {
        guard selectedIndex != nil else { return AppColors.textTertiary }
        if index == question.correctIndex { return AppColors.success }
        if index == selectedIndex { return AppColors.error }
        return AppColors.textTertiary
    }

    private func civicQuizBackground(_ index: Int, selectedIndex: Int?, question: CivicQuizQuestion) -> Color {
        guard selectedIndex != nil else { return Color.white.opacity(0.04) }
        if index == question.correctIndex { return AppColors.success.opacity(0.12) }
        if index == selectedIndex { return AppColors.error.opacity(0.10) }
        return Color.white.opacity(0.04)
    }

    // MARK: - Sources

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: L10n.t("historyNetherlands.sources.title", lang))

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(L10n.t("historyNetherlands.sources.wikipedia", lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.t("historyNetherlands.sources.license", lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    showingSources = true
                } label: {
                    Label(L10n.t("historyNetherlands.sources.open", lang), systemImage: "link")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.accentLight)
                .accessibilityLabel(L10n.t("historyNetherlands.sources.open", lang))
                .accessibilityIdentifier("history.sources.open")
            }
            .appCardStyle()
        }
    }

    // MARK: - Localized Strings

    private var pageTitle: String {
        L10n.t("historyNetherlands.title", lang)
    }

    private var headerSubtitle: String {
        L10n.t("historyNetherlands.subtitle", lang)
    }

    private var timelineTitle: String {
        L10n.t("historyNetherlands.timeline.title", lang)
    }

    private var glossaryTitle: String {
        L10n.t("historyNetherlands.keyTerms", lang)
    }

    private var historyJourneyIntro: String {
        localized(
            en: "A fast guided path through Dutch history. Each period gives the story first, then the facts to remember, and only uses an image when it explains the period.",
            nl: "Een korte gids door de Nederlandse geschiedenis. Elke periode geeft eerst het verhaal, daarna de feiten om te onthouden, en gebruikt alleen beeld wanneer het de periode uitlegt.",
            ru: "Короткий понятный путь по истории Нидерландов: сначала смысл периода, затем ключевые факты, и только те изображения, которые помогают понять тему."
        )
    }

    private var historyJourneyPeriods: [HistoryJourneyPeriod] {
        [
            HistoryJourneyPeriod(
                id: "roman-era",
                symbol: "building.columns.fill",
                accent: AppColors.softBlue,
                title: localized(en: "Roman Era", nl: "Romeinse tijd", ru: "Римский период"),
                dateRange: "57 BCE-400 CE",
                summary: localized(en: "The southern Netherlands sat on the edge of the Roman world, with the Rhine forming a military and trading frontier.", nl: "Zuid-Nederland lag aan de rand van de Romeinse wereld, met de Rijn als militaire en handelsgrens.", ru: "Юг будущих Нидерландов находился на краю римского мира, а Рейн стал военной и торговой границей."),
                facts: [
                    localized(en: "Rhine frontier shaped settlement", nl: "De Rijngrens bepaalde nederzettingen", ru: "Граница по Рейну влияла на поселения"),
                    localized(en: "Roman roads connected towns", nl: "Romeinse wegen verbonden steden", ru: "Римские дороги связывали города"),
                    localized(en: "Trade linked local communities to Europe", nl: "Handel verbond lokale gemeenschappen met Europa", ru: "Торговля связывала местные общины с Европой")
                ],
                figures: [localized(en: "Batavi", nl: "Bataven", ru: "Батавы"), localized(en: "Roman legions", nl: "Romeinse legioenen", ru: "Римские легионы")],
                detail: localized(en: "This period matters because Dutch history begins as a border story: water, trade routes, and outside powers all shaped where people lived and worked.", nl: "Deze periode laat zien dat de Nederlandse geschiedenis begint als grensverhaal: water, handelsroutes en buitenlandse machten bepaalden waar mensen woonden en werkten.", ru: "Этот период важен, потому что история Нидерландов начинается как история границы: вода, торговые пути и внешние силы влияли на жизнь людей."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "middle-ages",
                symbol: "shield.lefthalf.filled",
                accent: AppColors.emerald,
                title: localized(en: "Middle Ages", nl: "Middeleeuwen", ru: "Средневековье"),
                dateRange: "500-1400",
                summary: localized(en: "Towns, churches, markets, and water boards grew into the local structures that still influence Dutch public life.", nl: "Steden, kerken, markten en waterschappen groeiden uit tot lokale structuren die het openbare leven nog steeds beinvloeden.", ru: "Города, церкви, рынки и водные управления стали местными структурами, которые до сих пор влияют на жизнь страны."),
                facts: [
                    localized(en: "Towns received city rights", nl: "Steden kregen stadsrechten", ru: "Города получали городские права"),
                    localized(en: "Dikes and water boards expanded", nl: "Dijken en waterschappen groeiden", ru: "Развивались дамбы и водные управления"),
                    localized(en: "Trade networks connected the coast and rivers", nl: "Handelsnetwerken verbonden kust en rivieren", ru: "Торговые сети связывали побережье и реки")
                ],
                figures: [localized(en: "Counts of Holland", nl: "Graven van Holland", ru: "Графы Голландии"), localized(en: "Local guilds", nl: "Lokale gilden", ru: "Местные гильдии")],
                detail: localized(en: "The medieval period explains why municipalities, local rules, markets, and water management are so important in the Netherlands today.", nl: "De middeleeuwen verklaren waarom gemeenten, lokale regels, markten en waterbeheer vandaag zo belangrijk zijn.", ru: "Средневековье объясняет, почему муниципалитеты, местные правила, рынки и управление водой так важны в современной стране."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "burgundian-era",
                symbol: "seal.fill",
                accent: AppColors.violet,
                title: localized(en: "Burgundian Era", nl: "Bourgondische tijd", ru: "Бургундский период"),
                dateRange: "1384-1482",
                summary: localized(en: "The Low Countries became more connected under Burgundian rule, bringing wealthy cities and regional administration closer together.", nl: "De Lage Landen raakten onder Bourgondisch bestuur sterker verbonden, met rijke steden en regionale administratie.", ru: "При Бургундии Низинные земли стали теснее связаны: богатые города и региональное управление сближались."),
                facts: [
                    localized(en: "Cities became richer and more connected", nl: "Steden werden rijker en sterker verbonden", ru: "Города становились богаче и связаннее"),
                    localized(en: "Regional government became more organized", nl: "Regionaal bestuur werd georganiseerder", ru: "Региональное управление становилось организованнее"),
                    localized(en: "Court culture shaped art and politics", nl: "Hofcultuur beinvloedde kunst en politiek", ru: "Придворная культура влияла на искусство и политику")
                ],
                figures: [localized(en: "Philip the Good", nl: "Filips de Goede", ru: "Филипп Добрый"), localized(en: "Mary of Burgundy", nl: "Maria van Bourgondie", ru: "Мария Бургундская")],
                detail: localized(en: "This period helps explain why the Netherlands developed as a network of powerful towns rather than one single dominant capital.", nl: "Deze periode verklaart waarom Nederland zich ontwikkelde als netwerk van sterke steden, niet als een land met een enkele dominante hoofdstad.", ru: "Этот период помогает понять, почему Нидерланды развивались как сеть сильных городов, а не как страна с одной доминирующей столицей."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "dutch-revolt",
                symbol: "flag.fill",
                accent: AppColors.dutchOrange,
                title: localized(en: "Dutch Revolt", nl: "Nederlandse Opstand", ru: "Нидерландское восстание"),
                dateRange: "1568-1648",
                summary: localized(en: "The northern provinces rebelled against Spanish Habsburg rule and formed the Dutch Republic.", nl: "De noordelijke provincies kwamen in opstand tegen Spaans-Habsburgs bestuur en vormden de Republiek.", ru: "Северные провинции восстали против власти испанских Габсбургов и создали Нидерландскую республику."),
                facts: [
                    localized(en: "William of Orange led the revolt", nl: "Willem van Oranje leidde de opstand", ru: "Вильгельм Оранский возглавил восстание"),
                    localized(en: "The Union of Utrecht joined provinces", nl: "De Unie van Utrecht verbond provincies", ru: "Утрехтская уния объединила провинции"),
                    localized(en: "The Republic gained recognition in 1648", nl: "De Republiek werd erkend in 1648", ru: "Республику признали в 1648 году")
                ],
                figures: [localized(en: "William of Orange", nl: "Willem van Oranje", ru: "Вильгельм Оранский"), localized(en: "States General", nl: "Staten-Generaal", ru: "Генеральные штаты")],
                detail: localized(en: "The revolt is the foundation story of Dutch independence, religious conflict, provincial power, and the republican tradition.", nl: "De opstand vormt het fundament van onafhankelijkheid, religieus conflict, provinciale macht en republikeinse traditie.", ru: "Это основа истории независимости Нидерландов: религиозный конфликт, сила провинций и республиканская традиция."),
                image: historyImage("history-netherlands-map-1631"),
                imageReason: localized(en: "The 1631 map shows the early modern provinces as a political geography, not just a decorative old map.", nl: "De kaart uit 1631 toont de vroegmoderne provincies als politieke geografie, niet alleen als decoratie.", ru: "Карта 1631 года показывает провинции как политическую географию, а не просто старинную иллюстрацию.")
            ),
            HistoryJourneyPeriod(
                id: "golden-age",
                symbol: "shippingbox.fill",
                accent: AppColors.cyanGlow,
                title: localized(en: "Dutch Golden Age", nl: "Gouden Eeuw", ru: "Золотой век Нидерландов"),
                dateRange: "1600-1700",
                summary: localized(en: "The Dutch Republic became one of the world's leading trade, finance, science, and art powers.", nl: "De Republiek werd een wereldmacht in handel, finance, wetenschap en kunst.", ru: "Нидерландская республика стала одной из ведущих мировых сил в торговле, финансах, науке и искусстве."),
                facts: [
                    localized(en: "VOC founded", nl: "VOC opgericht", ru: "Основана VOC"),
                    localized(en: "Amsterdam became a financial center", nl: "Amsterdam werd financieel centrum", ru: "Амстердам стал финансовым центром"),
                    localized(en: "Rembrandt and Vermeer shaped world art", nl: "Rembrandt en Vermeer bepaalden wereldkunst", ru: "Рембрандт и Вермеер повлияли на мировое искусство")
                ],
                figures: ["Rembrandt", "Vermeer", "Antonie van Leeuwenhoek"],
                detail: localized(en: "The Golden Age is important because economic growth, global trade, art, publishing, science, and inequality all expanded at the same time.", nl: "De Gouden Eeuw is belangrijk omdat economische groei, wereldhandel, kunst, drukwerk, wetenschap en ongelijkheid tegelijk toenamen.", ru: "Золотой век важен тем, что экономический рост, мировая торговля, искусство, печать, наука и неравенство развивались одновременно."),
                image: historyImage("history-amsterdam-westerkerk-1660"),
                imageReason: localized(en: "The Amsterdam city view connects prosperity to urban growth, canals, churches, trade, and daily city life.", nl: "Het stadsgezicht van Amsterdam verbindt welvaart met stedelijke groei, grachten, kerken, handel en dagelijks leven.", ru: "Вид Амстердама связывает процветание с ростом города, каналами, церквями, торговлей и повседневной жизнью.")
            ),
            HistoryJourneyPeriod(
                id: "napoleonic-era",
                symbol: "scroll.fill",
                accent: AppColors.warning,
                title: localized(en: "Napoleonic Era", nl: "Napoleontische tijd", ru: "Наполеоновская эпоха"),
                dateRange: "1795-1813",
                summary: localized(en: "French influence changed administration, law, taxation, and identity documents before the Kingdom was founded.", nl: "Franse invloed veranderde bestuur, recht, belasting en identiteitsdocumenten voor de stichting van het Koninkrijk.", ru: "Французское влияние изменило управление, право, налоги и регистрацию личности до создания королевства."),
                facts: [
                    localized(en: "French-backed Batavian Republic formed", nl: "De Bataafse Republiek ontstond", ru: "Возникла Батавская республика"),
                    localized(en: "Civil registration became systematic", nl: "Burgerlijke registratie werd systematisch", ru: "Гражданская регистрация стала системной"),
                    localized(en: "The Netherlands was annexed by France", nl: "Nederland werd door Frankrijk ingelijfd", ru: "Нидерланды были присоединены к Франции")
                ],
                figures: [localized(en: "Louis Bonaparte", nl: "Lodewijk Napoleon", ru: "Людовик Бонапарт"), "Napoleon"],
                detail: localized(en: "This period explains practical systems newcomers still meet today: names, registration, national administration, and centralized records.", nl: "Deze periode verklaart systemen die nieuwkomers nog tegenkomen: namen, registratie, nationaal bestuur en centrale dossiers.", ru: "Этот период объясняет системы, с которыми новички сталкиваются сегодня: имена, регистрация, национальное управление и централизованные записи."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "industrial-era",
                symbol: "gearshape.2.fill",
                accent: AppColors.routeLine,
                title: localized(en: "Industrial Era", nl: "Industriele tijd", ru: "Индустриальная эпоха"),
                dateRange: "1815-1914",
                summary: localized(en: "The Kingdom modernized through railways, industry, education, ports, and constitutional reform.", nl: "Het Koninkrijk moderniseerde via spoorwegen, industrie, onderwijs, havens en grondwetsherziening.", ru: "Королевство модернизировалось через железные дороги, промышленность, образование, порты и конституционные реформы."),
                facts: [
                    localized(en: "Kingdom of the Netherlands established", nl: "Koninkrijk der Nederlanden opgericht", ru: "Создано Королевство Нидерландов"),
                    localized(en: "Railways and ports expanded", nl: "Spoorwegen en havens breidden uit", ru: "Развивались железные дороги и порты"),
                    localized(en: "1848 constitution strengthened parliament", nl: "De grondwet van 1848 versterkte het parlement", ru: "Конституция 1848 года усилила парламент")
                ],
                figures: [localized(en: "King William I", nl: "Koning Willem I", ru: "Король Виллем I"), "Johan Thorbecke"],
                detail: localized(en: "This period connects monarchy, parliament, infrastructure, schools, ports, and modern city growth into one national system.", nl: "Deze periode verbindt monarchie, parlement, infrastructuur, scholen, havens en moderne stadsgroei.", ru: "Этот период связывает монархию, парламент, инфраструктуру, школы, порты и рост современных городов в одну систему."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "world-wars",
                symbol: "flame.fill",
                accent: AppColors.error,
                title: localized(en: "World Wars", nl: "Wereldoorlogen", ru: "Мировые войны"),
                dateRange: "1914-1945",
                summary: localized(en: "The Netherlands stayed neutral in World War I, but was occupied during World War II, with deep human and civic consequences.", nl: "Nederland bleef neutraal in de Eerste Wereldoorlog, maar werd in de Tweede Wereldoorlog bezet.", ru: "В Первую мировую Нидерланды сохраняли нейтралитет, но во Вторую мировую были оккупированы, что имело глубокие человеческие и гражданские последствия."),
                facts: [
                    localized(en: "Neutral in World War I", nl: "Neutraal in de Eerste Wereldoorlog", ru: "Нейтралитет в Первой мировой войне"),
                    localized(en: "Occupied by Nazi Germany in 1940", nl: "Bezet door nazi-Duitsland in 1940", ru: "Оккупация нацистской Германией в 1940 году"),
                    localized(en: "Liberation came in 1945", nl: "Bevrijding kwam in 1945", ru: "Освобождение пришло в 1945 году")
                ],
                figures: [localized(en: "Anne Frank", nl: "Anne Frank", ru: "Анна Франк"), localized(en: "Dutch resistance", nl: "Nederlands verzet", ru: "Нидерландское сопротивление")],
                detail: localized(en: "This period is essential for understanding remembrance culture, freedom, anti-discrimination values, and why official memorial days matter.", nl: "Deze periode is essentieel om herdenken, vrijheid, antidiscriminatie en nationale herdenkingsdagen te begrijpen.", ru: "Этот период важен для понимания культуры памяти, свободы, антидискриминационных ценностей и официальных дней памяти."),
                image: nil,
                imageReason: nil
            ),
            HistoryJourneyPeriod(
                id: "modern-netherlands",
                symbol: "person.3.sequence.fill",
                accent: AppColors.success,
                title: localized(en: "Modern Netherlands", nl: "Modern Nederland", ru: "Современные Нидерланды"),
                dateRange: localized(en: "After 1945", nl: "Na 1945", ru: "После 1945"),
                summary: localized(en: "The country rebuilt, decolonized, joined European institutions, and became a modern welfare, trade, and water-management society.", nl: "Het land herbouwde, dekoloniseerde, sloot zich aan bij Europese instellingen en werd een moderne verzorgings-, handels- en waterbeheersamenleving.", ru: "Страна восстановилась, прошла деколонизацию, вошла в европейские институты и стала современным обществом с сильной социальной системой, торговлей и управлением водой."),
                facts: [
                    localized(en: "Welfare state expanded", nl: "De verzorgingsstaat groeide", ru: "Расширилась социальная система"),
                    localized(en: "Indonesia became independent", nl: "Indonesie werd onafhankelijk", ru: "Индонезия стала независимой"),
                    localized(en: "EU, NATO, and Delta Works shaped modern policy", nl: "EU, NAVO en Deltawerken bepaalden modern beleid", ru: "ЕС, НАТО и Дельта-проект повлияли на современную политику")
                ],
                figures: [localized(en: "Post-war governments", nl: "Naoorlogse regeringen", ru: "Послевоенные правительства"), localized(en: "Water engineers", nl: "Waterbouwkundigen", ru: "Инженеры по воде")],
                detail: localized(en: "Modern Dutch life combines local services, international cooperation, migration, housing pressure, climate adaptation, and strong public institutions.", nl: "Modern Nederlands leven combineert lokale diensten, internationale samenwerking, migratie, woningdruk, klimaatadaptatie en sterke publieke instellingen.", ru: "Современная жизнь в Нидерландах объединяет местные услуги, международное сотрудничество, миграцию, давление на жильё, адаптацию к климату и сильные публичные институты."),
                image: historyImage("history-afsluitdijk-aerial"),
                imageReason: localized(en: "The Afsluitdijk image teaches the continuing Dutch relationship with water, engineering, safety, and national planning.", nl: "Het Afsluitdijk-beeld laat de blijvende Nederlandse relatie met water, techniek, veiligheid en planning zien.", ru: "Изображение Афслёйтдейка показывает постоянную связь Нидерландов с водой, инженерией, безопасностью и национальным планированием.")
            )
        ]
    }

    private func historyImage(_ id: String) -> AppImageAsset? {
        HistoryMediaRegistry.teachingImages.first { $0.id == id }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

// MARK: - Guided History Timeline

private struct HistoryRecoveryAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct HistoryRecoveryActionCard: View {
    let action: HistoryRecoveryAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.color,
            minHeight: 104
        )
    }
}

private struct HistoryJourneyPeriod: Identifiable {
    let id: String
    let symbol: String
    let accent: Color
    let title: String
    let dateRange: String
    let summary: String
    let facts: [String]
    let figures: [String]
    let detail: String
    let image: AppImageAsset?
    let imageReason: String?
}

private struct HistoryJourneyPeriodSurface: View {
    let period: HistoryJourneyPeriod
    let language: AppLanguage
    let isFirst: Bool
    let isLast: Bool
    let isExpanded: Bool
    let onToggle: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var imageHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 220 : 184
    }

    private var railWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 34 : 30
    }

    private var contentLeadingInset: CGFloat {
        railWidth + 12
    }

    var body: some View {
        cardSurface
            .padding(.bottom, isLast ? 0 : 12)
    }

    private var cardSurface: some View {
        ZStack(alignment: .topLeading) {
            timelineRail
                .frame(width: railWidth)
                .padding(.leading, 2)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 12) {
                header
                storyBlock
                factsBlock
                figuresBlock

                if let image = period.image {
                    teachingImage(image)
                }

                learnMoreButton

                if isExpanded {
                    expandedDetail
                }
            }
            .padding(.leading, contentLeadingInset)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .padding(dynamicTypeSize.isAccessibilitySize ? 14 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColors.cardElevated.opacity(0.96), period.accent.opacity(0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(period.accent.opacity(0.20), lineWidth: 0.8)
        )
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : period.accent.opacity(0.35))
                .frame(width: 2, height: 16)

            ZStack {
                Circle()
                    .fill(period.accent.opacity(0.16))
                    .frame(width: railWidth, height: railWidth)
                Image(systemName: period.symbol)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 14 : 13, weight: .bold))
                    .foregroundStyle(period.accent)
            }

            Rectangle()
                .fill(isLast ? Color.clear : period.accent.opacity(0.35))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: railWidth)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(period.dateRange)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(period.accent)
                .textCase(.uppercase)

            Text(period.title)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var storyBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(storyLabel, systemImage: "text.alignleft")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            Text(period.summary)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(period.accent.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var factsBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(keyFactsLabel, systemImage: "checklist")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(period.facts, id: \.self) { fact in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5, weight: .bold))
                        .foregroundStyle(period.accent)
                        .padding(.top, 7)
                    Text(fact)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var figuresBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(keyFiguresLabel, systemImage: "person.2.fill")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: 7)],
                alignment: .leading,
                spacing: 7
            ) {
                ForEach(period.figures, id: \.self) { figure in
                    Text(figure)
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(period.accent)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(period.accent.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func teachingImage(_ image: AppImageAsset) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AppContentImageView(
                asset: image,
                language: language,
                mode: .fill,
                accent: period.accent,
                aspectRatio: 16.0 / 9.0,
                cornerRadius: 14,
                showsCaption: false,
                showsSourceButton: false,
                accessibilityLabel: image.displayTitle(language),
                targetPixelWidth: 900
            )
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: imageHeight)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .clipped()

            if let imageReason = period.imageReason {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(period.accent)
                        .padding(.top, 2)
                        .frame(width: 18, alignment: .center)

                    Text(imageReason)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                }
                .padding(.trailing, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var learnMoreButton: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(isExpanded ? showLessLabel : learnMoreLabel)
                    .font(.system(.footnote, design: .rounded).weight(.bold))
                Spacer(minLength: 0)
            }
            .foregroundStyle(period.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(period.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var expandedDetail: some View {
        Text(period.detail)
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var storyLabel: String {
        switch language {
        case .russian: return "Смысл"
        case .dutch: return "Verhaal"
        case .english: return "Story"
        }
    }

    private var keyFactsLabel: String {
        switch language {
        case .russian: return "Ключевые факты"
        case .dutch: return "Kernfeiten"
        case .english: return "Key facts"
        }
    }

    private var keyFiguresLabel: String {
        switch language {
        case .russian: return "Ключевые фигуры"
        case .dutch: return "Belangrijke personen"
        case .english: return "Key figures"
        }
    }

    private var learnMoreLabel: String {
        switch language {
        case .russian: return "Узнать больше"
        case .dutch: return "Meer leren"
        case .english: return "Learn more"
        }
    }

    private var showLessLabel: String {
        switch language {
        case .russian: return "Скрыть"
        case .dutch: return "Minder tonen"
        case .english: return "Show less"
        }
    }
}

private struct NetherlandsHistorySourcesView: View {
    @Environment(\.dismiss) private var dismiss
    let language: AppLanguage

    private var source: HistorySource {
        HistorySourceDetails.textSource(for: language)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    sourceRow(label: L10n.t("historyNetherlands.sources.pageTitle", language), value: source.title)
                    sourceRow(label: L10n.t("historyNetherlands.sources.language", language), value: source.language)
                    sourceRow(label: L10n.t("historyNetherlands.sources.url", language), value: source.url.absoluteString)
                    sourceRow(label: L10n.t("historyNetherlands.sources.lastUpdated", language), value: "2026-05-31")
                    sourceRow(label: L10n.t("historyNetherlands.sources.licenseLabel", language), value: "CC BY-SA")
                    sourceRow(label: L10n.t("historyNetherlands.sources.noteLabel", language), value: L10n.t("historyNetherlands.sources.note", language))

                    imageSourcesSection

                    Link(destination: AppURL.safeWebURL(source.url)) {
                        Label(L10n.t("historyNetherlands.sources.open", language), systemImage: "safari")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, AppSpacing.small)
                }
                .padding(AppSpacing.screenHorizontal)
                .tabBarScrollReserve()
            }
            .appSceneBackground(.documents)
            .navigationTitle(L10n.t("historyNetherlands.sources.title", language))
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(L10n.t("common.done", language)) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sourceRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private var imageSourcesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: L10n.t("historyNetherlands.images.sourcesTitle", language))

            ForEach(HistoryMediaRegistry.images) { image in
                VStack(alignment: .leading, spacing: 6) {
                    Text(image.displayTitle(language))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    sourceDetailLine(label: L10n.t("historyNetherlands.sources.pageTitle", language), value: image.sourceName)
                    if let detail = HistorySourceDetails.imageSource(for: image) {
                        sourceDetailLine(label: L10n.t("historyNetherlands.sources.url", language), value: detail.sourcePageURL.absoluteString)
                        sourceDetailLine(label: L10n.t("historyNetherlands.images.attribution", language), value: detail.attribution)
                        sourceDetailLine(label: L10n.t("historyNetherlands.sources.licenseLabel", language), value: detail.licenseName)
                        if let licenseURL = detail.licenseURL {
                            sourceDetailLine(label: L10n.t("historyNetherlands.sources.url", language), value: licenseURL.absoluteString)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
            }
        }
    }

    private func sourceDetailLine(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct HistorySource: Equatable {
    let title: String
    let language: String
    let url: URL
}

struct HistoryImageSourceDetail: Equatable {
    let id: String
    let title: String
    let sourceName: String
    let sourcePageURL: URL
    let licenseName: String
    let licenseURL: URL?
    let author: String
    let attribution: String
}

@MainActor
enum HistorySourceDetails {
    static func textSource(for language: AppLanguage) -> HistorySource {
        switch language {
        case .russian:
            return HistorySource(
                title: "История Нидерландов",
                language: "ru",
                url: AppURL.make("https://ru.wikipedia.org/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%9D%D0%B8%D0%B4%D0%B5%D1%80%D0%BB%D0%B0%D0%BD%D0%B4%D0%BE%D0%B2")
            )
        case .dutch:
            return HistorySource(
                title: "Geschiedenis van Nederland",
                language: "nl",
                url: AppURL.make("https://nl.wikipedia.org/wiki/Geschiedenis_van_Nederland")
            )
        case .english:
            return HistorySource(
                title: "History of the Netherlands",
                language: "en",
                url: AppURL.make("https://en.wikipedia.org/wiki/History_of_the_Netherlands")
            )
        }
    }

    static var imageSources: [HistoryImageSourceDetail] {
        HistoryMediaRegistry.images.compactMap(imageSource(for:))
    }

    static func imageSource(for image: AppImageAsset) -> HistoryImageSourceDetail? {
        guard
            let sourcePageURL = image.sourcePageURL,
            let licenseName = image.licenseName,
            let author = image.author,
            let attribution = image.attribution
        else {
            return nil
        }

        return HistoryImageSourceDetail(
            id: image.id,
            title: image.title,
            sourceName: image.sourceName,
            sourcePageURL: sourcePageURL,
            licenseName: licenseName,
            licenseURL: image.licenseURL,
            author: author,
            attribution: attribution
        )
    }
}

// MARK: - Atom Orbit Graphic (reusable)

struct NLHistoryAtomGraphic: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let center = CGPoint(x: cx, y: cy)

            // Outer dashed elliptic orbit
            let outerRx = size.width * 0.44
            let outerRy = outerRx * 0.55
            let outerRect = CGRect(x: cx - outerRx, y: cy - outerRy, width: outerRx * 2, height: outerRy * 2)
            context.stroke(
                Path(ellipseIn: outerRect),
                with: .color(AppColors.cyanGlow.opacity(0.30)),
                style: StrokeStyle(lineWidth: 1.0, dash: [4, 6])
            )

            // Inner dashed elliptic orbit
            let innerRx = outerRx * 0.60
            let innerRy = outerRy * 0.60
            let innerRect = CGRect(x: cx - innerRx, y: cy - innerRy, width: innerRx * 2, height: innerRy * 2)
            context.stroke(
                Path(ellipseIn: innerRect),
                with: .color(AppColors.violet.opacity(0.24)),
                style: StrokeStyle(lineWidth: 0.8, dash: [3, 5])
            )

            // Nucleus glow
            let glowR: CGFloat = 12
            context.fill(
                Path(ellipseIn: CGRect(x: cx - glowR, y: cy - glowR, width: glowR * 2, height: glowR * 2)),
                with: .color(AppColors.cyanGlow.opacity(0.16))
            )
            // Nucleus core
            let coreR: CGFloat = 6
            context.fill(
                Path(ellipseIn: CGRect(x: cx - coreR, y: cy - coreR, width: coreR * 2, height: coreR * 2)),
                with: .color(AppColors.cyanGlow.opacity(0.92))
            )

            // Orbit nodes: 5 dots representing history topics
            let nodeColors: [Color] = [
                AppColors.cyanGlow,
                AppColors.dutchOrange,
                AppColors.softBlue,
                AppColors.violet,
                AppColors.emerald
            ]
            let radiiX: [CGFloat] = [outerRx, innerRx, outerRx, innerRx, outerRx]
            let radiiY: [CGFloat] = [outerRy, innerRy, outerRy, innerRy, outerRy]

            for i in 0..<5 {
                let angle = CGFloat(i) / 5.0 * .pi * 2 - .pi / 2
                let px = center.x + cos(angle) * radiiX[i]
                let py = center.y + sin(angle) * radiiY[i]
                let color = nodeColors[i]

                // Node glow ring
                let glowNodeR: CGFloat = 8
                context.fill(
                    Path(ellipseIn: CGRect(x: px - glowNodeR, y: py - glowNodeR, width: glowNodeR * 2, height: glowNodeR * 2)),
                    with: .color(color.opacity(0.18))
                )
                // Node dot
                let nodeR: CGFloat = 4.5
                context.fill(
                    Path(ellipseIn: CGRect(x: px - nodeR, y: py - nodeR, width: nodeR * 2, height: nodeR * 2)),
                    with: .color(color.opacity(0.94))
                )
            }
        }
    }
}
