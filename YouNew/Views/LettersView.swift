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
                lettersHero
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
                    emptyLettersDashboard
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
            .accessibilityIdentifier("letters.screen")
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("letters.title", lang))
        .accessibilityIdentifier("letters.screen")
    }

    private var lettersHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: L10n.t("letters.title", lang),
            subtitle: lettersHeroSubtitle,
            symbol: "envelope.open.fill",
            badgeText: lettersHeroBadge,
            accent: AppColors.softBlue,
            asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
        .accessibilityIdentifier("letters.hero")
    }

    private var emptyLettersDashboard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            InfoCard(
                title: L10n.t("letters.summaries", lang),
                subtitle: L10n.t("letters.no_saved_examples", lang),
                detail: emptyLettersDetail,
                icon: "doc.text"
            )

            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 360, minimumColumnWidth: 156), spacing: AppSpacing.small) {
                ForEach(emptyLetterActions) { action in
                    NavigationLink(value: action.destination) {
                        LetterRecoveryActionCard(action: action)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                    .accessibilityIdentifier("letters.empty.action.\(action.id)")
                }
            }
        }
        .accessibilityIdentifier("letters.empty.dashboard")
    }

    private var lettersHeroSubtitle: String {
        switch lang {
        case .russian: return "Разбирайте официальные письма спокойнее: отправитель, срок, смысл и источник проверки."
        case .dutch: return "Begrijp officiële brieven rustiger: afzender, termijn, betekenis en controlebron."
        case .english: return "Understand official letters more calmly: sender, deadline, meaning, and where to verify."
        }
    }

    private var lettersHeroBadge: String {
        switch lang {
        case .russian: return "Официальные письма"
        case .dutch: return "Officiële brieven"
        case .english: return "Official letters"
        }
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

    private var emptyLettersDetail: String {
        switch lang {
        case .russian: return "Подготовьте документ локально, проверьте отправителя и ищите по учреждению или теме."
        case .dutch: return "Bereid het document lokaal voor, controleer de afzender en zoek op instantie of onderwerp."
        case .english: return "Prepare the document locally, verify the sender, and search by institution or topic."
        }
    }

    private var emptyLetterActions: [LetterRecoveryAction] {
        [
            LetterRecoveryAction(
                id: "documents",
                title: localized(en: "Documents", nl: "Documenten", ru: "Документы"),
                subtitle: localized(en: "Import, scan, and add notes locally.", nl: "Importeer, scan en voeg lokaal notities toe.", ru: "Импортируйте, сканируйте и добавляйте заметки локально."),
                icon: "doc.text.fill",
                tint: AppColors.cyanGlow,
                destination: .journeyDocuments
            ),
            LetterRecoveryAction(
                id: "sources",
                title: L10n.t("settings.sources", lang),
                subtitle: localized(en: "Verify the sender and official domain.", nl: "Controleer afzender en officieel domein.", ru: "Проверьте отправителя и официальный домен."),
                icon: "checkmark.shield.fill",
                tint: AppColors.success,
                destination: .officialSources
            ),
            LetterRecoveryAction(
                id: "search",
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search the institution or deadline text.", nl: "Zoek op instantie of deadline-tekst.", ru: "Ищите учреждение или текст дедлайна."),
                icon: "magnifyingglass.circle.fill",
                tint: AppColors.dutchOrange,
                destination: .searchList
            ),
            LetterRecoveryAction(
                id: "legal",
                title: localized(en: "Legal help", nl: "Juridische hulp", ru: "Юридическая помощь"),
                subtitle: localized(en: "Use support for fines, disputes, or urgent letters.", nl: "Gebruik hulp bij boetes, geschillen of dringende brieven.", ru: "Используйте помощь для штрафов, споров или срочных писем."),
                icon: "person.fill.questionmark",
                tint: AppColors.violet,
                destination: .legalHelp
            )
        ]
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct LetterRecoveryAction: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AppDestination
}

private struct LetterRecoveryActionCard: View {
    let action: LetterRecoveryAction

    var body: some View {
        ProductTaskCard(
            title: action.title,
            subtitle: action.subtitle,
            symbol: action.icon,
            accent: action.tint,
            minHeight: 104
        )
    }
}
