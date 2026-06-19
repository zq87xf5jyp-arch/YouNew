import Foundation

enum AIResponseComposer {
    static func compose(
        query: String,
        language: AppLanguage,
        context: AIContext
    ) -> AIResponse? {
        let results = AppSearchEngine().search(query, language: language, context: context, limit: 8)
        guard !results.isEmpty else {
            return missingInformationResponse(query: query, language: language, context: context)
        }

        let primary = results[0]
        let related = Array(results.dropFirst().prefix(4))
        let sources = deduplicatedSources(
            results
                .flatMap { [$0.item] + $0.graphNeighbors }
                .flatMap(\.sources)
        )
        let actions = responseActions(for: primary, related: related, language: language, context: context, sources: sources)
        let sections = responseSections(primary: primary, related: related, language: language, context: context)
        let nextStep = nextStep(for: primary, language: language, context: context)

        return AIResponse(
            answer: primary.item.summary(language),
            sources: Array(sources.prefix(6)),
            safetyNote: safetyNote(for: primary.item, language: language),
            suggestedActions: actions.map(\.title),
            quickActions: actions,
            sections: sections,
            nextStep: nextStep,
            appDestinationID: safeRouteID(from: primary.item.route, fallback: primary.item.routeID, context: context),
            isVerified: !sources.isEmpty || primary.item.safetyLevel == .general,
            cacheKey: nil
        )
    }

