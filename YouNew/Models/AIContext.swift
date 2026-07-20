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
    let lastChecked: Date?

    nonisolated init(id: UUID = UUID(), title: String, url: URL? = nil, institution: String? = nil, lastChecked: Date? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.institution = institution
        self.lastChecked = lastChecked
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case institution
        case lastChecked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        institution = try container.decodeIfPresent(String.self, forKey: .institution)
        lastChecked = try container.decodeIfPresent(Date.self, forKey: .lastChecked)
    }
}

enum AIResponseConfidence: String, Codable, Equatable {
    case high
    case medium
    case low
}

enum AIResponseOrigin: String, Codable, Equatable {
    /// A response validated against the bounded backend contract and carrying
    /// actual GPT-5.6 model/request metadata.
    case liveOpenAI
    /// Deterministic guidance composed entirely from bundled app content.
    case localGuide
    /// A response that did not satisfy the live or grounded-local contract.
    case unverified
    /// A locally generated safety or privacy warning.
    case safety
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
    let selectedCityData: DashboardCity?
    let selectedAudience: UserContentCategory?
    let selectedSection: IASection?
    let places: [PlaceItem]
    let foodGuide: [FoodGuideItem]
    let travelLinks: [TravelLinkItem]
    let calendarEvents: [CalendarEvent]
    let currentScreen: String
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
        selectedCityData: DashboardCity? = nil,
        selectedAudience: UserContentCategory? = nil,
        selectedSection: IASection? = nil,
        places: [PlaceItem] = [],
        foodGuide: [FoodGuideItem] = [],
        travelLinks: [TravelLinkItem] = [],
        calendarEvents: [CalendarEvent] = [],
        currentScreen: String? = nil,
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
        self.selectedCityData = selectedCityData
        self.selectedAudience = selectedAudience
        self.selectedSection = selectedSection
        self.places = places
        self.foodGuide = foodGuide
        self.travelLinks = travelLinks
        self.calendarEvents = calendarEvents
        self.currentScreen = currentScreen ?? screen.rawValue
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
    let confidence: AIResponseConfidence
    let origin: AIResponseOrigin
    let model: String?
    let requestID: String?

