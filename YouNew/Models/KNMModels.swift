import SwiftUI

// MARK: - Localised string

struct KNMLocalizedString: Sendable {
    let en: String
    let nl: String
    let ru: String

    func value(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return en
        case .dutch:   return nl
        case .russian: return ru
        }
    }
}

// MARK: - Accent colour token (no SwiftUI Color stored in data)

enum KNMAccentToken: String, Sendable {
    case cyan, orange, green, violet, blue, red, yellow, emerald, teal

    var color: Color {
        switch self {
        case .cyan:    return AppColors.cyanGlow
        case .orange:  return AppColors.dutchOrange
        case .green:   return AppColors.success
        case .violet:  return AppColors.violet
        case .blue:    return AppColors.softBlue
        case .red:     return AppColors.error
        case .yellow:  return AppColors.warning
        case .emerald: return AppColors.emerald
        case .teal:    return AppColors.accentLight
        }
    }
}

// MARK: - Official source

struct KNMSource: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let url: String
    let sourceType: String
    let language: String
    let retrievedAt: String
    let verified: Bool
}

// MARK: - Key term

struct KNMKeyTerm: Identifiable, Sendable {
    let id: String
    let term: String               // Dutch term
    let definition: KNMLocalizedString
}

// MARK: - Practice question
// isOfficial is always false because these are app-created study questions, not DUO exam material.

struct KNMPracticeQuestion: Identifiable, Sendable {
    let id: String
    let question: KNMLocalizedString
    let options: [KNMLocalizedString]   // always 4
    let correctIndex: Int
    let explanation: KNMLocalizedString
    let sourceIds: [String]
    let isOfficial: Bool
}

// MARK: - Lesson

struct KNMLesson: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let body: KNMLocalizedString
    let example: KNMLocalizedString?
    let everydaySituations: [KNMLocalizedString]
    let keyTerms: [KNMKeyTerm]
    let rememberItems: [KNMLocalizedString]
    let practiceQuestions: [KNMPracticeQuestion]
    let sourceIds: [String]
}

// MARK: - Module

struct KNMModule: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let summary: KNMLocalizedString
    let icon: String
    let accent: KNMAccentToken
    let lessons: [KNMLesson]
    let sources: [KNMSource]
    let updatedAt: String
    let verified: Bool
    let searchAliases: [String]

    nonisolated var allQuestions: [KNMPracticeQuestion] {
        lessons.flatMap(\.practiceQuestions)
    }
}
