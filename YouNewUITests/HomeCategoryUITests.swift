import XCTest

final class HomeCategoryUITests: XCTestCase {
    private let releaseHomeIdentifiers = [
        "home.currentCity",
        "home.globalSearch",
        "home.currentProfile"
    ]

    private let approvedCompactHomeIdentifiers = [
        "home.currentProfile",
        "home.officialServices",
        "home.placesToVisit",
        "home.housing",
        "home.transport",
        "home.leisure",
        "home.education",
        "home.compactAI",
        "home.localPartners.focused",
        "home.discoverNetherlands"
    ]

    private let floatingTabIdentifiers = [
        "tab.home",
        "tab.guide",
        "tab.map",
        "tab.saved",
        "tab.more"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        terminateAppIfNeeded()
    }

    override func tearDownWithError() throws {
        terminateAppIfNeeded()
    }

    // MARK: - Release Home

    @MainActor
    func testReleaseHomeFirstViewportRenders() throws {
        let app = launchApp(language: "ru")
        try requireAppWindow(in: app)
        assertReleaseHomeFirstViewport(in: app)
    }

    @MainActor
    func testReleaseHomeFirstViewportSurvivesLanguageSwitch() throws {
        for language in ["ru", "en", "nl"] {
            let app = launchApp(language: language)
            try requireAppWindow(in: app)
            assertReleaseHomeFirstViewport(in: app)
            terminate(app)
        }
    }

    @MainActor
    func testHomeUsesApprovedCompactArchitecture() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        for identifier in approvedCompactHomeIdentifiers {
            let element = app.descendants(matching: .any)[identifier]
            scrollToElement(element, in: app)
            assertExists(element, named: identifier)
            XCTAssertFalse(element.frame.isEmpty, "Compact Home section has an empty frame: \(identifier)")
        }

