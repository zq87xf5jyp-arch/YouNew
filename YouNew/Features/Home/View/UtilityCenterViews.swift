import SwiftUI
import EventKit
#if canImport(EventKitUI) && canImport(UIKit)
import EventKitUI
#endif
import UserNotifications

struct LifeTimelineView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var documentStore: DocumentStore
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var steps: [LifeTimelineStep] {
        LifeTimelineBuilder.steps(
            for: appState.selectedUserStatus,
            checklistItems: appState.visibleChecklistItems,
            documents: documentStore.items
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                timelineHero
                ForEach(steps) { step in
                    TimelineDetailCard(step: step, language: lang)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.home)
        .navigationTitle(title)
    }

    private var timelineHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "arrow.triangle.branch",
            badgeText: heroBadge,
            accent: AppColors.cyanGlow,
            asset: ContentMediaRegistry.profileImage ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
    }

    private var title: String {
        switch lang {
        case .english: return "Life Timeline"
        case .dutch: return "Levenslijn"
        case .russian: return "Жизненный маршрут"
        }
    }

    private var subtitle: String {
        switch lang {
        case .english: return "Your Netherlands path with status, documents, official sources, AI prompts, and due dates."
        case .dutch: return "Je Nederland-route met status, documenten, officiële bronnen, AI-hulp en datums."
        case .russian: return "Ваш путь в Нидерландах: статус, документы, источники, AI-пояснение и даты."
        }
    }

    private var heroBadge: String {
        switch lang {
        case .english: return "Your journey"
        case .dutch: return "Uw route"
        case .russian: return "Ваш маршрут"
        }
    }
}

private struct TimelineDetailCard: View {
    let step: LifeTimelineStep
    let language: AppLanguage
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                ProductSymbolTile(symbol: step.symbol, accent: accent, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title.value(language))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(step.explanation.value(language))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Text(step.status.localized(language))
                    .font(AppTypography.metadata)
                    .foregroundStyle(accent)
            }

            Text(documentText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            if let dueDate = step.dueDate {
                Label(dueDate.formattedForAppLanguage(language), systemImage: "calendar")
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColors.warning)
            }

            HStack(spacing: AppSpacing.small) {
                Button {
                    openURL(step.officialSourceURL)
                } label: {
                    Label(step.officialSourceName, systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())

                AIAskButton(
                    title: askTitle,
                    context: AIContext.empty(language: language),
                    prompt: step.aiPrompt.value(language)
                )
            }
        }
        .appCardStyle()
    }

    private var accent: Color {
        switch step.status {
        case .done: return AppColors.success
        case .inProgress: return AppColors.cyanGlow
        case .blocked: return AppColors.error
        case .notStarted: return AppColors.textTertiary
        }
    }

    private var documentText: String {
        let names = step.requiredDocuments.map { $0.localized(language) }.joined(separator: ", ")
        switch language {
        case .english: return "Required documents: \(names)"
        case .dutch: return "Benodigde documenten: \(names)"
        case .russian: return "Документы: \(names)"
        }
    }

    private var askTitle: String {
        switch language {
        case .english: return "Ask AI"
        case .dutch: return "Vraag AI"
        case .russian: return "Спросить AI"
        }
    }
}

struct DeadlineCenterView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedCalendarReminder: DeadlineReminder?
    @State private var statusMessage: String?

    private var lang: AppLanguage { languageManager.appLanguage }
    private var reminders: [DeadlineReminder] {
        let checklist = appState.visibleChecklistItems.compactMap { item -> DeadlineReminder? in
            guard let dueDate = item.dueDate, !item.isCompleted else { return nil }
            return DeadlineReminder(title: item.title(lang), detail: item.description(lang), possibleDueDate: dueDate, institutionName: item.officialSourceName, sourceURL: item.officialSourceURL)
        }
        return (checklist + MockDeadlinesData.reminders)
            .sorted { ($0.possibleDueDate ?? .distantFuture) < ($1.possibleDueDate ?? .distantFuture) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                deadlineHero
                ForEach(reminders) { reminder in
                    DeadlineCard(
                        reminder: reminder,
                        language: lang,
                        onAddCalendar: { selectedCalendarReminder = reminder },
                        onNotify: { scheduleNotification(reminder) }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.home)
        .navigationTitle(title)
        .sheet(item: $selectedCalendarReminder) { reminder in
            CalendarEventEditor(reminder: reminder)
        }
        .alert(infoTitle, isPresented: Binding(get: { statusMessage != nil }, set: { if !$0 { statusMessage = nil } })) {
            Button("OK", role: .cancel) { statusMessage = nil }
        } message: {
            Text(statusMessage ?? "")
        }
    }

    private var deadlineHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "calendar.badge.clock",
            badgeText: deadlineBadge,
            accent: AppColors.warning,
            asset: ContentMediaRegistry.calendarImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
    }

    private func scheduleNotification(_ reminder: DeadlineReminder) {
        Task {
            let success = await DeadlineNotificationScheduler.schedule(reminder)
            statusMessage = success ? notificationSuccess : notificationFailure
        }
    }

    private var title: String {
        switch lang {
        case .english: return "Deadline Center"
        case .dutch: return "Deadlinecentrum"
        case .russian: return "Центр дедлайнов"
        }
    }

    private var subtitle: String {
        switch lang {
        case .english: return "Track important dates from your checklist and add local reminders. Calendar events open in the iOS editor."
        case .dutch: return "Volg belangrijke datums uit je checklist en voeg lokale reminders toe. Agenda-items openen in de iOS-editor."
        case .russian: return "Отслеживайте важные даты из чеклиста и добавляйте локальные напоминания. События открываются в системном редакторе iOS."
        }
    }

    private var infoTitle: String { lang == .russian ? "Напоминание" : (lang == .dutch ? "Reminder" : "Reminder") }
    private var notificationSuccess: String { lang == .russian ? "Локальное напоминание добавлено." : (lang == .dutch ? "Lokale reminder toegevoegd." : "Local reminder added.") }
    private var notificationFailure: String { lang == .russian ? "Не удалось добавить напоминание." : (lang == .dutch ? "Reminder toevoegen mislukt." : "Could not add reminder.") }
    private var deadlineBadge: String { lang == .russian ? "Локальные напоминания" : (lang == .dutch ? "Lokale reminders" : "Local reminders") }
}

