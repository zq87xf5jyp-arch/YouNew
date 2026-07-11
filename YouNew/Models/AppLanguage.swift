import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case english = "en"
    case dutch = "nl"
    case russian = "ru"

    var id: String { rawValue }

    static var preferredSupported: AppLanguage {
        return .english
    }

    static var releasePriority: [AppLanguage] {
        [.english, .dutch, .russian]
    }
}
