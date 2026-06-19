import Foundation

struct MockAIService: AIServiceProtocol {
    func shouldPreferLocalResponse(for message: String) -> Bool {
        let query = normalizedQuery(message)
        guard !query.isEmpty else { return false }
        return query.count <= 4 || directGuide(for: message) != nil
    }

    func sendMessage(
        userMessage: String,
        context: AIContext,
        conversation: [AIMessage]
    ) async throws -> AIResponse {
        switch AISafetyFilter.evaluate(userMessage, language: context.userLanguage) {
        case .allowed:
            break
        case .blocked(let blocked), .privacyWarning(let blocked):
            return safetyResponse(blocked, context: context)
        }

        return verifiedLocalResponse(for: userMessage, context: context)
    }

    func sendMessage(_ message: String, language: AppLanguage) async -> String {
        if let blocked = AISafetyRules.blockedResponseIfNeeded(for: message, languageCode: language.rawValue) {
            return blocked
        }

        let context = AIContext.empty(language: language)
        return verifiedLocalResponse(for: message, context: context).answer
    }

    func summarizeLetter(_ text: String, language: AppLanguage) async -> String {
        if let blocked = AISafetyRules.blockedResponseIfNeeded(for: text, languageCode: language.rawValue) {
            return blocked
        }
        switch language {
        case .russian:
            return "Возможная сводка: это письмо может требовать ответного действия. Проверьте отправителя, возможные сроки и подтвердите через официальные каналы."
        case .dutch:
            return "Mogelijke samenvatting: deze brief kan om een vervolgactie vragen. Controleer de afzender, mogelijke deadlines en verifieer via officiële kanalen."
        case .english:
            return "Possible summary: this letter may request a follow-up action. Check sender details, possible deadlines, and verify via official channels."
        }
    }

    func translateText(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) async -> String {
        switch targetLanguage {
        case .russian:
            return "Перевод (предварительный): \(text). Переводы могут быть неточными — важные детали уточняйте в оригинале."
        case .dutch:
            return "Vertaling (voorlopig): \(text). Vertalingen kunnen onvolledig zijn — verifieer belangrijke details in het origineel."
        case .english:
            return "Translation (preliminary): \(text). Translations may be incomplete — verify important details in the original."
        }
    }

    func explainInstitution(_ name: String, language: AppLanguage) async -> String {
        switch language {
        case .russian:
            switch name.lowercased() {
            case "ind": return "IND часто отвечает за вопросы иммиграции и ВНЖ. Проверьте официальный сайт IND."
            case "duo": return "DUO часто отвечает за образование и студенческие выплаты. Проверьте официальный сайт DUO."
            case "uwv": return "UWV часто отвечает за вопросы работы и пособий. Проверьте официальный сайт UWV."
            case "belastingdienst": return "Belastingdienst — налоговая служба Нидерландов. Проверьте официальный сайт Belastingdienst."
            case "cjib": return "CJIB часто отправляет письма об оплате штрафов. Проверьте официальный сайт CJIB."
            case "rdw": return "RDW отвечает за регистрацию транспорта и водительские вопросы. Проверьте официальный сайт RDW."
            default: return "Это может быть важная организация. Проверьте информацию на официальном сайте."
            }
        case .dutch:
            switch name.lowercased() {
            case "ind": return "IND behandelt vaak immigratie en verblijfsvergunningen. Controleer de officiële IND-website."
            case "duo": return "DUO behandelt vaak onderwijsadministratie en studiefinanciering. Controleer de officiële DUO-website."
            case "uwv": return "UWV behandelt vaak werkgerelateerde uitkeringen. Controleer de officiële UWV-website."
            case "belastingdienst": return "Belastingdienst behandelt belastingen en gerelateerde brieven. Controleer de officiële Belastingdienst-website."
            case "cjib": return "CJIB behandelt officiële betalingsbeschikkingen zoals verkeersboetes. Controleer de officiële CJIB-website."
            case "rdw": return "RDW behandelt voertuig- en rijbewijsadministratie. Controleer de officiële RDW-website."
            default: return "Mogelijke institutionele context gevonden. Verifieer rechtstreeks bij officiële bronnen."
            }
        case .english:
            switch name.lowercased() {
            case "ind": return "IND often handles immigration and residence permits. Verify on the official IND website."
            case "duo": return "DUO often handles education-related administration and finance. Verify on the official DUO website."
            case "uwv": return "UWV often handles work-related benefits and employment support. Verify on the official UWV website."
            case "belastingdienst": return "Belastingdienst handles taxes and related letters. Verify on the official Belastingdienst website."
            case "cjib": return "CJIB handles many official payment notices such as traffic fines. Verify on the official CJIB website."
            case "rdw": return "RDW handles vehicle and driving-related administration. Verify on the official RDW website."
            default: return "Possible institution context found. Verify directly with official sources."
            }
        }
    }

