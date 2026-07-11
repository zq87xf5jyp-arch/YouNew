import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    private var groupedResources: [ResourceRelevanceBucket: [ResourceLinkItem]] {
        ResourceRelevanceEngine.resources(for: appState.selectedUserStatus, all: MockResourcesData.items)
    }

    private var hasVisibleResources: Bool {
        groupedResources.values.contains { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                resourcesHero

                if let status = appState.selectedUserStatus {
                    InfoCard(
                        title: L10n.t("checklist.recommended_for_you", lang),
                        subtitle: status.localized(lang),
                        detail: profileResourceContextText(status),
                        icon: status.icon
                    )
                }

                if hasVisibleResources {
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
                } else {
                    emptyResourcesDashboard
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("resources.title", lang))
    }

    private var resourcesHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("resources.title", lang),
            subtitle: L10n.t("resources.subtitle", lang),
            symbol: "books.vertical.fill",
            badgeText: resourcesHeroBadge,
            accent: AppColors.softBlue,
            asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("resources.hero")
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

    private var emptyResourcesDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(AppColors.dutchOrange)
                    .frame(width: 52, height: 52)
                    .background(AppColors.dutchOrange.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(localized(en: "Continue with trusted routes", nl: "Ga verder met vertrouwde routes", ru: "Продолжайте через проверенные маршруты"))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(localized(en: "Open official sources, search by topic, prepare documents, or review legal basics from here.", nl: "Open officiële bronnen, zoek op onderwerp, bereid documenten voor of bekijk juridische basisinformatie.", ru: "Откройте официальные источники, поиск по теме, документы или базовые юридические материалы."))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 10)], spacing: 10) {
                ForEach(emptyResourceActions) { action in
                    NavigationLink(value: action.destination) {
                        ResourceRecoveryActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("resources.empty.action.\(action.id)")
                }
            }
        }
        .appCardStyle()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("resources.empty.dashboard")
    }

    private var emptyResourceActions: [ResourceRecoveryAction] {
        [
            ResourceRecoveryAction(
                id: "official",
                icon: "checkmark.shield.fill",
                title: L10n.t("resources.official_sources", lang),
                subtitle: localized(en: "Government and public services", nl: "Overheid en publieke diensten", ru: "Государство и публичные службы"),
                color: AppColors.success,
                destination: .officialSources
            ),
            ResourceRecoveryAction(
                id: "search",
                icon: "magnifyingglass.circle.fill",
                title: L10n.t("resources.question_search", lang),
                subtitle: localized(en: "Find answers by topic", nl: "Zoek antwoorden per onderwerp", ru: "Найти ответы по теме"),
                color: AppColors.dutchOrange,
                destination: .searchList
            ),
            ResourceRecoveryAction(
                id: "documents",
                icon: "folder.fill",
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Prepare files and letters", nl: "Bereid bestanden en brieven voor", ru: "Подготовить файлы и письма"),
                color: AppColors.softBlue,
                destination: .journeyDocuments
            ),
            ResourceRecoveryAction(
                id: "legal",
                icon: "scalemass.fill",
                title: L10n.t("resources.legal_basics", lang),
                subtitle: localized(en: "Rights and help routes", nl: "Rechten en hulproutes", ru: "Права и маршруты помощи"),
                color: AppColors.violet,
                destination: .legalHelp
            )
        ]
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

    private var resourcesHeroBadge: String {
        switch lang {
        case .russian: return "Гайды и источники"
        case .dutch: return "Gidsen en bronnen"
        case .english: return "Guides and sources"
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }
}

private struct ResourceRecoveryAction: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AppDestination
}

private struct ResourceRecoveryActionCard: View {
    let action: ResourceRecoveryAction

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
