import SwiftUI

struct MistakesLibraryView: View {
    @State private var selectedCategory: MistakeCategory? = nil
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var visibleCategories: [MistakeCategory] {
        Array(Set(visibleItems.map(\.category))).sorted { $0.rawValue < $1.rawValue }
    }

    private var visibleItems: [NewcomerMistake] {
        MockNewcomerMistakesData.items.filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }
    }

    private var filtered: [NewcomerMistake] {
        guard let cat = selectedCategory, visibleCategories.contains(cat) else { return visibleItems }
        return visibleItems.filter { $0.category == cat }
    }

    private var hasActiveFilters: Bool {
        selectedCategory != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: L10n.t("mistakes.disclaimer", lang))

                SectionHeader(
                    title: L10n.t("mistakes.top_title", lang),
                    subtitle: String(format: L10n.t("mistakes.top_subtitle", lang), visibleItems.count)
                )

                categoryFilterBar

                if filtered.isEmpty {
                    emptyMistakesDashboard
                } else {
                    ForEach(filtered) { item in
                        NavigationLink(value: AppDestination.mistake(item.id)) {
                            mistakeCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }

                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("resources.common_mistakes", lang))
        .animation(AppAnimations.standard, value: selectedCategory)
    }

    private var emptyMistakesDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            InfoCard(
                title: emptyMistakesTitle,
                subtitle: emptyMistakesSubtitle,
                detail: emptyMistakesDetail,
                icon: "exclamationmark.triangle.fill"
            )

            if hasActiveFilters {
                Button {
                    selectedCategory = nil
                } label: {
                    Label(emptyMistakesResetTitle, systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .accessibilityIdentifier("mistakes.empty.reset")
            }

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(emptyMistakeActions) { action in
                    NavigationLink(value: action.destination) {
                        MistakeRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("mistakes.empty.action.\(action.id)")
                }
            }
        }
        .accessibilityIdentifier("mistakes.empty.dashboard")
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.small) {
                filterChip(title: L10n.t("common.all", lang), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(visibleCategories) { cat in
                    filterChip(title: cat.localized(lang), isSelected: selectedCategory == cat) {
                        selectedCategory = (selectedCategory == cat) ? nil : cat
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.dutchOrange : AppColors.chipBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func mistakeCard(item: NewcomerMistake) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: item.title(lang),
                asset: mistakeImageAsset(for: item.category),
                language: lang,
                symbol: item.category.systemImageName,
                accent: riskColor(item.riskLevel),
                height: 92,
                width: 104,
                cornerRadius: 18,
                fallbackCategory: mistakeFallbackCategory(for: item.category)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .center, spacing: 8) {
                    Text(item.category.localized(lang))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    riskBadge(item.riskLevel)
                }

                Text(item.title(lang))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(item.whyItMatters(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
        .appCardStyle()
    }

    private func mistakeImageAsset(for category: MistakeCategory) -> AppImageAsset? {
        switch category {
        case .documents, .legalLetters:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .deadlines:
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.officialSourcesHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .healthInsurance:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .taxes, .municipality:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.governmentBasicsImage
        case .transport:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .scams:
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero
        }
    }

    private func mistakeFallbackCategory(for category: MistakeCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .documents, .legalLetters:
            return .documents
        case .deadlines, .municipality, .taxes:
            return .government
        case .housing:
            return .housing
        case .healthInsurance:
            return .healthcare
        case .work:
            return .work
        case .transport:
            return .transport
        case .scams:
            return .search
        case .education:
            return .dutchA1A2
        }
    }

    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.dutchOrange
        case .urgent: return AppColors.error
        }
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color = riskColor(level)
        return Text(level.localized(lang))
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var emptyMistakesTitle: String {
        localized(en: "Use a safer route", nl: "Gebruik een veiligere route", ru: "Откройте безопасный маршрут")
    }

    private var emptyMistakesSubtitle: String {
        localized(en: "Try a safer route", nl: "Probeer een veiligere route", ru: "Попробуйте безопасный маршрут")
    }

    private var emptyMistakesDetail: String {
        localized(
            en: "Clear the category or start from scam safety, official sources, or legal support.",
            nl: "Wis de categorie of begin met oplichting voorkomen, officiële bronnen of juridische hulp.",
            ru: "Сбросьте категорию или начните с защиты от мошенников, официальных источников или юридической помощи."
        )
    }

    private var emptyMistakesResetTitle: String {
        localized(en: "Show all mistakes", nl: "Toon alle fouten", ru: "Показать все ошибки")
    }

    private var emptyMistakeActions: [MistakeRecoveryAction] {
        [
            MistakeRecoveryAction(
                id: "scams",
                title: L10n.t("resources.scam_safety", lang),
                subtitle: localized(en: "Check common fraud patterns.", nl: "Controleer veelvoorkomende fraude.", ru: "Проверьте частые схемы мошенничества."),
                icon: "shield.lefthalf.filled",
                tint: AppColors.error,
                destination: .scamWarningsList
            ),
            MistakeRecoveryAction(
                id: "sources",
                title: L10n.t("settings.sources", lang),
                subtitle: localized(en: "Verify current rules before acting.", nl: "Controleer actuele regels voordat je handelt.", ru: "Проверьте актуальные правила перед действием."),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                destination: .officialSources
            ),
            MistakeRecoveryAction(
                id: "search",
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search for the situation or institution.", nl: "Zoek op situatie of instantie.", ru: "Ищите ситуацию или учреждение."),
                icon: "magnifyingglass.circle.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            MistakeRecoveryAction(
                id: "legal",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Use support for disputes, fines, or urgent issues.", nl: "Gebruik hulp bij geschillen, boetes of urgente zaken.", ru: "Используйте помощь для споров, штрафов или срочных вопросов."),
                icon: "person.fill.questionmark",
                tint: AppColors.violet,
                destination: .legalHelp
            )
        ]
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

// MARK: - Detail View

private struct MistakeRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct MistakeRecoveryActionCard: View {
    let action: MistakeRecoveryAction

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

struct NewcomerMistakeDetailView: View {
    let item: NewcomerMistake
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var relatedItems: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: item)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [L10n.t("tab.home", lang), L10n.t("resources.common_mistakes", lang), item.title(lang)])
                headerSection
                whySection
                consequenceSection
                preventSection
                if let sourceName = item.officialSourceName, let sourceURL = item.officialSourceURL {
                    sourceSection(name: sourceName, url: sourceURL)
                }
                RelatedContentSection(title: L10n.t("map.related_guides", lang), items: relatedItems)
                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("mistakes.detail", lang))
#if os(iOS)
        .nlNavigationInline()
#endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SaveItemButton(
                    itemID: item.id.uuidString,
                    kind: .other,
                    title: item.title(lang),
                    subtitle: item.category.localized(lang),
                    destination: .mistake(item.id)
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            PremiumImageHeader(
                title: item.title(lang),
                asset: mistakeImageAsset(for: item.category),
                language: lang,
                symbol: item.category.systemImageName,
                accent: riskColor(item.riskLevel),
                height: 178,
                cornerRadius: 22,
                fallbackCategory: mistakeFallbackCategory(for: item.category)
            )

            HStack {
                Text(item.category.localized(lang))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.chipBackground)
                    .clipShape(Capsule())
                Spacer()
                riskBadge(item.riskLevel)
            }
            Text(item.title(lang))
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
        }
        .appCardStyle()
    }

    private func mistakeImageAsset(for category: MistakeCategory) -> AppImageAsset? {
        switch category {
        case .documents, .legalLetters:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .deadlines:
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.officialSourcesHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .healthInsurance:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .taxes, .municipality:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.governmentBasicsImage
        case .transport:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .scams:
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero
        }
    }

    private func mistakeFallbackCategory(for category: MistakeCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .documents, .legalLetters:
            return .documents
        case .deadlines, .municipality, .taxes:
            return .government
        case .housing:
            return .housing
        case .healthInsurance:
            return .healthcare
        case .work:
            return .work
        case .transport:
            return .transport
        case .scams:
            return .search
        case .education:
            return .dutchA1A2
        }
    }

    private var whySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("beginner.why_matters", lang))
            Text(item.whyItMatters(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }

    private var consequenceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("fines.possible_consequence", lang))
            Text(item.possibleConsequence(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.t("mistakes.educational_note", lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private var preventSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("mistakes.how_prevent", lang))
            Text(item.howToPrevent(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }

    private func sourceSection(name: String, url: URL) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("beginner.official_source", lang))
            Text(name)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            Button(L10n.t("beginner.open_official_source", lang)) {
                guard let safeURL = AppURL.validatedWebURL(url) else { return }
                openURL(safeURL)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            Text(L10n.t("mistakes.verify_rules", lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color = riskColor(level)
        return Text(level.localized(lang))
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return AppColors.success
        case .medium: return AppColors.warning
        case .high: return AppColors.dutchOrange
        case .urgent: return AppColors.error
        }
    }
}
