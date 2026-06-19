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
        return AISafetyFilter.enforceResponseSafety(
            AIResponse(
                answer: answer,
                sources: context.officialSources,
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
}
