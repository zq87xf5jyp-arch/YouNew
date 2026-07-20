import XCTest

final class CategoryRoutingRuntimeUITests: XCTestCase {
    private struct ChipRoute {
        let chipID: String
        let destinationID: String
    }

    private struct DetailRoute {
        let routeID: String
        let listID: String
        let detailLinkID: String?
        let detailLinkPrefix: String?
        let detailID: String?
        let detailPrefix: String?

        init(
            _ routeID: String,
            listID: String,
            detailLinkID: String? = nil,
            detailLinkPrefix: String? = nil,
            detailID: String? = nil,
            detailPrefix: String? = nil
        ) {
            self.routeID = routeID
            self.listID = listID
            self.detailLinkID = detailLinkID
            self.detailLinkPrefix = detailLinkPrefix
            self.detailID = detailID
            self.detailPrefix = detailPrefix
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    // MARK: - Every visible Home chip

    @MainActor
    func testCityProfileAndGovernmentChipsUseIndependentDestinations() {
        verifyChipRoutes([
            ChipRoute(chipID: "home.categoryChip.city.places", destinationID: "category.list.places.leiden"),
            ChipRoute(chipID: "home.categoryChip.city.today", destinationID: "category.list.events.leiden"),
            ChipRoute(chipID: "home.categoryChip.profile.city", destinationID: "city.detail.leiden"),
            ChipRoute(chipID: "home.categoryChip.profile.checklist", destinationID: "checklist.screen"),
            ChipRoute(chipID: "home.categoryChip.government.municipality", destinationID: "category.section.government.municipality"),
            ChipRoute(chipID: "home.categoryChip.government.ind", destinationID: "category.section.government.ind"),
            ChipRoute(chipID: "home.categoryChip.government.digid", destinationID: "category.section.government.digid"),
            ChipRoute(chipID: "home.categoryChip.government.taxes", destinationID: "category.section.government.taxes"),
            ChipRoute(chipID: "home.categoryChip.government.healthcare", destinationID: "category.section.government.healthcare")
        ])
    }

    @MainActor
    func testPlacesAndHousingChipsUseIndependentDestinations() {
        verifyChipRoutes([
            ChipRoute(chipID: "home.categoryChip.places.museums", destinationID: "category.list.museums.leiden"),
            ChipRoute(chipID: "home.categoryChip.places.nature", destinationID: "category.list.nature.leiden"),
            ChipRoute(chipID: "home.categoryChip.places.landmarks", destinationID: "category.list.landmarks.leiden"),
            ChipRoute(chipID: "home.categoryChip.places.today", destinationID: "category.list.events.leiden"),
            ChipRoute(chipID: "home.categoryChip.housing.rent", destinationID: "category.section.housing.rent"),
            ChipRoute(chipID: "home.categoryChip.housing.buy", destinationID: "category.section.housing.buy"),
            ChipRoute(chipID: "home.categoryChip.housing.studentHousing", destinationID: "category.section.housing.studentHousing"),
            ChipRoute(chipID: "home.categoryChip.housing.socialHousing", destinationID: "category.section.housing.socialHousing")
        ])
    }

    @MainActor
    func testTransportChipsUseIndependentDestinations() {
        verifyChipRoutes([
            ChipRoute(chipID: "home.categoryChip.transport.train", destinationID: "category.section.transport.train"),
            ChipRoute(chipID: "home.categoryChip.transport.bus", destinationID: "category.section.transport.bus"),
            ChipRoute(chipID: "home.categoryChip.transport.metro", destinationID: "category.section.transport.metro"),
            ChipRoute(chipID: "home.categoryChip.transport.bike", destinationID: "category.section.transport.bike"),
            ChipRoute(chipID: "home.categoryChip.transport.parking", destinationID: "category.section.transport.parking"),
            ChipRoute(chipID: "home.categoryChip.transport.journeyPlanner", destinationID: "category.section.transport.journeyPlanner"),
            ChipRoute(chipID: "home.categoryChip.transport.ovChipkaart", destinationID: "category.section.transport.ovChipkaart")
        ])
    }

    @MainActor
    func testLeisureAndEducationChipsUseIndependentDestinations() {
        verifyChipRoutes([
            ChipRoute(chipID: "home.categoryChip.leisure.museums", destinationID: "category.list.museums.leiden"),
            ChipRoute(chipID: "home.categoryChip.leisure.events", destinationID: "category.list.events.leiden"),
            ChipRoute(chipID: "home.categoryChip.leisure.parks", destinationID: "category.list.nature.leiden"),
            ChipRoute(chipID: "home.categoryChip.leisure.nightlife", destinationID: "category.list.nightlife.leiden"),
            ChipRoute(chipID: "home.categoryChip.leisure.weekend", destinationID: "category.list.weekend.leiden"),
            ChipRoute(chipID: "home.categoryChip.leisure.family", destinationID: "category.list.family-activities.leiden"),
            ChipRoute(chipID: "home.categoryChip.education.universities", destinationID: "category.section.education.universities"),
            ChipRoute(chipID: "home.categoryChip.education.duo", destinationID: "category.section.education.duo"),
            ChipRoute(chipID: "home.categoryChip.education.languageSchools", destinationID: "category.section.education.languageSchools"),
            ChipRoute(chipID: "home.categoryChip.education.drivingSchools", destinationID: "category.section.education.drivingSchools"),
            ChipRoute(chipID: "home.categoryChip.education.studentFinance", destinationID: "category.section.education.studentFinance")
        ])
    }

    @MainActor
    func testAIAndDiscoverChipsUseIndependentDestinations() {
        verifyChipRoutes([
            ChipRoute(chipID: "home.categoryChip.ai.bsn", destinationID: "category.section.government.municipality"),
            ChipRoute(chipID: "home.categoryChip.ai.digid", destinationID: "category.section.government.digid"),
            ChipRoute(chipID: "home.categoryChip.ai.housing", destinationID: "category.section.housing.overview"),
            ChipRoute(chipID: "home.categoryChip.ai.healthcare", destinationID: "category.section.government.healthcare"),
            ChipRoute(chipID: "home.categoryChip.ai.transport", destinationID: "category.section.transport.overview"),
            ChipRoute(chipID: "home.categoryChip.discover.cities", destinationID: "cities.screen"),
            ChipRoute(chipID: "home.categoryChip.discover.museums", destinationID: "category.list.museums.leiden"),
            ChipRoute(chipID: "home.categoryChip.discover.nature", destinationID: "category.list.nature.leiden"),
            ChipRoute(chipID: "home.categoryChip.discover.architecture", destinationID: "category.list.architecture.leiden"),
            ChipRoute(chipID: "home.categoryChip.discover.history", destinationID: "history.screen"),
            ChipRoute(chipID: "home.categoryChip.discover.culture", destinationID: "culture.screen"),
            ChipRoute(chipID: "home.categoryChip.discover.seasonal", destinationID: "holidays.screen")
        ])
    }

    // MARK: - List -> detail -> back for every typed route

    @MainActor
    func testEveryCityScopedCategoryListReachesItsTypedDetailAndReturns() {
        verifyDetailRoutes([
            DetailRoute("placeList:leiden", listID: "category.list.places.leiden", detailLinkPrefix: "category.detailLink.places.", detailPrefix: "place.detail."),
            DetailRoute("museumList:leiden", listID: "category.list.museums.leiden", detailLinkPrefix: "category.detailLink.museums.", detailPrefix: "place.detail."),
            DetailRoute("natureList:leiden", listID: "category.list.nature.leiden", detailLinkPrefix: "category.detailLink.nature.", detailPrefix: "place.detail."),
            DetailRoute("landmarkList:leiden", listID: "category.list.landmarks.leiden", detailLinkPrefix: "category.detailLink.landmarks.", detailPrefix: "place.detail."),
            DetailRoute("eventList:leiden", listID: "category.list.events.leiden", detailLinkPrefix: "category.detailLink.events.", detailPrefix: "event.detail."),
            DetailRoute("restaurantList:leiden", listID: "category.list.restaurants.leiden", detailLinkPrefix: "category.detailLink.restaurants.", detailPrefix: "restaurant.detail."),
            DetailRoute("cafeList:leiden", listID: "category.list.cafes.leiden", detailLinkPrefix: "category.detailLink.cafes.", detailPrefix: "cafe.detail.")
        ])
    }

    @MainActor
    func testEveryHousingAndGovernmentSectionReachesDetailAndReturns() {
        verifyDetailRoutes([
            DetailRoute("housingSection:overview", listID: "category.section.housing.overview", detailLinkID: "category.section.detailLink.housing.overview.housing-overview", detailID: "guide.article.renting"),
            DetailRoute("housingSection:rent", listID: "category.section.housing.rent", detailLinkID: "category.section.detailLink.housing.rent.rent", detailID: "guide.article.renting"),
            DetailRoute("housingSection:buy", listID: "category.section.housing.buy", detailLinkID: "category.section.detailLink.housing.buy.buy", detailID: "practicalGuide.housingBasics"),
            DetailRoute("housingSection:studentHousing", listID: "category.section.housing.studentHousing", detailLinkID: "category.section.detailLink.housing.studentHousing.student-housing", detailID: "guide.article.renting"),
            DetailRoute("housingSection:socialHousing", listID: "category.section.housing.socialHousing", detailLinkID: "category.section.detailLink.housing.socialHousing.social-housing", detailID: "guide.article.tenant-rights"),
            DetailRoute("governmentSection:overview", listID: "category.section.government.overview", detailLinkID: "category.section.detailLink.government.overview.municipality", detailID: "institution.detail.municipality"),
            DetailRoute("governmentSection:municipality", listID: "category.section.government.municipality", detailLinkID: "category.section.detailLink.government.municipality.municipality", detailID: "institution.detail.municipality"),
            DetailRoute("governmentSection:ind", listID: "category.section.government.ind", detailLinkID: "category.section.detailLink.government.ind.ind", detailID: "institution.detail.ind"),
            DetailRoute("governmentSection:digid", listID: "category.section.government.digid", detailLinkID: "category.section.detailLink.government.digid.digid", detailID: "institution.detail.digid"),
            DetailRoute("governmentSection:taxes", listID: "category.section.government.taxes", detailLinkID: "category.section.detailLink.government.taxes.taxes", detailID: "institution.detail.taxdienst"),
            DetailRoute("governmentSection:healthcare", listID: "category.section.government.healthcare", detailLinkID: "category.section.detailLink.government.healthcare.healthcare", detailID: "practicalGuide.healthcareBasics")
        ])
    }

    @MainActor
    func testEveryTransportSectionReachesDetailAndReturns() {
        verifyDetailRoutes([
            DetailRoute("transportSection:overview", listID: "category.section.transport.overview", detailLinkID: "category.section.detailLink.transport.overview.transport-overview", detailID: "guide.article.ov-chipkaart"),
            DetailRoute("transportSection:train", listID: "category.section.transport.train", detailLinkID: "category.section.detailLink.transport.train.train", detailID: "guide.article.trains"),
            DetailRoute("transportSection:bus", listID: "category.section.transport.bus", detailLinkID: "category.section.detailLink.transport.bus.bus", detailID: "guide.article.ov-chipkaart"),
            DetailRoute("transportSection:metro", listID: "category.section.transport.metro", detailLinkID: "category.section.detailLink.transport.metro.metro", detailID: "guide.article.ov-chipkaart"),
            DetailRoute("transportSection:bike", listID: "category.section.transport.bike", detailLinkID: "category.section.detailLink.transport.bike.bike", detailID: "guide.article.bicycle"),
            DetailRoute("transportSection:parking", listID: "category.section.transport.parking", detailLinkID: "category.section.detailLink.transport.parking.parking", detailID: "practicalGuide.transportBasics"),
            DetailRoute("transportSection:journeyPlanner", listID: "category.section.transport.journeyPlanner", detailLinkID: "category.section.detailLink.transport.journeyPlanner.journey-planner", detailID: "practicalGuide.transportBasics"),
            DetailRoute("transportSection:ovChipkaart", listID: "category.section.transport.ovChipkaart", detailLinkID: "category.section.detailLink.transport.ovChipkaart.ov-chipkaart", detailID: "guide.article.ov-chipkaart")
        ])
    }

    @MainActor
    func testEveryEducationSectionReachesDetailAndReturns() {
        verifyDetailRoutes([
            DetailRoute("educationSection:overview", listID: "category.section.education.overview", detailLinkID: "category.section.detailLink.education.overview.universities", detailID: "institution.detail.duo"),
            DetailRoute("educationSection:universities", listID: "category.section.education.universities", detailLinkID: "category.section.detailLink.education.universities.universities", detailID: "institution.detail.duo"),
            DetailRoute("educationSection:duo", listID: "category.section.education.duo", detailLinkID: "category.section.detailLink.education.duo.duo", detailID: "institution.detail.duo"),
            DetailRoute("educationSection:languageSchools", listID: "category.section.education.languageSchools", detailLinkID: "category.section.detailLink.education.languageSchools.language-schools", detailID: "dutchA1A2.screen"),
            DetailRoute("educationSection:drivingSchools", listID: "category.section.education.drivingSchools", detailLinkID: "category.section.detailLink.education.drivingSchools.driving-schools", detailID: "institution.detail.rdw"),
            DetailRoute("educationSection:studentFinance", listID: "category.section.education.studentFinance", detailLinkID: "category.section.detailLink.education.studentFinance.student-finance", detailID: "institution.detail.duo")
        ])
    }

    @MainActor
    func testEveryLeisureSectionReachesDetailAndReturns() {
        verifyDetailRoutes([
            DetailRoute("leisureSection:leiden:nightlife", listID: "category.list.nightlife.leiden", detailLinkID: "home.exploreList.action.late-transport", detailID: "practicalGuide.transportBasics"),
            DetailRoute("leisureSection:leiden:architecture", listID: "category.list.architecture.leiden", detailLinkPrefix: "category.detailLink.architecture.", detailPrefix: "place.detail.")
        ])

        let nestedRoutes: [(route: String, root: String, action: String)] = [
            ("leisureSection:leiden:weekend", "category.list.weekend.leiden", "home.exploreList.action.weekend-museums"),
            ("leisureSection:leiden:family", "category.list.family-activities.leiden", "home.exploreList.action.family-museums")
        ]

        for route in nestedRoutes {
            let app = launchDestination(route.route)
            let root = app.descendants(matching: .any)[route.root]
            XCTAssertTrue(root.waitForExistence(timeout: 8), "Typed leisure route opened the wrong list: \(route.route)")

            let action = app.descendants(matching: .any)[route.action]
            if !action.waitForExistence(timeout: 2), route.route.contains(":weekend") {
                let eventLink = element(prefix: "category.detailLink.weekend.", in: app)
                scrollToElement(eventLink, in: app)
                XCTAssertTrue(eventLink.isHittable, "Weekend list has neither an event nor a verified category path")
                eventLink.tap()
                XCTAssertTrue(element(prefix: "event.detail.", in: app).waitForExistence(timeout: 8), "Weekend event opened the wrong detail")
                navigateBack(in: app)
                XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to the weekend list")
                app.terminate()
                continue
            }

            scrollToElement(action, in: app)
            XCTAssertTrue(action.isHittable, "Leisure category has no in-app detail path: \(route.route)")
            action.tap()

            let museumList = app.descendants(matching: .any)["category.list.museums.leiden"]
            XCTAssertTrue(museumList.waitForExistence(timeout: 6), "Leisure category opened the wrong nested list: \(route.route)")
            let placeLink = element(prefix: "category.detailLink.museums.", in: app)
            scrollToElement(placeLink, in: app)
            XCTAssertTrue(placeLink.isHittable, "Nested museum list has no detail for \(route.route)")
            placeLink.tap()
            XCTAssertTrue(element(prefix: "place.detail.", in: app).waitForExistence(timeout: 8), "Nested leisure route opened the wrong detail: \(route.route)")

            navigateBack(in: app)
            XCTAssertTrue(museumList.waitForExistence(timeout: 6), "Back did not return to the nested museum list: \(route.route)")
            navigateBack(in: app)
            XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to the leisure list: \(route.route)")
            app.terminate()
        }
    }

    @MainActor
    func testRequestedDiscoveryChipsReachTheirTypedDetailAndReturn() {
        let cases: [(group: String, chip: String, list: String, detailLink: String, detail: String)] = [
            ("sideMenu.places", "sideMenu.places.museums", "category.list.museums.leiden", "category.detailLink.museums.", "place.detail."),
            ("sideMenu.places", "sideMenu.places.attractions", "category.list.landmarks.leiden", "category.detailLink.landmarks.", "place.detail."),
            ("sideMenu.places", "sideMenu.places.historic-places", "category.list.landmarks.leiden", "category.detailLink.landmarks.", "place.detail."),
            ("sideMenu.places", "sideMenu.places.parks", "category.list.nature.leiden", "category.detailLink.nature.", "place.detail."),
            ("sideMenu.food", "sideMenu.food.restaurants", "category.list.restaurants.leiden", "category.detailLink.restaurants.", "restaurant.detail."),
            ("sideMenu.food", "sideMenu.food.cafes", "category.list.cafes.leiden", "category.detailLink.cafes.", "cafe.detail."),
            ("sideMenu.food", "sideMenu.food.local-food", "category.list.local-food.leiden", "category.detailLink.local-food.", "restaurant.detail."),
            ("sideMenu.food", "sideMenu.food.vegetarian", "category.list.vegetarian.leiden", "category.detailLink.vegetarian.", "restaurant.detail."),
            ("sideMenu.food", "sideMenu.food.breakfast", "category.list.breakfast.leiden", "category.detailLink.breakfast.", "cafe.detail."),
            ("sideMenu.events", "sideMenu.events.events-today", "category.list.events.leiden", "category.detailLink.events.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-weekend", "category.list.events-weekend.leiden", "category.detailLink.events-weekend.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-week", "category.list.events-week.leiden", "category.detailLink.events-week.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-museums", "category.list.events-museums.leiden", "category.detailLink.events-museums.", "event.detail.")
        ]

        for item in cases {
            verifyDiscoveryChip(item, required: true)
        }
    }

    @MainActor
    func testEventSideMenuOnlyShowsFilteredCategoriesWithDetails() {
        let requiredCases: [(group: String, chip: String, list: String, detailLink: String, detail: String)] = [
            ("sideMenu.events", "sideMenu.events.events-today", "category.list.events.leiden", "category.detailLink.events.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-weekend", "category.list.events-weekend.leiden", "category.detailLink.events-weekend.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-week", "category.list.events-week.leiden", "category.detailLink.events-week.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-museums", "category.list.events-museums.leiden", "category.detailLink.events-museums.", "event.detail.")
        ]

        for item in requiredCases {
            verifyDiscoveryChip(item, required: true)
        }

        let dataDependentCases: [(group: String, chip: String, list: String, detailLink: String, detail: String)] = [
            ("sideMenu.events", "sideMenu.events.events-free", "category.list.events-free.leiden", "category.detailLink.events-free.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-family", "category.list.events-family.leiden", "category.detailLink.events-family.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-music", "category.list.events-music.leiden", "category.detailLink.events-music.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-markets", "category.list.events-markets.leiden", "category.detailLink.events-markets.", "event.detail."),
            ("sideMenu.events", "sideMenu.events.events-festivals", "category.list.events-festivals.leiden", "category.detailLink.events-festivals.", "event.detail.")
        ]

        for item in dataDependentCases {
            verifyDiscoveryChip(item, required: false)
        }
    }

    @MainActor
    func testAdditionalVisibleDiscoveryCategoriesReachTheirOwnTypedListsAndReturn() {
        verifyDiscoveryFamilyCategory()
        verifyDiscoveryPartnerCategory()
        verifyDiscoveryGalleryCategory()
    }

    @MainActor
    func testDiscoverNetherlandsTypedCategoryCardsReachTheirDetailAndReturn() {
        let cases: [(chip: String, list: String)] = [
            ("discoverNetherlands.category.museums", "category.list.museums.leiden"),
            ("discoverNetherlands.category.nature", "category.list.nature.leiden"),
            ("discoverNetherlands.category.architecture", "category.list.architecture.leiden")
        ]

        for item in cases {
            let app = launchDestination("discoverNetherlands")
            let root = app.descendants(matching: .any)["discoverNetherlands.screen"]
            XCTAssertTrue(root.waitForExistence(timeout: 8), "Discover Netherlands did not open")

            let chip = app.descendants(matching: .any)[item.chip]
            scrollToElement(chip, in: app)
            XCTAssertTrue(chip.exists, "Missing Discover Netherlands category: \(item.chip)")
            XCTAssertTrue(chip.isHittable, "Discover Netherlands category is not independently hittable: \(item.chip)")
            chip.tap()

            let list = app.descendants(matching: .any)[item.list]
            XCTAssertTrue(list.waitForExistence(timeout: 8), "Discover Netherlands category opened the wrong list: \(item.chip)")
            guard let route = detailRoute(for: item.list) else {
                XCTFail("Missing typed detail route for \(item.list)")
                app.terminate()
                continue
            }
            verifyDetailTraversal(route, list: list, in: app)

            navigateBack(in: app)
            XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Discover Netherlands after \(item.chip)")
            app.terminate()
        }

        verifyDiscoverNetherlandsCitiesCard()

        let directCases: [(chip: String, destination: String)] = [
            ("discoverNetherlands.category.history", "history.screen"),
            ("discoverNetherlands.category.culture", "culture.screen"),
            ("discoverNetherlands.category.seasonal", "holidays.screen")
        ]

        for item in directCases {
            let app = launchDestination("discoverNetherlands")
            let root = app.descendants(matching: .any)["discoverNetherlands.screen"]
            XCTAssertTrue(root.waitForExistence(timeout: 8), "Discover Netherlands did not open")

            let chip = app.descendants(matching: .any)[item.chip]
            scrollToElement(chip, in: app)
            XCTAssertTrue(chip.exists && chip.isHittable, "Discover Netherlands category is unavailable: \(item.chip)")
            chip.tap()

            let destination = app.descendants(matching: .any)[item.destination]
            XCTAssertTrue(destination.waitForExistence(timeout: 8), "Discover Netherlands category opened the wrong destination: \(item.chip)")

            if item.destination == "holidays.screen" {
                verifyHolidayExpansion(in: app)
            }

            navigateBack(in: app)
            XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Discover Netherlands after \(item.chip)")
            app.terminate()
        }
    }

    @MainActor
    func testGuideHousingGovernmentTransportAndEducationCardsUseTypedRoutes() {
        let cases: [(chip: String, list: String)] = [
            ("guide.category.housing", "category.section.housing.overview"),
            ("guide.category.official-services", "category.section.government.overview"),
            ("guide.category.work-money", "category.section.work.overview"),
            ("guide.category.study", "category.section.education.overview"),
            ("guide.category.health-safety", "category.section.health.overview"),
            ("guide.category.transport", "category.section.transport.overview"),
        ]

        let app = launch(arguments: ["-uiTestingStartTab", "guide"])
        let root = app.descendants(matching: .any)["screen.guide"]
        XCTAssertTrue(root.waitForExistence(timeout: 8), "Guide did not open")

        let gettingStarted = app.descendants(matching: .any)["guide.category.getting-started"]
        scrollToElement(gettingStarted, in: app)
        XCTAssertTrue(gettingStarted.exists && gettingStarted.isHittable, "Getting Started Guide category is unavailable")
        gettingStarted.tap()

        let firstSteps = app.descendants(matching: .any)["firstSteps.screen"]
        XCTAssertTrue(firstSteps.waitForExistence(timeout: 8), "Getting Started opened the wrong destination")
        let firstStepDetail = app.descendants(matching: .any)["firstSteps.detailLink.first-steps"]
        scrollToElement(firstStepDetail, in: app)
        XCTAssertTrue(firstStepDetail.exists && firstStepDetail.isHittable, "Getting Started has no independently hittable detail")
        firstStepDetail.tap()
        XCTAssertTrue(app.descendants(matching: .any)["practicalGuide.firstStepsNetherlands"].waitForExistence(timeout: 8), "Getting Started opened the wrong detail")
        navigateBack(in: app)
        XCTAssertTrue(firstSteps.waitForExistence(timeout: 6), "Back did not return to First Steps")
        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Guide after Getting Started")

        for item in cases {
            let chip = app.descendants(matching: .any)[item.chip]
            scrollToElement(chip, in: app)
            XCTAssertTrue(chip.exists, "Missing Guide category card: \(item.chip)")
            XCTAssertTrue(chip.isHittable, "Guide category card is not independently hittable: \(item.chip)")
            chip.tap()

            let list = app.descendants(matching: .any)[item.list]
            XCTAssertTrue(list.waitForExistence(timeout: 8), "Guide category opened the wrong typed section: \(item.chip)")
            guard let route = detailRoute(for: item.list) else {
                XCTFail("Missing typed detail route for \(item.list)")
                continue
            }
            verifyDetailTraversal(route, list: list, in: app)

            navigateBack(in: app)
            XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Guide after \(item.chip)")
        }

        let explore = app.descendants(matching: .any)["guide.category.explore"]
        scrollToElement(explore, in: app)
        XCTAssertTrue(explore.exists && explore.isHittable, "Explore Guide category is unavailable")
        explore.tap()
        let discoverNetherlands = app.descendants(matching: .any)["discoverNetherlands.screen"]
        XCTAssertTrue(discoverNetherlands.waitForExistence(timeout: 8), "Explore opened the wrong destination")

        let museums = app.descendants(matching: .any)["discoverNetherlands.category.museums"]
        scrollToElement(museums, in: app)
        XCTAssertTrue(museums.exists && museums.isHittable, "Explore has no independently hittable category detail")
        museums.tap()
        let museumList = app.descendants(matching: .any)["category.list.museums.leiden"]
        XCTAssertTrue(museumList.waitForExistence(timeout: 8), "Explore category opened the wrong typed list")
        verifyDetailTraversal(
            DetailRoute(
                "guide-explore-museums",
                listID: "category.list.museums.leiden",
                detailLinkPrefix: "category.detailLink.museums.",
                detailPrefix: "place.detail."
            ),
            list: museumList,
            in: app
        )
        navigateBack(in: app)
        XCTAssertTrue(discoverNetherlands.waitForExistence(timeout: 6), "Back did not return to Explore")
        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Guide after Explore")
    }

    @MainActor
    private func verifyDiscoveryFamilyCategory() {
        let app = launchHome()
        tapDiscoveryChip(groupID: "sideMenu.places", chipID: "sideMenu.places.family-activities", in: app)

        let root = app.descendants(matching: .any)["category.list.family-activities.leiden"]
        XCTAssertTrue(root.waitForExistence(timeout: 8), "Family activities opened the wrong typed list")
        verifyNestedMuseumDetail(actionID: "home.exploreList.action.family-museums", root: root, in: app)

        let parks = app.descendants(matching: .any)["home.exploreList.action.family-parks"]
        scrollToElement(parks, in: app)
        XCTAssertTrue(parks.exists && parks.isHittable, "Family Parks category is unavailable")
        parks.tap()
        let natureList = app.descendants(matching: .any)["category.list.nature.leiden"]
        XCTAssertTrue(natureList.waitForExistence(timeout: 6), "Family Parks opened the wrong typed list")
        verifyDetailTraversal(
            DetailRoute(
                "family-parks",
                listID: "category.list.nature.leiden",
                detailLinkPrefix: "category.detailLink.nature.",
                detailPrefix: "place.detail."
            ),
            list: natureList,
            in: app
        )
        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Family activities after Parks")

        navigateBack(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 6), "Back did not return Home after Family activities")
        app.terminate()
    }

