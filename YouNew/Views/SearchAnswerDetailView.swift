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
        .filter { $0.isVisible(for: activePersona, scope: .currentAndUniversal) }
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

                PremiumImageHeader(
                    title: answer.localizedQuestion(lang),
                    asset: answerImageAsset(for: answer.category),
                    language: lang,
                    symbol: answerSymbol(for: answer.category),
                    accent: answerAccent(for: answer.category),
                    height: 184,
                    cornerRadius: 24,
                    fallbackCategory: answerFallbackCategory(for: answer.category)
                )
                .accessibilityIdentifier("search.answer.hero")

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

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("search.related_questions", lang))
                    if relatedAnswers.isEmpty {
                        relatedQuestionsFallback
                    } else {
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
                }
                .accessibilityIdentifier("search.answer.relatedQuestions.dashboard")

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    SectionHeader(title: L10n.t("search.people_also_search", lang))
                    if peopleAlsoSearch.isEmpty {
                        peopleAlsoSearchFallback
                    } else {
                        ForEach(peopleAlsoSearch) { related in
                            SmartNavigationRow(
                                title: related.localizedQuestion(lang),
                                subtitle: related.localizedShortAnswer(lang),
                                symbol: "magnifyingglass",
                                destination: .searchAnswer(related.id)
                            )
                        }
                    }
                }
                .accessibilityIdentifier("search.answer.peopleAlsoSearch.dashboard")

                CommonMistakesSection(mistakes: commonMistakes)

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

    private var relatedQuestionsFallback: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            InfoCard(
                title: relatedFallbackTitle,
                subtitle: relatedFallbackSubtitle,
                detail: relatedFallbackDetail,
                icon: "point.3.connected.trianglepath.dotted"
            )

            SmartNavigationRow(
                title: searchMoreTitle,
                subtitle: searchMoreSubtitle,
                symbol: "magnifyingglass",
                destination: .searchList
            )

            SmartNavigationRow(
                title: officialSourcesTitle,
                subtitle: officialSourcesSubtitle,
                symbol: "checkmark.shield.fill",
                destination: .officialSources
            )
        }
        .accessibilityIdentifier("search.answer.relatedQuestions.empty")
    }

    private var peopleAlsoSearchFallback: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SmartNavigationRow(
                title: searchMoreTitle,
                subtitle: searchMoreSubtitle,
                symbol: "magnifyingglass.circle",
                destination: .searchList
            )

            if let placeCategory = mapCategory(for: answer) {
                SmartNavigationRow(
                    title: mapFallbackTitle,
                    subtitle: mapFallbackSubtitle,
                    symbol: "map.fill",
                    destination: .mapFocus(.category(placeCategory))
                )
            } else {
                SmartNavigationRow(
                    title: resourcesFallbackTitle,
                    subtitle: resourcesFallbackSubtitle,
                    symbol: "books.vertical.fill",
                    destination: .resourcesHub
                )
            }
        }
        .accessibilityIdentifier("search.answer.peopleAlsoSearch.empty")
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

    private var relatedFallbackTitle: String {
        switch lang {
        case .russian: return "Продолжите через похожие маршруты"
        case .dutch: return "Ga verder via verwante routes"
        case .english: return "Continue through related paths"
        }
    }

    private var relatedFallbackSubtitle: String {
        switch lang {
        case .russian: return "Продолжите через поиск или проверенные источники"
        case .dutch: return "Ga verder via zoeken of betrouwbare bronnen"
        case .english: return "Continue through search or trusted sources"
        }
    }

    private var relatedFallbackDetail: String {
        switch lang {
        case .russian: return "Этот ответ всё ещё можно расширить: найдите похожую тему, откройте официальный источник или спросите AI ниже."
        case .dutch: return "Je kunt dit antwoord nog uitbreiden: zoek een verwant onderwerp, open een officiële bron of vraag AI hieronder."
        case .english: return "You can still expand this answer: search a related topic, open official sources, or ask AI below."
        }
    }

    private var searchMoreTitle: String {
        switch lang {
        case .russian: return "Искать похожую тему"
        case .dutch: return "Zoek een verwant onderwerp"
        case .english: return "Search a related topic"
        }
    }

    private var searchMoreSubtitle: String {
        switch lang {
        case .russian: return "Попробуйте другое слово, учреждение или документ."
        case .dutch: return "Probeer een ander woord, instantie of document."
        case .english: return "Try another word, institution, or document."
        }
    }

    private var officialSourcesTitle: String {
        switch lang {
        case .russian: return "Проверить официальные источники"
        case .dutch: return "Controleer officiële bronnen"
        case .english: return "Check official sources"
        }
    }

    private var officialSourcesSubtitle: String {
        switch lang {
        case .russian: return "Откройте государственные и городские сайты по теме."
        case .dutch: return "Open overheids- en gemeentesites over dit onderwerp."
        case .english: return "Open government and municipality sources for this topic."
        }
    }

    private var mapFallbackTitle: String {
        switch lang {
        case .russian: return "Найти место рядом"
        case .dutch: return "Vind een locatie dichtbij"
        case .english: return "Find a nearby place"
        }
    }

    private var mapFallbackSubtitle: String {
        switch lang {
        case .russian: return "Откройте карту с подходящей категорией."
        case .dutch: return "Open de kaart met een passende categorie."
        case .english: return "Open the map with a matching category."
        }
    }

    private var resourcesFallbackTitle: String {
        switch lang {
        case .russian: return "Открыть полезные ресурсы"
        case .dutch: return "Open nuttige bronnen"
        case .english: return "Open useful resources"
        }
    }

    private var resourcesFallbackSubtitle: String {
        switch lang {
        case .russian: return "Перейдите к материалам, организациям и проверочным спискам."
        case .dutch: return "Ga naar materialen, organisaties en checklists."
        case .english: return "Go to materials, organizations, and checklists."
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

    private func answerImageAsset(for category: SearchCategory) -> AppImageAsset? {
        switch category {
        case .registration, .digid:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .immigration:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.governmentBasicsImage
        case .taxes, .work:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .fines, .legalHelp:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .healthInsurance, .emergency:
            return ContentMediaRegistry.healthcarePharmacyImage ?? ContentMediaRegistry.emergencyImage
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .general:
            return ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.dailyCultureImage
        }
    }

    private func answerFallbackCategory(for category: SearchCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .registration, .digid, .immigration:
            return .government
        case .taxes, .work:
            return .work
        case .fines, .legalHelp:
            return .documents
        case .healthInsurance:
            return .healthcare
        case .emergency:
            return .emergency
        case .education:
            return .dutchA1A2
        case .housing:
            return .housing
        case .transport:
            return .transport
        case .general:
            return .integration
        }
    }

    private func answerSymbol(for category: SearchCategory) -> String {
        switch category {
        case .registration: return "person.crop.circle.badge.checkmark"
        case .digid: return "key.fill"
        case .immigration: return "person.text.rectangle.fill"
        case .taxes: return "banknote.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .healthInsurance: return "cross.case.fill"
        case .work: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .housing: return "house.fill"
        case .transport: return "tram.fill"
        case .legalHelp: return "doc.text.magnifyingglass"
        case .emergency: return "phone.fill"
        case .general: return "sparkles"
        }
    }

    private func answerAccent(for category: SearchCategory) -> Color {
        switch category {
        case .healthInsurance, .emergency:
            return AppColors.error
        case .transport:
            return AppColors.dutchOrange
        case .education:
            return AppColors.emerald
        case .housing:
            return AppColors.softBlue
        case .fines, .legalHelp:
            return AppColors.warning
        default:
            return AppColors.accent
        }
    }
}
