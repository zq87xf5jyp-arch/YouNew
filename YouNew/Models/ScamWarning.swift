import Foundation

enum ScamCategory: String, CaseIterable, Identifiable {
    case phishing = "Phishing"
    case impostor = "Impostor"
    case rental = "Rental"
    case financial = "Financial"
    case employment = "Employment"
    case digitalIdentity = "Digital Identity"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .phishing: return "envelope.badge.shield.half.filled"
        case .impostor: return "person.badge.minus"
        case .rental: return "house.badge.exclamationmark"
        case .financial: return "eurosign.circle"
        case .employment: return "briefcase.badge.clock"
        case .digitalIdentity: return "faceid"
        }
    }
}

struct ScamWarning: Identifiable {
    let id: UUID
    let title: String
    let category: ScamCategory
    let howItWorks: String
    let warningSignals: [String]
    let whatToDo: String
    let reportTo: String
    let reportURL: URL?
    let personaTags: Set<PersonaTag>

    init(
        id: UUID = UUID(),
        title: String,
        category: ScamCategory,
        howItWorks: String,
        warningSignals: [String],
        whatToDo: String,
        reportTo: String,
        reportURL: URL? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.howItWorks = howItWorks
        self.warningSignals = warningSignals
        self.whatToDo = whatToDo
        self.reportTo = reportTo
        self.reportURL = reportURL
        self.personaTags = Self.assignedPersonaTags(explicitTags: personaTags, category: category)
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    private static func assignedPersonaTags(explicitTags: Set<PersonaTag>, category: ScamCategory) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        switch category {
        case .employment:
            return [.worker, .refugee, .highlySkilledMigrant, .entrepreneur]
        case .financial, .digitalIdentity:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .rental:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .phishing, .impostor:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }
}
