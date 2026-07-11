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
            let viewModel = SearchViewModel(initialQuery: query, language: .english, personaSearchScope: .allContentWithOutsidePathWarning)
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
            let viewModel = SearchViewModel(initialQuery: query, language: .english, personaSearchScope: .allContentWithOutsidePathWarning)
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
            let viewModel = SearchViewModel(initialQuery: query, language: .english, personaSearchScope: .allContentWithOutsidePathWarning)
            #expect(viewModel.displayedResults.contains { $0.category == category }, "Expected \(query) to include \(category.rawValue)")
        }
    }

    @Test func personaSearchRanksWithoutBlockingCrossPersonaResults() {
        let studentDUO = SearchViewModel(initialQuery: "DUO", language: .english, activePersona: .student)
        #expect(studentDUO.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("DUO") })

        let workerDUO = SearchViewModel(initialQuery: "DUO", language: .english, activePersona: .worker)
        #expect(workerDUO.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("DUO") })

        let workerUWV = SearchViewModel(initialQuery: "UWV", language: .english, activePersona: .worker)
        #expect(workerUWV.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("UWV") || $0.detailedAnswer(.english).localizedCaseInsensitiveContains("UWV") })

        let studentUWV = SearchViewModel(initialQuery: "UWV", language: .english, activePersona: .student)
        #expect(studentUWV.displayedResults.contains { $0.title(.english).localizedCaseInsensitiveContains("UWV") || $0.detailedAnswer(.english).localizedCaseInsensitiveContains("UWV") })
    }

    @Test func digidSearchRemainsVisibleForResidentPersonas() {
        let personas: [PersonaTag] = [.student, .worker, .refugee, .family, .highlySkilledMigrant, .eu, .entrepreneur, .lgbt, .nonEU]

        for persona in personas {
            let viewModel = SearchViewModel(initialQuery: "DigiD", language: .english, activePersona: persona)
            #expect(
                viewModel.displayedResults.contains { $0.category == .digid },
                "Expected DigiD results for \(persona.rawValue)"
            )
        }
    }

    @Test func explicitSearchRefreshesResultsImmediatelyWithoutWaitingForDebounce() {
        UserDefaults.standard.removeObject(forKey: "question_search_recent_v1")

        let viewModel = SearchViewModel(language: .english, activePersona: .worker)
        viewModel.query = "BSN"
        #expect(viewModel.displayedResults.isEmpty)

        viewModel.performSearch()

        #expect(viewModel.displayedResults.contains { $0.title(.english) == "How do I get a BSN?" })
        #expect(viewModel.recentSearches.first == "BSN")
    }

    @Test func explicitNoResultsSearchClearsPreviousResultsImmediately() {
        UserDefaults.standard.removeObject(forKey: "question_search_recent_v1")

        let viewModel = SearchViewModel(language: .english, activePersona: .worker)
        viewModel.query = "BSN"
        viewModel.performSearch()
        #expect(!viewModel.displayedResults.isEmpty)

        viewModel.query = "zzznothingzz"
        viewModel.performSearch()

        #expect(viewModel.displayedResults.isEmpty)
        #expect(viewModel.recentSearches.first == "zzznothingzz")
    }

    @Test func savedStarterPackUsesRouteBackedCoreAnswers() {
        let answers = FavoritesView.starterPackAnswers(activePersona: .worker)
        #expect(!answers.isEmpty)
        #expect(answers.contains { $0.title(.english) == "How do I get a BSN?" })
        #expect(answers.contains { $0.title(.english) == "Do I need health insurance?" })
        #expect(answers.allSatisfy { $0.isVisible(for: .worker, scope: .currentAndUniversal) })

        for answer in answers {
            let item = FavoritesView.starterPackSavedItem(for: answer)
            #expect(item.kind == .resource)
            #expect(item.destination == .searchAnswer(answer.id))
            #expect(!item.id.isEmpty)
        }
    }

    @Test func savedStarterPackKeepsCanonicalItemsReachableAcrossProfiles() {
        let touristAnswers = FavoritesView.starterPackAnswers(activePersona: .tourist)
        #expect(touristAnswers.contains { $0.category == .registration })
        #expect(touristAnswers.contains { $0.category == .digid })
        #expect(touristAnswers.allSatisfy { $0.isVisible(for: .tourist, scope: .currentAndUniversal) })
    }
}
