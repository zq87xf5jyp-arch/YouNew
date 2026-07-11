import Foundation

enum SearchCategory: String, CaseIterable, Identifiable {
    case registration
    case digid
    case immigration
    case taxes
    case fines
    case healthInsurance
    case work
    case education
    case housing
    case transport
    case legalHelp
    case emergency
    case general

    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .registration:   return L10n.t("search.category.registration", lang)
        case .digid:          return "DigiD"
        case .immigration:    return L10n.t("search.category.immigration", lang)
        case .taxes:          return L10n.t("search.category.taxes", lang)
        case .fines:          return L10n.t("search.category.fines", lang)
        case .healthInsurance: return L10n.t("search.category.health_insurance", lang)
        case .work:           return L10n.t("search.category.work", lang)
        case .education:      return L10n.t("search.category.education", lang)
        case .housing:        return L10n.t("search.category.housing", lang)
        case .transport:      return L10n.t("search.category.transport", lang)
        case .legalHelp:      return L10n.t("search.category.legal_help", lang)
        case .emergency:      return L10n.t("search.category.emergency", lang)
        case .general:        return L10n.t("search.category.general", lang)
        }
    }

    var needsSafetyNote: Bool {
        switch self {
        case .immigration, .legalHelp, .taxes, .fines, .work: return true
        default: return false
        }
    }

    func isVisible(for persona: PersonaTag?) -> Bool {
        guard let persona else { return false }
        switch persona {
        case .student:
            return [.registration, .digid, .education, .housing, .healthInsurance, .transport, .general].contains(self)
        case .worker:
            return [.registration, .digid, .taxes, .healthInsurance, .work, .housing, .transport, .legalHelp, .general].contains(self)
        case .refugee:
            return [.registration, .digid, .immigration, .healthInsurance, .education, .housing, .transport, .legalHelp, .emergency, .general].contains(self)
        case .family:
            return [.registration, .digid, .healthInsurance, .education, .housing, .transport, .emergency, .general].contains(self)
        case .highlySkilledMigrant:
            return [.registration, .digid, .immigration, .taxes, .healthInsurance, .work, .housing, .transport, .education, .general].contains(self)
        case .eu:
            return [.registration, .digid, .taxes, .healthInsurance, .work, .education, .housing, .transport, .general].contains(self)
        case .tourist:
            return [.healthInsurance, .transport, .emergency, .general].contains(self)
        case .entrepreneur:
            return [.registration, .digid, .taxes, .healthInsurance, .work, .housing, .transport, .legalHelp, .general].contains(self)
        case .lgbt:
            return [.registration, .digid, .healthInsurance, .housing, .legalHelp, .emergency, .general].contains(self)
        case .nonEU:
            return true
        case .universal:
            return self == .general
        }
    }
}

struct SearchAnswer: Identifiable {
    let id: UUID
    let titleByLanguage: [AppLanguage: String]
    let shortAnswerByLanguage: [AppLanguage: String]
    let detailedAnswerByLanguage: [AppLanguage: String]
    let keywordsByLanguage: [AppLanguage: [String]]
    let category: SearchCategory
    let relatedInstitution: String?
    let officialSourceName: String
    let officialSourceURL: URL
    let isOfficialSource: Bool
    let safetyNote: String?
    let lastUpdated: Date
    let relatedQuestions: [String]
    let relatedTermIDs: [UUID]
    let relatedFineIDs: [UUID]
    let relatedInstitutionNames: [String]
    let relatedMistakeIDs: [UUID]
    let nextRecommendedStep: String?
    let personaTags: Set<PersonaTag>

    var question: String { title(.english) }
    var shortAnswer: String { shortAnswer(.english) }
    var detailedAnswer: String { detailedAnswer(.english) }
    var keywords: [String] { keywords(.english) }

    init(
        id: UUID,
        question: String,
        keywords: [String],
        category: SearchCategory,
        shortAnswer: String,
        detailedAnswer: String,
        relatedInstitution: String?,
        officialSourceName: String,
        officialSourceURL: URL,
        isOfficialSource: Bool,
        safetyNote: String?,
        lastUpdated: Date,
        relatedQuestions: [String],
        relatedTermIDs: [UUID] = [],
        relatedFineIDs: [UUID] = [],
        relatedInstitutionNames: [String] = [],
        relatedMistakeIDs: [UUID] = [],
        nextRecommendedStep: String? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        let resolvedTitle = Self.visibleTextMap(from: question)
        let resolvedShortAnswer = Self.visibleTextMap(from: shortAnswer)
        let resolvedDetailedAnswer = Self.visibleTextMap(from: detailedAnswer)
        let resolvedKeywords: [AppLanguage: [String]] = [
            .english: keywords,
            .russian: keywords,
            .dutch: keywords
        ]
        self.titleByLanguage = resolvedTitle
        self.shortAnswerByLanguage = resolvedShortAnswer
        self.detailedAnswerByLanguage = resolvedDetailedAnswer
        self.keywordsByLanguage = resolvedKeywords
        self.category = category
        self.relatedInstitution = relatedInstitution
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.isOfficialSource = isOfficialSource
        self.safetyNote = safetyNote
        self.lastUpdated = lastUpdated
        self.relatedQuestions = relatedQuestions
        self.relatedTermIDs = relatedTermIDs
        self.relatedFineIDs = relatedFineIDs
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedMistakeIDs = relatedMistakeIDs
        self.nextRecommendedStep = nextRecommendedStep
        self.personaTags = Self.assignedPersonaTags(
            explicitTags: personaTags,
            category: category,
            titleByLanguage: resolvedTitle,
            shortAnswerByLanguage: resolvedShortAnswer,
            detailedAnswerByLanguage: resolvedDetailedAnswer,
            keywordsByLanguage: resolvedKeywords,
            officialSourceName: officialSourceName,
            officialSourceURL: officialSourceURL,
            relatedInstitution: relatedInstitution
        )
    }

