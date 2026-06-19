import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

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
                    InfoCard(
                        title: L10n.t("checklist.status", lang),
                        subtitle: L10n.t("checklist.all_completed", lang),
                        detail: AppEmptyStates.checklistComplete(lang),
                        icon: "checkmark.seal"
                    )
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
}
