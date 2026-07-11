import SwiftUI

private enum GuideChip: String, CaseIterable, Identifiable {
    case all, documents, work, study, registration, taxes, health, housing

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.all, .russian): return "Все"
        case (.documents, .russian): return "Документы"
        case (.work, .russian): return "Работа"
        case (.study, .russian): return "Учёба"
        case (.registration, .russian): return "Регистрация"
        case (.taxes, .russian): return "Налоги"
        case (.health, .russian): return "Медицина"
        case (.housing, .russian): return "Жильё"
        case (.all, .dutch): return "Alles"
        case (.documents, .dutch): return "Documenten"
        case (.work, .dutch): return "Werk"
        case (.study, .dutch): return "Studie"
        case (.registration, .dutch): return "Registratie"
        case (.taxes, .dutch): return "Belastingen"
        case (.health, .dutch): return "Gezondheid"
        case (.housing, .dutch): return "Wonen"
        case (.all, .english): return "All"
        case (.documents, .english): return "Documents"
        case (.work, .english): return "Work"
        case (.study, .english): return "Study"
        case (.registration, .english): return "Registration"
        case (.taxes, .english): return "Taxes"
        case (.health, .english): return "Healthcare"
        case (.housing, .english): return "Housing"
        }
    }

    var mappedCategories: [BeginnerGuideCategory] {
        switch self {
        case .all: return BeginnerGuideCategory.allCases
        case .documents: return [.identity, .dailyLife]
        case .work: return [.work]
        case .study: return [.education]
        case .registration: return [.municipality, .immigration]
        case .taxes: return [.taxes, .dailyLife]
        case .health: return [.healthcare]
        case .housing: return [.housing]
        }
    }
}

struct BeginnerGuidesView: View {
    @State private var selectedChip: GuideChip = .all
    @State private var searchText = ""
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var visibleChips: [GuideChip] {
        switch appState.selectedUserStatus?.personaTag {
        case .student:
            return [.all, .study, .housing, .health]
        case .worker, .highlySkilledMigrant, .eu:
            return [.all, .documents, .work, .registration, .taxes, .health, .housing]
        case .refugee:
            return [.all, .documents, .registration, .study, .health, .housing]
        case .family:
            return [.all, .documents, .registration, .health, .housing]
        case .tourist:
            return [.all, .documents, .health]
        case .entrepreneur:
            return [.all, .documents, .work, .registration, .taxes, .health, .housing]
        case .lgbt:
            return [.all, .documents, .health, .housing]
        case .nonEU, .universal, nil:
            return Array(GuideChip.allCases)
        }
    }

