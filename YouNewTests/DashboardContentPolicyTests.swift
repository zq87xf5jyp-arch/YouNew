import Foundation
import Testing
@testable import YouNew

struct DashboardContentPolicyTests {
    private struct Item: DashboardRenderableCard {
        let dashboardTitle: String
        let dashboardRouteID: String?
        let dashboardActionID: String?
        let dashboardURL: URL?
        let dashboardExternalURL: URL?
        let dashboardAudienceTags: Set<PersonaTag>
        let dashboardCityID: String?
        let dashboardHidden: Bool
        let dashboardDraft: Bool
        let dashboardPriority: Int

        init(
            title: String,
            routeID: String? = "route",
            actionID: String? = nil,
            url: URL? = nil,
            externalURL: URL? = nil,
            audience: Set<PersonaTag> = [.refugee],
            cityID: String? = nil,
            hidden: Bool = false,
            draft: Bool = false,
            priority: Int = 1
        ) {
            dashboardTitle = title
            dashboardRouteID = routeID
            dashboardActionID = actionID
            dashboardURL = url
            dashboardExternalURL = externalURL
            dashboardAudienceTags = audience
            dashboardCityID = cityID
            dashboardHidden = hidden
            dashboardDraft = draft
            dashboardPriority = priority
        }
    }

    private let refugeeContext = DashboardRenderContext(selectedAudience: .local, selectedCityID: "Amsterdam")
    private let touristContext = DashboardRenderContext(selectedAudience: .tourist, selectedCityID: "Amsterdam")

    @Test func emptyCardWithoutTitleIsNotRendered() {
        #expect(!DashboardContentPolicy.shouldRenderCard(Item(title: "   "), context: refugeeContext))
    }

    @Test func cardWithoutRouteActionOrURLIsNotRendered() {
        let item = Item(title: "Municipality", routeID: nil, actionID: nil, url: nil)
        #expect(!DashboardContentPolicy.shouldRenderCard(item, context: refugeeContext))
    }

    @Test func externalURLCountsAsActionableCard() throws {
        let url = try #require(URL(string: "https://example.com"))
        let item = Item(title: "External", routeID: nil, actionID: nil, url: nil, externalURL: url)
        #expect(DashboardContentPolicy.shouldRenderCard(item, context: refugeeContext))
    }

    @Test func invalidExternalURLDoesNotRenderURLOnlyCard() throws {
        let url = try #require(URL(string: "ftp://example.com/hotels"))
        let item = Item(title: "External", routeID: nil, actionID: nil, url: nil, externalURL: url)
        #expect(!DashboardContentPolicy.shouldRenderCard(item, context: refugeeContext))
    }

    @Test func cardWithoutAudienceIsNotRendered() {
        #expect(!DashboardContentPolicy.shouldRenderCard(Item(title: "No audience", audience: []), context: refugeeContext))
    }

    @Test func hiddenDraftAndWrongCityCardsAreNotRendered() {
        #expect(!DashboardContentPolicy.shouldRenderCard(Item(title: "IND", hidden: true), context: refugeeContext))
        #expect(!DashboardContentPolicy.shouldRenderCard(Item(title: "IND", draft: true), context: refugeeContext))
        #expect(!DashboardContentPolicy.shouldRenderCard(Item(title: "Municipality", cityID: "Rotterdam"), context: refugeeContext))
    }

    @Test func refugeeDashboardDoesNotShowTouristOnlyCards() {
        let touristOnly = Item(title: "Museums", audience: [.tourist])
        #expect(!DashboardContentPolicy.shouldRenderCard(touristOnly, context: refugeeContext))
    }

    @Test func touristDashboardDoesNotShowRefugeeOnlyCards() {
        let refugeeOnly = Item(title: "IND", audience: [.refugee])
        #expect(!DashboardContentPolicy.shouldRenderCard(refugeeOnly, context: touristContext))
    }

    @Test func emptySectionIsNotRendered() {
        let section = DashboardSection(
            id: "empty",
            title: "Empty",
            subtitle: nil,
            layout: .grid,
            priority: 1,
            audienceTags: [.refugee],
            items: [Item(title: "", routeID: nil)]
        )
        #expect(!DashboardContentPolicy.shouldRenderSection(section, context: refugeeContext))
    }

    @Test func sectionWithoutTitleIsNotRenderedEvenWithValidItems() {
        let section = DashboardSection(
            id: "blank-title",
            title: "   ",
            subtitle: nil,
            layout: .grid,
            priority: 1,
            audienceTags: [.refugee],
            items: [Item(title: "Valid card")]
        )
        #expect(!DashboardContentPolicy.shouldRenderSection(section, context: refugeeContext))
    }

