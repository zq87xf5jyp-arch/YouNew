import Foundation

enum FineCategory: String, CaseIterable, Identifiable {
    case traffic = "Traffic"
    case publicTransport = "Public Transport"
    case healthInsurance = "Health Insurance"
    case tax = "Tax"
    case latePayment = "Late Payment"
    case municipalityRegistration = "Municipality Registration"
    case parking = "Parking"
    case wasteDisposal = "Waste Disposal"
    case drivingLicence = "Driving Licence"
    case officialLetters = "Official Letters"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .traffic: return "car.fill"
        case .publicTransport: return "tram.fill"
        case .healthInsurance: return "cross.case.fill"
        case .tax: return "eurosign.circle.fill"
        case .latePayment: return "clock.badge.exclamationmark"
        case .municipalityRegistration: return "building.2.fill"
        case .parking: return "p.circle.fill"
        case .wasteDisposal: return "trash.fill"
        case .drivingLicence: return "car.badge.questionmark"
        case .officialLetters: return "envelope.badge.fill"
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .traffic:
            switch lang {
            case .russian: return "Дорожные нарушения"
            case .dutch:   return "Verkeersboetes"
            case .english: return rawValue
            }
        case .publicTransport:
            switch lang {
            case .russian: return "Общественный транспорт"
            case .dutch:   return "Openbaar vervoer"
            case .english: return rawValue
            }
        case .healthInsurance:
            switch lang {
            case .russian: return "Медицинская страховка"
            case .dutch:   return "Zorgverzekering"
            case .english: return rawValue
            }
        case .tax:
            switch lang {
            case .russian: return "Налоги"
            case .dutch:   return "Belastingen"
            case .english: return rawValue
            }
        case .latePayment:
            switch lang {
            case .russian: return "Просрочка оплаты"
            case .dutch:   return "Te late betaling"
            case .english: return rawValue
            }
        case .municipalityRegistration:
            switch lang {
            case .russian: return "Регистрация в gemeente"
            case .dutch:   return "Gemeentelijke inschrijving"
            case .english: return rawValue
            }
        case .parking:
            switch lang {
            case .russian: return "Парковка"
            case .dutch:   return "Parkeren"
            case .english: return rawValue
            }
        case .wasteDisposal:
            switch lang {
            case .russian: return "Утилизация мусора"
            case .dutch:   return "Afvalverwijdering"
            case .english: return rawValue
            }
        case .drivingLicence:
            switch lang {
            case .russian: return "Водительские права"
            case .dutch:   return "Rijbewijs"
            case .english: return rawValue
            }
        case .officialLetters:
            switch lang {
            case .russian: return "Официальные письма"
            case .dutch:   return "Officiële brieven"
            case .english: return rawValue
            }
        }
    }
}

enum FineSeverity: String, CaseIterable, Identifiable {
    case informational = "Informational"
    case moderate = "Moderate"
    case high = "High"

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .informational:
            switch lang {
            case .russian: return "Информационный"
            case .dutch:   return "Informatief"
            case .english: return rawValue
            }
        case .moderate:
            switch lang {
            case .russian: return "Умеренный"
            case .dutch:   return "Matig"
            case .english: return rawValue
            }
        case .high:
            switch lang {
            case .russian: return "Высокий"
            case .dutch:   return "Hoog"
            case .english: return rawValue
            }
        }
    }
}

struct FineInfoItem: Identifiable {
    let id: UUID
    let titleByLanguage: [AppLanguage: String]
    let category: FineCategory
    let simpleExplanationByLanguage: [AppLanguage: String]
    let possibleConsequenceByLanguage: [AppLanguage: String]
    let officialSourceName: String
    let officialSourceURL: URL
    let lastUpdated: Date
    let severity: FineSeverity
    let userActionByLanguage: [AppLanguage: String]
    let disclaimerByLanguage: [AppLanguage: String]
    let relatedInstitutionNames: [String]
    let relatedSearchAnswerIDs: [UUID]
    let relatedTermIDs: [UUID]
    let relatedMistakeIDs: [UUID]

    // Backward-compat for engine matching
    var title: String { titleByLanguage[.english] ?? titleByLanguage[.russian] ?? "" }
    var simpleExplanation: String { simpleExplanationByLanguage[.english] ?? simpleExplanationByLanguage[.russian] ?? "" }
    var possibleConsequence: String { possibleConsequenceByLanguage[.english] ?? possibleConsequenceByLanguage[.russian] ?? "" }
    var userAction: String { userActionByLanguage[.english] ?? userActionByLanguage[.russian] ?? "" }
    var disclaimer: String { disclaimerByLanguage[.english] ?? disclaimerByLanguage[.russian] ?? "" }
    var personaTags: Set<PersonaTag> {
        switch category {
        case .tax:
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .municipalityRegistration, .officialLetters:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .drivingLicence, .traffic, .parking:
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        case .healthInsurance:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .publicTransport:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        case .latePayment, .wasteDisposal:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }

    func title(_ language: AppLanguage) -> String {
        localized(titleByLanguage, language: language)
    }

    func simpleExplanation(_ language: AppLanguage) -> String {
        localized(simpleExplanationByLanguage, language: language)
    }

    func possibleConsequence(_ language: AppLanguage) -> String {
        localized(possibleConsequenceByLanguage, language: language)
    }

    func userAction(_ language: AppLanguage) -> String {
        localized(userActionByLanguage, language: language)
    }

    func disclaimer(_ language: AppLanguage) -> String {
        localized(disclaimerByLanguage, language: language)
    }

    private func localized(_ values: [AppLanguage: String], language: AppLanguage) -> String {
        if let requested = values[language], !requested.isEmpty { return requested }
        if let english = values[.english], !english.isEmpty { return english }
        return values.values.first(where: { !$0.isEmpty }) ?? ""
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    init(
        id: UUID,
        titleByLanguage: [AppLanguage: String],
        category: FineCategory,
        simpleExplanationByLanguage: [AppLanguage: String],
        possibleConsequenceByLanguage: [AppLanguage: String],
        officialSourceName: String,
        officialSourceURL: URL,
        lastUpdated: Date,
        severity: FineSeverity,
        userActionByLanguage: [AppLanguage: String],
        disclaimerByLanguage: [AppLanguage: String],
        relatedInstitutionNames: [String] = [],
        relatedSearchAnswerIDs: [UUID] = [],
        relatedTermIDs: [UUID] = [],
        relatedMistakeIDs: [UUID] = []
    ) {
        self.id = id
        self.titleByLanguage = titleByLanguage
        self.category = category
        self.simpleExplanationByLanguage = simpleExplanationByLanguage
        self.possibleConsequenceByLanguage = possibleConsequenceByLanguage
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.lastUpdated = lastUpdated
        self.severity = severity
        self.userActionByLanguage = userActionByLanguage
        self.disclaimerByLanguage = disclaimerByLanguage
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedSearchAnswerIDs = relatedSearchAnswerIDs
        self.relatedTermIDs = relatedTermIDs
        self.relatedMistakeIDs = relatedMistakeIDs
    }
}
