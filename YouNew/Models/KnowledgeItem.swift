import Foundation

enum KnowledgeItemType: String, CaseIterable, Codable, Hashable {
    case guide
    case article
    case searchAnswer
    case checklist
    case document
    case deadline
    case officialService
    case institution
    case city
    case province
    case nearbyPlace
    case fine
    case rule
    case letter
    case dutchTerm
    case knmModule
    case dutchCourseModule
    case risk
    case mistake
    case resource
    case localPartner
    case appTool
    case appScreen
    case topic
    case scenario
}

enum KnowledgeSafetyLevel: String, Codable, Hashable {
    case general
    case officialSourceRecommended
    case officialSourceRequired
    case emergency
}

enum KnowledgeRelationType: String, CaseIterable, Codable, Hashable {
    case requires
    case nextStep
    case relatedTopic
    case relatedGuide
    case sameCategory
    case officialSource
    case opensDestination
    case citySpecific
    case provinceSpecific
    case documentNeeded
    case deadline
    case warning
    case fallback
    case userStatusRecommended
}

struct LocalizedKnowledgeText: Hashable, Codable {
    let values: [AppLanguage: String]

    init(_ english: String, dutch: String? = nil, russian: String? = nil) {
        var values: [AppLanguage: String] = [.english: english]
        if let dutch { values[.dutch] = dutch }
        if let russian { values[.russian] = russian }
        self.values = values
    }

    init(values: [AppLanguage: String], fallback: String = "") {
        var values = values
        if values[.english] == nil {
            values[.english] = fallback
        }
        self.values = values
    }

    func text(_ language: AppLanguage) -> String {
        values[language] ?? values[.english] ?? ""
    }
}

struct KnowledgeItem: Identifiable {
    let id: String
    let type: KnowledgeItemType
    let title: LocalizedKnowledgeText
    let summary: LocalizedKnowledgeText
    let category: String
    let city: String?
    let province: String?
    let keywords: [String]
    let route: AppDestination?
    let routeID: String?
    let sources: [OfficialSource]
    let lastReviewed: Date?
    let safetyLevel: KnowledgeSafetyLevel
    let sourcePath: String
    let personaTags: Set<PersonaTag>

    init(
        id: String,
        type: KnowledgeItemType,
        title: LocalizedKnowledgeText,
        summary: LocalizedKnowledgeText,
        category: String,
        city: String?,
        province: String?,
        keywords: [String],
        route: AppDestination?,
        routeID: String?,
        sources: [OfficialSource],
        lastReviewed: Date?,
        safetyLevel: KnowledgeSafetyLevel,
        sourcePath: String,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.summary = summary
        self.category = category
        self.city = city
        self.province = province
        self.keywords = keywords
        self.route = route
        self.routeID = routeID
        self.sources = sources
        self.lastReviewed = lastReviewed
        self.safetyLevel = safetyLevel
        self.sourcePath = sourcePath
        self.personaTags = PersonaContentPolicy.assignedTags(
            explicitTags: personaTags,
            category: category,
            title: title.text(.english),
            summary: summary.text(.english),
            keywords: keywords,
            sources: sources
        )
    }

    func title(_ language: AppLanguage) -> String {
        title.text(language)
    }

    func summary(_ language: AppLanguage) -> String {
        summary.text(language)
    }

    func effectivePersonaTags(language: AppLanguage = .english) -> Set<PersonaTag> {
        personaTags
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: effectivePersonaTags(), activePersona: persona, scope: scope)
    }
}

struct KnowledgeRelation: Hashable {
    let fromID: String
    let toID: String
    let type: KnowledgeRelationType
    let weight: Double
    let reason: String
}

struct KnowledgeSearchResult: Identifiable {
    let item: KnowledgeItem
    let score: Double
    let matchedFields: [String]
    let graphNeighbors: [KnowledgeItem]
    let quickActions: [AIQuickAction]

    var id: String { item.id }
}

enum AIQuickAction: Hashable {
    case openGuide(AppDestination)
    case openScreen(AppDestination)
    case openCity(String)
    case openProvince(String)
    case openSource(URL)
    case save(String)
    case share(String)
    case relatedTopic(String)
    case askFollowUp(String)

    var title: String {
        switch self {
        case .openGuide: return "Open Guide"
        case .openScreen: return "Open Screen"
        case .openCity(let city): return "Open \(city)"
        case .openProvince(let province): return "Open \(province)"
        case .openSource: return "Open Source"
        case .save: return "Save"
        case .share: return "Share"
        case .relatedTopic(let topic): return "Related: \(topic)"
        case .askFollowUp(let question): return question
        }
    }
}
