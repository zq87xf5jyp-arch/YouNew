import Foundation

enum DailyLifeCategory: String, CaseIterable, Identifiable {
    case healthcare = "Healthcare"
    case banking = "Banking"
    case transport = "Transport"
    case cycling = "Cycling"
    case waste = "Waste & Recycling"
    case culture = "Culture & Customs"
    case shopping = "Shopping"
    case emergency = "Emergency"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .healthcare: return "cross.case.fill"
        case .banking: return "creditcard.fill"
        case .transport: return "tram.fill"
        case .cycling: return "bicycle"
        case .waste: return "trash.fill"
        case .culture: return "person.2.fill"
        case .shopping: return "bag.fill"
        case .emergency: return "sos.circle.fill"
        }
    }
}

struct DailyLifeTip: Identifiable {
    let id: UUID
    let title: String
    let category: DailyLifeCategory
    let summary: String
    let detail: String
    let practicalTip: String
    let officialSourceName: String?
    let officialSourceURL: URL?
    let personaTags: Set<PersonaTag>

    init(
        id: UUID? = nil,
        title: String,
        category: DailyLifeCategory,
        summary: String,
        detail: String,
        practicalTip: String,
        officialSourceName: String? = nil,
        officialSourceURL: URL? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id ?? StableRouteID.uuid("daily-life:\(Self.stableKnowledgeKey(title))")
        self.title = title
        self.category = category
        self.summary = summary
        self.detail = detail
        self.practicalTip = practicalTip
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.personaTags = Self.assignedPersonaTags(explicitTags: personaTags, category: category, title: title, summary: summary)
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    private static func assignedPersonaTags(explicitTags: Set<PersonaTag>, category: DailyLifeCategory, title: String, summary: String) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        switch category {
        case .healthcare, .transport, .cycling, .shopping:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .waste, .culture:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .emergency:
            return [.universal]
        case .banking:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }

    private static func stableKnowledgeKey(_ title: String) -> String {
        title.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
