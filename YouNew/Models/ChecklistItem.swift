import Foundation

enum ChecklistCategory: String {
    case registration = "Registration"
    case documents = "Documents"
    case insurance = "Insurance"
    case work = "Work"
    case taxes = "Taxes"
    case housing = "Housing"
    case education = "Education"
    case transport = "Transport"
}

extension ChecklistCategory {
    var localizedTitle: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .registration: return L10n.t("checklist.category.registration", lang)
        case .documents:    return L10n.t("checklist.category.documents", lang)
        case .insurance:    return L10n.t("checklist.category.insurance", lang)
        case .work:         return L10n.t("checklist.category.work", lang)
        case .taxes:        return L10n.t("checklist.category.taxes", lang)
        case .housing:      return L10n.t("checklist.category.housing", lang)
        case .education:    return L10n.t("checklist.category.education", lang)
        case .transport:    return L10n.t("checklist.category.transport", lang)
        }
    }
}

enum ChecklistPriority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .high:   return L10n.t("checklist.priority.high", lang)
        case .medium: return L10n.t("checklist.priority.medium", lang)
        case .low:    return L10n.t("checklist.priority.low", lang)
        }
    }
}

struct ChecklistItem: Identifiable {
    let id: UUID
    let titleByLanguage: [AppLanguage: String]
    let descriptionByLanguage: [AppLanguage: String]
    let category: ChecklistCategory
    let priority: ChecklistPriority
    let suggestedTimingByLanguage: [AppLanguage: String]
    let officialSourceName: String
    let officialSourceURL: URL
    var isCompleted: Bool
    let dueDate: Date?
    let relevantProfileTypes: [ProfileType]?
    let relatedChecklistIDs: [UUID]
    let relatedTermIDs: [UUID]
    let relatedFineIDs: [UUID]
    let relatedInstitutionNames: [String]
    let relatedSearchAnswerIDs: [UUID]
    let nextRecommendedStepID: UUID?

    // Backward-compat for engine/matching. Keep implicit values aligned with the
    // English release language to avoid mixed-language cards.
    var title: String { titleByLanguage[.english] ?? titleByLanguage[.russian] ?? "" }
    var description: String { descriptionByLanguage[.english] ?? descriptionByLanguage[.russian] ?? "" }
    var suggestedTiming: String { suggestedTimingByLanguage[.english] ?? suggestedTimingByLanguage[.russian] ?? "" }
    var personaTags: Set<PersonaTag> {
        let lowerTitle = title.lowercased()
        switch category {
        case .registration:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .documents:
            if lowerTitle.contains("duo") || lowerTitle.contains("student") {
                return [.student, .refugee, .family]
            }
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .insurance:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .work:
            return [.worker, .refugee, .highlySkilledMigrant, .entrepreneur]
        case .taxes:
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .housing:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .education:
            return [.student, .refugee, .family]
        case .transport:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        }
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    func title(_ language: AppLanguage) -> String {
        localized(titleByLanguage, language: language)
    }

    func description(_ language: AppLanguage) -> String {
        localized(descriptionByLanguage, language: language)
    }

    func suggestedTiming(_ language: AppLanguage) -> String {
        localized(suggestedTimingByLanguage, language: language)
    }

    private func localized(_ values: [AppLanguage: String], language: AppLanguage) -> String {
        if let requested = values[language], !requested.isEmpty { return requested }
        if let english = values[.english], !english.isEmpty { return english }
        return values.values.first(where: { !$0.isEmpty }) ?? ""
    }

    init(
        id: UUID,
        titleByLanguage: [AppLanguage: String],
        descriptionByLanguage: [AppLanguage: String],
        category: ChecklistCategory,
        priority: ChecklistPriority,
        suggestedTimingByLanguage: [AppLanguage: String],
        officialSourceName: String,
        officialSourceURL: URL,
        isCompleted: Bool,
        dueDate: Date?,
        relevantProfileTypes: [ProfileType]?,
        relatedChecklistIDs: [UUID] = [],
        relatedTermIDs: [UUID] = [],
        relatedFineIDs: [UUID] = [],
        relatedInstitutionNames: [String] = [],
        relatedSearchAnswerIDs: [UUID] = [],
        nextRecommendedStepID: UUID? = nil
    ) {
        self.id = id
        self.titleByLanguage = titleByLanguage
        self.descriptionByLanguage = descriptionByLanguage
        self.category = category
        self.priority = priority
        self.suggestedTimingByLanguage = suggestedTimingByLanguage
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.relevantProfileTypes = relevantProfileTypes
        self.relatedChecklistIDs = relatedChecklistIDs
        self.relatedTermIDs = relatedTermIDs
        self.relatedFineIDs = relatedFineIDs
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedSearchAnswerIDs = relatedSearchAnswerIDs
        self.nextRecommendedStepID = nextRecommendedStepID
    }
}
