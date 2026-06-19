import Testing
import Foundation
@testable import YouNew

// MARK: - Safety Filter Tests

@MainActor
struct AIFoundationTests {

    // MARK: Blocked prompts

    @Test func safetyFilterBlocksIllegalWorkAndTaxAvoidance() {
        let illegalWork = AISafetyFilter.evaluate("Can I work illegally?", language: .english)
        let taxAvoidance = AISafetyFilter.evaluate("How to avoid taxes?", language: .english)

        if case .blocked(let message) = illegalWork {
            #expect(message.contains("official") || message.contains("legal"))
        } else {
            Issue.record("Illegal work prompt should be blocked")
        }

        if case .blocked(let message) = taxAvoidance {
            #expect(message.contains("official") || message.contains("legal"))
        } else {
            Issue.record("Tax avoidance prompt should be blocked")
        }
    }

    @Test func safetyFilterBlocksFakeDocuments() {
        let decision = AISafetyFilter.evaluate("How to make a fake document?", language: .english)
        if case .blocked(_) = decision { } else {
            Issue.record("Fake document prompt should be blocked")
        }
    }

    @Test func safetyFilterBlocksTaxEvasion() {
        let decision = AISafetyFilter.evaluate("Tell me about tax evasion methods", language: .english)
        if case .blocked(_) = decision { } else {
            Issue.record("Tax evasion prompt should be blocked")
        }
    }

    @Test func safetyFilterBlocksRussianIllegalWork() {
        let decision = AISafetyFilter.evaluate("Как работать нелегально?", language: .russian)
        if case .blocked(_) = decision { } else {
            Issue.record("Russian illegal work prompt should be blocked")
        }
    }

    @Test func safetyFilterBlocksDutchIllegalWork() {
        let decision = AISafetyFilter.evaluate("Hoe kan ik illegaal werken?", language: .dutch)
        if case .blocked(_) = decision { } else {
            Issue.record("Dutch illegal work prompt should be blocked")
        }
    }

    // MARK: Privacy warnings

    @Test func safetyFilterWarnsOnSensitivePersonalData() {
        let decision = AISafetyFilter.evaluate("My BSN is 123456789, what should I do?", language: .english)

        if case .privacyWarning(let message) = decision {
            #expect(message.contains("BSN"))
        } else {
            Issue.record("BSN prompt should produce privacy warning")
        }
    }

    @Test func safetyFilterWarnsOnPassportMention() {
        let decision = AISafetyFilter.evaluate("My passport number is AB123456", language: .english)
        if case .privacyWarning(_) = decision { } else {
            Issue.record("Passport mention should produce privacy warning")
        }
    }

    @Test func safetyFilterWarnsOnMedicalRecord() {
        let decision = AISafetyFilter.evaluate("Can you look at my medical record?", language: .english)
        if case .privacyWarning(_) = decision { } else {
            Issue.record("Medical record mention should produce privacy warning")
        }
    }

    @Test func safetyFilterPrivacyWarningContainsBSN() {
        let warning = AISafetyRules.privacyWarning(for: .english)
        #expect(warning.contains("BSN"))
        #expect(warning.contains("passport"))
    }

    @Test func safetyFilterRussianPrivacyWarningContainsBSN() {
        let warning = AISafetyRules.privacyWarning(for: .russian)
        #expect(warning.contains("BSN"))
    }

    // MARK: Emergency escalation

    @Test func safetyFilterEscalatesEmergency() {
        let result = AISafetyRules.emergencyEscalationIfNeeded(for: "There is an emergency!", languageCode: "en")
        #expect(result != nil)
        #expect(result?.contains("112") == true)
    }

    @Test func safetyFilterEscalatesDutchEmergency() {
        let result = AISafetyRules.emergencyEscalationIfNeeded(for: "Er is een noodgeval", languageCode: "nl")
        #expect(result != nil)
        #expect(result?.contains("112") == true)
    }

