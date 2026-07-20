import XCTest

final class PublishedCitiesRuntimeUITests: XCTestCase {
    private let cities = [
        (name: "Amsterdam", slug: "amsterdam"),
        (name: "Rotterdam", slug: "rotterdam"),
        (name: "Den Haag", slug: "den-haag"),
        (name: "Utrecht", slug: "utrecht"),
        (name: "Eindhoven", slug: "eindhoven")
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPublishedCitiesTraverseHomeSearchAIPlacesMapGuideAndDetail() {
        for city in cities {
            var app = launch(city: city.name, startTab: "home")
            let currentCity = element("home.currentCity", in: app)
            XCTAssertTrue(currentCity.waitForExistence(timeout: 8), "Home missing for \(city.name)")
            let expectedHomeNames = city.slug == "den-haag" ? ["Den Haag", "The Hague"] : [city.name]
            XCTAssertTrue(expectedHomeNames.contains { currentCity.label.localizedCaseInsensitiveContains($0) }, "Home selected the wrong city")
            app.terminate()

            app = launch(city: city.name, destination: "search", searchQuery: city.name)
            let input = element("search.input", in: app)
            XCTAssertTrue(input.waitForExistence(timeout: 8), "Search missing for \(city.name)")
            let searchResult = element("search.directResult.link.city.\(city.slug)", in: app)
            XCTAssertTrue(searchResult.waitForExistence(timeout: 8), "Search did not find canonical \(city.name)")
            searchResult.tap()
            XCTAssertTrue(element("city.detail.\(city.slug)", in: app).waitForExistence(timeout: 8), "Search route did not open \(city.name)")
            let searchBack = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(searchBack.waitForExistence(timeout: 5) && searchBack.isHittable, "Back navigation missing for \(city.name)")
            searchBack.tap()
            XCTAssertTrue(element("search.input", in: app).waitForExistence(timeout: 5), "Back navigation failed for \(city.name)")
            app.terminate()

            app = launch(city: city.name, destination: "assistant")
            let assistantInput = element("assistant.input", in: app)
            XCTAssertTrue(assistantInput.waitForExistence(timeout: 8), "AI missing for \(city.name)")
            assistantInput.tap()
            assistantInput.typeText("Tell me about \(city.name) city")
            element("assistant.send", in: app).tap()
            XCTAssertTrue(element("assistant.response.structured", in: app).waitForExistence(timeout: 15), "AI did not answer for \(city.name)")
            app.terminate()

            app = launch(city: city.name, startTab: "map")
            XCTAssertTrue(element("map.hub", in: app).waitForExistence(timeout: 8), "Places/Map missing for \(city.name)")
            XCTAssertTrue(element("places.premiumNetherlandsMap", in: app).waitForExistence(timeout: 8), "Map dataset missing for \(city.name)")
            XCTAssertTrue(element("map.city.\(city.slug)", in: app).waitForExistence(timeout: 8), "Map city missing for \(city.name)")
            app.terminate()

            app = launch(city: city.name, startTab: "guide")
            XCTAssertTrue(element("screen.guide", in: app).waitForExistence(timeout: 8), "Guide missing for \(city.name)")
            app.terminate()

            app = launch(city: city.name, destination: "city:\(city.slug)")
            XCTAssertTrue(element("city.detail.\(city.slug)", in: app).waitForExistence(timeout: 8), "City detail missing for \(city.name)")
            XCTAssertTrue(element("city.hero.image", in: app).waitForExistence(timeout: 8), "Hero missing for \(city.name)")
            for _ in 0..<8 where !element("city.relatedArticles.dashboard", in: app).exists {
                app.swipeUp()
            }
            XCTAssertTrue(element("city.relatedArticles.dashboard", in: app).exists, "Related entities missing for \(city.name)")
            XCTAssertTrue(app.staticTexts["Official sources"].exists, "Official sources missing for \(city.name)")
            app.terminate()
        }
    }

    @MainActor
    func testPublishedAmsterdamMuseumFlowsFromSearchToGuideAndSaved() {
        let app = launch(city: "Amsterdam", destination: "search", searchQuery: "Rijksmuseum")
        let result = element("search.directResult.link.canonical-museum.rijksmuseum", in: app)
        XCTAssertTrue(result.waitForExistence(timeout: 10), "Published Rijksmuseum record is missing from Search")
        let labelComponents = result.label
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        XCTAssertTrue(
            labelComponents.contains("Rijksmuseum"),
            "Published museum result does not expose the exact title in its combined accessibility label"
        )
        result.tap()

        XCTAssertTrue(
            element("guide.article.museum.rijksmuseum", in: app).waitForExistence(timeout: 8),
            "Published Rijksmuseum record did not open in the existing Guide detail"
        )
        let bookmark = element("saved.toggle.museum.rijksmuseum", in: app)
        XCTAssertTrue(bookmark.waitForExistence(timeout: 5), "Canonical Guide detail has no Saved action")
        bookmark.tap()

        let savedTab = element("tab.saved", in: app)
        XCTAssertTrue(savedTab.waitForExistence(timeout: 5) && savedTab.isHittable)
        savedTab.tap()
        XCTAssertTrue(element("favorites.screen", in: app).waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Rijksmuseum"].waitForExistence(timeout: 8), "Published record did not appear in Saved")
    }

    @MainActor
    private func launch(city: String, startTab: String? = nil, destination: String? = nil, searchQuery: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting", "-resetUITestState", "-launchLanguage", "en",
            "-uiTestingCity", city, "-uiTestingStatus", "tourist"
        ]
        if let destination {
            app.launchArguments += ["-uiTestingDestination", destination]
        } else if let startTab {
            app.launchArguments += ["-uiTestingStartTab", startTab]
        }
        if let searchQuery {
            app.launchArguments += ["-uiTestingSearchQuery", searchQuery]
        }
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 8))
        return app
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
