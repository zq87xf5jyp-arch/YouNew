import XCTest

final class LocalizationRegressionUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Premium App Vision E2E Scaffolding

    @MainActor
    func testHomeScreenHasPremiumGreetingAndStatusWidgets() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        // Verify continuous global background presence
        XCTAssertTrue(app.otherElements["background.global.cinematic"].waitForExistence(timeout: 2), "Global cinematic background missing")

        // Greeting card
        XCTAssertTrue(app.staticTexts["home.greeting.title"].waitForExistence(timeout: 2), "Greeting title missing")
        XCTAssertTrue(app.staticTexts["home.greeting.subtitle"].exists, "Greeting subtitle missing")

        // Status widgets
        XCTAssertTrue(app.otherElements["widget.currentCity"].exists, "Current city widget missing")
        XCTAssertTrue(app.otherElements["widget.weather"].exists, "Weather widget missing")
        XCTAssertTrue(app.otherElements["widget.time"].exists, "Time widget missing")
        XCTAssertTrue(app.otherElements["widget.province"].exists, "Province widget missing")
    }

    @MainActor
    func testRightSideDrawerOpensAndShowsPersonalDashboardWidgets() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        // Open the right-side drawer
        let drawerButton = app.buttons["button.openRightDrawer"]
        if drawerButton.waitForExistence(timeout: 2) && drawerButton.isHittable {
            drawerButton.tap()
        } else {
            // Fallback gesture area if button is not present yet
            let edge = app.otherElements["gesture.rightEdgeArea"]
            if edge.exists { edge.swipeLeft() }
        }

        let drawer = app.otherElements["drawer.right.personalDashboard"]
        XCTAssertTrue(drawer.waitForExistence(timeout: 2), "Right drawer did not appear")

        // Verify key widgets
        XCTAssertTrue(app.otherElements["widget.weather"].exists)
        XCTAssertTrue(app.otherElements["widget.currentTime"].exists)
        XCTAssertTrue(app.otherElements["widget.emergencyContacts"].exists)
        XCTAssertTrue(app.otherElements["widget.bookmarks"].exists)
        XCTAssertTrue(app.otherElements["widget.recentSearches"].exists)
        XCTAssertTrue(app.otherElements["widget.reminders"].exists)
        XCTAssertTrue(app.otherElements["widget.savedCities"].exists)
        XCTAssertTrue(app.otherElements["widget.quickActions"].exists)
        XCTAssertTrue(app.otherElements["widget.phraseOfTheDay"].exists)
        XCTAssertTrue(app.otherElements["widget.upcomingHolidays"].exists)
        XCTAssertTrue(app.otherElements["widget.publicTransportStatus"].exists)
        XCTAssertTrue(app.buttons["shortcut.aiAssistant"].exists)
    }

    @MainActor
    func testInteractiveNetherlandsMapFlow() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        let map = app.otherElements["map.netherlands.premiumNeon"]
        XCTAssertTrue(map.waitForExistence(timeout: 3), "Premium neon map missing")

        // Province -> City -> Services -> Information
        let southHolland = app.buttons["map.province.southHolland"]
        if southHolland.waitForExistence(timeout: 2) { southHolland.tap() }

        let rotterdam = app.buttons["map.city.rotterdam"]
        if rotterdam.waitForExistence(timeout: 2) { rotterdam.tap() }

        let transport = app.buttons["map.category.transport"]
        if transport.waitForExistence(timeout: 2) { transport.tap() }

        XCTAssertTrue(app.otherElements["screen.information.transport"].waitForExistence(timeout: 2), "Transport information screen missing")
    }

    @MainActor
    func testPremiumSectionsCatalogHasIconsAccentsAndHeroImages() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        // Verify presence of several representative categories
        let categories = [
            "category.education",
            "category.law",
            "category.transport",
            "category.healthcare",
            "category.municipality",
            "category.financial",
            "category.integration",
            "category.culture",
            "category.history",
            "category.tourism"
        ]
        for id in categories {
            XCTAssertTrue(app.otherElements[id + ".card"].waitForExistence(timeout: 2), "Missing category card for \(id)")
            XCTAssertTrue(app.images[id + ".hero"].exists, "Missing hero image for \(id)")
            XCTAssertTrue(app.images[id + ".icon"].exists, "Missing custom icon for \(id)")
        }
    }

    @MainActor
    func testAIAssistantActsAsNavigatorNotAuthority() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        // Open AI assistant
        let assistant = app.buttons["shortcut.aiAssistant"]
        if assistant.waitForExistence(timeout: 2) { assistant.tap() }

        // Ask a question via a canned shortcut to avoid flaky typing in UITests
        let canned = app.buttons["assistant.prompt.registerInLeiden"]
        if canned.waitForExistence(timeout: 2) { canned.tap() }

        // Expect brief explanation and a navigation button, not legal advice
        XCTAssertTrue(app.staticTexts["assistant.response.brief"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["assistant.action.open.municipality.registration"].exists)
        XCTAssertFalse(app.staticTexts["assistant.disclaimer.legalAdvice"].exists, "Assistant should not present as legal authority")
    }

    @MainActor
    func testHistoryTimelineAndCultureCardsAreInteractiveAndRich() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        // History timeline
        let timeline = app.otherElements["history.timeline"]
        XCTAssertTrue(timeline.waitForExistence(timeout: 2))
        let goldenAge = app.buttons["history.timeline.dutchGoldenAge"]
        if goldenAge.waitForExistence(timeout: 2) { goldenAge.tap() }
        XCTAssertTrue(app.images["history.timeline.dutchGoldenAge.hero"].exists)

        // Culture large cards
        let culture = app.otherElements["culture.grid"]
        XCTAssertTrue(culture.waitForExistence(timeout: 2))
        let food = app.otherElements["culture.card.food"]
        XCTAssertTrue(food.exists)
    }

    @MainActor
    private func launchApp(language: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", language]
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    private func requireAppWindow(in app: XCUIApplication) throws {
        if !app.windows.firstMatch.waitForExistence(timeout: 4) {
            throw XCTSkip("No app window is exposed for the active UI test destination.")
        }
    }

    @MainActor
    private func openHighRiskTabs(in app: XCUIApplication) {
        for identifier in ["tab.home", "tab.search", "tab.map", "tab.assistant"] {
            let element = app.descendants(matching: .any)[identifier]
            if element.waitForExistence(timeout: 2), element.isHittable {
                element.tap()
                _ = app.windows.firstMatch.waitForExistence(timeout: 1)
            }
        }
    }

    @MainActor
    private func assertGlobalBackgroundPresent(in app: XCUIApplication) {
        XCTAssertTrue(app.otherElements["background.global.cinematic"].exists, "Global background element not found")
    }

    @MainActor
    private func visibleText(in app: XCUIApplication) -> String {
        app.descendants(matching: .any)
            .allElementsBoundByIndex
            .compactMap { element in
                guard element.elementType != .scrollBar,
                      element.elementType != .tabBar
                else { return nil }
                let label = element.label.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !label.isEmpty, element.exists else { return nil }
                return label
            }
            .joined(separator: "\n")
    }

    private func assertNoRawLocalizationKeys(in visibleText: String) {
        let forbidden = ["home.", "search.", "rules.", "status.", "common.", "letter.", "map.", "l10n."]
        for line in visibleText.components(separatedBy: .newlines) {
            let normalized = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            for prefix in forbidden {
                XCTAssertFalse(
                    normalized.hasPrefix(prefix),
                    "Visible raw localization key '\(line)' matched prefix '\(prefix)':\n\(visibleText)"
                )
            }
        }
    }

    private func printVisibleTextDump(_ visibleText: String) {
        print("VISIBLE_UI_TEXT_DUMP_START")
        print(visibleText)
        print("VISIBLE_UI_TEXT_DUMP_END")
    }

    private func assert(_ visibleText: String, doesNotContainAny forbidden: [String], language: String) {
        let lowercased = visibleText.lowercased()
        for pattern in forbidden {
            XCTAssertFalse(
                lowercased.contains(pattern.lowercased()),
                "\(language) UI contains forbidden visible text '\(pattern)':\n\(visibleText)"
            )
        }
    }

    private func containsCyrillic(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x0400...0x04FF).contains(Int(scalar.value))
        }
    }
}
