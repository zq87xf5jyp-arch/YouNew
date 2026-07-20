import Testing
@testable import YouNew

@Suite("Typed category route serialization")
struct TypedCategoryRouteSerializationTests {
    @Test func everyCityScopedListHasAResolvableTypedDetail() {
        for cityID in CityId.allCases {
            let city = CityDashboardContentData.city(for: cityID)
            let places = DashboardPlacesData.visiblePlaces(cityId: city.name, audience: .tourist, limit: nil)

            let requestedPlaceGroups: [[VisitPlaceCategory]] = [
                [.museum],
                [.park, .viewpoint, .hiddenGem],
                [.historic, .landmark]
            ]
            #expect(!places.isEmpty, "Missing general places for \(city.name)")
            for categories in requestedPlaceGroups {
                let place = places.first { !Set($0.category).isDisjoint(with: Set(categories)) }
                #expect(place != nil, "Missing typed place category \(categories) for \(city.name)")
                if let place {
                    #expect(DashboardPlacesData.detailPlace(id: place.id)?.id == place.id)
                }
            }

            let food = CityDashboardContentData.foodGuideItems(for: city, audience: .tourist, limit: nil)
            let restaurant = food.first { [.restaurant, .localFood, .vegetarian, .budget, .fineDining].contains($0.category) }
            let cafe = food.first { [.cafe, .breakfast].contains($0.category) }
            #expect(restaurant != nil, "Missing restaurant detail for \(city.name)")
            #expect(cafe != nil, "Missing café detail for \(city.name)")
            if let restaurant {
                let destination = AppDestination.restaurantDetail(city: cityID, itemID: restaurant.id)
                #expect(AppNavigationResolver.destination(for: AppNavigationResolver.routeID(from: destination)) == destination)
            }
            if let cafe {
                let destination = AppDestination.cafeDetail(city: cityID, itemID: cafe.id)
                #expect(AppNavigationResolver.destination(for: AppNavigationResolver.routeID(from: destination)) == destination)
            }

            let event = DashboardCalendarData.upcomingEvents(cityId: city.name, audience: .tourist, limit: nil).first
            #expect(event != nil, "Missing upcoming event detail for \(city.name)")
            if let event {
                #expect(DashboardCalendarData.detailEvent(id: event.id)?.id == event.id)
            }
        }
    }

    @Test func cityScopedListRoutesRoundTripWithoutFallback() {
        for city in CityId.allCases {
            let destinations: [AppDestination] = [
                .placeList(city: city),
                .museumList(city: city),
                .natureList(city: city),
                .landmarkList(city: city),
                .eventList(city: city),
                .restaurantList(city: city),
                .cafeList(city: city)
            ]

            for destination in destinations {
                let routeID = AppNavigationResolver.routeID(from: destination)
                #expect(routeID != nil)
                #expect(AppNavigationResolver.destination(for: routeID) == destination)
            }

            for type in DiscoveryListType.allCases {
                let destination = AppDestination.discoveryList(city: city, type: type)
                let routeID = AppNavigationResolver.routeID(from: destination)
                #expect(routeID != nil)
                #expect(AppNavigationResolver.destination(for: routeID) == destination)
            }
        }

        #expect(AppNavigationResolver.destination(for: "museumList:unknown-city") == nil)
        #expect(AppNavigationResolver.destination(for: "museumList") == nil)
        #expect(AppNavigationResolver.destination(for: "museumList:leiden:unexpected") == nil)
        #expect(AppNavigationResolver.destination(for: "discoveryList:leiden:unknown") == nil)
        #expect(AppNavigationResolver.destination(for: "discoveryList:unknown-city:gallery") == nil)
        #expect(AppNavigationResolver.destination(for: "discoveryList:leiden") == nil)
    }

