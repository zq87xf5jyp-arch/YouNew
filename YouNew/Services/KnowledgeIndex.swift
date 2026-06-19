import Foundation

nonisolated enum KnowledgeNormalizer {
    static func normalize(_ value: String) -> String {
        var normalized = value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()

        let synonyms: [String: String] = [
            "бсн": "bsn",
            "номер bsn": "bsn",
            "дигид": "digid",
            "регистрация": "registration",
            "муниципалитет": "municipality",
            "gemeente": "municipality",
            "zorgverzekering": "health insurance",
            "медстраховка": "health insurance",
            "страховка": "insurance",
            "врач": "huisarts",
            "huis arts": "huisarts",
            "boete": "fine",
            "штраф": "fine",
            "belasting": "tax",
            "налог": "tax",
            "toeslagen": "allowances",
            "huur": "rent",
            "жилье": "housing",
            "жильё": "housing",
            "fiets": "bicycle",
            "велосипед": "bicycle",
            "werk": "work",
            "работа": "work"
        ]

        for (source, target) in synonyms {
            normalized = normalized.replacingOccurrences(of: source, with: target)
        }

        return normalized
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    static func slug(_ value: String) -> String {
        normalize(value).replacingOccurrences(of: " ", with: "-")
    }
}

struct KnowledgeIndex {
    let items: [KnowledgeItem]
    let graph: KnowledgeGraph
    let itemsByID: [String: KnowledgeItem]
    private let searchableTextByID: [String: String]
    private let normalizedProvinceEnglishByName: [String: String]

    init(items: [KnowledgeItem]) {
        self.items = items
        self.itemsByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        self.graph = KnowledgeGraph.build(for: items)
        self.searchableTextByID = Dictionary(uniqueKeysWithValues: items.map { item in
            let text = [
                item.title(.english),
                item.summary(.english),
                item.category,
                item.city,
                item.province,
                item.keywords.joined(separator: " "),
                item.sources.map(\.title).joined(separator: " ")
            ]
            .compactMap { $0 }
            .joined(separator: " ")
            return (item.id, KnowledgeNormalizer.normalize(text))
        })
        self.normalizedProvinceEnglishByName = Dictionary(uniqueKeysWithValues: NLProvince.all.map { province in
            (province.name, KnowledgeNormalizer.normalize(province.nameEN))
        })
    }

    static let shared = KnowledgeIndex(items: KnowledgeIndexBuilder.buildItems())

    static func prewarmShared() {
        DispatchQueue.global(qos: .utility).async {
            _ = KnowledgeIndex.shared.items.count
        }
    }

    func search(
        _ query: String,
        language: AppLanguage,
        context: AIContext? = nil,
        activePersona: PersonaTag? = nil,
        scope: PersonaSearchScope = .currentAndUniversal,
        limit: Int = 8
    ) -> [KnowledgeSearchResult] {
        let normalizedQuery = KnowledgeNormalizer.normalize(query)
        guard !normalizedQuery.isEmpty else { return [] }
        let queryTokens = normalizedQuery.split(separator: " ").map(String.init)
        let contextCity = context?.selectedCity
        let contextProvince = context?.selectedProvince
        let persona = activePersona ?? context?.activePersonaTag
        let searchScope = context?.personaSearchScope ?? scope
        if searchScope != .allContentWithOutsidePathWarning,
           PersonaContentPolicy.isOutsidePersonaQuery(query, for: persona) {
            return []
        }

        let scored = items.compactMap { item -> (KnowledgeItem, Double, [String])? in
            guard item.isVisible(for: persona, scope: searchScope) else { return nil }

            let text = searchableTextByID[item.id] ?? ""
            let phraseMatched = text.contains(normalizedQuery)
            var matchedTokenCount = 0
            for token in queryTokens where text.contains(token) {
                matchedTokenCount += 1
            }
            guard matchedTokenCount > 0 || phraseMatched else { return nil }

            var score = 0.0
            var fields: [String] = []

            if phraseMatched {
                score += 82
                fields.append("text")
            }

            if matchedTokenCount > 0 {
                score += Double(matchedTokenCount) * 12
                fields.append("tokens")
            }

            let normalizedTitle = KnowledgeNormalizer.normalize(item.title(.english))
            if normalizedTitle == normalizedQuery {
                score += 140
                fields.append("exact-title")
            } else if !normalizedTitle.isEmpty, normalizedQuery.contains(normalizedTitle) {
                score += 80
                fields.append("title")
            }

            if item.type == .city,
               let city = item.city {
                let normalizedCity = KnowledgeNormalizer.normalize(city)
                if normalizedCity == normalizedQuery || normalizedQuery.contains(normalizedCity) {
                    score += 140
                    fields.append("city-entity")
                }
            }

            if item.type == .province,
               let province = item.province {
                let normalizedProvince = KnowledgeNormalizer.normalize(province)
                let normalizedProvinceEnglish = normalizedProvinceEnglishByName[province]
                if normalizedProvince == normalizedQuery
                    || normalizedQuery.contains(normalizedProvince)
                    || normalizedProvinceEnglish.map({ $0 == normalizedQuery || normalizedQuery.contains($0) }) == true {
                    score += 140
                    fields.append("province-entity")
                }
            }

            let tags = item.effectivePersonaTags(language: language)
            if let persona {
                if tags.contains(persona) {
                    score += 40
                    fields.append("persona")
                } else if tags.contains(.universal) {
                    score += 8
                    fields.append("universal")
                } else if searchScope == .allContentWithOutsidePathWarning {
                    score -= 18
                    fields.append("outside-persona")
                }
            }

            if let city = contextCity,
               let itemCity = item.city,
               itemCity.caseInsensitiveCompare(city) == .orderedSame {
                score += 16
                fields.append("city")
            }

            if let province = contextProvince,
               let itemProvince = item.province,
               itemProvince.caseInsensitiveCompare(province) == .orderedSame {
                score += 10
                fields.append("province")
            }

            guard score > 0 else { return nil }
            return (item, score, fields)
        }

        return scored
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.title(language) < rhs.0.title(language)
                }
                return lhs.1 > rhs.1
            }
            .prefix(limit)
            .map { item, score, fields in
                let visibleNeighbors = graph.neighbors(of: item.id, in: itemsByID)
                    .filter { $0.isVisible(for: persona, scope: searchScope) }
                return KnowledgeSearchResult(
                    item: item,
                    score: score,
                    matchedFields: fields,
                    graphNeighbors: visibleNeighbors,
                    quickActions: KnowledgeIndexBuilder.quickActions(for: item)
                )
            }
    }
}

