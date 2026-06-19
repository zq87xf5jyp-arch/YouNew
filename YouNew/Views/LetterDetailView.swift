import SwiftUI

struct LetterDetailView: View {
    let letter: LetterExample
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var related: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: letter).filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private var mistakes: [NewcomerMistake] {
        RelatedContentEngine.commonMistakes(for: letter).filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    private var linkedInstitution: Institution? {
        MockInstitutionsData.items.first(where: {
            $0.name.caseInsensitiveCompare(letter.institutionName(.english)) == .orderedSame &&
            $0.isVisible(for: activePersona, scope: .currentAndUniversal)
        })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [L10n.t("tab.home", lang), L10n.t("letter.breadcrumb", lang), letter.title(lang)])

                InfoCard(title: letter.title(lang), subtitle: letter.institutionName(lang), detail: letter.simplifiedExplanation(lang), icon: "envelope.open")
                InfoCard(title: L10n.t("letter.possible_deadline", lang), subtitle: L10n.t("letter.check_original", lang), detail: letter.possibleDeadline(lang), icon: "calendar")
                InfoCard(title: L10n.t("letter.safe_next_step", lang), subtitle: L10n.t("letter.beginner_guidance", lang), detail: letter.safeNextStep(lang), icon: "arrow.right.circle")

                if let institution = linkedInstitution {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        SectionHeader(title: L10n.t("letter.sent_by_institution", lang))
                        SmartNavigationRow(
                            title: institution.name,
                            subtitle: institution.whenToUse(lang),
                            symbol: "building.columns",
                            destination: .institution(institution.name)
                        )
                    }
                }

                CommonMistakesSection(mistakes: mistakes)

                RelatedContentSection(title: L10n.t("letter.related_content", lang), items: related)
                SafetyBanner(text: letter.officialSourceReminder(lang))

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.letterDetailContext(letter: letter, language: lang, appState: appState),
                    prompt: askAIPrompt
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("letter.nav_title", lang))
        .nlNavigationInline()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SaveItemButton(
                    itemID: letter.title,
                    kind: .document,
                    title: letter.title(lang),
                    subtitle: letter.institutionName(lang),
                    destination: .letter(letter.title)
                )
            }
        }
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI об этом письме"
        case .dutch: return "Vraag AI over deze brief"
        case .english: return "Ask AI about this letter"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Объясните это письмо просто: от кого, что требуется и что делать дальше."
        case .dutch: return "Leg deze brief eenvoudig uit: van wie, wat vereist wordt en wat ik nu moet doen."
        case .english: return "Explain this letter simply: who sent it, what is required, and what to do next."
        }
    }
}
