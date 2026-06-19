import Foundation

struct BeginnerGuideItem: Identifiable, Hashable {
    let id: UUID
    let category: BeginnerGuideCategory
    let titleByLanguage: [AppLanguage: String]
    let descriptionByLanguage: [AppLanguage: String]
    let simpleAnswerByLanguage: [AppLanguage: String]
    let whyItMattersByLanguage: [AppLanguage: String]
    let whatToCheckByLanguage: [AppLanguage: [String]]
    let commonMistakeByLanguage: [AppLanguage: String]
    let safeNextStepByLanguage: [AppLanguage: String]
    let officialSourceName: String
    let officialSourceURL: URL?
    let keywordsByLanguage: [AppLanguage: [String]]
    let relatedTopics: [String]
    let riskLevel: RiskLevel
    let lastUpdated: Date
    let personaTags: Set<PersonaTag>

    init(
        id: UUID = UUID(),
        category: BeginnerGuideCategory,
        titleByLanguage: [AppLanguage: String],
        descriptionByLanguage: [AppLanguage: String],
        simpleAnswerByLanguage: [AppLanguage: String],
        whyItMattersByLanguage: [AppLanguage: String],
        whatToCheckByLanguage: [AppLanguage: [String]],
        commonMistakeByLanguage: [AppLanguage: String],
        safeNextStepByLanguage: [AppLanguage: String],
        officialSourceName: String,
        officialSourceURL: URL?,
        keywordsByLanguage: [AppLanguage: [String]] = [:],
        relatedTopics: [String] = [],
        riskLevel: RiskLevel = .low,
        lastUpdated: Date = Date(),
        personaTags: Set<PersonaTag> = []
    ) {
        self.id = id
        self.category = category
        self.titleByLanguage = titleByLanguage
        self.descriptionByLanguage = descriptionByLanguage
        self.simpleAnswerByLanguage = simpleAnswerByLanguage
        self.whyItMattersByLanguage = whyItMattersByLanguage
        self.whatToCheckByLanguage = whatToCheckByLanguage
        self.commonMistakeByLanguage = commonMistakeByLanguage
        self.safeNextStepByLanguage = safeNextStepByLanguage
        self.officialSourceName = officialSourceName
        self.officialSourceURL = officialSourceURL
        self.keywordsByLanguage = keywordsByLanguage
        self.relatedTopics = relatedTopics
        self.riskLevel = riskLevel
        self.lastUpdated = lastUpdated
        self.personaTags = PersonaContentPolicy.assignedTags(
            explicitTags: personaTags,
            category: category.rawValue,
            title: titleByLanguage[.english] ?? titleByLanguage.values.first ?? "",
            summary: [
                descriptionByLanguage[.english] ?? descriptionByLanguage.values.first ?? "",
                simpleAnswerByLanguage[.english] ?? simpleAnswerByLanguage.values.first ?? "",
                whyItMattersByLanguage[.english] ?? whyItMattersByLanguage.values.first ?? "",
                commonMistakeByLanguage[.english] ?? commonMistakeByLanguage.values.first ?? "",
                safeNextStepByLanguage[.english] ?? safeNextStepByLanguage.values.first ?? ""
            ].joined(separator: " "),
            keywords: keywordsByLanguage[.english] ?? Array(keywordsByLanguage.values.joined()) + relatedTopics,
            sources: [OfficialSource(title: officialSourceName, url: officialSourceURL, institution: officialSourceName)]
        )
    }

    func title(_ language: AppLanguage) -> String {
        titleByLanguage[language] ?? titleByLanguage[.english] ?? ""
    }

    func description(_ language: AppLanguage) -> String {
        descriptionByLanguage[language] ?? descriptionByLanguage[.english] ?? ""
    }

    func simpleAnswer(_ language: AppLanguage) -> String {
        simpleAnswerByLanguage[language] ?? simpleAnswerByLanguage[.english] ?? ""
    }

    func whyItMatters(_ language: AppLanguage) -> String {
        whyItMattersByLanguage[language] ?? whyItMattersByLanguage[.english] ?? ""
    }

    func whatToCheck(_ language: AppLanguage) -> [String] {
        whatToCheckByLanguage[language] ?? whatToCheckByLanguage[.english] ?? []
    }

    func commonMistake(_ language: AppLanguage) -> String {
        commonMistakeByLanguage[language] ?? commonMistakeByLanguage[.english] ?? ""
    }

    func safeNextStep(_ language: AppLanguage) -> String {
        safeNextStepByLanguage[language] ?? safeNextStepByLanguage[.english] ?? ""
    }

    func keywords(_ language: AppLanguage) -> [String] {
        keywordsByLanguage[language] ?? keywordsByLanguage[.english] ?? []
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}
