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
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            HStack {
                                Text(item.title(lang))
                                    .font(AppTypography.cardTitle)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Text(localizedCategoryLabel(item.category))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.accent)
                            }
                            Text(item.simpleAnswer(lang))
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(2)
                            Text(item.officialSourceName)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.accent)
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
                        Text(topic)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .appCardStyle()

                if !relatedTerms.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(L10n.t("beginner.dutch_terms", lang)).font(AppTypography.cardTitle)
                        ForEach(relatedTerms) { term in
                            NavigationLink(value: AppDestination.dutchTerm(term.id)) {
                                Text(term.dutchTerm)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                    .appCardStyle()
                }

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

    private func detailSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title).font(AppTypography.cardTitle)
            Text(text).font(AppTypography.body).foregroundStyle(AppColors.textPrimary)
        }
        .appCardStyle()
    }
}
