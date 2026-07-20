import Foundation
import Testing
@testable import YouNew

@Suite("Canonical content repository")
struct ContentRepositoryTests {
    @Test("Legacy migration loses no objects")
    func migrationIsLossless() {
        let repository = ContentRepository.shared
        print("CONTENT_MIGRATION_METRICS \(repository.metrics)")
        let issueCounts = Dictionary(grouping: repository.validationIssues, by: \.kind)
            .mapValues(\.count)
        print("CONTENT_VALIDATION_BREAKDOWN \(issueCounts)")
        let duplicateKinds: Set<ContentValidationKind> = [
            .duplicateNormalizedTitle,
            .duplicateNormalizedBody,
            .semanticDuplicateBody
        ]
        let duplicateIDs = Set(
            repository.validationIssues
                .filter { duplicateKinds.contains($0.kind) }
                .flatMap(\.contentIDs)
        )
        print("CONTENT_UNIQUENESS_METRICS validated=\(repository.items.count) duplicateAffected=\(duplicateIDs.count) uniqueValidated=\(repository.items.count - duplicateIDs.count)")
        let itemsByID = Dictionary(uniqueKeysWithValues: repository.items.map { ($0.id, $0) })
        for issue in repository.validationIssues where duplicateKinds.contains(issue.kind) {
            let scopes = issue.contentIDs.compactMap { id -> String? in
                guard let item = itemsByID[id] else { return nil }
                return "\(id){title=\(item.title);category=\(item.primaryCategoryID);cities=\(item.cityIDs.joined(separator: ","));body=\(item.normalizedBody.prefix(90))}"
            }
            print("CANONICAL_DUPLICATE_GROUP kind=\(issue.kind.rawValue) \(scopes.joined(separator: " || "))")
        }
        #expect(repository.metrics.lostObjects == 0)
        #expect(repository.metrics.sourceObjects == repository.metrics.migratedObjects + repository.aliases.count)
        #expect(repository.items.count + repository.aliases.count == KnowledgeIndex.shared.items.count)
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
        #expect(published.allSatisfy { repository.destination(id: $0) != nil })
    }

