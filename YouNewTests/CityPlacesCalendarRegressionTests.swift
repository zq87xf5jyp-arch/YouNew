import Foundation
import ImageIO
import Testing
@testable import YouNew

@MainActor
struct CityPlacesCalendarRegressionTests {
    @Test func approvedLeidenContentReusesSavedIDsAndDutchDescriptions() throws {
        let originalIDs: Set<String> = ["place.leiden-lakenhal", "place.leiden-hortus", "place.leiden-burcht",
            "place.leiden-rmo", "place.leiden-naturalis", "museum.leiden-boerhaave", "museum.leiden-wereldmuseum",
            "restaurant.leiden-bikini", "restaurant.leiden-in-den-doofpot", "restaurant.leiden-verboden-toegang",
            "restaurant.leiden-prentenkabinet", "restaurant.leiden-oudt-leyden"]
        let places = CanonicalPlaceCatalog.items.filter { originalIDs.contains($0.canonicalContentID ?? "") }
        #expect(places.count == 12)
        #expect(places.filter { $0.coordinates != nil }.count == 7)
        #expect(Set(places.compactMap(\.canonicalContentID)).count == 12)
        for place in places {
            let canonicalID = try #require(place.canonicalContentID)
            #expect(CanonicalPlaceCatalog.detailPlace(id: canonicalID)?.id == place.id)
            #expect(place.id.hasPrefix("leiden-seed-"))
            #expect(place.localizedDescription(.dutch) != place.localizedDescription(.english))
            let url = try #require(place.directionsURL)
            let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
            let expectedDestination = place.coordinates.map { "\($0.lat),\($0.lng)" } ?? place.address
            #expect(query?.first(where: { $0.name == "daddr" })?.value == expectedDestination)
            #expect(place.externalUrl?.scheme == "https")
            #expect(place.lastChecked == "2026-11-09")
        }
    }

    @Test func approvedRestaurantsReuseDetailsWithoutInventedCoordinatesOrTickets() throws {
        let places = CanonicalPlaceCatalog.items.filter { $0.canonicalContentID?.hasPrefix("restaurant.") == true }
        #expect(places.count == 5)
        let food = CityDashboardContentData.foodGuideItems(for: "Leiden", audience: .tourist, limit: nil)
        for place in places {
            #expect(food.filter { $0.id == place.id }.count == 1)
            #expect(place.coordinates == nil)
            #expect(place.ticketsURL == nil)
            #expect(CanonicalPlaceImageResolver.imageAsset(for: place) == nil)
            #expect(place.category.contains(.food))
            #expect(place.directionsURL?.host == "maps.apple.com")
        }
    }

    @Test func leidenPlaceMediaPreservesExistingRightsAndIdentity() throws {
        let pairs = [
            ("leiden-seed-museum-de-lakenhal", "museum:leiden:lakenhal"),
            ("leiden-seed-naturalis-biodiversity-center", "museum:leiden:naturalis"),
            ("leiden-seed-burcht-van-leiden", "attraction:leiden:burcht")
        ]
        var imageIDs = Set<String>()
        for (placeID, entityID) in pairs {
            let place = try #require(CanonicalPlaceCatalog.detailPlace(id: placeID))
            let image = try #require(CanonicalPlaceImageResolver.imageAsset(for: place))
            #expect(image == NetherlandsKnowledgeDatabase.shared.entity(id: entityID)?.images.hero)
            #expect(image.verified)
            #expect(image.licenseURL?.scheme == "https")
            #expect(image.sourcePageURL?.host == "commons.wikimedia.org")
            #expect(image.attribution?.isEmpty == false)
            #expect(imageIDs.insert(image.id).inserted)
        }
    }

