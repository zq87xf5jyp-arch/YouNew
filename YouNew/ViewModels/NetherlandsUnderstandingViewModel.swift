import Foundation
import Combine

@MainActor
final class NetherlandsUnderstandingViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var timeline: [CivicTimelineItem] = []
    @Published private(set) var monarchyCards: [CivicInfoCardItem] = []
    @Published private(set) var politicsCards: [CivicInfoCardItem] = []
    @Published private(set) var societyCards: [CivicInfoCardItem] = []
    @Published private(set) var glossary: [CivicGlossaryTerm] = []
    @Published private(set) var quiz: [CivicQuizQuestion] = []
    @Published var selectedSection: CivicLearningSection = .history
    @Published var glossarySearchText = ""
    @Published var selectedQuizAnswers: [String: Int] = [:]
    @Published var expandedTimelineIDs: Set<String> = []
    @Published var expandedCardIDs: Set<String> = []

    @Published private(set) var completedIDs: Set<String> = [] {
        didSet { persistCompletedIDs() }
    }

    private let completionStorageKey = "NetherlandsUnderstanding.completedIDs.v1"

    init() {
        completedIDs = Self.loadCompletedIDs(key: completionStorageKey)
    }

    func load() async {
        state = .loading
        timeline = MockNetherlandsUnderstandingData.timeline
        monarchyCards = MockNetherlandsUnderstandingData.monarchyCards
        politicsCards = MockNetherlandsUnderstandingData.politicsCards
        societyCards = MockNetherlandsUnderstandingData.societyCards
        glossary = MockNetherlandsUnderstandingData.glossary
        quiz = MockNetherlandsUnderstandingData.quiz
        state = timeline.isEmpty ? .empty : .loaded
    }

    var progress: Double {
        let total = timeline.count + monarchyCards.count + politicsCards.count + societyCards.count
        guard total > 0 else { return 0 }
        return min(Double(completedIDs.count) / Double(total), 1)
    }

    var filteredGlossary: [CivicGlossaryTerm] {
        let query = glossarySearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return glossary }
        return glossary.filter { term in
            ([term.term, term.dutchTerm, term.definitionEN, term.definitionNL] + term.keywords)
                .joined(separator: " ")
                .lowercased()
                .contains(query)
        }
    }

    func toggleCompleted(_ id: String) {
        if completedIDs.contains(id) {
            completedIDs.remove(id)
        } else {
            completedIDs.insert(id)
        }
    }

    func toggleTimelineExpansion(_ id: String) {
        if expandedTimelineIDs.contains(id) {
            expandedTimelineIDs.remove(id)
        } else {
            expandedTimelineIDs.insert(id)
        }
    }

    func toggleCardExpansion(_ id: String) {
        if expandedCardIDs.contains(id) {
            expandedCardIDs.remove(id)
        } else {
            expandedCardIDs.insert(id)
        }
    }

    func answer(_ question: CivicQuizQuestion, index: Int) {
        selectedQuizAnswers[question.id] = index
    }

    func retry() async {
        await load()
    }

    private func persistCompletedIDs() {
        let payload = Array(completedIDs)
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: completionStorageKey)
        }
    }

    private static func loadCompletedIDs(key: String) -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let payload = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(payload)
    }
}