enum KnowledgeIndexBuilder {
    static func buildItems() -> [KnowledgeItem] {
        var items: [KnowledgeItem] = []
        items += appScreens()
        items += knowledgeTopics()
        items += lifeScenarios()
        items += officialServices()
        items += documents()
        items += municipalities()
        items += reminders()
        items += survivalGuide()
        items += beginnerGuides()
        items += guideContent()
        items += checklist()
        items += fines()
        items += institutions()
        items += dutchTerms()
        items += letters()
        items += mistakes()
        items += risks()
        items += rules()
        items += scamWarnings()
        items += legalInfo()
        items += dailyLife()
        items += lgbtqSupport()
        items += nearbyPlaces()
        items += resources()
        items += knmModules()
        items += dutchCourseModules()
        items += searchAnswers()
        items += provinces()
        items += cities()

        var seen = Set<String>()
        return items.filter { seen.insert($0.id).inserted }
    }

    static func quickActions(for item: KnowledgeItem) -> [AIQuickAction] {
        var actions: [AIQuickAction] = []
        if let route = item.route {
            switch item.type {
            case .guide, .article, .topic, .scenario:
                actions.append(.openGuide(route))
            case .city:
                actions.append(.openCity(item.city ?? item.title(.english)))
            case .province:
                actions.append(.openProvince(item.province ?? item.title(.english)))
            default:
                actions.append(.openScreen(route))
            }
        }
        if let url = item.sources.compactMap(\.url).first {
            actions.append(.openSource(url))
        }
        actions.append(.save(item.id))
        actions.append(.share(item.id))
        return actions
    }

