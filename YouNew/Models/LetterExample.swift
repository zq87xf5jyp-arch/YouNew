import Foundation

nonisolated struct LetterExample: Identifiable {
    let id = UUID()
    let titleByLanguage: [AppLanguage: String]
    let institutionNameByLanguage: [AppLanguage: String]
    let simplifiedExplanationByLanguage: [AppLanguage: String]
    let possibleDeadlineByLanguage: [AppLanguage: String]
    let safeNextStepByLanguage: [AppLanguage: String]
    let officialSourceReminderByLanguage: [AppLanguage: String]
    let relatedInstitutionNames: [String]
    let relatedTermIDs: [UUID]
    let relatedFineIDs: [UUID]
    let relatedMistakeIDs: [UUID]
    let personaTags: Set<PersonaTag>

    var title: String { title(.english) }
    var institutionName: String { institutionName(.english) }
    var simplifiedExplanation: String { simplifiedExplanation(.english) }
    var possibleDeadline: String { possibleDeadline(.english) }
    var safeNextStep: String { safeNextStep(.english) }
    var officialSourceReminder: String { officialSourceReminder(.english) }

    init(
        title: String,
        institutionName: String,
        simplifiedExplanation: String,
        possibleDeadline: String,
        safeNextStep: String,
        officialSourceReminder: String,
        relatedInstitutionNames: [String] = [],
        relatedTermIDs: [UUID] = [],
        relatedFineIDs: [UUID] = [],
        relatedMistakeIDs: [UUID] = [],
        personaTags: Set<PersonaTag> = []
    ) {
        self.titleByLanguage = Self.map(english: title, russian: title, dutch: title)
        self.institutionNameByLanguage = Self.map(english: institutionName, russian: institutionName, dutch: institutionName)
        self.simplifiedExplanationByLanguage = Self.map(english: simplifiedExplanation, russian: simplifiedExplanation, dutch: simplifiedExplanation)
        self.possibleDeadlineByLanguage = Self.map(english: possibleDeadline, russian: possibleDeadline, dutch: possibleDeadline)
        self.safeNextStepByLanguage = Self.map(english: safeNextStep, russian: safeNextStep, dutch: safeNextStep)
        self.officialSourceReminderByLanguage = Self.map(english: officialSourceReminder, russian: officialSourceReminder, dutch: officialSourceReminder)
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedTermIDs = relatedTermIDs
        self.relatedFineIDs = relatedFineIDs
        self.relatedMistakeIDs = relatedMistakeIDs
        self.personaTags = Self.assignedTags(explicitTags: personaTags, title: title, institutionName: institutionName)
    }

    init(
        title: [AppLanguage: String],
        institutionName: [AppLanguage: String],
        simplifiedExplanation: [AppLanguage: String],
        possibleDeadline: [AppLanguage: String],
        safeNextStep: [AppLanguage: String],
        officialSourceReminder: [AppLanguage: String],
        relatedInstitutionNames: [String] = [],
        relatedTermIDs: [UUID] = [],
        relatedFineIDs: [UUID] = [],
        relatedMistakeIDs: [UUID] = [],
        personaTags: Set<PersonaTag> = []
    ) {
        self.titleByLanguage = title
        self.institutionNameByLanguage = institutionName
        self.simplifiedExplanationByLanguage = simplifiedExplanation
        self.possibleDeadlineByLanguage = possibleDeadline
        self.safeNextStepByLanguage = safeNextStep
        self.officialSourceReminderByLanguage = officialSourceReminder
        self.relatedInstitutionNames = relatedInstitutionNames
        self.relatedTermIDs = relatedTermIDs
        self.relatedFineIDs = relatedFineIDs
        self.relatedMistakeIDs = relatedMistakeIDs
        self.personaTags = Self.assignedTags(
            explicitTags: personaTags,
            title: title[.english] ?? title.values.first ?? "",
            institutionName: institutionName[.english] ?? institutionName.values.first ?? ""
        )
    }

    func title(_ language: AppLanguage) -> String {
        localized(titleByLanguage, language: language)
    }

    func institutionName(_ language: AppLanguage) -> String {
        localized(institutionNameByLanguage, language: language)
    }

    func simplifiedExplanation(_ language: AppLanguage) -> String {
        localized(simplifiedExplanationByLanguage, language: language)
    }

    func possibleDeadline(_ language: AppLanguage) -> String {
        localized(possibleDeadlineByLanguage, language: language)
    }

    func safeNextStep(_ language: AppLanguage) -> String {
        localized(safeNextStepByLanguage, language: language)
    }

    func officialSourceReminder(_ language: AppLanguage) -> String {
        localized(officialSourceReminderByLanguage, language: language)
    }

    private func localized(_ values: [AppLanguage: String], language: AppLanguage) -> String {
        if let value = values[language], !value.isEmpty { return value }
        if let english = values[.english], !english.isEmpty { return english }
        return values.values.first(where: { !$0.isEmpty }) ?? ""
    }

    private static func map(english: String, russian: String, dutch: String) -> [AppLanguage: String] {
        [.english: english, .russian: russian, .dutch: dutch]
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    private static func assignedTags(explicitTags: Set<PersonaTag>, title: String, institutionName: String) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        let haystack = "\(title) \(institutionName)".folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX")).lowercased()
        if haystack.contains("duo") {
            return [.student, .refugee]
        }
        if haystack.contains("belasting") {
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if haystack.contains("cjib") || haystack.contains("fine") || haystack.contains("boete") {
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if haystack.contains("gemeente") || haystack.contains("municipality") {
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
        if haystack.contains("health") || haystack.contains("zorg") || haystack.contains("insurance") {
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
        if haystack.contains("housing") || haystack.contains("huur") || haystack.contains("rental") {
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        }
        return [.universal]
    }
}
