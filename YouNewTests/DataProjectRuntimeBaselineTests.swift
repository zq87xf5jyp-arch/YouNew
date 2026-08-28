import Foundation
import Testing
@testable import YouNew

@MainActor
struct DataProjectRuntimeBaselineTests {
    @Test func auditedRuntimeBaselineRemainsMeasurableDuringMigration() {
        let database = NetherlandsKnowledgeDatabase.shared
        let auditDate = Date(timeIntervalSince1970: 1_786_276_800) // 2026-08-09T12:00:00Z, deterministic audit reference
        let premium = database.premiumReport(now: auditDate)
        let complete = database.report
        let health = KnowledgeDataHealthService.snapshot(database: database, now: auditDate)

        let snapshot: [String: Any] = [
            "asOf": "2026-08-09T12:00:00Z",
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
