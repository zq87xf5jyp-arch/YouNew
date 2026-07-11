import SwiftUI

struct DutchA1A2View: View {
    let initialModuleID: String?
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedSection: DutchCourseSection = .modules

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
                    case .flashcards:
                        flashcardsSection
                    case .practice:
                        DutchCoursePracticeView()
                    case .sources:
                        DutchCourseSourceListView(sources: DutchA1A2CourseData.sources)
                    }

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(title)
        .nlNavigationInline()
        .accessibilityIdentifier("dutchA1A2.screen")
    }

    private var header: some View {
        CategoryHeroVisual(
            assetName: "home_language_classroom",
            title: title,
            subtitle: localized(
                en: "Learn practical Dutch for daily life.",
                nl: "Praktisch Nederlands voor het dagelijks leven.",
                ru: "Практический нидерландский для повседневной жизни."
            ),
            symbol: "text.book.closed.fill",
            badgeText: "A1-A2",
            accent: AppColors.emerald
        )
    }

    private var disclaimer: some View {
        DisclaimerBanner(text: localized(
            en: "These are app practice tasks, not an official exam. Lessons are original learning support for daily life.",
            nl: "Dit zijn oefenopgaven in de app, geen officieel examen. De lessen zijn originele leerhulp voor dagelijks leven.",
            ru: "Это тренировочные задания приложения, не официальный экзамен. Уроки являются оригинальной учебной помощью для повседневной жизни."
        ))
        .accessibilityIdentifier("dutchA1A2.disclaimer")
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xSmall) {
                ForEach(DutchCourseSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        Label(section.title(lang), systemImage: section.icon)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(selectedSection == section ? .white : AppColors.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(selectedSection == section ? AppColors.emerald : AppColors.glassSurfaceElevated)
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
                        DutchCourseModuleView(module: module)
                    } label: {
                        dutchModuleCard(module)
                    }
                    .buttonStyle(NLTileButtonStyle())
                    .accessibilityIdentifier("dutchA1A2.module.\(module.id)")
                }
            }
        }
    }

    private func dutchModuleCard(_ module: DutchCourseModule) -> some View {
        HStack(alignment: .top, spacing: 12) {
            PremiumImageHeader(
                title: module.title.value(lang),
                asset: moduleImageAsset(module),
                language: lang,
                symbol: module.icon,
                accent: AppColors.emerald,
                height: 88,
                width: 96,
                cornerRadius: 18,
                fallbackCategory: moduleFallbackCategory(module)
            )
            .layoutPriority(0)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(module.level.rawValue)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.emerald, in: Capsule())
                    Text("\(module.lessons.count) \(localized(en: "lessons", nl: "lessen", ru: "уроков"))")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Text(module.title.value(lang))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(module.summary.value(lang))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
        .appCardStyle()
    }

    private var flashcardsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Flashcards", nl: "Flashcards", ru: "Карточки"))
            ForEach(allVocabulary.prefix(32)) { item in
                ProductInfoBlock(
                    title: item.nl,
                    bodyText: "\(lang == .russian ? item.ru : (item.en ?? item.ru))\n\(item.exampleNl)\n\(item.exampleRu)",
                    symbol: "textformat.abc",
                    accent: AppColors.emerald
                )
            }
        }
    }

    private var sortedModules: [DutchCourseModule] {
        guard let initialModuleID else { return DutchA1A2CourseData.modules }
        return DutchA1A2CourseData.modules.sorted { lhs, rhs in
            if lhs.id == initialModuleID { return true }
            if rhs.id == initialModuleID { return false }
            return lhs.title.value(lang) < rhs.title.value(lang)
        }
    }

    private var allVocabulary: [DutchVocabularyItem] {
        DutchA1A2CourseData.modules.flatMap { $0.lessons.flatMap(\.vocabulary) }
    }

    private var title: String {
        localized(en: "Dutch A1-A2", nl: "Nederlands A1-A2", ru: "Нидерландский A1-A2")
    }

    private func moduleImageAsset(_ module: DutchCourseModule) -> AppImageAsset? {
        switch module.id {
        case "basics", "personal-info", "grammar":
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.mapImage
        case "municipality":
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case "housing":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "transport":
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case "healthcare":
            return ContentMediaRegistry.healthcarePharmacyImage
        case "work-income":
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case "shopping-services":
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.foodImage
        case "time-appointments":
            return ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        default:
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private func moduleFallbackCategory(_ module: DutchCourseModule) -> PremiumImageFallbackCategory {
        switch module.id {
        case "municipality", "time-appointments":
            return .government
        case "housing":
            return .housing
        case "transport":
            return .transport
        case "healthcare":
            return .healthcare
        case "work-income":
            return .work
        case "shopping-services":
            return .integration
        case "grammar", "basics", "personal-info":
            return .dutchA1A2
        default:
            return .integration
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

private struct DutchCourseModuleView: View {
    let module: DutchCourseModule
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    CategoryHeroVisual(
                        assetName: nil,
                        title: module.title.value(lang),
                        subtitle: module.summary.value(lang),
                        symbol: module.icon,
                        badgeText: module.level.rawValue,
                        accent: AppColors.emerald,
                        asset: moduleHeroAsset,
                        language: lang
                    )
                    DisclaimerBanner(text: localized(en: "App-created Dutch practice. Not official DUO exam material.", nl: "Nederlandse oefening gemaakt door de app. Geen officieel DUO-examenmateriaal.", ru: "Тренировка нидерландского, созданная приложением. Не официальный материал экзамена DUO."))

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        NLSectionHeader(title: localized(en: "Lessons", nl: "Lessen", ru: "Уроки"))
                        ForEach(module.lessons) { lesson in
                            NavigationLink {
                                DutchCourseLessonView(module: module, lesson: lesson)
                            } label: {
                                HStack(spacing: AppSpacing.medium) {
                                    Image(systemName: module.icon)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(AppColors.emerald)
                                        .frame(width: 38, height: 38)
                                        .background(AppColors.emerald.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lesson.title.value(lang))
                                            .font(AppTypography.bodyStrong)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Text("\(lesson.vocabulary.count) \(localized(en: "words", nl: "woorden", ru: "слов")) • \(lesson.phrases.count) \(localized(en: "phrases", nl: "zinnen", ru: "фраз")) • \(lesson.dialogues.count) \(localized(en: "dialogues", nl: "dialogen", ru: "диалогов")) • \(lesson.exercises.count) \(localized(en: "tasks", nl: "opgaven", ru: "заданий"))")
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    Spacer()
                                }
                                .appCardStyle()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("dutchA1A2.lesson.\(lesson.id)")
                        }
                    }

                    DutchCourseSourceListView(sources: module.sourceIds.compactMap(DutchA1A2CourseData.source(with:)))
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

    private var moduleHeroAsset: AppImageAsset? {
        switch module.id {
        case "basics", "personal-info", "grammar":
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.profileImage
        case "municipality":
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case "housing":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "transport":
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case "healthcare":
            return ContentMediaRegistry.healthcarePharmacyImage
        case "work-income":
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case "shopping-services":
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.foodImage
        case "time-appointments":
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.calendarImage
        default:
            return ContentMediaRegistry.profileImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }
}

private struct DutchCourseLessonView: View {
    let module: DutchCourseModule
    let lesson: DutchLesson
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedAnswers: [String: String] = [:]

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 920) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    CategoryHeroVisual(
                        assetName: nil,
                        title: lesson.title.value(lang),
                        subtitle: module.title.value(lang),
                        symbol: module.icon,
                        badgeText: module.level.rawValue,
                        accent: AppColors.emerald,
                        asset: moduleHeroAsset,
                        language: lang
                    )
                    textBlock(label("Explanation", "Uitleg", "Объяснение"), lesson.explanation.value(lang))
                    vocabularyBlock
                    phrasesBlock
                    dialoguesBlock
                    grammarBlock
                    practiceBlock
                    relatedBlock
                    DutchCourseSourceListView(sources: lesson.sourceIds.compactMap(DutchA1A2CourseData.source(with:)))
                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(lesson.title.value(lang))
        .nlNavigationInline()
        .accessibilityIdentifier("dutchA1A2.lesson.detail")
    }

    private func textBlock(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: title)
            Text(text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .appCardStyle()
        }
    }

    private var moduleHeroAsset: AppImageAsset? {
        switch module.id {
        case "basics", "personal-info", "grammar":
            return ContentMediaRegistry.dailyCultureImage ?? ContentMediaRegistry.profileImage
        case "municipality":
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.officialSourcesHero
        case "housing":
            return ContentMediaRegistry.premiumHousingImage ?? ContentMediaRegistry.housingTerracedHousesImage
        case "transport":
            return ContentMediaRegistry.transportStationHero ?? ContentMediaRegistry.transportHero
        case "healthcare":
            return ContentMediaRegistry.healthcarePharmacyImage
        case "work-income":
            return ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero
        case "shopping-services":
            return ContentMediaRegistry.marketsLocalLifeImage ?? ContentMediaRegistry.foodImage
        case "time-appointments":
            return ContentMediaRegistry.municipalityCityHallImage ?? ContentMediaRegistry.calendarImage
        default:
            return ContentMediaRegistry.profileImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero
        }
    }

    private var vocabularyBlock: some View {
        Group {
            if !lesson.vocabulary.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    NLSectionHeader(title: label("Words", "Woorden", "Слова"))
                    ForEach(lesson.vocabulary) { item in
                        ProductInfoBlock(
                            title: item.nl,
                            bodyText: "\(lang == .russian ? item.ru : (item.en ?? item.ru))\n\(item.exampleNl)\n\(item.exampleRu)",
                            symbol: "textformat.abc",
                            accent: AppColors.emerald
                        )
                    }
                }
            }
        }
    }

    private var phrasesBlock: some View {
        Group {
            if !lesson.phrases.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    NLSectionHeader(title: label("Phrases", "Zinnen", "Фразы"))
                    ForEach(lesson.phrases) { phrase in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(phrase.nl)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(lang == .russian ? phrase.ru : (phrase.en ?? phrase.ru))
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                            Text(phrase.context.value(lang))
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.emerald)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                }
            }
        }
    }

    private var grammarBlock: some View {
        Group {
            if !lesson.grammarNotes.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    NLSectionHeader(title: label("Grammar", "Grammatica", "Грамматика"))
                    ForEach(lesson.grammarNotes) { note in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(note.title.value(lang))
                                .font(AppTypography.bodyStrong)
                            Text(note.explanation.value(lang))
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                            ForEach(note.examples, id: \.self) { example in
                                Text(example)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.emerald)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                }
            }
        }
    }

    private var dialoguesBlock: some View {
        Group {
            if !lesson.dialogues.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    NLSectionHeader(title: label("Mini-dialogues", "Minidialogen", "Мини-диалоги"))
                    ForEach(lesson.dialogues) { dialogue in
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text(dialogue.title.value(lang))
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColors.textPrimary)
                            ForEach(dialogue.lines) { line in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(line.speaker.value(lang))
                                        .font(AppTypography.metadata)
                                        .foregroundStyle(AppColors.emerald)
                                    Text(line.nl)
                                        .font(AppTypography.bodyStrong)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(line.translation.value(lang))
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                }
            }
        }
    }

    private var practiceBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: label("Practice", "Oefenen", "Практика"))
            ForEach(lesson.exercises) { exercise in
                exercisePanel(exercise)
            }
        }
    }

    private func exercisePanel(_ exercise: DutchExercise) -> some View {
        let selectedAnswer = selectedAnswers[exercise.id]
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductInfoBlock(
                title: "\(exercise.level.rawValue) • \(exercise.type.rawValue)",
                bodyText: exercise.prompt.value(lang),
                symbol: "text.book.closed.fill",
                accent: AppColors.emerald
            )

            ForEach(exercise.options, id: \.self) { option in
                Button {
                    selectedAnswers[exercise.id] = option
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: exerciseOptionIcon(option, selectedAnswer: selectedAnswer, exercise: exercise))
                            .font(.system(size: 14, weight: .bold))
                        Text(option)
                            .font(AppTypography.body)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(exerciseOptionForeground(option, selectedAnswer: selectedAnswer, exercise: exercise))
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(exerciseOptionBackground(option, selectedAnswer: selectedAnswer, exercise: exercise))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dutchA1A2.exercise.option.\(exercise.id)")
            }

            if selectedAnswer != nil {
                ProductInfoBlock(
                    title: label("Explanation", "Uitleg", "Пояснение"),
                    bodyText: exercise.explanation.value(lang),
                    symbol: "text.bubble.fill",
                    accent: AppColors.cyanGlow
                )
                .accessibilityIdentifier("dutchA1A2.exercise.feedback")
            }
        }
    }

    private func exerciseOptionIcon(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> String {
        guard let selectedAnswer else { return "circle" }
        if option == exercise.correctAnswer { return "checkmark.circle.fill" }
        if option == selectedAnswer { return "xmark.circle.fill" }
        return "circle"
    }

    private func exerciseOptionForeground(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> Color {
        guard let selectedAnswer else { return AppColors.textPrimary }
        if option == exercise.correctAnswer { return AppColors.success }
        if option == selectedAnswer { return AppColors.error }
        return AppColors.textSecondary
    }

    private func exerciseOptionBackground(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> Color {
        guard let selectedAnswer else { return AppColors.glassSurfaceElevated }
        if option == exercise.correctAnswer { return AppColors.success.opacity(0.12) }
        if option == selectedAnswer { return AppColors.error.opacity(0.12) }
        return AppColors.glassSurfaceElevated
    }

    private var relatedBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(
                title: label("Related topics", "Gerelateerde thema's", "Связанные темы"),
                subtitle: lesson.relatedDestinations.isEmpty ? relatedFallbackSubtitle : nil
            )

            if lesson.relatedDestinations.isEmpty {
                relatedFallbackRows
            } else {
                ForEach(lesson.relatedDestinations) { related in
                    NavigationLink(value: related.destination) {
                        Label(related.title.value(lang), systemImage: related.icon)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityIdentifier("dutchA1A2.lesson.related.dashboard")
    }

    private var relatedFallbackRows: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            relatedFallbackRow(
                title: label("Dutch terms", "Nederlandse termen", "Нидерландские термины"),
                subtitle: label("Check words that appear in letters and official pages.", "Controleer woorden uit brieven en officiële pagina's.", "Проверьте слова из писем и официальных страниц."),
                icon: "text.magnifyingglass",
                destination: .dutchTermsList
            )

            relatedFallbackRow(
                title: label("Search", "Zoeken", "Поиск"),
                subtitle: label("Find answers, documents, and official sources.", "Vind antwoorden, documenten en officiële bronnen.", "Найти ответы, документы и официальные источники."),
                icon: "magnifyingglass",
                destination: .searchList
            )

            relatedFallbackRow(
                title: label("Course overview", "Cursusoverzicht", "Обзор курса"),
                subtitle: label("Return to modules and practice.", "Ga terug naar modules en oefenen.", "Вернуться к модулям и практике."),
                icon: "text.book.closed",
                destination: .dutchA1A2
            )
        }
        .accessibilityIdentifier("dutchA1A2.lesson.related.empty")
    }

    private func relatedFallbackRow(title: String, subtitle: String, icon: String, destination: AppDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.emerald)
                    .frame(width: 34, height: 34)
                    .background(AppColors.emerald.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var relatedFallbackSubtitle: String {
        label(
            "Continue with terms, search, or the course overview.",
            "Ga verder met termen, zoeken of het cursusoverzicht.",
            "Продолжите через термины, поиск или обзор курса."
        )
    }

    private func label(_ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct DutchCoursePracticeView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedLevel: DutchLevel = .a1
    @State private var selectedModuleID = "mixed"
    @State private var selectedAnswers: [String: String] = [:]

    private var lang: AppLanguage { languageManager.appLanguage }
    private var modules: [DutchCourseModule] { DutchA1A2CourseData.modules.filter { $0.level == selectedLevel || $0.id == "grammar" } }
    private var exercises: [DutchExercise] {
        let base = selectedModuleID == "mixed" ? modules.flatMap(\.exercises) : (DutchA1A2CourseData.module(with: selectedModuleID)?.exercises ?? [])
        return Array(base.filter { $0.level == selectedLevel || selectedLevel == .a2 }.prefix(10))
    }
    private var answered: Int { exercises.filter { selectedAnswers[$0.id] != nil }.count }
    private var correct: Int { exercises.filter { selectedAnswers[$0.id] == $0.correctAnswer }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Mini test", nl: "Minitoets", ru: "Мини-тест"))
            DisclaimerBanner(text: localized(en: "These are app practice tasks, not an official exam.", nl: "Dit zijn oefenopgaven in de app, geen officieel examen.", ru: "Это тренировочные задания приложения, не официальный экзамен."))

            HStack(spacing: AppSpacing.small) {
                Picker("Level", selection: $selectedLevel) {
                    ForEach(DutchLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Module", selection: $selectedModuleID) {
                    Text(localized(en: "Mixed", nl: "Gemengd", ru: "Смешанный")).tag("mixed")
                    ForEach(DutchA1A2CourseData.modules) { module in
                        Text(module.title.value(lang)).tag(module.id)
                    }
                }
                .pickerStyle(.menu)
            }
            .appCardStyle()

            HStack {
                Text("\(correct)/\(answered)")
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColors.success)
                Spacer()
                Button(localized(en: "Reset", nl: "Reset", ru: "Сброс")) {
                    selectedAnswers = [:]
                }
                .buttonStyle(GhostPremiumButtonStyle())
            }
            .appCardStyle()
            .accessibilityIdentifier("dutchA1A2.practice.summary")

            ForEach(exercises) { exercise in
                exercisePanel(exercise)
            }
        }
        .accessibilityIdentifier("dutchA1A2.practice")
    }

    private func exercisePanel(_ exercise: DutchExercise) -> some View {
        let selectedAnswer = selectedAnswers[exercise.id]
        return VStack(alignment: .leading, spacing: AppSpacing.small) {
            ProductInfoBlock(
                title: "\(exercise.level.rawValue) • \(exercise.type.rawValue)",
                bodyText: exercise.prompt.value(lang),
                symbol: "text.book.closed.fill",
                accent: AppColors.emerald
            )

            ForEach(exercise.options, id: \.self) { option in
                Button {
                    selectedAnswers[exercise.id] = option
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: exerciseOptionIcon(option, selectedAnswer: selectedAnswer, exercise: exercise))
                            .font(.system(size: 14, weight: .bold))
                        Text(option)
                            .font(AppTypography.body)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(exerciseOptionForeground(option, selectedAnswer: selectedAnswer, exercise: exercise))
                    .padding(AppSpacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(exerciseOptionBackground(option, selectedAnswer: selectedAnswer, exercise: exercise))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("dutchA1A2.exercise.option.\(exercise.id)")
            }

            if selectedAnswer != nil {
                ProductInfoBlock(
                    title: localized(en: "Explanation", nl: "Uitleg", ru: "Пояснение"),
                    bodyText: exercise.explanation.value(lang),
                    symbol: "text.bubble.fill",
                    accent: AppColors.cyanGlow
                )
                .accessibilityIdentifier("dutchA1A2.exercise.feedback")
            }
        }
    }

    private func exerciseOptionIcon(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> String {
        guard let selectedAnswer else { return "circle" }
        if option == exercise.correctAnswer { return "checkmark.circle.fill" }
        if option == selectedAnswer { return "xmark.circle.fill" }
        return "circle"
    }

    private func exerciseOptionForeground(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> Color {
        guard let selectedAnswer else { return AppColors.textPrimary }
        if option == exercise.correctAnswer { return AppColors.success }
        if option == selectedAnswer { return AppColors.error }
        return AppColors.textSecondary
    }

    private func exerciseOptionBackground(_ option: String, selectedAnswer: String?, exercise: DutchExercise) -> Color {
        guard let selectedAnswer else { return AppColors.glassSurfaceElevated }
        if option == exercise.correctAnswer { return AppColors.success.opacity(0.12) }
        if option == selectedAnswer { return AppColors.error.opacity(0.12) }
        return AppColors.glassSurfaceElevated
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private struct DutchCourseSourceListView: View {
    let sources: [DutchCourseSource]
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.openURL) private var openURL
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            NLSectionHeader(title: localized(en: "Sources", nl: "Bronnen", ru: "Источники"))
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
                                    .foregroundStyle(AppColors.emerald)
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
        .accessibilityIdentifier("dutchA1A2.sources")
    }

    private func localized(en: String, nl: String, ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

private enum DutchCourseSection: String, CaseIterable, Identifiable {
    case modules
    case flashcards
    case practice
    case sources

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .modules: return "square.grid.2x2.fill"
        case .flashcards: return "rectangle.on.rectangle.angled"
        case .practice: return "checklist"
        case .sources: return "link"
        }
    }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.modules, .english): return "Modules"
        case (.modules, .dutch): return "Modules"
        case (.modules, .russian): return "Модули"
        case (.flashcards, .english): return "Flashcards"
        case (.flashcards, .dutch): return "Flashcards"
        case (.flashcards, .russian): return "Карточки"
        case (.practice, .english): return "Practice"
        case (.practice, .dutch): return "Oefenen"
        case (.practice, .russian): return "Практика"
        case (.sources, .english): return "Sources"
        case (.sources, .dutch): return "Bronnen"
        case (.sources, .russian): return "Источники"
        }
    }
}
