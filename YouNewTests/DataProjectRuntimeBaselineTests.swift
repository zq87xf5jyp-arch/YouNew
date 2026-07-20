import Foundation
import Testing
@testable import YouNew

@MainActor
struct DataProjectRuntimeBaselineTests {
    @Test func runtimeBaselineRemainsMeasurableDuringMigration() {
        let database = NetherlandsKnowledgeDatabase.shared
        let premium = database.premiumReport()
        let complete = database.report
        let health = KnowledgeDataHealthService.snapshot(database: database)

        let snapshot: [String: Any] = [
            "totalRecords": health.totalRecords,
            "publishableRecords": health.publishableRecords,
            "cities": premium.cities,
            "museums": premium.museums,
            "restaurants": premium.restaurants,
            "cafes": premium.cafes,
            "hotels": complete.hotels,
            "government": premium.governmentServices,
            "partners": premium.partners,
            "events": premium.events,
            "images": premium.images,
            "verifiedWebsites": premium.verifiedWebsites,
            "currentRecordPercentage": premium.currentRecordPercentage,
            "uniquePhotoPercentage": premium.uniquePhotoPercentage,
            "relations": complete.relations
        ]
        let data = try! JSONSerialization.data(withJSONObject: snapshot, options: [.sortedKeys])
        let json = String(decoding: data, as: UTF8.self)
        print("DATA_PROJECT_RUNTIME_BASELINE=\(json)")

        #expect(health.totalRecords >= health.publishableRecords)
        #expect(premium.cities > 0)
        #expect(premium.governmentServices > 0)
        #expect(complete.relations > 0)
    }
}
