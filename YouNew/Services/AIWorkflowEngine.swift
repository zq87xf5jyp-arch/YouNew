import Foundation

enum AIWorkflowEngine {
    static func startIfNeeded(
        query: String,
        language: AppLanguage,
        context: AIContext
    ) -> (workflow: AIWorkflow, response: AIResponse)? {
        let normalized = KnowledgeNormalizer.normalize(query)

        if matchesHealthInsurance(normalized) {
            return startHealthInsurance(language: language, context: context)
        }
        if matchesDigiD(normalized) {
            return startDigiD(language: language, context: context)
        }
        if matchesBSN(normalized) {
            return startBSN(language: language, context: context)
        }
        if matchesLetterOrFine(normalized) {
            return startFineLetter(language: language, context: context)
        }
        if matchesHousing(normalized) {
            return startHousing(language: language, context: context)
        }
        if matchesWhatNext(normalized) {
            return startWhatNext(language: language, context: context)
        }

        return nil
    }

    static func advance(
        workflow: AIWorkflow,
        answer: String,
        language: AppLanguage,
        context: AIContext
    ) -> (workflow: AIWorkflow?, response: AIResponse)? {
        var workflow = workflow
        let normalized = KnowledgeNormalizer.normalize(answer)
        let choice = choiceValue(normalized)

        switch (workflow.kind, workflow.step) {
        case (.healthInsurance, .asksWorkStatus):
            guard let value = yesNo(normalized) else { return nil }
            workflow.userWorks = value
            workflow.step = .asksRegistrationStatus
            return (workflow, registrationQuestion(workflow: workflow, language: language, context: context))

        case (.healthInsurance, .asksRegistrationStatus):
            guard let value = yesNo(normalized) else { return nil }
            workflow.isRegistered = value
            workflow.step = .finalGuidance
            return (nil, finalResponse(workflow: workflow, query: value ? "health insurance huisarts zorgtoeslag" : "municipality registration BSN health insurance", language: language, context: context))

        case (.bsnRegistration, .asksAddressStatus):
            guard let value = yesNo(normalized) else { return nil }
            workflow.hasAddress = value
            workflow.step = .asksDigiDNeed
            return (workflow, digidNeedQuestion(workflow: workflow, language: language, context: context))

        case (.bsnRegistration, .asksDigiDNeed):
            guard let value = yesNo(normalized) else { return nil }
            workflow.needsDigiD = value
            workflow.step = .finalGuidance
            let query = value ? "BSN municipality registration DigiD documents" : "BSN municipality registration documents"
            return (nil, finalResponse(workflow: workflow, query: query, language: language, context: context))

        case (.digid, .asksBSNStatus):
            guard let value = yesNo(normalized) else { return nil }
            workflow.hasBSN = value
            workflow.step = .finalGuidance
            let query = value ? "DigiD official source phishing government login" : "BSN municipality registration DigiD"
            return (nil, finalResponse(workflow: workflow, query: query, language: language, context: context))

        case (.fineLetter, .asksLetterType):
            guard let choice else { return nil }
            workflow.selectedOption = choice
            workflow.step = .finalGuidance
            return (nil, finalResponse(workflow: workflow, query: "\(choice) government letter fine deadline official source scam warning", language: language, context: context))

        case (.housing, .asksHousingStatus):
            guard let choice else { return nil }
            workflow.selectedOption = choice
            workflow.step = .finalGuidance
            return (nil, finalResponse(workflow: workflow, query: "\(choice) housing rent registration deposit legal help municipality", language: language, context: context))

        case (.whatNext, .finalGuidance):
            return nil

        default:
            return nil
        }
    }
}