    init(
        id: UUID,
        titleByLanguage: [AppLanguage: String],
        keywordsByLanguage: [AppLanguage: [String]],
        category: SearchCategory,
        shortAnswerByLanguage: [AppLanguage: String],
        detailedAnswerByLanguage: [AppLanguage: String],
        relatedInstitution: String?,
        officialSourceName: String,
        officialSourceURL: URL,
        isOfficialSource: Bool,
        safetyNote: String?,
        lastUpdated: Date,
        relatedQuestions: [String],
        relatedTermIDs: [UUID] = [],
        relatedFineIDs: [UUID] = [],
        relatedInstitutionNames: [String] = [],
        relatedMistakeIDs: [UUID] = [],
        nextRecommendedStep: String? = nil,
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.titleByLanguage = titleByLanguage
        self.keywordsByLanguage = keywordsByLanguage
        self.category = category
        self.shortAnswerByLanguage = shortAnswerByLanguage
        self.detailedAnswerByLanguage = detailedAnswerByLanguage
        self.relatedInstitution = relatedInstitution
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.isOfficialSource = isOfficialSource
        self.safetyNote = safetyNote
        self.lastUpdated = lastUpdated
        self.relatedQuestions = relatedQuestions
        self.relatedTermIDs = relatedTermIDs
        self.relatedFineIDs = relatedFineIDs
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedMistakeIDs = relatedMistakeIDs
        self.nextRecommendedStep = nextRecommendedStep
        self.personaTags = Self.assignedPersonaTags(
            explicitTags: personaTags,
            category: category,
            titleByLanguage: titleByLanguage,
            shortAnswerByLanguage: shortAnswerByLanguage,
            detailedAnswerByLanguage: detailedAnswerByLanguage,
            keywordsByLanguage: keywordsByLanguage,
            officialSourceName: officialSourceName,
            officialSourceURL: officialSourceURL,
            relatedInstitution: relatedInstitution
        )
    }
}

extension SearchAnswer {
    static func stableID(_ key: String) -> UUID {
        StableRouteID.uuid(key)
    }

    func title(_ lang: AppLanguage) -> String {
        localizedVisibleText(titleByLanguage, lang: lang)
    }

    func shortAnswer(_ lang: AppLanguage) -> String {
        localizedVisibleText(shortAnswerByLanguage, lang: lang)
    }

    func detailedAnswer(_ lang: AppLanguage) -> String {
        localizedVisibleText(detailedAnswerByLanguage, lang: lang)
    }

    func keywords(_ lang: AppLanguage) -> [String] {
        keywordsByLanguage[lang] ?? keywordsByLanguage[.english] ?? []
    }

    func localizedQuestion(_ lang: AppLanguage) -> String {
        title(lang)
    }

    func localizedShortAnswer(_ lang: AppLanguage) -> String {
        shortAnswer(lang)
    }

    func localizedDetailedAnswer(_ lang: AppLanguage) -> String {
        detailedAnswer(lang)
    }

    func localizedSafetyNote(_ lang: AppLanguage) -> String? {
        guard safetyNote != nil else { return nil }
        switch lang {
        case .russian:
            return "Это общая справочная информация. Для личных решений проверяйте официальный источник или консультируйтесь со специалистом."
        case .dutch:
            return "Dit is algemene informatie. Controleer voor persoonlijke beslissingen de officiële bron of raadpleeg een deskundige."
        case .english:
            return safetyNote
        }
    }

    func effectivePersonaTags(language: AppLanguage = .english) -> Set<PersonaTag> {
        personaTags
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        true
    }

    private func localizedVisibleText(_ values: [AppLanguage: String], lang: AppLanguage) -> String {
        if let value = values[lang], !value.isEmpty { return value }
        if let english = values[.english], !english.isEmpty { return english }
        return ""
    }

    private static func visibleTextMap(from text: String) -> [AppLanguage: String] {
        if containsCyrillic(text) {
            return [.russian: text, .english: text, .dutch: text]
        }
        return [.english: text]
    }

    private static func assignedPersonaTags(
        explicitTags: Set<PersonaTag>,
        category: SearchCategory,
        titleByLanguage: [AppLanguage: String],
        shortAnswerByLanguage: [AppLanguage: String],
        detailedAnswerByLanguage: [AppLanguage: String],
        keywordsByLanguage: [AppLanguage: [String]],
        officialSourceName: String,
        officialSourceURL: URL,
        relatedInstitution: String?
    ) -> Set<PersonaTag> {
        PersonaContentPolicy.assignedTags(
            explicitTags: explicitTags,
            category: category.rawValue,
            title: titleByLanguage[.english] ?? titleByLanguage.values.first ?? "",
            summary: [
                shortAnswerByLanguage[.english] ?? shortAnswerByLanguage.values.first ?? "",
                detailedAnswerByLanguage[.english] ?? detailedAnswerByLanguage.values.first ?? ""
            ].joined(separator: " "),
            keywords: keywordsByLanguage[.english] ?? Array(keywordsByLanguage.values.joined()),
            sources: [OfficialSource(title: officialSourceName, url: officialSourceURL, institution: relatedInstitution)]
        )
    }

    private static func containsCyrillic(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(Int(scalar.value))
        }
    }
}