    private enum CodingKeys: String, CodingKey {
        case answer
        case sources
        case safetyNote
        case suggestedActions
        case quickActions
        case sections
        case nextStep
        case appDestinationID
        case isVerified
        case cacheKey
        case confidence
        case origin
        case model
        case requestID = "requestId"
    }

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
        cacheKey: String? = nil,
        confidence: AIResponseConfidence? = nil,
        origin: AIResponseOrigin = .localGuide,
        model: String? = nil,
        requestID: String? = nil
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
        self.confidence = confidence ?? (isVerified ? .high : .low)
        self.origin = origin
        self.model = model
        self.requestID = requestID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        answer = try container.decode(String.self, forKey: .answer)
        sources = try container.decodeIfPresent([OfficialSource].self, forKey: .sources) ?? []
        safetyNote = try container.decodeIfPresent(String.self, forKey: .safetyNote)
        suggestedActions = try container.decodeIfPresent([String].self, forKey: .suggestedActions) ?? []
        quickActions = try container.decodeIfPresent([AIResponseAction].self, forKey: .quickActions) ?? []
        sections = try container.decodeIfPresent([AIResponseSection].self, forKey: .sections) ?? []
        nextStep = try container.decodeIfPresent(AINextStep.self, forKey: .nextStep)
        appDestinationID = try container.decodeIfPresent(String.self, forKey: .appDestinationID)
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        cacheKey = try container.decodeIfPresent(String.self, forKey: .cacheKey)
        confidence = try container.decodeIfPresent(AIResponseConfidence.self, forKey: .confidence) ?? (isVerified ? .high : .low)
        // Persisted responses created before this field existed must never be
        // promoted to a live response merely because they were cached.
        origin = try container.decodeIfPresent(AIResponseOrigin.self, forKey: .origin) ?? .localGuide
        model = try container.decodeIfPresent(String.self, forKey: .model)
        requestID = try container.decodeIfPresent(String.self, forKey: .requestID)
    }

    var isLiveOpenAI: Bool {
        guard origin == .liveOpenAI,
              let model,
              let requestID,
              !requestID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return false }
        return BuildWeekNewcomerDemo.isAllowedModel(model)
    }

    static func empty(language: AppLanguage) -> AIResponse {
        let searchTitle = localizedActionTitle(.search, language)
        let officialSourcesTitle = localizedActionTitle(.officialSources, language)
        let officialSourceTitle = localizedActionTitle(.officialSource, language)
        let saveTitle = localizedActionTitle(.save, language)
        let shareTitle = localizedActionTitle(.share, language)
        let relatedTitle = localizedRelatedOfficialSourcesTitle(language)
        let fallbackSource = OfficialSource(
            title: "Government.nl",
            url: URL(string: "https://www.government.nl"),
            institution: "Government of the Netherlands"
        )
        return AIResponse(
            answer: AISafetyRules.emptyAnswerMessage(for: language),
            sources: [fallbackSource],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: [searchTitle, officialSourcesTitle, saveTitle, shareTitle],
            quickActions: [
                AIResponseAction.openScreen(title: searchTitle, destinationID: "search"),
                AIResponseAction.openScreen(title: officialSourcesTitle, destinationID: "officialSources"),
                AIResponseAction.openSource(title: officialSourceTitle, url: AppURL.make("https://www.government.nl")),
                AIResponseAction.save(title: saveTitle, itemID: "empty-response"),
                AIResponseAction.share(title: shareTitle, itemID: "empty-response"),
                AIResponseAction.relatedTopic(relatedTitle, query: relatedTitle)
            ],
            isVerified: false,
            origin: .unverified
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
        let officialSourcesTitle = localizedActionTitle(.officialSources, language)
        let officialSourceTitle = localizedActionTitle(.officialSource, language)
        let saveTitle = localizedActionTitle(.save, language)
        let shareTitle = localizedActionTitle(.share, language)
        let relatedTitle = localizedRelatedOfficialSourcesTitle(language)
        let fallbackSource = OfficialSource(
            title: "Government.nl",
            url: URL(string: "https://www.government.nl"),
            institution: "Government of the Netherlands"
        )
        return AIResponse(
            answer: displayBody,
            sources: [fallbackSource],
            safetyNote: AISafetyRules.sourceMissingMessage(for: language),
            suggestedActions: [nextTitle, officialSourcesTitle, saveTitle, shareTitle],
            quickActions: [
                AIResponseAction.openScreen(title: nextTitle, destinationID: "search"),
                AIResponseAction.openScreen(title: officialSourcesTitle, destinationID: "officialSources"),
                AIResponseAction.openSource(title: officialSourceTitle, url: AppURL.make("https://www.government.nl")),
                AIResponseAction.save(title: saveTitle, itemID: "unverified-response"),
                AIResponseAction.share(title: shareTitle, itemID: "unverified-response"),
                AIResponseAction.relatedTopic(relatedTitle, query: relatedTitle)
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
            isVerified: false,
            origin: .unverified
        )
    }

    private enum FallbackActionTitle {
        case search
        case officialSources
        case officialSource
        case save
        case share
    }

    private static func localizedActionTitle(_ title: FallbackActionTitle, _ language: AppLanguage) -> String {
        switch (title, language) {
        case (.search, .russian): return "Открыть поиск"
        case (.search, .dutch): return "Zoeken openen"
        case (.search, .english): return "Open Search"
        case (.officialSources, .russian): return "Открыть официальные источники"
        case (.officialSources, .dutch): return "Officiële bronnen openen"
        case (.officialSources, .english): return "Open Official Sources"
        case (.officialSource, .russian): return "Открыть официальный источник"
        case (.officialSource, .dutch): return "Officiële bron openen"
        case (.officialSource, .english): return "Open Official Source"
        case (.save, .russian): return "Сохранить"
        case (.save, .dutch): return "Bewaren"
        case (.save, .english): return "Save"
        case (.share, .russian): return "Поделиться"
        case (.share, .dutch): return "Delen"
        case (.share, .english): return "Share"
        }
    }

    private static func localizedRelatedOfficialSourcesTitle(_ language: AppLanguage) -> String {
        switch language {
        case .russian: return "Связано: официальные источники"
        case .dutch: return "Verwant: officiële bronnen"
        case .english: return "Related: official sources"
        }
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
