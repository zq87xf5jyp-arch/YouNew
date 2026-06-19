import Foundation

enum LegalInfoCategory: String, CaseIterable, Identifiable {
    case immigration = "Immigration"
    case municipality = "Municipality"
    case identity = "Identity"
    case work = "Work"
    case tax = "Tax"
    case benefits = "Benefits"
    case healthcare = "Healthcare"
    case housing = "Housing"
    case transport = "Transport"
    case education = "Education"
    case fines = "Fines"
    case legalHelp = "Legal Help"
    case emergency = "Emergency"
    case scams = "Scams"
    case general = "General"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .immigration: return "airplane"
        case .municipality: return "building.2"
        case .identity: return "person.text.rectangle"
        case .work: return "briefcase"
        case .tax: return "eurosign.circle"
        case .benefits: return "hand.thumbsup"
        case .healthcare: return "cross.case"
        case .housing: return "house"
        case .transport: return "tram"
        case .education: return "graduationcap"
        case .fines: return "exclamationmark.triangle"
        case .legalHelp: return "scale.3d"
        case .emergency: return "light.beacon.max"
        case .scams: return "shield.slash"
        case .general: return "info.circle"
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return rawValue
        case .dutch:
            switch self {
            case .immigration:  return "Immigratie"
            case .municipality: return "Gemeente"
            case .identity:     return "Identiteit"
            case .work:         return "Werk"
            case .tax:          return "Belastingen"
            case .benefits:     return "Toeslagen"
            case .healthcare:   return "Gezondheidszorg"
            case .housing:      return "Huisvesting"
            case .transport:    return "Vervoer"
            case .education:    return "Onderwijs"
            case .fines:        return "Boetes"
            case .legalHelp:    return "Rechtshulp"
            case .emergency:    return "Noodsituaties"
            case .scams:        return "Oplichting"
            case .general:      return "Algemeen"
            }
        case .russian:
            switch self {
            case .immigration:  return "Иммиграция"
            case .municipality: return "Муниципалитет"
            case .identity:     return "Удостоверения"
            case .work:         return "Работа"
            case .tax:          return "Налоги"
            case .benefits:     return "Пособия"
            case .healthcare:   return "Здравоохранение"
            case .housing:      return "Жилье"
            case .transport:    return "Транспорт"
            case .education:    return "Образование"
            case .fines:        return "Штрафы"
            case .legalHelp:    return "Юридическая помощь"
            case .emergency:    return "Экстренные ситуации"
            case .scams:        return "Мошенничество"
            case .general:      return "Общее"
            }
        }
    }
}

struct LegalInfoItem: Identifiable {
    let id: UUID
    private let titleByLanguage: [AppLanguage: String]
    let category: LegalInfoCategory
    private let shortSummaryByLanguage: [AppLanguage: String]
    private let beginnerExplanationByLanguage: [AppLanguage: String]
    let officialSourceName: String
    let officialSourceURL: URL?
    let relatedInstitution: String?
    let riskLevel: RiskLevel
    let lastUpdated: Date
    let disclaimer: String
    let keywords: [String]

    var title: String { titleByLanguage[.english] ?? titleByLanguage.values.first ?? "" }
    var shortSummary: String { shortSummaryByLanguage[.english] ?? shortSummaryByLanguage.values.first ?? "" }
    var beginnerExplanation: String { beginnerExplanationByLanguage[.english] ?? beginnerExplanationByLanguage.values.first ?? "" }
    var personaTags: Set<PersonaTag> {
        switch category {
        case .immigration:
            return [.refugee, .nonEU, .highlySkilledMigrant, .lgbt]
        case .municipality, .identity:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .work:
            return [.worker, .refugee, .highlySkilledMigrant, .entrepreneur]
        case .tax:
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .benefits:
            return [.refugee, .family, .worker]
        case .healthcare:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .housing:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .transport:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        case .education:
            return [.student, .refugee, .family]
        case .fines:
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        case .legalHelp:
            return [.worker, .refugee, .family, .entrepreneur, .lgbt]
        case .emergency:
            return [.universal]
        case .scams:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .general:
            return [.universal]
        }
    }

    func title(_ lang: AppLanguage) -> String {
        if lang == .russian { return titleByLanguage[.russian] ?? "Смотрите описание на английском языке." }
        return titleByLanguage[lang] ?? titleByLanguage[.english] ?? "Content available in English."
    }

    func shortSummary(_ lang: AppLanguage) -> String {
        if lang == .russian { return shortSummaryByLanguage[.russian] ?? "Смотрите описание на английском языке." }
        return shortSummaryByLanguage[lang] ?? shortSummaryByLanguage[.english] ?? "Content available in English."
    }

    func beginnerExplanation(_ lang: AppLanguage) -> String {
        if lang == .russian { return beginnerExplanationByLanguage[.russian] ?? "Смотрите описание на английском языке." }
        return beginnerExplanationByLanguage[lang] ?? beginnerExplanationByLanguage[.english] ?? "Content available in English."
    }

    func localizedDisclaimer(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return "Это справочная информация, а не юридическая консультация. Проверяйте актуальные правила в официальных источниках."
        case .dutch:   return "Dit is informatieve begeleiding, geen juridisch advies. Controleer actuele regels altijd bij officiele bronnen."
        case .english: return "This is informational guidance, not legal advice. Always verify current rules with official sources."
        }
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    init(
        id: UUID,
        titleByLanguage: [AppLanguage: String],
        category: LegalInfoCategory,
        shortSummaryByLanguage: [AppLanguage: String],
        beginnerExplanationByLanguage: [AppLanguage: String],
        officialSourceName: String,
        officialSourceURL: URL?,
        relatedInstitution: String?,
        riskLevel: RiskLevel,
        lastUpdated: Date,
        disclaimer: String,
        keywords: [String]
    ) {
        self.id = id
        self.titleByLanguage = titleByLanguage
        self.category = category
        self.shortSummaryByLanguage = shortSummaryByLanguage
        self.beginnerExplanationByLanguage = beginnerExplanationByLanguage
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.relatedInstitution = relatedInstitution
        self.riskLevel = riskLevel
        self.lastUpdated = lastUpdated
        self.disclaimer = disclaimer
        self.keywords = keywords
    }
}
