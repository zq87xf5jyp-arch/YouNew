import SwiftUI

struct LegalInfoView: View {
    @State private var selectedCategory: LegalInfoCategory? = nil
    @State private var searchText = ""
    @State private var selectedItem: LegalInfoItem? = nil
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleCategories: [LegalInfoCategory] {
        LegalInfoCategory.allCases.filter { category in
            MockLegalInfoData.items.contains {
                $0.category == category &&
                $0.isVisible(for: activePersona, scope: .currentAndUniversal)
            }
        }
    }

    private var filtered: [LegalInfoItem] {
        var base = MockLegalInfoData.items.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
        if let cat = selectedCategory {
            base = base.filter { $0.category == cat }
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            base = base.filter {
                $0.title(lang).lowercased().contains(q) ||
                $0.shortSummary(lang).lowercased().contains(q) ||
                $0.keywords.contains(where: { $0.lowercased().contains(q) })
            }
        }
        return base
    }

    private var hasActiveFilters: Bool {
        selectedCategory != nil || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: AppDisclaimers.expanded)

                TextField(L10n.t("legal.search_placeholder", lang), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                categoryFilterBar

                if filtered.isEmpty {
                    noResultsDashboard
                } else {
                    ForEach(filtered) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            legalInfoCard(item: item)
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
        .navigationTitle(L10n.t("resources.legal_basics", lang))
        .animation(AppAnimations.standard, value: selectedCategory)
        .animation(AppAnimations.standard, value: searchText)
        .sheet(item: $selectedItem) { item in
            LegalInfoDetailView(item: item)
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.small) {
                categoryChip(title: L10n.t("common.all", lang), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(visibleCategories) { cat in
                    categoryChip(title: cat.localized(lang), isSelected: selectedCategory == cat) {
                        selectedCategory = (selectedCategory == cat) ? nil : cat
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.accent : AppColors.chipBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var noResultsDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            InfoCard(
                title: L10n.t("legal.no_results", lang),
                subtitle: legalNoResultsSubtitle,
                detail: legalNoResultsDetail,
                icon: "scalemass.fill"
            )

            if hasActiveFilters {
                Button {
                    searchText = ""
                    selectedCategory = nil
                } label: {
                    Label(legalResetFiltersTitle, systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .accessibilityIdentifier("legal.empty.reset")
            }

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(legalRecoveryActions) { action in
                    NavigationLink(value: action.destination) {
                        LegalRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("legal.empty.action.\(action.id)")
                }
            }
        }
        .accessibilityIdentifier("legal.empty.dashboard")
    }

    private func legalInfoCard(item: LegalInfoItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: item.title(lang),
                asset: legalImageAsset(for: item.category),
                language: lang,
                symbol: legalSymbol(for: item.category),
                accent: riskColor(item.riskLevel),
                height: 94,
                width: 106,
                cornerRadius: 18,
                fallbackCategory: legalFallbackCategory(for: item.category)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .center, spacing: 8) {
                    Text(item.category.localized(lang))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.accent)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    riskBadge(item.riskLevel)
                }

                Text(item.title(lang))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(item.shortSummary(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield")
                        .font(.caption2)
                        .foregroundStyle(AppColors.success)
                    Text(item.officialSourceName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(item.lastUpdated.formattedForAppLanguage(lang))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 142, alignment: .topLeading)
        .appCardStyle()
    }

    private func legalImageAsset(for category: LegalInfoCategory) -> AppImageAsset? {
        switch category {
        case .immigration, .municipality, .identity, .tax, .benefits, .legalHelp, .general:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport, .fines:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero
        case .emergency:
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        case .scams:
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func legalFallbackCategory(for category: LegalInfoCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .immigration, .municipality, .identity, .tax, .benefits, .legalHelp, .general:
            return .government
        case .work:
            return .work
        case .healthcare:
            return .healthcare
        case .housing:
            return .housing
        case .transport, .fines:
            return .transport
        case .education:
            return .dutchA1A2
        case .emergency:
            return .emergency
        case .scams:
            return .search
        }
    }

    private func legalSymbol(for category: LegalInfoCategory) -> String {
        switch category {
        case .immigration: return "person.text.rectangle.fill"
        case .municipality, .legalHelp, .general: return "building.columns.fill"
        case .identity: return "lock.shield.fill"
        case .work: return "briefcase.fill"
        case .tax: return "eurosign.circle.fill"
        case .benefits: return "hand.raised.fill"
        case .healthcare: return "cross.case.fill"
        case .housing: return "house.fill"
        case .transport: return "tram.fill"
        case .education: return "graduationcap.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .emergency: return "light.beacon.max.fill"
        case .scams: return "shield.lefthalf.filled"
        }
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color = riskColor(level)
        return Text(level.rawValue)
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

    private var legalNoResultsSubtitle: String {
        switch lang {
        case .russian: return "Попробуйте другой путь"
        case .dutch: return "Probeer een andere route"
        case .english: return "Try another route"
        }
    }

    private var legalNoResultsDetail: String {
        switch lang {
        case .russian: return "Сбросьте фильтр или откройте проверенные источники. Для срочных или личных ситуаций используйте официальную юридическую помощь."
        case .dutch: return "Wis de filter of open betrouwbare bronnen. Gebruik officiële juridische hulp voor dringende of persoonlijke situaties."
        case .english: return "Reset the filter or open verified sources. Use official legal help for urgent or personal situations."
        }
    }

    private var legalResetFiltersTitle: String {
        switch lang {
        case .russian: return "Сбросить фильтр"
        case .dutch: return "Filter wissen"
        case .english: return "Reset filter"
        }
    }

    private var legalRecoveryActions: [LegalRecoveryAction] {
        [
            LegalRecoveryAction(
                id: "search",
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search broader newcomer answers.", nl: "Zoek bredere antwoorden voor nieuwkomers.", ru: "Искать шире по ответам для новичков."),
                icon: "magnifyingglass.circle.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            LegalRecoveryAction(
                id: "sources",
                title: L10n.t("settings.sources", lang),
                subtitle: localized(en: "Verify rules on official websites.", nl: "Controleer regels op officiële websites.", ru: "Проверьте правила на официальных сайтах."),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                destination: .officialSources
            ),
            LegalRecoveryAction(
                id: "legal-help",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Find support for personal situations.", nl: "Vind hulp voor persoonlijke situaties.", ru: "Найдите помощь для личной ситуации."),
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

private struct LegalRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct LegalRecoveryActionCard: View {
    let action: LegalRecoveryAction

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

private struct LegalInfoDetailView: View {
    let item: LegalInfoItem
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    DisclaimerBanner(text: item.localizedDisclaimer(lang), tone: AppColors.error)

                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        PremiumImageHeader(
                            title: item.title(lang),
                            asset: legalImageAsset(for: item.category),
                            language: lang,
                            symbol: legalSymbol(for: item.category),
                            accent: riskColor(item.riskLevel),
                            height: 184,
                            cornerRadius: 22,
                            fallbackCategory: legalFallbackCategory(for: item.category)
                        )

                        HStack {
                            Text(item.category.localized(lang))
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.accent)
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

                        Text(item.shortSummary(lang))
                            .font(AppTypography.bodyLeading)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("legal.explanation", lang))
                        Text(item.beginnerExplanation(lang))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .appCardStyle()

                    officialSourceSection

                    OutdatedInfoReportCard()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
                .tabBarScrollReserve()
            }
            .appSceneBackground()
            .navigationTitle(L10n.t("legal.info", lang))
#if os(iOS)
            .nlNavigationInline()
#endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(L10n.t("common.done", lang)) { dismiss() }
                }
            }
        }
    }

    private var officialSourceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("beginner.official_source", lang))
            HStack {
                Image(systemName: "building.columns")
                    .foregroundStyle(AppColors.accent)
                Text(item.officialSourceName)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
            }
            if let institution = item.relatedInstitution {
                Text(String(format: L10n.t("legal.related_institution", lang), institution))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(String(format: L10n.t("legal.last_updated", lang), item.lastUpdated.formattedForAppLanguage(lang)))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            if let url = AppURL.validatedWebURL(item.officialSourceURL) {
                Button(L10n.t("beginner.open_official_source", lang)) {
                    openURL(url)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
            }
            Text(L10n.t("legal.start_here_verify", lang))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func legalImageAsset(for category: LegalInfoCategory) -> AppImageAsset? {
        switch category {
        case .immigration, .municipality, .identity, .tax, .benefits, .legalHelp, .general:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport, .fines:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.cultureHero
        case .emergency:
            return ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero
        case .scams:
            return ContentMediaRegistry.searchImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func legalFallbackCategory(for category: LegalInfoCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .immigration, .municipality, .identity, .tax, .benefits, .legalHelp, .general:
            return .government
        case .work:
            return .work
        case .healthcare:
            return .healthcare
        case .housing:
            return .housing
        case .transport, .fines:
            return .transport
        case .education:
            return .dutchA1A2
        case .emergency:
            return .emergency
        case .scams:
            return .search
        }
    }

    private func legalSymbol(for category: LegalInfoCategory) -> String {
        switch category {
        case .immigration: return "person.text.rectangle.fill"
        case .municipality, .legalHelp, .general: return "building.columns.fill"
        case .identity: return "lock.shield.fill"
        case .work: return "briefcase.fill"
        case .tax: return "eurosign.circle.fill"
        case .benefits: return "hand.raised.fill"
        case .healthcare: return "cross.case.fill"
        case .housing: return "house.fill"
        case .transport: return "tram.fill"
        case .education: return "graduationcap.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .emergency: return "light.beacon.max.fill"
        case .scams: return "shield.lefthalf.filled"
        }
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color = riskColor(level)
        return Text(level.rawValue)
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
