import Foundation

enum MistakeCategory: String, CaseIterable, Identifiable {
    case documents = "Documents"
    case deadlines = "Deadlines"
    case housing = "Housing"
    case healthInsurance = "Health Insurance"
    case work = "Work"
    case taxes = "Taxes"
    case transport = "Transport"
    case scams = "Scams"
    case municipality = "Municipality"
    case education = "Education"
    case legalLetters = "Legal & Letters"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .documents: return "doc.badge.ellipsis"
        case .deadlines: return "calendar.badge.exclamationmark"
        case .housing: return "house.badge.exclamationmark"
        case .healthInsurance: return "cross.case"
        case .work: return "briefcase"
        case .taxes: return "eurosign.circle"
        case .transport: return "tram"
        case .scams: return "shield.slash"
        case .municipality: return "building.2"
        case .education: return "graduationcap"
        case .legalLetters: return "envelope.badge.shield.half.filled"
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .documents:
            switch lang {
            case .russian: return "Документы"
            case .dutch:   return "Documenten"
            case .english: return rawValue
            }
        case .deadlines:
            switch lang {
            case .russian: return "Сроки"
            case .dutch:   return "Deadlines"
            case .english: return rawValue
            }
        case .housing:
            switch lang {
            case .russian: return "Жильё"
            case .dutch:   return "Huisvesting"
            case .english: return rawValue
            }
        case .healthInsurance:
            switch lang {
            case .russian: return "Медицинская страховка"
            case .dutch:   return "Zorgverzekering"
            case .english: return rawValue
            }
        case .work:
            switch lang {
            case .russian: return "Работа"
            case .dutch:   return "Werk"
            case .english: return rawValue
            }
        case .taxes:
            switch lang {
            case .russian: return "Налоги"
            case .dutch:   return "Belastingen"
            case .english: return rawValue
            }
        case .transport:
            switch lang {
            case .russian: return "Транспорт"
            case .dutch:   return "Vervoer"
            case .english: return rawValue
            }
        case .scams:
            switch lang {
            case .russian: return "Мошенничество"
            case .dutch:   return "Oplichting"
            case .english: return rawValue
            }
        case .municipality:
            switch lang {
            case .russian: return "Gemeente"
            case .dutch:   return "Gemeente"
            case .english: return rawValue
            }
        case .education:
            switch lang {
            case .russian: return "Образование"
            case .dutch:   return "Onderwijs"
            case .english: return rawValue
            }
        case .legalLetters:
            switch lang {
            case .russian: return "Юридические письма"
            case .dutch:   return "Juridische brieven"
            case .english: return rawValue
            }
        }
    }
}

struct NewcomerMistake: Identifiable {
    let id: UUID
    let titleByLanguage: [AppLanguage: String]
    let whyItMattersByLanguage: [AppLanguage: String]
    let possibleConsequenceByLanguage: [AppLanguage: String]
    let howToPreventByLanguage: [AppLanguage: String]
    let officialSourceURL: URL?
    let officialSourceName: String?
    let riskLevel: RiskLevel
    let category: MistakeCategory
    let personaTags: Set<PersonaTag>

    // Backward-compat for RelatedContentEngine and matching code. The release
    // UI is English-first, so implicit access must not leak Russian strings.
    var title: String { titleByLanguage[.english] ?? titleByLanguage[.russian] ?? "" }
    var whyItMatters: String { whyItMattersByLanguage[.english] ?? whyItMattersByLanguage[.russian] ?? "" }
    var possibleConsequence: String { possibleConsequenceByLanguage[.english] ?? possibleConsequenceByLanguage[.russian] ?? "" }
    var howToPrevent: String { howToPreventByLanguage[.english] ?? howToPreventByLanguage[.russian] ?? "" }

    init(
        id: UUID,
        titleByLanguage: [AppLanguage: String],
        whyItMattersByLanguage: [AppLanguage: String],
        possibleConsequenceByLanguage: [AppLanguage: String],
        howToPreventByLanguage: [AppLanguage: String],
        officialSourceURL: URL?,
        officialSourceName: String?,
        riskLevel: RiskLevel,
        category: MistakeCategory,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.titleByLanguage = titleByLanguage
        self.whyItMattersByLanguage = whyItMattersByLanguage
        self.possibleConsequenceByLanguage = possibleConsequenceByLanguage
        self.howToPreventByLanguage = howToPreventByLanguage
        self.officialSourceURL = officialSourceURL
        self.officialSourceName = officialSourceName
        self.riskLevel = riskLevel
        self.category = category
        self.personaTags = Self.assignedPersonaTags(
            explicitTags: personaTags,
            category: category,
            title: titleByLanguage[.english] ?? titleByLanguage[.russian] ?? "",
            body: [
                whyItMattersByLanguage[.english],
                possibleConsequenceByLanguage[.english],
                howToPreventByLanguage[.english],
                officialSourceName
            ].compactMap { $0 }.joined(separator: " ")
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    func title(_ language: AppLanguage) -> String {
        localized(titleByLanguage, language: language)
    }

    func whyItMatters(_ language: AppLanguage) -> String {
        localized(whyItMattersByLanguage, language: language)
    }

    func possibleConsequence(_ language: AppLanguage) -> String {
        localized(possibleConsequenceByLanguage, language: language)
    }

    func howToPrevent(_ language: AppLanguage) -> String {
        localized(howToPreventByLanguage, language: language)
    }

    private func localized(_ values: [AppLanguage: String], language: AppLanguage) -> String {
        if let requested = values[language], !requested.isEmpty { return requested }
        if let english = values[.english], !english.isEmpty { return english }
        return values.values.first(where: { !$0.isEmpty }) ?? ""
    }

    private static func assignedPersonaTags(
        explicitTags: Set<PersonaTag>,
        category: MistakeCategory,
        title: String,
        body: String
    ) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        switch category {
        case .work:
            return [.worker, .refugee, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur]
        case .taxes:
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .education:
            return [.student, .refugee, .family]
        case .municipality:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .documents:
            if body.localizedCaseInsensitiveContains("IND") || title.localizedCaseInsensitiveContains("residence permit") {
                return [.refugee, .nonEU, .highlySkilledMigrant]
            }
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .housing:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .healthInsurance:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .transport:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur]
        case .scams:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .deadlines:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .legalLetters:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }
}