    @MainActor
    private func verifyDiscoveryPartnerCategory() {
        let app = launchHome()
        tapDiscoveryChip(groupID: "sideMenu.stay", chipID: "sideMenu.stay.hotels", in: app)

        let root = app.descendants(matching: .any)["category.list.hotels.leiden"]
        XCTAssertTrue(root.waitForExistence(timeout: 8), "Hotels opened the wrong typed list")
        let detailLink = element(prefix: "category.detailLink.hotels.", in: app)
        scrollToElement(detailLink, in: app)
        XCTAssertTrue(detailLink.exists && detailLink.isHittable, "Hotels has no independently hittable partner detail")
        detailLink.tap()
        XCTAssertTrue(app.descendants(matching: .any)["localPartner.detail.hero"].waitForExistence(timeout: 8), "Hotels opened the wrong detail")

        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Hotels")
        navigateBack(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 6), "Back did not return Home after Hotels")
        app.terminate()
    }

    @MainActor
    private func verifyDiscoveryGalleryCategory() {
        let app = launchHome()
        let menu = app.descendants(matching: .any)["home.discoveryMenu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 8), "Discovery menu trigger is missing")
        menu.tap()

        let chip = app.descendants(matching: .any)["sideMenu.gallery"]
        scrollToElement(chip, in: app)
        XCTAssertTrue(chip.exists && chip.isHittable, "Gallery is not independently hittable")
        chip.tap()

        let root = app.descendants(matching: .any)["category.list.gallery.leiden"]
        XCTAssertTrue(root.waitForExistence(timeout: 8), "Gallery opened the wrong typed list")
        verifyDetailTraversal(
            DetailRoute("gallery", listID: "category.list.gallery.leiden", detailLinkPrefix: "category.detailLink.gallery.", detailPrefix: "place.detail."),
            list: root,
            in: app
        )

        navigateBack(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 6), "Back did not return Home after Gallery")
        app.terminate()
    }