    func suggestResources(for topic: String, language: AppLanguage) async -> [ResourceLinkItem] {
        MockResourcesData.items.filter {
            $0.title.localizedCaseInsensitiveContains(topic) ||
            $0.description.localizedCaseInsensitiveContains(topic) ||
            $0.category.localizedCaseInsensitiveContains(topic)
        }.prefix(3).map { $0 }
    }

    private func bestGuide(for message: String, language: AppLanguage, context: AIContext) -> BeginnerGuideItem? {
        directGuide(for: message, context: context)
        ?? MockBeginnerGuidesData.search(
            message,
            language: language,
            activePersona: context.activePersonaTag,
            scope: context.personaSearchScope
        ).first
    }

    private func verifiedLocalResponse(for message: String, context: AIContext) -> AIResponse {
        let language = context.userLanguage
        guard let guide = bestGuide(for: message, language: language, context: context),
              let sourceURL = guide.officialSourceURL,
              sourceURL.scheme == "https"
        else {
            return AIResponse.unverified(language: language)
        }

        let source = OfficialSource(
            title: guide.officialSourceName,
            url: sourceURL,
            institution: guide.officialSourceName
        )
        let checks = guide.whatToCheck(language).prefix(3).map { "• \($0)" }.joined(separator: "\n")
        let destination = destination(for: guide.category)
        let nextStep = guide.safeNextStep(language)
        let quickActions = quickActions(
            for: guide,
            source: source,
            destination: destination,
            language: language,
            context: context
        )

        return AIResponse(
            answer: guide.simpleAnswer(language),
            sources: [source],
            safetyNote: AISafetyRules.sourceReminder(languageCode: language.rawValue),
            suggestedActions: Array(quickActions.map(\.title).prefix(4)),
            quickActions: quickActions,
            sections: [
                AIResponseSection(
                    title: localizedSectionTitle("Answer", "Antwoord", "Ответ", language),
                    body: guide.simpleAnswer(language),
                    symbol: "checkmark.circle.fill"
                ),
                AIResponseSection(
                    title: localizedSectionTitle("Why it matters", "Waarom dit belangrijk is", "Почему важно", language),
                    body: guide.whyItMatters(language),
                    symbol: "exclamationmark.circle.fill"
                ),
                AIResponseSection(
                    title: localizedSectionTitle("What to check", "Wat te controleren", "Что проверить", language),
                    body: checks.isEmpty ? defaultChecks(language).prefix(3).map { "• \($0)" }.joined(separator: "\n") : checks,
                    symbol: "checklist"
                )
            ],
            nextStep: AINextStep(
                title: localizedSectionTitle("Next step", "Volgende stap", "Следующий шаг", language),
                detail: nextStep,
                destinationID: destination.id,
                destinationTitle: destination.title
            ),
            appDestinationID: destination.id,
            isVerified: true,
            cacheKey: normalizedQuery(message)
        )
    }

    private func safetyResponse(_ message: String, context: AIContext) -> AIResponse {
        let actions = [
            AIResponseAction.openScreen(
                title: localizedSectionTitle("Open official sources", "Open officiële bronnen", "Открыть официальные источники", context.userLanguage),
                destinationID: "officialSources"
            ),
            AIResponseAction.openScreen(
                title: localizedSectionTitle("Find in app", "Zoek in app", "Найти в приложении", context.userLanguage),
                destinationID: "search"
            )
        ]

        return AIResponse(
            answer: message,
            sources: [],
            safetyNote: context.disclaimer,
            suggestedActions: actions.map(\.title),
            quickActions: actions,
            sections: [
                AIResponseSection(
                    title: localizedSectionTitle("Safety", "Veiligheid", "Безопасность", context.userLanguage),
                    body: message,
                    symbol: "shield.lefthalf.filled"
                )
            ],
            nextStep: AINextStep(
                title: localizedSectionTitle("Official sources", "Officiële bronnen", "Официальные источники", context.userLanguage),
                detail: localizedSectionTitle(
                    "Use verified sources before acting.",
                    "Gebruik geverifieerde bronnen voordat u handelt.",
                    "Перед действием проверьте официальные источники.",
                    context.userLanguage
                ),
                destinationID: "officialSources",
                destinationTitle: "Official sources"
            ),
            appDestinationID: "officialSources",
            isVerified: false
        )
    }

