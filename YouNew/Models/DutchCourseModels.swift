import Foundation

enum DutchLevel: String, CaseIterable, Identifiable, Sendable {
    case a1 = "A1"
    case a2 = "A2"

    var id: String { rawValue }
}

enum DutchExerciseType: String, CaseIterable, Sendable {
    case multipleChoice
    case fillBlank
    case wordOrder
    case translation
    case phraseMatch
    case grammarChoice
}

struct DutchCourseSource: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let url: String
    let sourceType: String
    let language: String
    let retrievedAt: String
    let verified: Bool
}

struct DutchCourseModule: Identifiable, Sendable {
    let id: String
    let level: DutchLevel
    let title: KNMLocalizedString
    let summary: KNMLocalizedString
    let icon: String
    let lessons: [DutchLesson]
    let sourceIds: [String]
    let updatedAt: String
    let searchAliases: [String]

    nonisolated var exercises: [DutchExercise] {
        lessons.flatMap(\.exercises)
    }
}

struct DutchLesson: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let explanation: KNMLocalizedString
    let vocabulary: [DutchVocabularyItem]
    let phrases: [DutchPhrase]
    let dialogues: [DutchDialogue]
    let grammarNotes: [DutchGrammarNote]
    let exercises: [DutchExercise]
    let sourceIds: [String]
    let relatedDestinations: [DutchCourseRelatedDestination]
}

struct DutchVocabularyItem: Identifiable, Sendable {
    let id: String
    let nl: String
    let ru: String
    let en: String?
    let exampleNl: String
    let exampleRu: String
    let pronunciationHint: String?
    let tags: [String]
}

struct DutchPhrase: Identifiable, Sendable {
    let id: String
    let nl: String
    let ru: String
    let en: String?
    let context: KNMLocalizedString
}

struct DutchDialogue: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let lines: [DutchDialogueLine]
}

struct DutchDialogueLine: Identifiable, Sendable {
    let id: String
    let speaker: KNMLocalizedString
    let nl: String
    let translation: KNMLocalizedString
}

struct DutchGrammarNote: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let explanation: KNMLocalizedString
    let examples: [String]
}

struct DutchExercise: Identifiable, Sendable {
    let id: String
    let type: DutchExerciseType
    let level: DutchLevel
    let prompt: KNMLocalizedString
    let options: [String]
    let correctAnswer: String
    let explanation: KNMLocalizedString
}

struct DutchCourseRelatedDestination: Identifiable, Sendable {
    let id: String
    let title: KNMLocalizedString
    let icon: String
    let destination: AppDestination
}
