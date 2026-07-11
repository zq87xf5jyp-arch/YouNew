import SwiftUI

struct SurvivalGuideView: View {
    @State private var expandedIDs: Set<UUID> = []
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleItems: [SurvivalGuideItem] {
        MockExpansionData.survivalGuide.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                survivalHero
                DisclaimerBanner(text: L10n.t("disclaimer.medium", lang))

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.survivalGuideContext(language: lang, appState: appState),
                    prompt: askAIPrompt
                )

                ForEach(visibleItems) { item in
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        HStack {
                            Text(item.title)
                                .font(AppTypography.cardTitle)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Button(expandedIDs.contains(item.id) ? L10n.t("survival_guide.collapse", lang) : L10n.t("survival_guide.expand", lang)) {
                                if expandedIDs.contains(item.id) {
                                    expandedIDs.remove(item.id)
                                } else {
                                    expandedIDs.insert(item.id)
                                }
                            }
                            .font(AppTypography.footnote)
                        }

                        Text(item.shortText)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)

                        if expandedIDs.contains(item.id) {
                            Text(item.detailText)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .appCardStyle()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("survival_guide.nav_title", lang))
    }

    private var survivalHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("survival_guide.title", lang),
            subtitle: L10n.t("survival_guide.subtitle", lang),
            symbol: "lifepreserver.fill",
            badgeText: survivalHeroBadge,
            accent: AppColors.error,
            asset: ContentMediaRegistry.emergencyImage ?? ContentMediaRegistry.healthcareBasicsImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("survivalGuide.hero")
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI о важных советах"
        case .dutch: return "Vraag AI over overlevingstips"
        case .english: return "Ask AI about survival tips"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Что самое важное нужно знать и сделать первым делом в Нидерландах?"
        case .dutch: return "Wat is het allerbelangrijkste om te weten als nieuwkomer in Nederland?"
        case .english: return "What are the most important things to know and do first as a newcomer in the Netherlands?"
        }
    }

    private var survivalHeroBadge: String {
        switch lang {
        case .russian: return "Спокойный старт"
        case .dutch: return "Rustige start"
        case .english: return "Calm start"
        }
    }
}
