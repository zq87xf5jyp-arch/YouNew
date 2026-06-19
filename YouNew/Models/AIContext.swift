import Foundation

enum AIContextScreen: String, Codable, Equatable {
    case home
    case search
    case rulesAndFines
    case fineDetail
    case documents
    case transport
    case province
    case city
    case emergency
    case housing
    case healthcare
    case workAndTaxes
    case saved
    case settings
    case onboarding
    case officialLinks
    case informationHub
    case knm
    case dutchCourse
    case practicalGuide
    case map
    case assistant
    case unknown
}

struct OfficialSource: Codable, Equatable, Identifiable {
    let id: UUID
    let title: String
    let url: URL?
    let institution: String?

    nonisolated init(id: UUID = UUID(), title: String, url: URL? = nil, institution: String? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.institution = institution
    }
}

struct AIContext: Codable, Equatable {
    let screen: AIContextScreen
    let category: String?
    let topicTitle: String?
    let topicSummary: String?
    let officialSources: [OfficialSource]
    let lastReviewed: Date?
    let userLanguage: AppLanguage
    let userSituation: String?
    let selectedCity: String?
    let selectedProvince: String?
    let savedItemTitles: [String]
    let savedItemIDs: [String]
    let savedItemKinds: [String]
    let currentRouteID: String?
    let recentRouteIDs: [String]
    let lastSearches: [String]
    let completedChecklistItemIDs: [String]
    let completedGuideIDs: [String]
    let journeyProgress: String?
    let disclaimer: String
    let activePersonaTag: PersonaTag?
    let secondaryPersonaTags: [PersonaTag]
    let personaSearchScope: PersonaSearchScope

    init(
        screen: AIContextScreen,
        category: String?,
        topicTitle: String?,
        topicSummary: String?,
        officialSources: [OfficialSource],
        lastReviewed: Date?,
        userLanguage: AppLanguage,
        userSituation: String?,
        selectedCity: String?,
        selectedProvince: String?,
        savedItemTitles: [String],
        savedItemIDs: [String] = [],
        savedItemKinds: [String] = [],
        currentRouteID: String? = nil,
        recentRouteIDs: [String] = [],
        lastSearches: [String] = [],
        completedChecklistItemIDs: [String] = [],
        completedGuideIDs: [String] = [],
        journeyProgress: String? = nil,
        disclaimer: String,
        activePersonaTag: PersonaTag? = nil,
        secondaryPersonaTags: [PersonaTag] = [],
        personaSearchScope: PersonaSearchScope = .currentAndUniversal
    ) {
        self.screen = screen
        self.category = category
        self.topicTitle = topicTitle
        self.topicSummary = topicSummary
        self.officialSources = officialSources
        self.lastReviewed = lastReviewed
        self.userLanguage = userLanguage
        self.userSituation = userSituation
        self.selectedCity = selectedCity
        self.selectedProvince = selectedProvince
        self.savedItemTitles = savedItemTitles
        self.savedItemIDs = savedItemIDs
        self.savedItemKinds = savedItemKinds
        self.currentRouteID = currentRouteID
        self.recentRouteIDs = recentRouteIDs
        self.lastSearches = lastSearches
        self.completedChecklistItemIDs = completedChecklistItemIDs
        self.completedGuideIDs = completedGuideIDs
        self.journeyProgress = journeyProgress
        self.disclaimer = disclaimer
        self.activePersonaTag = activePersonaTag
        self.secondaryPersonaTags = secondaryPersonaTags
        self.personaSearchScope = personaSearchScope
    }

    static func empty(language: AppLanguage) -> AIContext {
        AIContext(
            screen: .unknown,
            category: nil,
            topicTitle: nil,
            topicSummary: nil,
            officialSources: [],
            lastReviewed: nil,
            userLanguage: language,
            userSituation: nil,
            selectedCity: nil,
            selectedProvince: nil,
            savedItemTitles: [],
            savedItemIDs: [],
            savedItemKinds: [],
            currentRouteID: nil,
            recentRouteIDs: [],
            lastSearches: [],
            completedChecklistItemIDs: [],
            completedGuideIDs: [],
            journeyProgress: nil,
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: language)
        )
    }
}

struct AIResponse: Codable, Equatable {
    static let unverifiedAnswer = "I don’t have verified information in the app yet."

    let answer: String
    let sources: [OfficialSource]
    let safetyNote: String?
    let suggestedActions: [String]
    let quickActions: [AIResponseAction]
    let sections: [AIResponseSection]
    let nextStep: AINextStep?
    let appDestinationID: String?
    let isVerified: Bool
    let cacheKey: String?

    init(
        answer: String,
        sources: [OfficialSource],
        safetyNote: String?,
        suggestedActions: [String],
        quickActions: [AIResponseAction] = [],
        sections: [AIResponseSection] = [],
        nextStep: AINextStep? = nil,
        appDestinationID: String? = nil,
        isVerified: Bool = true,
        cacheKey: String? = nil
    ) {
        self.answer = answer
        self.sources = sources
        self.safetyNote = safetyNote
        self.suggestedActions = suggestedActions
        self.quickActions = quickActions
        self.sections = sections
        self.nextStep = nextStep
        self.appDestinationID = appDestinationID
        self.isVerified = isVerified
        self.cacheKey = cacheKey
    }

