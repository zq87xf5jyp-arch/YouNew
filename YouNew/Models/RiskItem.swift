import Foundation

enum RiskSection: String, CaseIterable {
    case topMistakes = "Common mistakes"
    case fines = "Possible fines"
    case scams = "Scam warnings"
    case reminders = "Important reminders"

    func localized(_ language: AppLanguage) -> String {
        switch self {
        case .topMistakes:
            switch language {
            case .russian: return "Частые ошибки"
            case .dutch: return "Veelgemaakte fouten"
            case .english: return rawValue
            }
        case .fines:
            switch language {
            case .russian: return "Возможные штрафы"
            case .dutch: return "Mogelijke boetes"
            case .english: return rawValue
            }
        case .scams:
            switch language {
            case .russian: return "Мошенничество"
            case .dutch: return "Oplichting"
            case .english: return rawValue
            }
        case .reminders:
            switch language {
            case .russian: return "Важные напоминания"
            case .dutch: return "Belangrijke herinneringen"
            case .english: return rawValue
            }
        }
    }
}

struct RiskItem: Identifiable {
    let id = UUID()
    let titleByLanguage: [AppLanguage: String]
    let possibleIssueByLanguage: [AppLanguage: String]
    let possibleConsequenceByLanguage: [AppLanguage: String]
    let verifyRuleByLanguage: [AppLanguage: String]
    let section: RiskSection
    let personaTags: Set<PersonaTag>

    init(
        title: [AppLanguage: String],
        possibleIssue: [AppLanguage: String],
        possibleConsequence: [AppLanguage: String],
        verifyRule: [AppLanguage: String],
        section: RiskSection,
        personaTags: Set<PersonaTag> = []
    ) {
        self.titleByLanguage = title
        self.possibleIssueByLanguage = possibleIssue
        self.possibleConsequenceByLanguage = possibleConsequence
        self.verifyRuleByLanguage = verifyRule
        self.section = section
        self.personaTags = Self.assignedPersonaTags(
            explicitTags: personaTags,
            section: section,
            title: title[.english] ?? title.values.first ?? "",
            detail: possibleIssue[.english] ?? possibleIssue.values.first ?? ""
        )
    }

    var title: String { title(.english) }
    var possibleIssue: String { possibleIssue(.english) }
    var possibleConsequence: String { possibleConsequence(.english) }
    var verifyRule: String { verifyRule(.english) }
    var detail: String { detail(.english) }

    func title(_ language: AppLanguage) -> String {
        localized(titleByLanguage, language: language)
    }

    func possibleIssue(_ language: AppLanguage) -> String {
        localized(possibleIssueByLanguage, language: language)
    }

    func possibleConsequence(_ language: AppLanguage) -> String {
        localized(possibleConsequenceByLanguage, language: language)
    }

    func verifyRule(_ language: AppLanguage) -> String {
        localized(verifyRuleByLanguage, language: language)
    }

    func detail(_ language: AppLanguage) -> String {
        switch language {
        case .russian:
            return "Возможная проблема: \(possibleIssue(language)) Возможное последствие: \(possibleConsequence(language)) \(verifyRule(language))"
        case .dutch:
            return "Mogelijk probleem: \(possibleIssue(language)) Mogelijk gevolg: \(possibleConsequence(language)) \(verifyRule(language))"
        case .english:
            return "Possible issue: \(possibleIssue(language)) Possible consequence: \(possibleConsequence(language)) \(verifyRule(language))"
        }
    }

    private func localized(_ values: [AppLanguage: String], language: AppLanguage) -> String {
        if let value = values[language], !value.isEmpty { return value }
        if let english = values[.english], !english.isEmpty { return english }
        return values.values.first(where: { !$0.isEmpty }) ?? ""
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }

    private static func assignedPersonaTags(explicitTags: Set<PersonaTag>, section: RiskSection, title: String, detail: String) -> Set<PersonaTag> {
        if !explicitTags.isEmpty { return explicitTags }
        let haystack = "\(section.rawValue) \(title) \(detail)"
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
        if haystack.contains("student") || haystack.contains("duo") || haystack.contains("study") {
            return [.student]
        }
        if haystack.contains("work") || haystack.contains("contract") || haystack.contains("uwv") || haystack.contains("salary") {
            return [.worker, .highlySkilledMigrant, .entrepreneur]
        }
        if haystack.contains("tax") || haystack.contains("belasting") || haystack.contains("toeslag") {
            return [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        }
        if haystack.contains("ind") || haystack.contains("asylum") || haystack.contains("refugee") || haystack.contains("residence permit") {
            return [.refugee, .nonEU, .highlySkilledMigrant]
        }
        if haystack.contains("child") || haystack.contains("school") || haystack.contains("family") {
            return [.family]
        }
        switch section {
        case .fines:
            return [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        case .scams:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .topMistakes, .reminders:
            return [.worker, .refugee, .family, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        }
    }
}
