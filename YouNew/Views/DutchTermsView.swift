import SwiftUI

struct DutchTermsView: View {
    @State private var selectedCategory: DutchTermCategory? = nil
    @State private var searchText = ""
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var lang: AppLanguage { languageManager.appLanguage }

    private var filtered: [DutchTerm] {
        var base = MockDutchTermsData.items.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
        if let cat = selectedCategory {
            base = base.filter { $0.category == cat }
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            base = base.filter {
                $0.dutchTerm.lowercased().contains(q) ||
                $0.localizedExplanation(languageManager.appLanguage).lowercased().contains(q) ||
                $0.localizedNewcomerExplanation(languageManager.appLanguage).lowercased().contains(q) ||
                $0.category.localizedTitle(languageManager.appLanguage).lowercased().contains(q)
            }
        }
        return base.sorted { $0.dutchTerm < $1.dutchTerm }
    }

    private var hasActiveFilters: Bool {
        selectedCategory != nil || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [L10n.t("tab.home", languageManager.appLanguage), L10n.t("resources.dutch_terms", languageManager.appLanguage)])
                DisclaimerBanner(text: L10n.t("dutch_terms.disclaimer", languageManager.appLanguage))

                TextField(L10n.t("dutch_terms.search_placeholder", languageManager.appLanguage), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                categoryFilterBar

                if filtered.isEmpty {
                    noTermsDashboard
                } else {
                    ForEach(filtered) { term in
                        NavigationLink(value: AppDestination.dutchTerm(term.id)) {
                            termCard(term: term)
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
        .navigationTitle(L10n.t("dutch_terms.nav_title", languageManager.appLanguage))
        .animation(AppAnimations.standard, value: selectedCategory)
        .animation(AppAnimations.standard, value: searchText)
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.small) {
                filterChip(title: L10n.t("common.all", languageManager.appLanguage), isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(DutchTermCategory.allCases.filter { category in
                    MockDutchTermsData.items.contains { $0.category == category && $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
                }) { cat in
                    filterChip(title: cat.localizedTitle(languageManager.appLanguage), isSelected: selectedCategory == cat) {
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
                .background(isSelected ? AppColors.accent : AppColors.chipBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var noTermsDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            InfoCard(
                title: L10n.t("dutch_terms.no_terms", lang),
                subtitle: noTermsSubtitle,
                detail: noTermsDetail,
                icon: "text.magnifyingglass"
            )

            if hasActiveFilters {
                Button {
                    searchText = ""
                    selectedCategory = nil
                } label: {
                    Label(resetTermsFilterTitle, systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryPremiumButtonStyle())
                .accessibilityIdentifier("dutchTerms.empty.reset")
            }

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(termRecoveryActions) { action in
                    NavigationLink(value: action.destination) {
                        DutchTermRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("dutchTerms.empty.action.\(action.id)")
                }
            }
        }
        .accessibilityIdentifier("dutchTerms.empty.dashboard")
    }

    private func termCard(term: DutchTerm) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: term.dutchTerm,
                asset: termImageAsset(for: term.category),
                language: lang,
                symbol: termSymbol(for: term.category),
                accent: termAccent(for: term),
                height: 92,
                width: 104,
                cornerRadius: 18,
                fallbackCategory: termFallbackCategory(for: term.category)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .center, spacing: 8) {
                    Text(term.category.localizedTitle(languageManager.appLanguage))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.accent)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    if term.hasLegalFinancialWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.warning)
                            .font(.caption.weight(.bold))
                    }
                }

                Text(term.dutchTerm)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(term.localizedExplanation(languageManager.appLanguage))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .appCardStyle()
    }

    private func termImageAsset(for category: DutchTermCategory) -> AppImageAsset? {
        switch category {
        case .administrative, .legal, .financial, .immigration, .social:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .transport:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func termFallbackCategory(for category: DutchTermCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .administrative, .legal, .financial, .immigration, .social:
            return .government
        case .healthcare:
            return .healthcare
        case .transport:
            return .transport
        case .housing:
            return .housing
        case .work:
            return .work
        }
    }

    private func termSymbol(for category: DutchTermCategory) -> String {
        switch category {
        case .administrative: return "building.columns.fill"
        case .legal: return "doc.text.magnifyingglass"
        case .financial: return "eurosign.circle.fill"
        case .immigration: return "person.text.rectangle.fill"
        case .social: return "person.2.fill"
        case .healthcare: return "cross.case.fill"
        case .transport: return "tram.fill"
        case .housing: return "house.fill"
        case .work: return "briefcase.fill"
        }
    }

    private func termAccent(for term: DutchTerm) -> Color {
        if term.hasLegalFinancialWarning { return AppColors.warning }
        switch term.category {
        case .administrative, .legal, .immigration, .social:
            return AppColors.softBlue
        case .financial:
            return AppColors.success
        case .healthcare:
            return AppColors.error
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .work:
            return AppColors.dutchOrange
        }
    }

    private var noTermsSubtitle: String {
        localized(en: "Try a learning route", nl: "Probeer een leerroute", ru: "Попробуйте учебный маршрут")
    }

    private var noTermsDetail: String {
        localized(
            en: "Clear the filter, search broader answers, or continue with Dutch A1-A2 practice.",
            nl: "Wis de filter, zoek breder of ga verder met Nederlands A1-A2.",
            ru: "Сбросьте фильтр, поищите шире или продолжите практику нидерландского A1-A2."
        )
    }

    private var resetTermsFilterTitle: String {
        localized(en: "Reset term search", nl: "Termzoekopdracht wissen", ru: "Сбросить поиск терминов")
    }

    private var termRecoveryActions: [DutchTermRecoveryAction] {
        [
            DutchTermRecoveryAction(
                id: "course",
                title: L10n.t("sideMenu.dutchA1A2", lang),
                subtitle: L10n.t("sideMenu.subtitle.dutchA1A2", lang),
                icon: "text.book.closed.fill",
                tint: AppColors.emerald,
                destination: .dutchA1A2
            ),
            DutchTermRecoveryAction(
                id: "search",
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search guides, answers, and official topics.", nl: "Zoek gidsen, antwoorden en officiële onderwerpen.", ru: "Искать гайды, ответы и официальные темы."),
                icon: "magnifyingglass.circle.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            DutchTermRecoveryAction(
                id: "sources",
                title: L10n.t("settings.sources", lang),
                subtitle: localized(en: "Check official vocabulary in context.", nl: "Controleer officiële woorden in context.", ru: "Проверьте официальные термины в контексте."),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                destination: .officialSources
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

private struct DutchTermRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct DutchTermRecoveryActionCard: View {
    let action: DutchTermRecoveryAction

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

struct DutchTermDetailView: View {
    let term: DutchTerm
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var relatedItems: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: term).filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private var mistakes: [NewcomerMistake] {
        RelatedContentEngine.commonMistakes(for: term).filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    private var relatedInstitutions: [Institution] {
        term.relatedInstitutionNames.compactMap { name in
            MockInstitutionsData.items.first(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame &&
                $0.isVisible(for: activePersona, scope: .currentAndUniversal)
            })
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [L10n.t("tab.home", languageManager.appLanguage), L10n.t("resources.dutch_terms", languageManager.appLanguage), term.dutchTerm])
                if term.hasLegalFinancialWarning {
                    DisclaimerBanner(text: L10n.t("dutch_terms.legal_warning", languageManager.appLanguage), tone: AppColors.warning)
                }

                termHeaderSection
                explanationSection

                if !relatedInstitutions.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("ai.related_institutions", languageManager.appLanguage))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.small) {
                                ForEach(relatedInstitutions, id: \.name) { inst in
                                    InstitutionChip(title: inst.name, destination: .institution(inst.name))
                                }
                            }
                        }
                    }
                }

                if let sourceName = term.officialSourceName, let sourceURL = term.officialSourceURL {
                    officialSourceSection(name: sourceName, url: sourceURL)
                }

                CommonMistakesSection(mistakes: mistakes)

                RelatedContentSection(title: L10n.t("beginner.related_topics", languageManager.appLanguage), items: relatedItems)

                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("dutch_terms.term", languageManager.appLanguage))
#if os(iOS)
        .nlNavigationInline()
#endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SaveItemButton(
                    itemID: term.id.uuidString,
                    kind: .other,
                    title: term.dutchTerm,
                    subtitle: term.category.localizedTitle(languageManager.appLanguage),
                    destination: .dutchTerm(term.id)
                )
            }
        }
    }

    private var termHeaderSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            PremiumImageHeader(
                title: term.dutchTerm,
                asset: termImageAsset(for: term.category),
                language: languageManager.appLanguage,
                symbol: termSymbol(for: term.category),
                accent: termAccent(for: term),
                height: 184,
                cornerRadius: 22,
                fallbackCategory: termFallbackCategory(for: term.category)
            )

            HStack {
                Text(term.category.localizedTitle(languageManager.appLanguage))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.chipBackground)
                    .clipShape(Capsule())
                Spacer()
                if term.hasLegalFinancialWarning {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text(L10n.t("dutch_terms.legal_financial", languageManager.appLanguage))
                            .font(AppTypography.metadata)
                    }
                    .foregroundStyle(AppColors.warning)
                }
            }

            Text(term.dutchTerm)
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text(term.localizedExplanation(languageManager.appLanguage))
                .font(AppTypography.bodyLeading)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }

    private func termImageAsset(for category: DutchTermCategory) -> AppImageAsset? {
        switch category {
        case .administrative, .legal, .financial, .immigration, .social:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare:
            return ContentMediaRegistry.healthInsuranceImage ?? ContentMediaRegistry.healthcareBasicsImage
        case .transport:
            return ContentMediaRegistry.ovChipkaartImage ?? ContentMediaRegistry.transportStationHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func termFallbackCategory(for category: DutchTermCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .administrative, .legal, .financial, .immigration, .social:
            return .government
        case .healthcare:
            return .healthcare
        case .transport:
            return .transport
        case .housing:
            return .housing
        case .work:
            return .work
        }
    }

    private func termSymbol(for category: DutchTermCategory) -> String {
        switch category {
        case .administrative: return "building.columns.fill"
        case .legal: return "doc.text.magnifyingglass"
        case .financial: return "eurosign.circle.fill"
        case .immigration: return "person.text.rectangle.fill"
        case .social: return "person.2.fill"
        case .healthcare: return "cross.case.fill"
        case .transport: return "tram.fill"
        case .housing: return "house.fill"
        case .work: return "briefcase.fill"
        }
    }

    private func termAccent(for term: DutchTerm) -> Color {
        if term.hasLegalFinancialWarning { return AppColors.warning }
        switch term.category {
        case .administrative, .legal, .immigration, .social:
            return AppColors.softBlue
        case .financial:
            return AppColors.success
        case .healthcare:
            return AppColors.error
        case .transport:
            return AppColors.routeLine
        case .housing:
            return AppColors.cyanGlow
        case .work:
            return AppColors.dutchOrange
        }
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("search.beginner_explanation", languageManager.appLanguage))
            Text(term.localizedNewcomerExplanation(languageManager.appLanguage))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCardStyle()
    }

    private func officialSourceSection(name: String, url: URL) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SectionHeader(title: L10n.t("beginner.official_source", languageManager.appLanguage))
            Text(name)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
            Button(L10n.t("beginner.open_official_source", languageManager.appLanguage)) {
                guard let safeURL = AppURL.validatedWebURL(url) else { return }
                openURL(safeURL)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            Text(L10n.t("legal.start_here_verify", languageManager.appLanguage))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle()
    }
}
