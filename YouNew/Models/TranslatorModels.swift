import Foundation

enum TranslationLanguage: String, CaseIterable, Identifiable {
    case dutch = "Dutch"
    case english = "English"
    case ukrainian = "Ukrainian"
    case russian = "Russian"
    case arabic = "Arabic"
    case turkish = "Turkish"
    case polish = "Polish"

    var id: String { rawValue }

    var code: String {
        switch self {
        case .dutch: return "nl"
        case .english: return "en"
        case .ukrainian: return "uk"
        case .russian: return "ru"
        case .arabic: return "ar"
        case .turkish: return "tr"
        case .polish: return "pl"
        }
    }
}

struct TranslationResult: Identifiable, Codable {
    let id: UUID
    let sourceText: String
    let translatedText: String
    let fromLanguage: String
    let toLanguage: String
    let simpleExplanation: String
    let detectedInstitution: String
    let possibleDates: [String]
    let createdAt: Date
}