    @Test func approvedCompletionUsesFourBundledPhotosAndSixTicketActions() throws {
        let ids = ["leiden-seed-hortus-botanicus", "leiden-seed-rijksmuseum-van-oudheden",
                   "leiden-seed-rijksmuseum-boerhaave", "leiden-seed-wereldmuseum-leiden"]
        for id in ids {
            let place = try #require(CanonicalPlaceCatalog.detailPlace(id: id))
            let asset = try #require(CanonicalPlaceImageResolver.imageAsset(for: place))
            let url = try #require(asset.url)
            #expect(url.isFileURL)
            let source = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
            #expect(CGImageSourceCreateImageAtIndex(source, 0, nil) != nil)
            #expect(asset.author?.isEmpty == false)
            #expect(asset.attribution?.isEmpty == false)
            #expect(asset.licenseURL?.scheme == "https")
            #expect(asset.sourcePageURL?.host == "commons.wikimedia.org")
        }
        let places = CanonicalPlaceCatalog.items.filter { $0.canonicalContentID != nil }
        #expect(places.filter { $0.ticketsURL != nil }.count == 6)
        #expect(CanonicalPlaceCatalog.detailPlace(id: "place.leiden-burcht")?.ticketsURL == nil)
        for place in places where place.directionsURL != nil {
            #expect(place.directionsURL?.host == "maps.apple.com")
            #expect(URLComponents(url: try #require(place.directionsURL), resolvingAgainstBaseURL: false)?.queryItems?.first?.name == "daddr")
        }
        #expect(PremiumImageFallbackCategory.place.fallbackLocalAssetName.isEmpty)
        #expect(PremiumImageFallbackCategory.map.fallbackLocalAssetName == "netherlands_map_base")
    }

    @Test func localTravelApprovalLoadsOnlyInOptedInDebugLoader() throws {
        let url = try #require(Bundle.main.url(forResource: "younew-approved-local-test", withExtension: "json"))
        let data = try Data(contentsOf: url)
        #expect(DataProjectRuntimeLoader.load(data: data).entities.isEmpty)
        let candidate = DataProjectRuntimeLoader.load(data: data, allowLocalTest: true)
        #expect(Set(CanonicalPlaceCatalog.items.map(\.id)).count == CanonicalPlaceCatalog.items.count)
        let aliases = ["museum.leiden-de-valk": "leiden-seed-molen-de-valk",
                       "place.rotterdam-markthal": "rotterdam-seed-markthal",
                       "museum.rotterdam-maritime": "rotterdam-seed-maritime-museum",
                       "place.utrecht-rietveld-schroderhuis": "utrecht-seed-rietveld-schroder-house",
                       "place.eindhoven-evoluon": "eindhoven-seed-evoluon"]
        for (canonicalID, savedID) in aliases {
            #expect(CanonicalPlaceCatalog.detailPlace(id: canonicalID)?.id == savedID)
            #expect(CanonicalPlaceCatalog.items.filter { $0.canonicalContentID == canonicalID }.count == 1)
        }
        #expect(candidate.entities.count == 85)
        #expect(candidate.collections.count == 6)
        #expect(candidate.entities.filter { $0.images.hero?.url?.isFileURL == true }.count == 36)
        #expect(candidate.entities.filter { $0.attributes["iosCoordinateAccuracy"] == "bag-address-centroid" }.count == 33)
        for entity in candidate.entities {
            let place = try #require(CanonicalPlaceCatalog.detailPlace(id: entity.id))
            #expect(place.canonicalContentID == entity.id)
            #expect(place.localizedDescription(.dutch) == entity.attributes["description_nl"])
        }
        for collection in candidate.collections {
            #expect(collection.entityIDs.allSatisfy { CanonicalPlaceCatalog.detailPlace(id: $0) != nil })
        }
    }

    @Test func selectedCityResolvesExpectedHeroCity() throws {
        let expectations: [(input: String, expected: String)] = [
            ("Amsterdam", "Amsterdam"),
            ("Rotterdam", "Rotterdam"),
            ("Den Haag", "Den Haag")
        ]

        for expectation in expectations {
            let content = CityDashboardContentData.content(for: expectation.input)
            let heroCity = try #require(content.heroCity)

            #expect(content.cityName == expectation.expected)
            #expect(heroCity.name == expectation.expected)
            #expect(content.mapFocus == .mapFocus(.city(expectation.expected)))
        }
    }

