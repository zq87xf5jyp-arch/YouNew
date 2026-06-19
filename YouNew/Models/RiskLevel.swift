import Foundation

enum RiskLevel: String, CaseIterable, Identifiable, Hashable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .low: return "circle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .urgent: return "xmark.octagon.fill"
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .low:
            switch lang {
            case .russian: return "Низкий"
            case .dutch:   return "Laag"
            case .english: return rawValue
            }
        case .medium:
            switch lang {
            case .russian: return "Средний"
            case .dutch:   return "Gemiddeld"
            case .english: return rawValue
            }
        case .high:
            switch lang {
            case .russian: return "Высокий"
            case .dutch:   return "Hoog"
            case .english: return rawValue
            }
        case .urgent:
            switch lang {
            case .russian: return "Срочно"
            case .dutch:   return "Dringend"
            case .english: return rawValue
            }
        }
    }
}