    @Test func visibleCardsDropsEmptyAndUnactionableItems() {
        let items = [
            Item(title: "Valid", priority: 2),
            Item(title: "No route", routeID: nil, actionID: nil, url: nil, priority: 1),
            Item(title: "   ", priority: 0)
        ]
        let visible = DashboardContentPolicy.visibleCards(items, context: refugeeContext)

        #expect(visible.map(\.dashboardTitle) == ["Valid"])
    }

    @Test func getVisibleSectionItemsFiltersAndSorts() {
        let section = DashboardSection(
            id: "mixed",
            title: "Mixed",
            subtitle: nil,
            layout: .grid,
            priority: 1,
            audienceTags: [.refugee],
            items: [
                Item(title: "Second", priority: 2),
                Item(title: "No action", routeID: nil, actionID: nil, url: nil, priority: 0),
                Item(title: "First", priority: 1)
            ]
        )

        #expect(DashboardContentPolicy.getVisibleSectionItems(section, context: refugeeContext).map(\.dashboardTitle) == ["First", "Second"])
    }

    @Test func citySpecificCardRendersOnlyForSelectedCity() {
        let amsterdam = Item(title: "Amsterdam help", cityID: "Amsterdam")
        let leiden = Item(title: "Leiden help", cityID: "Leiden")

        #expect(DashboardContentPolicy.shouldRenderCard(amsterdam, context: refugeeContext))
        #expect(!DashboardContentPolicy.shouldRenderCard(leiden, context: refugeeContext))
    }

    @Test func universalCardRendersForTouristDashboard() {
        let universal = Item(title: "Emergency", audience: [.universal])
        #expect(DashboardContentPolicy.shouldRenderCard(universal, context: touristContext))
    }

    @Test func lostDocumentsRouteIsTouristGuideNotEmergencyHub() {
        let routeID = "article:tourist-documents:lost-documents"
        #expect(AppNavigationResolver.destination(for: routeID) == .guideArticle(sectionID: "tourist-documents", articleID: "lost-documents"))
        #expect(AppNavigationResolver.destination(for: routeID) != .emergencyHub)
        #expect(GuideContent.article(sectionID: "tourist-documents", articleID: "lost-documents", activePersona: .tourist) != nil)
        #expect(GuideContent.article(sectionID: "tourist-documents", articleID: "lost-documents", activePersona: .refugee) != nil)
    }

    @Test func quickActionsShowMaxFourPrimaryActions() {
        let items = (0..<6).map { index in
            Item(title: "Action \(index)", audience: [.refugee], priority: index)
        }
        let visible = DashboardContentPolicy.visibleCards(items, context: refugeeContext, limit: 4)
        #expect(visible.count == 4)
        #expect(visible.map(\.dashboardTitle) == ["Action 0", "Action 1", "Action 2", "Action 3"])
    }

    @Test func sectionTitleHiddenWhenSectionHasZeroVisibleItems() {
        let section = DashboardSection(
            id: "tourist",
            title: "Tourist-only",
            subtitle: nil,
            layout: .grid,
            priority: 1,
            audienceTags: [.tourist],
            items: [Item(title: "Museums", audience: [.tourist])]
        )
        #expect(!DashboardContentPolicy.shouldRenderSection(section, context: refugeeContext))
    }

    @Test func cityDashboardContentTracksSelectedCity() throws {
        for cityName in ["Leiden", "Rotterdam", "Den Haag"] {
            let content = CityDashboardContentData.content(for: cityName)
            let heroCity = try #require(content.heroCity)

            #expect(content.cityName == cityName)
            #expect(content.city.id.displayName == cityName)
            #expect(content.city.country == "NL")
            #expect(heroCity.name == cityName)
            #expect(content.province == heroCity.province)
            #expect(content.city.heroImage != nil)
            #expect(!content.stats.isEmpty)
            #expect(!content.places.isEmpty)
            #expect(!content.travelLinks.isEmpty)
            #expect(content.aiSummary.contains(cityName))
        }
    }

    @Test func supportedCitySeedContainsRequiredDashboardFields() {
        let expectedTags: [CityId: [String]] = [
            .amsterdam: ["Canals", "Museums", "Cycling", "Nightlife"],
            .rotterdam: ["Architecture", "Harbor", "Food", "Modern city"],
            .denHaag: ["Beach", "Politics", "Museums", "International city"],
            .leiden: ["History", "University", "Canals", "Museums"],
            .utrecht: ["Canals", "Student city", "Dom Tower", "Old town"],
            .eindhoven: ["Design", "Tech", "Innovation", "Nightlife"],
            .maastricht: ["History", "Food", "Architecture", "Shopping"],
            .groningen: ["Student city", "Cycling", "Culture", "Nightlife"]
        ]

        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)

