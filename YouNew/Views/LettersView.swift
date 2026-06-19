import SwiftUI

struct LettersView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }
    private var visibleExamples: [LetterExample] {
        MockLettersData.examples.filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                DisclaimerBanner(text: L10n.t("disclaimer.expanded", lang), tone: AppColors.error)

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.documentsContext(language: lang, appState: appState),
                    prompt: askAIPrompt
                )

                SectionHeader(title: L10n.t("letters.smart_assistant", lang), subtitle: L10n.t("letters.smart_assistant_subtitle", lang))

                InfoCard(
                    title: letterGuideIntroTitle,
                    subtitle: letterGuideIntroSubtitle,
                    detail: letterGuideIntroDetail,
                    icon: "envelope.open"
                )

                if visibleExamples.isEmpty {
                    InfoCard(
                        title: L10n.t("letters.summaries", lang),
                        subtitle: L10n.t("letters.no_saved_examples", lang),
                        detail: AppEmptyStates.noLetterSummaries(lang),
                        icon: "doc.text"
                    )
                } else {
                    ForEach(visibleExamples) { example in
                        NavigationLink(value: AppDestination.letter(example.title)) {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(example.title(lang))
                                    .font(AppTypography.cardTitle)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(example.institutionName(lang))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textSecondary)

                                Text(example.simplifiedExplanation(lang))
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }

                InfoCard(
                    title: L10n.t("letters.center_flow", lang),
                    subtitle: L10n.t("letters.center_flow_subtitle", lang),
                    detail: L10n.t("letters.center_flow_detail", lang),
                    icon: "point.topleft.down.curvedto.point.bottomright.up"
                )
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("letters.title", lang))
        .accessibilityIdentifier("letters.screen")
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Объяснить документы и письма"
        case .dutch: return "Documenten en brieven uitleggen"
        case .english: return "Explain documents and letters"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Что мне нужно знать о BSN, DigiD и официальных письмах?"
        case .dutch: return "Wat moet ik weten over BSN, DigiD en officiële brieven?"
        case .english: return "What do I need to know about BSN, DigiD, and official letters?"
        }
    }

    private var letterGuideIntroTitle: String {
        switch lang {
        case .russian: return "Понимайте официальные письма безопасно"
        case .dutch: return "Begrijp officiële brieven veilig"
        case .english: return "Understand official letters safely"
        }
    }

    private var letterGuideIntroSubtitle: String {
        switch lang {
        case .russian: return "Используйте примеры ниже и сверяйтесь с учреждением"
        case .dutch: return "Gebruik de voorbeelden hieronder en controleer bij de instantie"
        case .english: return "Use the examples below and verify with the institution"
        }
    }

    private var letterGuideIntroDetail: String {
        switch lang {
        case .russian: return "Не вводите BSN, паспортные номера или полные личные письма в Explain Mode. Сначала проверьте отправителя, срок и официальный сайт."
        case .dutch: return "Voer geen BSN, paspoortnummers of volledige persoonlijke brieven in Explain Mode in. Controleer eerst afzender, termijn en officiële website."
        case .english: return "Do not enter BSN, passport numbers or full personal letters into Explain Mode. First check the sender, deadline and official website."
        }
    }
}
