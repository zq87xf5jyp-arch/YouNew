import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private var groupedResources: [ResourceRelevanceBucket: [ResourceLinkItem]] {
        ResourceRelevanceEngine.resources(for: appState.selectedUserStatus, all: MockResourcesData.items)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                SectionHeader(title: L10n.t("resources.title", lang), subtitle: L10n.t("resources.subtitle", lang))

                if let status = appState.selectedUserStatus {
                    InfoCard(
                        title: L10n.t("checklist.recommended_for_you", lang),
                        subtitle: status.localized(lang),
                        detail: profileResourceContextText(status),
                        icon: status.icon
                    )
                }

                resourceSection(
                    title: sectionTitle(for: .recommendedNow),
                    items: groupedResources[.recommendedNow] ?? []
                )

                resourceSection(
                    title: sectionTitle(for: .usefulLater),
                    items: groupedResources[.usefulLater] ?? []
                )

                resourceSection(
                    title: sectionTitle(for: .scamSafety),
                    items: groupedResources[.scamSafety] ?? []
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("resources.title", lang))
    }

    @ViewBuilder
    private func resourceSection(title: String, items: [ResourceLinkItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                SectionHeader(title: title)
                ForEach(items) { item in
                    ResourceCard(item: item)
                }
            }
        }
    }

    private func sectionTitle(for bucket: ResourceRelevanceBucket) -> String {
        switch bucket {
        case .recommendedNow: return L10n.t("resources.recommended_now", lang)
        case .usefulLater:    return L10n.t("resources.useful_later", lang)
        case .scamSafety:     return L10n.t("resources.scam_safety", lang)
        }
    }

    private func profileResourceContextText(_ status: UserStatus) -> String {
        let blueprint = ProfileBlueprint.forStatus(status)
        let top = blueprint.topPriorities.prefix(3).compactMap { $0.text[lang] }.joined(separator: ", ")
        return String(format: L10n.t("resources.context_text", lang), top)
    }
}
