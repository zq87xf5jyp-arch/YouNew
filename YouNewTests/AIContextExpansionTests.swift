import Testing
import Foundation
@testable import YouNew

@MainActor
struct AIContextExpansionTests {
    private func appState(status: UserStatus = .worker) -> AppStateViewModel {
        let state = AppStateViewModel()
        state.selectedUserStatus = status
        return state
    }

    @Test func searchContextIncludesExpandedKnowledgeMatches() {
        let context = AIContextBuilder.searchContext(query: "huisarts", language: .english, appState: appState())

        #expect(context.screen == .search)
        #expect(context.topicSummary?.contains("Matched topics") == true)
        #expect(context.topicSummary?.contains("Healthcare Navigation") == true)
        #expect(!context.officialSources.isEmpty)
    }

    @Test func searchContextIncludesOfficialServices() {
        let context = AIContextBuilder.searchContext(query: "toeslagen", language: .english, appState: appState())

        #expect(context.topicSummary?.contains("Official services") == true)
        #expect(context.officialSources.contains { $0.title == "Toeslagen" || $0.title == "Belastingdienst" })
    }

    @Test func searchContextIncludesProvinceAndCityDataForCityQueries() {
        let context = AIContextBuilder.searchContext(query: "Amsterdam housing", language: .english, appState: appState(status: .tourist))

        #expect(context.topicSummary?.contains("City data: Amsterdam") == true)
        #expect(context.topicSummary?.contains("Province data: North Holland") == true)
    }

    @Test func searchContextStaysCompact() {
        let context = AIContextBuilder.searchContext(query: "registration tax housing healthcare municipality work transport", language: .english, appState: appState())

        #expect((context.topicSummary?.count ?? 0) <= 1_200)
        #expect(context.officialSources.count <= 8)
    }

    @Test func automaticContextCarriesSelectedCityDashboardPayload() {
        let state = appState(status: .tourist)
        state.selectedCity = "Rotterdam"

        let context = AIContextBuilder.automaticContext(
            selectedTab: .assistant,
            activeDestination: nil,
            language: .english,
            appState: state
        )

        #expect(context.selectedCity == "Rotterdam")
        #expect(context.selectedProvince == "Zuid-Holland")
        #expect(context.selectedCityData?.id == .rotterdam)
        #expect(context.selectedAudience == .tourist)
        #expect(context.currentScreen == AIContextScreen.assistant.rawValue)
        #expect(context.places.isEmpty == false)
        #expect(context.places.allSatisfy { $0.cityId == "Rotterdam" })
        #expect(context.foodGuide.contains { $0.title == "Restaurants in Rotterdam" })
        #expect(context.travelLinks.contains { $0.kind == .booking && $0.url.absoluteString.localizedCaseInsensitiveContains("rotterdam") })
        #expect(context.calendarEvents.allSatisfy { $0.cityId == nil || $0.cityId == "Rotterdam" })
        #expect(!context.places.contains { $0.cityId == "Amsterdam" })
        #expect(!context.travelLinks.contains { $0.cityId == CityId.amsterdam.rawValue })
    }

    @Test func contextRedactsSensitiveData() {
        let context = AIContextBuilder.searchContext(
            query: "BSN help for test@example.com +31612345678",
            language: .english,
            appState: appState()
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
