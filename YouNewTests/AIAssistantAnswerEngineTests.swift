import Testing
import Foundation
@testable import YouNew

@MainActor
struct AIAssistantAnswerEngineTests {
    @Test func bigAsksClarificationWithoutGenericTemplate() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "big",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("what do you mean"))
        #expect(!response.answer.localizedCaseInsensitiveContains("deadlines, payments"))
        #expect(response.sources.isEmpty)
    }

    @Test func bsnInTouristModeExplainsItIsUsuallyNotNeeded() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Bsn",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        #expect(response.answer.contains("Most short-stay tourists do not need a BSN"))
        #expect(!response.answer.localizedCaseInsensitiveContains("must have a BSN"))
        #expect(!response.answer.localizedCaseInsensitiveContains("type your BSN"))
    }

    @Test func directAssistantResponsesUseContextualActionStructure() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Bsn",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        let titles = response.sections.map(\.title)
        #expect(titles.contains("Answer"))
        #expect(titles.contains("What This Means"))
        #expect(titles.contains("Next step"))
        #expect(titles.contains("Useful Actions"))
        #expect(titles.contains("Related Topics"))
        #expect(titles.contains("Official Source"))
        #expect(response.nextStep?.destinationID == "documents")
        #expect(response.quickActions.contains { $0.kind == .openScreen && $0.destinationID == "documents" })
    }

    @Test func lostPassportInAmsterdamTouristModeUsesLostDocumentsFlow() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "lost passport",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("lose your passport"))
        #expect(response.answer.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(response.nextStep != nil)
        #expect(response.sources.allSatisfy { $0.url != nil })
    }

    @Test func transportUsesTouristTransportContent() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "transport",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("tourist"))
        #expect(response.answer.localizedCaseInsensitiveContains("9292"))
        #expect(response.appDestinationID == "transport")
    }

    @Test func selectedAmsterdamDoesNotReturnLeidenMunicipalityContent() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "places",
            language: .english,
            context: Self.touristContext(city: "Amsterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Leiden"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Rotterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Den Haag"))
    }

    @Test func stayQuestionUsesSelectedCityBookingLinkWithoutInventingAvailability() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Where can I stay?",
            language: .english,
            context: Self.dashboardTouristContext(city: "Rotterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("Rotterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(response.quickActions.contains { $0.kind == .openSource && $0.url?.host?.localizedCaseInsensitiveContains("booking.com") == true })
        #expect(!response.answer.localizedCaseInsensitiveContains("available now"))
        #expect(!response.answer.contains("€"))
    }

    @Test func bookingQuestionUsesSelectedCityBookingCard() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Booking",
            language: .english,
            context: Self.dashboardTouristContext(city: "Rotterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("Hotels in Rotterdam"))
        #expect(response.sources.contains { $0.url?.absoluteString.localizedCaseInsensitiveContains("rotterdam") == true })
        #expect(!response.answer.localizedCaseInsensitiveContains("Amsterdam"))
    }

    @Test func restaurantQuestionUsesSelectedCityFoodGuideWithoutFakeRatings() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Restaurants?",
            language: .english,
            context: Self.dashboardTouristContext(city: "Rotterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("Food & drinks guide"))
        #expect(response.answer.localizedCaseInsensitiveContains("Rotterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("top rated"))
        #expect(response.sources.contains { $0.url?.absoluteString.localizedCaseInsensitiveContains("rotterdam") == true })
    }

    @Test func cafesQuestionUsesSelectedCityCafeGuide() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "Cafes?",
            language: .english,
            context: Self.dashboardTouristContext(city: "Rotterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("cafe guide"))
        #expect(response.answer.localizedCaseInsensitiveContains("Rotterdam"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(response.sources.contains { $0.url?.absoluteString.localizedCaseInsensitiveContains("rotterdam") == true })
    }

    @Test func visitQuestionUsesSelectedCityPlacesOnly() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "What can I visit?",
            language: .english,
            context: Self.dashboardTouristContext(city: "Rotterdam")
        )!

        #expect(response.answer.localizedCaseInsensitiveContains("Rotterdam"))
        #expect(response.answer.localizedCaseInsensitiveContains("Markthal"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Rijksmuseum"))
        #expect(!response.answer.localizedCaseInsensitiveContains("Amsterdam"))
    }

    @Test func officialSourceMissingKeepsSourcesHidden() {
        let response = AssistantAnswerEngine.getAssistantAnswer(
            userText: "bike rules",
            language: .english,
            context: Self.touristContext(city: "Amsterdam", sources: [])
        )!

        #expect(response.sources.isEmpty)
        #expect(!response.quickActions.contains { action in
            action.kind == AIResponseAction.Kind.openSource
        })
    }

    @Test func emptyInputIsNotSent() async {
        let viewModel = AIViewModel(service: StaticAIService())
        viewModel.clearConversation()
        viewModel.updateContext(Self.touristContext(city: "Amsterdam"))
        viewModel.input = "   "

        await viewModel.sendCurrentMessage()

        #expect(viewModel.conversation.messages.isEmpty)
    }

    @Test func twoDifferentMessagesProduceDifferentAssistantResponses() async throws {
        let viewModel = AIViewModel(service: StaticAIService())
        viewModel.clearConversation()
        viewModel.updateContext(Self.touristContext(city: "Amsterdam"))

        viewModel.input = "Bsn"
        await viewModel.sendCurrentMessage()
        viewModel.input = "transport"
        await viewModel.sendCurrentMessage()

        let assistantMessages = viewModel.conversation.messages.filter { $0.role == .assistant }
        #expect(assistantMessages.count == 2)
        #expect(assistantMessages[0].text != assistantMessages[1].text)
        #expect(assistantMessages.allSatisfy { $0.status == .done })
    }

    @Test func longUserMessageIsStoredFullyForWrapping() async {
        let viewModel = AIViewModel(service: StaticAIService())
        viewModel.clearConversation()
        viewModel.updateContext(Self.touristContext(city: "Amsterdam"))
        let text = String(repeating: "Can you explain transport rules for tourists in Amsterdam? ", count: 20)
        viewModel.input = text

        await viewModel.sendCurrentMessage()

        let userMessage = viewModel.conversation.messages.first { $0.role == .user }
        #expect(userMessage?.text == text.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    @Test func loadingMessageIsReplacedByFinalAssistantMessage() async {
        let viewModel = AIViewModel(service: StaticAIService())
        viewModel.clearConversation()
        viewModel.updateContext(Self.touristContext(city: "Amsterdam"))
        viewModel.input = "Bsn"

        await viewModel.sendCurrentMessage()

        let messages = viewModel.conversation.messages
        #expect(messages.count == 2)
        #expect(messages.last?.role == .assistant)
        #expect(messages.last?.status == .done)
        #expect(messages.last?.text.localizedCaseInsensitiveContains("BSN") == true)
    }

    @Test func quickPromptAdvancesBSNWorkflowInWorkerContext() async {
        let viewModel = AIViewModel(service: StaticAIService())
        viewModel.clearConversation()
        viewModel.updateContext(Self.workerContext(city: "Leiden"))

        viewModel.input = "How do I get BSN?"
        await viewModel.sendCurrentMessage()
        await viewModel.useQuickPrompt("yes address")

        let assistantResponses = viewModel.conversation.messages
            .filter { $0.role == .assistant && $0.status == .done }
            .compactMap { viewModel.structuredResponse(for: $0.id) }

        #expect(assistantResponses.count == 2)
        #expect(assistantResponses.last?.quickActions.contains { $0.kind == .askFollowUp && $0.query == "yes digid" } == true)
        #expect(assistantResponses.last?.quickActions.contains { $0.kind == .askFollowUp && $0.query == "no digid" } == true)
    }

    private static func touristContext(
        city: String,
        sources: [OfficialSource] = [
            OfficialSource(title: "Netherlands Worldwide", url: URL(string: "https://www.netherlandsworldwide.nl"), institution: "Ministry of Foreign Affairs"),
            OfficialSource(title: "9292", url: URL(string: "https://9292.nl/en"), institution: "9292")
        ]
    ) -> AIContext {
        AIContext(
            screen: .assistant,
            category: "Tourist essentials",
            topicTitle: "Tourist assistant",
            topicSummary: "Tourist help for emergency, transport, rules, places, healthcare, and lost documents.",
            officialSources: sources,
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "Tourist",
            selectedCity: city,
            selectedProvince: "Noord-Holland",
            savedItemTitles: [],
            currentRouteID: "assistant",
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: .english),
            activePersonaTag: .tourist,
            secondaryPersonaTags: [.universal],
            personaSearchScope: .currentAndUniversal
        )
    }

    private static func workerContext(city: String) -> AIContext {
        AIContext(
            screen: .assistant,
            category: "Worker essentials",
            topicTitle: "Worker assistant",
            topicSummary: "Registration, BSN, DigiD, municipality, documents, work, and healthcare.",
            officialSources: [
                OfficialSource(title: "Government.nl", url: URL(string: "https://www.government.nl"), institution: "Government.nl")
            ],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "Worker",
            selectedCity: city,
            selectedProvince: "Zuid-Holland",
            savedItemTitles: [],
            currentRouteID: "assistant",
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: .english),
            activePersonaTag: .worker,
            secondaryPersonaTags: [.universal],
            personaSearchScope: .currentAndUniversal
        )
    }

    private static func dashboardTouristContext(city: String) -> AIContext {
        let dashboardCity = CityDashboardContentData.city(for: city)
        return AIContext(
            screen: .assistant,
            category: "Tourist essentials",
            topicTitle: "Tourist assistant",
            topicSummary: "Tourist help for \(dashboardCity.name).",
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "Tourist",
            selectedCity: dashboardCity.name,
            selectedProvince: dashboardCity.province,
            selectedCityData: dashboardCity,
            selectedAudience: .tourist,
            places: DashboardPlacesData.visiblePlaces(cityId: dashboardCity.name, audience: .tourist, limit: 8),
            foodGuide: CityDashboardContentData.foodGuideItems(for: dashboardCity, audience: .tourist, limit: 8),
            travelLinks: CityDashboardContentData.travelLinks(for: dashboardCity).filter { $0.audience.contains(.tourist) },
            calendarEvents: DashboardCalendarData.upcomingEvents(cityId: dashboardCity.name, audience: .tourist, limit: 5),
            currentScreen: AIContextScreen.assistant.rawValue,
            savedItemTitles: [],
            currentRouteID: "assistant",
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: .english),
            activePersonaTag: .tourist,
            secondaryPersonaTags: [.universal],
            personaSearchScope: .currentAndUniversal
        )
    }
}

private struct StaticAIService: AIServiceProtocol {
    func sendMessage(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse {
        AIResponse.unverified(language: context.userLanguage)
    }

    func sendMessage(_ message: String, language: AppLanguage) async -> String {
        "Static response"
    }

    func summarizeLetter(_ text: String, language: AppLanguage) async -> String {
        "Summary"
    }

    func translateText(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) async -> String {
        text
    }

    func explainInstitution(_ name: String, language: AppLanguage) async -> String {
        name
    }

    func suggestResources(for topic: String, language: AppLanguage) async -> [ResourceLinkItem] {
        []
    }
}