    @Test("Published coordinate records project into the existing map and Saved route")
    func publishedItemsHaveAutomaticConsumerRoutes() throws {
        let repository = ContentRepository.shared
        for item in repository.mapItems() {
            let cityID = try #require(item.cityIDs.first)
            let city = try #require(repository.cities.first(where: { $0.id == cityID }))
            let place = try #require(NearbyPlace(canonicalContent: item, city: city))
            #expect(place.saveKey == item.id)
            #expect(place.relatedLinks.first?.destination == repository.destination(id: item.id))
        }
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

    @Test("Validator detects semantic description reuse")
    func validatorFindsSemanticDuplicates() {
        let first = fixture(
            id: "semantic-a",
            description: "Use the official municipality website to register your address and verify the required documents before your appointment."
        )
        let second = fixture(
            id: "semantic-b",
            description: "Use the official municipality website to register your address and verify the required documents before your appointment carefully."
        )
        let issues = ContentRepositoryValidator.validate(
            items: [first, second],
            categories: Category.canonical,
            cities: [],
            sources: []
        )
        #expect(issues.contains { $0.kind == .semanticDuplicateBody })
    }

    @Test("Canonical place catalog is shared and geographically consistent")
    func canonicalPlacesAreUniqueAndGeographicallyConsistent() {
        let repository = ContentRepository.shared
        let placeIDs = repository.places.map(\.id)
        let canonicalIDs = CanonicalPlaceCatalog.items.compactMap { item in
            item.coordinates.map { _ in item.id }
        }
        let cityIDs = Set(repository.cities.map(\.id))
        let provinceIDs = Set(repository.provinces.map(\.id))

        #expect(!repository.places.isEmpty)
        #expect(Set(placeIDs).count == placeIDs.count)
        #expect(Set(placeIDs) == Set(canonicalIDs))
        #expect(repository.places.allSatisfy { place in
            place.coordinates.isValid
                && place.cityID.map(cityIDs.contains) == true
                && place.provinceID.map(provinceIDs.contains) == true
        })
    }

    @Test("Validator covers source freshness reachability and usage gates")
    func validatorCoversAllRequiredGates() {
        let staleDate = Date(timeIntervalSince1970: 0)
        let sourceURL = URL(string: "https://example.org/")!
        let sources = [
            SourceReference(id: "source-a", title: "A", publisher: nil, url: sourceURL, isOfficial: true, lastVerifiedAt: staleDate),
            SourceReference(id: "source-b", title: "B", publisher: nil, url: URL(string: "https://example.org#copy")!, isOfficial: true, lastVerifiedAt: staleDate)
        ]
        let items = [
            fixture(id: "missing-source", contentType: .officialService),
            fixture(id: "stale", lastVerifiedAt: staleDate),
            fixture(id: "unused", actionType: .none, deepLink: nil),
            fixture(id: "unreachable", isSearchable: false),
            fixture(id: "bad-map", coordinates: GeoCoordinates(latitude: 200, longitude: 0), isMapVisible: true)
        ]
        let issues = ContentRepositoryValidator.validate(
            items: items,
            categories: Category.canonical,
            cities: [],
            sources: sources
        )
        let kinds = Set(issues.map(\.kind))

        #expect(kinds.contains(.duplicateCanonicalURL))
        #expect(kinds.contains(.missingSource))
        #expect(kinds.contains(.staleVerificationDate))
        #expect(kinds.contains(.unusedObject))
        #expect(kinds.contains(.unreachableThroughGuideOrSearch))
        #expect(kinds.contains(.invalidCoordinates))
    }

    @Test("Search uses canonical items and audience does not gate")
    func canonicalSearchIsUniversal() {
        let engine = AppSearchEngine()
        let student = engine.searchContent("BSN", language: .english, activePersona: .student, limit: 5_000)
        let tourist = engine.searchContent("BSN", language: .english, activePersona: .tourist, limit: 5_000)

        #expect(Set(student.map(\.id)) == Set(tourist.map(\.id)))
        #expect(student.allSatisfy { ContentRepository.shared.item(id: $0.id) != nil })
    }

    @Test("AI context returns canonical IDs and deep links")
    func assistantReturnsCanonicalReferences() {
        let answer = AppSearchEngine().answerContentContext(for: "health insurance", language: .english)
        #expect(!answer.contentIDs.isEmpty)
        #expect(answer.contentIDs.allSatisfy { ContentRepository.shared.item(id: $0) != nil })
        #expect(answer.deepLinks.count == answer.contentIDs.count)
    }

    @Test("Saved persistence stores IDs and timestamps only")
    func savedPersistenceIsReferenceOnly() throws {
        let key = "SavedItemsStore.savedItems.v1"
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        let store = SavedItemsStore()
        let contentID = try #require(ContentRepository.shared.items.first?.id)
        store.toggle(id: contentID, kind: .other, title: "Snapshot must not persist")

        let data = try #require(defaults.data(forKey: key))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        let record = try #require(object.first)
        #expect(Set(record.keys) == ["id", "savedAt"])
        #expect(record["id"] as? String == contentID)
        defaults.removeObject(forKey: key)
    }

    private func fixture(
        id: String,
        categoryID: String = "getting-started",
        cityIDs: [CityID] = [],
        description: String = "Fixture body",
        contentType: ContentType = .article,
        lastVerifiedAt: Date? = nil,
        coordinates: GeoCoordinates? = nil,
        actionType: ContentActionType = .openContent,
        isSearchable: Bool = true,
        isMapVisible: Bool = false,
        deepLink: String? = "younew://content/fixture"
    ) -> ContentItem {
        ContentItem(
            id: id,
            contentType: contentType,
            title: "Fixture",
            localTitle: [:],
            shortDescription: description,
            fullDescription: description,
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
            lastVerifiedAt: lastVerifiedAt,
            coordinates: coordinates,
            actionType: actionType,
            relatedContentIDs: [],
            priority: 0,
            emergencyLevel: .none,
            isSearchable: isSearchable,
            isMapVisible: isMapVisible,
            status: .published,
            deepLink: deepLink,
            legacySourcePath: nil
        )
    }
}