    static func empty(language: AppLanguage) -> AIResponse {
        let officialSource = AppURL.make("https://www.government.nl")
        return AIResponse(
            answer: AISafetyRules.emptyAnswerMessage(for: language),
            sources: [
                OfficialSource(title: "Government.nl", url: officialSource, institution: "Government of the Netherlands")
            ],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: ["Open Search", "Open Official Sources", "Open Official Source", "Save", "Share"],
            quickActions: [
                AIResponseAction.openScreen(title: "Open Search", destinationID: "search"),
                AIResponseAction.openScreen(title: "Open Official Sources", destinationID: "officialSources"),
                AIResponseAction.openSource(title: "Open Official Source", url: officialSource),
                AIResponseAction.save(title: "Save", itemID: "empty-response"),
                AIResponseAction.share(title: "Share", itemID: "empty-response"),
                AIResponseAction.relatedTopic("Related: official sources", query: "official sources")
            ],
            isVerified: false
        )
    }

    static func unverified(language: AppLanguage) -> AIResponse {
        let sectionTitle: String
        let displayBody: String
        let nextTitle: String
        let nextDetail: String
        let nextDestTitle: String
        switch language {
        case .dutch:
            sectionTitle = "Antwoord"
            displayBody = "Ik heb hier nog geen geverifieerde informatie over."
            nextTitle = "Zoek geverifieerde informatie"
            nextDetail = "Gebruik de zoekfunctie of officiële bronnen voordat u actie onderneemt."
            nextDestTitle = "Zoeken"
        case .russian:
            sectionTitle = "Ответ"
            displayBody = "У меня пока нет проверенной информации по этому вопросу."
            nextTitle = "Найдите проверенную информацию"
            nextDetail = "Используйте поиск в приложении или официальные источники, прежде чем действовать."
            nextDestTitle = "Поиск"
        case .english:
            sectionTitle = "Answer"
            displayBody = unverifiedAnswer
            nextTitle = "Search verified information"
            nextDetail = "Use app search or official sources before acting."
            nextDestTitle = "Search"
        }
        let officialSource = AppURL.make("https://www.government.nl")
        return AIResponse(
            answer: displayBody,
            sources: [
                OfficialSource(title: "Government.nl", url: officialSource, institution: "Government of the Netherlands")
            ],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: [nextTitle, "Open Official Sources", "Open Official Source", "Save", "Share"],
            quickActions: [
                AIResponseAction.openScreen(title: nextTitle, destinationID: "search"),
                AIResponseAction.openScreen(title: nextDestTitle, destinationID: "officialSources"),
                AIResponseAction.openSource(title: "Open Official Source", url: officialSource),
                AIResponseAction.save(title: "Save", itemID: "unverified-response"),
                AIResponseAction.share(title: "Share", itemID: "unverified-response"),
                AIResponseAction.relatedTopic("Related: official sources", query: "official sources")
            ],
            sections: [
                AIResponseSection(
                    title: sectionTitle,
                    body: displayBody,
                    symbol: "exclamationmark.shield.fill"
                )
            ],
            nextStep: AINextStep(
                title: nextTitle,
                detail: nextDetail,
                destinationID: "search",
                destinationTitle: nextDestTitle
            ),
            appDestinationID: "search",
            isVerified: false
        )
    }
}

struct AIResponseSection: Codable, Equatable {
    let title: String
    let body: String
    let symbol: String?

    init(title: String, body: String, symbol: String? = nil) {
        self.title = title
        self.body = body
        self.symbol = symbol
    }
}

struct AIResponseAction: Codable, Equatable, Identifiable {
    enum Kind: String, Codable {
        case openGuide
        case openScreen
        case openCity
        case openProvince
        case openSource
        case save
        case share
        case relatedTopic
        case askFollowUp
    }

    let id: UUID
    let kind: Kind
    let title: String
    let destinationID: String?
    let url: URL?
    let itemID: String?
    let query: String?

    nonisolated init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        destinationID: String? = nil,
        url: URL? = nil,
        itemID: String? = nil,
        query: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.destinationID = destinationID
        self.url = url
        self.itemID = itemID
        self.query = query
    }

    nonisolated static func openGuide(title: String, destinationID: String?) -> AIResponseAction {
        AIResponseAction(kind: .openGuide, title: title, destinationID: destinationID)
    }

    nonisolated static func openScreen(title: String, destinationID: String?) -> AIResponseAction {
        AIResponseAction(kind: .openScreen, title: title, destinationID: destinationID)
    }

    nonisolated static func openSource(title: String, url: URL) -> AIResponseAction {
        AIResponseAction(kind: .openSource, title: title, url: url)
    }

    nonisolated static func save(title: String, itemID: String) -> AIResponseAction {
        AIResponseAction(kind: .save, title: title, itemID: itemID)
    }

    nonisolated static func share(title: String, itemID: String) -> AIResponseAction {
        AIResponseAction(kind: .share, title: title, itemID: itemID)
    }

    nonisolated static func relatedTopic(_ title: String, query: String) -> AIResponseAction {
        AIResponseAction(kind: .relatedTopic, title: title, query: query)
    }
}

struct AINextStep: Codable, Equatable {
    let title: String
    let detail: String
    let destinationID: String?
    let destinationTitle: String?

    init(title: String, detail: String, destinationID: String? = nil, destinationTitle: String? = nil) {
        self.title = title
        self.detail = detail
        self.destinationID = destinationID
        self.destinationTitle = destinationTitle
    }
}
