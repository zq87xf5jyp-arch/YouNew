import Foundation
import Testing
@testable import YouNew

struct MediaAttributionRegistryTests {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test func bundledPhotographyAttributionIsCompleteAndUnique() {
        let records = MediaAttributionRegistry.records
        let allowedContextIDs: Set<String> = [
            "app_amsterdam_evening_background",
            "home_documents_city_hall",
            "home_healthcare_pharmacy",
            "home_leiden_canals"
        ]

        #expect(records.count == MediaAttributionRegistry.expectedRecordCount)
        #expect(Set(records.map(\.id)).count == records.count)

        for record in records {
            #expect(
                record.id.hasPrefix("nl_") || allowedContextIDs.contains(record.id),
                "Unexpected asset family: \(record.id)"
            )
            #expect(!record.title.isEmpty, "Missing title: \(record.id)")
            #expect(!record.creator.isEmpty, "Missing creator: \(record.id)")
            #expect(!record.creditLine.isEmpty, "Missing credit line: \(record.id)")
            #expect(!record.licenseName.isEmpty, "Missing license: \(record.id)")
            #expect(record.licenseURL.scheme == "https", "Non-HTTPS license URL: \(record.id)")
            #expect(record.sourcePageURL.scheme == "https", "Non-HTTPS source URL: \(record.id)")
            #expect(record.sourcePageURL.host == "commons.wikimedia.org", "Unexpected source host: \(record.id)")
        }
    }

    @Test func bundledPhotographyAttributionMatchesEveryNLCatalogAsset() throws {
        let assetRoot = repoRoot.appendingPathComponent("YouNew/Assets.xcassets")
        let children = try FileManager.default.contentsOfDirectory(
            at: assetRoot,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        let catalogIDs = Set(
            children
                .filter { $0.lastPathComponent.hasPrefix("nl_") && $0.pathExtension == "imageset" }
                .map { $0.deletingPathExtension().lastPathComponent }
        )
        let attributionIDs = Set(
            MediaAttributionRegistry.records
                .map(\.id)
                .filter { $0.hasPrefix("nl_") }
        )

        #expect(catalogIDs.count == MediaAttributionRegistry.expectedNetherlandsPackRecordCount)
        #expect(attributionIDs == catalogIDs)
    }

    @Test func localPhotographyRegistryPropagatesExactRightsMetadata() throws {
        let rights = try #require(MediaAttributionRegistry.record(for: "nl_amsterdam_hero_01"))
        let asset = try #require(
            LocalNetherlandsImagePackRegistry.cityHero(placeId: "nl-city-noord_holland-amsterdam")
        )

        #expect(asset.verified)
        #expect(asset.creator == rights.creator)
        #expect(asset.author == rights.creator)
        #expect(asset.licenseName == rights.licenseName)
        #expect(asset.licenseURL == rights.licenseURL)
        #expect(asset.sourcePageURL == rights.sourcePageURL)
        #expect(asset.attribution == rights.creditLine)
    }

    @Test func everyRequiredCreditNamesCreatorAndLicense() {
        for record in MediaAttributionRegistry.records where record.attributionRequired {
            #expect(record.creditLine.contains(record.creator), "Credit omits creator: \(record.id)")
            #expect(record.creditLine.contains(record.licenseName), "Credit omits license: \(record.id)")
        }
    }
}