    @Test func changingSelectedCityChangesHeroImageTagsAndMunicipality() throws {
        let amsterdam = CityDashboardContentData.content(for: "Amsterdam")
        let rotterdam = CityDashboardContentData.content(for: "Rotterdam")
        let denHaag = CityDashboardContentData.content(for: "Den Haag")

        let amsterdamHero = try #require(amsterdam.city.heroImage)
        let rotterdamHero = try #require(rotterdam.city.heroImage)
        let denHaagHero = try #require(denHaag.city.heroImage)

        #expect(amsterdamHero != rotterdamHero)
        #expect(amsterdamHero != denHaagHero)
        #expect(rotterdamHero != denHaagHero)

        #expect(amsterdam.tags != rotterdam.tags)
        #expect(amsterdam.tags != denHaag.tags)
        #expect(rotterdam.tags != denHaag.tags)

        #expect(amsterdam.municipalityName == "Gemeente Amsterdam")
        #expect(rotterdam.municipalityName == "Gemeente Rotterdam")
        #expect(denHaag.municipalityName == "Gemeente Den Haag")
    }

    @Test func amsterdamBackgroundIsNotUsedForEverySupportedCity() throws {
        let amsterdamHero = try #require(CityDashboardContentData.content(for: "Amsterdam").city.heroImage)
        let otherHeroes = CityDashboardContentData.supportedCityNames
            .filter { $0 != "Amsterdam" }
            .compactMap { CityDashboardContentData.content(for: $0).city.heroImage }

        #expect(!otherHeroes.isEmpty)
        #expect(otherHeroes.contains { $0 != amsterdamHero })
        #expect(otherHeroes.allSatisfy { !$0.localizedCaseInsensitiveContains("amsterdam") })
    }

    @Test func touristDashboardPrimaryActionsPreferStayFoodCafesAndPlaces() {
        let content = CityDashboardContentData.content(for: "Rotterdam")
        let links = content.travelLinks.filter { $0.audience.contains(.tourist) }
        let kinds = Set(links.map(\.kind))
        let placeTitles = Set(content.places.map(\.title))

        #expect(kinds.contains(.booking))
        #expect(kinds.contains(.restaurants))
        #expect(kinds.contains(.cafes))
        #expect(kinds.contains(.places))
        #expect(!kinds.contains(.officialGuide) || links.first?.kind != .officialGuide)
        #expect(placeTitles.contains("Markthal"))
        #expect(!placeTitles.contains("Rijksmuseum"))
    }

    @Test func cityPlacesAreVisibleOnlyForTheirSelectedCity() {
        let amsterdamPlaces = DashboardPlacesData.visiblePlaces(cityId: "Amsterdam", audience: .tourist, limit: nil)
        let rotterdamPlaces = DashboardPlacesData.visiblePlaces(cityId: "Rotterdam", audience: .tourist, limit: nil)

        #expect(!amsterdamPlaces.isEmpty)
        #expect(!rotterdamPlaces.isEmpty)
        #expect(amsterdamPlaces.allSatisfy { $0.cityId == "Amsterdam" })
        #expect(rotterdamPlaces.allSatisfy { $0.cityId == "Rotterdam" })
        #expect(amsterdamPlaces.contains { $0.title == "Rijksmuseum" })
        #expect(rotterdamPlaces.contains { $0.title == "Markthal" })
        #expect(!amsterdamPlaces.contains { $0.title == "Markthal" })
        #expect(!rotterdamPlaces.contains { $0.title == "Rijksmuseum" })
    }

    @Test func savedPlaceDetailResolvesByIDOutsideCurrentCityFilter() throws {
        let rotterdamPlace = try #require(DashboardPlacesData.visiblePlaces(cityId: "Rotterdam", audience: .tourist, limit: nil).first { $0.title == "Markthal" })
        let amsterdamPlaces = DashboardPlacesData.visiblePlaces(cityId: "Amsterdam", audience: .tourist, limit: nil)

        #expect(!amsterdamPlaces.contains { $0.id == rotterdamPlace.id })

        let detailPlace = DashboardPlacesData.detailPlace(id: rotterdamPlace.id)

        #expect(detailPlace?.id == rotterdamPlace.id)
        #expect(detailPlace?.cityId == "Rotterdam")
        #expect(detailPlace?.source != nil)
        #expect(detailPlace?.lastChecked?.isEmpty == false)
    }

    @Test func savedCalendarDetailResolvesByIDOutsideCurrentCityFilter() throws {
        let event = try #require(DashboardCalendarData.upcomingEvents(cityId: "Amsterdam", audience: .tourist, limit: nil).first)
        let detailEvent = DashboardCalendarData.detailEvent(id: event.id)

        #expect(detailEvent?.id == event.id)
        #expect(detailEvent?.source != nil)
        #expect(detailEvent?.lastChecked?.isEmpty == false)
    }

