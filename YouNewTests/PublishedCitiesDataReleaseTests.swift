import Foundation
import Testing
@testable import YouNew

@MainActor
struct PublishedCitiesDataReleaseTests {
    private let cities: [(legacy: String, canonical: String, name: String, latitude: Double, longitude: Double)] = [
        ("city:amsterdam", "city.amsterdam", "Amsterdam", 52.3676, 4.9041),
        ("city:rotterdam", "city.rotterdam", "Rotterdam", 51.9244, 4.4777),
        ("city:den-haag", "city.den-haag", "Den Haag", 52.0705, 4.3007),
        ("city:utrecht", "city.utrecht", "Utrecht", 52.0907, 5.1214),
        ("city:eindhoven", "city.eindhoven", "Eindhoven", 51.4416, 5.4697)
    ]

    @Test func publishedReleaseReplacesMappedLegacyCitiesWithoutDuplicates() throws {
        let database = NetherlandsKnowledgeDatabase.shared
        let databaseIDs = database.entities.map(\.id)
        let indexIDs = KnowledgeIndex.shared.items.map(\.id)

        for city in cities {
            #expect(database.canonicalID(for: city.legacy) == city.canonical)
            #expect(database.entity(id: city.legacy)?.id == city.canonical)
            #expect(databaseIDs.filter { $0 == city.canonical }.count == 1)
            #expect(!databaseIDs.contains(city.legacy))
            #expect(indexIDs.filter { $0 == city.canonical }.count == 1)
            #expect(!indexIDs.contains(city.legacy))
        }
    }

    @Test func publishedCitiesFeedSearchAIHomePlacesAndMapData() throws {
        let database = NetherlandsKnowledgeDatabase.shared
        let index = KnowledgeIndex.shared
        let search = AppSearchEngine(index: index)

        for city in cities {
            let entity = try #require(database.entity(id: city.canonical))
            #expect(entity.title == city.name)
            #expect(entity.kind == .city)
            #expect(entity.coordinate?.latitude == city.latitude)
            #expect(entity.coordinate?.longitude == city.longitude)
            #expect(entity.source?.url?.scheme == "https")
            #expect(entity.images.hero != nil)
            #expect(!entity.aiSummary.isEmpty)

            let results = search.search(city.name, language: .english, scope: .allContentWithOutsidePathWarning, limit: 20)
            #expect(results.filter { $0.item.id == city.canonical }.count == 1)
            #expect(!results.contains { $0.item.id == city.legacy })
            #expect(index.itemsByID[city.canonical]?.sources.first?.url?.scheme == "https")

            #expect(CityDashboardContentData.supportedCityNames.contains(city.name))
            #expect(MockNearbyPlacesData.supportedCities.contains(city.name))
            #expect(CityDashboardContentData.city(for: city.name).heroImage != nil)
        }
    }

    @Test func runtimeLoaderRejectsCorruptedDataset() {
        let corrupted = Data("{\"schemaVersion\":1,\"mode\":\"production\",BROKEN".utf8)
        let result = DataProjectRuntimeLoader.load(data: corrupted)
        #expect(result.entities.isEmpty)
        #expect(result.migrationRegistry.isEmpty)
    }

    @Test func oldRuntimeWithoutGovernanceRemainsDecodableButDegraded() throws {
        let result = DataProjectRuntimeLoader.load(data: try runtimeData(governance: nil))
        let entity = try #require(result.entities.first)

        #expect(result.entities.count == 1)
        #expect(entity.governance == nil)
    }

    @Test func newRuntimePropagatesSafeGovernanceAndRejectsUnsafeEnvelope() throws {
        let safeResult = DataProjectRuntimeLoader.load(data: try runtimeData(governance: governanceEnvelope()))
        let safe = try #require(safeResult.entities.first)
        #expect(safe.governance?.publicationStatus == .published)
        #expect(safe.governance?.effectiveStatus() == .verified)

        var unsafe = governanceEnvelope()
        unsafe["publicationStatus"] = "draft"
        unsafe["verificationStatus"] = "unverified"
        let unsafeResult = DataProjectRuntimeLoader.load(data: try runtimeData(governance: unsafe))
        #expect(unsafeResult.entities.isEmpty)
    }

