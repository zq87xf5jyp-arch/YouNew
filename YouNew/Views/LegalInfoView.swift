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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: AppDisclaimers.expanded)

                TextField(L10n.t("legal.search_placeholder", lang), text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                categoryFilterBar

                if filtered.isEmpty {
                    Text(L10n.t("legal.no_results", lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .appCardStyle()
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

    private func legalInfoCard(item: LegalInfoItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(item.title(lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(item.category.localized(lang))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.accent)
                }
                Spacer()
                riskBadge(item.riskLevel)
            }

            Text(item.shortSummary(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            HStack {
                Image(systemName: "checkmark.shield")
                    .font(.caption2)
                    .foregroundStyle(AppColors.success)
                Text(item.officialSourceName)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text(item.lastUpdated.formattedForAppLanguage(lang))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color: Color = {
            switch level {
            case .low: return AppColors.success
            case .medium: return AppColors.warning
            case .high: return AppColors.dutchOrange
            case .urgent: return AppColors.error
            }
        }()
        return Text(level.rawValue)
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Detail View

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

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color: Color = {
            switch level {
            case .low: return AppColors.success
            case .medium: return AppColors.warning
            case .high: return AppColors.dutchOrange
            case .urgent: return AppColors.error
            }
        }()
        return Text(level.rawValue)
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
