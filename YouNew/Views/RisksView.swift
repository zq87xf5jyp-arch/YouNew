import SwiftUI

struct RisksView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var visibleSections: [RiskSection] {
        RiskSection.allCases.filter { section in
            MockRisksData.items.contains {
                $0.section == section &&
                $0.isVisible(for: activePersona, scope: .currentAndUniversal)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: AppDisclaimers.medium(lang))

                ForEach(visibleSections, id: \.self) { section in
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        SectionHeader(title: section.localized(lang))
                        ForEach(MockRisksData.items.filter {
                            $0.section == section &&
                            $0.isVisible(for: activePersona, scope: .currentAndUniversal)
                        }) { item in
                            RiskCard(item: item)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("risks.nav_title", lang))
    }
}