    @Test func safetyFilterEscalatesRussianEmergency() {
        let result = AISafetyRules.emergencyEscalationIfNeeded(for: "Это срочно!", languageCode: "ru")
        #expect(result != nil)
        #expect(result?.contains("112") == true)
    }

    @Test func safetyFilterDoesNotEscalateNormalMessage() {
        let result = AISafetyRules.emergencyEscalationIfNeeded(for: "What is DigiD?", languageCode: "en")
        #expect(result == nil)
    }

    // MARK: Allowed prompts

    @Test func safetyFilterAllowsDigiDQuestion() {
        let decision = AISafetyFilter.evaluate("What is DigiD?", language: .english)
        if case .allowed = decision { } else {
            Issue.record("DigiD question should be allowed")
        }
    }

    @Test func safetyFilterAllowsBSNQuestion() {
        let decision = AISafetyFilter.evaluate("What if I don't have BSN yet?", language: .english)
        if case .allowed = decision { } else {
            Issue.record("BSN status question should be allowed")
        }
    }

    @Test func safetyFilterAllowsMunicipalityQuestion() {
        let decision = AISafetyFilter.evaluate("Where do I check municipality rules?", language: .english)
        if case .allowed = decision { } else {
            Issue.record("Municipality question should be allowed")
        }
    }

    @Test func safetyFilterAllowsTransportQuestion() {
        let decision = AISafetyFilter.evaluate("How does OV-chipkaart work?", language: .english)
        if case .allowed = decision { } else {
            Issue.record("Transport question should be allowed")
        }
    }

    @Test func safetyFilterBlocksEmptyInput() {
        let decision = AISafetyFilter.evaluate("   ", language: .english)
        if case .blocked(_) = decision { } else {
            Issue.record("Empty input should be blocked")
        }
    }

    // MARK: Sensitive personal data detection

    @Test func sensitiveDataDetectionFindsBSNPattern() {
        #expect(AISafetyFilter.containsSensitivePersonalData("My bsn 123456789 please help"))
    }

    @Test func sensitiveDataDetectionFindsPassportWord() {
        #expect(AISafetyFilter.containsSensitivePersonalData("I lost my passport document"))
    }

    @Test func sensitiveDataDetectionIgnoresSafeText() {
        #expect(!AISafetyFilter.containsSensitivePersonalData("What is DigiD and how do I register?"))
    }

    @Test func sensitiveDataDetectionFindsRussianPassport() {
        #expect(AISafetyFilter.containsSensitivePersonalData("мой паспорт просрочен"))
    }

    // MARK: Response parser

    @Test func responseParserReadsStrictBackendResponse() throws {
        let json = """
        {
          "answer": "Check official sources before taking action.",
          "verified": true,
          "sections": [
            {"title": "Answer", "body": "Check official sources before taking action.", "symbol": "checkmark.circle.fill"},
            {"title": "Next step", "body": "Open the official source card.", "symbol": "arrow.right.circle.fill"}
          ],
          "nextStep": {
            "title": "Open source",
            "detail": "Verify before acting.",
            "destination": {"id": "officialSources", "title": "Official sources"}
          },
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ],
          "safetyNote": "Information only.",
          "suggestedActions": ["Open official source"],
          "cacheKey": "bsn"
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.answer.contains("Check official sources"))
        #expect(response.sources.count == 1)
        #expect(response.sections.count == 2)
        #expect(response.nextStep?.destinationID == "officialSources")
        #expect(response.appDestinationID == "officialSources")
        #expect(response.cacheKey == "bsn")
        #expect(response.suggestedActions == ["Open official source"])
    }

    @Test func responseParserLocalizesGenericFallbackLabels() throws {
        let json = """
        {
          "answer": "Проверьте официальный источник перед действием.",
          "verified": true,
          "sections": [
            {"title": "ANSWER", "body": "Проверьте официальный источник перед действием.", "symbol": "checkmark.circle.fill"},
            {"title": "REQUIREMENTS", "body": "Возьмите паспорт и договор аренды.", "symbol": "doc.text.fill"},
            {"title": "CHECKLIST", "body": "Запишитесь в gemeente.", "symbol": "checklist.checked"},
            {"title": "WARNINGS", "body": "Не отправляйте BSN в чат.", "symbol": "exclamationmark.triangle.fill"}
          ],
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .russian)
        let titles = response.sections.map(\.title)

        #expect(titles.contains("Ответ"))
        #expect(titles.contains("Требования"))
        #expect(titles.contains("Чеклист"))
        #expect(titles.contains("Предупреждения"))
        #expect(!titles.contains("ANSWER"))
        #expect(!titles.contains("REQUIREMENTS"))
        #expect(response.nextStep?.title == "Открыть официальные источники")
        #expect(response.nextStep?.detail == "Перед действием проверьте карточку официального источника.")
        #expect(response.nextStep?.destinationTitle == "Официальные источники")
    }

