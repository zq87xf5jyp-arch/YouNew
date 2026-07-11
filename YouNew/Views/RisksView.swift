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
                risksHero
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

    private var risksHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("risks.nav_title", lang),
            subtitle: risksHeroSubtitle,
            symbol: "exclamationmark.triangle.fill",
            badgeText: risksHeroBadge,
            accent: AppColors.warning,
            asset: ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("risks.hero")
    }

    private var risksHeroSubtitle: String {
        switch lang {
        case .russian: return "Практичные предупреждения, которые помогают проверить письма, сроки, платежи и официальные действия."
        case .dutch: return "Praktische waarschuwingen om brieven, termijnen, betalingen en officiële stappen te controleren."
        case .english: return "Practical warnings to help check letters, deadlines, payments, and official steps."
        }
    }

    private var risksHeroBadge: String {
        switch lang {
        case .russian: return "Проверяйте сначала"
        case .dutch: return "Eerst controleren"
        case .english: return "Check first"
        }
    }
}
