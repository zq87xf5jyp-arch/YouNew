import Foundation

nonisolated struct Institution: Identifiable {
    let id = UUID()
    let name: String
    private let shortExplanationByLanguage: [AppLanguage: String]
    private let usageByLanguage: [AppLanguage: String]
    private let whenToUseByLanguage: [AppLanguage: String]
    private let commonConfusionByLanguage: [AppLanguage: String]
    let officialWebsiteURL: URL
    private let warningByLanguage: [AppLanguage: String]
    let relatedChecklistIDs: [UUID]
    let relatedTermIDs: [UUID]
    let relatedSearchAnswerIDs: [UUID]
    let relatedLetterTitles: [String]
    let personaTags: Set<PersonaTag>

    func shortExplanation(_ lang: AppLanguage) -> String {
        shortExplanationByLanguage[lang] ?? shortExplanationByLanguage[.english] ?? "—"
    }
    func usage(_ lang: AppLanguage) -> String {
        usageByLanguage[lang] ?? usageByLanguage[.english] ?? "—"
    }
    func whenToUse(_ lang: AppLanguage) -> String {
        whenToUseByLanguage[lang] ?? whenToUseByLanguage[.english] ?? "—"
    }
    func commonConfusion(_ lang: AppLanguage) -> String {
        commonConfusionByLanguage[lang] ?? commonConfusionByLanguage[.english] ?? "—"
    }
    func warning(_ lang: AppLanguage) -> String {
        warningByLanguage[lang] ?? warningByLanguage[.english] ?? "—"
    }

    init(
        name: String,
        shortExplanationByLanguage: [AppLanguage: String],
        usageByLanguage: [AppLanguage: String],
        whenToUseByLanguage: [AppLanguage: String],
        commonConfusionByLanguage: [AppLanguage: String],
        officialWebsiteURL: URL,
        warningByLanguage: [AppLanguage: String],
        relatedChecklistIDs: [UUID] = [],
        relatedTermIDs: [UUID] = [],
        relatedSearchAnswerIDs: [UUID] = [],
        relatedLetterTitles: [String] = [],
        personaTags: Set<PersonaTag> = []
    ) {
        self.name = name
        self.shortExplanationByLanguage = shortExplanationByLanguage
        self.usageByLanguage = usageByLanguage
        self.whenToUseByLanguage = whenToUseByLanguage
        self.commonConfusionByLanguage = commonConfusionByLanguage
        self.officialWebsiteURL = officialWebsiteURL
        self.warningByLanguage = warningByLanguage
        self.relatedChecklistIDs = relatedChecklistIDs
        self.relatedTermIDs = relatedTermIDs
        self.relatedSearchAnswerIDs = relatedSearchAnswerIDs
        self.relatedLetterTitles = relatedLetterTitles
        self.personaTags = PersonaContentPolicy.assignedTags(
            explicitTags: personaTags,
            category: "institution",
            title: name,
            summary: [
                shortExplanationByLanguage[.english],
                usageByLanguage[.english],
                whenToUseByLanguage[.english],
                commonConfusionByLanguage[.english]
            ].compactMap { $0 }.joined(separator: " "),
            keywords: [name],
            sources: [OfficialSource(title: name, url: officialWebsiteURL, institution: name)]
        )
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}
