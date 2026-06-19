import Foundation

enum DutchTermCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case administrative
    case legal
    case financial
    case immigration
    case social
    case healthcare
    case transport
    case housing
    case work

    var id: String { rawValue }

    func localizedTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return rawValue.capitalized
        case .dutch: return rawValue.capitalized
        case .russian: return rawValue.capitalized
        }
    }
}

struct DutchTerm: Identifiable, Hashable {
    let id: UUID
    let dutchTerm: String
    let englishExplanation: String
    let dutchExplanation: String
    let russianExplanation: String
    let newcomerExplanation: String
    let newcomerExplanationNL: String
    let newcomerExplanationRU: String
    let category: DutchTermCategory
    let hasLegalFinancialWarning: Bool
    let officialSourceURL: URL?
    let officialSourceName: String?
    let relatedInstitutionNames: [String]
    let relatedSearchAnswerIDs: [UUID]
    let relatedLetterTitles: [String]
    let relatedMistakeIDs: [UUID]
    var personaTags: Set<PersonaTag> {
        switch category {
        case .work:
            return [.worker, .highlySkilledMigrant, .entrepreneur]
        case .immigration:
            return [.refugee, .nonEU, .highlySkilledMigrant, .lgbt]
        case .financial:
            return dutchTerm.caseInsensitiveCompare("DUO") == .orderedSame || officialSourceName?.localizedCaseInsensitiveContains("DUO") == true
                ? [.student, .refugee]
                : [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        case .legal:
            return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .administrative:
            if dutchTerm.localizedCaseInsensitiveContains("DigiD") || dutchTerm.localizedCaseInsensitiveContains("BSN") {
                return [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
            }
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .healthcare:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        case .transport:
            return [.student, .worker, .refugee, .family, .tourist, .eu, .highlySkilledMigrant, .lgbt]
        case .housing:
            return [.student, .worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .lgbt]
        case .social:
            return [.refugee, .family, .lgbt]
        }
    }

    func localizedExplanation(_ language: AppLanguage) -> String {
        switch language {
        case .english: return englishExplanation
        case .dutch: return dutchExplanation
        case .russian: return russianExplanation
        }
    }

    func localizedNewcomerExplanation(_ language: AppLanguage) -> String {
        switch language {
        case .english: return newcomerExplanation
        case .dutch: return newcomerExplanationNL
        case .russian: return newcomerExplanationRU
        }
    }

    func isVisible(for persona: PersonaTag?, scope: PersonaSearchScope = .currentAndUniversal) -> Bool {
        PersonaContentPolicy.isVisible(tags: personaTags, activePersona: persona, scope: scope)
    }
}
