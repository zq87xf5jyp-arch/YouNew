import Foundation
import Testing
@testable import YouNew

@MainActor
struct CityPlacesCalendarRegressionTests {
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
        let results = AppSearchEngine().search(
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
        #expect(!placeResults.contains { $0.item.title(.english).localizedCaseInsensitiveContains("Rijksmuseum") })
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
