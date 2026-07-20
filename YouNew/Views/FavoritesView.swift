import SwiftUI

private enum SavedFilter: String, CaseIterable, Identifiable {
    case all, articles, services, cities, places, checklists
    var id: String { rawValue }

    func matches(_ item: SavedItemsStore.SavedItem) -> Bool {
        switch self {
        case .all: return true
        case .articles: return [.rule, .document, .resource, .other].contains(item.kind)
        case .services: return item.kind == .institution
        case .cities: return item.kind == .city
        case .places: return item.kind == .place
        case .checklists: return item.id.localizedCaseInsensitiveContains("checklist")
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.all, .russian): return "Все"
        case (.articles, .russian): return "Статьи"
        case (.services, .russian): return "Услуги"
        case (.cities, .russian): return "Города"
        case (.places, .russian): return "Места"
        case (.checklists, .russian): return "Чек-листы"
        case (.all, .dutch): return "Alles"
        case (.articles, .dutch): return "Artikelen"
        case (.services, .dutch): return "Diensten"
        case (.cities, .dutch): return "Steden"
        case (.places, .dutch): return "Plekken"
        case (.checklists, .dutch): return "Checklists"
        case (.all, .english): return "All"
        case (.articles, .english): return "Articles"
        case (.services, .english): return "Services"
        case (.cities, .english): return "Cities"
        case (.places, .english): return "Places"
        case (.checklists, .english): return "Checklists"
        }
    }
}