    @Test func publishedPlaceRoutesToItsCanonicalGuideDetail() throws {
        let museum = try #require(
            NetherlandsKnowledgeDatabase.shared.entity(id: "museum.rijksmuseum")
        )

        #expect(
            museum.route == .guideArticle(
                sectionID: GuideContent.dataProjectSectionID,
                articleID: museum.id
            )
        )
        #expect(ContentRepository.shared.destination(id: museum.id) == museum.route)
        let routeID = try #require(AppNavigationResolver.routeID(from: museum.route))
        #expect(routeID == "article:data-project:museum.rijksmuseum")
        #expect(AppNavigationResolver.destination(for: routeID) == museum.route)
        #expect(
            RelatedContentEngine.isVisible(
                try #require(museum.route),
                for: .tourist
            )
        )
    }

    private func runtimeData(governance: [String: Any]?) throws -> Data {
        var entity: [String: Any] = [
            "id": "government.fixture-governed",
            "kind": "governmentService",
            "title": "Governed fixture",
            "summary": "Fixture summary",
            "cityId": NSNull(),
            "provinceId": NSNull(),
            "category": "government",
            "coordinate": NSNull(),
            "source": [
                "title": "Official fixture",
                "publisher": "Government of the Netherlands",
                "url": "https://example.nl/source"
            ],
            "lastChecked": "2026-07-30",
            "images": [],
            "aiSummary": "Governed fixture summary for compatibility testing.",
            "relatedEntityIDs": [],
            "attributes": [:],
            "keywords": ["fixture"],
            "publicationStatus": "published",
            "verificationStatus": "verified"
        ]
        if let governance { entity["governance"] = governance }
        return try JSONSerialization.data(withJSONObject: [
            "schemaVersion": 1,
            "mode": "production",
            "migrationRegistry": [:],
            "entities": [entity]
        ])
    }

    private func governanceEnvelope() -> [String: Any] {
        [
            "id": "government.fixture-governed",
            "title": "Governed fixture",
            "contentType": "government_service",
            "jurisdiction": [
                "countryCode": "NL",
                "level": "national",
                "municipalityDependent": false,
                "applicabilityVerified": true,
                "provinceCode": NSNull(),
                "provinceName": NSNull(),
                "municipalityCode": NSNull(),
                "municipalityName": NSNull()
            ],
            "officialSourceURL": "https://example.nl/source",
            "sourceTitle": "Official fixture",
            "sourcePublisher": "Government of the Netherlands",
            "lastVerifiedAt": "2026-07-30T12:00:00Z",
            "nextReviewAt": "2099-01-01T00:00:00Z",
            "reviewIntervalDays": 90,
            "contentOwner": "owner",
            "reviewedBy": "reviewer-a",
            "verificationStatus": "verified",
            "confidenceLevel": "high",
            "validityStart": NSNull(),
            "validityEnd": NSNull(),
            "changeNotes": NSNull(),
            "version": 1,
            "updatedAt": "2026-07-30T12:00:00Z",
            "publicationStatus": "published",
            "reviewState": "monitoring",
            "criticality": "critical",
            "contentOrigin": "government_publication",
            "originReference": "https://example.nl/source",
            "originCapturedAt": "2026-07-30T12:00:00Z",
            "originArtifactDigest": "sha256:\(String(repeating: "a", count: 64))",
            "confidenceScore": 85,
            "confidenceScoreVersion": 1,
            "confidenceBreakdown": [
                "officialSource": 40,
                "humanReviewer": 20,
                "independentReview": 0,
                "freshness": 10,
                "jurisdictionApplicability": 15
            ]
        ]
    }
}
