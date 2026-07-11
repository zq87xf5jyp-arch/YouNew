import Foundation
import Combine
import SwiftUI
import Network

@MainActor
final class AIViewModel: ObservableObject {
    enum SendError: LocalizedError {
        case emptyInput
        case serviceUnavailable
        case unknown

        var errorDescription: String? {
            switch self {
            case .emptyInput: return nil
            case .serviceUnavailable: return "Service temporarily unavailable. Please try again."
            case .unknown: return "Something went wrong. Please try again."
            }
        }
    }

    private struct CachedAIResponse: Codable {
        let response: AIResponse
        let responseCount: Int
        let updatedAt: Date
    }

    enum RequestState: Equatable {
        case idle
        case loading
        case failed(String)
    }

    @Published var conversation = AIConversation()
    @Published var input = ""
    @Published private(set) var requestState: RequestState = .idle
    @Published var responseSources: [OfficialSource] = []
    @Published private(set) var structuredResponses: [UUID: AIResponse] = [:]
    @Published private(set) var canRetryLastMessage = false

    var isLoading: Bool {
        if case .loading = requestState { return true }
        return false
    }

    var lastError: String? {
        if case .failed(let message) = requestState { return message }
        return nil
    }
    @Published var suggestedActions: [String] = []
    @Published var safetyNote: String? = nil
    @Published var suggestedResources: [ResourceLinkItem] = []
    @Published var suggestedMapCategory: PlaceCategory?
    @Published var contextQuickPrompts: [String] = []
    @Published var activeContextTitle: String? = nil
    @Published var activeContextSummary: String? = nil
    @Published private(set) var isOffline = false

    private let service: AIServiceProtocol
    private var contextSnapshot: AssistantContextSnapshot?
    private var activeContext: AIContext?
    private var activeLanguage: AppLanguage = .english
    private var activeWorkflow: AIWorkflow?
    private var sendTask: Task<Void, Never>?
    private var activeRequestID: UUID?
    private var activeUserMessageID: UUID?
    private var activeAssistantMessageID: UUID?
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "YouNew.AIConnectivity")
    private let conversationStorageKey = AssistantStorage.conversationStorageKey
    private let workflowStorageKey = AssistantStorage.workflowStorageKey
    private let answerCacheStorageKey = AssistantStorage.answerCacheStorageKey
    private let structuredResponsesStorageKey = AssistantStorage.structuredResponsesStorageKey
    private let cacheFrequencyThreshold = 2
    private let cacheTtl: TimeInterval = 60 * 60 * 24 * 30
    private var answerCache: [String: CachedAIResponse] = [:]

    private var currentLanguage: AppLanguage {
        activeContext?.userLanguage ?? activeLanguage
    }

    init(service: AIServiceProtocol? = nil) {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-uiTesting"),
           ProcessInfo.processInfo.arguments.contains("-resetUITestState") {
            Self.resetPersistentAssistantStateForUITesting()
        }
#endif
        self.service = service ?? AIService()
        Self.removeLegacyAssistantStateIfNeeded()
        conversation = Self.loadConversation(storageKey: conversationStorageKey)
        activeWorkflow = Self.loadActiveWorkflow(storageKey: workflowStorageKey)
        answerCache = Self.loadAnswerCache(storageKey: answerCacheStorageKey)
        structuredResponses = Self.loadStructuredResponses(storageKey: structuredResponsesStorageKey)
        startConnectivityMonitor()
    }

    deinit {
        monitor.cancel()
        sendTask?.cancel()
    }

#if DEBUG
    private static func resetPersistentAssistantStateForUITesting() {
        let defaults = UserDefaults.standard
        AssistantStorage.allPersistentKeys.forEach { defaults.removeObject(forKey: $0) }
    }
