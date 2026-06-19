import SwiftUI

struct InstitutionsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var visibleInstitutions: [Institution] {
        MockInstitutionsData.items.filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                heroSection

                DisclaimerBanner(text: L10n.t("disclaimer.medium", lang))

                NavigationLink(L10n.t("institutions.find_questions", lang)) {
                    SearchView(viewModel: SearchViewModel(
                        initialQuery: "What is IND?",
                        language: lang,
                        activePersona: appState.selectedUserStatus?.personaTag,
                        personaSearchScope: .currentAndUniversal
                    ))
                }
                .premiumNetherlandsCard(cornerRadius: 18, accent: AppColors.cyanGlow)

                SectionHeader(
                    title: L10n.t("institutions.title", lang),
                    subtitle: L10n.t("institutions.subtitle", lang)
                )

                ForEach(visibleInstitutions) { institution in
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        NavigationLink(value: AppDestination.institution(institution.name)) {
                            InstitutionCard(institution: institution)
                        }
                        .buttonStyle(.plain)
                        SmartNavigationRow(
                            title: String(format: L10n.t("institutions.related_questions", lang), institution.name),
                            subtitle: L10n.t("institutions.searchable_explanations", lang),
                            symbol: "magnifyingglass",
                            destination: .searchList
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.more)
        .navigationTitle(L10n.t("institutions.nav_title", lang))
        .nlNavigationInline()
    }

    private var heroSection: some View {
        CategoryHeroVisual(
            assetName: "home_documents_city_hall",
            title: L10n.t("institutions.nav_title", lang),
            subtitle: L10n.t("institutions.subtitle", lang),
            symbol: "building.columns.fill",
            badgeText: officialBadgeText,
            accent: AppColors.softBlue,
            asset: ContentMediaRegistry.municipalityCityHallImage
        )
    }

    private var officialBadgeText: String {
        switch lang {
        case .english: return "Official institutions"
        case .dutch: return "Officiele instanties"
        case .russian: return "Официальные службы"
        }
    }
}