            #expect(city.name == cityId.displayName)
            #expect(city.country == "NL")
            #expect(city.heroImage?.isEmpty == false)
            #expect(city.tags == expectedTags[cityId])
            #expect(!city.province.isEmpty)
            #expect(city.municipalityName?.hasPrefix("Gemeente ") == true)
            #expect(city.coordinates.lat != 0)
            #expect(city.coordinates.lng != 0)
            #expect(city.bookingQuery.contains(city.name))
            #expect(city.restaurantQuery.localizedCaseInsensitiveContains(city.name))
            #expect(city.cafeQuery.localizedCaseInsensitiveContains(city.name))
            #expect(city.placesQuery.localizedCaseInsensitiveContains(city.name))
            #expect(!city.placeSeed.isEmpty)
        }
    }

    @Test func visiblePlacesAreCitySpecificForEverySupportedCity() {
        for cityName in CityDashboardContentData.supportedCityNames {
            let places = DashboardPlacesData.visiblePlaces(cityId: cityName, audience: .tourist, limit: nil)

            #expect(!places.isEmpty, "\(cityName) should have dashboard places")
            #expect(places.allSatisfy { $0.cityId == cityName })
            if cityName != "Amsterdam" {
                #expect(places.allSatisfy { $0.cityId != "Amsterdam" })
                #expect(places.allSatisfy { !$0.id.lowercased().hasPrefix("amsterdam-") })
            }
        }
    }

    @Test func dashboardPlacesPreviewIsLimitedAndDoesNotInventVenueFacts() {
        for cityName in CityDashboardContentData.supportedCityNames {
            let preview = DashboardPlacesData.visiblePlaces(cityId: cityName, audience: .tourist, limit: 5)
            #expect(preview.count <= 5)
            #expect(preview.allSatisfy { $0.cityId == cityName })
            #expect(preview.allSatisfy { $0.estimatedVisitTime == nil })
            #expect(preview.allSatisfy { $0.priceHint == nil })
            #expect(preview.allSatisfy { !$0.category.contains(.free) })
            #expect(preview.allSatisfy { $0.route != nil || $0.action != nil || $0.externalUrl != nil })
            #expect(preview.allSatisfy { $0.source != nil })
            #expect(preview.allSatisfy { $0.lastChecked?.isEmpty == false })

            let joinedText = preview
                .flatMap { [$0.title, $0.description, $0.lastChecked ?? ""] }
                .joined(separator: " ")
                .lowercased()
            for blockedClaim in ["rating", "ratings", "stars", "opening hours", "open until", "ticket price", "€", "$"] {
                #expect(!joinedText.contains(blockedClaim), "\(cityName) places should not include \(blockedClaim)")
            }
        }
    }

    @Test func dashboardPlacesSeedContainsRequiredSafeCityContent() {
        let requiredPlaces: [CityId: Set<String>] = [
            .amsterdam: ["Rijksmuseum", "Van Gogh Museum", "Anne Frank House", "Vondelpark", "Dam Square", "Jordaan", "NEMO Science Museum", "Albert Cuyp Market", "Amsterdam Canals"],
            .rotterdam: ["Markthal", "Erasmus Bridge", "Cube Houses", "Museum Boijmans area", "Euromast", "Maritime Museum", "Delfshaven"],
            .denHaag: ["Binnenhof area", "Mauritshuis", "Scheveningen Beach", "Peace Palace", "Madurodam", "Escher in Het Paleis"],
            .leiden: ["Leiden canals", "Museum De Lakenhal", "Hortus Botanicus", "Burcht van Leiden", "National Museum of Antiquities"],
            .utrecht: ["Dom Tower", "Oudegracht", "Museum Speelklok", "Centraal Museum", "Rietveld Schroder House"],
            .eindhoven: ["Strijp-S", "Van Abbemuseum", "Philips Museum", "Evoluon", "Downtown Eindhoven"],
            .maastricht: ["Vrijthof", "Basilica of Saint Servatius", "Bonnefanten Museum", "St. Pietersberg Caves", "Maastricht old town"],
            .groningen: ["Martinitoren", "Groninger Museum", "Noorderplantsoen", "Grote Markt", "Forum Groningen"]
        ]

        for cityId in CityDashboardContentData.supportedCityIds {
            let cityName = cityId.displayName
            let places = DashboardPlacesData.visiblePlaces(cityId: cityName, audience: .tourist, limit: nil)
            let titles = Set(places.map(\.title))

            #expect(requiredPlaces[cityId]?.isSubset(of: titles) == true)
            #expect(places.allSatisfy { $0.cityId == cityName })
            #expect(places.allSatisfy { $0.estimatedVisitTime == nil && $0.priceHint == nil })
        }
    }

    @Test func leidenDashboardPlacesUseDistinctSpecificImages() throws {
        let places = DashboardPlacesData.visiblePlaces(cityId: "Leiden", audience: .tourist, limit: nil)
        let requiredTitles = [
            "Leiden canals",
            "Museum De Lakenhal",
            "Hortus Botanicus",
            "Burcht van Leiden",
            "National Museum of Antiquities"
        ]
        let requiredPlaces = try requiredTitles.map { title in
            try #require(places.first { $0.title == title }, "Missing Leiden place: \(title)")
        }
        let imageURLs = requiredPlaces.compactMap(\.image)

        #expect(imageURLs.count == requiredTitles.count)
        #expect(Set(imageURLs).count == imageURLs.count, "Leiden dashboard place images must not be duplicated")
        #expect(imageURLs.allSatisfy { $0.hasPrefix("https://") })
        #expect(imageURLs.allSatisfy { !$0.localizedCaseInsensitiveContains("kinderdijk") })
        #expect(imageURLs.allSatisfy { !$0.localizedCaseInsensitiveContains("windmill") })
        #expect(imageURLs.allSatisfy { !$0.localizedCaseInsensitiveContains("de%20valk") })
    }

    @Test func dashboardFoodAndStaySeedAreNotEmptyForSupportedCities() {
        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)
            let food = CityDashboardContentData.foodGuideItems(for: city, audience: .tourist)
            let links = CityDashboardContentData.travelLinks(for: city)

            #expect(food.contains { $0.title == "Restaurants in \(city.name)" })
            #expect(food.contains { $0.title == "Cafes in \(city.name)" })
            #expect(food.contains { $0.title == "Breakfast spots" })
            #expect(food.contains { $0.title == "Food markets" || $0.title == "Market Hall area" })
            #expect(food.contains { $0.title == "Local food" || $0.title == "Local Dutch food" || $0.title == "Harbor food spots" })
            #expect(links.contains { $0.kind == .booking && $0.title == "Booking.com" })
        }
    }

    @Test func travelLinksAreCitySpecificValidatedHTTPSURLs() {
        for cityId in CityDashboardContentData.supportedCityIds {
            let cityName = cityId.displayName
            let links = CityDashboardContentData.travelLinks(for: cityName)

            #expect(Set(links.map(\.kind)) == Set(TravelLinkKind.allCases))
            #expect(links.allSatisfy { $0.cityId == cityId.rawValue })
            #expect(links.allSatisfy { $0.url.scheme == "https" })
            #expect(links.allSatisfy { $0.url.host?.isEmpty == false })
            #expect(links.allSatisfy { !$0.audience.isEmpty })
            #expect(links.allSatisfy { !$0.sourceLabel.isEmpty })
            #expect(links.allSatisfy { !$0.lastChecked.isEmpty })
            #expect(links.allSatisfy { $0.externalLink?.cityId == cityId })
            #expect(links.allSatisfy { $0.externalLink?.url.scheme == "https" })
            #expect(links.allSatisfy { $0.externalLink?.source?.isEmpty == false })
            #expect(links.allSatisfy { $0.externalLink?.lastChecked?.isEmpty == false })
            #expect(links.contains { $0.kind == .booking && $0.url.absoluteString.contains("booking.com") })
            #expect(links.contains { $0.kind == .booking && $0.externalLink?.provider == .booking })
            #expect(links.contains { $0.kind == .officialGuide && $0.isOfficial })
        }
    }

    @Test func travelLinksHaveDashboardCardLabelsAndProviders() {
        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)
            let links = CityDashboardContentData.travelLinks(for: city)

            #expect(links.contains { $0.kind == .booking && $0.title == "Booking.com" && $0.subtitle == "Find hotels and stays" && $0.externalLink?.provider == .booking })
            #expect(links.contains { $0.kind == .restaurants && $0.title == "Restaurants" && $0.subtitle == "Search restaurants in \(city.name)" && $0.externalLink?.provider == .googleMaps })
            #expect(links.contains { $0.kind == .cafes && $0.title == "Cafes" && $0.subtitle == "Coffee and breakfast spots" && $0.externalLink?.provider == .googleMaps })
            #expect(links.contains { $0.kind == .places && $0.title == "Attractions" && $0.subtitle == "Museums and places" && $0.externalLink?.provider == .googleMaps })
            #expect(links.contains { $0.kind == .maps && $0.title == "Public transport" && $0.subtitle == "Routes and tickets" && $0.externalLink?.category == .transport })
            #expect(links.contains { $0.kind == .officialGuide && $0.title == "Official city info" && $0.subtitle == "City visitor information" && $0.externalLink?.provider == .official })
        }
    }

    @Test func bookingExternalLinksAreSafeCitySpecificSearchURLs() throws {
        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)
            let link = try #require(CityDashboardContentData.bookingExternalLink(for: city))

            #expect(link.provider == .booking)
            #expect(link.cityId == cityId)
            #expect(link.category == .hotels)
            #expect(link.audience == [.tourist])
            #expect(link.title == "Hotels in \(city.name)")
            #expect(link.url.scheme == "https")
            #expect(link.url.host == "www.booking.com")
            #expect(link.url.path == "/searchresults.html")

            let components = try #require(URLComponents(url: link.url, resolvingAgainstBaseURL: false))
            let queryItems = components.queryItems ?? []
            #expect(queryItems.contains { $0.name == "ss" && $0.value == city.bookingQuery })
            #expect(!queryItems.contains { $0.name == "aid" && ($0.value?.isEmpty ?? true) })

            if cityId != .amsterdam {
                #expect(!link.url.absoluteString.localizedCaseInsensitiveContains("Amsterdam"))
            }
        }
    }

    @Test func bookingURLBuilderRejectsEmptySearchQuery() {
        #expect(CityDashboardContentData.buildBookingURL(searchQuery: "   ") == nil)
    }

    @Test func foodGuideItemsAreCitySpecificSearchCards() {
        let expectedCategories = Set(FoodGuideCategory.allCases)

        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)
            let items = CityDashboardContentData.foodGuideItems(for: city, audience: .tourist)

            #expect(Set(items.map(\.category)) == expectedCategories)
            #expect(items.count == 8)
            #expect(items.allSatisfy { $0.cityId == cityId })
            #expect(items.allSatisfy { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            #expect(items.allSatisfy { $0.externalUrl?.scheme == "https" })
            #expect(items.allSatisfy { $0.externalUrl?.host == "www.google.com" })
            #expect(items.allSatisfy { $0.query?.localizedCaseInsensitiveContains(city.name) == true })
            #expect(items.allSatisfy { !$0.audience.isEmpty })

            if cityId != .amsterdam {
                #expect(items.allSatisfy { item in
                    item.externalUrl?.absoluteString.localizedCaseInsensitiveContains("Amsterdam") != true
                })
            }
        }
    }

    @Test func foodGuideDoesNotInventVenueFacts() {
        let blockedClaims = ["rating", "ratings", "stars", "opening hours", "open until", "€", "$", "cheap price"]

        for cityId in CityDashboardContentData.supportedCityIds {
            let city = CityDashboardContentData.city(for: cityId)
            let text = CityDashboardContentData.foodGuideItems(for: city, audience: .tourist)
                .flatMap { [$0.title, $0.description, $0.query ?? ""] }
                .joined(separator: " ")
                .lowercased()

            for blockedClaim in blockedClaims {
                #expect(!text.contains(blockedClaim), "\(city.name) food guide should not include \(blockedClaim)")
            }
        }
    }

    @Test func nonAmsterdamDashboardDoesNotLeakAmsterdamTravelOrPlaces() {
        let content = CityDashboardContentData.content(for: "Rotterdam")

        #expect(content.cityName == "Rotterdam")
        #expect(content.places.allSatisfy { $0.cityId == "Rotterdam" })
        #expect(content.travelLinks.allSatisfy { $0.cityId == CityId.rotterdam.rawValue })
        #expect(!content.aiSummary.contains("Amsterdam"))
    }

    @Test func unsupportedCityDoesNotFallbackToAmsterdam() {
        let content = CityDashboardContentData.content(for: "Haarlem")

        #expect(content.city.id == .leiden)
        #expect(content.cityName == "Leiden")
        #expect(content.city.heroImage?.localizedCaseInsensitiveContains("amsterdam") != true)
        #expect(content.travelLinks.allSatisfy { !$0.url.absoluteString.localizedCaseInsensitiveContains("amsterdam") })
    }
}
