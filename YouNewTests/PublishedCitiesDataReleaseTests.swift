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
}
