import Foundation
import Testing
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

    @Test func weatherResponseDecodesOpenMeteoCurrentConditions() throws {
        let data = Data(#"{"current":{"time":"2026-07-14T10:00:00Z","temperature_2m":21.4,"apparent_temperature":20.8,"is_day":1,"precipitation":0.0,"weather_code":2,"wind_speed_10m":13.2}}"#.utf8)
        let snapshot = try HomeWeatherModel.decode(data: data)
        #expect(snapshot.temperature == 21.4)
        #expect(snapshot.weatherCode == 2)
        #expect(snapshot.isDay)
    }

    @Test func weatherResponseRejectsCorruptMeasurements() {
        let data = Data(#"{"current":{"time":"2026-07-14T10:00:00Z","temperature_2m":999,"apparent_temperature":20.8,"is_day":1,"precipitation":0.0,"weather_code":2,"wind_speed_10m":13.2}}"#.utf8)
        #expect(throws: DecodingError.self) {
            try HomeWeatherModel.decode(data: data)
        }
    }
}