    private func destination(for category: BeginnerGuideCategory) -> (id: String, title: String) {
        switch category {
        case .identity, .municipality, .dailyLife:
            return ("firstSteps", "First steps")
        case .immigration:
            return ("government", "Government")
        case .work, .taxes, .benefits:
            return ("government", "Government")
        case .education:
            return ("knm", "KNM")
        case .healthcare, .health:
            return ("healthcare", "Healthcare")
        case .housing:
            return ("housing", "Housing")
        case .transport:
            return ("transport", "Transport")
        case .fines:
            return ("fines", "Fines")
        case .legalHelp, .safety:
            return ("officialSources", "Official sources")
        }
    }

    private func quickActions(
        for guide: BeginnerGuideItem,
        source: OfficialSource,
        destination: (id: String, title: String),
        language: AppLanguage,
        context: AIContext
    ) -> [AIResponseAction] {
        var actions: [AIResponseAction] = [
            .openGuide(
                title: localizedSectionTitle("Open guide", "Open gids", "Открыть гид", language),
                destinationID: destination.id
            ),
            .save(
                title: localizedSectionTitle("Save", "Bewaar", "Сохранить", language),
                itemID: guide.id.uuidString
            ),
            .share(
                title: localizedSectionTitle("Share", "Deel", "Поделиться", language),
                itemID: guide.id.uuidString
            )
        ]

        if let url = source.url {
            actions.insert(.openSource(title: source.title, url: url), at: 1)
        }

        if let city = context.selectedCity?.trimmingCharacters(in: .whitespacesAndNewlines),
           !city.isEmpty,
           let routeID = routeID(forCityNamed: city) {
            actions.append(AIResponseAction(kind: .openCity, title: cityActionTitle(city, language), destinationID: routeID, query: city))
        }

        if let province = context.selectedProvince?.trimmingCharacters(in: .whitespacesAndNewlines),
           !province.isEmpty,
           let routeID = routeID(forProvinceNamed: province) {
            actions.append(AIResponseAction(kind: .openProvince, title: provinceActionTitle(province, language), destinationID: routeID, query: province))
        }

        for action in suggestedActions(for: language, context: context) where actions.count < 8 {
            actions.append(.relatedTopic(action, query: action))
        }

        return deduplicatedActions(actions)
    }

    private func routeID(forCityNamed name: String) -> String? {
        NLCity.all.first { city in
            city.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }.flatMap { AppNavigationResolver.routeID(from: .nlCityDetail($0.id)) }
    }

    private func routeID(forProvinceNamed name: String) -> String? {
        NLProvince.all.first { province in
            province.name.localizedCaseInsensitiveCompare(name) == .orderedSame ||
            province.id.localizedCaseInsensitiveCompare(name) == .orderedSame
        }.flatMap { AppNavigationResolver.routeID(from: .provinceDetail($0.id)) }
    }

