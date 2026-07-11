import Foundation

enum AIResponseParser {
    struct BackendResponse: Decodable {
        let answer: String
        let sections: [BackendSection]?
        let nextStep: BackendNextStep?
        let appDestination: BackendDestination?
        let appDestinationID: String?
        let sources: [BackendSource]?
        let safetyNote: String?
        let suggestedActions: [String]?
        let quickActions: [BackendAction]?
        let verified: Bool?
        let cacheKey: String?
    }

    struct BackendSource: Decodable {
        let title: String
        let url: String?
        let institution: String?
    }

    struct BackendSection: Decodable {
        let title: String
        let body: String
        let icon: String?
        let symbol: String?
    }

    struct BackendNextStep: Decodable {
        let title: String
        let detail: String?
        let destination: BackendDestination?
        let destinationID: String?
        let destinationTitle: String?
    }

    struct BackendDestination: Decodable {
        let id: String
        let title: String?
    }

    struct BackendAction: Decodable {
        let kind: String?
        let title: String
        let destinationID: String?
        let destination: BackendDestination?
        let url: String?
        let itemID: String?
        let query: String?
    }

    static func parse(_ data: Data, language: AppLanguage) throws -> AIResponse {
        let decoded = try JSONDecoder().decode(BackendResponse.self, from: data)

        let sources = (decoded.sources ?? []).compactMap(makeSource)
        let requiresVerifiedContext = decoded.verified == true

        guard requiresVerifiedContext && !sources.isEmpty else {
            return AIResponse.unverified(language: language)
        }

        let answer = sanitizedBody(decoded.answer)
        guard !answer.isEmpty else {
            return AIResponse.unverified(language: language)
        }

        let appDestinationID = canonicalDestinationID(
            decoded.appDestination?.id,
            decoded.appDestinationID,
            decoded.nextStep?.destination?.id,
            decoded.nextStep?.destinationID
        )

        let normalizedNextStep = normalizedNextStep(decoded.nextStep, language: language)
        let suggestedActions = normalizedSuggestedActions(decoded.suggestedActions, fallback: normalizedNextStep)
        let quickActions = normalizedQuickActions(
            decoded.quickActions,
            fallbackNextStep: normalizedNextStep,
            appDestinationID: appDestinationID,
            sources: sources,
            suggestedActions: suggestedActions
        )
        let response = AIResponse(
            answer: answer,
            sources: sources,
            safetyNote: sanitizedBody(decoded.safetyNote),
            suggestedActions: suggestedActions,
            quickActions: quickActions,
            sections: normalizedSections(decoded.sections, answer: answer, language: language),
            nextStep: normalizedNextStep,
            appDestinationID: appDestinationID,
            isVerified: true,
            cacheKey: decoded.cacheKey
        )
        guard AIResponseLanguageGuard.isResponseAcceptable(response, for: language) else {
            return AIResponse.unverified(language: language)
        }
        return response
    }