private struct DeadlineCard: View {
    let reminder: DeadlineReminder
    let language: AppLanguage
    let onAddCalendar: () -> Void
    let onNotify: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(reminder.title)
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text(reminder.detail)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
            Label(dateText, systemImage: "calendar.badge.clock")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.warning)
            LazyVGrid(columns: DetailPageLayout.twoColumnWhenPossible(for: 320, minimumColumnWidth: 140), spacing: AppSpacing.small) {
                Button(action: onAddCalendar) {
                    Label(calendarTitle, systemImage: "calendar.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
                Button(action: onNotify) {
                    Label(reminderTitle, systemImage: "bell.badge")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryPremiumButtonStyle())
                AIAskButton(title: askTitle, context: AIContext.empty(language: language), prompt: aiPrompt)
            }
        }
        .appCardStyle()
    }

    private var dateText: String {
        reminder.possibleDueDate?.formattedForAppLanguage(language) ?? noDateTitle
    }

    private var calendarTitle: String { language == .russian ? "Открыть календарь" : (language == .dutch ? "Open agenda" : "Open calendar") }
    private var reminderTitle: String { language == .russian ? "Напомнить" : (language == .dutch ? "Reminder" : "Remind") }
    private var askTitle: String { language == .russian ? "Спросить AI" : (language == .dutch ? "Vraag AI" : "Ask AI") }
    private var noDateTitle: String { language == .russian ? "Добавьте дату" : (language == .dutch ? "Voeg datum toe" : "Add a date") }
    private var aiPrompt: String {
        "Deadline: \(reminder.title). Date: \(dateText). Source: \(reminder.institutionName). Explain what to prepare and which documents to check. Do not invent rules."
    }
}

private enum DeadlineNotificationScheduler {
    static func schedule(_ reminder: DeadlineReminder) async -> Bool {
        guard let dueDate = reminder.possibleDueDate else { return false }
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { return false }
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.detail
            content.sound = .default
            let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let request = UNNotificationRequest(identifier: "younew.deadline.\(reminder.id.uuidString)", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }
}

private struct CalendarEventEditor: View {
    let reminder: DeadlineReminder

    var body: some View {
#if canImport(EventKitUI) && canImport(UIKit)
        CalendarEventEditController(reminder: reminder)
#else
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(reminder.title)
                .font(AppTypography.cardTitle)
            Text("Calendar editing is available on iOS.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding()
#endif
    }
}

#if canImport(EventKitUI) && canImport(UIKit)
private struct CalendarEventEditController: UIViewControllerRepresentable {
    let reminder: DeadlineReminder
    private let store = EKEventStore()

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        let event = EKEvent(eventStore: store)
        let startDate = reminder.possibleDueDate ?? Date()
        event.title = reminder.title
        event.notes = "\(reminder.detail)\nSource: \(reminder.institutionName)"
        event.startDate = startDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        event.calendar = store.defaultCalendarForNewEvents
        controller.event = event
        controller.eventStore = store
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            controller.dismiss(animated: true)
        }
    }
}
#endif

