import Testing
import Foundation
@testable import YouNew

struct KnowledgeTopicQuickAnswerTests {
    @Test func everyKnowledgeTopicHasSearchAnswer() {
        for topic in MockExpansionData.knowledgeTopics {
            let answer = MockSearchAnswersData.items.first { $0.id == topic.id }
            #expect(answer != nil, "Missing search answer for \(topic.title)")
            #expect(answer?.shortAnswer(.english) == topic.summary)
            #expect(answer?.nextRecommendedStep == topic.practicalSteps.first)
        }
    }

    @Test func everyKnowledgeTopicHasRequiredQualityMetadata() {
        for topic in MockExpansionData.knowledgeTopics {
            #expect(!topic.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!topic.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!topic.beginnerExplanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!topic.officialSourceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(topic.officialSourceURL.host?.isEmpty == false)
            #expect(topic.lastReviewed.timeIntervalSince1970 > 0)
            #expect(!topic.safetyDisclaimer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @Test func regulatedTopicsHaveOfficialSources() {
        let regulatedCategories = ["Taxes", "Healthcare", "Emergency", "Legal", "Government"]
        let topics = MockExpansionData.knowledgeTopics.filter { regulatedCategories.contains($0.category) }

        #expect(!topics.isEmpty)
        for topic in topics {
            #expect(topic.officialSourceURL.host?.isEmpty == false, "Missing official URL for \(topic.title)")
            #expect(!topic.officialSourceName.isEmpty, "Missing source name for \(topic.title)")
        }
    }
}
