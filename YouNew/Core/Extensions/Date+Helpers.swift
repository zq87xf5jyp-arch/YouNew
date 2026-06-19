import Foundation

enum DateHelpers {
    static func daysFromNow(_ days: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
}

extension AppLanguage {
    var localeIdentifier: String {
        switch self {
        case .english: return "en_US"
        case .dutch: return "nl_NL"
        case .russian: return "ru_RU"
        }
    }
}

extension Date {
    func formattedForAppLanguage(_ language: AppLanguage) -> String {
        formatted(
            .dateTime
                .locale(Locale(identifier: language.localeIdentifier))
                .day()
                .month(.abbreviated)
                .year()
        )
    }
}
