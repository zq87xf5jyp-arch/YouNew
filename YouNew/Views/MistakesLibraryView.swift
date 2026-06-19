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
                    Text(L10n.t("fines.no_items", lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .appCardStyle()
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
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top) {
                Image(systemName: item.category.systemImageName)
                    .font(.title3)
                    .foregroundStyle(riskColor(item.riskLevel))
                    .frame(width: 36, height: 36)
                    .background(riskColor(item.riskLevel).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(item.title(lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(item.category.localized(lang))
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                riskBadge(item.riskLevel)
            }

            Text(item.whyItMatters(lang))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardStyle()
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
}

// MARK: - Detail View

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
        let color: Color = {
            switch level {
            case .low: return AppColors.success
            case .medium: return AppColors.warning
            case .high: return AppColors.dutchOrange
            case .urgent: return AppColors.error
            }
        }()
        return Text(level.localized(lang))
            .font(AppTypography.metadata)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