struct FavoritesView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var router: TabRouter
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject private var savedStore = SavedItemsStore.shared
    @State private var query = ""
    @State private var selectedFilter: SavedFilter = .all
    @State private var sortNewestFirst = true

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleSavedItems: [SavedItemsStore.SavedItem] {
        savedStore.savedItems
            .filter { selectedFilter.matches($0) }
            .filter { item in
                let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
                return value.isEmpty || item.displayTitle(lang).localizedCaseInsensitiveContains(value)
            }
            .sorted { sortNewestFirst ? $0.savedAt > $1.savedAt : $0.savedAt < $1.savedAt }
    }

    var body: some View {
        let visibleItems = visibleSavedItems
        let itemsByKind = Dictionary(grouping: visibleItems, by: \.kind)

        ScrollViewReader { scrollProxy in
            ScrollView {
                ResponsiveContentContainer(maxWidth: 920) {
                    LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Color.clear
                            .frame(height: 0)
                            .id("favoritesTop")

                        savedControls

                        if visibleItems.isEmpty {
                            emptySavedDashboard
                        } else {
                            savedHero
                            ForEach(SavedItemsStore.SavedItemKind.allCases, id: \.rawValue) { kind in
                                let items = itemsByKind[kind] ?? []
                                if !items.isEmpty {
                                    Section {
                                        ForEach(items) { item in
                                            favoriteRow(item)
                                        }
                                    } header: {
                                        SectionHeader(title: title(for: kind))
                                    }
                                }
                            }
                        }

                        Color.clear.frame(height: savedBottomReserve)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.medium)
                    .padding(.top, AppSpacing.large)
                }
            }
            .onReceive(router.savedScrollTop) { _ in
                withAnimation(.easeInOut(duration: 0.24)) {
                    scrollProxy.scrollTo("favoritesTop", anchor: .top)
                }
            }
        }
        .appSceneBackground(.saved)
        .navigationTitle(titleText)
        .nlNavigationInline()
        .accessibilityIdentifier("favorites.screen")
    }

    private var savedControls: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text(titleText)
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Menu {
                    Button(sortNewestTitle) { sortNewestFirst = true }
                    Button(sortOldestTitle) { sortNewestFirst = false }
                } label: {
                    Label(sortTitle, systemImage: "arrow.up.arrow.down")
                        .font(AppTypography.footnote.weight(.semibold))
                }
            }
            TextField(searchPlaceholder, text: $query)
                .textFieldStyle(.plain)
                .padding(13)
                .background(AppColors.cardElevated, in: RoundedRectangle(cornerRadius: 15))
                .accessibilityIdentifier("saved.search")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SavedFilter.allCases) { filter in
                        Button { selectedFilter = filter } label: {
                            Text(filter.title(lang))
                                .font(AppTypography.captionStrong)
                                .foregroundStyle(selectedFilter == filter ? .white : AppColors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(selectedFilter == filter ? AppColors.dutchOrange : AppColors.chipBackground, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptySavedDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            emptySavedVisual

            emptyQuickActions
            if !starterPackAnswers.isEmpty {
                starterPackCard
            }
        }
        .accessibilityIdentifier("saved.empty.dashboard")
    }

    @ViewBuilder
    private var emptySavedVisual: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "bookmark.fill")
                .font(.title2.bold())
                .foregroundStyle(AppColors.dutchOrange)
                .frame(width: 48, height: 48)
                .background(AppColors.dutchOrange.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(emptyTitle)
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(emptyDetail)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.dutchOrange)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("saved.empty.visual")
    }

    private var emptyQuickActions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: emptyQuickActionsTitle, subtitle: emptyQuickActionsSubtitle)

            LazyVGrid(columns: emptyActionGridColumns, spacing: AppSpacing.small) {
                ForEach(emptyActions) { action in
                    NavigationLink(value: action.destination) {
                        emptyActionCard(action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier(
                        action.id == emptyActions.last?.id
                            ? "saved.lastElement"
                            : "saved.empty.action.\(action.id)"
                    )
                }
            }
        }
    }

    private var emptyActionGridColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible(minimum: 0), spacing: AppSpacing.small)]
        }

        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 260), spacing: AppSpacing.small)]
        }

        return [GridItem(.flexible(minimum: 0), spacing: AppSpacing.small)]
    }

    private func emptyActionCard(_ action: EmptySavedAction) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            ProductSymbolTile(symbol: action.symbol, accent: action.tint, size: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text(action.title)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                Text(action.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 24, height: 24)
        }
        .padding(PremiumVisualMetrics.Card.padding)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .appGlassCardStyle(padding: 0, cornerRadius: PremiumVisualMetrics.Card.cornerRadius, accent: action.tint)
        .contentShape(RoundedRectangle(cornerRadius: PremiumVisualMetrics.Card.cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var starterPackCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                GradientIconBadge(symbol: "tray.and.arrow.down.fill", color: AppColors.emerald, size: 44, cornerRadius: 14)

                VStack(alignment: .leading, spacing: 4) {
                    Text(starterPackTitle)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(starterPackDetail)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(starterPackAnswers) { answer in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.success)
                        Text(answer.title(lang))
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                        Spacer(minLength: 0)
                    }
                }
            }

            Button {
                saveStarterPack()
            } label: {
                Label(starterPackButtonTitle, systemImage: "bookmark.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryPremiumButtonStyle())
            .disabled(starterPackAnswers.isEmpty)
            .accessibilityIdentifier("saved.empty.saveStarterPack")
            .accessibilityIdentifier("saved.lastElement")
        }
        .appGlassCardStyle(accent: AppColors.emerald)
    }

    private var titleText: String {
        switch lang {
        case .russian: return "Избранное"
        case .english: return "Saved"
        case .dutch: return "Opgeslagen"
        }
    }

    private var savedBottomReserve: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? AppSpacing.tabBarScrollReserveLarge + 56 : AppSpacing.tabBarScrollReserve
    }

    @ViewBuilder
    private var savedHero: some View {
        if dynamicTypeSize.isAccessibilitySize {
            savedReadableHero(title: titleText, subtitle: subtitleText)
                .accessibilityIdentifier("saved.hero")
        } else {
            CategoryHeroVisual(
                assetName: nil,
                title: titleText,
                subtitle: subtitleText,
                symbol: "bookmark.fill",
                badgeText: savedHeroBadge,
                accent: AppColors.dutchOrange,
                asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
                height: 180,
                language: lang
            )
            .accessibilityIdentifier("saved.hero")
        }
    }

    private func savedReadableHero(title: String, subtitle: String) -> some View {
        ProductStatusStrip(
            title: title,
            subtitle: subtitle,
            symbol: "bookmark.fill",
            accent: AppColors.dutchOrange,
            actionTitle: savedHeroBadge
        )
    }

    @ViewBuilder
    private func favoriteRow(_ item: SavedItemsStore.SavedItem) -> some View {
        if let destination = item.destination ?? ContentRepository.shared.destination(id: item.id) {
            NavigationLink(value: destination) {
                rowContent(item)
            }
            .buttonStyle(.plain)
        } else {
            rowContent(item)
        }
    }

    private var searchPlaceholder: String { emptyActionTitle(en: "Search saved items", nl: "Zoek opgeslagen items", ru: "Поиск в избранном") }
    private var sortTitle: String { emptyActionTitle(en: "Sort", nl: "Sorteren", ru: "Сортировка") }
    private var sortNewestTitle: String { emptyActionTitle(en: "Newest first", nl: "Nieuwste eerst", ru: "Сначала новые") }
    private var sortOldestTitle: String { emptyActionTitle(en: "Oldest first", nl: "Oudste eerst", ru: "Сначала старые") }

    private func rowContent(_ item: SavedItemsStore.SavedItem) -> some View {
        HStack {
            Image(systemName: icon(for: item.kind))
                .foregroundStyle(AppColors.dutchOrange)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                if let subtitle = item.displaySubtitle(lang), !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Button {
                savedStore.remove(item.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(AppColors.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t("common.remove_bookmark", lang))
        }
        .appCardStyle()
    }

    private func icon(for kind: SavedItemsStore.SavedItemKind) -> String {
        switch kind {
        case .rule: return "exclamationmark.octagon.fill"
        case .city: return "building.2.fill"
        case .institution: return "building.columns.fill"
        case .document: return "doc.text.fill"
        case .resource: return "link.circle.fill"
        case .place: return "map.fill"
        case .other: return "bookmark.fill"
        }
    }

    private func title(for kind: SavedItemsStore.SavedItemKind) -> String {
        switch (kind, lang) {
        case (.rule, .russian): return "Правила и штрафы"
        case (.city, .russian): return "Города"
        case (.institution, .russian): return "Организации"
        case (.document, .russian): return "Документы"
        case (.resource, .russian): return "Ресурсы"
        case (.place, .russian): return "Места рядом"
        case (.other, .russian): return "Другое"
        case (.rule, .dutch): return "Regels en boetes"
        case (.city, .dutch): return "Steden"
        case (.institution, .dutch): return "Instellingen"
        case (.document, .dutch): return "Documenten"
        case (.resource, .dutch): return "Bronnen"
        case (.place, .dutch): return "Locaties in de buurt"
        case (.other, .dutch): return "Overig"
        case (.rule, .english): return "Rules and fines"
        case (.city, .english): return "Cities"
        case (.institution, .english): return "Institutions"
        case (.document, .english): return "Documents"
        case (.resource, .english): return "Resources"
        case (.place, .english): return "Nearby places"
        case (.other, .english): return "Other"
        }
    }

    private var subtitleText: String {
        switch lang {
        case .russian: return "Сохранённые правила, места и материалы"
        case .english: return "Saved rules, places, and resources"
        case .dutch: return "Opgeslagen regels, locaties en bronnen"
        }
    }

    private var savedHeroBadge: String {
        switch lang {
        case .russian: return "Ваша библиотека"
        case .english: return "Your library"
        case .dutch: return "Jouw bibliotheek"
        }
    }

    private var emptyTitle: String {
        switch lang {
        case .russian: return "Сохраняйте полезное по мере просмотра"
        case .english: return "Save useful items as you explore"
        case .dutch: return "Bewaar nuttige items terwijl je verkent"
        }
    }

    private var emptyDetail: String {
        switch lang {
        case .russian: return "Нажимайте на иконку закладки в карточках, чтобы собрать важное в одном месте."
        case .english: return "Use bookmark icons in cards to collect important items here."
        case .dutch: return "Gebruik bladwijzericonen in kaarten om belangrijke items hier te bewaren."
        }
    }

    private var emptyQuickActionsTitle: String {
        switch lang {
        case .russian: return "Начните отсюда"
        case .english: return "Start from here"
        case .dutch: return "Begin hier"
        }
    }

    private var emptyQuickActionsSubtitle: String {
        switch lang {
        case .russian: return "Откройте раздел и сохраните нужные карточки по пути."
        case .english: return "Open a section and bookmark useful cards as you go."
        case .dutch: return "Open een onderdeel en bewaar nuttige kaarten onderweg."
        }
    }

    private var starterPackTitle: String {
        switch lang {
        case .russian: return "Стартовый набор новичка"
        case .english: return "Newcomer starter pack"
        case .dutch: return "Startpakket voor nieuwkomers"
        }
    }

    private var starterPackDetail: String {
        switch lang {
        case .russian: return "Добавьте базовые темы в Saved одним нажатием: регистрация, DigiD и медицинская страховка."
        case .english: return "Add the basics to Saved in one tap: registration, DigiD, and health insurance."
        case .dutch: return "Bewaar de basis in een tik: registratie, DigiD en zorgverzekering."
        }
    }

    private var starterPackButtonTitle: String {
        switch lang {
        case .russian: return "Сохранить стартовый набор"
        case .english: return "Save starter pack"
        case .dutch: return "Startpakket bewaren"
        }
    }

    private var emptyActions: [EmptySavedAction] {
        [
            EmptySavedAction(
                id: "guide",
                title: emptyActionTitle(en: "Open Guide", nl: "Open Gids", ru: "Открыть гид"),
                subtitle: emptyActionTitle(en: "Browse practical topics", nl: "Bekijk praktische onderwerpen", ru: "Выберите полезную тему"),
                symbol: "books.vertical.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            EmptySavedAction(
                id: "places",
                title: emptyActionTitle(en: "Find places", nl: "Vind plaatsen", ru: "Найти места"),
                subtitle: emptyActionTitle(en: "Explore nearby services", nl: "Bekijk diensten dichtbij", ru: "Посмотрите сервисы рядом"),
                symbol: "map.fill",
                tint: AppColors.emerald,
                destination: .mapHub
            ),
            EmptySavedAction(
                id: "cities",
                title: emptyActionTitle(en: "Cities", nl: "Steden", ru: "Города"),
                subtitle: emptyActionTitle(en: "Find local city guidance", nl: "Vind lokale stadshulp", ru: "Найдите советы по городу"),
                symbol: "building.2.fill",
                tint: AppColors.softBlue,
                destination: .cityList
            ),
            EmptySavedAction(
                id: "documents",
                title: emptyActionTitle(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: emptyActionTitle(en: "Organize letters and proof", nl: "Orden brieven en bewijs", ru: "Соберите письма и подтверждения"),
                symbol: "doc.text.fill",
                tint: AppColors.dutchOrange,
                destination: .journeyDocuments
            ),
            EmptySavedAction(
                id: "official",
                title: emptyActionTitle(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: emptyActionTitle(en: "Keep trusted links close", nl: "Houd betrouwbare links dichtbij", ru: "Держите проверенные ссылки рядом"),
                symbol: "checkmark.shield.fill",
                tint: AppColors.cyanGlow,
                destination: .officialSources
            )
        ]
    }

    private var starterPackAnswers: [SearchAnswer] {
        Self.starterPackAnswers(activePersona: activePersona)
    }

    private func saveStarterPack() {
        for answer in starterPackAnswers {
            let item = Self.starterPackSavedItem(for: answer)
            if !savedStore.isSaved(item.id) {
                savedStore.toggle(item: item)
            }
        }
    }

    static func starterPackAnswers(activePersona: PersonaTag?) -> [SearchAnswer] {
        let questions = [
            "How do I get a BSN?",
            "How do I activate DigiD?",
            "Do I need health insurance?"
        ]

        return questions.compactMap { question in
            MockSearchAnswersData.items.first { $0.title(.english) == question }
        }
        .filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    static func starterPackSavedItem(for answer: SearchAnswer) -> SavedItemsStore.SavedItem {
        SavedItemsStore.SavedItem(
            id: "starter-search-answer::\(answer.id.uuidString.lowercased())",
            kind: .resource,
            title: answer.title(.english),
            subtitle: answer.category.localized(.english),
            destination: .searchAnswer(answer.id),
            savedAt: Date()
        )
    }

    private func emptyActionTitle(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct EmptySavedAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let destination: AppDestination
}