    @MainActor
    private func tapDiscoveryChip(groupID: String, chipID: String, in app: XCUIApplication) {
        let menu = app.descendants(matching: .any)["home.discoveryMenu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 8), "Discovery menu trigger is missing")
        menu.tap()

        let group = app.descendants(matching: .any)[groupID]
        scrollToElement(group, in: app)
        XCTAssertTrue(group.exists && group.isHittable, "Discovery group is unavailable: \(groupID)")
        group.tap()

        let chip = app.descendants(matching: .any)[chipID]
        scrollToElement(chip, in: app)
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "Discovery category is missing: \(chipID)")
        XCTAssertTrue(chip.isHittable, "Discovery category is not independently hittable: \(chipID)")
        chip.tap()
    }

    // MARK: - Helpers

    @MainActor
    private func verifyDiscoverNetherlandsCitiesCard() {
        let app = launchDestination("discoverNetherlands")
        let root = app.descendants(matching: .any)["discoverNetherlands.screen"]
        XCTAssertTrue(root.waitForExistence(timeout: 8), "Discover Netherlands did not open")

        let chip = app.descendants(matching: .any)["discoverNetherlands.category.cities"]
        scrollToElement(chip, in: app)
        XCTAssertTrue(chip.exists && chip.isHittable, "Cities category is unavailable")
        chip.tap()

        let list = app.descendants(matching: .any)["cities.screen"]
        XCTAssertTrue(list.waitForExistence(timeout: 8), "Cities category opened the wrong list")
        let city = element(prefix: "cities.detailLink.", in: app)
        scrollToElement(city, in: app)
        XCTAssertTrue(city.exists && city.isHittable, "Cities list has no independently hittable city detail")
        city.tap()
        XCTAssertTrue(element(prefix: "city.detail.", in: app).waitForExistence(timeout: 8), "Cities list opened the wrong detail")

        navigateBack(in: app)
        XCTAssertTrue(list.waitForExistence(timeout: 6), "Back did not return to Cities")
        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to Discover Netherlands after Cities")
        app.terminate()
    }