private extension AIWorkflowEngine {
    static func startHealthInsurance(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .healthInsurance, step: .asksWorkStatus)
        return (
            workflow,
            questionResponse(
                workflow: workflow,
                searchQuery: "health insurance",
                question: t("Do you work in the Netherlands?", "Werk je in Nederland?", "Вы работаете в Нидерландах?", language),
                detail: t(
                    "This matters because health insurance can become mandatory when you live or work here. I will choose the right guide after two checks.",
                    "Dit is belangrijk omdat zorgverzekering verplicht kan worden als je hier woont of werkt. Na twee checks kies ik de juiste gids.",
                    "Это важно: медицинская страховка может быть обязательной, если вы живёте или работаете здесь. После двух проверок я открою правильный гид.",
                    language
                ),
                actions: yesNoActions(yes: t("Yes, I work", "Ja, ik werk", "Да, я работаю", language), no: t("No", "Nee", "Нет", language), yesQuery: "yes work", noQuery: "no work"),
                language: language,
                context: context
            )
        )
    }

    static func startBSN(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .bsnRegistration, step: .asksAddressStatus)
        return (
            workflow,
            questionResponse(
                workflow: workflow,
                searchQuery: "BSN municipality registration documents",
                question: t("Do you already have a fixed address in the Netherlands?", "Heb je al een vast adres in Nederland?", "У вас уже есть постоянный адрес в Нидерландах?", language),
                detail: t(
                    "Municipality registration and BSN usually depend on booking with the right gemeente and bringing the documents they request.",
                    "Inschrijving bij de gemeente en BSN hangen meestal af van de juiste gemeente-afspraak en de documenten die zij vragen.",
                    "Регистрация в gemeente и BSN обычно зависят от записи в правильный муниципалитет и нужных документов.",
                    language
                ),
                actions: yesNoActions(yes: t("Yes, fixed address", "Ja, vast adres", "Да, есть адрес", language), no: t("No address yet", "Nog geen adres", "Адреса пока нет", language), yesQuery: "yes address", noQuery: "no address"),
                language: language,
                context: context
            )
        )
    }

    static func startDigiD(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .digid, step: .asksBSNStatus)
        return (
            workflow,
            questionResponse(
                workflow: workflow,
                searchQuery: "DigiD BSN official source",
                question: t("Do you already have a BSN?", "Heb je al een BSN?", "У вас уже есть BSN?", language),
                detail: t(
                    "DigiD depends on verified identity details. If BSN is missing, the safe path starts with municipality registration.",
                    "DigiD hangt af van geverifieerde identiteitsgegevens. Zonder BSN begint de veilige route bij gemeente-inschrijving.",
                    "DigiD зависит от проверенных данных личности. Если BSN нет, безопасный путь начинается с регистрации в gemeente.",
                    language
                ),
                actions: yesNoActions(yes: t("Yes, I have BSN", "Ja, ik heb BSN", "Да, BSN есть", language), no: t("No BSN yet", "Nog geen BSN", "BSN пока нет", language), yesQuery: "yes bsn", noQuery: "no bsn"),
                language: language,
                context: context
            )
        )
    }

    static func startFineLetter(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .fineLetter, step: .asksLetterType)
        let actions = [
            AIResponseAction(kind: .askFollowUp, title: t("Fine or CJIB", "Boete of CJIB", "Штраф или CJIB", language), query: "fine cjib"),
            AIResponseAction(kind: .askFollowUp, title: t("Tax letter", "Belastingbrief", "Письмо о налогах", language), query: "tax letter"),
            AIResponseAction(kind: .askFollowUp, title: t("Unknown sender", "Onbekende afzender", "Неизвестный отправитель", language), query: "unknown sender")
        ]
        return (
            workflow,
            questionResponse(
                workflow: workflow,
                searchQuery: "government letter fine CJIB scam warning",
                question: t("What type of letter did you receive?", "Wat voor brief heb je ontvangen?", "Какое письмо вы получили?", language),
                detail: t(
                    "Do not paste BSN, passport number, full address, payment codes, or document numbers. I will route you to verified examples and official sources.",
                    "Plak geen BSN, paspoortnummer, volledig adres, betaalcodes of documentnummers. Ik verwijs je naar geverifieerde voorbeelden en officiële bronnen.",
                    "Не вставляйте BSN, номер паспорта, полный адрес, платёжные коды или номера документов. Я направлю вас к проверенным примерам и официальным источникам.",
                    language
                ),
                actions: actions,
                language: language,
                context: context
            )
        )
    }

    static func startHousing(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .housing, step: .asksHousingStatus)
        let actions = [
            AIResponseAction(kind: .askFollowUp, title: t("Looking for housing", "Ik zoek woning", "Ищу жильё", language), query: "looking housing"),
            AIResponseAction(kind: .askFollowUp, title: t("Rental problem", "Huurprobleem", "Проблема с арендой", language), query: "rental problem"),
            AIResponseAction(kind: .askFollowUp, title: t("Registration issue", "Inschrijfprobleem", "Проблема с регистрацией", language), query: "registration issue")
        ]
        return (
            workflow,
            questionResponse(
                workflow: workflow,
                searchQuery: "housing rent registration deposit scam legal help",
                question: t("Which housing situation fits you?", "Welke woonsituatie past bij jou?", "Какая ситуация с жильём подходит вам?", language),
                detail: t(
                    "Housing advice depends on whether you are searching, dealing with a current rental problem, or trying to register at an address.",
                    "Woonadvies hangt ervan af of je zoekt, een huidig huurprobleem hebt of je op een adres probeert in te schrijven.",
                    "Совет по жилью зависит от того, ищете ли вы жильё, решаете проблему с арендой или пытаетесь зарегистрироваться по адресу.",
                    language
                ),
                actions: actions,
                language: language,
                context: context
            )
        )
    }

    static func startWhatNext(language: AppLanguage, context: AIContext) -> (workflow: AIWorkflow, response: AIResponse) {
        let workflow = AIWorkflow(kind: .whatNext, step: .finalGuidance)
        return (workflow, nextChecklistResponse(workflow: workflow, language: language, context: context))
    }

    static func registrationQuestion(workflow: AIWorkflow, language: AppLanguage, context: AIContext) -> AIResponse {
        questionResponse(
            workflow: workflow,
            searchQuery: "municipality registration BSN health insurance",
            question: t("Are you registered at a municipality and do you have BSN?", "Ben je ingeschreven bij de gemeente en heb je een BSN?", "Вы зарегистрированы в gemeente и у вас есть BSN?", language),
            detail: t(
                "Registration and BSN affect the correct next step for insurance, huisarts, and allowances.",
                "Inschrijving en BSN bepalen de juiste volgende stap voor verzekering, huisarts en toeslagen.",
                "Регистрация и BSN влияют на следующий шаг для страховки, huisarts и пособий.",
                language
            ),
            actions: yesNoActions(yes: t("Yes, registered", "Ja, ingeschreven", "Да, зарегистрирован", language), no: t("No, not yet", "Nog niet", "Пока нет", language), yesQuery: "yes registered", noQuery: "no registration"),
            language: language,
            context: context
        )
    }

    static func digidNeedQuestion(workflow: AIWorkflow, language: AppLanguage, context: AIContext) -> AIResponse {
        questionResponse(
            workflow: workflow,
            searchQuery: "BSN DigiD documents municipality",
            question: t("Do you want to set up DigiD after BSN?", "Wil je na BSN DigiD regelen?", "Хотите оформить DigiD после BSN?", language),
            detail: t(
                "DigiD is often the next safe step after BSN because it unlocks many official online services.",
                "DigiD is vaak de volgende veilige stap na BSN, omdat het veel officiële online diensten opent.",
                "DigiD часто следующий безопасный шаг после BSN, потому что он открывает доступ ко многим официальным онлайн-сервисам.",
                language
            ),
            actions: yesNoActions(yes: t("Yes, include DigiD", "Ja, DigiD meenemen", "Да, добавить DigiD", language), no: t("No, only BSN", "Nee, alleen BSN", "Нет, только BSN", language), yesQuery: "yes digid", noQuery: "no digid"),
            language: language,
            context: context
        )
    }

    static func questionResponse(
        workflow: AIWorkflow,
        searchQuery: String,
        question: String,
        detail: String,
        actions: [AIResponseAction],
        language: AppLanguage,
        context: AIContext
    ) -> AIResponse {
        let search = AppSearchEngine().answerContext(for: searchQuery, language: language, context: context)
        let destinationID = visibleDestinationID(
            search.destination.flatMap(AppNavigationResolver.routeID(from:)) ?? fallbackDestinationID(for: workflow.kind),
            context: context
        )
        return AIResponse(
            answer: question,
            sources: search.sources,
            safetyNote: AISafetyRules.sourceReminder(languageCode: language.rawValue),
            suggestedActions: visibleActions(actions, context: context).map(\.title),
            quickActions: visibleActions(
                actions + supportActions(for: workflow.kind, language: language, sources: search.sources),
                context: context
            ),
            sections: [
                AIResponseSection(title: t("Step", "Stap", "Шаг", language), body: question, symbol: "questionmark.circle.fill"),
                AIResponseSection(title: t("Why it matters", "Waarom dit belangrijk is", "Почему это важно", language), body: detail, symbol: "exclamationmark.circle.fill")
            ],
            nextStep: AINextStep(title: question, detail: detail, destinationID: destinationID, destinationTitle: nil),
            appDestinationID: destinationID,
            isVerified: !search.sources.isEmpty
        )
    }

    static func finalResponse(
        workflow: AIWorkflow,
        query: String,
        language: AppLanguage,
        context: AIContext
    ) -> AIResponse {
        guard let composed = AIResponseComposer.compose(query: query, language: language, context: context) else {
            return AIResponse.unverified(language: language)
        }

        let guidance = workflowGuidance(workflow: workflow, language: language, context: context)
        let contextualActions = composed.quickActions.filter { $0.kind == .openCity || $0.kind == .openProvince }
        let remainingComposedActions = composed.quickActions.filter { $0.kind != .openCity && $0.kind != .openProvince }
        var actions = branchActions(for: workflow, language: language) + supportActions(for: workflow.kind, language: language, sources: composed.sources) + contextualActions + remainingComposedActions
        actions = visibleActions(prioritizedActions(deduplicateActions(actions)), context: context)

        return AIResponse(
            answer: guidance,
            sources: composed.sources,
            safetyNote: composed.safetyNote,
            suggestedActions: actions.map(\.title),
            quickActions: actions,
            sections: [
                AIResponseSection(title: t("Workflow result", "Workflow-resultaat", "Результат сценария", language), body: guidance, symbol: "arrow.triangle.branch")
            ] + composed.sections,
            nextStep: composed.nextStep,
            appDestinationID: visibleDestinationID(composed.appDestinationID ?? fallbackDestinationID(for: workflow.kind), context: context),
            isVerified: composed.isVerified,
            cacheKey: composed.cacheKey
        )
    }

    static func nextChecklistResponse(
        workflow: AIWorkflow,
        language: AppLanguage,
        context: AIContext
    ) -> AIResponse {
        let completed = Set(context.completedChecklistItemIDs)
        let visibleChecklistItems = MockChecklistData.items
            .filter { $0.isVisible(for: context.activePersonaTag, scope: context.personaSearchScope) }
        let candidate = visibleChecklistItems
            .filter { !completed.contains($0.id.uuidString) }
            .sorted { lhs, rhs in
                let lhsScore = checklistScore(lhs, context: context)
                let rhsScore = checklistScore(rhs, context: context)
                if lhsScore == rhsScore {
                    return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
                }
                return lhsScore > rhsScore
            }
            .first

        guard let item = candidate else {
            let response = AIResponseComposer.compose(
                query: "official sources saved items search",
                language: language,
                context: context
            ) ?? AIResponse.unverified(language: language)
            return response
        }

        let search = AppSearchEngine().answerContext(for: item.title(.english), language: language, context: context)
        let source = OfficialSource(title: item.officialSourceName, url: item.officialSourceURL, institution: item.officialSourceName)
        let sources = deduplicateSources([source] + search.sources)
        let routeID = "checklist:\(item.id.uuidString)"
        let cityText = context.selectedCity.map { " \($0)" } ?? ""
        let visibleCompletedCount = visibleChecklistItems.filter { completed.contains($0.id.uuidString) }.count
        let progressText = context.journeyProgress ?? "\(visibleCompletedCount)/\(visibleChecklistItems.count) checklist"
        let answer = t(
            "Your next concrete step\(cityText): \(item.title(language)). It is \(item.priority.localized(language).lowercased()) priority and belongs to \(item.category.localized(language)).",
            "Je volgende concrete stap\(cityText): \(item.title(language)). Deze heeft \(item.priority.localized(language).lowercased()) prioriteit en hoort bij \(item.category.localized(language)).",
            "Ваш следующий конкретный шаг\(cityText): \(item.title(language)). Приоритет: \(item.priority.localized(language).lowercased()), категория: \(item.category.localized(language)).",
            language
        )
        let timing = item.suggestedTiming(language)
        let actionDetail = item.description(language)
        let deadline = item.dueDate.map { date in
            date.formattedForAppLanguage(language)
        }

        var sections = [
            AIResponseSection(title: t("Workflow result", "Workflow-resultaat", "Результат сценария", language), body: answer, symbol: "arrow.triangle.branch"),
            AIResponseSection(title: t("Checklist", "Checklist", "Чеклист", language), body: "\(item.title(language))\n\(actionDetail)", symbol: "checklist.checked"),
            AIResponseSection(title: t("Why this is next", "Waarom dit nu komt", "Почему это следующий шаг", language), body: t(
                "Current progress: \(progressText). I selected the highest-priority unfinished item with the nearest timing.",
                "Huidige voortgang: \(progressText). Ik koos de belangrijkste onafgeronde stap met de dichtstbijzijnde timing.",
                "Текущий прогресс: \(progressText). Я выбрал самый важный незавершённый шаг с ближайшим сроком.",
                language
            ), symbol: "target")
        ]
        if !timing.isEmpty {
            sections.append(AIResponseSection(title: t("Timing", "Timing", "Срок", language), body: timing, symbol: "calendar"))
        }
        if let deadline {
            sections.append(AIResponseSection(title: t("Deadline", "Deadline", "Дедлайн", language), body: deadline, symbol: "clock.badge.exclamationmark"))
        }
        if let summary = search.summary {
            sections.append(AIResponseSection(title: t("Related app knowledge", "Gerelateerde app-kennis", "Связанные знания приложения", language), body: String(summary.prefix(600)), symbol: "link"))
        }

        let actions = visibleActions(deduplicateActions([
            .openScreen(title: t("Open Checklist Item", "Open checklistitem", "Открыть пункт чеклиста", language), destinationID: routeID),
            .openScreen(title: t("Open First Steps", "Open eerste stappen", "Открыть первые шаги", language), destinationID: "firstSteps"),
            .openSource(title: t("Open Official Source", "Open officiële bron", "Открыть официальный источник", language), url: item.officialSourceURL),
            .save(title: t("Save", "Bewaar", "Сохранить", language), itemID: "checklist:\(item.id.uuidString)"),
            .share(title: t("Share", "Deel", "Поделиться", language), itemID: "checklist:\(item.id.uuidString)"),
            .relatedTopic(item.category.localized(language), query: item.category.rawValue)
        ] + supportActions(for: workflow.kind, language: language, sources: sources)), context: context)

        return AIResponse(
            answer: answer,
            sources: sources,
            safetyNote: AISafetyRules.sourceReminder(languageCode: language.rawValue),
            suggestedActions: actions.map(\.title),
            quickActions: actions,
            sections: sections,
            nextStep: AINextStep(title: item.title(language), detail: actionDetail, destinationID: routeID, destinationTitle: item.title(language)),
            appDestinationID: routeID,
            isVerified: !sources.isEmpty,
            cacheKey: "workflow:whatNext:\(item.id.uuidString)"
        )
    }

    static func workflowGuidance(workflow: AIWorkflow, language: AppLanguage, context: AIContext) -> String {
        switch workflow.kind {
        case .healthInsurance:
            if workflow.isRegistered == true {
                return t(
                    "Because you said you are registered, open the health insurance guide first, then choose a huisarts and check whether zorgtoeslag applies.",
                    "Omdat je bent ingeschreven, open eerst de zorgverzekeringsgids, kies daarna een huisarts en controleer of zorgtoeslag geldt.",
                    "Так как вы зарегистрированы, сначала откройте гид по медицинской страховке, затем выберите huisarts и проверьте право на zorgtoeslag.",
                    language
                )
            }
            return t(
                "Because you are not registered yet, start with municipality registration and BSN, then return to health insurance.",
                "Omdat je nog niet bent ingeschreven, begin met gemeente-inschrijving en BSN en kom daarna terug naar zorgverzekering.",
                "Так как вы ещё не зарегистрированы, начните с регистрации в gemeente и BSN, затем вернитесь к страховке.",
                language
            )
        case .bsnRegistration:
            if workflow.hasAddress == false {
                return t(
                    "Start by finding the municipality requirements for registration without a fixed address, then prepare ID and address evidence before booking.",
                    "Begin met de gemeente-eisen voor inschrijving zonder vast adres, bereid daarna ID en adresbewijs voor voordat je boekt.",
                    "Начните с требований gemeente для регистрации без постоянного адреса, затем подготовьте ID и подтверждение адреса перед записью.",
                    language
                )
            }
            if workflow.needsDigiD == true {
                return t(
                    "Book municipality registration for BSN first, bring required documents, then set up DigiD through the official source.",
                    "Boek eerst gemeente-inschrijving voor BSN, neem de vereiste documenten mee en regel daarna DigiD via de officiële bron.",
                    "Сначала запишитесь в gemeente для BSN, принесите нужные документы, затем оформите DigiD через официальный источник.",
                    language
                )
            }
            return t(
                "Book municipality registration for BSN and bring the documents requested by your gemeente.",
                "Boek gemeente-inschrijving voor BSN en neem de documenten mee die jouw gemeente vraagt.",
                "Запишитесь в gemeente для BSN и принесите документы, которые требует ваш муниципалитет.",
                language
            )
        case .digid:
            if workflow.hasBSN == true {
                return t(
                    "Use the official DigiD source, avoid links from messages, and keep recovery details safe.",
                    "Gebruik de officiële DigiD-bron, vermijd links uit berichten en bewaar herstelgegevens veilig.",
                    "Используйте официальный источник DigiD, избегайте ссылок из сообщений и храните данные восстановления безопасно.",
                    language
                )
            }
            return t(
                "Get BSN through municipality registration first, then return to DigiD setup.",
                "Regel eerst BSN via gemeente-inschrijving en kom daarna terug voor DigiD.",
                "Сначала получите BSN через регистрацию в gemeente, затем вернитесь к DigiD.",
                language
            )
        case .fineLetter:
            return t(
                "Verify the sender, check the deadline, avoid pasting personal numbers, and use official portals before paying or replying.",
                "Controleer de afzender, check de termijn, plak geen persoonlijke nummers en gebruik officiële portalen voordat je betaalt of reageert.",
                "Проверьте отправителя и срок, не вставляйте личные номера и используйте официальные порталы перед оплатой или ответом.",
                language
            )
        case .housing:
            return t(
                "Follow the housing route that matches your situation, watch for deposit scams, and use municipality or legal-help routes when registration or safety is involved.",
                "Volg de woonroute die bij je situatie past, let op borgfraude en gebruik gemeente- of juridische hulp bij inschrijving of veiligheid.",
                "Следуйте маршруту по жилью для вашей ситуации, остерегайтесь мошенничества с депозитом и используйте gemeente или юридическую помощь при регистрации или безопасности.",
                language
            )
        case .whatNext:
            let city = context.selectedCity.map { " \($0)" } ?? ""
            return t(
                "Your next safest step is based on your checklist, profile, saved items, and current city\(city). Open the first relevant guide and verify the official source before acting.",
                "Je veiligste volgende stap is gebaseerd op je checklist, profiel, opgeslagen items en huidige stad\(city). Open de eerste relevante gids en controleer de officiële bron voordat je handelt.",
                "Ваш следующий безопасный шаг основан на чеклисте, профиле, сохранённых элементах и текущем городе\(city). Откройте первый подходящий гид и проверьте официальный источник перед действием.",
                language
            )
        }
    }

    static func supportActions(for kind: AIWorkflowKind, language: AppLanguage, sources: [OfficialSource]) -> [AIResponseAction] {
        var actions: [AIResponseAction]
        switch kind {
        case .healthInsurance:
            actions = [
                .openGuide(title: t("Open Health Guide", "Open zorggids", "Открыть гид по медицине", language), destinationID: "healthcare"),
                .openScreen(title: t("Find Healthcare Nearby", "Zorg dichtbij zoeken", "Найти медицину рядом", language), destinationID: "mapFocus:healthcare"),
                .relatedTopic(t("Huisarts", "Huisarts", "Huisarts", language), query: "huisarts")
            ]
        case .bsnRegistration:
            actions = [
                .openScreen(title: t("Open Municipality", "Open gemeente", "Открыть gemeente", language), destinationID: "government"),
                .openScreen(title: t("Open Documents", "Open documenten", "Открыть документы", language), destinationID: "journeyDocuments"),
                .openGuide(title: t("Open BSN Guide", "Open BSN-gids", "Открыть гид BSN", language), destinationID: "article:documents:bsn")
            ]
        case .digid:
            actions = [
                .openScreen(title: t("Open Documents", "Open documenten", "Открыть документы", language), destinationID: "journeyDocuments"),
                .openGuide(title: t("Open DigiD Topic", "Open DigiD-topic", "Открыть тему DigiD", language), destinationID: "article:documents:digid"),
                .relatedTopic("BSN", query: "BSN")
            ]
        case .fineLetter:
            actions = [
                .openScreen(title: t("Open Fines", "Open boetes", "Открыть штрафы", language), destinationID: "fines"),
                .openScreen(title: t("Open Letters", "Open brieven", "Открыть письма", language), destinationID: "letters"),
                .openScreen(title: t("Open Official Sources", "Open officiële bronnen", "Открыть официальные источники", language), destinationID: "officialSources"),
                .relatedTopic(t("Scam Warnings", "Oplichting waarschuwingen", "Предупреждения о мошенничестве", language), query: "scam warning")
            ]
        case .housing:
            actions = [
                .openGuide(title: t("Open Housing Guide", "Open woongids", "Открыть гид по жилью", language), destinationID: "housing"),
                .openScreen(title: t("Open Municipality", "Open gemeente", "Открыть gemeente", language), destinationID: "government"),
                .relatedTopic(t("Scam Warnings", "Oplichting waarschuwingen", "Предупреждения о мошенничестве", language), query: "housing scam")
            ]
        case .whatNext:
            actions = [
                .openScreen(title: t("Open First Steps", "Open eerste stappen", "Открыть первые шаги", language), destinationID: "firstSteps"),
                .openScreen(title: t("Open Checklist", "Open checklist", "Открыть чеклист", language), destinationID: "checklist"),
                .openScreen(title: t("Open Search", "Open zoeken", "Открыть поиск", language), destinationID: "search")
            ]
        }

        if let source = sources.first, let url = source.url {
            actions.append(.openSource(title: t("Open Official Source", "Open officiële bron", "Открыть официальный источник", language), url: url))
        } else if let url = URL(string: "https://www.government.nl") {
            actions.append(.openSource(title: "Government.nl", url: url))
        }

        actions.append(.save(title: t("Save", "Bewaar", "Сохранить", language), itemID: "workflow:\(kind.rawValue)"))
        actions.append(.share(title: t("Share", "Deel", "Поделиться", language), itemID: "workflow:\(kind.rawValue)"))
        return actions
    }

    static func branchActions(for workflow: AIWorkflow, language: AppLanguage) -> [AIResponseAction] {
        switch workflow.kind {
        case .healthInsurance where workflow.isRegistered == false:
            return [
                .openScreen(title: t("Open Municipality", "Open gemeente", "Открыть gemeente", language), destinationID: "government"),
                .openScreen(title: t("Open Documents", "Open documenten", "Открыть документы", language), destinationID: "journeyDocuments"),
                .openGuide(title: t("Open BSN Guide", "Open BSN-gids", "Открыть гид BSN", language), destinationID: "article:documents:bsn")
            ]
        default:
            return []
        }
    }

    static func fallbackDestinationID(for kind: AIWorkflowKind) -> String {
        switch kind {
        case .healthInsurance: return "healthcare"
        case .bsnRegistration, .digid: return "journeyDocuments"
        case .fineLetter: return "fines"
        case .housing: return "housing"
        case .whatNext: return "firstSteps"
        }
    }

    static func visibleActions(_ actions: [AIResponseAction], context: AIContext) -> [AIResponseAction] {
        actions.filter { action in
            guard let destinationID = action.destinationID else { return true }
            return AppNavigationResolver.destination(for: destinationID) != nil
        }
    }

    static func visibleDestinationID(_ destinationID: String?, context: AIContext) -> String {
        if let destinationID,
           AppNavigationResolver.destination(for: destinationID) != nil {
            return destinationID
        }
        return "search"
    }

    static func yesNoActions(yes: String, no: String, yesQuery: String, noQuery: String) -> [AIResponseAction] {
        [
            AIResponseAction(kind: .askFollowUp, title: yes, query: yesQuery),
            AIResponseAction(kind: .askFollowUp, title: no, query: noQuery)
        ]
    }

    static func yesNo(_ normalized: String) -> Bool? {
        if normalized.contains("no") || normalized.contains("nee") || normalized.contains("нет") || normalized.contains("not") || normalized.contains("geen") {
            return false
        }
        if normalized.contains("yes") || normalized.contains("ja") || normalized.contains("да") || normalized.contains("work") || normalized.contains("registered") || normalized.contains("address") || normalized.contains("bsn") || normalized.contains("digid") {
            return true
        }
        return nil
    }

    static func choiceValue(_ normalized: String) -> String? {
        if normalized.contains("fine") || normalized.contains("cjib") || normalized.contains("boete") || normalized.contains("штраф") { return "fine CJIB" }
        if normalized.contains("tax") || normalized.contains("belasting") || normalized.contains("налог") { return "tax" }
        if normalized.contains("unknown") || normalized.contains("onbekend") || normalized.contains("неизвест") { return "unknown sender" }
        if normalized.contains("looking") || normalized.contains("zoek") || normalized.contains("ищ") { return "looking housing" }
        if normalized.contains("rental") || normalized.contains("huur") || normalized.contains("аренд") { return "rental problem" }
        if normalized.contains("registration") || normalized.contains("inschrijf") || normalized.contains("регистрац") { return "registration issue" }
        return nil
    }

    static func deduplicateActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
        var seen = Set<String>()
        return actions.filter { action in
            let key = [action.kind.rawValue, action.destinationID ?? "", action.url?.absoluteString ?? "", action.itemID ?? "", action.query ?? "", action.title].joined(separator: "|")
            return seen.insert(key).inserted
        }
    }

    static func prioritizedActions(_ actions: [AIResponseAction]) -> [AIResponseAction] {
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

    static func deduplicateSources(_ sources: [OfficialSource]) -> [OfficialSource] {
        var seen = Set<String>()
        return sources.filter { source in
            let key = "\(source.title)|\(source.url?.absoluteString ?? "")"
            return seen.insert(key).inserted
        }
    }

    static func checklistScore(_ item: ChecklistItem, context: AIContext) -> Int {
        var score = 0
        switch item.priority {
        case .high: score += 100
        case .medium: score += 50
        case .low: score += 10
        }
        if let dueDate = item.dueDate {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 999
            if days <= 7 { score += 40 }
            else if days <= 14 { score += 25 }
            else if days <= 30 { score += 12 }
        }
        if item.category == .registration { score += 20 }
        if item.title(.english).localizedCaseInsensitiveContains("BSN") { score += 18 }
        if item.title(.english).localizedCaseInsensitiveContains("DigiD") { score += 12 }
        let routeID = "checklist:\(item.id.uuidString)"
        if context.currentRouteID == routeID { score -= 80 }
        if context.recentRouteIDs.contains(routeID) { score -= 35 }
        if context.savedItemIDs.contains(routeID) || context.savedItemIDs.contains("checklist:\(item.id.uuidString.lowercased())") { score -= 15 }
        if context.savedItemKinds.contains("document"), [.documents, .registration].contains(item.category) { score += 6 }
        if context.savedItemKinds.contains("institution"), item.category == .registration { score += 4 }
        if context.lastSearches.contains(where: { item.title(.english).localizedCaseInsensitiveContains($0) || $0.localizedCaseInsensitiveContains(item.title(.english)) }) {
            score += 10
        }
        return score
    }

    static func matchesHealthInsurance(_ normalized: String) -> Bool {
        normalized.contains("health insurance") || normalized.contains("zorgverzekering") || normalized.contains("insurance")
    }

    static func matchesBSN(_ normalized: String) -> Bool {
        normalized.contains("bsn") || normalized.contains("municipality registration") || normalized.contains("gemeente registration") || normalized.contains("register in gemeente")
    }

    static func matchesDigiD(_ normalized: String) -> Bool {
        normalized.contains("digid")
    }

    static func matchesLetterOrFine(_ normalized: String) -> Bool {
        normalized.contains("cjib") || normalized.contains("fine") || normalized.contains("government letter") || normalized.contains("letter") || normalized.contains("boete")
    }

    static func matchesHousing(_ normalized: String) -> Bool {
        normalized.contains("housing") || normalized.contains("rent") || normalized.contains("rental") || normalized.contains("woning") || normalized.contains("huur")
    }

    static func matchesWhatNext(_ normalized: String) -> Bool {
        normalized.contains("what should i do next") || normalized.contains("what next") || normalized.contains("next step") || normalized.contains("wat nu")
    }

    static func t(_ english: String, _ dutch: String, _ russian: String, _ language: AppLanguage) -> String {
        switch language {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}