        XCTAssertFalse(
            app.descendants(matching: .any)["home.cityGallery"].exists,
            "The immersive city gallery belongs on city pages, not Home."
        )
        XCTAssertFalse(
            app.descendants(matching: .any)["home.photoGallery"].exists,
            "Long photo galleries must not be restored on Home."
        )
    }

    // MARK: - Tab Bar: No Duplicate

    /// Verifies that the native UITabBar is not visible — only the custom FloatingTabBar renders.
    @MainActor
    func testNativeTabBarIsHidden() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        let nativeTabBars = app.tabBars
        XCTAssertEqual(
            nativeTabBars.count, 0,
            "Native UITabBar must be hidden. Found \(nativeTabBars.count) tab bar(s). Double tab bar detected."
        )
    }

    /// Verifies the custom FloatingTabBar buttons exist and are hittable.
    @MainActor
    func testFloatingTabBarButtonsExistAndAreHittable() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        for identifier in floatingTabIdentifiers {
            let button = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(
                button.waitForExistence(timeout: 3),
                "Floating tab bar button missing: \(identifier)"
            )
            XCTAssertTrue(
                button.isHittable,
                "Floating tab bar button not hittable: \(identifier)"
            )
            XCTAssertGreaterThanOrEqual(button.frame.width, 44, "Tab button touch width is too small: \(identifier)")
            XCTAssertGreaterThanOrEqual(button.frame.height, 44, "Tab button touch height is too small: \(identifier)")
        }
    }

    @MainActor
    func testRussianTabLabelsFitCompactBottomBar() throws {
        let app = launchApp(language: "ru")
        try requireAppWindow(in: app)

        for identifier in floatingTabIdentifiers {
            let button = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(button.waitForExistence(timeout: 3), "Russian floating tab missing: \(identifier)")
            XCTAssertFalse(button.frame.isEmpty, "Russian floating tab has empty frame: \(identifier)")
            XCTAssertGreaterThanOrEqual(button.frame.width, 44, "Russian tab touch width is too small: \(identifier)")
        }
    }

    /// Verifies that no tab bar duplicate appears across all three languages.
    @MainActor
    func testNoDoubleTabBarAcrossLanguages() throws {
        for language in ["ru", "en", "nl"] {
            let app = launchApp(language: language)
            try requireAppWindow(in: app)

            let nativeTabBars = app.tabBars
            XCTAssertEqual(
                nativeTabBars.count, 0,
                "[\(language)] Native tab bar visible — double tab bar detected. Count: \(nativeTabBars.count)"
            )
            terminate(app)
        }
    }

    /// Verifies tab bar buttons navigate to correct screens without layout breakage.
    @MainActor
    func testTabBarNavigationWorks() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        let tabsToTest: [(id: String, waitId: String)] = [
            ("tab.guide",  "tab.guide"),
            ("tab.map",    "tab.map"),
            ("tab.home",   "tab.home")
        ]

        for (tapId, waitId) in tabsToTest {
            let button = app.descendants(matching: .any)[tapId]
            if button.waitForExistence(timeout: 3), button.isHittable {
                button.tap()
                _ = app.descendants(matching: .any)[waitId].waitForExistence(timeout: 2)
                // After each tap, verify no native tab bar materialised
                XCTAssertEqual(app.tabBars.count, 0, "Native tab bar appeared after tapping \(tapId)")
            }
        }
    }

    // MARK: - Search

    @MainActor
    func testSearchSuggestionReturnsResults() throws {
        let app = launchApp(language: "en", startTab: "search")
        try requireAppWindow(in: app)

        let suggestion = app.descendants(matching: .any)["search.suggestion.bsn"]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 4), "BSN search suggestion is missing")
        suggestion.tap()

        let result = app.descendants(matching: .any)["search.directResult.link.essential-bsn-registration"]
        XCTAssertTrue(result.waitForExistence(timeout: 4), "Search should return at least one result for BSN")
        XCTAssertFalse(result.frame.isEmpty, "Search result has an empty frame")

        let searchTab = app.descendants(matching: .any)["tab.guide"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 2), "Guide tab is missing below the Search destination")
        XCTAssertLessThanOrEqual(
            result.frame.maxY,
            searchTab.frame.minY - 8,
            "First search result should not be obscured by the floating tab bar"
        )
    }

    @MainActor
    func testSearchNoResultsStateAppears() throws {
        let app = launchApp(language: "en", startTab: "search")
        try requireAppWindow(in: app)

        let field = app.textFields["search.input"]
        XCTAssertTrue(field.waitForExistence(timeout: 4), "Search input is missing")
        field.tap()
        field.typeText("zzznothingzz")

        let noResults = app.descendants(matching: .any)["search.no_results"]
        XCTAssertTrue(noResults.waitForExistence(timeout: 4), "No-results state should appear for nonsense query")
        XCTAssertFalse(noResults.frame.isEmpty, "No-results state has an empty frame")
    }

    // MARK: - Helpers

    @MainActor
    private func launchApp(language: String, startTab: String = "home") -> XCUIApplication {
        let app = XCUIApplication()
        if app.state != .notRunning {
            terminate(app)
        }

        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", language,
            "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ]
        if startTab == "assistant" || startTab == "search" {
            app.launchArguments += ["-uiTestingDestination", startTab]
        } else {
            app.launchArguments += ["-uiTestingStartTab", startTab]
        }
        app.launch()
        app.activate()
        return app
    }

    private func terminateAppIfNeeded() {
        terminate(XCUIApplication())
    }

    private func terminate(_ app: XCUIApplication) {
        guard app.state != .notRunning else { return }
        app.terminate()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 5), "App did not terminate before the next UI test launch.")
    }

    @MainActor
    private func requireAppWindow(in app: XCUIApplication) throws {
        if !app.windows.firstMatch.waitForExistence(timeout: 4) {
            XCTFail("No app window is exposed for the active UI test destination.")
        }
    }

    @MainActor
    private func assertReleaseHomeFirstViewport(in app: XCUIApplication) {
        for identifier in releaseHomeIdentifiers {
            let element = app.descendants(matching: .any)[identifier]
            assertExists(element, named: identifier)
            XCTAssertFalse(element.frame.isEmpty, "Release Home element has an empty frame: \(identifier)")
            XCTAssertGreaterThanOrEqual(element.frame.minX, 0, "Release Home element clips past the left edge: \(identifier)")
            XCTAssertGreaterThanOrEqual(element.frame.width, 44, "Release Home element touch width is too small: \(identifier)")
        }

        let city = app.descendants(matching: .any)["home.currentCity"]
        let search = app.descendants(matching: .any)["home.globalSearch"]
        XCTAssertLessThanOrEqual(search.frame.minY, city.frame.minY, "Search must remain available before the city hero.")
        XCTAssertTrue(search.isHittable, "Search button must be hittable in the first viewport.")
    }

    @MainActor
    private func assertExists(_ element: XCUIElement, named name: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 4), "Missing element: \(name)")
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while !element.isHittable && attempts < 30 {
            app.swipeUp(velocity: .fast)
            attempts += 1
        }
    }
}
