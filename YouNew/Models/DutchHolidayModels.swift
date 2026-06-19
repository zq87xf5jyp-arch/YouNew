import Foundation
import SwiftUI

enum DutchHolidayType: String, CaseIterable {
    case publicHoliday
    case remembrance
    case monarchy
    case christian
    case cultural

    func title(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.publicHoliday, .russian): return "Государственный праздник"
        case (.publicHoliday, .dutch):   return "Officiële feestdag"
        case (.publicHoliday, _):        return "Public Holiday"
        case (.remembrance, .russian):   return "День памяти"
        case (.remembrance, .dutch):     return "Herdenkingsdag"
        case (.remembrance, _):          return "Day of Remembrance"
        case (.monarchy, .russian):      return "Монархия"
        case (.monarchy, .dutch):        return "Monarchie"
        case (.monarchy, _):             return "Monarchy"
        case (.christian, .russian):     return "Христианский праздник"
        case (.christian, .dutch):       return "Christelijke feestdag"
        case (.christian, _):            return "Christian Holiday"
        case (.cultural, .russian):      return "Культурный праздник"
        case (.cultural, .dutch):        return "Culturele feestdag"
        case (.cultural, _):             return "Cultural Holiday"
        }
    }

    var symbol: String {
        switch self {
        case .publicHoliday: return "flag.fill"
        case .remembrance:   return "heart.circle.fill"
        case .monarchy:      return "crown.fill"
        case .christian:     return "cross.fill"
        case .cultural:      return "star.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .publicHoliday: return AppColors.dutchOrange
        case .remembrance:   return AppColors.softBlue
        case .monarchy:      return AppColors.violet
        case .christian:     return AppColors.cyanGlow
        case .cultural:      return AppColors.dutchOrange
        }
    }
}

struct DutchHoliday: Identifiable {
    let id: String
    let month: Int
    let day: Int
    let dateEN: String
    let dateNL: String
    let dateRU: String
    let type: DutchHolidayType
    let isAutomaticDayOff: Bool
    let nameEN: String
    let nameNL: String
    let nameRU: String
    let summaryEN: String
    let summaryNL: String
    let summaryRU: String
    let originEN: String
    let originNL: String
    let originRU: String
    let practicalEN: String
    let practicalNL: String
    let practicalRU: String
    let sourceURL: URL?
    let lastChecked: String

    func name(_ lang: AppLanguage) -> String {
        switch lang { case .english: return nameEN; case .dutch: return nameNL; case .russian: return nameRU }
    }
    func date(_ lang: AppLanguage) -> String {
        switch lang { case .english: return dateEN; case .dutch: return dateNL; case .russian: return dateRU }
    }
    func summary(_ lang: AppLanguage) -> String {
        switch lang { case .english: return summaryEN; case .dutch: return summaryNL; case .russian: return summaryRU }
    }
    func origin(_ lang: AppLanguage) -> String {
        switch lang { case .english: return originEN; case .dutch: return originNL; case .russian: return originRU }
    }
    func practical(_ lang: AppLanguage) -> String {
        switch lang { case .english: return practicalEN; case .dutch: return practicalNL; case .russian: return practicalRU }
    }
    func dayOffStatus(_ lang: AppLanguage) -> String {
        if isAutomaticDayOff {
            switch lang {
            case .russian: return "Официальный выходной"
            case .dutch:   return "Officieel vrij"
            case .english: return "Official day off"
            }
        } else {
            switch lang {
            case .russian: return "Зависит от CAO/договора"
            case .dutch:   return "Afhankelijk van CAO/contract"
            case .english: return "Depends on CAO/contract"
            }
        }
    }
}

// Model for Kings & Queens timeline
struct DutchMonarch: Identifiable {
    let id: String
    let name: String
    let years: String
    let reignEN: String
    let reignNL: String
    let reignRU: String
    let summaryEN: String
    let summaryNL: String
    let summaryRU: String
    let emoji: String
    let accentColor: Color

    func reign(_ lang: AppLanguage) -> String {
        switch lang { case .english: return reignEN; case .dutch: return reignNL; case .russian: return reignRU }
    }
    func summary(_ lang: AppLanguage) -> String {
        switch lang { case .english: return summaryEN; case .dutch: return summaryNL; case .russian: return summaryRU }
    }
}
