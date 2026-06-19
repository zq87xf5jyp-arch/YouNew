import Foundation

enum DutchLevel: String, CaseIterable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"

    var id: String { rawValue }
}

enum DutchExerciseType: String, CaseIterable {
    case multipleChoice
    case fillBlank
    case wordOrder
    case translation
    case phraseMatch
    case grammarChoice
}

struct DutchCourseSource: Identifiable {
    let id: String
    let title: KNMLocalizedString
    let url: String
    let sourceType: String
    let language: String
    let retrievedAt: String
    let verified: Bool
}

struct DutchCourseModule: Identifiable {
    let id: String
    let level: DutchLevel
    let title: KNMLocalizedString
    let summary: KNMLocalizedString
    let icon: String
    let lessons: [DutchLesson]
    let sourceIds: [String]
    let updatedAt: String
    let searchAliases: [String]

    var exercises: [DutchExercise] {
        lessons.flatMap(\.exercises)
    }
}

struct DutchLesson: Identifiable {
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

struct DutchVocabularyItem: Identifiable {
    let id: String
    let nl: String
    let ru: String
    let en: String?
    let exampleNl: String
    let exampleRu: String
    let pronunciationHint: String?
    let tags: [String]
}

struct DutchPhrase: Identifiable {
    let id: String
    let nl: String
    let ru: String
    let en: String?
    let context: KNMLocalizedString
}

struct DutchDialogue: Identifiable {
    let id: String
    let title: KNMLocalizedString
    let lines: [DutchDialogueLine]
}

struct DutchDialogueLine: Identifiable {
    let id: String
    let speaker: KNMLocalizedString
    let nl: String
    let translation: KNMLocalizedString
}

struct DutchGrammarNote: Identifiable {
    let id: String
    let title: KNMLocalizedString
    let explanation: KNMLocalizedString
    let examples: [String]
}

struct DutchExercise: Identifiable {
    let id: String
    let type: DutchExerciseType
    let level: DutchLevel
    let prompt: KNMLocalizedString
    let options: [String]
    let correctAnswer: String
    let explanation: KNMLocalizedString
}

struct DutchCourseRelatedDestination: Identifiable {
    let id: String
    let title: KNMLocalizedString
    let icon: String
    let destination: AppDestination
}
