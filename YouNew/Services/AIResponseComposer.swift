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

        guard let primary = results.first else {
            return missingInformationResponse(query: query, language: language, context: context)
        }
        let related = Array(results.dropFirst().prefix(4))
        let sources = deduplicatedSources(
            results
                .flatMap { [$0.item] + $0.graphNeighbors }
                .flatMap(\.sources)
        )
        let actions = responseActions(for: primary, related: related, language: language, context: context, sources: sources)
        let sections = responseSections(primary: primary, related: related, language: language, context: context)
        let nextStep = nextStep(for: primary, language: language, context: context)

        let response = AIResponse(
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
        guard language != .russian || AIResponseLanguageGuard.isResponseAcceptable(response, for: language) else {
            return missingInformationResponse(query: query, language: language, context: context)
        }
        return response
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

        if let meaning = meaningText(primary: primary, language: language, context: context) {
            sections.append(AIResponseSection(title: label(.meaning, language), body: meaning, symbol: "info.circle.fill"))
        }

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

        if let next = nextActionText(primary: primary, language: language, context: context) {
            sections.append(AIResponseSection(title: label(.nextStep, language), body: next, symbol: "arrow.right.circle.fill"))
        }

        let usefulActions = usefulActionsText(primary: primary, language: language, context: context)
        if !usefulActions.isEmpty {
            sections.append(AIResponseSection(title: label(.usefulActions, language), body: usefulActions, symbol: "square.grid.2x2.fill"))
        }

        let relatedTopics = related
            .prefix(3)
            .map { $0.item.title(language) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        if !relatedTopics.isEmpty {
            sections.append(AIResponseSection(title: label(.relatedTopics, language), body: relatedTopics, symbol: "arrow.triangle.branch"))
        }

        let sourceText = officialSourceText(sources: item.sources, language: language)
        if !sourceText.isEmpty {
            sections.append(AIResponseSection(title: label(.officialSource, language), body: sourceText, symbol: "checkmark.seal.fill"))
        }

        let partners = localPartnerText(query: item.category, context: context, language: language)
        if !partners.isEmpty {
            sections.append(AIResponseSection(title: label(.localPartners, language), body: partners, symbol: "person.2.fill"))
        }

        return Array(sections.prefix(9))
    }

    private static func meaningText(
        primary: KnowledgeSearchResult,
        language: AppLanguage,
        context: AIContext
    ) -> String? {
        let title = primary.item.title(language)
        let audience = context.userSituation ?? context.activePersonaTag?.title
        let place = [context.selectedCity, context.selectedProvince].compactMap { $0 }.joined(separator: ", ")
        switch language {
        case .russian:
            if let audience, !place.isEmpty {
                return "Для профиля \(audience) в \(place) это связано с темой «\(title)» и ближайшими шагами внутри YouNew."
            }
            return "Это связано с темой «\(title)» и ближайшими шагами внутри YouNew."
        case .dutch:
            if let audience, !place.isEmpty {
                return "Voor profiel \(audience) in \(place) hoort dit bij '\(title)' en de volgende stappen in YouNew."
            }
            return "Dit hoort bij '\(title)' en de volgende stappen in YouNew."
        case .english:
            if let audience, !place.isEmpty {
                return "For the \(audience) profile in \(place), this connects to “\(title)” and the next in-app steps."
            }
            return "This connects to “\(title)” and the next in-app steps."
        }
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

    private static func nextActionText(primary: KnowledgeSearchResult, language: AppLanguage, context: AIContext) -> String? {
        let destination = primary.item.title(language)
        switch language {
        case .russian:
            return "Откройте связанный раздел «\(destination)», проверьте документы или требования, затем сверяйте важные детали с официальным источником."
        case .dutch:
            return "Open de verwante sectie '\(destination)', controleer documenten of vereisten en verifieer belangrijke details bij de officiële bron."
        case .english:
            return "Open the related “\(destination)” section, check documents or requirements, then verify important details with the official source."
        }
    }

    private static func usefulActionsText(primary: KnowledgeSearchResult, language: AppLanguage, context: AIContext) -> String {
        let actions = responseActions(
            for: primary,
            related: [],
            language: language,
            context: context,
            sources: primary.item.sources
        )
        return bulletList(actions.prefix(5).map(\.title))
    }

    private static func officialSourceText(sources: [OfficialSource], language: AppLanguage) -> String {
        let sourceLines = deduplicatedSources(sources).prefix(4).map { source in
            ([source.title] + [source.institution].compactMap { $0 }).compactMap { value in
                value.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            }.joined(separator: " · ")
        }
        if sourceLines.isEmpty {
            switch language {
            case .russian: return "Официальный источник не найден в карточке. Используйте Official Sources перед важным действием."
            case .dutch: return "Geen officiële bron in deze kaart. Gebruik Official Sources voordat u een belangrijke stap zet."
            case .english: return "No official source is attached to this card. Use Official Sources before taking an important step."
            }
        }
        return bulletList(Array(sourceLines))
    }

    private static func localPartnerText(query: String, context: AIContext, language: AppLanguage) -> String {
        guard let city = context.selectedCity else { return "" }
        let partners = Array(MockLocalPartnersData.matching(query: query, city: city).prefix(3))
        guard !partners.isEmpty else { return "" }
        let prefix: String
        switch language {
        case .russian: prefix = "Подходящие локальные партнеры в \(city):"
        case .dutch: prefix = "Passende lokale partners in \(city):"
        case .english: prefix = "Relevant local partners in \(city):"
        }
        return ([prefix] + partners.map { "- \($0.name) · \($0.category.title(language))" }).joined(separator: "\n")
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
            if let responseAction = responseAction(from: action, fallbackTitle: primary.item.title(language), language: language) {
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
            actions.append(.openSource(title: actionLabel(.openOfficialSource, language), url: sourceURL))
        }
        if !actions.contains(where: { $0.kind == .save }) {
            actions.append(.save(title: actionLabel(.save, language), itemID: primary.item.id))
        }
        if !actions.contains(where: { $0.kind == .share }) {
            actions.append(.share(title: actionLabel(.share, language), itemID: primary.item.id))
        }

        if !actions.contains(where: { $0.kind == .relatedTopic }) {
            actions.append(.relatedTopic(relatedTitle(primary.item.category, language), query: primary.item.category))
        }

        for result in related.prefix(2) {
            if let routeID = AppNavigationResolver.routeID(from: result.item.route) ?? result.item.routeID {
                actions.append(.openScreen(title: openTitle(result.item.title(language), language), destinationID: routeID))
            } else {
                actions.append(.relatedTopic(relatedTitle(result.item.title(language), language), query: result.item.title(language)))
            }
        }

        actions.append(.openScreen(title: actionLabel(.findInApp, language), destinationID: "search"))
        let visibleActions = deduplicatedActions(actions)
            .filter { isActionVisible($0, context: context) }
            .prefixArray(8)
        return prioritizedActions(visibleActions)
    }

    private static func cityAction(from context: AIContext) -> AIResponseAction? {
        guard let city = context.selectedCity,
              let destination = NLCity.all.first(where: { $0.name.caseInsensitiveCompare(city) == .orderedSame || $0.id.caseInsensitiveCompare(city) == .orderedSame })
                .map({ AppDestination.nlCityDetail($0.id) })
        else { return nil }
        return AIResponseAction(kind: .openCity, title: openTitle(city, context.userLanguage), destinationID: AppNavigationResolver.routeID(from: destination), query: city)
    }

    private static func provinceAction(from context: AIContext) -> AIResponseAction? {
        guard let province = context.selectedProvince,
              let destination = NLProvince.all.first(where: { $0.name.caseInsensitiveCompare(province) == .orderedSame || $0.id.caseInsensitiveCompare(province) == .orderedSame })
                .map({ AppDestination.provinceDetail($0.name) })
        else { return nil }
        return AIResponseAction(kind: .openProvince, title: openTitle(province, context.userLanguage), destinationID: AppNavigationResolver.routeID(from: destination), query: province)
    }

    private static func responseAction(from action: AIQuickAction, fallbackTitle: String, language: AppLanguage) -> AIResponseAction? {
        switch action {
        case .openGuide(let destination):
            return .openGuide(title: actionLabel(.openGuide, language), destinationID: AppNavigationResolver.routeID(from: destination))
        case .openScreen(let destination):
            return .openScreen(title: openTitle(fallbackTitle, language), destinationID: AppNavigationResolver.routeID(from: destination))
        case .openCity(let city):
            let destination = NLCity.all.first { $0.name.caseInsensitiveCompare(city) == .orderedSame || $0.id.caseInsensitiveCompare(city) == .orderedSame }
                .map { AppDestination.nlCityDetail($0.id) }
            return AIResponseAction(kind: .openCity, title: openTitle(city, language), destinationID: AppNavigationResolver.routeID(from: destination), query: city)
        case .openProvince(let province):
            let destination = NLProvince.all.first { $0.name.caseInsensitiveCompare(province) == .orderedSame || $0.id.caseInsensitiveCompare(province) == .orderedSame }
                .map { AppDestination.provinceDetail($0.name) }
            return AIResponseAction(kind: .openProvince, title: openTitle(province, language), destinationID: AppNavigationResolver.routeID(from: destination), query: province)
        case .openSource(let url):
            return .openSource(title: actionLabel(.openSource, language), url: url)
        case .save(let itemID):
            return .save(title: actionLabel(.save, language), itemID: itemID)
        case .share(let itemID):
            return .share(title: actionLabel(.share, language), itemID: itemID)
        case .relatedTopic(let topic):
            return .relatedTopic(relatedTitle(topic, language), query: topic)
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

        let fallbackSource = OfficialSource(
            title: "Government.nl",
            url: URL(string: "https://www.government.nl"),
            institution: "Government of the Netherlands"
        )
        var actions: [AIResponseAction] = [
            .openScreen(title: actionLabel(.findInApp, language), destinationID: "search"),
            .openScreen(title: actionLabel(.openOfficialSources, language), destinationID: "officialSources"),
            .openSource(title: actionLabel(.openOfficialSource, language), url: AppURL.make("https://www.government.nl")),
            .relatedTopic(searchRelatedTitle(query, language), query: query),
            .save(title: actionLabel(.save, language), itemID: "missing:\(KnowledgeNormalizer.slug(query))"),
            .share(title: actionLabel(.share, language), itemID: "missing:\(KnowledgeNormalizer.slug(query))")
        ]
        if let cityAction = cityAction(from: context) {
            actions.append(cityAction)
        }
        if let provinceAction = provinceAction(from: context) {
            actions.append(provinceAction)
        }

        return AIResponse(
            answer: answer,
            sources: [fallbackSource],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: actions.map(\.title),
            quickActions: deduplicatedActions(actions).prefixArray(8),
            sections: [
                AIResponseSection(title: label(.answer, language), body: answer, symbol: "exclamationmark.shield.fill"),
                AIResponseSection(title: label(.nextActions, language), body: detail, symbol: "arrow.right.circle.fill")
            ],
            nextStep: AINextStep(
                title: actionLabel(.findInApp, language),
                detail: detail,
                destinationID: "search",
                destinationTitle: searchDestinationTitle(language)
            ),
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

    private static func prioritizedActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
        actions.enumerated()
            .sorted { lhs, rhs in
                let leftPriority = actionPriority(lhs.element)
                let rightPriority = actionPriority(rhs.element)
                return leftPriority == rightPriority ? lhs.offset < rhs.offset : leftPriority < rightPriority
            }
            .map(\.element)
    }

    private static func actionPriority(_ action: AIResponseAction) -> Int {
        switch action.kind {
        case .askFollowUp: return 0
        case .openCity, .openProvince: return 1
        case .openGuide, .openScreen: return 2
        case .openSource: return 3
        case .save, .share, .relatedTopic: return 4
        }
    }

    private enum SectionLabel {
        case answer
        case meaning
        case requirements
        case checklist
        case warnings
        case cityProvince
        case nextStep
        case usefulActions
        case relatedTopics
        case officialSource
        case localPartners
        case nextActions
    }

    private enum ActionLabel {
        case findInApp
        case openGuide
        case openSource
        case openOfficialSource
        case openOfficialSources
        case save
        case share
    }

    private static func actionLabel(_ label: ActionLabel, _ language: AppLanguage) -> String {
        switch (label, language) {
        case (.findInApp, .russian): return "Найти в приложении"
        case (.findInApp, .dutch): return "Zoeken in app"
        case (.findInApp, .english): return "Find in App"
        case (.openGuide, .russian): return "Открыть гид"
        case (.openGuide, .dutch): return "Gids openen"
        case (.openGuide, .english): return "Open Guide"
        case (.openSource, .russian): return "Открыть источник"
        case (.openSource, .dutch): return "Bron openen"
        case (.openSource, .english): return "Open Source"
        case (.openOfficialSource, .russian): return "Открыть официальный источник"
        case (.openOfficialSource, .dutch): return "Officiële bron openen"
        case (.openOfficialSource, .english): return "Open Official Source"
        case (.openOfficialSources, .russian): return "Открыть официальные источники"
        case (.openOfficialSources, .dutch): return "Officiële bronnen openen"
        case (.openOfficialSources, .english): return "Open Official Sources"
        case (.save, .russian): return "Сохранить"
        case (.save, .dutch): return "Bewaren"
        case (.save, .english): return "Save"
        case (.share, .russian): return "Поделиться"
        case (.share, .dutch): return "Delen"
        case (.share, .english): return "Share"
        }
    }

    private static func openTitle(_ title: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Открыть \(title)"
        case .dutch: return "Open \(title)"
        case .english: return "Open \(title)"
        }
    }

    private static func relatedTitle(_ title: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Связано: \(localizedCategory(title, language))"
        case .dutch: return "Verwant: \(localizedCategory(title, language))"
        case .english: return "Related: \(title)"
        }
    }

    private static func localizedCategory(_ title: String, _ language: AppLanguage) -> String {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch (normalized, language) {
        case ("work", .russian), ("employment", .russian): return "работа"
        case ("housing", .russian): return "жильё"
        case ("healthcare", .russian), ("health", .russian): return "медицина"
        case ("transport", .russian): return "транспорт"
        case ("education", .russian): return "образование"
        case ("taxes", .russian), ("tax", .russian): return "налоги"
        case ("registration", .russian), ("identity", .russian): return "регистрация"
        case ("government", .russian): return "государственные услуги"
        case ("official sources", .russian): return "официальные источники"
        case ("work", .dutch), ("employment", .dutch): return "werk"
        case ("housing", .dutch): return "wonen"
        case ("healthcare", .dutch), ("health", .dutch): return "zorg"
        case ("transport", .dutch): return "vervoer"
        case ("education", .dutch): return "onderwijs"
        case ("taxes", .dutch), ("tax", .dutch): return "belastingen"
        case ("registration", .dutch), ("identity", .dutch): return "registratie"
        case ("government", .dutch): return "overheidsdiensten"
        case ("official sources", .dutch): return "officiële bronnen"
        default: return title
        }
    }

    private static func searchRelatedTitle(_ query: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Поиск: \(query)"
        case .dutch: return "Zoeken: \(query)"
        case .english: return "Search: \(query)"
        }
    }

    private static func searchDestinationTitle(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Поиск"
        case .dutch: return "Zoeken"
        case .english: return "Search"
        }
    }

    private static func label(_ label: SectionLabel, _ language: AppLanguage) -> String {
        switch (label, language) {
        case (.answer, .russian): return "Ответ"
        case (.answer, .dutch): return "Antwoord"
        case (.answer, .english): return "Answer"
        case (.meaning, .russian): return "Что это означает"
        case (.meaning, .dutch): return "Wat dit betekent"
        case (.meaning, .english): return "What This Means"
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
        case (.nextStep, .russian): return "Что делать дальше"
        case (.nextStep, .dutch): return "Wat nu te doen"
        case (.nextStep, .english): return "What To Do Next"
        case (.usefulActions, .russian): return "Полезные действия"
        case (.usefulActions, .dutch): return "Nuttige acties"
        case (.usefulActions, .english): return "Useful Actions"
        case (.relatedTopics, .russian): return "Связанные темы"
        case (.relatedTopics, .dutch): return "Verwante onderwerpen"
        case (.relatedTopics, .english): return "Related Topics"
        case (.officialSource, .russian): return "Официальный источник"
        case (.officialSource, .dutch): return "Officiële bron"
        case (.officialSource, .english): return "Official Source"
        case (.localPartners, .russian): return "Локальные партнеры"
        case (.localPartners, .dutch): return "Lokale partners"
        case (.localPartners, .english): return "Local Partners"
        case (.nextActions, .russian): return "Следующие действия"
        case (.nextActions, .dutch): return "Volgende acties"
        case (.nextActions, .english): return "Next Actions"
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension Array {
    func prefixArray(_ maxLength: Int) -> [Element] {
        Array(prefix(maxLength))
    }
}
