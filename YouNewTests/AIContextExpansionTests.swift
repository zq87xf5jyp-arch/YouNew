import Testing
@testable import YouNew

@MainActor
struct AIContextExpansionTests {
    @Test func searchContextIncludesExpandedKnowledgeMatches() {
        let context = AIContextBuilder.searchContext(query: "huisarts", language: .english, appState: nil)

        #expect(context.screen == .search)
        #expect(context.topicSummary?.contains("Matched topics") == true)
        #expect(context.topicSummary?.contains("Healthcare Navigation") == true)
        #expect(!context.officialSources.isEmpty)
    }

    @Test func searchContextIncludesOfficialServices() {
        let context = AIContextBuilder.searchContext(query: "toeslagen", language: .english, appState: nil)

        #expect(context.topicSummary?.contains("Official services") == true)
        #expect(context.officialSources.contains { $0.title == "Toeslagen" || $0.title == "Belastingdienst" })
    }

    @Test func searchContextIncludesProvinceAndCityDataForCityQueries() {
        let context = AIContextBuilder.searchContext(query: "Amsterdam housing", language: .english, appState: nil)

        #expect(context.topicSummary?.contains("City data: Amsterdam") == true)
        #expect(context.topicSummary?.contains("Province data: North Holland") == true)
    }

    @Test func searchContextStaysCompact() {
        let context = AIContextBuilder.searchContext(query: "registration tax housing healthcare municipality work transport", language: .english, appState: nil)

        #expect((context.topicSummary?.count ?? 0) <= 1_200)
        #expect(context.officialSources.count <= 8)
    }

    @Test func contextRedactsSensitiveData() {
        let context = AIContextBuilder.searchContext(
            query: "BSN help for test@example.com +31612345678",
            language: .english,
            appState: nil
        )

        let serialized = [
            context.topicTitle,
            context.topicSummary
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        #expect(!serialized.contains("test@example.com"))
        #expect(!serialized.contains("+31612345678"))
        #expect(serialized.contains("[redacted]"))
    }
}
