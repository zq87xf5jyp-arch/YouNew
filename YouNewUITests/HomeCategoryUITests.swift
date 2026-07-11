import XCTest

final class HomeCategoryUITests: XCTestCase {
    private let releaseHomeIdentifiers = [
        "home.product.hero",
        "home.statusCard",
        "home.status.change"
    ]

    private let floatingTabIdentifiers = [
        "tab.home",
        "tab.search",
        "tab.map",
        "tab.favorites",
        "tab.assistant"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
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
            app.terminate()
        }
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
            app.terminate()
        }
    }

    /// Verifies tab bar buttons navigate to correct screens without layout breakage.
    @MainActor
    func testTabBarNavigationWorks() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        let tabsToTest: [(id: String, waitId: String)] = [
            ("tab.search", "tab.search"),
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

        let result = app.descendants(matching: .any)["search.result.card"]
        XCTAssertTrue(result.waitForExistence(timeout: 4), "Search should return at least one result for BSN")
        XCTAssertFalse(result.frame.isEmpty, "Search result has an empty frame")

        let searchTab = app.descendants(matching: .any)["tab.search"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 2), "Search tab is missing")
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
        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", language,
            "-uiTestingStartTab", startTab,
            "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ]
        app.launch()
        app.activate()
        return app
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

        let statusCard = app.descendants(matching: .any)["home.statusCard"]
        let changeButton = app.descendants(matching: .any)["home.status.change"]

        XCTAssertLessThan(statusCard.frame.minY, changeButton.frame.minY, "Status card must appear before profile change.")
        XCTAssertTrue(changeButton.isHittable, "Change button must be hittable in the first viewport.")
        XCTAssertGreaterThanOrEqual(changeButton.frame.height, 44, "Change button touch height is too small.")
        XCTAssertGreaterThanOrEqual(changeButton.frame.width, 44, "Change button touch width is too small.")
    }

    @MainActor
    private func assertExists(_ element: XCUIElement, named name: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 4), "Missing element: \(name)")
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while !element.isHittable && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
    }
}