    private static func responseSections(
        primary: KnowledgeSearchResult,
        related: [KnowledgeSearchResult],
        language: AppLanguage,
        context: AIContext
    ) -> [AIResponseSection] {
        let item = primary.item
        var sections: [AIResponseSection] = [
            AIResponseSection(title: label(.answer, language), body: item.summary(language), symbol: "checkmark.circle.fill")
        ]

        let requirements = requirementsText(primary: primary, language: language)
        if !requirements.isEmpty {
            sections.append(AIResponseSection(title: label(.requirements, language), body: requirements, symbol: "list.bullet.clipboard.fill"))
        }

        let checklist = checklistText(results: [primary], language: language)
        if !checklist.isEmpty {
            sections.append(AIResponseSection(title: label(.checklist, language), body: checklist, symbol: "checklist.checked"))
        }

        let warnings = warningText(results: [primary], language: language)
        if !warnings.isEmpty {
            sections.append(AIResponseSection(title: label(.warnings, language), body: warnings, symbol: "exclamationmark.triangle.fill"))
        }

        if let location = locationText(context: context, primary: primary, language: language) {
            sections.append(AIResponseSection(title: label(.cityProvince, language), body: location, symbol: "mappin.and.ellipse"))
        }

        let relatedTopics = related
            .prefix(3)
            .map { $0.item.title(language) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        if !relatedTopics.isEmpty {
            sections.append(AIResponseSection(title: label(.relatedTopics, language), body: relatedTopics, symbol: "arrow.triangle.branch"))
        }

        return Array(sections.prefix(6))
    }

    private static func requirementsText(
        primary: KnowledgeSearchResult,
        language: AppLanguage
    ) -> String {
        let candidates = [primary]
            .filter { [.document, .checklist, .article, .guide].contains($0.item.type) }
            .map { $0.item.title(language) }
        return bulletList(Array(candidates.prefix(4)))
    }

    private static func checklistText(results: [KnowledgeSearchResult], language: AppLanguage) -> String {
        let checklistItems = results
            .filter { $0.item.type == .checklist || $0.item.type == .scenario }
            .map { $0.item.title(language) }
        return bulletList(Array(checklistItems.prefix(4)))
    }

    private static func warningText(results: [KnowledgeSearchResult], language: AppLanguage) -> String {
        let warnings = results
            .filter { [.fine, .risk, .mistake, .rule].contains($0.item.type) || $0.item.safetyLevel == .officialSourceRequired || $0.item.safetyLevel == .emergency }
            .map { result in
                let title = result.item.title(language)
                let summary = result.item.summary(language)
                return summary.isEmpty ? title : "\(title): \(summary)"
            }
        return bulletList(Array(warnings.prefix(3)))
    }

    private static func locationText(context: AIContext, primary: KnowledgeSearchResult, language: AppLanguage) -> String? {
        let city = context.selectedCity ?? primary.item.city
        let province = context.selectedProvince ?? primary.item.province
        let value = [city, province].compactMap { $0 }.joined(separator: ", ")
        guard !value.isEmpty else { return nil }
        switch language {
        case .russian: return "Контекст пользователя: \(value). Используйте местные страницы gemeente или провинции, если шаг зависит от адреса."
        case .dutch: return "Gebruikerscontext: \(value). Gebruik de lokale gemeente- of provinciepagina als de stap adresafhankelijk is."
        case .english: return "User context: \(value). Use the local municipality or province page when the step depends on address."
        }
    }

    private static func nextStep(for result: KnowledgeSearchResult, language: AppLanguage, context: AIContext) -> AINextStep {
        let title: String
        let detail: String
        switch language {
        case .russian:
            title = "Откройте связанный раздел"
            detail = "Проверьте шаг в приложении и затем сверяйте важные детали с официальным источником."
        case .dutch:
            title = "Open de verwante sectie"
            detail = "Controleer de stap in de app en verifieer belangrijke details daarna bij de officiële bron."
        case .english:
            title = "Open the related section"
            detail = "Check the step in the app, then verify important details with the official source."
        }

        return AINextStep(
            title: title,
            detail: detail,
            destinationID: safeRouteID(from: result.item.route, fallback: result.item.routeID, context: context),
            destinationTitle: result.item.title(language)
        )
    }

    private static func responseActions(
        for primary: KnowledgeSearchResult,
        related: [KnowledgeSearchResult],
        language: AppLanguage,
        context: AIContext,
        sources: [OfficialSource]
    ) -> [AIResponseAction] {
        var actions: [AIResponseAction] = []

        for action in primary.quickActions {
            if let responseAction = responseAction(from: action, fallbackTitle: primary.item.title(language)) {
                actions.append(responseAction)
            }
        }

        if let cityAction = cityAction(from: context) {
            actions.append(cityAction)
        }
        if let provinceAction = provinceAction(from: context) {
            actions.append(provinceAction)
        }

        if !actions.contains(where: { $0.kind == .openSource }),
           let sourceURL = sources.compactMap(\.url).first {
            actions.append(.openSource(title: "Open Official Source", url: sourceURL))
        }
        if !actions.contains(where: { $0.kind == .save }) {
            actions.append(.save(title: "Save", itemID: primary.item.id))
        }
        if !actions.contains(where: { $0.kind == .share }) {
            actions.append(.share(title: "Share", itemID: primary.item.id))
        }

        if !actions.contains(where: { $0.kind == .relatedTopic }) {
            actions.append(.relatedTopic("Related: \(primary.item.category)", query: primary.item.category))
        }

        for result in related.prefix(2) {
            if let routeID = AppNavigationResolver.routeID(from: result.item.route) ?? result.item.routeID {
                actions.append(.openScreen(title: "Open \(result.item.title(language))", destinationID: routeID))
            } else {
                actions.append(.relatedTopic("Related: \(result.item.title(language))", query: result.item.title(language)))
            }
        }

        actions.append(.openScreen(title: "Find in App", destinationID: "search"))
        return deduplicatedActions(actions)
            .filter { isActionVisible($0, context: context) }
            .prefixArray(8)
    }

    private static func cityAction(from context: AIContext) -> AIResponseAction? {
        guard let city = context.selectedCity,
              let destination = NLCity.all.first(where: { $0.name.caseInsensitiveCompare(city) == .orderedSame || $0.id.caseInsensitiveCompare(city) == .orderedSame })
                .map({ AppDestination.nlCityDetail($0.id) })
        else { return nil }
        return AIResponseAction(kind: .openCity, title: "Open \(city)", destinationID: AppNavigationResolver.routeID(from: destination), query: city)
    }

    private static func provinceAction(from context: AIContext) -> AIResponseAction? {
        guard let province = context.selectedProvince,
              let destination = NLProvince.all.first(where: { $0.name.caseInsensitiveCompare(province) == .orderedSame || $0.id.caseInsensitiveCompare(province) == .orderedSame })
                .map({ AppDestination.provinceDetail($0.name) })
        else { return nil }
        return AIResponseAction(kind: .openProvince, title: "Open \(province)", destinationID: AppNavigationResolver.routeID(from: destination), query: province)
    }

    private static func responseAction(from action: AIQuickAction, fallbackTitle: String) -> AIResponseAction? {
        switch action {
        case .openGuide(let destination):
            return .openGuide(title: "Open Guide", destinationID: AppNavigationResolver.routeID(from: destination))
        case .openScreen(let destination):
            return .openScreen(title: "Open Screen", destinationID: AppNavigationResolver.routeID(from: destination))
        case .openCity(let city):
            let destination = NLCity.all.first { $0.name.caseInsensitiveCompare(city) == .orderedSame || $0.id.caseInsensitiveCompare(city) == .orderedSame }
                .map { AppDestination.nlCityDetail($0.id) }
            return AIResponseAction(kind: .openCity, title: "Open \(city)", destinationID: AppNavigationResolver.routeID(from: destination), query: city)
        case .openProvince(let province):
            let destination = NLProvince.all.first { $0.name.caseInsensitiveCompare(province) == .orderedSame || $0.id.caseInsensitiveCompare(province) == .orderedSame }
                .map { AppDestination.provinceDetail($0.name) }
            return AIResponseAction(kind: .openProvince, title: "Open \(province)", destinationID: AppNavigationResolver.routeID(from: destination), query: province)
        case .openSource(let url):
            return .openSource(title: "Open Source", url: url)
        case .save(let itemID):
            return .save(title: "Save", itemID: itemID)
        case .share(let itemID):
            return .share(title: "Share", itemID: itemID)
        case .relatedTopic(let topic):
            return .relatedTopic("Related: \(topic)", query: topic)
        case .askFollowUp(let question):
            return AIResponseAction(kind: .askFollowUp, title: question, query: question)
        }
    }

    private static func safeRouteID(from destination: AppDestination?, fallback: String?, context: AIContext) -> String? {
        let routeID = AppNavigationResolver.routeID(from: destination) ?? fallback
        return safeDestinationID(routeID, context: context)
    }

    private static func safeDestinationID(_ destinationID: String?, context: AIContext) -> String? {
        guard let destinationID else { return nil }
        return AppNavigationResolver.destination(for: destinationID) == nil ? nil : destinationID
    }

    private static func isActionVisible(_ action: AIResponseAction, context: AIContext) -> Bool {
        guard let destinationID = action.destinationID else { return true }
        return safeDestinationID(destinationID, context: context) != nil
    }

    private static func missingInformationResponse(query: String, language: AppLanguage, context: AIContext) -> AIResponse {
        let answer: String
        let detail: String
        switch language {
        case .russian:
            answer = "У меня нет проверенной информации об этом в приложении."
            detail = "Откройте поиск или официальный источник. Не действуйте по непроверенной информации."
        case .dutch:
            answer = "Ik heb hierover geen geverifieerde informatie in de app."
            detail = "Open zoekresultaten of officiële bronnen. Handel niet op ongecontroleerde informatie."
        case .english:
            answer = "I don't have verified information in the app for this yet."
            detail = "Open search or official sources. Do not act on unverified information."
        }

        let officialSource = OfficialSource(
            title: "Government.nl",
            url: URL(string: "https://www.government.nl"),
            institution: "Government of the Netherlands"
        )
        var actions: [AIResponseAction] = [
            .openScreen(title: "Find in App", destinationID: "search"),
            .openScreen(title: "Open Official Sources", destinationID: "officialSources"),
            .openSource(title: "Open Official Source", url: officialSource.url ?? AppURL.make("https://www.government.nl")),
            .relatedTopic("Search: \(query)", query: query),
            .save(title: "Save", itemID: "missing:\(KnowledgeNormalizer.slug(query))"),
            .share(title: "Share", itemID: "missing:\(KnowledgeNormalizer.slug(query))")
        ]
        if let cityAction = cityAction(from: context) {
            actions.append(cityAction)
        }
        if let provinceAction = provinceAction(from: context) {
            actions.append(provinceAction)
        }

        return AIResponse(
            answer: answer,
            sources: [officialSource],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: actions.map(\.title),
            quickActions: deduplicatedActions(actions).prefixArray(8),
            sections: [
                AIResponseSection(title: label(.answer, language), body: answer, symbol: "exclamationmark.shield.fill"),
                AIResponseSection(title: label(.nextActions, language), body: detail, symbol: "arrow.right.circle.fill")
            ],
            nextStep: AINextStep(title: "Find in App", detail: detail, destinationID: "search", destinationTitle: "Search"),
            appDestinationID: "search",
            isVerified: false
        )
    }

    private static func safetyNote(for item: KnowledgeItem, language: AppLanguage) -> String? {
        guard item.safetyLevel != .general else { return nil }
        return AISafetyRules.sourceReminder(languageCode: language.rawValue)
    }

    private static func bulletList(_ values: [String]) -> String {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0.lowercased()).inserted }
            .map { "- \($0)" }
            .joined(separator: "\n")
    }

    private static func deduplicatedSources(_ sources: [OfficialSource]) -> [OfficialSource] {
        var seen = Set<String>()
        return sources.filter { source in
            let key = "\(source.title)|\(source.url?.absoluteString ?? "")"
            return seen.insert(key).inserted
        }
    }

    private static func deduplicatedActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
        var seen = Set<String>()
        return actions.filter { action in
            let key = "\(action.kind.rawValue)|\(action.title)|\(action.destinationID ?? "")|\(action.url?.absoluteString ?? "")|\(action.itemID ?? "")|\(action.query ?? "")"
            return seen.insert(key).inserted
        }
    }

    private enum SectionLabel {
        case answer
        case requirements
        case checklist
        case warnings
        case cityProvince
        case relatedTopics
        case nextActions
    }

    private static func label(_ label: SectionLabel, _ language: AppLanguage) -> String {
        switch (label, language) {
        case (.answer, .russian): return "Ответ"
        case (.answer, .dutch): return "Antwoord"
        case (.answer, .english): return "Answer"
        case (.requirements, .russian): return "Требования"
        case (.requirements, .dutch): return "Vereisten"
        case (.requirements, .english): return "Requirements"
        case (.checklist, .russian): return "Чеклист"
        case (.checklist, .dutch): return "Checklist"
        case (.checklist, .english): return "Checklist"
        case (.warnings, .russian): return "Предупреждения"
        case (.warnings, .dutch): return "Waarschuwingen"
        case (.warnings, .english): return "Warnings"
        case (.cityProvince, .russian): return "Город / провинция"
        case (.cityProvince, .dutch): return "Stad / provincie"
        case (.cityProvince, .english): return "City / Province"
        case (.relatedTopics, .russian): return "Связанные темы"
        case (.relatedTopics, .dutch): return "Verwante onderwerpen"
        case (.relatedTopics, .english): return "Related Topics"
        case (.nextActions, .russian): return "Следующие действия"
        case (.nextActions, .dutch): return "Volgende acties"
        case (.nextActions, .english): return "Next Actions"
        }
    }
}

private extension Array {
    func prefixArray(_ maxLength: Int) -> [Element] {
        Array(prefix(maxLength))
    }
}