    @Test func malformedPlacesAreHidden() {
        let hiddenWithoutCity = Self.makePlace(id: "missing-city", cityId: "", title: "Valid title", route: "place:missing-city")
        let hiddenWithoutTitle = Self.makePlace(id: "missing-title", cityId: "Amsterdam", title: "  ", route: "place:missing-title")
        let hiddenWithoutAction = Self.makePlace(id: "missing-action", cityId: "Amsterdam", title: "No action", route: nil, action: nil)
        let visible = Self.makePlace(
            id: "visible",
            cityId: "Amsterdam",
            title: "Visible",
            route: "place:visible",
            source: OfficialSource(title: "Amsterdam", url: URL(string: "https://www.amsterdam.nl"), institution: "Gemeente Amsterdam"),
            lastChecked: "2026-06-26"
        )

        #expect(!hiddenWithoutCity.isVisible(cityId: "Amsterdam", audience: UserContentCategory.tourist))
        #expect(!hiddenWithoutTitle.isVisible(cityId: "Amsterdam", audience: UserContentCategory.tourist))
        #expect(!hiddenWithoutAction.isVisible(cityId: "Amsterdam", audience: UserContentCategory.tourist))
        #expect(visible.isVisible(cityId: "Amsterdam", audience: UserContentCategory.tourist))
    }

    @Test func externalSearchLinksUseSelectedCityQuery() throws {
        for cityId in [CityId.amsterdam, .rotterdam, .denHaag] {
            let city = CityDashboardContentData.city(for: cityId)
            let booking = try #require(CityDashboardContentData.bookingExternalLink(for: city))
            let food = CityDashboardContentData.foodGuideItems(for: city, audience: .tourist)
            let restaurant = try #require(food.first { $0.category == .restaurant })
            let cafe = try #require(food.first { $0.category == .cafe })

            #expect(booking.url.absoluteString.localizedCaseInsensitiveContains(city.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city.name))
            #expect(restaurant.query?.localizedCaseInsensitiveContains(city.name) == true)
            #expect(cafe.query?.localizedCaseInsensitiveContains(city.name) == true)
            #expect(restaurant.externalUrl?.absoluteString.localizedCaseInsensitiveContains(city.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city.name) == true)
            #expect(cafe.externalUrl?.absoluteString.localizedCaseInsensitiveContains(city.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city.name) == true)
        }
    }

    @Test func searchIndexDoesNotReturnPlacesFromAnotherCityWhenContextIsCitySpecific() {
        let rotterdamContext = Self.dashboardTouristContext(city: "Rotterdam")
        let auditDate = Date(timeIntervalSince1970: 1_786_276_800)
        let items = ["Rotterdam", "Amsterdam"].map { city in
            KnowledgeItem(
                id: "place:synthetic-\(city.lowercased())-museum", type: .nearbyPlace,
                title: LocalizedKnowledgeText("\(city) museum"),
                summary: LocalizedKnowledgeText("Synthetic museum for city isolation testing."),
                category: "museum", city: city, province: nil, keywords: ["museum"],
                route: .mapFocus(.city(city)), routeID: "city:\(city.lowercased())",
                sources: [OfficialSource(title: "Fixture", url: URL(string: "https://example.nl/museum"), institution: "Fixture")],
                lastReviewed: auditDate, safetyLevel: .general, sourcePath: "test-fixture",
                personaTags: [.tourist]
            )
        }
        let engine = AppSearchEngine(
            index: KnowledgeIndex(items: items),
            repository: ContentRepository(legacyItems: items, now: auditDate, performsValidation: false)
        )
        let results = engine.search(
            "museum",
            language: AppLanguage.english,
            context: rotterdamContext,
            activePersona: .tourist,
            scope: .currentAndUniversal,
            limit: 12
        )
        let placeResults = results.filter { $0.item.id.hasPrefix("place:") }

        #expect(!placeResults.isEmpty)
        #expect(placeResults.allSatisfy { $0.item.city == "Rotterdam" })
        #expect(!placeResults.contains { $0.item.city == "Amsterdam" })
    }

