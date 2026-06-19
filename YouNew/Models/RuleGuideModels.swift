import Foundation

enum RuleSeverity: String, CaseIterable {
    case low
    case medium
    case high
    case critical

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.low, .russian): return "Низкая"
        case (.medium, .russian): return "Средняя"
        case (.high, .russian): return "Высокая"
        case (.critical, .russian): return "Критическая"
        case (.low, .dutch): return "Laag"
        case (.medium, .dutch): return "Middel"
        case (.high, .dutch): return "Hoog"
        case (.critical, .dutch): return "Kritiek"
        case (.low, .english): return "Low"
        case (.medium, .english): return "Medium"
        case (.high, .english): return "High"
        case (.critical, .english): return "Critical"
        }
    }
}

enum MainGuideSection: String, CaseIterable, Identifiable {
    case startHere
    case dailyLife
    case transport
    case documents
    case finesAndRules
    case workAndTaxes
    case housing
    case healthcare
    case government
    case emergency
    case helpNearby
    case assistant

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.startHere, .russian): return "Старт"
        case (.startHere, .dutch): return "Start Hier"
        case (.startHere, .english): return "Start Here"
        case (.dailyLife, .russian): return "Повседневная жизнь"
        case (.dailyLife, .dutch): return "Dagelijks Leven"
        case (.dailyLife, .english): return "Daily Life"
        case (.transport, .russian): return "Транспорт"
        case (.transport, .dutch): return "Vervoer"
        case (.transport, .english): return "Transport"
        case (.documents, .russian): return "Документы"
        case (.documents, .dutch): return "Documenten"
        case (.documents, .english): return "Documents"
        case (.finesAndRules, .russian): return "Штрафы и правила"
        case (.finesAndRules, .dutch): return "Boetes en Regels"
        case (.finesAndRules, .english): return "Fines & Rules"
        case (.workAndTaxes, .russian): return "Работа и налоги"
        case (.workAndTaxes, .dutch): return "Werk en Belastingen"
        case (.workAndTaxes, .english): return "Work & Taxes"
        case (.housing, .russian): return "Жильё"
        case (.housing, .dutch): return "Wonen"
        case (.housing, .english): return "Housing"
        case (.healthcare, .russian): return "Здравоохранение"
        case (.healthcare, .dutch): return "Gezondheidszorg"
        case (.healthcare, .english): return "Healthcare"
        case (.government, .russian): return "Госуслуги"
        case (.government, .dutch): return "Overheid"
        case (.government, .english): return "Government"
        case (.emergency, .russian): return "Экстренно"
        case (.emergency, .dutch): return "Nood"
        case (.emergency, .english): return "Emergency"
        case (.helpNearby, .russian): return "Помощь рядом"
        case (.helpNearby, .dutch): return "Hulp In De Buurt"
        case (.helpNearby, .english): return "Help Nearby"
        case (.assistant, .russian): return "Ассистент"
        case (.assistant, .dutch): return "Assistent"
        case (.assistant, .english): return "Assistant"
        }
    }

    var icon: String {
        switch self {
        case .startHere: return "sparkles"
        case .dailyLife: return "sun.max.fill"
        case .transport: return "tram.fill"
        case .documents: return "doc.text.fill"
        case .finesAndRules: return "exclamationmark.octagon.fill"
        case .workAndTaxes: return "briefcase.fill"
        case .housing: return "house.fill"
        case .healthcare: return "cross.case.fill"
        case .government: return "building.columns.fill"
        case .emergency: return "phone.down.fill"
        case .helpNearby: return "map.fill"
        case .assistant: return "sparkles"
        }
    }
}

struct RuleGuideTopic: Identifiable {
    let id: UUID
    let category: String
    let title: String
    let severity: RuleSeverity
    let rule: String
    let reason: String
    let commonMistake: String
    let estimatedFineRange: String
    let approximateFine: String
    let consequence: String
    let authority: String
    let alreadyFinedAction: String
    let officialSourceName: String
    let officialSourceURL: URL
    let realLifeExample: String
    let avoidWarning: String
    let relatedTopics: [String]
    var personaTags: Set<PersonaTag> {
        Self.tags(forCategory: category)
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    static func tags(forCategory category: String) -> Set<PersonaTag> {
        switch category {
        case "Work violations":
            return [.worker, .highlySkilledMigrant, .entrepreneur]
        case "Tourist mistakes":
            return [.tourist]
        case "ID/passport obligations", "Municipality rules":
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case "Public transport fines":
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        case "Bicycle rules", "Scooter / moped rules":
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        case "Car rules", "Parking fines":
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        case "Housing violations":
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case "Scam warnings":
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        default:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }
}

enum RuleGuideCategoryLocalization {
    static func localized(_ category: String, lang: AppLanguage) -> String {
        switch lang {
        case .english:
            return category
        case .russian:
            switch category {
            case "Bicycle rules": return "Велосипед"
            case "Scooter / moped rules": return "Мопед / скутер"
            case "Car rules": return "Автомобиль"
            case "Parking fines": return "Парковка"
            case "Public transport fines": return "Общественный транспорт"
            case "Trash / garbage rules": return "Мусор и переработка"
            case "Smoking rules": return "Курение"
            case "Noise complaints": return "Шум"
            case "ID/passport obligations": return "ID и документы"
            case "Alcohol/drug rules": return "Алкоголь и вещества"
            case "Municipality rules": return "Правила gemeente"
            case "Housing violations": return "Жилищные правила"
            case "Work violations": return "Нарушения работы"
            case "Scam warnings": return "Мошенничество"
            case "Tourist mistakes": return "Ошибки туристов"
            default: return category
            }
        case .dutch:
            switch category {
            case "Bicycle rules": return "Fiets"
            case "Scooter / moped rules": return "Brommer / scooter"
            case "Car rules": return "Auto"
            case "Parking fines": return "Parkeren"
            case "Public transport fines": return "Openbaar vervoer"
            case "Trash / garbage rules": return "Afval en recycling"
            case "Smoking rules": return "Roken"
            case "Noise complaints": return "Geluid"
            case "ID/passport obligations": return "ID en documenten"
            case "Alcohol/drug rules": return "Alcohol en drugs"
            case "Municipality rules": return "Gemeenteregels"
            case "Housing violations": return "Woonregels"
            case "Work violations": return "Werkovertredingen"
            case "Scam warnings": return "Fraudewaarschuwingen"
            case "Tourist mistakes": return "Toeristische fouten"
            default: return category
            }
        }
    }
}

struct RuleScenario: Identifiable {
    let id: UUID
    let title: String
    let meaning: String
    let doNotPanic: String
    let nextSteps: [String]
    let institution: String
    let officialSourceURL: URL
    var personaTags: Set<PersonaTag> {
        if institution.localizedCaseInsensitiveContains("DUO") {
            return [.student, .refugee]
        }
        if institution.localizedCaseInsensitiveContains("IND") {
            return [.refugee, .nonEU, .highlySkilledMigrant]
        }
        if institution.localizedCaseInsensitiveContains("UWV") {
            return [.worker, .refugee]
        }
        if institution.localizedCaseInsensitiveContains("Belastingdienst") {
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if institution.localizedCaseInsensitiveContains("CJIB") {
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}
