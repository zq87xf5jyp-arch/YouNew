import Testing
@testable import YouNew

@MainActor
struct KNMGuideTests {
    @Test func modulesLessonsQuestionsAndSourcesExist() {
        #expect(KNMGuideData.modules.count == 10)
        #expect(KNMGuideData.modules.allSatisfy { !$0.lessons.isEmpty })
        #expect(KNMGuideData.modules.allSatisfy { !$0.sources.isEmpty && $0.verified })
        #expect(KNMGuideData.modules.flatMap(\.lessons).allSatisfy { !$0.sourceIds.isEmpty })
        #expect(KNMGuideData.allQuestions.count >= 10)
        #expect(KNMGuideData.allQuestions.allSatisfy { !$0.explanation.en.isEmpty && !$0.sourceIds.isEmpty && $0.isOfficial == false })
    }

    @Test func requiredOfficialSourcesAreRegistered() {
        let required = ["duo-knowledge", "duo-practice", "duo-register", "belastingdienst", "zorgverzekering", "ns", "ovpay", "9292", "politie", "112"]
        for id in required {
            let source = KNMGuideData.source(with: id)
            #expect(source != nil, "Missing source \(id)")
            #expect(source?.verified == true)
            #expect(source?.url.hasPrefix("https://") == true)
        }
    }

    @Test func localizedModuleTitlesArePresent() {
        for module in KNMGuideData.modules {
            #expect(!module.title.value(.english).isEmpty)
            #expect(!module.title.value(.dutch).isEmpty)
            #expect(!module.title.value(.russian).isEmpty)
        }
        #expect(KNMGuideData.module(with: "health")?.title.value(.russian) == "Здоровье")
        #expect(KNMGuideData.module(with: "transport")?.title.value(.dutch) == "Vervoer")
    }
}
