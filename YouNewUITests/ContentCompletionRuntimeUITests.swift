import XCTest

final class ContentCompletionRuntimeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    @MainActor
    func testPrimaryTabsRenderCompletedSurfacesWithoutPlaceholderCopy() throws {
        let cases: [(tab: String, requiredIdentifiers: [String])] = [
            ("home", ["screen.home", "home.currentCity"]),
            ("guide", ["screen.guide", "guide.lastElement"]),
            ("map", ["map.hub", "places.premiumNetherlandsMap"]),
            ("saved", ["favorites.screen", "saved.hero", "saved.empty.dashboard"]),
            ("more", ["screen.more"])
        ]

        for testCase in cases {
            let app = launchApp(startTab: testCase.tab)
            try requireAppWindow(in: app)
            assertNoNativeTabBar(in: app, context: testCase.tab)
            assertAnyRequiredIdentifierExists(testCase.requiredIdentifiers, in: app, context: testCase.tab)
            assertNoUnfinishedVisibleCopy(in: app, context: testCase.tab)
            app.terminate()
        }
    }

    @MainActor
    func testRequiredContentDestinationsRenderCompletedSurfacesWithoutPlaceholderCopy() throws {
        let destinations: [(route: String, requiredIdentifiers: [String])] = [
            ("search", ["search.input", "search.intro.card"]),
            ("map", ["map.hub", "places.premiumNetherlandsMap"]),
            ("journeyDocuments", ["documents.screen", "documents.empty.dashboard"]),
            ("government", ["government.screen"]),
            ("healthcare", ["practicalGuide.healthcareBasics"]),
            ("housing", ["practicalGuide.housingBasics"]),
            ("transport", ["practicalGuide.transportBasics"]),
            ("education", ["institutions.screen"]),
            ("institutions", ["institutions.screen"]),
            ("businessGrowth", ["business.landing"]),
            ("calendar", ["calendar.screen"]),
            ("settings", ["settings.screen"]),
            ("localPartners", ["localPartners.hero"]),
            ("officialSources", ["officialSources.screen"])
        ]

        for destination in destinations {
            let app = launchApp(destination: destination.route)
            try requireAppWindow(in: app)
            assertAnyRequiredIdentifierExists(destination.requiredIdentifiers, in: app, context: destination.route)
            assertNoUnfinishedVisibleCopy(in: app, context: destination.route)
            app.terminate()
        }
    }

    @MainActor
    func testSearchStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "search", requiredIdentifiers: ["search.input", "search.intro.card"], scrolls: 3)
    }

    @MainActor
    func testMapStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "map", requiredIdentifiers: ["map.hub", "places.premiumNetherlandsMap"], scrolls: 3)
    }

    @MainActor
    func testJourneyDocumentsStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "journeyDocuments", requiredIdentifiers: ["documents.screen", "documents.empty.dashboard"], scrolls: 4)
    }

    @MainActor
    func testGovernmentStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "government", requiredIdentifiers: ["government.screen"], scrolls: 4)
    }

    @MainActor
    func testHealthcareStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "healthcare", requiredIdentifiers: ["practicalGuide.healthcareBasics"], scrolls: 4)
    }

    @MainActor
    func testHousingStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "housing", requiredIdentifiers: ["practicalGuide.housingBasics"], scrolls: 4)
    }

    @MainActor
    func testTransportStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "transport", requiredIdentifiers: ["practicalGuide.transportBasics"], scrolls: 4)
    }

    @MainActor
    func testEducationStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "education", requiredIdentifiers: ["institutions.screen"], scrolls: 4)
    }

    @MainActor
    func testBusinessGrowthStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "businessGrowth", requiredIdentifiers: ["business.landing"], scrolls: 4)
    }

    @MainActor
    func testCalendarStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "calendar", requiredIdentifiers: ["calendar.screen"], scrolls: 3)
    }

    @MainActor
    func testSettingsStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "settings", requiredIdentifiers: ["settings.screen"], scrolls: 4)
    }

    @MainActor
    func testLocalPartnersStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "localPartners", requiredIdentifiers: ["localPartners.hero"], scrolls: 4)
    }

    @MainActor
    func testOfficialSourcesStaysCompletedWhileScrolling() throws {
        try assertCompletedWhileScrolling(route: "officialSources", requiredIdentifiers: ["officialSources.screen"], scrolls: 4)
    }

    @MainActor
    private func assertCompletedWhileScrolling(route: String, requiredIdentifiers: [String], scrolls: Int) throws {
        let app = launchApp(destination: route)
        try requireAppWindow(in: app)
        assertAnyRequiredIdentifierExists(requiredIdentifiers, in: app, context: route)
        assertCompletedVisibleState(in: app, context: "\(route).initial")
        for index in 1...scrolls {
            app.swipeUp()
            assertCompletedVisibleState(in: app, context: "\(route).scroll\(index)")
        }
        app.terminate()
    }

    @MainActor
    private func launchApp(startTab: String) -> XCUIApplication {
        let app = baseApp()
        if startTab == "assistant" || startTab == "search" {
            app.launchArguments += ["-uiTestingDestination", startTab]
        } else {
            app.launchArguments += ["-uiTestingStartTab", startTab]
        }
        app.launch()
        app.activate()
        return app
    }

    @MainActor
    private func launchApp(destination: String) -> XCUIApplication {
        let app = baseApp()
        if destination == "map" {
            app.launchArguments += ["-uiTestingStartTab", "map"]
        } else {
            app.launchArguments += ["-uiTestingDestination", destination]
        }
        app.launch()
        app.activate()
        return app
    }

    private func baseApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", "en",
            "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ]
        return app
    }

    @MainActor
    private func requireAppWindow(in app: XCUIApplication) throws {
        if !app.windows.firstMatch.waitForExistence(timeout: 6) {
            XCTFail("No app window is exposed for the active UI test destination.")
        }
    }

    @MainActor
    private func assertNoNativeTabBar(in app: XCUIApplication, context: String) {
        XCTAssertEqual(app.tabBars.count, 0, "[\(context)] Native tab bar should not duplicate the custom navigation.")
    }

    @MainActor
    private func assertAnyRequiredIdentifierExists(_ identifiers: [String], in app: XCUIApplication, context: String) {
        for identifier in identifiers {
            let element = firstElement(matching: identifier, in: app)
            if element.waitForExistence(timeout: 5), !element.frame.isEmpty {
                XCTAssertGreaterThan(element.frame.width, 1, "[\(context)] \(identifier) width is empty.")
                XCTAssertGreaterThan(element.frame.height, 1, "[\(context)] \(identifier) height is empty.")
                return
            }
        }

        XCTFail("[\(context)] None of the required completed surfaces rendered: \(identifiers.joined(separator: ", "))")
    }

    @MainActor
    private func firstElement(matching identifier: String, in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.otherElements[identifier],
            app.scrollViews[identifier],
            app.collectionViews[identifier],
            app.staticTexts[identifier],
            app.buttons[identifier],
            app.textFields[identifier],
            app.searchFields[identifier],
            app.images[identifier]
        ]

        return candidates.first(where: { $0.exists }) ?? app.otherElements[identifier]
    }

    @MainActor
    private func assertNoUnfinishedVisibleCopy(in app: XCUIApplication, context: String) {
        assertNoUnfinishedVisibleCopy(visibleLabels(in: app), context: context)
    }

    private func assertNoUnfinishedVisibleCopy(_ labels: [String], context: String) {
        let text = labels.joined(separator: "\n")
        XCTAssertFalse(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "[\(context)] Visible content is empty.")
        assertNoRawLocalizationKeys(in: text, context: context)

        let forbidden = [
            "coming soon",
            "will appear here",
            "resources will appear here",
            "content not found",
            "image unavailable",
            "no image available",
            "official symbol unavailable",
            "verified image unavailable",
            "no results found",
            "nothing saved yet",
            "no saved items yet",
            "no upcoming reminders yet",
            "no saved letter summaries yet",
            "opening hours unavailable",
            "future update",
            "todo",
            "fixme",
            "lorem"
        ]

        let lowercased = text.lowercased()
        for phrase in forbidden {
            XCTAssertFalse(lowercased.contains(phrase), "[\(context)] Visible unfinished copy '\(phrase)' found:\n\(text)")
        }
    }

    @MainActor
    private func assertCompletedVisibleState(in app: XCUIApplication, context: String) {
        // Each full accessibility-tree snapshot is expensive on dense surfaces.
        // Reuse one snapshot for both independent assertions so this test does not
        // create duplicate global queries after every scroll.
        let labels = visibleLabels(in: app)
        assertNoUnfinishedVisibleCopy(labels, context: context)

        let meaningfulLabels = labels
            .filter { label in
                let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.count >= 2 else { return false }
                return !["home", "places", "ai assistant", "saved", "more"].contains(trimmed.lowercased())
            }

        XCTAssertGreaterThanOrEqual(
            Set(meaningfulLabels).count,
            3,
            "[\(context)] Too little meaningful visible content after scrolling: \(meaningfulLabels.joined(separator: " | "))"
        )
    }

    @MainActor
    private func visibleLabels(in app: XCUIApplication) -> [String] {
        // Read one consistent tree per state instead of issuing three remote
        // accessibility queries for every element. Keep the same element types,
        // per-type limit, frame filter and label assertions.
        do {
            let snapshot = try app.snapshot()
            var descendants: [XCUIElementSnapshot] = []
            func collect(_ node: XCUIElementSnapshot) {
                for child in node.children {
                    descendants.append(child)
                    collect(child)
                }
            }
            collect(snapshot)
            let types: [XCUIElement.ElementType] = [.staticText, .button, .textField, .searchField]
            return types.flatMap { type in
                descendants.filter { $0.elementType == type }.prefix(120).compactMap { element in
                    let frame = element.frame
                    guard !frame.isEmpty, frame.maxX > 0, frame.maxY > 0 else { return nil }
                    let label = element.label.trimmingCharacters(in: .whitespacesAndNewlines)
                    return label.isEmpty ? nil : label
                }
            }
        } catch {
            XCTFail("Unable to capture visible content: \(error)")
            return []
        }
    }

    private func assertNoRawLocalizationKeys(in text: String, context: String) {
        let forbiddenPrefixes = [
            "home.",
            "search.",
            "places.",
            "map.",
            "assistant.",
            "saved.",
            "documents.",
            "settings.",
            "more.",
            "common.",
            "l10n."
        ]

        for line in text.components(separatedBy: .newlines) {
            let normalized = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            for prefix in forbiddenPrefixes {
                XCTAssertFalse(normalized.hasPrefix(prefix), "[\(context)] Raw localization key visible: \(line)")
            }
        }
    }
}