    @Test func aiClientRetrievalContextSerializesPersonaFields() throws {
        let context = AIContext(
            screen: .home,
            category: "Personal guide",
            topicTitle: "Student dashboard",
            topicSummary: "DUO, universities, housing, language, and student work",
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "Student",
            selectedCity: "Amsterdam",
            selectedProvince: "Noord-Holland",
            savedItemTitles: [],
            disclaimer: "Informational guidance only.",
            activePersonaTag: .student,
            secondaryPersonaTags: [.nonEU],
            personaSearchScope: .currentPersonaOnly
        )

        let retrieval = AIClient.RetrievalContext(context: context)
        let data = try JSONEncoder().encode(retrieval)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["activePersonaTag"] as? String == "student")
        #expect(object?["personaSearchScope"] as? String == "currentPersonaOnly")
        #expect(object?["secondaryPersonaTags"] as? [String] == ["nonEU"])
    }

    @Test func responseParserAcceptsTypedQuickActions() throws {
        let json = """
        {
          "answer": "Use the BSN guide and verify with the source.",
          "verified": true,
          "nextStep": {
            "title": "Open BSN guide",
            "detail": "Use the in-app route.",
            "destinationID": "article:documents:bsn"
          },
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ],
          "quickActions": [
            {"kind": "openGuide", "title": "Open BSN guide", "destinationID": "article:documents:bsn"},
            {"kind": "openSource", "title": "Government.nl", "url": "https://www.government.nl"},
            {"kind": "relatedTopic", "title": "DigiD", "query": "digid"},
            {"kind": "openSource", "title": "Unsafe source", "url": "http://example.com"},
            {"kind": "openScreen", "title": "Hidden route", "destinationID": "missing-route"}
          ],
          "suggestedActions": ["Check DigiD"]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.isVerified)
        #expect(response.quickActions.contains { $0.kind == .openGuide && $0.destinationID == "article:documents:bsn" })
        #expect(response.quickActions.contains { $0.kind == .openSource && $0.url?.scheme == "https" })
        #expect(response.quickActions.contains { $0.kind == .relatedTopic && $0.query == "digid" })
        #expect(!response.quickActions.contains { $0.title == "Unsafe source" })
        #expect(!response.quickActions.contains { $0.title == "Hidden route" })
    }

    @Test func responseParserBackfillsQuickActionsWhenBackendOmitsThem() throws {
        let json = """
        {
          "answer": "Check official sources before taking action.",
          "verified": true,
          "nextStep": {
            "title": "Open official source",
            "detail": "Verify before acting.",
            "destination": {"id": "officialSources", "title": "Official sources"}
          },
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ],
          "suggestedActions": ["Related BSN topic"]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.quickActions.contains { $0.kind == .openScreen && $0.destinationID == "officialSources" })
        #expect(response.quickActions.contains { $0.kind == .openSource && $0.url?.absoluteString == "https://www.government.nl" })
        #expect(response.quickActions.contains { $0.kind == .relatedTopic && $0.query == "Related BSN topic" })
    }

    @Test func responseParserReturnsUnverifiedWhenSourcesMissing() throws {
        let json = """
        {
          "answer": "Here is the information.",
          "verified": true,
          "sources": []
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)
        #expect(response.answer == AIResponse.unverifiedAnswer)
        #expect(!response.isVerified)
        #expect(response.sources.contains { $0.url?.absoluteString == "https://www.government.nl" })
        #expect(response.quickActions.contains { $0.kind == .openSource })
        #expect(response.quickActions.contains { $0.kind == .save })
        #expect(response.quickActions.contains { $0.kind == .share })
        #expect(response.nextStep?.destinationID == "search")
    }

    @Test func responseParserThrowsOnMissingAnswer() {
        let json = """
        {
          "sources": []
        }
        """
        do {
            _ = try AIResponseParser.parse(Data(json.utf8), language: .english)
            Issue.record("Strict backend response must include answer")
        } catch { }
    }

    @Test func responseParserRejectsInsecureSource() throws {
        let json = """
        {
          "answer": "Some answer.",
          "verified": true,
          "sources": [{"title": "Test source", "url": "http://example.com", "institution": null}],
          "suggestedActions": []
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)
        #expect(response.answer == AIResponse.unverifiedAnswer)
        #expect(response.sources.contains { $0.url?.absoluteString == "https://www.government.nl" })
        #expect(response.quickActions.contains { $0.kind == .openSource })
    }

    @Test func responseParserRemovesRawURLsFromAnswerBody() throws {
        let json = """
        {
          "answer": "Use Government.nl: https://www.government.nl before acting.",
          "verified": true,
          "sections": [
            {"title": "Answer", "body": "Read https://www.government.nl first.", "symbol": "checkmark.circle.fill"}
          ],
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)
        #expect(!response.answer.contains("https://"))
        #expect(response.sections.allSatisfy { !$0.body.contains("https://") })
    }

    @Test func responseParserRepairsGluedDynamicFields() throws {
        let json = """
        {
          "answer": "Call operator Use the official source.Step Leiden: Get your documents.",
          "verified": true,
          "sections": [
            {"title": "Answer", "body": "Call operator Use the official source.Step Leiden: Get your documents.", "symbol": "checkmark.circle.fill"},
            {"title": "Checklist", "body": "First requirement Bring ID.Checklist Leiden: Confirm appointment.", "symbol": "checklist.checked"}
          ],
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.answer.contains("operator. Use"))
        #expect(response.answer.contains("source. Step"))
        #expect(response.answer.contains("Leiden: Get"))
        #expect(response.sections.contains { $0.body.contains("requirement. Bring") })
        #expect(response.sections.contains { $0.body.contains("ID. Checklist") })
    }

    @Test func responseParserDropsDuplicatedWarningsAndSectionBodies() throws {
        let json = """
        {
          "answer": "Verify the official source before acting.",
          "verified": true,
          "sections": [
            {"title": "Answer", "body": "Verify the official source before acting.", "symbol": "checkmark.circle.fill"},
            {"title": "Warnings", "body": "Verify the official source before acting.", "symbol": "exclamationmark.triangle.fill"},
            {"title": "Checklist", "body": "Bring ID and appointment proof.", "symbol": "checklist.checked"},
            {"title": "Requirements", "body": "Bring ID and appointment proof.", "symbol": "list.bullet.clipboard.fill"}
          ],
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(!response.sections.contains { $0.title == "Warnings" })
        #expect(response.sections.filter { $0.body == "Bring ID and appointment proof." }.count == 1)
    }

    @Test func responseParserDropsUnknownDestinationID() throws {
        let json = """
        {
          "answer": "Check official sources before taking action.",
          "verified": true,
          "nextStep": {
            "title": "Open hidden route",
            "detail": "This backend target is not registered in the app.",
            "destination": {"id": "content-not-found", "title": "Hidden route"}
          },
          "appDestinationID": "missing_detail_screen",
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.isVerified)
        #expect(response.answer.contains("Check official sources"))
        #expect(response.nextStep?.destinationID == nil)
        #expect(response.appDestinationID == nil)
    }

    @Test func appRouteAliasesResolveToKnownDestinations() {
        let fixtures: [(String, AppDestination)] = [
            ("  search  ", .searchList),
            ("official-sources", .officialSources),
            ("journey_documents", .journeyDocuments),
            ("government hub", .governmentHub),
            ("DUTCH", .dutchA1A2),
            ("health-insurance", .practicalGuide(.healthInsuranceBasics)),
            ("huisarts", .practicalGuide(.findingHuisarts))
        ]

        for (rawID, expected) in fixtures {
            #expect(AppDestination.aiRoute(for: rawID) == expected)
        }
    }

    @Test func appRouteIDsAreRoundTripSafe() {
        for routeID in AppDestination.allKnownAIRouteIDs() {
            let destination = AppDestination.aiRoute(for: routeID)
            #expect(destination != nil, "Unknown route id: \(routeID)")
            if let destination {
                let canonical = AppDestination.aiRouteID(from: destination)
                #expect(canonical != nil)
                #expect(AppDestination.aiRoute(for: canonical) != nil)
            }
        }
    }

    @Test func practicalGuideRouteIDsRoundTrip() {
        let legacyShortcutTopics: Set<PracticalGuideTopic> = [
            .healthcareBasics,
            .housingBasics,
            .transportBasics
        ]

        for topic in PracticalGuideTopic.allCases {
            let destination = AppDestination.practicalGuide(topic)
            let routeID = AppNavigationResolver.routeID(from: destination)
            #expect(routeID.flatMap(AppNavigationResolver.destination(for:)) == destination)

            let explicitRouteID = "practicalGuide:\(topic.rawValue)"
            #expect(AppNavigationResolver.destination(for: explicitRouteID) == destination)

            if !legacyShortcutTopics.contains(topic) {
                #expect(routeID == explicitRouteID)
            }
        }
    }

    @Test func responseParserCanonicalizesRouteIDsAndStripsSectionURLs() throws {
        let json = """
        {
          "answer": "Use the official link https://www.government.nl to confirm.",
          "verified": true,
          "sections": [
            {"title": "Answer", "body": "Check https://www.government.nl", "symbol": "checkmark.circle.fill"}
          ],
          "nextStep": {
            "title": "Open section",
            "detail": "Go to https://younew.nl/search",
            "destination": {"id": "official-sources", "title": "Official sources"}
          },
          "appDestinationID": "government_hub",
          "safetyNote": "Source: https://www.government.nl/entry",
          "suggestedActions": ["Open https://www.government.nl/info"],
          "sources": [
            {"title": "Government.nl", "url": "https://www.government.nl", "institution": "Government of the Netherlands"}
          ]
        }
        """
        let response = try AIResponseParser.parse(Data(json.utf8), language: .english)

        #expect(response.answer.contains("official link"))
        #expect(!response.answer.contains("https://"))
        #expect(!response.sections.first!.body.contains("https://"))
        #expect(response.safetyNote?.contains("https://") == false)
        #expect(!response.suggestedActions.first!.contains("https://"))
        #expect(response.nextStep?.destinationID == "officialSources")
        #expect(response.appDestinationID == "government")
    }

    @Test func localFallbackReturnsVerifiedCachedBSNResponse() async throws {
        let service = MockAIService()
        let response = try await service.sendMessage(
            userMessage: "BSN",
            context: AIContext.empty(language: .english),
            conversation: []
        )

        #expect(response.isVerified)
        #expect(response.answer != AIResponse.unverifiedAnswer)
        #expect(!response.answer.contains("https://"))
        #expect(response.sources.isEmpty == false)
        #expect(response.nextStep?.destinationID != nil)
        #expect(response.cacheKey == "bsn")
        #expect(response.quickActions.contains { $0.kind == .openGuide || $0.kind == .openScreen })
        #expect(response.quickActions.contains { $0.kind == .openSource })
        #expect(response.quickActions.contains { $0.kind == .save })
        #expect(response.quickActions.contains { $0.kind == .share })
    }

    @Test func localFallbackUnknownQuestionUsesExactUnverifiedAnswer() async throws {
        let service = MockAIService()
        let response = try await service.sendMessage(
            userMessage: "big",
            context: AIContext.empty(language: .english),
            conversation: []
        )

        #expect(response.answer == AIResponse.unverifiedAnswer)
        #expect(!response.isVerified)
        #expect(response.sources.contains { $0.url?.absoluteString == "https://www.government.nl" })
        #expect(response.quickActions.contains { $0.kind == .openSource })
        #expect(response.quickActions.contains { $0.kind == .save })
        #expect(response.quickActions.contains { $0.kind == .share })
    }

    // MARK: Context builder - Province

    @Test func contextBuilderIncludesProvinceSource() {
        let province = ProvinceCatalog.item(id: "Noord-Holland")
        let context = AIContextBuilder.provinceContext(
            province: province,
            language: .english,
            appState: nil
        )

        #expect(context.screen == .province)
        #expect(context.topicTitle == "Noord-Holland")
        #expect(context.officialSources.first?.title == "noord-holland.nl")
        #expect(context.disclaimer.contains("informational guidance"))
    }

    // MARK: Safety rules

    @Test func systemPromptMentionsNoLegalAdvice() {
        #expect(AISafetyRules.systemPrompt.contains("not a lawyer"))
        #expect(AISafetyRules.systemPrompt.contains("not a"))
    }

    @Test func systemPromptMentions112() {
        #expect(AISafetyRules.systemPrompt.contains("112"))
    }

    @Test func mandatoryDisclaimerEnglishIsCorrect() {
        let disclaimer = AISafetyRules.mandatoryDisclaimer(for: .english)
        #expect(disclaimer.contains("informational guidance"))
        #expect(disclaimer.contains("legal"))
        #expect(disclaimer.contains("medical"))
    }

    @Test func mandatoryDisclaimerRussianIsCorrect() {
        let disclaimer = AISafetyRules.mandatoryDisclaimer(for: .russian)
        #expect(disclaimer.contains("информационную"))
    }

    @Test func mandatoryDisclaimerDutchIsCorrect() {
        let disclaimer = AISafetyRules.mandatoryDisclaimer(for: .dutch)
        #expect(disclaimer.contains("informatieve"))
    }

    @Test func sourceReminderEnglishContainsVerify() {
        let reminder = AISafetyRules.sourceReminder(languageCode: "en")
        #expect(reminder.contains("verify") || reminder.contains("Always"))
    }

    @Test func sourceMissingMessageEnglishMentionsInstitution() {
        let msg = AISafetyRules.sourceMissingMessage(for: .english)
        #expect(msg.contains("institution"))
    }

    // MARK: Usage limiter

    @Test func usageLimiterAllowsSendBelowLimit() {
        var limiter = AIUsageLimiter()
        limiter.defaults = UserDefaults(suiteName: "test.ai.limiter.\(UUID().uuidString)")!
        limiter.limit = 5
        #expect(limiter.canSend())
    }

    @Test func usageLimiterBlocksAtLimit() {
        var limiter = AIUsageLimiter()
        limiter.defaults = UserDefaults(suiteName: "test.ai.limiter.\(UUID().uuidString)")!
        limiter.limit = 3
        limiter.recordSend()
        limiter.recordSend()
        limiter.recordSend()
        #expect(!limiter.canSend())
    }

    @Test func usageLimiterAllowsAgainAfterWindow() {
        var limiter = AIUsageLimiter()
        limiter.defaults = UserDefaults(suiteName: "test.ai.limiter.\(UUID().uuidString)")!
        limiter.limit = 1
        limiter.window = 1
        limiter.recordSend(now: Date(timeIntervalSinceNow: -2))
        #expect(limiter.canSend())
    }
}
