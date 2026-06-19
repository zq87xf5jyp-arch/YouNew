import Testing
import Foundation
@testable import YouNew

@MainActor
struct SearchSynonymTests {
    @Test func requiredEnglishRussianAndDutchQueriesReturnResults() {
        let queries = [
            "BSN", "DigiD", "huisarts", "gemeente", "taxes", "toeslagen",
            "штраф", "налог", "врач", "жильё", "работа",
            "fiets", "boete", "zorgverzekering", "huur", "werk", "uitkering",
            "KNM", "Знание нидерландского общества",
            "Dutch A1-A2", "afspraak", "de het", "hebben zijn", "отделяемые глаголы"
        ]

        for query in queries {
            let viewModel = SearchViewModel(initialQuery: query, language: .english)
            #expect(!viewModel.displayedResults.isEmpty, "Expected search results for \(query)")
        }
    }

    @Test func russianQueriesResolveToExpectedKnowledgeAreas() {
        let expectations = [
            ("налог", SearchCategory.taxes),
            ("врач", SearchCategory.healthInsurance),
            ("жильё", SearchCategory.housing),
            ("работа", SearchCategory.work),
            ("штраф", SearchCategory.fines),
            ("Знание нидерландского общества", SearchCategory.general),
            ("отделяемые глаголы", SearchCategory.education)
        ]

        for (query, category) in expectations {
            let viewModel = SearchViewModel(initialQuery: query, language: .english)
            #expect(viewModel.displayedResults.contains { $0.category == category }, "Expected \(query) to include \(category.rawValue)")
        }
    }

    @Test func dutchSynonymsResolveToExpectedKnowledgeAreas() {
        let expectations = [
            ("fiets", SearchCategory.transport),
            ("boete", SearchCategory.fines),
            ("zorgverzekering", SearchCategory.healthInsurance),
            ("huur", SearchCategory.housing),
            ("werk", SearchCategory.work),
            ("uitkering", SearchCategory.work)
        ]

        for (query, category) in expectations {
            let viewModel = SearchViewModel(initialQuery: query, language: .english)
            #expect(viewModel.displayedResults.contains { $0.category == category }, "Expected \(query) to include \(category.rawValue)")
        }
    }

    @Test func personaSearchBlocksCrossPersonaResults() {
        let studentDUO = SearchViewModel(initialQuery: "DUO", language: .english, activePersona: .student)
        #expect(studentDUO.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("DUO") })

        let workerDUO = SearchViewModel(initialQuery: "DUO", language: .english, activePersona: .worker)
        #expect(!workerDUO.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("DUO") })

        let workerUWV = SearchViewModel(initialQuery: "UWV", language: .english, activePersona: .worker)
        #expect(workerUWV.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("UWV") || $0.detailedAnswer(.english).localizedCaseInsensitiveContains("UWV") })

        let studentUWV = SearchViewModel(initialQuery: "UWV", language: .english, activePersona: .student)
        #expect(!studentUWV.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("UWV") || $0.detailedAnswer(.english).localizedCaseInsensitiveContains("UWV") })
    }
}
