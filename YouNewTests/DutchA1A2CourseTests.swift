import Testing
@testable import YouNew

@MainActor
struct DutchA1A2CourseTests {
    @Test func courseHasRequiredModulesAndLevels() {
        #expect(DutchA1A2CourseData.modules.count >= 10)
        #expect(DutchA1A2CourseData.modules.contains { $0.level == .a1 })
        #expect(DutchA1A2CourseData.modules.contains { $0.level == .a2 })
        #expect(DutchA1A2CourseData.modules.allSatisfy { !$0.lessons.isEmpty })
    }

    @Test func lessonsContainLearningMaterialAndExercises() {
        let lessons = DutchA1A2CourseData.modules.flatMap(\.lessons)
        #expect(lessons.count >= 18)
        #expect(lessons.allSatisfy { !$0.vocabulary.isEmpty || !$0.phrases.isEmpty || !$0.grammarNotes.isEmpty })
        #expect(lessons.allSatisfy { !$0.exercises.isEmpty })
        #expect(DutchA1A2CourseData.allExercises.allSatisfy { !$0.correctAnswer.isEmpty && !$0.explanation.en.isEmpty })
    }

    @Test func requiredPracticalModulesExist() {
        for id in ["basics", "personal-info", "municipality", "housing", "transport", "healthcare", "work-income", "shopping-services", "time-appointments", "grammar"] {
            #expect(DutchA1A2CourseData.module(with: id) != nil, "Missing module \(id)")
        }
    }

    @Test func sourcesAndKNMLinksExist() {
        #expect(DutchA1A2CourseData.source(with: "cefr")?.verified == true)
        #expect(DutchA1A2CourseData.source(with: "duo-exams")?.verified == true)
        let related = DutchA1A2CourseData.modules.flatMap { $0.lessons.flatMap(\.relatedDestinations) }
        #expect(related.contains { related in
            if case .knmModule = related.destination { return true }
            return false
        })
    }
}
