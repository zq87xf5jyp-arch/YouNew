import XCTest
@testable import YouNew

final class DiscoveryMenuRoutingTests: XCTestCase {
    func testRoutesUseStableIdentifiers() {
        XCTAssertEqual(DiscoveryMenuRoute.museums.id, "museums")
        XCTAssertEqual(DiscoveryMenuRoute.cafes.id, "cafes")
        XCTAssertEqual(DiscoveryMenuRoute.eventsToday.id, "events-today")
        XCTAssertEqual(DiscoveryMenuRoute.businessLogin.id, "business-login")
        XCTAssertEqual(Set(DiscoveryMenuRoute.allCases.map(\.id)).count, DiscoveryMenuRoute.allCases.count)
    }

    func testCategoryDestinationsAreSpecific() {
        let city = CityId.leiden

        XCTAssertEqual(DiscoveryMenuRoute.museums.destination(city: city), .museumList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.parks.destination(city: city), .natureList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.nature.destination(city: city), .natureList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.attractions.destination(city: city), .landmarkList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.historicPlaces.destination(city: city), .landmarkList(city: city))
        XCTAssertEqual(
            DiscoveryMenuRoute.architecture.destination(city: city),
            .leisureSection(city: city, type: .architecture)
        )
        XCTAssertEqual(
            DiscoveryMenuRoute.familyActivities.destination(city: city),
            .leisureSection(city: city, type: .family)
        )
        XCTAssertEqual(DiscoveryMenuRoute.freePlaces.destination(city: city), .discoveryList(city: city, type: .freePlaces))
        XCTAssertEqual(DiscoveryMenuRoute.restaurants.destination(city: city), .restaurantList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.localFood.destination(city: city), .discoveryList(city: city, type: .localFood))
        XCTAssertEqual(DiscoveryMenuRoute.vegetarian.destination(city: city), .discoveryList(city: city, type: .vegetarian))
        XCTAssertEqual(DiscoveryMenuRoute.cafes.destination(city: city), .cafeList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.bakeries.destination(city: city), .cafeList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.breakfast.destination(city: city), .discoveryList(city: city, type: .breakfast))
        XCTAssertEqual(
            DiscoveryMenuRoute.bars.destination(city: city),
            .leisureSection(city: city, type: .nightlife)
        )
        XCTAssertEqual(DiscoveryMenuRoute.eventsToday.destination(city: city), .eventList(city: city))
        XCTAssertEqual(DiscoveryMenuRoute.eventsWeekend.destination(city: city), .discoveryList(city: city, type: .eventsWeekend))
        XCTAssertEqual(DiscoveryMenuRoute.eventsWeek.destination(city: city), .discoveryList(city: city, type: .eventsWeek))
        XCTAssertEqual(DiscoveryMenuRoute.eventsFestivals.destination(city: city), .discoveryList(city: city, type: .eventsFestivals))
        XCTAssertEqual(DiscoveryMenuRoute.gallery.destination(city: city), .discoveryList(city: city, type: .gallery))
        XCTAssertEqual(DiscoveryMenuRoute.hotels.destination(city: city), .discoveryList(city: city, type: .hotels))
        XCTAssertEqual(DiscoveryMenuRoute.shopping.destination(city: city), .discoveryList(city: city, type: .shopping))
    }

    func testNoDiscoveryMenuRouteUsesGenericHomeExploreFallback() {
        let city = CityId.leiden

        for route in DiscoveryMenuRoute.allCases {
            let routeID = AppNavigationResolver.routeID(from: route.destination(city: city))
            XCTAssertFalse(routeID?.hasPrefix("homeExploreList:") == true, "Discovery route \(route.id) uses the generic home explore fallback")
        }

        XCTAssertNil(AppNavigationResolver.destination(for: "homeExploreList:gallery"))
    }

    func testBusinessDestinationsRemainSeparateFromUserProfile() {
        let city = CityId.leiden

        XCTAssertEqual(DiscoveryMenuRoute.businessRegister.destination(city: city), .businessGrowth)
        XCTAssertEqual(DiscoveryMenuRoute.businessLogin.destination(city: city), .businessLogin)
        XCTAssertEqual(DiscoveryMenuRoute.businessManage.destination(city: city), .businessDashboard)
        XCTAssertNotEqual(DiscoveryMenuRoute.businessLogin.destination(city: city), .profileSelection)
    }
}
