import Foundation

enum CivicLearningSection: String, CaseIterable, Identifiable {
    case history
    case monarchy
    case politics
    case society
    case glossary
    case quiz

    var id: String { rawValue }

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.history, .dutch): return "Geschiedenis"
        case (.history, .russian): return "История"
        case (.history, _): return "History"
        case (.monarchy, .dutch): return "Monarchie"
        case (.monarchy, .russian): return "Монархия"
        case (.monarchy, _): return "Monarchy"
        case (.politics, .dutch): return "Politiek"
        case (.politics, .russian): return "Политика и государство"
        case (.politics, _): return "Politics"
        case (.society, .dutch): return "Samenleving"
        case (.society, .russian): return "Общество"
        case (.society, _): return "Society"
        case (.glossary, .dutch): return "Woordenlijst"
        case (.glossary, .russian): return "Словарь"
        case (.glossary, _): return "Glossary"
        case (.quiz, .dutch): return "Quiz"
        case (.quiz, .russian): return "Проверка"
        case (.quiz, _): return "Quiz"
        }
    }

    var symbol: String {
        switch self {
        case .history: return "book.closed.fill"
        case .monarchy: return "crown.fill"
        case .politics: return "building.columns.fill"
        case .society: return "person.3.sequence.fill"
        case .glossary: return "text.book.closed.fill"
        case .quiz: return "checkmark.seal.fill"
        }
    }
}

enum CivicDifficulty: String {
    case beginner
    case intermediate

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.beginner, .dutch): return "Beginner"
        case (.beginner, .russian): return "Начальный"
        case (.beginner, _): return "Beginner"
        case (.intermediate, .dutch): return "Gemiddeld"
        case (.intermediate, .russian): return "Средний"
        case (.intermediate, _): return "Intermediate"
        }
    }
}

struct CivicTimelineItem: Identifiable, Hashable {
    let id: String
    let localizationKey: String
    let symbol: String
    let difficulty: CivicDifficulty

    func period(_ lang: AppLanguage) -> String { L10n.t("\(localizationKey).date", lang) }
    func title(_ lang: AppLanguage) -> String { L10n.t("\(localizationKey).title", lang) }
    func summary(_ lang: AppLanguage) -> String { L10n.t("\(localizationKey).summary", lang) }
    func details(_ lang: AppLanguage) -> String { L10n.t("\(localizationKey).details", lang) }
    func whyItMatters(_ lang: AppLanguage) -> String { L10n.t("\(localizationKey).whyItMatters", lang) }
}

struct CivicInfoCardItem: Identifiable, Hashable {
    let id: String
    let section: CivicLearningSection
    let titleEN: String
    let titleNL: String
    let titleRU: String
    let summaryEN: String
    let summaryNL: String
    let summaryRU: String
    let detailEN: String
    let detailNL: String
    let detailRU: String
    let symbol: String
    let difficulty: CivicDifficulty
    let sourceURL: URL?
    let keywords: [String]

    func title(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return titleEN
        case .dutch: return titleNL
        case .russian: return titleRU
        }
    }

    func summary(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return summaryEN
        case .dutch: return summaryNL
        case .russian: return summaryRU
        }
    }

    func detail(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return detailEN
        case .dutch: return detailNL
        case .russian: return detailRU
        }
    }
    var saveKey: String { "civic::\(id)" }
}

struct LocalizedInfoText: Hashable, Sendable {
    let english: String
    let dutch: String
    let russian: String

    func value(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}

struct InfoSourceMetadata: Identifiable, Hashable {
    let id: String
    let title: String
    let institution: String
    let url: URL
    let sourceType: String
}

enum InfoArticleType: String, Hashable {
    case culture
    case attraction
}

struct InfoArticle: Identifiable {
    let id: String
    let type: InfoArticleType
    let title: LocalizedInfoText
    let subtitle: LocalizedInfoText
    let summary: LocalizedInfoText
    let practicalNote: LocalizedInfoText
    let relatedPlaceIds: [String]
    let tags: [String]
    let sources: [InfoSourceMetadata]
    let image: AppImageAsset?
    let readingTimeMinutes: Int?
    let updatedAt: String
    let verified: Bool
    let symbol: String
}

struct CityInfoProfile: Identifiable {
    let cityId: String
    let title: LocalizedInfoText
    let subtitle: LocalizedInfoText
    let summary: LocalizedInfoText
    let provinceId: String
    let populationText: String?
    let areaText: String?
    let municipalityWebsite: URL?
    let practicalGuideIds: [String]
    let attractionIds: [String]
    let articleIds: [String]
    let officialSourceIds: [String]
    let updatedAt: String
    let verified: Bool

    var id: String { cityId }
}

struct ProvinceInfoProfile: Identifiable {
    let provinceId: String
    let title: LocalizedInfoText
    let summary: LocalizedInfoText
    let capital: String
    let officialSourceIds: [String]
    let updatedAt: String
    let verified: Bool

    var id: String { provinceId }
}

struct SourceValidationIssue: Identifiable, Hashable {
    let id: String
    let ownerId: String
    let sourceId: String
    let message: String
}

struct CivicGlossaryTerm: Identifiable, Hashable {
    let id: String
    let term: String
    let dutchTerm: String
    let definitionEN: String
    let definitionNL: String
    let definitionRU: String
    let exampleEN: String
    let exampleNL: String
    let exampleRU: String
    let keywords: [String]

    func displayTerm(_ lang: AppLanguage) -> String { lang == .dutch ? dutchTerm : term }
    func definition(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return definitionEN
        case .dutch: return definitionNL
        case .russian: return definitionRU
        }
    }

    func example(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return exampleEN
        case .dutch: return exampleNL
        case .russian: return exampleRU
        }
    }
}

struct CivicQuizQuestion: Identifiable, Hashable {
    let id: String
    let questionEN: String
    let questionNL: String
    let questionRU: String
    let optionsEN: [String]
    let optionsNL: [String]
    let optionsRU: [String]
    let correctIndex: Int
    let explanationEN: String
    let explanationNL: String
    let explanationRU: String

    func question(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return questionEN
        case .dutch: return questionNL
        case .russian: return questionRU
        }
    }

    func options(_ lang: AppLanguage) -> [String] {
        switch lang {
        case .english: return optionsEN
        case .dutch: return optionsNL
        case .russian: return optionsRU
        }
    }

    func explanation(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return explanationEN
        case .dutch: return explanationNL
        case .russian: return explanationRU
        }
    }
}
