import Foundation
import Testing
@testable import YouNew

@MainActor
struct BuildWeekNewcomerDemoTests {
    @Test func boundedScenarioUsesExistingKnowledgeIndexRecordsAndRoutes() {
        let index = KnowledgeIndex(items: KnowledgeIndexBuilder.buildItems(now: Self.auditDate))

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

    @Test func parserRejectsUnapprovedReleaseEvenWhenLiveShapeIsComplete() throws {
        let response = try AIResponseParser.parse(
            Self.validPayload(),
            language: .english
        )

        #expect(!response.isLiveOpenAI)
        #expect(response.origin == .unverified)
        #expect(response.model == nil)
        #expect(response.requestID == nil)
        #expect(BuildWeekNewcomerDemo.approvedLiveContentReleases.isEmpty)
    }

    @Test func governanceContractRequiresReleaseDateLocationUncertaintyAndEscalation() {
        let valid = AIResponseGovernance(
            contentReleaseID: "younew-newcomer-demo-v1",
            verifiedDate: "2026-07-14",
            locationAssumption: "National guidance; verify municipality-specific steps.",
            uncertainty: "Duties depend on personal status.",
            escalation: "Use 112 for immediate danger and official sources otherwise."
        )
        #expect(valid.isMachineValid)

        let invalidDate = AIResponseGovernance(
            contentReleaseID: valid.contentReleaseID,
            verifiedDate: "2026-02-31",
            locationAssumption: valid.locationAssumption,
            uncertainty: valid.uncertainty,
            escalation: valid.escalation
        )
        #expect(!invalidDate.isMachineValid)

        let futureDate = AIResponseGovernance(
            contentReleaseID: valid.contentReleaseID,
            verifiedDate: "2999-01-01",
            locationAssumption: valid.locationAssumption,
            uncertainty: valid.uncertainty,
            escalation: valid.escalation
        )
        #expect(!futureDate.isMachineValid)
    }

    @Test func parserRejectsLiveResponseWithoutCompleteGovernanceContract() throws {
        for key in [
            "contentReleaseId",
            "verifiedDate",
            "locationAssumption",
            "uncertainty",
            "escalation",
            "decisionTrace"
        ] {
            var payload = Self.validJSONObject()
            payload.removeValue(forKey: key)
            let data = try JSONSerialization.data(withJSONObject: payload)
            do {
                let response = try AIResponseParser.parse(data, language: .english)
                #expect(!response.isLiveOpenAI, "Missing \(key) must never produce a live response")
            } catch { }
        }
    }

    @Test func parserRejectsMismatchedSourceVerificationDate() throws {
        var payload = Self.validJSONObject()
        var steps = try #require(payload["steps"] as? [[String: Any]])
        steps[0]["sourceVerifiedDate"] = "2026-07-13"
        payload["steps"] = steps

        let data = try JSONSerialization.data(withJSONObject: payload)
        let response = try AIResponseParser.parse(data, language: .english)

        #expect(!response.isLiveOpenAI)
        #expect(response.origin == .unverified)
    }

    @Test func parserRejectsDuplicateDecisionTraceRecordsWithoutTrapping() throws {
        var payload = Self.validJSONObject()
        var trace = try #require(payload["decisionTrace"] as? [String: Any])
        var citations = try #require(trace["sourceCitations"] as? [[String: Any]])
        citations[3] = citations[0]
        trace["sourceCitations"] = citations
        payload["decisionTrace"] = trace

        let data = try JSONSerialization.data(withJSONObject: payload)
        let response = try AIResponseParser.parse(data, language: .english)

        #expect(!response.isLiveOpenAI)
        #expect(response.origin == .unverified)
    }

    @Test func languageGuardChecksVisibleGovernanceBoundaryText() {
        let response = AIResponse(
            answer: "Проверьте официальные источники.",
            sources: [],
            safetyNote: nil,
            suggestedActions: [],
            governance: AIResponseGovernance(
                contentReleaseID: "younew-newcomer-demo-v1",
                verifiedDate: "2026-07-14",
                locationAssumption: "National guidance; verify municipality-specific steps.",
                uncertainty: "Обязанности зависят от статуса.",
                escalation: "При непосредственной опасности звоните 112."
            )
        )

        #expect(!AIResponseLanguageGuard.isResponseAcceptable(response, for: .russian))
    }

    @Test func liveClassificationRequiresVerifiedApprovedBundledRelease() {
        let local = BuildWeekNewcomerDemo.localResponse(language: .english)
        let governance = AIResponseGovernance(
            contentReleaseID: "younew-newcomer-demo-v1",
            verifiedDate: "2026-07-14",
            locationAssumption: "National guidance; verify municipality-specific steps.",
            uncertainty: "Duties depend on personal status.",
            escalation: "Use 112 for immediate danger and official sources otherwise."
        )
        let response = AIResponse(
            answer: local.answer,
            sources: local.sources,
            safetyNote: local.safetyNote,
            suggestedActions: local.suggestedActions,
            isVerified: true,
            origin: .liveOpenAI,
            model: "gpt-5.6",
            requestID: "req_contract_12345678",
            decisionTrace: local.decisionTrace,
            governance: governance
        )

        #expect(!response.isLiveOpenAI)
        #expect(BuildWeekNewcomerDemo.approvedLiveContentReleases.isEmpty)
    }

    @Test func parserRejectsModelsOutsideYouNewSolPolicy() throws {
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
        #expect(response.decisionTrace?.isMachineValid == true)
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

    private static let auditDate = Date(timeIntervalSince1970: 1_786_276_800) // 2026-08-09T12:00:00Z, deterministic audit reference

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
                "sourceVerifiedDate": "2026-07-14",
                "appDestination": contract.appDestination
            ]
        }
        return [
            "summary": "Check registration first, then DigiD, situation-dependent insurance, and recommended huisarts registration.",
            "steps": steps,
            "warnings": [
                "Requirements can depend on your gemeente and residence, work, or study status."
            ],
            "contentReleaseId": "younew-newcomer-demo-v1",
            "verifiedDate": "2026-07-14",
            "locationAssumption": "National Netherlands guidance; municipality-specific steps must be verified.",
            "uncertainty": "Registration and insurance duties depend on personal status.",
            "escalation": "Use 112 for immediate danger and official sources for individual next steps.",
            "model": "gpt-5.6",
            "requestId": "req_buildweek_12345678",
            "decisionTrace": [
                "selectedRecordIDs": BuildWeekNewcomerDemo.knowledgeRecordIDs,
                "sourceCitations": BuildWeekNewcomerDemo.steps.map { contract in
                    [
                        "recordID": contract.knowledgeRecordID,
                        "sourceTitle": contract.sourceTitle,
                        "sourcePublisher": contract.id == "digid" ? "DigiD" : "Government of the Netherlands",
                        "sourceURL": contract.sourceURL.absoluteString
                    ]
                },
                "freshnessEvidence": BuildWeekNewcomerDemo.steps.map { contract in
                    [
                        "recordID": contract.knowledgeRecordID,
                        "summary": "Official source checked 2026-07-14."
                    ]
                },
                "jurisdictionEvidence": BuildWeekNewcomerDemo.steps.map { contract in
                    [
                        "recordID": contract.knowledgeRecordID,
                        "summary": "National guidance with municipality or personal-status limits."
                    ]
                },
                "rankingFactors": ["bounded scenario", "official source", "stable order"],
                "confidenceBreakdown": [:],
                "excludedCandidateReasons": [:],
                "policyVersion": "retrieval-policy-v1",
                "modelVersion": "gpt-5.6",
                "contextVersion": BuildWeekNewcomerDemo.contextVersion
            ]
        ]
    }
}