#endif

    private static func removeLegacyAssistantStateIfNeeded() {
        let defaults = UserDefaults.standard
        let migrationKey = AssistantStorage.legacyStorageClearedKey
        guard !defaults.bool(forKey: migrationKey) else { return }
        AssistantStorage.legacyStorageKeys.forEach { defaults.removeObject(forKey: $0) }
        defaults.set(true, forKey: migrationKey)
    }

    func followUpPrompts(for language: AppLanguage) -> [String] {
        [
            L10n.t("ai.followup.explain_simpler", language),
            L10n.t("ai.followup.what_next", language),
            L10n.t("ai.followup.show_official_site", language)
        ]
    }

    func displayedQuickPrompts(for language: AppLanguage) -> [String] {
        Array(uniquedPrompts(contextQuickPrompts + fallbackQuickPrompts(for: language)).prefix(4))
    }

    private func uniquedPrompts(_ prompts: [String]) -> [String] {
        var seen = Set<String>()
        return prompts.filter { prompt in
            seen.insert(promptDedupeKey(for: prompt)).inserted
        }
    }

    private func promptDedupeKey(for prompt: String) -> String {
        let normalized = prompt
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        let mentionsDUO = normalized.contains("duo")
        let asksVerification = [
            "verify", "check", "controleer", "controleren", "проверить", "провер", "проверь"
        ].contains { normalized.contains($0) }
        if mentionsDUO && asksVerification {
            return "intent:duo-verification"
        }

        return "literal:\(normalized)"
    }

    private func fallbackQuickPrompts(for language: AppLanguage) -> [String] {
        if let persona = activeContext?.activePersonaTag {
            return personaQuickPrompts(for: persona, language: language)
        }
        switch language {
        case .russian:
            return [
                "Какое действие сейчас самое безопасное?",
                "Где проверить это официально?",
                "Какие шаги подходят моему профилю?",
                "Найти информацию по моему пути"
            ]
        case .dutch:
            return [
                "Wat is nu mijn veiligste volgende stap?",
                "Waar kan ik dit officieel controleren?",
                "Welke stappen passen bij mijn profiel?",
                "Zoek informatie voor mijn route"
            ]
        case .english:
            return [
                "What is my safest next step?",
                "Where can I verify this officially?",
                "Which steps fit my profile?",
                "Find information for my path"
            ]
        }
    }

    private func personaQuickPrompts(for persona: PersonaTag, language: AppLanguage) -> [String] {
        switch (persona, language) {
        case (.student, .english):
            return ["How do I verify DUO?", "Find student housing steps", "Explain student insurance", "Where can I study Dutch?"]
        case (.student, .dutch):
            return ["Hoe controleer ik DUO?", "Vind stappen voor studentenwoning", "Leg studentenverzekering uit", "Waar kan ik Nederlands leren?"]
        case (.student, .russian):
            return ["Как проверить DUO?", "Найти шаги по студенческому жилью", "Объясните страховку студента", "Где учить нидерландский?"]
        case (.worker, .english):
            return ["Check my work contract", "Explain my payslip", "Which tax letter matters?", "What are my employment rights?"]
        case (.worker, .dutch):
            return ["Controleer mijn arbeidscontract", "Leg mijn loonstrook uit", "Welke belastingbrief is belangrijk?", "Wat zijn mijn arbeidsrechten?"]
        case (.worker, .russian):
            return ["Проверить рабочий договор", "Объясните payslip", "Какое налоговое письмо важно?", "Какие у меня трудовые права?"]
        case (.refugee, .english):
            return ["What should I verify with IND?", "Find integration steps", "Explain work permission", "Find support organizations"]
        case (.refugee, .dutch):
            return ["Wat controleer ik bij IND?", "Vind integratiestappen", "Leg werktoestemming uit", "Vind hulporganisaties"]
        case (.refugee, .russian):
            return ["Что проверить в IND?", "Найти шаги интеграции", "Объясните разрешение на работу", "Найти организации поддержки"]
        case (.family, .english):
            return ["Find schools near me", "Explain kinderopvang", "Check child benefits", "Find family healthcare steps"]
        case (.family, .dutch):
            return ["Vind scholen in de buurt", "Leg kinderopvang uit", "Controleer kinderbijslag", "Vind zorgstappen voor gezin"]
        case (.family, .russian):
            return ["Найти школы рядом", "Объясните kinderopvang", "Проверить детские пособия", "Найти шаги медицины для семьи"]
        case (.tourist, .english):
            return ["What matters for short stay?", "Find emergency help", "Explain public transport", "What steps can tourists skip?"]
        case (.tourist, .dutch):
            return ["Wat telt bij kort verblijf?", "Vind noodhulp", "Leg openbaar vervoer uit", "Welke stappen kan een toerist overslaan?"]
        case (.tourist, .russian):
            return ["Что важно при short stay?", "Найти экстренную помощь", "Объясните транспорт", "Какие шаги туристу не нужны?"]
        case (.entrepreneur, .english):
            return ["Explain KVK registration", "Check VAT basics", "Find business permit steps", "What taxes matter for business?"]
        case (.entrepreneur, .dutch):
            return ["Leg KVK-inschrijving uit", "Controleer btw-basis", "Vind vergunningstappen", "Welke belasting telt voor bedrijf?"]
        case (.entrepreneur, .russian):
            return ["Объясните регистрацию KVK", "Проверить основы VAT/BTW", "Найти шаги business permits", "Какие налоги важны бизнесу?"]
        case (.lgbt, .english):
            return ["Find legal safety support", "Find LGBT healthcare support", "Report discrimination safely", "Find trusted organizations"]
        case (.lgbt, .dutch):
            return ["Vind juridische veiligheid", "Vind LGBT-zorgsteun", "Meld discriminatie veilig", "Vind betrouwbare organisaties"]
        case (.lgbt, .russian):
            return ["Найти поддержку правовой безопасности", "Найти ЛГБТ медподдержку", "Сообщить о дискриминации безопасно", "Найти trusted organizations"]
        case (.eu, .english), (.nonEU, .english), (.highlySkilledMigrant, .english), (.universal, .english):
            return ["What is my next official step?", "Check registration requirements", "Find healthcare steps", "Verify work or stay rules"]
        case (.eu, .dutch), (.nonEU, .dutch), (.highlySkilledMigrant, .dutch), (.universal, .dutch):
            return ["Wat is mijn volgende officiële stap?", "Controleer inschrijfvereisten", "Vind zorgstappen", "Controleer werk- of verblijfsregels"]
        case (.eu, .russian), (.nonEU, .russian), (.highlySkilledMigrant, .russian), (.universal, .russian):
            return ["Какой следующий официальный шаг?", "Проверить требования регистрации", "Найти шаги по медицине", "Проверить правила работы или пребывания"]
        }
    }

    func sendCurrentMessage() async {
        guard !isLoading else { return }
        let message = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            requestState = .idle
            canRetryLastMessage = false
            return
        }

        let language = currentLanguage
        let context = activeContext ?? fallbackContext(language: language)
        let userMessage = appendUserMessage(message, context: context)
        activeUserMessageID = userMessage.id
        let loadingMessage = appendLoadingAssistantMessage(replyingTo: userMessage.id, context: context, language: language)
        activeAssistantMessageID = loadingMessage.id
        canRetryLastMessage = false
        input = ""

        switch AISafetyFilter.evaluate(message, language: currentLanguage) {
        case .allowed:
            break
        case .blocked(let warning), .privacyWarning(let warning):
            replaceAssistantMessage(
                loadingMessage.id,
                text: warning,
                response: safetyWarningResponse(warning, language: language),
                status: .error,
                context: context
            )
            requestState = .failed(warning)
            canRetryLastMessage = false
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        sendTask?.cancel()
        let requestID = UUID()
        activeRequestID = requestID
        withAnimation(AppAnimations.standard) {
            requestState = .loading
        }

        let cacheKey = Self.buildCacheKey(message: message, language: language, context: context)

        if let workflow = activeWorkflow,
           let advanced = AIWorkflowEngine.advance(workflow: workflow, answer: message, language: language, context: context) {
            activeWorkflow = advanced.workflow
            persistActiveWorkflow()
            withAnimation(AppAnimations.standard) {
                applyAIResponse(advanced.response, language: language, replyingTo: userMessage.id, replacing: loadingMessage.id, context: context)
                requestState = .idle
            }
            suggestedResources = advanced.response.sources.compactMap(resourceLink(from:))
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        if context.activePersonaTag != .tourist,
           let started = AIWorkflowEngine.startIfNeeded(query: message, language: language, context: context) {
            activeWorkflow = started.workflow
            persistActiveWorkflow()
            withAnimation(AppAnimations.standard) {
                applyAIResponse(started.response, language: language, replyingTo: userMessage.id, replacing: loadingMessage.id, context: context)
                requestState = .idle
            }
            suggestedResources = started.response.sources.compactMap(resourceLink(from:))
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        if let contextualResponse = AssistantAnswerEngine.getAssistantAnswer(
            userText: message,
            language: language,
            context: context
        ) {
            activeWorkflow = nil
            persistActiveWorkflow()
            withAnimation(AppAnimations.standard) {
                applyAIResponse(contextualResponse, language: language, replyingTo: userMessage.id, replacing: loadingMessage.id, context: context)
                requestState = .idle
            }
            suggestedResources = contextualResponse.sources.compactMap(resourceLink(from:))
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        if let localResponse = AIResponseComposer.compose(query: message, language: language, context: context) {
            withAnimation(AppAnimations.standard) {
                applyAIResponse(localResponse, language: language, replyingTo: userMessage.id, replacing: loadingMessage.id, context: context)
                requestState = .idle
            }
            suggestedResources = localResponse.sources.compactMap(resourceLink(from:))
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        if let cachedResponse = cachedResponse(for: cacheKey) {
            withAnimation(AppAnimations.standard) {
                requestState = .idle
                appendCachedResponse(cachedResponse, language: language, replyingTo: userMessage.id, context: context)
            }
            let baseResources = await service.suggestResources(for: message, language: language)
            guard activeRequestID == requestID, !Task.isCancelled else { return }
            if let status = contextSnapshot?.status {
                let ranked = ResourceRelevanceEngine.resources(
                    for: status, all: MockResourcesData.items
                )[.recommendedNow] ?? []
                suggestedResources = Array((baseResources + ranked).prefix(6))
            } else {
                suggestedResources = baseResources
            }
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
            return
        }

        sendTask = Task {
            defer {
                if activeRequestID == requestID {
                    sendTask = nil
                    withAnimation(AppAnimations.standard) {
                if case .loading = requestState { requestState = .idle }
            }
        }
            }

            guard activeRequestID == requestID, !Task.isCancelled else { return }

            let response: AIResponse
            do {
                response = try await service.sendMessage(
                    userMessage: message,
                    context: context,
                    conversation: conversation.messages
                )
                if response.isVerified {
                    cacheResponse(response, for: cacheKey)
                }
            } catch {
                response = AIResponse.unverified(language: language)
            }

            guard activeRequestID == requestID, !Task.isCancelled else { return }

            if response.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                withAnimation(AppAnimations.standard) {
                    canRetryLastMessage = true
                    requestState = .failed(localizedNoResponseError(for: language))
                    replaceAssistantMessage(
                        loadingMessage.id,
                        text: localizedNoResponseError(for: language),
                        response: nil,
                        status: .error,
                        context: context
                    )
                }
            } else {
                applyAIResponse(response, language: language, replyingTo: userMessage.id, context: context)
            }

            guard activeRequestID == requestID, !Task.isCancelled else { return }

            let baseResources = await service.suggestResources(for: message, language: language)
            guard activeRequestID == requestID, !Task.isCancelled else { return }
            if let status = contextSnapshot?.status {
                let ranked = ResourceRelevanceEngine.resources(
                    for: status, all: MockResourcesData.items
                )[.recommendedNow] ?? []
                suggestedResources = Array((baseResources + ranked).prefix(6))
            } else {
                suggestedResources = baseResources
            }
            guard activeRequestID == requestID, !Task.isCancelled else { return }
            suggestedMapCategory = suggestedCategory(for: message)
            activeUserMessageID = nil
            activeAssistantMessageID = nil
        }
    }

    func useQuickPrompt(_ prompt: String) async {
        guard !isLoading else { return }
        input = prompt
        await sendCurrentMessage()
    }

    func cancelCurrentResponse() {
        let hadRetryableMessage = activeUserMessageID != nil
        activeRequestID = nil
        activeUserMessageID = nil
        let assistantMessageID = activeAssistantMessageID
        activeAssistantMessageID = nil
        sendTask?.cancel()
        sendTask = nil
        withAnimation(AppAnimations.standard) {
            canRetryLastMessage = hadRetryableMessage
            requestState = .failed(localizedCancelledRequestText(for: currentLanguage))
            if let assistantMessageID {
                replaceAssistantMessage(
                    assistantMessageID,
                    text: localizedCancelledRequestText(for: currentLanguage),
                    response: nil,
                    status: .error,
                    context: activeContext
                )
            }
        }
    }

    func clearConversation() {
        activeRequestID = nil
        activeUserMessageID = nil
        sendTask?.cancel()
        sendTask = nil
        withAnimation(AppAnimations.standard) {
            conversation.clear()
            structuredResponses.removeAll()
            suggestedResources = []
            responseSources = []
            suggestedActions = []
            safetyNote = nil
            suggestedMapCategory = nil
            canRetryLastMessage = false
            activeAssistantMessageID = nil
            activeWorkflow = nil
            persistActiveWorkflow()
            requestState = .idle
        }
        persistConversation()
        UserDefaults.standard.removeObject(forKey: structuredResponsesStorageKey)
    }

    func retryLastMessage() async {
        guard !isLoading,
              canRetryLastMessage,
              let lastUserMessage = conversation.messages.last(where: { $0.role == .user })
        else { return }
        canRetryLastMessage = false
        requestState = .idle
        input = lastUserMessage.text
        conversation.removeLastUserMessage()
        persistConversation()
        await sendCurrentMessage()
    }

    func structuredResponse(for messageID: UUID) -> AIResponse? {
        structuredResponses[messageID]
    }

    func updateContext(from appState: AppStateViewModel, language: AppLanguage) {
        activeLanguage = language
        contextSnapshot = AssistantContextSnapshot(
            status: appState.selectedUserStatus,
            city: appState.selectedCity,
            completedChecklistCount: appState.visibleChecklistItems.filter(\.isCompleted).count,
            totalChecklistCount: appState.visibleChecklistItems.count,
            hasBSN: appState.userProfile.hasBSN,
            hasDigiD: appState.userProfile.hasDigiD,
            hasHealthInsurance: appState.userProfile.hasHealthInsuranceNL
        )
        contextQuickPrompts = AssistantContextEngine.quickPrompts(
            for: appState.selectedUserStatus, language: language
        )
        let context = AIContextBuilder.assistantHomeContext(appState: appState, language: language)
        activeContext = context
        updateContextLabels(context)
    }

    func updateContext(_ context: AIContext) {
        activeContext = context
        activeLanguage = context.userLanguage
        contextQuickPrompts = contextualPrompts(for: context)
        updateContextLabels(context)
    }

    private func suggestedCategory(for message: String) -> PlaceCategory? {
        let lower = message.lowercased()
        // English
        if lower.contains("register") || lower.contains("municipality") || lower.contains("bsn") { return .municipality }
        if lower.contains("medical") || lower.contains("hospital") { return .healthcare }
        if lower.contains("pharmacy") { return .pharmacy }
        if lower.contains("legal") || lower.contains("fine") || lower.contains("cjib") || lower.contains("rule") { return .legalHelp }
        if lower.contains("shelter") || lower.contains("refugee") || lower.contains("immigration") { return .immigrationSupport }
        if lower.contains("student") || lower.contains("university") || lower.contains("duo") { return .studentHelp }
        if lower.contains("library") { return .library }
        // Dutch
        if lower.contains("gemeente") || lower.contains("inschrijv") { return .municipality }
        if lower.contains("ziekenhuis") || lower.contains("arts") || lower.contains("dokter") { return .healthcare }
        if lower.contains("apotheek") { return .pharmacy }
        if lower.contains("juridisch") || lower.contains("rechtshulp") { return .legalHelp }
        if lower.contains("opvang") || lower.contains("vluchteling") || lower.contains("immigratie") { return .immigrationSupport }
        if lower.contains("universiteit") || lower.contains("bibliotheek") { return .library }
        // Russian
        if lower.contains("муниципалитет") || lower.contains("регистрац") || lower.contains("прописк") { return .municipality }
        if lower.contains("больниц") || lower.contains("врач") || lower.contains("медицин") { return .healthcare }
        if lower.contains("аптек") { return .pharmacy }
        if lower.contains("юрид") || lower.contains("правовой") || lower.contains("адвокат") { return .legalHelp }
        if lower.contains("убежищ") || lower.contains("бежен") || lower.contains("иммиграц") { return .immigrationSupport }
        if lower.contains("студент") || lower.contains("университет") { return .studentHelp }
        if lower.contains("библиотек") { return .library }

        if let status = contextSnapshot?.status {
            return MapCategoryPriorityEngine.primaryCategory(for: status)
        }
        return nil
    }

    private func appendUserMessage(_ text: String, context: AIContext) -> AIMessage {
        let message = conversation.appendUser(text, metadata: messageMetadata(context: context, confidence: nil))
        persistConversation()
        return message
    }

    private func appendLoadingAssistantMessage(replyingTo userMessageID: UUID, context: AIContext, language: AppLanguage) -> AIMessage {
        let message = conversation.appendAssistant(
            localizedThinkingText(for: language),
            replyToMessageID: userMessageID,
            status: .sending,
            metadata: messageMetadata(context: context, confidence: nil)
        )
        persistConversation()
        return message
    }

    private func appendCachedResponse(_ response: AIResponse, language: AppLanguage, replyingTo userMessageID: UUID, context: AIContext) {
        applyAIResponse(response, language: language, replyingTo: userMessageID, context: context)
    }

    private func applyAIResponse(_ response: AIResponse, language: AppLanguage, replyingTo userMessageID: UUID, replacing assistantMessageID: UUID? = nil, context: AIContext? = nil) {
        let personaCheckedResponse = context.map { personaSafeResponse(response, context: $0) } ?? response
        let languageCheckedResponse = AIResponseLanguageGuard.isResponseAcceptable(personaCheckedResponse, for: language)
            ? personaCheckedResponse
            : AIResponse.unverified(language: language)
        let safeResponse = responseWithMandatoryDisclaimer(
            languageCheckedResponse,
            language: language
        )
        responseSources = safeResponse.sources
        suggestedActions = safeResponse.suggestedActions
        safetyNote = safeResponse.safetyNote
        upsertAssistantMessage(
            Self.safeFormattedAnswer(safeResponse.answer, language: language, offline: isOffline),
            response: safeResponse,
            replyingTo: userMessageID,
            replacing: assistantMessageID,
            context: context
        )
    }

    private func personaSafeResponse(_ response: AIResponse, context: AIContext) -> AIResponse {
        var quickActions = response.quickActions.filter { action in
            guard let destinationID = action.destinationID else { return true }
            return AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) != nil
        }

        if quickActions.isEmpty && response.quickActions.contains(where: { $0.destinationID != nil }) {
            quickActions.append(.openScreen(title: localizedSearchTitle(for: context.userLanguage), destinationID: "search"))
        }

        let suggestedActions = quickActions.isEmpty ? response.suggestedActions : quickActions.map(\.title)
        let nextStep = personaSafeNextStep(response.nextStep, context: context)
        let appDestinationID = personaSafeDestinationID(response.appDestinationID, context: context)

        return AIResponse(
            answer: response.answer,
            sources: response.sources,
            safetyNote: response.safetyNote,
            suggestedActions: suggestedActions,
            quickActions: quickActions,
            sections: response.sections,
            nextStep: nextStep,
            appDestinationID: appDestinationID,
            isVerified: response.isVerified,
            cacheKey: response.cacheKey,
            confidence: response.confidence
        )
    }

    private func responseWithMandatoryDisclaimer(_ response: AIResponse, language: AppLanguage) -> AIResponse {
        response
    }

    private func personaSafeNextStep(_ nextStep: AINextStep?, context: AIContext) -> AINextStep? {
        guard let nextStep else { return nil }
        guard let destinationID = nextStep.destinationID else { return nextStep }
        guard AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) == nil else {
            return nextStep
        }
        return AINextStep(
            title: localizedSearchTitle(for: context.userLanguage),
            detail: localizedSearchDetail(for: context.userLanguage),
            destinationID: "search",
            destinationTitle: localizedSearchDestinationTitle(for: context.userLanguage)
        )
    }

    private func personaSafeDestinationID(_ destinationID: String?, context: AIContext) -> String? {
        guard let destinationID else { return nil }
        if AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) != nil {
            return destinationID
        }
        return "search"
    }

    private func localizedSearchTitle(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Найти подходящую информацию"
        case .dutch: return "Zoek relevante informatie"
        case .english: return "Search relevant information"
        }
    }

    private func localizedSearchDetail(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Откройте поиск с фильтром вашего профиля, чтобы избежать нерелевантных шагов."
        case .dutch: return "Open zoeken met je profielfilter om irrelevante stappen te vermijden."
        case .english: return "Open search with your profile filter to avoid irrelevant next steps."
        }
    }

    private func localizedSearchDestinationTitle(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private func resourceLink(from source: OfficialSource) -> ResourceLinkItem? {
        guard let url = source.url else { return nil }
        return ResourceLinkItem(
            category: "Official sources",
            title: source.title,
            description: source.institution ?? source.title,
            whoItHelps: "Newcomers verifying official information",
            sourceLabel: source.institution ?? source.title,
            url: url,
            isOfficial: true,
            reminder: nil
        )
    }

    private static func buildCacheKey(message: String, language: AppLanguage, context: AIContext) -> String {
        let normalizedMessage = message
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let contextFingerprint = [
            context.activePersonaTag?.rawValue ?? "",
            context.secondaryPersonaTags.map(\.rawValue).sorted().joined(separator: ","),
            context.personaSearchScope.rawValue,
            context.screen.rawValue,
            context.category ?? "",
            context.topicTitle ?? "",
            context.topicSummary ?? "",
            context.selectedCity ?? "",
            context.selectedProvince ?? "",
            context.currentRouteID ?? "",
            context.recentRouteIDs.joined(separator: ","),
            context.journeyProgress ?? "",
            context.completedChecklistItemIDs.joined(separator: ","),
            context.completedGuideIDs.joined(separator: ","),
            context.savedItemIDs.joined(separator: ","),
            context.savedItemKinds.joined(separator: ","),
            context.lastSearches.joined(separator: ",")
        ].joined(separator: "|")

        return "\(language.rawValue)|\(normalizedMessage)|\(contextFingerprint)"
    }

    private func cachedResponse(for key: String) -> AIResponse? {
        guard let cached = answerCache[key] else { return nil }
        guard Date().timeIntervalSince(cached.updatedAt) <= cacheTtl else {
            answerCache.removeValue(forKey: key)
            persistAnswerCache()
            return nil
        }
        guard cached.responseCount >= cacheFrequencyThreshold else { return nil }
        return cached.response
    }

    private func cacheResponse(_ response: AIResponse, for key: String) {
        let cached = answerCache[key]
        let frequency = min(20, (cached?.responseCount ?? 0) + 1)
        answerCache[key] = CachedAIResponse(response: response, responseCount: frequency, updatedAt: Date())
        if answerCache.count > 120 {
            // LRU: keep the 120 most recently updated entries.
            let evicted = answerCache
                .sorted { $0.value.updatedAt > $1.value.updatedAt }
                .prefix(120)
                .reduce(into: [String: CachedAIResponse]()) { $0[$1.key] = $1.value }
            answerCache = evicted
        }
        persistAnswerCache()
    }

    private func upsertAssistantMessage(_ text: String, response: AIResponse? = nil, replyingTo userMessageID: UUID, replacing assistantMessageID: UUID?, context: AIContext?) {
        if let assistantMessageID {
            replaceAssistantMessage(assistantMessageID, text: text, response: response, status: .done, context: context)
            return
        }

        let removedReplies = conversation.removeAssistantReplies(to: userMessageID)
        for removedReply in removedReplies {
            structuredResponses.removeValue(forKey: removedReply.id)
        }

        let message = conversation.appendAssistant(
            text,
            replyToMessageID: userMessageID,
            status: .done,
            source: response?.sources.first,
            metadata: context.map { messageMetadata(context: $0, confidence: response?.confidence) }
        )
        if let response {
            structuredResponses[message.id] = response
            persistStructuredResponses()
        }
        persistConversation()
    }

    private func replaceAssistantMessage(_ messageID: UUID, text: String, response: AIResponse?, status: AIMessage.Status?, context: AIContext?) {
        if let response {
            structuredResponses[messageID] = response
            persistStructuredResponses()
        } else {
            structuredResponses.removeValue(forKey: messageID)
            persistStructuredResponses()
        }

        _ = conversation.replaceMessage(
            id: messageID,
            text: text,
            status: status,
            source: response?.sources.first,
            metadata: context.map { messageMetadata(context: $0, confidence: response?.confidence) }
        )
        persistConversation()
    }

    private func messageMetadata(context: AIContext, confidence: AIResponseConfidence?) -> AIMessage.Metadata {
        AIMessage.Metadata(
            cityId: context.selectedCity,
            audience: context.activePersonaTag,
            categoryId: context.category,
            confidence: confidence
        )
    }

    private func safetyWarningResponse(_ warning: String, language: AppLanguage) -> AIResponse {
        AIResponse(
            answer: warning,
            sources: [],
            safetyNote: nil,
            suggestedActions: [],
            sections: [
                AIResponseSection(title: safetyTitle(for: language), body: warning, symbol: "shield.lefthalf.filled")
            ],
            isVerified: false,
            confidence: .low
        )
    }

    private func updateContextLabels(_ context: AIContext) {
        activeContextTitle = [context.category, context.topicTitle]
            .compactMap { value in
                let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed?.isEmpty == false ? trimmed : nil
            }
            .joined(separator: " · ")
        let summary = context.topicSummary?.trimmingCharacters(in: .whitespacesAndNewlines)
        activeContextSummary = summary?.isEmpty == false ? summary : nil
    }

    private func fallbackContext(language: AppLanguage) -> AIContext {
        activeContext ?? AIContext.empty(language: language)
    }

    private func contextualPrompts(for context: AIContext) -> [String] {
        switch context.screen {
        case .rulesAndFines, .fineDetail:
            return prompts(
                english: ["Explain this rule simply", "What happens if I ignore this?", "Where can I verify this officially?"],
                dutch: ["Leg deze regel eenvoudig uit", "Wat gebeurt er als ik dit negeer?", "Waar kan ik dit officieel controleren?"],
                russian: ["Объясните это правило просто", "Что будет, если это игнорировать?", "Где это проверить официально?"],
                language: context.userLanguage
            )
        case .documents:
            return personaQuickPrompts(for: context.activePersonaTag ?? .universal, language: context.userLanguage)
        case .transport:
            if context.activePersonaTag == .student {
                return prompts(
                    english: ["Explain student transport discounts", "How do I verify DUO travel product rules?", "How do I plan a route to campus?"],
                    dutch: ["Leg studentenreisproduct uit", "Hoe controleer ik DUO-vervoerregels?", "Hoe plan ik een route naar campus?"],
                    russian: ["Объясните студенческие скидки на транспорт", "Как проверить правила DUO travel product?", "Как спланировать маршрут до кампуса?"],
                    language: context.userLanguage
                )
            }
            return prompts(
                english: ["Explain OV-chipkaart", "What bike rules matter most?", "Where can I verify transport rules?"],
                dutch: ["Leg OV-chipkaart uit", "Welke fietsregels zijn het belangrijkst?", "Waar controleer ik vervoersregels?"],
                russian: ["Объясните OV-chipkaart", "Какие правила велосипеда важнее всего?", "Где проверить правила транспорта?"],
                language: context.userLanguage
            )
        case .province, .city:
            return prompts(
                english: ["What should a newcomer know here?", "Show useful official links", "What services are important?"],
                dutch: ["Wat moet een nieuwkomer hier weten?", "Toon nuttige officiële links", "Welke diensten zijn belangrijk?"],
                russian: ["Что новичку важно знать здесь?", "Покажите полезные официальные ссылки", "Какие службы важны?"],
                language: context.userLanguage
            )
        case .emergency:
            return prompts(
                english: ["When should I call 112?", "What number is non-emergency police?", "Explain emergency contacts"],
                dutch: ["Wanneer bel ik 112?", "Wat is het nummer voor geen spoed politie?", "Leg noodcontacten uit"],
                russian: ["Когда звонить 112?", "Какой номер полиции не для экстренных случаев?", "Объясните экстренные контакты"],
                language: context.userLanguage
            )
        default:
            return fallbackQuickPrompts(for: context.userLanguage)
        }
    }

    private func prompts(english: [String], dutch: [String], russian: [String], language: AppLanguage) -> [String] {
        switch language {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }

    private func persistConversation() {
        guard let data = try? JSONEncoder().encode(conversation) else { return }
        UserDefaults.standard.set(data, forKey: conversationStorageKey)
    }

    private func persistActiveWorkflow() {
        guard let activeWorkflow else {
            UserDefaults.standard.removeObject(forKey: workflowStorageKey)
            return
        }
        guard let data = try? JSONEncoder().encode(activeWorkflow) else { return }
        UserDefaults.standard.set(data, forKey: workflowStorageKey)
    }

    private func persistAnswerCache() {
        guard let data = try? JSONEncoder().encode(answerCache) else { return }
        UserDefaults.standard.set(data, forKey: answerCacheStorageKey)
    }

    private func persistStructuredResponses() {
        let stringKeyed = structuredResponses.reduce(into: [String: AIResponse]()) {
            $0[$1.key.uuidString] = $1.value
        }
        guard let data = try? JSONEncoder().encode(stringKeyed) else { return }
        UserDefaults.standard.set(data, forKey: structuredResponsesStorageKey)
    }

    private static func loadStructuredResponses(storageKey: String) -> [UUID: AIResponse] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: AIResponse].self, from: data)
        else { return [:] }
        return decoded.reduce(into: [UUID: AIResponse]()) { result, pair in
            if let uuid = UUID(uuidString: pair.key) { result[uuid] = pair.value }
        }
    }

    private static func loadConversation(storageKey: String) -> AIConversation {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(AIConversation.self, from: data)
        else {
            return AIConversation()
        }
        return decoded
    }

    private static func loadActiveWorkflow(storageKey: String) -> AIWorkflow? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(AIWorkflow.self, from: data)
        else {
            return nil
        }
        return decoded
    }

    private static func loadAnswerCache(storageKey: String) -> [String: CachedAIResponse] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: CachedAIResponse].self, from: data)
        else {
            return [:]
        }

        let now = Date()
        return decoded.filter { _, cached in
            now.timeIntervalSince(cached.updatedAt) <= (60 * 60 * 24 * 30)
        }
    }

    private func startConnectivityMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isOffline = path.status != .satisfied
            Task { @MainActor [weak self] in
                self?.isOffline = isOffline
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func localizedEmptyInputError(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Введите вопрос, чтобы ассистент мог помочь."
        case .dutch: return "Typ een vraag zodat de assistent kan helpen."
        case .english: return "Enter a question so the assistant can help."
        }
    }

    private func localizedNoResponseError(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Не удалось получить ответ. Попробуйте снова или проверьте официальный источник."
        case .dutch: return "Geen antwoord ontvangen. Probeer opnieuw of controleer de officiële bron."
        case .english: return "No response received. Please try again or check the official source."
        }
    }

    private func localizedCancelledRequestText(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Запрос остановлен. Можно задать вопрос ещё раз."
        case .dutch: return "Verzoek gestopt. Je kunt opnieuw een vraag stellen."
        case .english: return "Request stopped. You can ask again."
        }
    }

    private func localizedThinkingText(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Готовлю ответ..."
        case .dutch: return "Antwoord voorbereiden..."
        case .english: return "Preparing an answer..."
        }
    }

    private func safetyTitle(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Безопасность"
        case .dutch: return "Veiligheid"
        case .english: return "Safety"
        }
    }

    private static func safeFormattedAnswer(_ answer: String, language: AppLanguage, offline: Bool) -> String {
        if answer == AIResponse.unverifiedAnswer {
            return AIResponse.unverified(language: language).answer
        }

        let sanitized = stripRawURLs(from: answer)

        var lines = sanitized
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if offline {
            lines.insert(offlinePrefix(for: language), at: 0)
        }

        let joined = lines.joined(separator: "\n\n")
        if joined.localizedCaseInsensitiveContains("official")
            || joined.localizedCaseInsensitiveContains("offici")
            || joined.localizedCaseInsensitiveContains("официаль") {
            return joined
        }
        return "\(joined)\n\n\(AISafetyRules.sourceReminder(languageCode: language.rawValue))"
    }

    private static func stripRawURLs(from text: String) -> String {
        text
            .replacingOccurrences(of: #"https?://\S+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"www\.\S+"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func offlinePrefix(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Офлайн-режим: показываю локальную справочную подсказку."
        case .dutch: return "Offline modus: lokale algemene informatie wordt getoond."
        case .english: return "Offline mode: showing local general guidance."
        }
    }
}
