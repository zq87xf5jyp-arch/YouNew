import XCTest

final class AccessibilityRuntimeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    @MainActor
    func testAccessibilityTextSizeKeepsHomeControlsReachable() throws {
        let app = launchApp(startTab: "home")
        try requireAppWindow(in: app)

        let requiredIdentifiers = [
            "home.discoveryMenu",
            "home.currentCity",
            "home.globalSearch",
            "home.currentProfile",
            "tab.home",
            "tab.guide",
            "tab.map",
            "tab.saved",
            "tab.more"
        ]

        for identifier in requiredIdentifiers {
            let element = app.descendants(matching: .any)[identifier]
            assertAccessibleElement(element, identifier: identifier)
        }

        let changeButton = app.descendants(matching: .any)["home.currentCity"]
        scrollToElement(changeButton, in: app)
        assertAboveFloatingTab(changeButton, in: app, identifier: "home.currentCity")
    }

    @MainActor
    func testAccessibilityTextSizeKeepsSearchUsable() throws {
        let app = launchApp(startTab: "search")
        try requireAppWindow(in: app)

        let input = app.textFields["search.input"]
        assertAccessibleElement(input, identifier: "search.input")

        let submit = app.descendants(matching: .any)["search.submit"]
        assertAccessibleElement(submit, identifier: "search.submit")

        input.tap()
        input.typeText("BS")
        input.typeText("N")
        let completeQuery = NSPredicate(format: "value == %@", "BSN")
        expectation(for: completeQuery, evaluatedWith: input)
        waitForExpectations(timeout: 3)
        submit.tap()

        let result = app.descendants(matching: .any)["search.directResult.link.essential-bsn-registration"]
        XCTAssertTrue(result.waitForExistence(timeout: 5), "Search result card should appear at accessibility text size.")
        XCTAssertFalse(result.frame.isEmpty, "Search result card has an empty frame at accessibility text size.")
        scrollToElement(result, in: app)
        assertAboveFloatingTab(result, in: app, identifier: "search.directResult.link.essential-bsn-registration")
    }

    @MainActor
    func testAccessibilityTextSizeKeepsAssistantAndMapEntryPointsUsable() throws {
        let assistantApp = launchApp(startTab: "assistant")
        try requireAppWindow(in: assistantApp)

        assertAccessibleElement(
            assistantApp.descendants(matching: .any)["assistant.input"],
            identifier: "assistant.input",
            requiresMinimumTouchTarget: false
        )
        assertAccessibleElement(
            assistantApp.descendants(matching: .any)["assistant.send"],
            identifier: "assistant.send"
        )
        assistantApp.terminate()

        let mapApp = launchApp(startTab: "map")
        try requireAppWindow(in: mapApp)

        let mapHub = mapApp.descendants(matching: .any)["map.hub"]
        XCTAssertTrue(mapHub.waitForExistence(timeout: 8), "Map hub should render at accessibility text size.")
        XCTAssertFalse(mapHub.frame.isEmpty, "Map hub has an empty frame at accessibility text size.")

        let chipRow = revealCityFilter(in: mapApp)
        XCTAssertTrue(chipRow.waitForExistence(timeout: 6), "Map chip row should render at accessibility text size.")
        XCTAssertFalse(chipRow.frame.isEmpty, "Map chip row has an empty frame at accessibility text size.")
    }

    @MainActor
    private func launchApp(startTab: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", "en",
            "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ]
        if startTab == "assistant" || startTab == "search" {
            app.launchArguments += ["-uiTestingDestination", startTab]
        } else {
            app.launchArguments += ["-uiTestingStartTab", startTab]
        }
        app.launchEnvironment["UIPreferredContentSizeCategoryName"] = "UICTContentSizeCategoryAccessibilityXXXL"
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    private func requireAppWindow(in app: XCUIApplication) throws {
        if !app.windows.firstMatch.waitForExistence(timeout: 5) {
            XCTFail("No app window is exposed for the active UI test destination.")
        }
    }

    @MainActor
    private func assertAccessibleElement(
        _ element: XCUIElement,
        identifier: String,
        requiresMinimumTouchTarget: Bool = true
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: 6), "Missing element at accessibility text size: \(identifier)")
        XCTAssertFalse(element.frame.isEmpty, "Element has an empty frame at accessibility text size: \(identifier)")
        if requiresMinimumTouchTarget {
            XCTAssertGreaterThanOrEqual(element.frame.width, 44, "Touch width is too small at accessibility text size: \(identifier)")
            XCTAssertGreaterThanOrEqual(element.frame.height, 44, "Touch height is too small at accessibility text size: \(identifier)")
        } else {
            XCTAssertTrue(element.isHittable, "Text input should remain hittable at accessibility text size: \(identifier)")
        }
        XCTAssertFalse(element.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Element has no accessibility label: \(identifier)")
    }

    @MainActor
    private func assertAboveFloatingTab(_ element: XCUIElement, in app: XCUIApplication, identifier: String) {
        let tab = app.descendants(matching: .any)["tab.guide"]
        XCTAssertTrue(tab.waitForExistence(timeout: 4), "Floating tab bar is missing while checking \(identifier).")
        XCTAssertLessThanOrEqual(
            element.frame.maxY,
            tab.frame.minY - 4,
            "\(identifier) should not be obscured by the floating tab bar at accessibility text size."
        )
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        let tab = app.descendants(matching: .any)["tab.guide"]
        var attempts = 0
        while element.exists, tab.exists, element.frame.maxY > tab.frame.minY - 4, attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
    }

    @MainActor
    private func revealCityFilter(in app: XCUIApplication) -> XCUIElement {
        let chipRow = app.descendants(matching: .any)["map.city.leiden"]
        for _ in 0..<5 {
            if chipRow.exists && !chipRow.frame.isEmpty {
                return chipRow
            }
            app.swipeUp()
        }
        return chipRow
    }
}
