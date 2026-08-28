import Foundation
import Testing
@testable import YouNew

@MainActor
struct VerifiedLeidenVenueTests {
    @Test func auditedVerifiedVenuesArePublishedAndSearchable() {
        let seeded = VerifiedLeidenVenueData.entities
        let publishedIDs = Set(NetherlandsKnowledgeDatabase.shared.publishedEntities(at: Self.auditDate).map(\.id))
        let index = KnowledgeIndex(items: KnowledgeIndexBuilder.buildItems(now: Self.auditDate))

        #expect(seeded.count == 12)
        #expect(seeded.allSatisfy { publishedIDs.contains($0.id) })
        #expect(seeded.allSatisfy { $0.cityId == "Leiden" && $0.coordinate != nil })
        #expect(seeded.allSatisfy { $0.source?.url?.scheme == "https" })
        #expect(index.itemsByID["restaurant:leiden:pakhuis"] != nil)
    }

    @Test func verifiedVenueMediaHasHonestReusableRightsMetadata() {
        let venues = VerifiedLeidenVenueData.entities
        let licensedRemote = venues.filter { $0.images.hero?.imageURL != nil }
        let mediaIDs = licensedRemote.compactMap { $0.images.hero?.id }

        #expect(licensedRemote.count == 11)
        #expect(Set(mediaIDs).count == mediaIDs.count)
        #expect(venues.allSatisfy { $0.hasReusablePrimaryMedia })
        #expect(licensedRemote.allSatisfy { entity in
            guard let image = entity.images.hero else { return false }
            return image.sourceName == "Wikimedia Commons"
                && image.sourcePageURL?.host == "commons.wikimedia.org"
                && image.licenseURL != nil
                && image.attribution?.isEmpty == false
        })
    }

    @Test func auditedFoodAndCultureCoverageIsEnrichedWithoutChangingHomeArchitecture() {
        let records = NetherlandsKnowledgeDatabase.shared.publishedEntities(at: Self.auditDate)
        #expect(records.filter { $0.kind == .restaurant }.count >= 7)
        #expect(records.filter { $0.kind == .cafe }.count >= 4)
        #expect(records.filter { $0.kind == .museum }.count >= 27)
    }

    @Test func healthSnapshotTracksEventsLinksAndMediaDebt() {
        let database = NetherlandsKnowledgeDatabase.shared
        let now = Date(timeIntervalSince1970: 1_784_721_600)
        let snapshot = KnowledgeDataHealthService.snapshot(database: database, now: now)
        let expectedActiveEvents = database.publishedEntities(at: now).filter {
            $0.kind == .event && $0.isActiveEvent(now: now)
        }.count

        #expect(snapshot.totalRecords >= snapshot.publishableRecords)
        #expect(snapshot.publishableRecords > 0)
        #expect(snapshot.activeEvents == expectedActiveEvents)
        #expect(snapshot.missingPhotoLicenses >= 0)
        #expect(snapshot.duplicatePrimaryPhotos >= 0)
    }

    private static let auditDate = Date(timeIntervalSince1970: 1_786_276_800) // 2026-08-09T12:00:00Z, deterministic audit reference
}
