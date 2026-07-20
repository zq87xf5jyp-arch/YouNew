import XCTest

final class RootNavigationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFiveTabsHaveStableOrderAndNoSearchOrAssistantTab() {
        let app = launch(startTab: "home")
        let expected = ["tab.home", "tab.guide", "tab.map", "tab.saved", "tab.more"]

        for identifier in expected {
            XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: 6), "Missing root tab \(identifier)")
        }
        XCTAssertFalse(element("tab.search", in: app).exists)
        XCTAssertFalse(element("tab.assistant", in: app).exists)

        let frames = expected.map { element($0, in: app).frame }
        XCTAssertEqual(frames.map(\.minX), frames.map(\.minX).sorted())
        XCTAssertTrue(frames.allSatisfy { $0.width >= 44 && $0.height >= 44 })
        attachScreenshot(app, name: "root-navigation-home")
    }

    @MainActor
    func testRootScreensRenderAbovePersistentTabBar() {
        let cases: [(start: String, tab: String, screen: String)] = [
            ("home", "tab.home", "screen.home"),
            ("guide", "tab.guide", "screen.guide"),
            ("map", "tab.map", "map.hub"),
            ("saved", "tab.saved", "favorites.screen"),
            ("more", "tab.more", "screen.more")
        ]

        for item in cases {
            let app = launch(startTab: item.start)
            let tab = element(item.tab, in: app)
            let screen = element(item.screen, in: app)
            XCTAssertTrue(screen.waitForExistence(timeout: 7), "Missing screen \(item.screen)")
            XCTAssertLessThanOrEqual(screen.frame.minY, tab.frame.minY)
            attachScreenshot(app, name: item.tab.replacingOccurrences(of: ".", with: "-"))
            app.terminate()
        }
    }

    @MainActor
    func testAccessibilitySizeKeepsPrimaryHomeActionsReachable() {
        for identifier in ["home.discoveryMenu", "home.globalSearch", "home.currentCity", "home.currentProfile"] {
            let app = launch(startTab: "home", accessibilitySize: true)
            let target = element(identifier, in: app)
            for _ in 0..<14 where !target.exists || !target.isHittable {
                app.swipeUp(velocity: .fast)
            }
            XCTAssertTrue(target.waitForExistence(timeout: 7), "Missing \(identifier)")
            XCTAssertTrue(target.isHittable, "Primary Home action is not reachable: \(identifier)")
            XCTAssertGreaterThanOrEqual(target.frame.width, 44)
            XCTAssertGreaterThanOrEqual(target.frame.height, 44)
            XCTAssertFalse(target.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            app.terminate()
        }
    }

    @MainActor
    func testAllRootScreensScrollToVisibleLastElementAboveTabBar() {
        assertScrollMatrix(accessibilitySize: false)
    }

    @MainActor
    func testAllRootScreensScrollAtAccessibilityXXXL() {
        assertScrollMatrix(accessibilitySize: true)
    }

    @MainActor
    private func assertScrollMatrix(accessibilitySize: Bool) {
        let cases: [(tab: String, first: String, last: String, ai: String?)] = [
            ("saved", "saved.search", "saved.lastElement", nil),
            ("more", "screen.more", "more.lastElement", nil),
            ("home", "home.currentCity", "home.lastElement", "home.aiButton"),
            ("guide", "screen.guide", "guide.lastElement", "guide.aiButton")
        ]

        for item in cases {
            let app = launch(startTab: item.tab, accessibilitySize: accessibilitySize)
            let first = element(item.first, in: app)
            XCTAssertTrue(first.waitForExistence(timeout: 10), "[\(item.tab)] first element missing")
            let tabBar = element("root.tabBar", in: app)
            XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "[\(item.tab)] root tab bar missing")

            let last = element(item.last, in: app)
            for _ in 0..<14
            where !last.exists || !last.isHittable || last.frame.maxY + 8 > tabBar.frame.minY {
                app.swipeUp(velocity: .fast)
            }
            XCTAssertTrue(last.exists, "[\(item.tab)] last element does not exist")
            XCTAssertTrue(last.isHittable, "[\(item.tab)] last element is outside the visible/hittable area")
            XCTAssertLessThanOrEqual(last.frame.maxY + 8, tabBar.frame.minY, "[\(item.tab)] last element intersects the tab bar or has no visual gap")

            if let aiIdentifier = item.ai {
                let ai = element(aiIdentifier, in: app)
                if ai.exists {
                    XCTAssertFalse(ai.frame.intersects(last.frame), "[\(item.tab)] AI intersects the last element")
                    XCTAssertFalse(ai.frame.intersects(tabBar.frame), "[\(item.tab)] AI intersects the tab bar")
                }
            }

            attachScreenshot(app, name: "scroll-\(item.tab)-\(accessibilitySize ? "axxxl" : "default")")
            for _ in 0..<14 where !first.isHittable {
                app.swipeDown(velocity: .fast)
            }
            XCTAssertTrue(first.isHittable, "[\(item.tab)] could not return to the first element")
            app.terminate()
        }
    }

    @MainActor
    private func launch(startTab: String, accessibilitySize: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting", "-resetUITestState", "-launchLanguage", "en",
            "-uiTestingStartTab", startTab, "-uiTestingCity", "Leiden",
            "-uiTestingStatus", "worker"
        ]
        if accessibilitySize {
            app.launchEnvironment["UIPreferredContentSizeCategoryName"] = "UICTContentSizeCategoryAccessibilityXXXL"
        }
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 7))
        return app
    }

    @MainActor
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
