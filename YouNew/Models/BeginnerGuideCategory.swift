import Foundation

enum BeginnerGuideCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case identity
    case municipality
    case immigration
    case work
    case education
    case healthcare
    case housing
    case transport
    case taxes
    case fines
    case legalHelp
    case safety
    case dailyLife
    case benefits
    case health

    var id: String { rawValue }
}