    private static func appScreens() -> [KnowledgeItem] {
        [
            screen("screen:search", "Search", "Find guides, answers, cities, provinces, documents, and official sources.", "search", .searchList, tags: [.universal]),
            screen("screen:officialSources", "Official Sources", "Verified government and institution links.", "official sources", .officialSources, tags: [.universal]),
            screen("screen:journeyDocuments", "Documents", "Organize important Dutch documents and registration proof.", "documents", .journeyDocuments, tags: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("screen:assistant", "AI Assistant", "Ask contextual questions, explain screens, search app knowledge, and start guided workflows.", "assistant", .assistantHub, tags: [.universal]),
            screen("screen:cities", "Cities", "Open Dutch city pages with newcomer services, local context, and city-specific guidance.", "cities", .cityList, tags: [.student, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]),
            screen("screen:provinces", "Provinces", "Open province pages with regional context, cities, and useful newcomer information.", "provinces", .provinceList, tags: [.student, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]),
            screen("screen:fines", "Fines and Rules", "Understand fines, rules, warnings, official letters, and safe next steps.", "fines", .finesList, tags: [.worker, .tourist, .entrepreneur, .eu, .highlySkilledMigrant]),
            screen("screen:letters", "Letters", "Recognize Dutch official letters, deadlines, senders, and verification steps.", "letters", .lettersList, tags: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("screen:institutions", "Institutions", "Find Dutch institutions such as IND, UWV, DUO, CJIB, and Belastingdienst.", "institutions", .institutionsList, tags: [.universal]),
            screen("screen:settings", "Settings", "Manage app language, navigation preferences, privacy, and support options.", "settings", .settings, tags: [.universal]),
            screen("screen:knm", "KNM", "Study Knowledge of Dutch Society modules for integration and daily life.", "language", .knm, tags: [.refugee, .nonEU, .family, .lgbt]),
            screen("screen:dutch", "Dutch A1-A2", "Learn beginner Dutch vocabulary, grammar, phrases, and practice modules.", "language", .dutchA1A2, tags: [.student, .refugee, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("screen:healthinsurance", "Health Insurance", "Understand Dutch health insurance, registration dependencies, huisarts, and official checks.", "healthcare", .practicalGuide(.healthInsuranceBasics), tags: [.student, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("screen:huisarts", "Huisarts", "Find and register with a GP, understand urgent care, and connect healthcare steps.", "healthcare", .practicalGuide(.findingHuisarts), tags: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("hub:government", "Government", "Gemeente, IND, UWV, taxes, and official procedures.", "government", .governmentHub, tags: [.worker, .refugee, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("hub:help", "Help", "Practical help hubs for newcomer issues.", "help", .helpHub, tags: [.refugee, .family, .tourist, .lgbt, .nonEU]),
            screen("hub:languagehub", "Language", "Dutch A1-A2, KNM, and language support.", "language", .languageHub, tags: [.student, .refugee, .worker, .family, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt]),
            screen("screen:map", "Map", "Find nearby services and city help.", "map", .mapHub, tags: [.universal]),
            screen("screen:emergency", "Emergency", "112, police, urgent healthcare, and crisis support.", "emergency", .emergencyHub, tags: [.student, .worker, .refugee, .family, .tourist, .entrepreneur, .eu, .nonEU, .highlySkilledMigrant, .lgbt])
        ]
    }

    private static func screen(_ id: String, _ title: String, _ summary: String, _ category: String, _ route: AppDestination, tags: Set<PersonaTag>) -> KnowledgeItem {
        KnowledgeItem(
            id: id,
            type: .appScreen,
            title: LocalizedKnowledgeText(title),
            summary: LocalizedKnowledgeText(summary),
            category: category,
            city: nil,
            province: nil,
            keywords: [title, category, summary],
            route: route,
            routeID: AppDestination.aiRouteID(from: route),
            sources: [],
            lastReviewed: nil,
            safetyLevel: .general,
            sourcePath: "YouNew/Models/AppDestination.swift",
            personaTags: tags
        )
    }

    private static func knowledgeTopics() -> [KnowledgeItem] {
        MockExpansionData.knowledgeTopics.map { topic in
            KnowledgeItem(
                id: "topic:\(KnowledgeNormalizer.slug(topic.title))",
                type: .topic,
                title: LocalizedKnowledgeText(topic.title),
                summary: LocalizedKnowledgeText(topic.summary),
                category: topic.category,
                city: nil,
                province: nil,
                keywords: topic.tags + topic.relatedQuestions + topic.practicalSteps + topic.commonMistakes,
                route: routeFor(category: topic.category, title: topic.title),
                routeID: routeFor(category: topic.category, title: topic.title).flatMap(AppDestination.aiRouteID(from:)),
                sources: [OfficialSource(title: topic.officialSourceName, url: topic.officialSourceURL, institution: topic.officialSourceName)],
                lastReviewed: topic.lastReviewed,
                safetyLevel: safetyLevel(for: topic.category),
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: topic.personaTags
            )
        }
    }

    private static func lifeScenarios() -> [KnowledgeItem] {
        MockExpansionData.lifeScenarios.map { scenario in
            KnowledgeItem(
                id: "scenario:\(KnowledgeNormalizer.slug(scenario.title))",
                type: .scenario,
                title: LocalizedKnowledgeText(scenario.title),
                summary: LocalizedKnowledgeText(scenario.situation),
                category: "Workflow",
                city: nil,
                province: nil,
                keywords: scenario.firstActions + scenario.documentsToPrepare + scenario.relatedTopics,
                route: .firstSteps,
                routeID: "firstSteps",
                sources: [OfficialSource(title: scenario.officialSourceName, url: scenario.officialSourceURL, institution: scenario.officialSourceName)],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: scenario.personaTags
            )
        }
    }

    private static func officialServices() -> [KnowledgeItem] {
        MockExpansionData.officialServices.map { service in
            KnowledgeItem(
                id: "source:\(KnowledgeNormalizer.slug(service.name))",
                type: .officialService,
                title: LocalizedKnowledgeText(service.name),
                summary: LocalizedKnowledgeText("\(service.purpose) \(service.whenToUse)"),
                category: "Official Service",
                city: nil,
                province: nil,
                keywords: service.tags + [service.domain, service.purpose, service.whenToUse],
                route: .officialSources,
                routeID: "officialSources",
                sources: [OfficialSource(title: service.name, url: service.officialURL, institution: service.name)],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: service.personaTags
            )
        }
    }

    private static func documents() -> [KnowledgeItem] {
        MockExpansionData.documents.map { document in
            KnowledgeItem(
                id: "documentReference:\(KnowledgeNormalizer.slug(document.title))",
                type: .document,
                title: LocalizedKnowledgeText(document.title),
                summary: LocalizedKnowledgeText(document.note),
                category: document.category,
                city: nil,
                province: nil,
                keywords: [document.title, document.category, document.note] + document.tags,
                route: .journeyDocuments,
                routeID: "journeyDocuments",
                sources: [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: document.personaTags
            )
        }
    }

    private static func municipalities() -> [KnowledgeItem] {
        MockExpansionData.municipalities.map { municipality in
            KnowledgeItem(
                id: "municipality:\(KnowledgeNormalizer.slug(municipality.name))",
                type: .officialService,
                title: LocalizedKnowledgeText(municipality.name),
                summary: LocalizedKnowledgeText(municipality.registrationInfo),
                category: "Municipality",
                city: municipality.name,
                province: nil,
                keywords: [municipality.name, municipality.registrationInfo, municipality.wasteGuide, municipality.parkingBasics, municipality.emergencyContact],
                route: .mapFocus(.government),
                routeID: nil,
                sources: [
                    OfficialSource(title: "\(municipality.name) municipality", url: municipality.website, institution: municipality.name),
                    OfficialSource(title: "\(municipality.name) appointment page", url: municipality.appointmentPage, institution: municipality.name)
                ],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockExpansionData.swift"
            )
        }
    }

    private static func reminders() -> [KnowledgeItem] {
        MockExpansionData.reminders.map { reminder in
            KnowledgeItem(
                id: "reminder:\(KnowledgeNormalizer.slug(reminder.title))",
                type: .deadline,
                title: LocalizedKnowledgeText(reminder.title),
                summary: LocalizedKnowledgeText(reminder.detail),
                category: reminder.category.rawValue,
                city: nil,
                province: nil,
                keywords: [reminder.title, reminder.detail, reminder.category.rawValue, reminder.urgency.rawValue],
                route: routeFor(category: reminder.category.rawValue, title: reminder.title),
                routeID: routeFor(category: reminder.category.rawValue, title: reminder.title).flatMap(AppDestination.aiRouteID(from:)),
                sources: [],
                lastReviewed: nil,
                safetyLevel: reminder.urgency == .high ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: reminder.personaTags
            )
        }
    }

    private static func survivalGuide() -> [KnowledgeItem] {
        MockExpansionData.survivalGuide.map { item in
            KnowledgeItem(
                id: "survival:\(KnowledgeNormalizer.slug(item.title))",
                type: .guide,
                title: LocalizedKnowledgeText(item.title),
                summary: LocalizedKnowledgeText(item.detailText),
                category: "Survival",
                city: nil,
                province: nil,
                keywords: [item.title, item.shortText, item.detailText],
                route: .survivalHub,
                routeID: nil,
                sources: [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockExpansionData.swift",
                personaTags: item.personaTags
            )
        }
    }

    private static func beginnerGuides() -> [KnowledgeItem] {
        MockBeginnerGuidesData.items.map { guide in
            KnowledgeItem(
                id: "beginnerGuide:\(guide.id.uuidString)",
                type: .guide,
                title: LocalizedKnowledgeText(values: guide.titleByLanguage),
                summary: LocalizedKnowledgeText(values: guide.simpleAnswerByLanguage),
                category: guide.category.rawValue,
                city: nil,
                province: nil,
                keywords: guide.keywords(.english) + guide.relatedTopics + guide.whatToCheck(.english),
                route: .beginnerGuide(guide.id),
                routeID: nil,
                sources: [OfficialSource(title: guide.officialSourceName, url: guide.officialSourceURL, institution: guide.officialSourceName)],
                lastReviewed: guide.lastUpdated,
                safetyLevel: guide.riskLevel == .high ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockBeginnerGuidesData.swift"
            )
        }
    }

    private static func guideContent() -> [KnowledgeItem] {
        var items: [KnowledgeItem] = []
        for section in GuideContent.sections {
            items.append(KnowledgeItem(
                id: "guide:\(section.id)",
                type: .guide,
                title: LocalizedKnowledgeText(section.titleEN ?? section.title),
                summary: LocalizedKnowledgeText(section.subtitleEN ?? section.subtitle),
                category: section.id,
                city: nil,
                province: nil,
                keywords: [section.title, section.subtitle, section.id],
                route: .guideSection(section.id),
                routeID: nil,
                sources: [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Views/GuideContentView.swift"
            ))

            for article in section.articles {
                let sources = article.links.compactMap { link -> OfficialSource? in
                    guard let url = AppURL.validatedWebURL(URL(string: link.urlString)) else { return nil }
                    return OfficialSource(title: link.title, url: url, institution: link.institution)
                }
                items.append(KnowledgeItem(
                    id: "article:\(section.id):\(article.id)",
                    type: .article,
                    title: LocalizedKnowledgeText(article.titleEN ?? article.title),
                    summary: LocalizedKnowledgeText(article.summaryEN ?? article.summary),
                    category: section.id,
                    city: nil,
                    province: nil,
                    keywords: [article.title, article.summary, section.title, section.id] + article.links.map(\.title),
                    route: .guideArticle(sectionID: section.id, articleID: article.id),
                    routeID: nil,
                    sources: sources,
                    lastReviewed: nil,
                    safetyLevel: article.isOfficial ? .officialSourceRequired : .officialSourceRecommended,
                    sourcePath: "YouNew/Views/GuideContentView.swift"
                ))
            }
        }
        return items
    }

    private static func checklist() -> [KnowledgeItem] {
        MockChecklistData.items.map { item in
            KnowledgeItem(
                id: "checklist:\(item.id.uuidString)",
                type: .checklist,
                title: LocalizedKnowledgeText(values: item.titleByLanguage),
                summary: LocalizedKnowledgeText(values: item.descriptionByLanguage),
                category: item.category.rawValue,
                city: nil,
                province: nil,
                keywords: [
                    item.title(.english),
                    item.description(.english),
                    item.suggestedTiming(.english),
                    item.category.rawValue,
                    item.priority.rawValue
                ] + item.relatedInstitutionNames,
                route: .checklist(item.id),
                routeID: nil,
                sources: [OfficialSource(title: item.officialSourceName, url: item.officialSourceURL, institution: item.officialSourceName)],
                lastReviewed: nil,
                safetyLevel: item.priority == .high ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockChecklistData.swift",
                personaTags: item.personaTags
            )
        }
    }

    private static func fines() -> [KnowledgeItem] {
        MockFineInfoData.items.map { fine in
            KnowledgeItem(
                id: "fine:\(fine.id.uuidString)",
                type: .fine,
                title: LocalizedKnowledgeText(values: fine.titleByLanguage),
                summary: LocalizedKnowledgeText(values: fine.simpleExplanationByLanguage),
                category: fine.category.rawValue,
                city: nil,
                province: nil,
                keywords: [
                    fine.title(.english),
                    fine.simpleExplanation(.english),
                    fine.possibleConsequence(.english),
                    fine.userAction(.english),
                    fine.category.rawValue,
                    fine.severity.rawValue
                ] + fine.relatedInstitutionNames,
                route: .fineInfo(fine.id),
                routeID: nil,
                sources: [OfficialSource(title: fine.officialSourceName, url: fine.officialSourceURL, institution: fine.officialSourceName)],
                lastReviewed: fine.lastUpdated,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockFineInfoData.swift",
                personaTags: fine.personaTags
            )
        }
    }

    private static func institutions() -> [KnowledgeItem] {
        MockInstitutionsData.items.map { institution in
            KnowledgeItem(
                id: "institution:\(KnowledgeNormalizer.slug(institution.name))",
                type: .institution,
                title: LocalizedKnowledgeText(institution.name),
                summary: LocalizedKnowledgeText(institution.shortExplanation(.english)),
                category: "Institution",
                city: nil,
                province: nil,
                keywords: [
                    institution.name,
                    institution.shortExplanation(.english),
                    institution.usage(.english),
                    institution.whenToUse(.english),
                    institution.commonConfusion(.english),
                    institution.warning(.english)
                ],
                route: .institution(institution.name),
                routeID: nil,
                sources: [OfficialSource(title: institution.name, url: institution.officialWebsiteURL, institution: institution.name)],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockInstitutionsData.swift",
                personaTags: institution.personaTags
            )
        }
    }

    private static func dutchTerms() -> [KnowledgeItem] {
        MockDutchTermsData.items.map { term in
            KnowledgeItem(
                id: "dutchTerm:\(term.id.uuidString)",
                type: .dutchTerm,
                title: LocalizedKnowledgeText(term.dutchTerm),
                summary: LocalizedKnowledgeText(
                    term.localizedNewcomerExplanation(.english),
                    dutch: term.localizedNewcomerExplanation(.dutch),
                    russian: term.localizedNewcomerExplanation(.russian)
                ),
                category: term.category.rawValue,
                city: nil,
                province: nil,
                keywords: [
                    term.dutchTerm,
                    term.englishExplanation,
                    term.newcomerExplanation,
                    term.category.rawValue
                ] + term.relatedInstitutionNames + term.relatedLetterTitles,
                route: .dutchTerm(term.id),
                routeID: nil,
                sources: term.officialSourceURL.map { [OfficialSource(title: term.officialSourceName ?? term.dutchTerm, url: $0, institution: term.officialSourceName)] } ?? [],
                lastReviewed: nil,
                safetyLevel: term.hasLegalFinancialWarning ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockDutchTermsData.swift",
                personaTags: term.personaTags
            )
        }
    }

    private static func letters() -> [KnowledgeItem] {
        MockLettersData.examples.map { letter in
            KnowledgeItem(
                id: "letter:\(KnowledgeNormalizer.slug(letter.title))",
                type: .letter,
                title: LocalizedKnowledgeText(values: letter.titleByLanguage),
                summary: LocalizedKnowledgeText(values: letter.simplifiedExplanationByLanguage),
                category: "Letter",
                city: nil,
                province: nil,
                keywords: [
                    letter.title(.english),
                    letter.institutionName(.english),
                    letter.possibleDeadline(.english),
                    letter.safeNextStep(.english),
                    letter.officialSourceReminder(.english)
                ] + letter.relatedInstitutionNames,
                route: .letter(letter.title),
                routeID: nil,
                sources: [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockLettersData.swift",
                personaTags: letter.personaTags
            )
        }
    }

    private static func mistakes() -> [KnowledgeItem] {
        MockNewcomerMistakesData.items.map { mistake in
            KnowledgeItem(
                id: "mistake:\(mistake.id.uuidString)",
                type: .mistake,
                title: LocalizedKnowledgeText(values: mistake.titleByLanguage),
                summary: LocalizedKnowledgeText(values: mistake.whyItMattersByLanguage),
                category: mistake.category.rawValue,
                city: nil,
                province: nil,
                keywords: [
                    mistake.title(.english),
                    mistake.whyItMatters(.english),
                    mistake.possibleConsequence(.english),
                    mistake.howToPrevent(.english),
                    mistake.category.rawValue,
                    mistake.riskLevel.rawValue
                ],
                route: .mistake(mistake.id),
                routeID: nil,
                sources: mistake.officialSourceURL.map { [OfficialSource(title: mistake.officialSourceName ?? "Official source", url: $0, institution: mistake.officialSourceName)] } ?? [],
                lastReviewed: nil,
                safetyLevel: mistake.riskLevel == .high ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockNewcomerMistakesData.swift",
                personaTags: mistake.personaTags
            )
        }
    }

    private static func risks() -> [KnowledgeItem] {
        MockRiskData.items.map { risk in
            KnowledgeItem(
                id: "risk:\(KnowledgeNormalizer.slug(risk.title))",
                type: .risk,
                title: LocalizedKnowledgeText(values: risk.titleByLanguage),
                summary: LocalizedKnowledgeText(values: risk.possibleIssueByLanguage),
                category: risk.section.rawValue,
                city: nil,
                province: nil,
                keywords: [risk.title(.english), risk.possibleIssue(.english), risk.possibleConsequence(.english), risk.verifyRule(.english), risk.section.rawValue],
                route: .survivalHub,
                routeID: nil,
                sources: [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockRiskData.swift",
                personaTags: risk.personaTags
            )
        }
    }

    private static func rules() -> [KnowledgeItem] {
        let topics = MockRulesGuideData.topics.map { rule in
            KnowledgeItem(
                id: "rule:\(rule.id.uuidString)",
                type: .rule,
                title: LocalizedKnowledgeText(rule.title),
                summary: LocalizedKnowledgeText(rule.rule),
                category: rule.category,
                city: nil,
                province: nil,
                keywords: [rule.title, rule.rule, rule.reason, rule.commonMistake, rule.estimatedFineRange, rule.approximateFine, rule.consequence, rule.authority, rule.alreadyFinedAction, rule.realLifeExample, rule.avoidWarning] + rule.relatedTopics,
                route: .ruleTopic(rule.id),
                routeID: nil,
                sources: [OfficialSource(title: rule.officialSourceName, url: rule.officialSourceURL, institution: rule.authority)],
                lastReviewed: nil,
                safetyLevel: rule.severity == .high || rule.severity == .critical ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockRulesGuideData.swift",
                personaTags: rule.personaTags
            )
        }

        let scenarios = MockRulesGuideData.scenarios.map { scenario in
            KnowledgeItem(
                id: "ruleScenario:\(scenario.id.uuidString)",
                type: .scenario,
                title: LocalizedKnowledgeText(scenario.title),
                summary: LocalizedKnowledgeText(scenario.meaning),
                category: "Rule Scenario",
                city: nil,
                province: nil,
                keywords: [scenario.title, scenario.meaning, scenario.doNotPanic, scenario.institution] + scenario.nextSteps,
                route: .ruleScenario(scenario.id),
                routeID: nil,
                sources: [OfficialSource(title: scenario.institution, url: scenario.officialSourceURL, institution: scenario.institution)],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockRulesGuideData.swift",
                personaTags: scenario.personaTags
            )
        }

        return topics + scenarios
    }

    private static func scamWarnings() -> [KnowledgeItem] {
        MockScamWarningsData.items.map { scam in
            KnowledgeItem(
                id: "scam:\(scam.id.uuidString)",
                type: .risk,
                title: LocalizedKnowledgeText(scam.title),
                summary: LocalizedKnowledgeText(scam.howItWorks),
                category: scam.category.rawValue,
                city: nil,
                province: nil,
                keywords: [scam.title, scam.category.rawValue, scam.howItWorks, scam.whatToDo, scam.reportTo] + scam.warningSignals,
                route: .scamWarning(scam.id),
                routeID: nil,
                sources: scam.reportURL.map { [OfficialSource(title: scam.reportTo, url: $0, institution: scam.reportTo)] } ?? [],
                lastReviewed: nil,
                safetyLevel: .officialSourceRequired,
                sourcePath: "YouNew/Data/MockScamWarningsData.swift",
                personaTags: scam.personaTags
            )
        }
    }

    private static func legalInfo() -> [KnowledgeItem] {
        MockLegalInfoData.items.map { item in
            KnowledgeItem(
                id: "legal:\(item.id.uuidString)",
                type: .article,
                title: LocalizedKnowledgeText(item.title(.english), dutch: item.title(.dutch), russian: item.title(.russian)),
                summary: LocalizedKnowledgeText(item.shortSummary(.english), dutch: item.shortSummary(.dutch), russian: item.shortSummary(.russian)),
                category: item.category.rawValue,
                city: nil,
                province: nil,
                keywords: [item.title(.english), item.shortSummary(.english), item.beginnerExplanation(.english), item.category.rawValue, item.relatedInstitution ?? ""] + item.keywords,
                route: routeFor(category: item.category.rawValue, title: item.title(.english)),
                routeID: routeFor(category: item.category.rawValue, title: item.title(.english)).flatMap(AppDestination.aiRouteID(from:)),
                sources: item.officialSourceURL.map { [OfficialSource(title: item.officialSourceName, url: $0, institution: item.relatedInstitution ?? item.officialSourceName)] } ?? [],
                lastReviewed: item.lastUpdated,
                safetyLevel: item.riskLevel == .high || item.riskLevel == .urgent ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockLegalInfoData.swift",
                personaTags: item.personaTags
            )
        }
    }

    private static func dailyLife() -> [KnowledgeItem] {
        MockDailyLifeData.items.map { tip in
            KnowledgeItem(
                id: "dailyLife:\(tip.id.uuidString)",
                type: .guide,
                title: LocalizedKnowledgeText(tip.title),
                summary: LocalizedKnowledgeText(tip.summary),
                category: tip.category.rawValue,
                city: nil,
                province: nil,
                keywords: [tip.title, tip.summary, tip.detail, tip.practicalTip, tip.category.rawValue],
                route: routeFor(category: tip.category.rawValue, title: tip.title),
                routeID: routeFor(category: tip.category.rawValue, title: tip.title).flatMap(AppDestination.aiRouteID(from:)),
                sources: tip.officialSourceURL.map { [OfficialSource(title: tip.officialSourceName ?? "Official source", url: $0, institution: tip.officialSourceName)] } ?? [],
                lastReviewed: nil,
                safetyLevel: tip.officialSourceURL == nil ? .general : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockDailyLifeData.swift",
                personaTags: tip.personaTags
            )
        }
    }

    private static func lgbtqSupport() -> [KnowledgeItem] {
        MockLGBTQSupportData.items.map { item in
            KnowledgeItem(
                id: "lgbtq:\(KnowledgeNormalizer.slug(item.id))",
                type: .resource,
                title: LocalizedKnowledgeText(item.title),
                summary: LocalizedKnowledgeText(item.description(.english), dutch: item.description(.dutch)),
                category: item.category.title(.english),
                city: item.city,
                province: nil,
                keywords: [item.title, item.descriptionEN, item.descriptionNL, item.city, item.section.title(.english), item.category.title(.english), item.organizer ?? "", item.publicTransportInfoEN ?? "", item.openingHoursEN ?? ""] + item.accessibilityTags + item.keywords,
                route: .lgbtqSupport,
                routeID: nil,
                sources: item.websiteURL.map { [OfficialSource(title: item.organizer ?? item.title, url: $0, institution: item.organizer)] } ?? [],
                lastReviewed: nil,
                safetyLevel: item.isTrusted ? .officialSourceRecommended : .general,
                sourcePath: "YouNew/Data/MockLGBTQSupportData.swift",
                personaTags: item.personaTags
            )
        }
    }

    private static func nearbyPlaces() -> [KnowledgeItem] {
        MockNearbyPlacesData.places.map { place in
            KnowledgeItem(
                id: "nearbyPlace:\(KnowledgeNormalizer.slug(place.saveKey))",
                type: .nearbyPlace,
                title: LocalizedKnowledgeText(place.localizedName(.english), dutch: place.localizedName(.dutch), russian: place.localizedName(.russian)),
                summary: LocalizedKnowledgeText(place.localizedDescription(.english), dutch: place.localizedDescription(.dutch), russian: place.localizedDescription(.russian)),
                category: place.category.rawValue,
                city: place.city,
                province: nil,
                keywords: [place.name, place.address, place.city, place.category.rawValue, place.description, place.newcomerUseCase, place.sourceLabel, place.trustNote, place.emergencyNote ?? ""] + place.relatedLinks.map(\.title),
                route: .mapFocus(.place(place.saveKey)),
                routeID: nil,
                sources: place.websiteURL.map { [OfficialSource(title: place.sourceLabel, url: $0, institution: place.name)] } ?? [],
                lastReviewed: nil,
                safetyLevel: place.emergencyNote == nil ? (place.isOfficialSource ? .officialSourceRecommended : .general) : .emergency,
                sourcePath: "YouNew/Data/MockNearbyPlacesData.swift",
                personaTags: place.personaTags
            )
        }
    }

    private static func resources() -> [KnowledgeItem] {
        MockResourcesData.items.map { resource in
            KnowledgeItem(
                id: "resource:\(resource.id.uuidString)",
                type: .resource,
                title: LocalizedKnowledgeText(resource.localizedTitle(.english), dutch: resource.localizedTitle(.dutch), russian: resource.localizedTitle(.russian)),
                summary: LocalizedKnowledgeText(resource.localizedDescription(.english), dutch: resource.localizedDescription(.dutch), russian: resource.localizedDescription(.russian)),
                category: resource.category,
                city: nil,
                province: nil,
                keywords: [resource.title, resource.description, resource.whoItHelps, resource.sourceLabel, resource.category, resource.reminder ?? ""],
                route: .resource(resource.id),
                routeID: nil,
                sources: [OfficialSource(title: resource.sourceLabel, url: resource.url, institution: resource.sourceLabel)],
                lastReviewed: nil,
                safetyLevel: resource.isOfficial ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockResourcesData.swift"
            )
        }
    }

    private static func knmModules() -> [KnowledgeItem] {
        KNMGuideData.modules.map { module in
            KnowledgeItem(
                id: "knmModule:\(module.id)",
                type: .knmModule,
                title: LocalizedKnowledgeText(module.title.value(.english), dutch: module.title.value(.dutch), russian: module.title.value(.russian)),
                summary: LocalizedKnowledgeText(module.summary.value(.english), dutch: module.summary.value(.dutch), russian: module.summary.value(.russian)),
                category: "KNM",
                city: nil,
                province: nil,
                keywords: [module.id, module.title.value(.english), module.summary.value(.english)] + module.searchAliases + module.lessons.map { $0.title.value(.english) },
                route: .knmModule(module.id),
                routeID: nil,
                sources: module.sources.compactMap { source in
                    guard let url = AppURL.validatedWebURL(URL(string: source.url)) else { return nil }
                    return OfficialSource(title: source.title.value(.english), url: url, institution: source.title.value(.english))
                },
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Data/KNMGuideData.swift"
            )
        }
    }

    private static func dutchCourseModules() -> [KnowledgeItem] {
        DutchA1A2CourseData.modules.map { module in
            KnowledgeItem(
                id: "dutchCourseModule:\(module.id)",
                type: .dutchCourseModule,
                title: LocalizedKnowledgeText(module.title.value(.english), dutch: module.title.value(.dutch), russian: module.title.value(.russian)),
                summary: LocalizedKnowledgeText(module.summary.value(.english), dutch: module.summary.value(.dutch), russian: module.summary.value(.russian)),
                category: module.level.rawValue,
                city: nil,
                province: nil,
                keywords: [module.id, module.level.rawValue, module.title.value(.english), module.summary.value(.english)] + module.searchAliases + module.lessons.map { $0.title.value(.english) },
                route: .dutchA1A2Module(module.id),
                routeID: nil,
                sources: module.sourceIds.compactMap(DutchA1A2CourseData.source(with:)).compactMap { source in
                    guard let url = AppURL.validatedWebURL(URL(string: source.url)) else { return nil }
                    return OfficialSource(title: source.title.value(.english), url: url, institution: source.title.value(.english))
                },
                lastReviewed: nil,
                safetyLevel: .officialSourceRecommended,
                sourcePath: "YouNew/Data/DutchA1A2CourseData.swift"
            )
        }
    }

    private static func searchAnswers() -> [KnowledgeItem] {
        MockSearchAnswersData.items.map { answer in
            KnowledgeItem(
                id: "searchAnswer:\(answer.id.uuidString)",
                type: .searchAnswer,
                title: LocalizedKnowledgeText(values: answer.titleByLanguage),
                summary: LocalizedKnowledgeText(values: answer.shortAnswerByLanguage),
                category: answer.category.rawValue,
                city: nil,
                province: nil,
                keywords: answer.keywords(.english) + answer.relatedQuestions + answer.relatedInstitutionNames,
                route: .searchAnswer(answer.id),
                routeID: nil,
                sources: [OfficialSource(title: answer.officialSourceName, url: answer.officialSourceURL, institution: answer.relatedInstitution ?? answer.officialSourceName)],
                lastReviewed: answer.lastUpdated,
                safetyLevel: answer.category.needsSafetyNote ? .officialSourceRequired : .officialSourceRecommended,
                sourcePath: "YouNew/Data/MockSearchAnswersData.swift"
            )
        }
    }

    private static func provinces() -> [KnowledgeItem] {
        NLProvince.all.map { province in
            KnowledgeItem(
                id: "province:\(KnowledgeNormalizer.slug(province.id))",
                type: .province,
                title: LocalizedKnowledgeText(province.name),
                summary: LocalizedKnowledgeText(province.description),
                category: "Province",
                city: nil,
                province: province.name,
                keywords: [province.name, province.nameEN, province.id, province.capital, province.history] + province.highlights,
                route: .provinceDetail(province.name),
                routeID: nil,
                sources: [OfficialSource(title: province.name, url: URL(string: "https://www.government.nl/topics/municipalities"), institution: "Province")],
                lastReviewed: nil,
                safetyLevel: .general,
                sourcePath: "YouNew/Data/NetherlandsData.swift"
            )
        }
    }

    private static func cities() -> [KnowledgeItem] {
        NLCity.all.map { city in
            KnowledgeItem(
                id: "city:\(KnowledgeNormalizer.slug(city.id))",
                type: .city,
                title: LocalizedKnowledgeText(city.name),
                summary: LocalizedKnowledgeText(city.shortDescription),
                category: "City",
                city: city.name,
                province: city.province,
                keywords: [city.name, city.province, city.tagline, city.expat, city.transport] + city.services + city.highlights,
                route: .nlCityDetail(city.id),
                routeID: nil,
                sources: [OfficialSource(title: city.name, url: URL(string: "https://www.government.nl/topics/municipalities"), institution: "Municipality")],
                lastReviewed: nil,
                safetyLevel: .general,
                sourcePath: "YouNew/Data/NetherlandsData.swift"
            )
        }
    }

    private static func routeFor(category: String, title: String) -> AppDestination? {
        let normalized = KnowledgeNormalizer.normalize("\(category) \(title)")
        if normalized.contains("health") { return .practicalGuide(.healthcareBasics) }
        if normalized.contains("housing") || normalized.contains("rent") { return .practicalGuide(.housingBasics) }
        if normalized.contains("transport") || normalized.contains("bicycle") { return .practicalGuide(.transportBasics) }
        if normalized.contains("tax") || normalized.contains("government") || normalized.contains("registration") || normalized.contains("digid") { return .governmentHub }
        if normalized.contains("work") { return .guideSection("work") }
        return .searchList
    }

    private static func safetyLevel(for category: String) -> KnowledgeSafetyLevel {
        let normalized = KnowledgeNormalizer.normalize(category)
        if normalized.contains("emergency") { return .emergency }
        if ["tax", "health", "work", "housing", "government", "registration"].contains(where: { normalized.contains($0) }) {
            return .officialSourceRequired
        }
        return .officialSourceRecommended
    }
}
