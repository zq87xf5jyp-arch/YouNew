import Foundation
import Testing
@testable import YouNew

@Suite("Canonical content repository")
struct ContentRepositoryTests {
    @Test("Legacy migration loses no objects")
    func migrationIsLossless() {
        let repository = ContentRepository.shared
        print("CONTENT_MIGRATION_METRICS \(repository.metrics)")
        #expect(repository.metrics.lostObjects == 0)
        #expect(repository.metrics.sourceObjects == repository.metrics.migratedObjects)
        #expect(repository.items.count == KnowledgeIndex.shared.items.count)
    }

    @Test("Every canonical item has a known category and country")
    func referencesResolve() {
        let repository = ContentRepository.shared
        let categoryIDs = Set(repository.categories.map(\.id))
        let countryIDs = Set(repository.countries.map(\.id))

        #expect(repository.items.allSatisfy { categoryIDs.contains($0.primaryCategoryID) })
        #expect(repository.items.allSatisfy { countryIDs.contains($0.countryID) })
    }

    @Test("Guide and Search expose every published item")
    func publishedItemsAreReachable() {
        let repository = ContentRepository.shared
        let published = Set(repository.items.filter { $0.status == .published }.map(\.id))
        let guide = Set(repository.guideItems().map(\.id))
        let search = Set(repository.searchableItems().map(\.id))

        #expect(published.isSubset(of: guide))
        #expect(published.isSubset(of: search))
    }

    @Test("Map projection contains only valid coordinates")
    func mapProjectionIsCoordinateDriven() {
        #expect(ContentRepository.shared.mapItems().allSatisfy { item in
            item.isMapVisible && item.coordinates?.isValid == true
        })
    }

    @Test("Audience changes Home order, not Guide access")
    func audienceDoesNotGateContent() {
        let repository = ContentRepository.shared
        let allGuideIDs = Set(repository.guideItems().map(\.id))
        _ = repository.homeReferences(audienceTags: ["student"])
        _ = repository.homeReferences(audienceTags: ["visitor"])
        #expect(Set(repository.guideItems().map(\.id)) == allGuideIDs)
    }

    @Test("Validator detects structural violations")
    func validatorFindsDuplicatesAndUnknownReferences() {
        let item = fixture(id: "duplicate", categoryID: "missing", cityIDs: ["unknown-city"])
        let issues = ContentRepositoryValidator.validate(
            items: [item, item],
            categories: Category.canonical,
            cities: [],
            sources: []
        )
        let kinds = Set(issues.map(\.kind))

        #expect(kinds.contains(.duplicateID))
        #expect(kinds.contains(.duplicateNormalizedTitle))
        #expect(kinds.contains(.duplicateNormalizedBody))
        #expect(kinds.contains(.unknownCategory))
        #expect(kinds.contains(.unknownCity))
    }

    private func fixture(id: String, categoryID: String, cityIDs: [CityID]) -> ContentItem {
        ContentItem(
            id: id,
            contentType: .article,
            title: "Fixture",
            localTitle: [:],
            shortDescription: "Fixture body",
            fullDescription: "Fixture body",
            primaryCategoryID: categoryID,
            subcategoryIDs: [],
            audienceTags: [],
            countryID: "nl",
            provinceID: nil,
            cityIDs: cityIDs,
            placeID: nil,
            keywords: [],
            officialSourceURL: nil,
            additionalSourceURLs: [],
            lastVerifiedAt: nil,
            coordinates: nil,
            actionType: .openContent,
            relatedContentIDs: [],
            priority: 0,
            emergencyLevel: .none,
            isSearchable: true,
            isMapVisible: false,
            status: .published,
            deepLink: "younew://content/fixture",
            legacySourcePath: nil
        )
    }
}
