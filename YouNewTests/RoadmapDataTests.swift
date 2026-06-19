import Testing
import Foundation
@testable import YouNew

struct RoadmapDataTests {
    @Test func roadmapHasFourOrderedWeeks() {
        #expect(MockExpansionData.newcomerRoadmap.count == 4)

        for index in MockExpansionData.newcomerRoadmap.indices {
            #expect(MockExpansionData.newcomerRoadmap[index].title == "Week \(index + 1)")
        }
    }

    @Test func roadmapWeeksHaveActionsAndSources() {
        for week in MockExpansionData.newcomerRoadmap {
            #expect(!week.focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(week.steps.count >= 4)
            #expect(!week.officialSourceNames.isEmpty)
        }
    }

    @Test func suggestedSearchesCoverCoreOnboardingTasks() {
        let suggested = MockExpansionData.suggestedSearches.joined(separator: " ").lowercased()

        for term in ["bsn", "digid", "insurance", "tax", "huisarts", "toeslagen"] {
            #expect(suggested.contains(term), "Suggested searches should contain \(term)")
        }
    }
}
