import Foundation

protocol AIServiceProtocol {
    func sendMessage(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse

    func sendMessage(_ message: String, language: AppLanguage) async -> String
    func summarizeLetter(_ text: String, language: AppLanguage) async -> String
    func translateText(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) async -> String
    func explainInstitution(_ name: String, language: AppLanguage) async -> String
    func suggestResources(for topic: String, language: AppLanguage) async -> [ResourceLinkItem]
}

extension AIServiceProtocol {
    func sendMessage(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse {
        let answer = await sendMessage(userMessage, language: context.userLanguage)
        guard !context.officialSources.isEmpty else {
            return AIResponse.unverified(language: context.userLanguage)
        }
        let topicSources = Self.topicMatchedSources(for: userMessage, in: context)
        guard !topicSources.isEmpty else {
            return AIResponse.unverified(language: context.userLanguage)
        }
        return AISafetyFilter.enforceResponseSafety(
            AIResponse(
                answer: answer,
                sources: topicSources,
                safetyNote: AISafetyRules.sourceReminder(languageCode: context.userLanguage.rawValue),
                suggestedActions: [],
                sections: [
                    AIResponseSection(title: "Answer", body: answer, symbol: "checkmark.circle.fill")
                ],
                isVerified: true
            ),
            context: context
        )
    }

    private static func topicMatchedSources(for message: String, in context: AIContext) -> [OfficialSource] {
        let normalizedMessage = message
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
        let matches = context.officialSources.filter { source in
            let sourceText = [source.title, source.institution ?? "", source.url?.absoluteString ?? ""]
                .joined(separator: " ")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
                .lowercased()
            return normalizedMessage
                .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
                .contains { token in
                    token.count >= 3 && sourceText.contains(token)
                }
        }
        return Array(matches.prefix(3))
    }
}
