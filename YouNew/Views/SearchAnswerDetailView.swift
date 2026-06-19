import SwiftUI

struct SearchAnswerDetailView: View {
    let answer: SearchAnswer
    let allAnswers: [SearchAnswer]

    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var invalidLinkMessage: String?

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var sourceDomain: String {
        answer.officialSourceURL.host ?? answer.officialSourceURL.absoluteString
    }

    private var relatedAnswers: [SearchAnswer] {
        answer.relatedQuestions.compactMap { q in
            allAnswers.first(where: { $0.question.caseInsensitiveCompare(q) == .orderedSame })
        }
    }

    private var relatedNavigationItems: [RelatedNavigationItem] {
        RelatedContentEngine.relatedItems(for: answer).filter { RelatedContentEngine.isVisible($0.destination, for: activePersona) }
    }

    private var peopleAlsoSearch: [SearchAnswer] {
        RelatedContentEngine.peopleAlsoSearch(for: answer).filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    private var commonMistakes: [NewcomerMistake] {
        RelatedContentEngine.commonMistakes(for: answer).filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                BreadcrumbTrail(segments: [L10n.t("tab.home", lang), L10n.t("search.nav_title", lang), answer.localizedQuestion(lang)])
                DisclaimerBanner(text: L10n.t("disclaimer.short", lang))

                Text(answer.localizedQuestion(lang))
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)

                InfoCard(title: L10n.t("search.short_answer", lang), subtitle: answer.category.localized(lang), detail: answer.localizedShortAnswer(lang), icon: "questionmark.circle")
                InfoCard(title: L10n.t("search.detailed_answer", lang), subtitle: L10n.t("search.beginner_explanation", lang), detail: answer.localizedDetailedAnswer(lang), icon: "text.book.closed")

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(L10n.t("search.source", lang))
                        .font(AppTypography.cardTitle)
                    Text(answer.officialSourceName)
                        .font(AppTypography.bodyStrong)
                    Text(sourceDomain)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(answer.isOfficialSource ? L10n.t("search.official_source", lang) : L10n.t("search.trusted_source", lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(answer.isOfficialSource ? AppColors.success : AppColors.warning)
                    Text(String(format: L10n.t("legal.last_updated", lang), answer.lastUpdated.formattedForAppLanguage(lang)))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .appCardStyle()

                if let institution = answer.relatedInstitution {
                    InfoCard(title: L10n.t("search.related_institution", lang), subtitle: institution, detail: L10n.t("search.check_personal_official", lang), icon: "building.columns")
                }

                if let safetyNote = answer.localizedSafetyNote(lang) {
                    DisclaimerBanner(text: safetyNote, tone: AppColors.warning)
                }

                HStack(spacing: AppSpacing.small) {
                    Button(L10n.t("beginner.open_official_source", lang)) {
                        openOfficialSource()
                    }
                    .buttonStyle(PrimaryPremiumButtonStyle())

                    Button(L10n.t("search.copy_source_link", lang)) {
#if os(iOS)
                        UIPasteboard.general.string = answer.officialSourceURL.absoluteString
#endif
                    }
                    .buttonStyle(SecondaryPremiumButtonStyle())
                }

                if let placeCategory = mapCategory(for: answer) {
                    NavigationLink(value: AppDestination.mapFocus(.category(placeCategory))) {
                        Label(L10n.t("search.open_on_map", lang), systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryPremiumButtonStyle())
                }

                if let invalidLinkMessage {
                    Text(invalidLinkMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.error)
                        .appCardStyle()
                }

                if !relatedAnswers.isEmpty {
                    SectionHeader(title: L10n.t("search.related_questions", lang))
                    ForEach(relatedAnswers) { related in
                        NavigationLink(value: AppDestination.searchAnswer(related.id)) {
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                Text(related.localizedQuestion(lang))
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                Text(related.localizedShortAnswer(lang))
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !peopleAlsoSearch.isEmpty {
                    SectionHeader(title: L10n.t("search.people_also_search", lang))
                    ForEach(peopleAlsoSearch) { related in
                        SmartNavigationRow(
                            title: related.localizedQuestion(lang),
                            subtitle: related.localizedShortAnswer(lang),
                            symbol: "magnifyingglass",
                            destination: .searchAnswer(related.id)
                        )
                    }
                }

                if !commonMistakes.isEmpty {
                    SectionHeader(title: L10n.t("resources.common_mistakes", lang))
                    ForEach(commonMistakes) { mistake in
                        SmartNavigationRow(
                            title: mistake.title(lang),
                            subtitle: mistake.possibleConsequence(lang),
                            symbol: "exclamationmark.triangle",
                            destination: .mistakesList
                        )
                    }
                }

                InfoCard(
                    title: L10n.t("search.next_recommended_step", lang),
                    subtitle: L10n.t("search.actionable_followup", lang),
                    detail: RelatedContentEngine.nextRecommendedStepText(for: answer, language: lang),
                    icon: "arrow.forward.circle"
                )

                RelatedContentSection(title: L10n.t("search.related_topics_actions", lang), items: relatedNavigationItems)

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.searchContext(query: answer.localizedQuestion(lang), language: lang, appState: appState),
                    prompt: askAIPrompt
                )

                OutdatedInfoReportCard()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("search.answer", lang))
        .nlNavigationInline()
        .onAppear {
            appState.addRecentlyViewedTopic("searchAnswer::\(answer.id.uuidString)")
        }
    }

    private func openOfficialSource() {
        guard let safeURL = AppURL.validatedWebURL(answer.officialSourceURL) else {
            invalidLinkMessage = L10n.t("search.invalid_link", lang)
            return
        }
        invalidLinkMessage = nil
        openURL(safeURL)
        appState.showToast(L10n.t("search.source_opened", lang))
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI об этом ответе"
        case .dutch: return "Vraag AI over dit antwoord"
        case .english: return "Ask AI about this answer"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Объясните «\(answer.localizedQuestion(lang))» просто и покажите следующий шаг."
        case .dutch: return "Leg «\(answer.localizedQuestion(lang))» eenvoudig uit en laat de volgende stap zien."
        case .english: return "Explain «\(answer.localizedQuestion(lang))» simply and show what to do next."
        }
    }

    private func mapCategory(for answer: SearchAnswer) -> PlaceCategory? {
        switch answer.category {
        case .registration: return .municipality
        case .healthInsurance: return .pharmacy
        case .transport: return .transport
        case .legalHelp, .fines: return .legalHelp
        case .education: return .studentHelp
        case .emergency: return .police
        case .immigration: return .immigrationSupport
        case .general, .digid, .taxes, .work, .housing: return nil
        }
    }
}
