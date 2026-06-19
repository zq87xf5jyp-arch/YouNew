import SwiftUI

struct InstitutionDetailView: View {
    let institution: Institution
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var related: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: institution).filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private var mistakes: [NewcomerMistake] {
        RelatedContentEngine.commonMistakes(for: institution).filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [
                    L10n.t("tab.home", lang),
                    L10n.t("institutions.nav_title", lang),
                    institution.name
                ])
                InstitutionCard(institution: institution)

                InfoCard(
                    title: L10n.t("institution.when_to_use_title", lang),
                    subtitle: institution.name,
                    detail: institution.whenToUse(lang),
                    icon: "clock"
                )
                InfoCard(
                    title: L10n.t("institution.common_confusion_title", lang),
                    subtitle: L10n.t("institution.avoid_mistakes", lang),
                    detail: institution.commonConfusion(lang),
                    icon: "questionmark.circle"
                )

                HStack(spacing: AppSpacing.small) {
                    OfficialSourceButton(title: L10n.t("beginner.open_official_source", lang), url: institution.officialWebsiteURL)
                    QuickActionButton(title: L10n.t("institution.search_this_topic", lang), symbol: "magnifyingglass", destination: .searchList)
                }

                CommonMistakesSection(mistakes: mistakes)

                RelatedContentSection(title: L10n.t("institution.related_next_steps", lang), items: related)
                SafetyBanner(text: institution.warning(lang))

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.institutionContext(institution: institution, language: lang, appState: appState),
                    prompt: askAIPrompt
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(institution.name)
        .nlNavigationInline()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SaveItemButton(
                    itemID: "institution::\(institution.name.lowercased())",
                    kind: .institution,
                    title: institution.name,
                    subtitle: L10n.t("institutions.nav_title", lang),
                    destination: .institution(institution.name)
                )
            }
        }
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI об этой организации"
        case .dutch: return "Vraag AI over deze instantie"
        case .english: return "Ask AI about this institution"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Объясните \(institution.name) просто: что это, когда обращаться и что взять с собой."
        case .dutch: return "Leg \(institution.name) eenvoudig uit: wat is het, wanneer ga ik erheen en wat neem ik mee."
        case .english: return "Explain \(institution.name) simply: what it is, when to go, and what to bring."
        }
    }
}
