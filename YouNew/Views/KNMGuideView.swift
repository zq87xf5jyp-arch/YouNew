import SwiftUI

struct KNMGuideView: View {
    let initialModuleID: String?
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedSection: KNMSection = .modules

    init(initialModuleID: String? = nil) {
        self.initialModuleID = initialModuleID
    }

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    header
                    disclaimer
                    sectionPicker

                    switch selectedSection {
                    case .modules:
                        modulesSection
                    case .practice:
                        KNMPracticeView()
                    case .terms:
                        keyTermsSection
                    case .sources:
                        sourcesSection
                    case .exam:
                        examInfoSection
                    }

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle("KNM")
        .nlNavigationInline()
        .onAppear {
            if initialModuleID != nil {
                selectedSection = .modules
            }
        }
        .accessibilityIdentifier("knm.screen")
    }

    private var header: some View {
        CategoryHeroVisual(
            assetName: "premium_home_language",
            title: "KNM",
            subtitle: localized(
                en: "Knowledge of Dutch Society",
                nl: "Kennis van de Nederlandse Maatschappij",
                ru: "Знание нидерландского общества"
            ),
            symbol: "graduationcap.fill",
            badgeText: localized(en: "Study guide", nl: "Studiegids", ru: "Учебный раздел"),
            accent: AppColors.cyanGlow
        )
    }

    private var disclaimer: some View {
        DisclaimerBanner(text: localized(
            en: "This section helps you study KNM topics, but it is not an official DUO exam. Always verify current information on official websites.",
            nl: "Dit onderdeel helpt bij KNM-onderwerpen, maar is geen officieel DUO-examen. Controleer actuele informatie altijd op officiële websites.",
            ru: "Раздел помогает подготовиться к темам KNM, но не является официальным экзаменом DUO. Проверяйте актуальную информацию на официальных сайтах."
        ))
        .accessibilityIdentifier("knm.disclaimer")
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xSmall) {
                ForEach(KNMSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        Label(section.title(lang), systemImage: section.icon)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(selectedSection == section ? .white : AppColors.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(selectedSection == section ? AppColors.cyanGlow : AppColors.glassSurfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(AppPressableButtonStyle())
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Modules", nl: "Modules", ru: "Модули"))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: AppSpacing.small)], spacing: AppSpacing.small) {
                ForEach(sortedModules) { module in
                    NavigationLink {
                        KNMModuleView(module: module)
                    } label: {
                        moduleCard(module)
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("knm.module.\(module.id)")
                }
            }
        }
    }

    private var sortedModules: [KNMModule] {
        guard let initialModuleID else { return KNMGuideData.modules }
        return KNMGuideData.modules.sorted { lhs, rhs in
            if lhs.id == initialModuleID { return true }
            if rhs.id == initialModuleID { return false }
            return lhs.title.value(lang) < rhs.title.value(lang)
        }
    }

    private func moduleCard(_ module: KNMModule) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                Image(systemName: module.icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(module.accent.color)
                    .frame(width: 42, height: 42)
                    .background(module.accent.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(module.title.value(lang))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text("\(module.lessons.count) \(localized(en: "lesson", nl: "les", ru: "урок")) • \(module.allQuestions.count) \(localized(en: "questions", nl: "vragen", ru: "вопроса"))")
                        .font(AppTypography.metadata)
                        .foregroundStyle(module.accent.color)
                }
                Spacer(minLength: 0)
            }

            Text(module.summary.value(lang))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .appCardStyle()
    }

    private var keyTermsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Key terms", nl: "Belangrijke woorden", ru: "Важные слова"))
            ForEach(allTerms) { term in
                VStack(alignment: .leading, spacing: 5) {
                    Text(term.term)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(term.definition.value(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
            }
        }
    }

    private var allTerms: [KNMKeyTerm] {
        Array(KNMGuideData.modules.flatMap { $0.lessons.flatMap(\.keyTerms) }.prefix(30))
    }

    private var sourcesSection: some View {
        KNMSourceListView(sources: KNMGuideData.sources)
    }

    private var examInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Exam info", nl: "Exameninformatie", ru: "Информация об экзамене"))
            Text(localized(
                en: "DUO explains that KNM is a computer-based knowledge exam with themes such as living and work and income. Check Mijn Inburgering to see which exams apply to your own route.",
                nl: "DUO legt uit dat KNM een kennisexamen op de computer is met thema's zoals wonen en werk en inkomen. Kijk in Mijn Inburgering welke examens voor uw route gelden.",
                ru: "DUO объясняет, что KNM - это компьютерный экзамен по знаниям с темами вроде жилья и работы/дохода. Проверяйте в Mijn Inburgering, какие экзамены относятся к вашему маршруту."
            ))
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .appCardStyle()
            KNMSourceListView(sources: ["duo-knowledge", "duo-practice", "duo-register"].compactMap(KNMGuideData.source(with:)))
        }
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct KNMModuleView: View {
    let module: KNMModule
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    CategoryHeroVisual(assetName: nil, title: module.title.value(lang), subtitle: module.summary.value(lang), symbol: module.icon, badgeText: "KNM", accent: module.accent.color)
                    DisclaimerBanner(text: localized(en: "App-created KNM study content. Not an official DUO exam.", nl: "Door de app gemaakte KNM-studiecontent. Geen officieel DUO-examen.", ru: "Учебный материал KNM, созданный приложением. Не официальный экзамен DUO."))

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        NLSectionHeader(title: localized(en: "Lessons", nl: "Lessen", ru: "Уроки"))
                        ForEach(module.lessons) { lesson in
                            NavigationLink {
                                KNMLessonDetailView(module: module, lesson: lesson)
                            } label: {
                                HStack(spacing: AppSpacing.medium) {
                                    Image(systemName: module.icon)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(module.accent.color)
                                        .frame(width: 38, height: 38)
                                        .background(module.accent.color.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lesson.title.value(lang))
                                            .font(AppTypography.bodyStrong)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Text("\(lesson.everydaySituations.count) \(localized(en: "situations", nl: "situaties", ru: "ситуации")) • \(lesson.keyTerms.count) \(localized(en: "terms", nl: "woorden", ru: "слова")) • \(lesson.practiceQuestions.count) \(localized(en: "questions", nl: "vragen", ru: "вопросов"))")
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    Spacer()
                                }
                                .appCardStyle()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("knm.lesson.\(lesson.id)")
                        }
                    }

                    if let dutchModuleID = relatedDutchModuleID {
                        NavigationLink(value: AppDestination.dutchA1A2Module(dutchModuleID)) {
                            Label(localized(en: "Learn Dutch words for this topic", nl: "Leer Nederlandse woorden bij dit thema", ru: "Выучить слова по этой теме"), systemImage: "text.book.closed.fill")
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .appCardStyle()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("knm.related.dutchA1A2")
                    }

                    KNMSourceListView(sources: module.sources)
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(module.title.value(lang))
        .nlNavigationInline()
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private var relatedDutchModuleID: String? {
        switch module.id {
        case "housing": return "housing"
        case "transport": return "transport"
        case "health": return "healthcare"
        case "government-institutions": return "municipality"
        case "work-income": return "work-income"
        case "money": return "shopping-services"
        default: return nil
        }
    }
}

private struct KNMLessonDetailView: View {
    let module: KNMModule
    let lesson: KNMLesson
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedAnswers: [String: Int] = [:]

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    CategoryHeroVisual(assetName: nil, title: lesson.title.value(lang), subtitle: module.title.value(lang), symbol: module.icon, badgeText: "KNM", accent: module.accent.color)
                    textBlock(title: label("Explanation", "Uitleg", "Объяснение"), text: lesson.body.value(lang))
                    if let example = lesson.example {
                        textBlock(title: label("Example", "Voorbeeld", "Пример"), text: example.value(lang))
                    }
                    situationsBlock
                    termsBlock
                    rememberBlock
                    practiceBlock
                    KNMSourceListView(sources: lesson.sourceIds.compactMap(KNMGuideData.source(with:)))
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(lesson.title.value(lang))
        .nlNavigationInline()
        .accessibilityIdentifier("knm.lesson.detail")
    }

    private func textBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: title)
            Text(text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .appCardStyle()
        }
    }

    private var termsBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: label("Key terms", "Belangrijke woorden", "Важные слова"))
            ForEach(lesson.keyTerms) { term in
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.term)
                        .font(AppTypography.bodyStrong)
                    Text(term.definition.value(lang))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()
            }
        }
    }

    private var situationsBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: label("Everyday situations", "Dagelijkse situaties", "Бытовые ситуации"))
            ForEach(Array(lesson.everydaySituations.enumerated()), id: \.offset) { index, situation in
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(module.accent.color)
                        .clipShape(Circle())
                    Text(situation.value(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .appCardStyle()
            }
        }
    }

    private var rememberBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: label("Remember", "Onthouden", "Что запомнить"))
            ForEach(Array(lesson.rememberItems.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: AppSpacing.small) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(module.accent.color)
                        .padding(.top, 2)
                    Text(item.value(lang))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .appCardStyle()
            }
        }
    }

    private var practiceBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: label("Practice", "Oefenen", "Практика"))
            ForEach(lesson.practiceQuestions) { question in
                KNMQuestionCard(question: question, selectedIndex: selectedAnswers[question.id]) { index in
                    selectedAnswers[question.id] = index
                }
            }
        }
    }

    private func label(_ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct KNMPracticeView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedModuleID = "mixed"
    @State private var selectedAnswers: [String: Int] = [:]

    private var lang: AppLanguage { languageManager.appLanguage }
    private var questions: [KNMPracticeQuestion] {
        if selectedModuleID == "mixed" { return Array(KNMGuideData.allQuestions.prefix(20)) }
        return KNMGuideData.module(with: selectedModuleID)?.allQuestions ?? []
    }
    private var answeredCount: Int { questions.filter { selectedAnswers[$0.id] != nil }.count }
    private var correctCount: Int { questions.filter { selectedAnswers[$0.id] == $0.correctIndex }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Practice questions", nl: "Oefenvragen", ru: "Тренировочные вопросы"))
            DisclaimerBanner(text: localized(en: "This is not an official DUO exam.", nl: "Dit is geen officieel DUO-examen.", ru: "Это не официальный экзамен DUO."))

            Picker(localized(en: "Module", nl: "Module", ru: "Модуль"), selection: $selectedModuleID) {
                Text(localized(en: "Mixed practice", nl: "Gemengd oefenen", ru: "Смешанная практика")).tag("mixed")
                ForEach(KNMGuideData.modules) { module in
                    Text(module.title.value(lang)).tag(module.id)
                }
            }
            .pickerStyle(.menu)
            .appCardStyle()

            HStack {
                Text("\(correctCount)/\(answeredCount)")
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.success)
                Spacer()
                Button(localized(en: "Reset", nl: "Reset", ru: "Сброс")) {
                    selectedAnswers = [:]
                }
                .buttonStyle(GhostPremiumButtonStyle())
            }
            .appCardStyle()
            .accessibilityIdentifier("knm.practice.summary")

            ForEach(questions) { question in
                KNMQuestionCard(question: question, selectedIndex: selectedAnswers[question.id]) { index in
                    selectedAnswers[question.id] = index
                }
            }
        }
        .accessibilityIdentifier("knm.practice")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct KNMQuestionCard: View {
    let question: KNMPracticeQuestion
    let selectedIndex: Int?
    let onAnswer: (Int) -> Void
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(question.question.value(lang))
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(question.isOfficial ? officialLabel : appPracticeLabel)
                .font(AppTypography.metadata)
                .foregroundStyle(question.isOfficial ? AppColors.success : AppColors.warning)

            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                Button {
                    onAnswer(index)
                } label: {
                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        Image(systemName: optionIcon(index))
                            .font(.system(size: 14, weight: .bold))
                        Text(option.value(lang))
                            .font(AppTypography.body)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(optionForeground(index))
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(optionBackground(index))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("knm.quiz.option.\(question.id).\(index)")
            }

            if selectedIndex != nil {
                Text(question.explanation.value(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("knm.quiz.feedback")
            }
        }
        .appCardStyle()
    }

    private var officialLabel: String {
        switch lang {
        case .english: return "Official public question"
        case .dutch: return "Officiële openbare vraag"
        case .russian: return "Официальный публичный вопрос"
        }
    }

    private var appPracticeLabel: String {
        switch lang {
        case .english: return "App-created practice question"
        case .dutch: return "Oefenvraag gemaakt door de app"
        case .russian: return "Тренировочный вопрос, созданный приложением"
        }
    }

    private func optionIcon(_ index: Int) -> String {
        guard let selectedIndex else { return "circle" }
        if index == question.correctIndex { return "checkmark.circle.fill" }
        if index == selectedIndex { return "xmark.circle.fill" }
        return "circle"
    }

    private func optionForeground(_ index: Int) -> Color {
        guard selectedIndex != nil else { return AppColors.textPrimary }
        if index == question.correctIndex { return AppColors.success }
        if index == selectedIndex { return AppColors.error }
        return AppColors.textSecondary
    }

    private func optionBackground(_ index: Int) -> Color {
        guard selectedIndex != nil else { return AppColors.glassSurfaceElevated }
        if index == question.correctIndex { return AppColors.success.opacity(0.12) }
        if index == selectedIndex { return AppColors.error.opacity(0.12) }
        return AppColors.glassSurfaceElevated
    }
}