struct VerifiedExpertsView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var experts: [LocalPartner] {
        MockLocalPartnersData.partners(in: appState.selectedCity)
            .filter { $0.plan != .freeListing && [.legal, .finance, .education, .home].contains($0.category) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                expertsHero
                DisclaimerBanner(text: disclaimer)
                ForEach(experts) { expert in
                    NavigationLink(value: AppDestination.localPartnerDetail(expert.id)) {
                        LocalPartnerRow(partner: expert, language: lang)
                    }
                    .buttonStyle(AppPressableCardButtonStyle())
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.map)
        .navigationTitle(title)
    }

    private var title: String { lang == .russian ? "Verified Experts" : "Verified Experts" }
    private var subtitle: String { lang == .russian ? "Юристы, налоговые консультанты, переводчики, школы и другие проверенные специалисты по вашему городу." : "Immigration, tax, notary, translation, housing, insurance, mortgage, accounting, driving, and language experts by city." }
    private var disclaimer: String { lang == .russian ? "Commercial placement is always marked. Verify price, availability, and credentials directly with the expert." : "Featured, Partner, and Sponsored placements are marked. Verify price, availability, and credentials directly with the expert." }
    private var expertsHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "checkmark.seal.fill",
            badgeText: expertsBadge,
            accent: AppColors.success,
            asset: ContentMediaRegistry.workImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
    }

    private var expertsBadge: String { lang == .russian ? "Partner listings" : "Partner listings" }
}

struct AILetterGeneratorView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var selectedTemplateTitle: String = ""
    @State private var recipient = ""
    @State private var situation = ""
    @State private var generatedDraft = ""

    private var lang: AppLanguage { languageManager.appLanguage }
    private var templates: [LetterExample] {
        MockLettersData.examples.filter { $0.isVisible(for: appState.selectedUserStatus?.personaTag, scope: .currentAndUniversal) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                generatorHero
                DisclaimerBanner(text: disclaimer, tone: AppColors.warning)
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Picker(templateTitle, selection: $selectedTemplateTitle) {
                        Text(templatePlaceholder).tag("")
                        ForEach(templates) { template in
                            Text(template.title(lang)).tag(template.title(lang))
                        }
                    }
                    TextField(recipientTitle, text: $recipient)
                        .textFieldStyle(.roundedBorder)
                    TextField(situationTitle, text: $situation, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4, reservesSpace: true)
                    Button(generateTitle) {
                        generatedDraft = draftText
                    }
                    .buttonStyle(PrimaryPremiumButtonStyle())
                }
                .appCardStyle()

                if !generatedDraft.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(draftTitle)
                            .font(AppTypography.sectionTitle)
                        Text(generatedDraft)
                            .font(AppTypography.body)
                            .textSelection(.enabled)
                        ShareLink(item: generatedDraft) {
                            Label(shareTitle, systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryPremiumButtonStyle())
                    }
                    .appCardStyle()
                }

                AIAskButton(title: aiTitle, context: AIContextBuilder.documentsContext(language: lang, appState: appState), prompt: aiPrompt)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground(.documents)
        .navigationTitle(title)
        .onAppear {
            if selectedTemplateTitle.isEmpty {
                selectedTemplateTitle = templates.first?.title(lang) ?? ""
            }
        }
    }

    private var draftText: String {
        """
        Subject: \(selectedTemplateTitle)

        Dear \(recipient.isEmpty ? "Sir/Madam" : recipient),

        I am writing about: \(selectedTemplateTitle).

        Situation:
        \(situation.isEmpty ? "[Add the facts, dates, reference numbers, and what you are requesting.]" : situation)

        Please let me know the next official step and which documents you need from me.

        Kind regards,
        [Your name]

        \(disclaimer)
        """
    }

    private var aiPrompt: String { "Draft an official Dutch/English letter for: \(selectedTemplateTitle). Situation: \(situation). This is a draft, not legal advice. Do not invent legal deadlines." }
    private var title: String {
        switch lang {
        case .english: return "AI Letter Generator"
        case .dutch: return "AI-briefgenerator"
        case .russian: return "AI Letter Generator"
        }
    }

    private var subtitle: String {
        switch lang {
        case .english: return "Choose a template, fill the fields, and generate an official letter draft."
        case .dutch: return "Kies een sjabloon, vul de velden in en maak een concept voor een officiele brief."
        case .russian: return "Выберите шаблон, заполните поля и получите черновик официального письма."
        }
    }

    private var disclaimer: String { "This is a draft, not legal advice." }
    private var templateTitle: String {
        switch lang {
        case .english: return "Template"
        case .dutch: return "Sjabloon"
        case .russian: return "Шаблон"
        }
    }

    private var templatePlaceholder: String {
        switch lang {
        case .english: return "Choose template"
        case .dutch: return "Kies sjabloon"
        case .russian: return "Выберите шаблон"
        }
    }

    private var recipientTitle: String {
        switch lang {
        case .english: return "Recipient"
        case .dutch: return "Ontvanger"
        case .russian: return "Получатель"
        }
    }

    private var situationTitle: String {
        switch lang {
        case .english: return "Situation"
        case .dutch: return "Situatie"
        case .russian: return "Ситуация"
        }
    }

    private var generateTitle: String {
        switch lang {
        case .english: return "Generate draft"
        case .dutch: return "Maak concept"
        case .russian: return "Сгенерировать черновик"
        }
    }

    private var draftTitle: String {
        switch lang {
        case .english: return "Draft"
        case .dutch: return "Concept"
        case .russian: return "Черновик"
        }
    }

    private var shareTitle: String {
        switch lang {
        case .english: return "Share or email"
        case .dutch: return "Delen of mailen"
        case .russian: return "Открыть/отправить"
        }
    }

    private var aiTitle: String {
        switch lang {
        case .english: return "Improve with AI"
        case .dutch: return "Verbeteren met AI"
        case .russian: return "Улучшить через AI"
        }
    }
    private var generatorHero: some View {
        CategoryHeroVisual(
            assetName: nil,
            title: title,
            subtitle: subtitle,
            symbol: "envelope.badge.fill",
            badgeText: generatorBadge,
            accent: AppColors.violet,
            asset: ContentMediaRegistry.savedImage ?? ContentMediaRegistry.officialSourcesHero,
            height: 240,
            language: lang
        )
    }

    private var generatorBadge: String { lang == .russian ? "Черновик" : (lang == .dutch ? "Concept" : "Draft") }
}

