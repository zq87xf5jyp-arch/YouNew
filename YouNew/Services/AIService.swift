import Foundation

struct AIService: AIServiceProtocol {
    private let client: AIClient
    private let fallback: MockAIService
    private let usageLimiter: AIUsageLimiter

    init(
        client: AIClient = AIClient(),
        fallback: MockAIService = MockAIService(),
        usageLimiter: AIUsageLimiter = AIUsageLimiter()
    ) {
        self.client = client
        self.fallback = fallback
        self.usageLimiter = usageLimiter
    }

    func sendMessage(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse {
        switch AISafetyFilter.evaluate(userMessage, language: context.userLanguage) {
        case .allowed:
            break
        case .blocked(let message):
            return safetyResponse(message, context: context)
        case .privacyWarning(let message):
            return safetyResponse(message, context: context)
        }

        guard usageLimiter.canSend() else {
            return AIResponse.unverified(language: context.userLanguage)
        }
        usageLimiter.recordSend()

        do {
            let response = try await client.send(
                userMessage: userMessage,
                context: context,
                conversation: conversation
            )

            guard response.isVerified else { return AIResponse.unverified(language: context.userLanguage) }

            return AISafetyFilter.enforceResponseSafety(
                personaSafeResponse(response, context: context),
                context: context
            )
        } catch AIClientError.backendNotConfigured {
            return AIResponse.unverified(language: context.userLanguage)
        } catch {
            return AIResponse.unverified(language: context.userLanguage)
        }
    }

    func sendMessage(_ message: String, language: AppLanguage) async -> String {
        await fallback.sendMessage(message, language: language)
    }

    func summarizeLetter(_ text: String, language: AppLanguage) async -> String {
        await fallback.summarizeLetter(text, language: language)
    }

    func translateText(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) async -> String {
        await fallback.translateText(text, from: sourceLanguage, to: targetLanguage)
    }

    func explainInstitution(_ name: String, language: AppLanguage) async -> String {
        await fallback.explainInstitution(name, language: language)
    }

    func suggestResources(for topic: String, language: AppLanguage) async -> [ResourceLinkItem] {
        await fallback.suggestResources(for: topic, language: language)
    }

    private func personaSafeResponse(_ response: AIResponse, context: AIContext) -> AIResponse {
        var quickActions = response.quickActions.filter { action in
            guard let destinationID = action.destinationID else { return true }
            return AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) != nil
        }

        if quickActions.isEmpty && response.quickActions.contains(where: { $0.destinationID != nil }) {
            quickActions.append(.openScreen(title: searchTitle(for: context.userLanguage), destinationID: "search"))
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
            cacheKey: response.cacheKey
        )
    }

    private func personaSafeNextStep(_ nextStep: AINextStep?, context: AIContext) -> AINextStep? {
        guard let nextStep else { return nil }
        guard let destinationID = nextStep.destinationID else { return nextStep }
        guard AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) == nil else {
            return nextStep
        }

        return AINextStep(
            title: searchTitle(for: context.userLanguage),
            detail: searchDetail(for: context.userLanguage),
            destinationID: "search",
            destinationTitle: searchDestinationTitle(for: context.userLanguage)
        )
    }

    private func personaSafeDestinationID(_ destinationID: String?, context: AIContext) -> String? {
        guard let destinationID else { return nil }
        if AppNavigationResolver.destination(for: destinationID, visibleFor: context.activePersonaTag) != nil {
            return destinationID
        }
        return "search"
    }

    private func searchTitle(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Найти подходящую информацию"
        case .dutch: return "Zoek relevante informatie"
        case .english: return "Search relevant information"
        }
    }

    private func searchDetail(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Откройте поиск с фильтром вашего профиля, чтобы избежать нерелевантных шагов."
        case .dutch: return "Open zoeken met je profielfilter om irrelevante stappen te vermijden."
        case .english: return "Open search with your profile filter to avoid irrelevant next steps."
        }
    }

    private func searchDestinationTitle(for language: AppLanguage) -> String {
        switch language {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private func safetyResponse(_ message: String, context: AIContext) -> AIResponse {
        AIResponse(
            answer: message,
            sources: [],
            safetyNote: context.disclaimer,
            suggestedActions: [],
            sections: [
                AIResponseSection(
                    title: "Safety",
                    body: message,
                    symbol: "shield.lefthalf.filled"
                )
            ],
            nextStep: AINextStep(
                title: "Open official sources",
                detail: "Use verified sources before acting.",
                destinationID: "officialSources",
                destinationTitle: "Official sources"
            ),
            appDestinationID: "officialSources",
            isVerified: false
        )
    }
}