private struct KNMSourceListView: View {
    let sources: [KNMSource]
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Official sources", nl: "Officiële bronnen", ru: "Источники"))
            ForEach(sources) { source in
                if let url = AppURL.validatedWebURL(URL(string: source.url)) {
                    Button {
                        openURL(url)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(alignment: .top) {
                                Text(source.title.value(lang))
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(AppColors.cyanGlow)
                            }
                            Text(source.url)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(2)
                            Text("\(source.sourceType) • \(source.language) • \(source.retrievedAt)")
                                .font(AppTypography.metadata)
                                .foregroundStyle(source.verified ? AppColors.success : AppColors.warning)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("knm.sources")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private enum KNMSection: String, CaseIterable, Identifiable {
    case modules
    case practice
    case terms
    case sources
    case exam

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .modules: return "square.grid.2x2.fill"
        case .practice: return "checklist"
        case .terms: return "text.book.closed.fill"
        case .sources: return "link"
        case .exam: return "graduationcap.fill"
        }
    }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.modules, .english): return "Modules"
        case (.modules, .dutch): return "Modules"
        case (.modules, .russian): return "Модули"
        case (.practice, .english): return "Practice"
        case (.practice, .dutch): return "Oefenen"
        case (.practice, .russian): return "Практика"
        case (.terms, .english): return "Key terms"
        case (.terms, .dutch): return "Woorden"
        case (.terms, .russian): return "Слова"
        case (.sources, .english): return "Sources"
        case (.sources, .dutch): return "Bronnen"
        case (.sources, .russian): return "Источники"
        case (.exam, .english): return "Exam info"
        case (.exam, .dutch): return "Examen"
        case (.exam, .russian): return "Экзамен"
        }
    }
}
