import XCTest

final class MapChipUITests: XCTestCase {
    private let chipIdentifiers = [
        "map.chip.all",
        "map.chip.emergency",
        "map.chip.municipality",
        "map.chip.legal_help",
        "map.chip.healthcare",
        "map.chip.transport"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMapChipsRender() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)
        let chipRow = revealChipRow(in: app)
        XCTAssertTrue(waitForNonEmptyFrame(chipRow), "Map chip row has an empty or offscreen frame.")

        for identifier in chipIdentifiers {
            let chip = app.buttons[identifier]
            scrollToElement(chip, in: app, chipRow: chipRow)
            assertExists(chip, named: identifier)
            XCTAssertFalse(chip.frame.isEmpty, "Map chip has an empty frame: \(identifier)")
        }
    }

    @MainActor
    private func launchApp(language: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetUITestState", "-launchLanguage", language, "-uiTestingStartTab", "map", "-uiTestingCity", "Amsterdam"]
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
    private func openMap(in app: XCUIApplication) {
        if app.buttons["map.chip.all"].waitForExistence(timeout: 1) {
            return
        }

        tapIfPresent(firstExistingElement(
            [
                app.buttons["tab.map"],
                app.descendants(matching: .any)["tab.map"],
                app.buttons["Map"],
                app.descendants(matching: .any)["Map"]
            ],
            timeout: 4
        ))
    }

    @MainActor
    private func revealChipRow(in app: XCUIApplication) -> XCUIElement {
        let chipRow = app.scrollViews["map.chip.row"]
        for _ in 0..<5 {
            if waitForNonEmptyFrame(chipRow, timeout: 0.5) || app.buttons["map.chip.all"].isHittable {
                return chipRow
            }
            app.swipeUp()
        }
        return chipRow
    }

    @MainActor
    private func tapIfPresent(_ element: XCUIElement) {
        if element.exists {
            element.tap()
        }
    }

    @MainActor
    private func firstExistingElement(_ elements: [XCUIElement], timeout: TimeInterval) -> XCUIElement {
        for element in elements where element.waitForExistence(timeout: timeout) {
            return element
        }

        return elements[0]
    }

    @MainActor
    private func assertExists(_ element: XCUIElement, named name: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 4), "Missing element: \(name)")
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, chipRow: XCUIElement) {
        if element.exists { return }

        var horizontalAttempts = 0
        while !element.exists && waitForNonEmptyFrame(chipRow, timeout: 0.5) && horizontalAttempts < 5 {
            chipRow.swipeLeft()
            horizontalAttempts += 1
        }

        var verticalAttempts = 0
        while !element.exists && verticalAttempts < 3 {
            app.swipeUp()
            verticalAttempts += 1
        }
    }

    @MainActor
    private func waitForNonEmptyFrame(_ element: XCUIElement, timeout: TimeInterval = 3) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && element.isHittable && !element.frame.isEmpty && element.frame.width > 1 && element.frame.height > 1 {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return false
    }
}