    nonisolated private static func makeSource(_ source: BackendSource) -> OfficialSource? {
        let title = source.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty,
              let rawURL = source.url,
              let url = validatedURL(rawURL)
        else { return nil }

        return OfficialSource(
            title: title,
            url: url,
            institution: source.institution?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    nonisolated private static func validatedURL(_ raw: String) -> URL? {
        guard let components = URLComponents(string: raw),
              components.scheme == "https",
              components.host?.isEmpty == false
        else { return nil }
        return components.url
    }

    private static func normalizedSections(_ sections: [BackendSection]?, answer: String, language: AppLanguage) -> [AIResponseSection] {
        var seenBodies = Set<String>()
        let answerBodyKey = normalizedSectionBody(answer)
        let mapped = (sections ?? []).compactMap { section -> AIResponseSection? in
            let title = section.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = sanitizedBody(section.body)
            guard !title.isEmpty, !body.isEmpty else { return nil }
            let titleKey = normalizedSectionTitle(title)
            let bodyKey = normalizedSectionBody(body)
            guard !(titleKey == "warnings" && bodyKey == answerBodyKey) else { return nil }
            guard seenBodies.insert(bodyKey).inserted else { return nil }
            return AIResponseSection(
                title: localizedGenericSectionTitle(title, language: language),
                body: body,
                symbol: section.symbol ?? section.icon
            )
        }

        if mapped.isEmpty {
            return [
                AIResponseSection(
                    title: localizedParserText(.answer, language),
                    body: answer,
                    symbol: "checkmark.circle.fill"
                )
            ]
        }
        return mapped
    }

    private static func normalizedNextStep(_ nextStep: BackendNextStep?, language: AppLanguage) -> AINextStep {
        guard let nextStep else {
            return AINextStep(
                title: localizedParserText(.openOfficialSources, language),
                detail: localizedParserText(.verifySourceCard, language),
                destinationID: "officialSources",
                destinationTitle: localizedParserText(.officialSources, language)
            )
        }

        let title = nextStep.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return AINextStep(
                title: title.isEmpty ? localizedParserText(.openOfficialSources, language) : title,
                detail: sanitizedBody(nextStep.detail ?? localizedParserText(.verifySourceCard, language)),
            destinationID: canonicalDestinationID(nextStep.destination?.id, nextStep.destinationID),
            destinationTitle: nextStep.destination?.title ?? nextStep.destinationTitle
        )
    }

    private static func normalizedSuggestedActions(_ actions: [String]?, fallback: AINextStep) -> [String] {
        let normalized = (actions ?? []).compactMap { action in
            let value = sanitizedBody(action)
            return value.isEmpty ? nil : value
        }
        if normalized.isEmpty { return [fallback.title] }
        return normalized
    }

    private static func normalizedQuickActions(
        _ actions: [BackendAction]?,
        fallbackNextStep: AINextStep,
        appDestinationID: String?,
        sources: [OfficialSource],
        suggestedActions: [String]
    ) -> [AIResponseAction] {
        var output = (actions ?? []).compactMap { action in
            makeAction(action)
        }

        let fallbackDestinationID = fallbackNextStep.destinationID ?? appDestinationID
        if let fallbackDestinationID,
           !output.contains(where: { $0.destinationID == fallbackDestinationID }) {
            output.append(.openScreen(title: fallbackNextStep.title, destinationID: fallbackDestinationID))
        }

        for source in sources {
            guard let url = source.url,
                  !output.contains(where: { $0.url == url })
            else { continue }
            output.append(.openSource(title: source.title, url: url))
        }

        for action in suggestedActions where output.count < 8 {
            guard !output.contains(where: { $0.query == action || $0.title == action }) else { continue }
            output.append(.relatedTopic(action, query: action))
        }

        return Array(deduplicatedActions(output).prefix(8))
    }

    private static func makeAction(_ action: BackendAction) -> AIResponseAction? {
        let title = sanitizedBody(action.title)
        guard !title.isEmpty else { return nil }

        let destinationID = canonicalDestinationID(action.destination?.id, action.destinationID)
        let sourceURL = action.url.flatMap(validatedURL)
        let query = nilIfEmpty(sanitizedBody(action.query))
        let itemID = nilIfEmpty(action.itemID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")

        switch normalizedActionKind(action.kind) {
        case .openGuide:
            guard let destinationID else { return nil }
            return .openGuide(title: title, destinationID: destinationID)
        case .openScreen:
            guard let destinationID else { return nil }
            return .openScreen(title: title, destinationID: destinationID)
        case .openCity:
            guard let destinationID else { return nil }
            return AIResponseAction(kind: .openCity, title: title, destinationID: destinationID, query: query)
        case .openProvince:
            guard let destinationID else { return nil }
            return AIResponseAction(kind: .openProvince, title: title, destinationID: destinationID, query: query)
        case .openSource:
            guard let sourceURL else { return nil }
            return .openSource(title: title, url: sourceURL)
        case .save:
            guard let itemID else { return nil }
            return .save(title: title, itemID: itemID)
        case .share:
            guard let itemID else { return nil }
            return .share(title: title, itemID: itemID)
        case .relatedTopic:
            guard let query else { return nil }
            return .relatedTopic(title, query: query)
        case .askFollowUp:
            guard let query else { return nil }
            return AIResponseAction(kind: .askFollowUp, title: title, query: query)
        case nil:
            if let sourceURL {
                return .openSource(title: title, url: sourceURL)
            }
            if let destinationID {
                return .openScreen(title: title, destinationID: destinationID)
            }
            if let query {
                return .relatedTopic(title, query: query)
            }
            return nil
        }
    }

    nonisolated private static func normalizedActionKind(_ raw: String?) -> AIResponseAction.Kind? {
        guard let raw else { return nil }
        let normalized = raw
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()

        switch normalized {
        case "openguide", "guide": return .openGuide
        case "openscreen", "screen", "navigate", "navigation": return .openScreen
        case "opencity", "city": return .openCity
        case "openprovince", "province": return .openProvince
        case "opensource", "source", "officialsource", "link": return .openSource
        case "save", "saved": return .save
        case "share": return .share
        case "relatedtopic", "related", "topic": return .relatedTopic
        case "askfollowup", "followup", "question": return .askFollowUp
        default: return nil
        }
    }

    nonisolated private static func deduplicatedActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
        var seen = Set<String>()
        return actions.filter { action in
            let key = "\(action.kind.rawValue)|\(action.title)|\(action.destinationID ?? "")|\(action.url?.absoluteString ?? "")|\(action.itemID ?? "")|\(action.query ?? "")"
            return seen.insert(key).inserted
        }
    }

    private static func canonicalDestinationID(_ candidates: String?...) -> String? {
        candidates.compactMap { rawID in
            canonicalAIRequestRoute(rawID)
        }.first
    }

    private static func canonicalAIRequestRoute(_ rawID: String?) -> String? {
        guard let rawID else { return nil }
        guard let destination = AppNavigationResolver.destination(for: rawID) else { return nil }
        return AppNavigationResolver.routeID(from: destination)
    }

    nonisolated private static func sanitizedBody(_ text: String?) -> String {
        guard var output = text else { return "" }
        output = removeRawURLs(from: output)
        output = repairMissingSeparators(in: output)
        output = output
            .replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return output
    }

    nonisolated private static func repairMissingSeparators(in text: String) -> String {
        text
            .replacingOccurrences(of: #"([.!?])([A-ZА-Я])"#, with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(
                of: #"\b(operator|step|source|deadline|requirement|warning|answer|checklist)\s+([A-ZА-Я])"#,
                with: "$1. $2",
                options: [.regularExpression, .caseInsensitive]
            )
            .replacingOccurrences(of: #"\s+([:;,.!?])"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"([:;,.!?])([^\s\]\)])"#, with: "$1 $2", options: .regularExpression)
    }

    nonisolated private enum ParserText {
        case answer
        case warnings
        case requirements
        case checklist
        case nextStep
        case sources
        case openOfficialSources
        case verifySourceCard
        case officialSources
    }

    nonisolated private static func localizedParserText(_ key: ParserText, _ language: AppLanguage) -> String {
        switch (key, language) {
        case (.answer, .russian): return "Ответ"
        case (.answer, .dutch): return "Antwoord"
        case (.answer, .english): return "Answer"
        case (.warnings, .russian): return "Предупреждения"
        case (.warnings, .dutch): return "Waarschuwingen"
        case (.warnings, .english): return "Warnings"
        case (.requirements, .russian): return "Требования"
        case (.requirements, .dutch): return "Vereisten"
        case (.requirements, .english): return "Requirements"
        case (.checklist, .russian): return "Чеклист"
        case (.checklist, .dutch): return "Checklist"
        case (.checklist, .english): return "Checklist"
        case (.nextStep, .russian): return "Следующий шаг"
        case (.nextStep, .dutch): return "Volgende stap"
        case (.nextStep, .english): return "Next step"
        case (.sources, .russian): return "Источники"
        case (.sources, .dutch): return "Bronnen"
        case (.sources, .english): return "Sources"
        case (.openOfficialSources, .russian): return "Открыть официальные источники"
        case (.openOfficialSources, .dutch): return "Officiële bronnen openen"
        case (.openOfficialSources, .english): return "Open official sources"
        case (.verifySourceCard, .russian): return "Перед действием проверьте карточку официального источника."
        case (.verifySourceCard, .dutch): return "Controleer de officiële bronkaart voordat u handelt."
        case (.verifySourceCard, .english): return "Use the source card below before acting."
        case (.officialSources, .russian): return "Официальные источники"
        case (.officialSources, .dutch): return "Officiële bronnen"
        case (.officialSources, .english): return "Official sources"
        }
    }

    nonisolated private static func localizedGenericSectionTitle(_ title: String, language: AppLanguage) -> String {
        switch normalizedSectionTitle(title) {
        case "answer", "antwoord", "ответ":
            return localizedParserText(.answer, language)
        case "warnings", "warning", "waarschuwingen", "waarschuwing", "предупреждения", "предупреждение":
            return localizedParserText(.warnings, language)
        case "requirements", "requirement", "vereisten", "vereiste", "требования", "требование":
            return localizedParserText(.requirements, language)
        case "checklist", "чеклист":
            return localizedParserText(.checklist, language)
        case "nextstep", "nextsteps", "volgendestap", "следующийшаг":
            return localizedParserText(.nextStep, language)
        case "sources", "source", "bronnen", "bron", "источники", "источник":
            return localizedParserText(.sources, language)
        default:
            return title
        }
    }

    nonisolated private static func normalizedSectionTitle(_ title: String) -> String {
        title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"[^a-zа-я]+"#, with: "", options: .regularExpression)
    }

    nonisolated private static func normalizedSectionBody(_ body: String) -> String {
        body
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    nonisolated private static func removeRawURLs(from text: String) -> String {
        var result = text
            .replacingOccurrences(of: #"https?://\S+"#, with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: #"www\.\S+"#, with: "", options: .regularExpression)
        return result
    }

    nonisolated private static func nilIfEmpty(_ value: String) -> String? {
        value.isEmpty ? nil : value
    }
}
