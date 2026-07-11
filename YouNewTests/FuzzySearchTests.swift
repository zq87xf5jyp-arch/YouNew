import Testing
@testable import YouNew

@MainActor
struct FuzzySearchTests {
    @Test func partialWordsReturnRelevantResults() {
        let expectations = [
            ("zorgverzek", "Health Insurance"),
            ("gemeent", "gemeente"),
            ("belasting", "Taxes"),
            ("huisart", "Healthcare")
        ]

        for (query, expectedText) in expectations {
            let viewModel = SearchViewModel(initialQuery: query, language: .english, personaSearchScope: .allContentWithOutsidePathWarning)
            let combined = viewModel.displayedResults
                .prefix(5)
                .map { [$0.title(.english), $0.shortAnswer(.english), $0.keywords(.english).joined(separator: " ")].joined(separator: " ") }
                .joined(separator: " ")
                .lowercased()

            #expect(combined.contains(expectedText.lowercased()), "Expected \(query) to match \(expectedText)")
        }
    }

    @Test func fuzzyTyposReturnResults() {
        let queries = ["diggd", "gemeete", "zorgverzkering", "belastngdienst", "huisarts"]

        for query in queries {
            let viewModel = SearchViewModel(initialQuery: query, language: .english, personaSearchScope: .allContentWithOutsidePathWarning)
            #expect(!viewModel.displayedResults.isEmpty, "Expected fuzzy result for \(query)")
        }
    }
}