    @Test func typedSectionRoutesRoundTripAndRejectUnknownTypes() {
        let destinations = HousingSectionType.allCases.map(AppDestination.housingSection)
            + GovernmentSectionType.allCases.map(AppDestination.governmentSection)
            + TransportSectionType.allCases.map(AppDestination.transportSection)
            + EducationSectionType.allCases.map(AppDestination.educationSection)
            + WorkSectionType.allCases.map(AppDestination.workSection)
            + HealthSectionType.allCases.map(AppDestination.healthSection)
            + CityId.allCases.flatMap { city in
                LeisureSectionType.allCases.map { AppDestination.leisureSection(city: city, type: $0) }
            }

        for destination in destinations {
            let routeID = AppNavigationResolver.routeID(from: destination)
            #expect(routeID != nil)
            #expect(AppNavigationResolver.destination(for: routeID) == destination)
        }

        #expect(AppNavigationResolver.destination(for: "housingSection:unknown") == nil)
        #expect(AppNavigationResolver.destination(for: "governmentSection") == nil)
        #expect(AppNavigationResolver.destination(for: "workSection:unknown") == nil)
        #expect(AppNavigationResolver.destination(for: "workSection:overview:unexpected") == nil)
        #expect(AppNavigationResolver.destination(for: "healthSection") == nil)
        #expect(AppNavigationResolver.destination(for: "healthSection:unknown") == nil)
        #expect(AppNavigationResolver.destination(for: "leisureSection:leiden:unknown") == nil)
        #expect(AppNavigationResolver.destination(for: "leisureSection:unknown:family") == nil)
    }

    @Test func workAndHealthRoutesResolveDirectDetailsAndMigrateLegacySectionIDs() {
        let workDetails: [(WorkSectionType, String)] = [
            (.permitsAndRights, "working-permit"),
            (.salaryTaxes, "salary-taxes"),
            (.jobSearch, "job-search-nl")
        ]
        for (type, articleID) in workDetails {
            let destination = AppDestination.workSection(type)
            #expect(RelatedContentEngine.isVisible(destination, for: nil))
            #expect(GuideContent.article(sectionID: "work", articleID: articleID) != nil)
            #expect(InformationArchitecture.section(for: destination) == .workStudy)
        }

        let healthDetails: [(HealthSectionType, String)] = [
            (.insurance, "insurance"),
            (.huisarts, "huisarts"),
            (.urgentCare, "urgent-care")
        ]
        for (type, articleID) in healthDetails {
            let destination = AppDestination.healthSection(type)
            #expect(RelatedContentEngine.isVisible(destination, for: nil))
            #expect(GuideContent.article(sectionID: "healthcare", articleID: articleID) != nil)
            #expect(InformationArchitecture.section(for: destination) == .healthcare)
        }

        #expect(AppNavigationResolver.destination(for: "guide:work") == .workSection(.overview))
        #expect(AppNavigationResolver.destination(for: "guide:healthcare") == .healthSection(.overview))
        #expect(AppNavigationResolver.destination(for: "guide:housing") == .housingSection(.overview))
        #expect(AppNavigationResolver.destination(for: "guide:transport") == .transportSection(.overview))
        #expect(KnowledgeIndexBuilder.guideSectionDestination(for: "work") == .workSection(.overview))
        #expect(KnowledgeIndexBuilder.guideSectionDestination(for: "healthcare") == .healthSection(.overview))
        #expect(KnowledgeIndexBuilder.guideSectionDestination(for: "housing") == .housingSection(.overview))
        #expect(KnowledgeIndexBuilder.guideSectionDestination(for: "transport") == .transportSection(.overview))
        #expect(KnowledgeIndexBuilder.guideSectionDestination(for: "documents") == .guideSection("documents"))
    }

    @Test func foodDetailRoutesRoundTripOnlyForTheCorrectCityAndCategory() {
        let restaurant = AppDestination.restaurantDetail(city: .leiden, itemID: "leiden-verified-food-1")
        let cafe = AppDestination.cafeDetail(city: .leiden, itemID: "leiden-verified-food-4")

        for destination in [restaurant, cafe] {
            let routeID = AppNavigationResolver.routeID(from: destination)
            #expect(routeID != nil)
            #expect(AppNavigationResolver.destination(for: routeID) == destination)
        }

        #expect(AppNavigationResolver.destination(for: "restaurantDetail:leiden:leiden-verified-food-4") == nil)
        #expect(AppNavigationResolver.destination(for: "cafeDetail:leiden:leiden-verified-food-1") == nil)
        #expect(AppNavigationResolver.destination(for: "restaurantDetail:utrecht:leiden-verified-food-1") == nil)
        #expect(AppNavigationResolver.destination(for: "restaurantDetail:leiden:missing") == nil)
    }
}