struct DiscoverNetherlandsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = AppSpacing.screenHorizontal
            let contentWidth = max(0, proxy.size.width - horizontalPadding * 2)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    discoverHero
                    VStack(spacing: AppSpacing.small) {
                        ForEach(Array(discoverItems.enumerated()), id: \.offset) { _, item in
                            NavigationLink(value: item.destination) {
                                discoverCard(item)
                            }
                            .buttonStyle(AppPressableCardButtonStyle())
                        }
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, AppSpacing.medium)
                .tabBarScrollReserve()
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(title)
    }

    private var title: String { lang == .russian ? "Discover Netherlands" : "Discover Netherlands" }
    private var subtitle: String { lang == .russian ? "Культурный контент находится отдельно от основного практического пути." : "Culture and history are here, outside the primary action flow." }
    private var historySubtitle: String { lang == .russian ? "Контекст страны и общества." : "Country and society context." }
    private var figuresSubtitle: String { lang == .russian ? "Известные нидерландские личности." : "Notable Dutch people." }
    private var cultureSubtitle: String { lang == .russian ? "Музеи, привычки и повседневная культура." : "Museums, habits, and daily culture." }
    private var holidaysSubtitle: String { lang == .russian ? "Праздники и календарь." : "Holidays and calendar." }
    private var discoverHero: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumImageView(
                asset: ContentMediaRegistry.homeAtmosphereHero ?? ContentMediaRegistry.cultureWideHero ?? ContentMediaRegistry.mapImage ?? ContentMediaRegistry.officialSourcesHero,
                language: lang,
                height: 240,
                aspectRatio: nil,
                mode: .fill,
                cornerRadius: AppCornerRadius.hero,
                overlayStyle: .none,
                fallbackCategory: .city,
                accessibilityLabel: title,
                targetPixelWidth: 1200,
                role: .hero,
                overlayPolicy: .none,
                focalPoint: .center
            )
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.12), Color.black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                LandmarkSymbolBadge(symbol: "sparkles.rectangle.stack.fill", accent: AppColors.dutchOrange, size: 48)
                Text(title)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Text(subtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.cardPadding)
        }
        .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240, alignment: .bottomLeading)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 0.85)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
    }

    private var discoverBadge: String { lang == .russian ? "Культура" : (lang == .dutch ? "Cultuur" : "Culture") }

    private var discoverItems: [(title: String, subtitle: String, symbol: String, destination: AppDestination, accent: Color)] {
        [
            ("History", historySubtitle, "clock.arrow.circlepath", .netherlandsHistory, AppColors.softBlue),
            ("Dutch Figures", figuresSubtitle, "person.text.rectangle", .dutchFigures, AppColors.violet),
            ("Culture", cultureSubtitle, "building.columns", .cultureAttractions, AppColors.dutchOrange),
            ("Dutch Holidays", holidaysSubtitle, "calendar", .dutchHolidays, AppColors.emerald)
        ]
    }

    private func discoverCard(_ item: (title: String, subtitle: String, symbol: String, destination: AppDestination, accent: Color)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ProductSymbolTile(symbol: item.symbol, accent: item.accent, size: 46)
            Text(item.title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
            Text(item.subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Image(systemName: AppIcons.forward)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .padding(14)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.stroke.opacity(0.72), lineWidth: 0.8))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