    @MainActor
    private func verifyDiscoveryChip(
        _ item: (group: String, chip: String, list: String, detailLink: String, detail: String),
        required: Bool
    ) {
        let app = launchHome()
        let menu = app.descendants(matching: .any)["home.discoveryMenu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 8), "Discovery menu trigger is missing")
        guard menu.exists else {
            app.terminate()
            return
        }
        menu.tap()

        let group = app.descendants(matching: .any)[item.group]
        scrollToElement(group, in: app)
        XCTAssertTrue(group.waitForExistence(timeout: 4), "Discovery group is missing: \(item.group)")
        XCTAssertTrue(group.isHittable, "Discovery group is not hittable: \(item.group)")
        guard group.exists && group.isHittable else {
            app.terminate()
            return
        }
        group.tap()

        let chip = app.descendants(matching: .any)[item.chip]
        var attempts = 0
        while (!chip.exists || !chip.isHittable), attempts < 8 {
            app.swipeUp(velocity: .fast)
            attempts += 1
        }
        guard chip.exists && chip.isHittable else {
            if required {
                XCTFail("Discovery chip is missing: \(item.chip)")
            }
            app.terminate()
            return
        }
        chip.tap()

        let list = app.descendants(matching: .any)[item.list]
        XCTAssertTrue(list.waitForExistence(timeout: 6), "Discovery chip opened the wrong list: \(item.chip)")
        guard list.exists else {
            app.terminate()
            return
        }
        let detailLink = element(prefix: item.detailLink, in: app)
        scrollToElement(detailLink, in: app)
        XCTAssertTrue(detailLink.isHittable, "No in-app detail row for \(item.chip)")
        guard detailLink.isHittable else {
            app.terminate()
            return
        }
        detailLink.tap()
        XCTAssertTrue(element(prefix: item.detail, in: app).waitForExistence(timeout: 6), "Wrong detail for \(item.chip)")

        navigateBack(in: app)
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Back did not return to \(item.list)")
        navigateBack(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 5), "Back did not return Home after \(item.chip)")
        app.terminate()
    }

