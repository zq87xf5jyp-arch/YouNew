import SwiftUI

struct DutchTermsView: View {
    @State private var selectedCategory: DutchTermCategory? = nil
    @State private var searchText = ""
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

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
                    Text(L10n.t("dutch_terms.no_terms", languageManager.appLanguage))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .appCardStyle()
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

    private func termCard(term: DutchTerm) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(term.dutchTerm)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(term.category.localizedTitle(languageManager.appLanguage))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.accent)
                }
                Spacer()
                if term.hasLegalFinancialWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppColors.warning)
                        .font(.caption)
                }
            }

            Text(term.localizedExplanation(languageManager.appLanguage))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }
}

// MARK: - Detail View

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
