import XCTest

final class LocalizationRegressionUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    // MARK: - Release UX Regression

    @MainActor
    func testHomeScreenStartsWithHeroStatusAndProfileChange() throws {
        for language in ["en", "nl", "ru"] {
            let app = launchApp(language: language)
            try requireAppWindow(in: app)

            let hero = app.descendants(matching: .any)["home.product.hero"]
            let statusCard = app.descendants(matching: .any)["home.statusCard"]
            let changeButton = app.descendants(matching: .any)["home.status.change"]

            XCTAssertTrue(hero.waitForExistence(timeout: 4), "[\(language)] hero missing")
            XCTAssertTrue(statusCard.waitForExistence(timeout: 4), "[\(language)] status card missing")
            XCTAssertTrue(changeButton.waitForExistence(timeout: 2), "[\(language)] Change button missing")
            XCTAssertLessThan(hero.frame.minY, statusCard.frame.minY, "[\(language)] hero must appear before status")
            XCTAssertLessThan(statusCard.frame.minY, changeButton.frame.minY, "[\(language)] status must precede profile change")
            XCTAssertTrue(changeButton.isHittable, "[\(language)] Change button must be hittable")

            app.terminate()
        }
    }

    @MainActor
    func testFloatingNavigationOpensPrimaryPublicAreas() throws {
        let routes: [(startTab: String, screen: String)] = [
            ("search", "search.input"),
            ("map", "map.hub"),
            ("assistant", "assistant.input"),
            ("more", "rightMenu.panel"),
            ("home", "home.statusCard")
        ]

        for route in routes {
            let app = launchApp(language: "en", startTab: route.startTab)
            try requireAppWindow(in: app)
            let screen = app.descendants(matching: .any).matching(identifier: route.screen).firstMatch
            XCTAssertTrue(screen.waitForExistence(timeout: 4), "Start tab \(route.startTab) did not open \(route.screen)")
            XCTAssertFalse(screen.frame.isEmpty, "Screen \(route.screen) has an empty frame")
            app.terminate()
        }
    }

    @MainActor
    func testMapFlowShowsUsableNearbyScreen() throws {
        let app = launchApp(language: "en", startTab: "map")
        try requireAppWindow(in: app)

        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "map.hub").firstMatch.waitForExistence(timeout: 4), "Map hub missing")
        XCTAssertFalse(
            app.descendants(matching: .any).matching(identifier: "map.hub").firstMatch.frame.isEmpty,
            "Map hub has an empty frame"
        )
    }

    @MainActor
    func testSearchUsesCurrentLocalizedResultContract() throws {
        let app = launchApp(language: "en", startTab: "search")
        try requireAppWindow(in: app)

        let suggestion = app.descendants(matching: .any)["search.suggestion.bsn"]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 4), "BSN suggestion missing")
        suggestion.tap()

        let result = app.descendants(matching: .any).matching(identifier: "search.result.card").firstMatch
        XCTAssertTrue(result.waitForExistence(timeout: 4), "Search result card missing")
        XCTAssertFalse(result.frame.isEmpty, "Search result card has empty frame")
    }

    @MainActor
    func testAIAssistantIsUsableAndDoesNotPresentAsLegalAuthority() throws {
        let app = launchApp(language: "en", startTab: "assistant")
        try requireAppWindow(in: app)

        let input = app.descendants(matching: .any)["assistant.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 4), "Assistant input missing")
        let send = app.descendants(matching: .any)["assistant.send"]
        XCTAssertTrue(send.waitForExistence(timeout: 4), "Assistant send control missing")
        XCTAssertFalse(app.staticTexts["assistant.disclaimer.legalAdvice"].exists, "Assistant should not present as legal authority")
    }

    @MainActor
    func testMoreHubOpensAsSimpleOverflowSurface() throws {
        let app = launchApp(language: "en")
        try requireAppWindow(in: app)

        let moreTab = app.descendants(matching: .any)["tab.more"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 4), "More tab missing")
        XCTAssertTrue(moreTab.isHittable, "More tab is not hittable")
        moreTab.tap()

        let moreScreen = app.descendants(matching: .any).matching(identifier: "more.screen").firstMatch
        XCTAssertTrue(moreScreen.waitForExistence(timeout: 4), "More screen missing")
        XCTAssertFalse(moreScreen.frame.isEmpty, "More screen has empty frame")
    }

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
