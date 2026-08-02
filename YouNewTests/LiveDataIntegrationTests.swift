import Foundation
import Testing
import WeatherKit
@testable import YouNew

struct LiveDataIntegrationTests {
    @Test func productionAPIRequiresSecureAbsoluteURL() {
        #expect(YouNewAPIConfiguration.validatedBaseURL("") == nil)
        #expect(YouNewAPIConfiguration.validatedBaseURL("http://api.example.com") == nil)
        #expect(YouNewAPIConfiguration.validatedBaseURL("api.example.com") == nil)
        #expect(YouNewAPIConfiguration.validatedBaseURL("https://api.example.com")?.host == "api.example.com")
    }

    @Test func citySlugIsStableAndURLSafe() {
        #expect(YouNewAPIConfiguration.citySlug("Den Haag") == "den-haag")
        #expect(YouNewAPIConfiguration.citySlug("'s-Hertogenbosch") == "s-hertogenbosch")
        #expect(YouNewAPIConfiguration.citySlug("  Leiden  ") == "leiden")
    }

    @Test func placeSummaryAcceptsSupportedServerAliasesAndTimestamp() throws {
        let data = Data(#"{"placesCount":42,"restaurantCount":12,"eventCount":7,"updatedAt":"2026-07-14T10:00:00Z"}"#.utf8)
        let summary = try HomePlaceSyncService.decode(data: data, cityID: "Leiden", localCount: 10)
        #expect(summary.placeCount == 42)
        #expect(summary.restaurantCount == 12)
        #expect(summary.eventCount == 7)
        #expect(summary.updatedAt == ISO8601DateFormatter().date(from: "2026-07-14T10:00:00Z"))
    }

    @Test func placeSummaryRejectsNegativeCounts() {
        let data = Data(#"{"placeCount":-1}"#.utf8)
        #expect(throws: DecodingError.self) {
            try HomePlaceSyncService.decode(data: data, cityID: "Leiden", localCount: 10)
        }
    }

    @Test func businessSummaryKeepsVerifiedAndFeaturedCountsConsistent() throws {
        let data = Data(#"{"businessCount":30,"verifiedCount":24,"featuredCount":6,"updatedAt":"2026-07-14T10:00:00Z"}"#.utf8)
        let summary = try HomeBusinessSyncService.decode(data: data, cityID: "Leiden", localCount: 5)
        #expect(summary.businessCount == 30)
        #expect(summary.verifiedCount == 24)
        #expect(summary.featuredCount == 6)
    }

    @Test func businessSummaryRejectsImpossibleQualityMetrics() {
        let data = Data(#"{"businessCount":5,"verifiedCount":6,"featuredCount":1}"#.utf8)
        #expect(throws: DecodingError.self) {
            try HomeBusinessSyncService.decode(data: data, cityID: "Leiden", localCount: 5)
        }
    }

    @Test func weatherKitConditionsMapToStableDisplayGroups() {
        #expect(HomeWeatherModel.weatherCode(for: .clear) == 0)
        #expect(HomeWeatherModel.weatherCode(for: .partlyCloudy) == 2)
        #expect(HomeWeatherModel.weatherCode(for: .foggy) == 45)
        #expect(HomeWeatherModel.weatherCode(for: .rain) == 63)
        #expect(HomeWeatherModel.weatherCode(for: .snow) == 73)
        #expect(HomeWeatherModel.weatherCode(for: .thunderstorms) == 95)
    }

    @Test func everyWeatherKitConditionHasAVisibleDisplayGroup() {
        let codes = Set(WeatherCondition.allCases.map(HomeWeatherModel.weatherCode(for:)))
        #expect(codes == Set([0, 2, 45, 63, 73, 95]))
    }
}