    @MainActor
    private func verifyChipRoutes(_ routes: [ChipRoute]) {
        let app = launchHome()
        XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 8))

        for route in routes {
            let chip = app.descendants(matching: .any)[route.chipID]
            scrollToElement(chip, in: app)
            XCTAssertTrue(chip.exists, "Missing category chip: \(route.chipID)")
            XCTAssertTrue(chip.isHittable, "Category chip is not independently hittable: \(route.chipID)")
            chip.tap()

            let destination = app.descendants(matching: .any)[route.destinationID]
            XCTAssertTrue(destination.waitForExistence(timeout: 6), "\(route.chipID) opened the wrong destination; expected \(route.destinationID)")

            if route.destinationID == "category.list.weekend.leiden" {
                verifyWeekendDetail(from: destination, in: app)
            } else if route.destinationID == "category.list.family-activities.leiden" {
                verifyNestedMuseumDetail(
                    actionID: "home.exploreList.action.family-museums",
                    root: destination,
                    in: app
                )
            } else if route.destinationID == "holidays.screen" {
                verifyHolidayExpansion(in: app)
            } else if route.destinationID == "cities.screen" {
                verifyCityDetail(from: destination, in: app)
            } else if let detailRoute = detailRoute(for: route.destinationID) {
                verifyDetailTraversal(detailRoute, list: destination, in: app)
            }

            navigateBack(in: app)
            XCTAssertTrue(app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 5), "Back did not return Home after \(route.chipID)")
        }
    }

    @MainActor
    private func verifyHolidayExpansion(in app: XCUIApplication) {
        let holiday = element(prefix: "holiday.card.", in: app)
        scrollToElement(holiday, in: app)
        XCTAssertTrue(holiday.exists && holiday.isHittable, "Seasonal Netherlands has no expandable holiday detail")
        holiday.tap()
        let expanded = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "expanded"),
            object: holiday
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [expanded], timeout: 6),
            .completed,
            "Seasonal Netherlands holiday did not reveal its detail"
        )
    }

    @MainActor
    private func verifyCityDetail(from list: XCUIElement, in app: XCUIApplication) {
        let city = element(prefix: "cities.detailLink.", in: app)
        scrollToElement(city, in: app)
        XCTAssertTrue(city.exists && city.isHittable, "Cities has no independently hittable city detail")
        city.tap()
        XCTAssertTrue(element(prefix: "city.detail.", in: app).waitForExistence(timeout: 8), "Cities opened the wrong city detail")
        navigateBack(in: app)
        XCTAssertTrue(list.waitForExistence(timeout: 6), "Back did not return to Cities")
    }

    @MainActor
    private func verifyDetailRoutes(_ routes: [DetailRoute]) {
        for route in routes {
            let app = launchDestination(route.routeID)
            let list = app.descendants(matching: .any)[route.listID]
            XCTAssertTrue(list.waitForExistence(timeout: 8), "Typed route did not open expected list: \(route.routeID)")
            verifyDetailTraversal(route, list: list, in: app)
            app.terminate()
        }
    }

    @MainActor
    private func verifyDetailTraversal(_ route: DetailRoute, list: XCUIElement, in app: XCUIApplication) {
        let link: XCUIElement
        if let detailLinkID = route.detailLinkID {
            link = app.descendants(matching: .any)[detailLinkID]
        } else if let detailLinkPrefix = route.detailLinkPrefix {
            link = element(prefix: detailLinkPrefix, in: app)
        } else {
            XCTFail("Missing detail-link selector for \(route.listID)")
            return
        }

        scrollToElement(link, in: app)
        XCTAssertTrue(link.exists, "Typed list has no detail row: \(route.listID)")
        XCTAssertTrue(link.isHittable, "Typed list detail row is not hittable: \(route.listID)")
        link.tap()

        let detail: XCUIElement
        if let detailID = route.detailID {
            detail = app.descendants(matching: .any)[detailID]
        } else if let detailPrefix = route.detailPrefix {
            detail = element(prefix: detailPrefix, in: app)
        } else {
            XCTFail("Missing detail selector for \(route.listID)")
            return
        }
        XCTAssertTrue(detail.waitForExistence(timeout: 8), "Typed list opened the wrong detail: \(route.listID)")

        navigateBack(in: app)
        XCTAssertTrue(list.waitForExistence(timeout: 6), "Back did not return to the typed list: \(route.listID)")
    }

    @MainActor
    private func verifyWeekendDetail(from root: XCUIElement, in app: XCUIApplication) {
        let eventLink = element(prefix: "category.detailLink.weekend.", in: app)
        if eventLink.waitForExistence(timeout: 1) {
            scrollToElement(eventLink, in: app)
            XCTAssertTrue(eventLink.isHittable, "Weekend event is not independently hittable")
            eventLink.tap()
            XCTAssertTrue(element(prefix: "event.detail.", in: app).waitForExistence(timeout: 8), "Weekend event opened the wrong detail")
            navigateBack(in: app)
            XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to the weekend list")
            return
        }

        verifyNestedMuseumDetail(
            actionID: "home.exploreList.action.weekend-museums",
            root: root,
            in: app
        )
    }

    @MainActor
    private func verifyNestedMuseumDetail(actionID: String, root: XCUIElement, in app: XCUIApplication) {
        let action = app.descendants(matching: .any)[actionID]
        scrollToElement(action, in: app)
        XCTAssertTrue(action.exists && action.isHittable, "Nested museum action is unavailable: \(actionID)")
        action.tap()

        let museumList = app.descendants(matching: .any)["category.list.museums.leiden"]
        XCTAssertTrue(museumList.waitForExistence(timeout: 6), "Nested action opened the wrong museum list: \(actionID)")
        verifyDetailTraversal(
            DetailRoute(
                actionID,
                listID: "category.list.museums.leiden",
                detailLinkPrefix: "category.detailLink.museums.",
                detailPrefix: "place.detail."
            ),
            list: museumList,
            in: app
        )

        navigateBack(in: app)
        XCTAssertTrue(root.waitForExistence(timeout: 6), "Back did not return to the originating leisure list: \(actionID)")
    }

    private func detailRoute(for listID: String) -> DetailRoute? {
        switch listID {
        case "category.list.places.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.places.", detailPrefix: "place.detail.")
        case "category.list.museums.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.museums.", detailPrefix: "place.detail.")
        case "category.list.nature.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.nature.", detailPrefix: "place.detail.")
        case "category.list.landmarks.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.landmarks.", detailPrefix: "place.detail.")
        case "category.list.architecture.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.architecture.", detailPrefix: "place.detail.")
        case "category.list.events.leiden":
            return DetailRoute(listID, listID: listID, detailLinkPrefix: "category.detailLink.events.", detailPrefix: "event.detail.")
        case "category.list.nightlife.leiden":
            return DetailRoute(listID, listID: listID, detailLinkID: "home.exploreList.action.late-transport", detailID: "practicalGuide.transportBasics")

        case "category.section.housing.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.housing.overview.housing-overview", detailID: "guide.article.renting")
        case "category.section.housing.rent":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.housing.rent.rent", detailID: "guide.article.renting")
        case "category.section.housing.buy":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.housing.buy.buy", detailID: "practicalGuide.housingBasics")
        case "category.section.housing.studentHousing":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.housing.studentHousing.student-housing", detailID: "guide.article.renting")
        case "category.section.housing.socialHousing":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.housing.socialHousing.social-housing", detailID: "guide.article.tenant-rights")

        case "category.section.government.municipality":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.municipality.municipality", detailID: "institution.detail.municipality")
        case "category.section.government.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.overview.municipality", detailID: "institution.detail.municipality")
        case "category.section.government.ind":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.ind.ind", detailID: "institution.detail.ind")
        case "category.section.government.digid":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.digid.digid", detailID: "institution.detail.digid")
        case "category.section.government.taxes":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.taxes.taxes", detailID: "institution.detail.taxdienst")
        case "category.section.government.healthcare":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.government.healthcare.healthcare", detailID: "practicalGuide.healthcareBasics")

        case "category.section.transport.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.overview.transport-overview", detailID: "guide.article.ov-chipkaart")
        case "category.section.transport.train":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.train.train", detailID: "guide.article.trains")
        case "category.section.transport.bus":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.bus.bus", detailID: "guide.article.ov-chipkaart")
        case "category.section.transport.metro":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.metro.metro", detailID: "guide.article.ov-chipkaart")
        case "category.section.transport.bike":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.bike.bike", detailID: "guide.article.bicycle")
        case "category.section.transport.parking":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.parking.parking", detailID: "practicalGuide.transportBasics")
        case "category.section.transport.journeyPlanner":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.journeyPlanner.journey-planner", detailID: "practicalGuide.transportBasics")
        case "category.section.transport.ovChipkaart":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.transport.ovChipkaart.ov-chipkaart", detailID: "guide.article.ov-chipkaart")

        case "category.section.education.universities":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.universities.universities", detailID: "institution.detail.duo")
        case "category.section.education.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.overview.universities", detailID: "institution.detail.duo")
        case "category.section.education.duo":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.duo.duo", detailID: "institution.detail.duo")
        case "category.section.education.languageSchools":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.languageSchools.language-schools", detailID: "dutchA1A2.screen")
        case "category.section.education.drivingSchools":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.drivingSchools.driving-schools", detailID: "institution.detail.rdw")
        case "category.section.education.studentFinance":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.education.studentFinance.student-finance", detailID: "institution.detail.duo")

        case "category.section.work.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.work.overview.permits-and-rights", detailID: "guide.article.working-permit")
        case "category.section.work.permits-and-rights":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.work.permits-and-rights.permits-and-rights", detailID: "guide.article.working-permit")
        case "category.section.work.salary-taxes":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.work.salary-taxes.salary-taxes", detailID: "guide.article.salary-taxes")
        case "category.section.work.job-search":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.work.job-search.job-search", detailID: "guide.article.job-search-nl")

        case "category.section.health.overview":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.health.overview.insurance", detailID: "guide.article.insurance")
        case "category.section.health.insurance":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.health.insurance.insurance", detailID: "guide.article.insurance")
        case "category.section.health.huisarts":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.health.huisarts.huisarts", detailID: "guide.article.huisarts")
        case "category.section.health.urgent-care":
            return DetailRoute(listID, listID: listID, detailLinkID: "category.section.detailLink.health.urgent-care.urgent-care", detailID: "guide.article.urgent-care")
        default:
            return nil
        }
    }

    @MainActor
    private func launchHome() -> XCUIApplication {
        launch(arguments: ["-uiTestingStartTab", "home"])
    }

    @MainActor
    private func launchDestination(_ routeID: String) -> XCUIApplication {
        launch(arguments: ["-uiTestingDestination", routeID])
    }

    @MainActor
    private func launch(arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", "en",
            "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ] + arguments
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    private func element(prefix: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
            .firstMatch
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<18 where !element.exists || !element.isHittable {
            app.swipeUp(velocity: .fast)
        }
        for _ in 0..<18 where !element.exists || !element.isHittable {
            app.swipeDown(velocity: .fast)
        }
    }

    @MainActor
    private func navigateBack(in app: XCUIApplication) {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        if back.waitForExistence(timeout: 3), back.isHittable {
            back.tap()
            return
        }

        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.82, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