    private func cityActionTitle(_ city: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Открыть \(city)"
        case .dutch: return "Open \(city)"
        case .english: return "Open \(city)"
        }
    }

    private func provinceActionTitle(_ province: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Открыть \(province)"
        case .dutch: return "Open \(province)"
        case .english: return "Open \(province)"
        }
    }

    private func deduplicatedActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
        var seen = Set<String>()
        return actions.filter { action in
            let key = [action.kind.rawValue, action.destinationID ?? "", action.url?.absoluteString ?? "", action.itemID ?? "", action.query ?? "", action.title].joined(separator: "|")
            return seen.insert(key).inserted
        }
    }

    private func localizedSectionTitle(_ english: String, _ dutch: String, _ russian: String, _ language: AppLanguage) -> String {
        switch language {
        case .russian: return russian
        case .dutch: return dutch
        case .english: return english
        }
    }

    private func defaultChecks(_ language: AppLanguage) -> [String] {
        switch language {
        case .russian: return ["Кто отправил?", "Какая дата?", "Какое действие требуется?"]
        case .dutch: return ["Wie heeft dit gestuurd?", "Welke datum staat vermeld?", "Welke actie is vereist?"]
        case .english: return ["Who sent this?", "What date is shown?", "What action is required?"]
        }
    }

    private func directGuide(for message: String, context: AIContext? = nil) -> BeginnerGuideItem? {
        let query = normalizedQuery(message)

        let directMatchers: [(needles: [String], titleNeedles: [String])] = [
            (["bsn", "burgerservicenummer", "бсн"], ["what is bsn"]),
            (["digid", "digital identity", "дигид"], ["digid"]),
            (["cjib"], ["cjib"]),
            (["health insurance", "zorgverzekering", "медстраховка"], ["health insurance"]),
            (["huisarts", "family doctor", "gp"], ["huisarts"]),
            (["ov-chipkaart", "ovpay", "public transport", "transport"], ["ov-chipkaart", "transport"]),
            (["municipality", "gemeente", "registration", "brp"], ["municipality", "gemeente"]),
            (["housing", "rent", "huur", "жиль"], ["housing"]),
            (["bank", "iban"], ["banking"]),
            (["fine", "boete", "штраф"], ["fine"])
        ]

        for matcher in directMatchers where matcher.needles.contains(where: { query.contains($0) }) {
            if let guide = MockBeginnerGuidesData.items.first(where: { item in
                if let context, !item.isVisible(for: context.activePersonaTag, scope: context.personaSearchScope) {
                    return false
                }
                let title = item.title(.english).lowercased()
                return matcher.titleNeedles.contains(where: { title.contains($0) })
            }) {
                return guide
            }
        }

        return nil
    }

    private func normalizedQuery(_ message: String) -> String {
        message
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func suggestedActions(for language: AppLanguage, context: AIContext) -> [String] {
        let base: [String]
        switch language {
        case .russian:
            base = ["Проверьте официальный источник", "Сохраните важные сроки", "Не отправляйте чувствительные данные"]
        case .dutch:
            base = ["Controleer de officiële bron", "Bewaar belangrijke deadlines", "Deel geen gevoelige gegevens"]
        case .english:
            base = ["Check the official source", "Save important deadlines", "Do not share sensitive data"]
        }

        let contextual: [String]
        switch (context.screen, language) {
        case (.transport, .russian):
            contextual = ["Проверьте маршрут в 9292 или NS", "Сверьте оплату OVpay/OV-chipkaart"]
        case (.transport, .dutch):
            contextual = ["Controleer de route in 9292 of NS", "Controleer OVpay/OV-chipkaart betaling"]
        case (.transport, .english):
            contextual = ["Check the route in 9292 or NS", "Verify OVpay/OV-chipkaart payment"]
        case (.knm, .russian):
            contextual = ["Откройте модуль KNM по теме", "Пройдите тренировочный вопрос"]
        case (.knm, .dutch):
            contextual = ["Open de KNM-module voor dit onderwerp", "Maak een oefenvraag"]
        case (.knm, .english):
            contextual = ["Open the KNM module for this topic", "Try a practice question"]
        case (.dutchCourse, .russian):
            contextual = ["Выучите 5 слов по теме", "Повторите короткий диалог"]
        case (.dutchCourse, .dutch):
            contextual = ["Leer 5 woorden bij dit onderwerp", "Herhaal een korte dialoog"]
        case (.dutchCourse, .english):
            contextual = ["Learn 5 words for this topic", "Practice a short dialogue"]
        case (.officialLinks, .russian):
            contextual = ["Откройте официальный сайт", "Проверьте дату и требования"]
        case (.officialLinks, .dutch):
            contextual = ["Open de officiële website", "Controleer datum en voorwaarden"]
        case (.officialLinks, .english):
            contextual = ["Open the official website", "Check date and requirements"]
        case (.map, .russian):
            contextual = ["Откройте карту рядом", "Проверьте выбранный город"]
        case (.map, .dutch):
            contextual = ["Open hulp dichtbij", "Controleer de gekozen stad"]
        case (.map, .english):
            contextual = ["Open nearby help", "Check the selected city"]
        default:
            contextual = []
        }

        return Array((contextual + base).prefix(4))
    }
}