    @Test func assistantUsesSelectedCityForStayFoodAndVisitQuestions() throws {
        let context = Self.dashboardTouristContext(city: "Rotterdam")
        let stay = AssistantAnswerEngine.getAssistantAnswer(userText: "Where can I stay?", language: AppLanguage.english, context: context)
        let restaurants = AssistantAnswerEngine.getAssistantAnswer(userText: "Restaurants?", language: AppLanguage.english, context: context)
        let visit = AssistantAnswerEngine.getAssistantAnswer(userText: "What can I visit?", language: AppLanguage.english, context: context)

        #expect(stay?.answer.localizedCaseInsensitiveContains("Rotterdam") == true)
        #expect(stay?.sources.contains { $0.url?.host == "www.booking.com" } == true)
        #expect(restaurants?.answer.localizedCaseInsensitiveContains("Rotterdam") == true)
        #expect(restaurants?.sources.contains { $0.url?.host == "www.google.com" } == true)
        #expect(visit?.answer.localizedCaseInsensitiveContains("Rotterdam") == true)
        #expect(visit?.answer.localizedCaseInsensitiveContains("Markthal") == true)

        let combined = [stay?.answer, restaurants?.answer, visit?.answer].compactMap { $0 }.joined(separator: " ")
        #expect(!combined.localizedCaseInsensitiveContains("Amsterdam"))
        #expect(!combined.localizedCaseInsensitiveContains("Rijksmuseum"))
    }

    @Test func premiumMapMarkersFollowSelectedCity() {
        let amsterdam = PremiumNetherlandsMapModel.markers(selectedCity: "Amsterdam", mode: .cities)
        let rotterdam = PremiumNetherlandsMapModel.markers(selectedCity: "Rotterdam", mode: .cities)
        let denHaag = PremiumNetherlandsMapModel.markers(selectedCity: "Den Haag", mode: .cities)

        #expect(amsterdam.map(\.name) == ["Amsterdam"])
        #expect(rotterdam.map(\.name) == ["Rotterdam"])
        #expect(denHaag.map(\.name) == ["The Hague"])
        #expect(rotterdam.allSatisfy { $0.name != "Amsterdam" })
    }

    private static func makePlace(
        id: String,
        cityId: String,
        title: String,
        route: String?,
        action: String? = "openPlaceDetail",
        source: OfficialSource? = nil,
        lastChecked: String? = nil
    ) -> PlaceItem {
        PlaceItem(
            id: id,
            cityId: cityId,
            section: .places,
            title: title,
            shortTitle: nil,
            description: "Description",
            category: [.landmark],
            audience: [.tourist],
            address: nil,
            coordinates: nil,
            image: nil,
            estimatedVisitTime: nil,
            priceHint: nil,
            indoor: nil,
            goodForRain: nil,
            familyFriendly: nil,
            priority: 1,
            source: source,
            lastChecked: lastChecked,
            route: route,
            externalUrl: nil,
            action: action,
            hidden: false,
            draft: false
        )
    }

    private static func dashboardTouristContext(city: String) -> AIContext {
        let dashboardCity = CityDashboardContentData.city(for: city)
        return AIContext(
            screen: .assistant,
            category: "Tourist essentials",
            topicTitle: "Tourist assistant",
            topicSummary: "Tourist help for \(dashboardCity.name).",
            officialSources: [],
            lastReviewed: nil,
            userLanguage: .english,
            userSituation: "Tourist",
            selectedCity: dashboardCity.name,
            selectedProvince: dashboardCity.province,
            selectedCityData: dashboardCity,
            selectedAudience: .tourist,
            places: DashboardPlacesData.visiblePlaces(cityId: dashboardCity.name, audience: .tourist, limit: 8),
            foodGuide: CityDashboardContentData.foodGuideItems(for: dashboardCity, audience: .tourist, limit: 8),
            travelLinks: CityDashboardContentData.travelLinks(for: dashboardCity).filter { $0.audience.contains(.tourist) },
            calendarEvents: DashboardCalendarData.upcomingEvents(cityId: dashboardCity.name, audience: .tourist, limit: 5),
            currentScreen: AIContextScreen.assistant.rawValue,
            savedItemTitles: [],
            currentRouteID: "assistant",
            disclaimer: AISafetyRules.mandatoryDisclaimer(for: .english),
            activePersonaTag: .tourist,
            secondaryPersonaTags: [.universal],
            personaSearchScope: .currentAndUniversal
        )
    }
}
