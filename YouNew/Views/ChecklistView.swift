import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showCompletionConfetti = false

    private var lang: AppLanguage { languageManager.appLanguage }

    private var prioritized: AppStateViewModel.PrioritizedChecklist {
        appState.prioritizedChecklist
    }

    private var allItems: [ChecklistItem] { appState.visibleChecklistItems }

    private var nextStep: ChecklistItem? {
        (prioritized.recommended.isEmpty ? allItems : prioritized.recommended)
            .first(where: { !$0.isCompleted })
    }

    private var progress: Double {
        guard !allItems.isEmpty else { return 0 }
        return Double(allItems.filter(\.isCompleted).count) / Double(allItems.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                checklistHero

                ProgressCard(
                    title: L10n.t("checklist.progress_summary", lang),
                    progress: progress,
                    completedCount: allItems.filter(\.isCompleted).count,
                    totalCount: allItems.count
                )

                if let nextStep {
                    InfoCard(
                        title: L10n.t("common.possible_next_step", lang),
                        subtitle: nextStep.title(lang),
                        detail: nextStep.description(lang),
                        icon: "flag"
                    )
                } else {
                    checklistCompleteDashboard
                }

                DisclaimerBanner(text: L10n.t("disclaimer.short", lang))

                if appState.selectedUserStatus != nil && !prioritized.recommended.isEmpty {
                    if let rationale = prioritized.rationaleByLanguage[lang] {
                        InfoCard(
                            title: L10n.t("checklist.based_on_status", lang),
                            subtitle: L10n.t("common.learn_more", lang),
                            detail: rationale,
                            icon: "person.text.rectangle"
                        )
                    }

                    checklistSection(
                        title: L10n.t("checklist.recommended_for_you", lang),
                        subtitle: L10n.t("checklist.based_on_status", lang),
                        items: prioritized.recommended
                    )

                    if !prioritized.later.isEmpty {
                        checklistSection(
                            title: L10n.t("checklist.might_need_later", lang),
                            subtitle: nil,
                            items: prioritized.later
                        )
                    }
                } else {
                    let grouped = Dictionary(grouping: allItems, by: { $0.category })
                        .sorted { $0.key.rawValue < $1.key.rawValue }
                    ForEach(grouped, id: \.0.rawValue) { category, items in
                        checklistSection(
                            title: category.localized(lang),
                            subtitle: "\(items.filter(\.isCompleted).count)/\(items.count) \(L10n.t("checklist.completed_suffix", lang))",
                            items: items
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("checklist.title", lang))
        .overlay {
            AchievementConfetti(visible: showCompletionConfetti)
        }
        .onChange(of: progress) { oldValue, newValue in
            if oldValue < 1, newValue == 1 {
                showCompletionConfetti = true
            } else if newValue < 1 {
                showCompletionConfetti = false
            }
        }
    }

    private var checklistHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("checklist.title", lang),
            subtitle: checklistHeroSubtitle,
            symbol: "checklist.checked",
            badgeText: checklistHeroBadge,
            accent: AppColors.success,
            asset: ContentMediaRegistry.profileImage ?? ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("checklist.hero")
    }

    private var checklistCompleteDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(AppColors.success)
                    .frame(width: 52, height: 52)
                    .background(AppColors.success.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.t("checklist.all_completed", lang))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(AppEmptyStates.checklistComplete(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 10)], spacing: 10) {
                ForEach(checklistCompleteActions) { action in
                    NavigationLink(value: action.destination) {
                        ChecklistRecoveryActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("checklist.complete.action.\(action.id)")
                }
            }
        }
        .appCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("checklist.complete.dashboard")
    }

    private var checklistCompleteActions: [ChecklistRecoveryAction] {
        [
            ChecklistRecoveryAction(
                id: "first-steps",
                icon: "list.bullet.clipboard.fill",
                title: localized(en: "Review first steps", nl: "Eerste stappen bekijken", ru: "Проверить первые шаги"),
                subtitle: localized(en: "Registration, DigiD, care", nl: "Inschrijving, DigiD, zorg", ru: "Регистрация, DigiD, медицина"),
                color: AppColors.success,
                destination: .firstSteps
            ),
            ChecklistRecoveryAction(
                id: "documents",
                icon: "folder.fill",
                title: localized(en: "Organize documents", nl: "Documenten ordenen", ru: "Разобрать документы"),
                subtitle: localized(en: "Files, scans, letters", nl: "Bestanden, scans, brieven", ru: "Файлы, сканы, письма"),
                color: AppColors.softBlue,
                destination: .journeyDocuments
            ),
            ChecklistRecoveryAction(
                id: "sources",
                icon: "checkmark.shield.fill",
                title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Официальные источники"),
                subtitle: localized(en: "Verify before acting", nl: "Controleer voordat u handelt", ru: "Проверяйте перед действием"),
                color: AppColors.dutchOrange,
                destination: .officialSources
            ),
            ChecklistRecoveryAction(
                id: "search",
                icon: "magnifyingglass.circle.fill",
                title: localized(en: "Search knowledge", nl: "Kennis zoeken", ru: "Поиск знаний"),
                subtitle: localized(en: "Find the next topic", nl: "Vind het volgende onderwerp", ru: "Найти следующую тему"),
                color: AppColors.violet,
                destination: .searchList
            )
        ]
    }

    @ViewBuilder
    private func checklistSection(title: String, subtitle: String?, items: [ChecklistItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(
                title: title,
                subtitle: subtitle ?? "\(items.filter(\.isCompleted).count)/\(items.count) \(L10n.t("checklist.completed_suffix", lang))"
            )

            ForEach(items) { item in
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    ChecklistRow(item: item) {
                        appState.toggleChecklistItem(item)
                    }
                    SmartNavigationRow(
                        title: L10n.t("checklist.open_step_guide", lang),
                        subtitle: L10n.t("checklist.open_step_guide_subtitle", lang),
                        symbol: "arrow.right.circle",
                        destination: .checklist(item.id)
                    )
                }
            }
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private var checklistHeroSubtitle: String {
        switch lang {
        case .russian: return "Ваши следующие шаги, документы и проверки в одном спокойном маршруте."
        case .dutch: return "Uw volgende stappen, documenten en controles in een rustige route."
        case .english: return "Your next steps, documents, and checks in one calm path."
        }
    }

    private var checklistHeroBadge: String {
        switch lang {
        case .russian: return "Следующие шаги"
        case .dutch: return "Volgende stappen"
        case .english: return "Next steps"
        }
    }
}

private struct ChecklistRecoveryAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct ChecklistRecoveryActionCard: View {
    let action: ChecklistRecoveryAction

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
