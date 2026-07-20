import Foundation
import Testing
@testable import YouNew

@MainActor
struct BuildWeekNewcomerDemoTests {
    @Test func boundedScenarioUsesExistingKnowledgeIndexRecordsAndRoutes() {
        let index = KnowledgeIndex.shared

        #expect(BuildWeekNewcomerDemo.steps.count == 4)
        #expect(BuildWeekNewcomerDemo.steps.map(\.id) == [
            "bsn", "digid", "health-insurance", "huisarts"
        ])
        #expect(BuildWeekNewcomerDemo.knowledgeRecordIDs.allSatisfy {
            index.itemsByID[$0] != nil
        })
        #expect(BuildWeekNewcomerDemo.steps.allSatisfy {
            $0.sourceURL.scheme == "https"
                && AppNavigationResolver.destination(for: $0.appDestination) != nil
        })
    }

    @Test func parserAcceptsOnlyBoundedLiveGPT56Response() throws {
        let response = try AIResponseParser.parse(
            Self.validPayload(),
            language: .english
        )

        #expect(response.isVerified)
        #expect(response.isLiveOpenAI)
        #expect(response.origin == .liveOpenAI)
        #expect(response.model == "gpt-5.6")
        #expect(response.requestID == "req_buildweek_12345678")
        #expect(response.sections.count == 4)
        #expect(response.sources.map(\.url) == BuildWeekNewcomerDemo.steps.map(\.sourceURL))
        #expect(response.quickActions.filter { $0.kind == .openGuide }.count == 4)
    }

    @Test func parserRejectsNonGPT56Metadata() throws {
        #expect(BuildWeekNewcomerDemo.isAllowedModel("gpt-5.6"))
        #expect(BuildWeekNewcomerDemo.isAllowedModel("gpt-5.6-sol"))

        for rejectedModel in [
            "gpt-4.1-mini",
            "gpt-5.6-unlisted",
            "gpt-5.6-terra",
            "gpt-5.6-luna"
        ] {
            var payload = Self.validJSONObject()
            payload["model"] = rejectedModel
            let data = try JSONSerialization.data(withJSONObject: payload)
            let response = try AIResponseParser.parse(data, language: .english)

            #expect(!response.isLiveOpenAI)
            #expect(response.origin == .unverified)
        }
    }

    @Test func parserRejectsSourceOrRouteOutsideServerContract() throws {
        var payload = Self.validJSONObject()
        var steps = try #require(payload["steps"] as? [[String: Any]])
        steps[0]["sourceURL"] = "https://example.com/not-an-official-source"
        steps[0]["appDestination"] = "search"
        payload["steps"] = steps

        let data = try JSONSerialization.data(withJSONObject: payload)
        let response = try AIResponseParser.parse(data, language: .english)

        #expect(!response.isLiveOpenAI)
        #expect(response.origin == .unverified)
    }

    @Test func unavailableBackendUsesExplicitDeterministicFallback() async throws {
        let service = AIService(client: AIClient(endpoint: nil))
        let response = try await service.sendMessage(
            userMessage: BuildWeekNewcomerDemo.prompt(for: .english),
            context: AIContext.empty(language: .english),
            conversation: []
        )

        #expect(response.origin == .localGuide)
        #expect(!response.isLiveOpenAI)
        #expect(response.model == nil)
        #expect(response.requestID == nil)
        #expect(response.sections.count == 4)
        #expect(response.answer.localizedCaseInsensitiveContains("planning guide"))
    }

    @Test func legacyPersistedResponseCannotBecomeLiveByDecoding() throws {
        let data = Data(
            """
            {
              "answer": "Previously stored local guidance",
              "isVerified": true,
              "confidence": "high"
            }
            """.utf8
        )
        let response = try JSONDecoder().decode(AIResponse.self, from: data)

        #expect(response.origin == .localGuide)
        #expect(!response.isLiveOpenAI)
    }

    @Test func endpointValidationRequiresHTTPSOutsideExplicitLoopbackTests() {
        #expect(AIClient.validatedEndpoint("https://api.example.test/v1/newcomer-demo") != nil)
        #expect(AIClient.validatedEndpoint("https://api.example.test/v1/newcomer-guide") == nil)
        #expect(AIClient.validatedEndpoint("http://api.example.test/v1/newcomer-demo") == nil)
        #expect(AIClient.validatedEndpoint("http://127.0.0.1:8787/v1/newcomer-demo") == nil)
        #expect(
            AIClient.validatedEndpoint(
                "http://127.0.0.1:8787/v1/newcomer-demo",
                allowInsecureLoopback: true
            ) != nil
        )
        #expect(AIClient.validatedEndpoint("https://user:password@example.test/v1/newcomer-demo") == nil)
        #expect(AIClient.validatedEndpoint("https://api.example.test/v1/newcomer-demo?debug=true") == nil)
    }

    private static func validPayload() throws -> Data {
        try JSONSerialization.data(withJSONObject: validJSONObject())
    }

    private static func validJSONObject() -> [String: Any] {
        let titles = [
            "1. Registration-dependent — BSN",
            "2. After prerequisites — DigiD",
            "3. Situation-dependent — health insurance",
            "4. Recommended — huisarts"
        ]
        let reasons = [
            "Municipality registration and the BSN route depend on registration status.",
            "A BSN and registered address are normally prerequisites for this route.",
            "The obligation depends on residence, work, study, and other status facts.",
            "A huisarts is normally the first contact for non-emergency care."
        ]
        let actions = [
            "Ask your gemeente which registration route and documents apply.",
            "Use the official DigiD application route after checking the prerequisites.",
            "Verify whether Dutch health insurance applies before choosing a policy.",
            "Check local huisarts availability and registration instructions."
        ]
        let steps = BuildWeekNewcomerDemo.steps.enumerated().map { index, contract in
            [
                "title": titles[index],
                "reason": reasons[index],
                "action": actions[index],
                "sourceTitle": contract.sourceTitle,
                "sourceURL": contract.sourceURL.absoluteString,
                "appDestination": contract.appDestination
            ]
        }
        return [
            "summary": "Check registration first, then DigiD, situation-dependent insurance, and recommended huisarts registration.",
            "steps": steps,
            "warnings": [
                "Requirements can depend on your gemeente and residence, work, or study status."
            ],
            "model": "gpt-5.6",
            "requestId": "req_buildweek_12345678"
        ]
    }
}