    private var displayedItems: [BeginnerGuideItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let category: BeginnerGuideCategory? = selectedChip == .all ? nil : selectedChip.mappedCategories.first
        let base = MockBeginnerGuidesData.search(
            q,
            language: lang,
            category: category,
            activePersona: appState.selectedUserStatus?.personaTag,
            scope: .currentAndUniversal
        )
        if selectedChip == .all || selectedChip.mappedCategories.count == 1 {
            return base.sorted { (lhs: BeginnerGuideItem, rhs: BeginnerGuideItem) -> Bool in
                lhs.title(lang) < rhs.title(lang)
            }
        }
        return base.filter { selectedChip.mappedCategories.contains($0.category) }
            .sorted { (lhs: BeginnerGuideItem, rhs: BeginnerGuideItem) -> Bool in
                lhs.title(lang) < rhs.title(lang)
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                SectionHeader(title: L10n.t("beginner.guides.title", lang), subtitle: L10n.t("beginner.guides.subtitle", lang))
                DisclaimerBanner(text: L10n.t("disclaimer.medium", lang))

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.textSecondary)
                    TextField(L10n.t("beginner.guides.search_placeholder", lang), text: $searchText)
                        .font(AppTypography.body)
                        .autocorrectionDisabled(true)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous).stroke(AppColors.stroke.opacity(0.7), lineWidth: 1))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.small) {
                    ForEach(visibleChips) { chip in
                            filterChip(title: chip.localized(lang), selected: selectedChip == chip) {
                                withAnimation(AppAnimations.standard) { selectedChip = chip }
                            }
                        }
                    }
                }

                ForEach(displayedItems) { item in
                    NavigationLink(value: AppDestination.beginnerGuide(item.id)) {
                        HStack(alignment: .top, spacing: 12) {
                            PremiumImageHeader(
                                title: item.title(lang),
                                asset: guideImageAsset(for: item.category),
                                language: lang,
                                symbol: guideSymbol(for: item.category),
                                accent: guideAccent(for: item.category),
                                height: 82,
                                width: 88,
                                cornerRadius: 18,
                                fallbackCategory: guideFallbackCategory(for: item.category)
                            )
                            .layoutPriority(0)

                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                HStack(alignment: .top) {
                                    Text(item.title(lang))
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(AppColors.textPrimary)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.82)
                                    Spacer(minLength: 8)
                                    Text(localizedCategoryLabel(item.category))
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.accent)
                                        .lineLimit(1)
                                }
                                Text(item.simpleAnswer(lang))
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                                Text(item.officialSourceName)
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.accent)
                                    .lineLimit(1)
                            }
                            .layoutPriority(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(2)
                        .background(
                            LinearGradient(colors: [AppColors.card, AppColors.card.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("beginner.guides.nav_title", lang))
        .nlNavigationInline()
    }

    private func guideImageAsset(for category: BeginnerGuideCategory) -> AppImageAsset? {
        switch category {
        case .identity:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .municipality, .immigration, .benefits:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.governmentBasicsImage
        case .work, .taxes:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare, .health:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .fines, .legalHelp:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .safety:
            return ContentMediaRegistry.emergencyImage
        case .dailyLife:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage
        }
    }

    private func guideFallbackCategory(for category: BeginnerGuideCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .identity, .fines, .legalHelp:
            return .documents
        case .municipality, .immigration, .benefits:
            return .government
        case .work, .taxes:
            return .work
        case .education:
            return .dutchA1A2
        case .healthcare, .health:
            return .healthcare
        case .housing:
            return .housing
        case .transport:
            return .transport
        case .safety:
            return .emergency
        case .dailyLife:
            return .integration
        }
    }

    private func guideSymbol(for category: BeginnerGuideCategory) -> String {
        switch category {
        case .identity: return "doc.text.fill"
        case .municipality: return "building.columns.fill"
        case .immigration: return "person.text.rectangle.fill"
        case .work: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .healthcare, .health: return "cross.case.fill"
        case .housing: return "house.fill"
        case .transport: return "tram.fill"
        case .taxes: return "banknote.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .legalHelp: return "doc.text.magnifyingglass"
        case .safety: return "shield.fill"
        case .dailyLife: return "figure.walk"
        case .benefits: return "checkmark.seal.fill"
        }
    }

    private func guideAccent(for category: BeginnerGuideCategory) -> Color {
        switch category {
        case .healthcare, .health, .safety:
            return AppColors.error
        case .transport:
            return AppColors.dutchOrange
        case .education:
            return AppColors.emerald
        case .housing:
            return AppColors.softBlue
        case .legalHelp, .fines:
            return AppColors.warning
        default:
            return AppColors.accent
        }
    }

    private func filterChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(selected ? Color.white : AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? AppColors.accent : AppColors.chipBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? Color.clear : AppColors.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func localizedCategoryLabel(_ category: BeginnerGuideCategory) -> String {
        switch (category, lang) {
        case (.identity, .russian): return "Документы"
        case (.municipality, .russian): return "Муниципалитет"
        case (.immigration, .russian): return "Иммиграция"
        case (.work, .russian): return "Работа"
        case (.education, .russian): return "Образование"
        case (.healthcare, .russian): return "Здравоохранение"
        case (.housing, .russian): return "Жильё"
        case (.transport, .russian): return "Транспорт"
        case (.taxes, .russian): return "Налоги"
        case (.fines, .russian): return "Штрафы"
        case (.legalHelp, .russian): return "Юридическая помощь"
        case (.safety, .russian): return "Безопасность"
        case (.dailyLife, .russian): return "Повседневная жизнь"
        case (.identity, .dutch): return "Documenten"
        case (.municipality, .dutch): return "Gemeente"
        case (.immigration, .dutch): return "Immigratie"
        case (.work, .dutch): return "Werk"
        case (.education, .dutch): return "Onderwijs"
        case (.healthcare, .dutch): return "Gezondheidszorg"
        case (.housing, .dutch): return "Wonen"
        case (.transport, .dutch): return "Vervoer"
        case (.taxes, .dutch): return "Belastingen"
        case (.fines, .dutch): return "Boetes"
        case (.legalHelp, .dutch): return "Juridische hulp"
        case (.safety, .dutch): return "Veiligheid"
        case (.dailyLife, .dutch): return "Dagelijks leven"
        case (.identity, .english): return "Documents"
        case (.municipality, .english): return "Municipality"
        case (.immigration, .english): return "Immigration"
        case (.work, .english): return "Work"
        case (.education, .english): return "Education"
        case (.healthcare, .english): return "Healthcare"
        case (.housing, .english): return "Housing"
        case (.transport, .english): return "Transport"
        case (.taxes, .english): return "Taxes"
        case (.fines, .english): return "Fines"
        case (.legalHelp, .english): return "Legal Help"
        case (.safety, .english): return "Safety"
        case (.dailyLife, .english): return "Daily Life"
        case (.benefits, .english): return "Benefits"
        case (.health, .english): return "Health"
        case (.benefits, .dutch): return "Toeslagen"
        case (.health, .dutch): return "Gezondheid"
        case (.benefits, .russian): return "Пособия"
        case (.health, .russian): return "Здоровье"
        }
    }
}

struct BeginnerGuideDetailView: View {
    let item: BeginnerGuideItem
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var activePersona: PersonaTag? { appState.selectedUserStatus?.personaTag }

    private var relatedTerms: [DutchTerm] {
        let bag = (item.relatedTopics + item.keywords(lang) + [item.title(lang)]).joined(separator: " ").lowercased()
        return MockDutchTermsData.items.filter { term in
            term.isVisible(for: activePersona, scope: .currentAndUniversal) &&
            (bag.contains(term.dutchTerm.lowercased()) || bag.contains(term.localizedExplanation(lang).lowercased()))
        }.prefix(4).map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                PremiumImageHeader(
                    title: item.title(lang),
                    asset: guideImageAsset(for: item.category),
                    language: lang,
                    symbol: guideSymbol(for: item.category),
                    accent: guideAccent(for: item.category),
                    height: 184,
                    cornerRadius: 24,
                    fallbackCategory: guideFallbackCategory(for: item.category)
                )
                .accessibilityIdentifier("beginnerGuide.detail.hero")

                Text(item.title(lang))
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)

                detailSection(title: L10n.t("beginner.simple_answer", lang), text: item.simpleAnswer(lang))
                detailSection(title: L10n.t("beginner.explain_new_here", lang), text: item.description(lang))
                detailSection(title: L10n.t("beginner.why_matters", lang), text: item.whyItMatters(lang))

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(L10n.t("beginner.what_to_check", lang)).font(AppTypography.cardTitle)
                    ForEach(item.whatToCheck(lang), id: \.self) { line in
                        Text("• \(line)")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .appCardStyle()

                detailSection(title: L10n.t("beginner.common_mistake", lang), text: item.commonMistake(lang))
                detailSection(title: L10n.t("beginner.safe_next_step", lang), text: item.safeNextStep(lang))

                if let url = item.officialSourceURL {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(L10n.t("beginner.official_source", lang)).font(AppTypography.cardTitle)
                        Text(item.officialSourceName).font(AppTypography.body).foregroundStyle(AppColors.textSecondary)
                        OfficialSourceButton(title: L10n.t("beginner.open_official_source", lang), url: url)
                    }
                    .appCardStyle()
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(L10n.t("beginner.related_topics", lang)).font(AppTypography.cardTitle)
                    ForEach(item.relatedTopics, id: \.self) { topic in
                        SmartNavigationRow(
                            title: topic,
                            subtitle: relatedTopicSubtitle,
                            symbol: "magnifyingglass",
                            destination: .searchList
                        )
                    }
                }
                .accessibilityIdentifier("beginnerGuide.relatedTopics.dashboard")
                .appCardStyle()

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(L10n.t("beginner.dutch_terms", lang)).font(AppTypography.cardTitle)
                    if relatedTerms.isEmpty {
                        dutchTermsFallback
                    } else {
                        ForEach(relatedTerms) { term in
                            SmartNavigationRow(
                                title: term.dutchTerm,
                                subtitle: term.localizedExplanation(lang),
                                symbol: "text.magnifyingglass",
                                destination: .dutchTerm(term.id)
                            )
                        }
                    }
                }
                .accessibilityIdentifier("beginnerGuide.dutchTerms.dashboard")
                .appCardStyle()

                AIAskButton(
                    title: askAITitle,
                    context: AIContextBuilder.beginnerGuideDetailContext(item: item, language: lang, appState: appState),
                    prompt: askAIPrompt
                )

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text(L10n.t("disclaimer.medium", lang))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.warning)
                    Text("\(L10n.t("beginner.last_updated", lang)): \(item.lastUpdated.formattedForAppLanguage(lang))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .appCardStyle()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("beginner.guide_nav", lang))
        .nlNavigationInline()
    }

    private var askAITitle: String {
        switch lang {
        case .russian: return "Спросить AI об этом руководстве"
        case .dutch: return "Vraag AI over deze gids"
        case .english: return "Ask AI about this guide"
        }
    }

    private var askAIPrompt: String {
        switch lang {
        case .russian: return "Объясните «\(item.title(lang))» просто и скажите, с чего начать."
        case .dutch: return "Leg «\(item.title(lang))» eenvoudig uit en vertel waar ik moet beginnen."
        case .english: return "Explain «\(item.title(lang))» simply and tell me where to start."
        }
    }

    private var dutchTermsFallback: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            InfoCard(
                title: dutchTermsFallbackTitle,
                subtitle: dutchTermsFallbackSubtitle,
                detail: dutchTermsFallbackDetail,
                icon: "text.book.closed"
            )

            SmartNavigationRow(
                title: L10n.t("resources.dutch_terms", lang),
                subtitle: localized(en: "Open the full glossary.", nl: "Open de volledige woordenlijst.", ru: "Открыть полный словарь."),
                symbol: "text.magnifyingglass",
                destination: .dutchTermsList
            )

            SmartNavigationRow(
                title: L10n.t("tab.search", lang),
                subtitle: localized(en: "Search by institution, document, or rule.", nl: "Zoek op instantie, document of regel.", ru: "Искать по организации, документу или правилу."),
                symbol: "magnifyingglass",
                destination: .searchList
            )
        }
        .accessibilityIdentifier("beginnerGuide.dutchTerms.empty")
    }

    private var relatedTopicSubtitle: String {
        localized(
            en: "Open search to compare related answers and sources.",
            nl: "Open zoeken om verwante antwoorden en bronnen te vergelijken.",
            ru: "Откройте поиск, чтобы сравнить связанные ответы и источники."
        )
    }

    private var dutchTermsFallbackTitle: String {
        localized(
            en: "No exact Dutch term is linked",
            nl: "Geen exacte Nederlandse term gekoppeld",
            ru: "Точный нидерландский термин не привязан"
        )
    }

    private var dutchTermsFallbackSubtitle: String {
        localized(
            en: "Use the glossary when wording matters",
            nl: "Gebruik de woordenlijst wanneer formulering belangrijk is",
            ru: "Используйте словарь, когда важна формулировка"
        )
    }

    private var dutchTermsFallbackDetail: String {
        localized(
            en: "This guide can still involve Dutch words on letters, websites, or municipality pages. Check the glossary or search before acting.",
            nl: "Deze gids kan nog steeds Nederlandse woorden bevatten op brieven, websites of gemeentepagina's. Controleer de woordenlijst of zoek voordat je handelt.",
            ru: "В этом гайде всё равно могут встречаться нидерландские слова в письмах, на сайтах или страницах gemeente. Проверьте словарь или поиск перед действием."
        )
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .russian: return ru
        case .dutch: return nl
        case .english: return en
        }
    }

    private func detailSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title).font(AppTypography.cardTitle)
            Text(text).font(AppTypography.body).foregroundStyle(AppColors.textPrimary)
        }
        .appCardStyle()
    }

    private func guideImageAsset(for category: BeginnerGuideCategory) -> AppImageAsset? {
        switch category {
        case .identity:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.governmentBasicsImage
        case .municipality, .immigration, .benefits:
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.governmentBasicsImage
        case .work, .taxes:
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case .education:
            return ContentMediaRegistry.museumsCultureImage ?? ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.officialSourcesHero
        case .healthcare, .health:
            return ContentMediaRegistry.healthcarePharmacyImage
        case .housing:
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case .transport:
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case .fines, .legalHelp:
            return ContentMediaRegistry.officialSourcesHero ?? ContentMediaRegistry.municipalityCityHallImage
        case .safety:
            return ContentMediaRegistry.emergencyImage
        case .dailyLife:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage
        }
    }

    private func guideFallbackCategory(for category: BeginnerGuideCategory) -> PremiumImageFallbackCategory {
        switch category {
        case .identity, .fines, .legalHelp:
            return .documents
        case .municipality, .immigration, .benefits:
            return .government
        case .work, .taxes:
            return .work
        case .education:
            return .dutchA1A2
        case .healthcare, .health:
            return .healthcare
        case .housing:
            return .housing
        case .transport:
            return .transport
        case .safety:
            return .emergency
        case .dailyLife:
            return .integration
        }
    }

    private func guideSymbol(for category: BeginnerGuideCategory) -> String {
        switch category {
        case .identity: return "doc.text.fill"
        case .municipality: return "building.columns.fill"
        case .immigration: return "person.text.rectangle.fill"
        case .work: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .healthcare, .health: return "cross.case.fill"
        case .housing: return "house.fill"
        case .transport: return "tram.fill"
        case .taxes: return "banknote.fill"
        case .fines: return "exclamationmark.triangle.fill"
        case .legalHelp: return "doc.text.magnifyingglass"
        case .safety: return "shield.fill"
        case .dailyLife: return "figure.walk"
        case .benefits: return "checkmark.seal.fill"
        }
    }

    private func guideAccent(for category: BeginnerGuideCategory) -> Color {
        switch category {
        case .healthcare, .health, .safety:
            return AppColors.error
        case .transport:
            return AppColors.dutchOrange
        case .education:
            return AppColors.emerald
        case .housing:
            return AppColors.softBlue
        case .legalHelp, .fines:
            return AppColors.warning
        default:
            return AppColors.accent
        }
    }
}
