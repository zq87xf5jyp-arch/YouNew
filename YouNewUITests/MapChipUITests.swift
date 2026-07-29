import XCTest

final class MapChipUITests: XCTestCase {
    private let chipIdentifiers = ["map.city.leiden"]

    private struct ProvinceTapSample {
        let provinceID: String
        let mapNormalizedPoint: CGPoint
    }

    private struct ProvinceTapOutcome {
        let matched: Bool
        let value: String
        let elapsed: TimeInterval
        let touchSequence: Int?
        let resolvedProvinceID: String?
        let hitPoint: String?
        let appHandlingMilliseconds: Double?
    }

    private struct ProvinceSurfaceSnapshot {
        let provinceID: String
        let touchSequence: Int?
        let resolvedProvinceID: String?
        let hitPoint: String?
        let appHandlingMilliseconds: Double?
    }

    private struct RootTabNavigationMetric {
        let sequence: Int
        let tab: String
        let delayMilliseconds: Double
    }

    private struct SeededCalibrationGenerator {
        private var state: UInt64 = 0x59A3_1D7C_2E41_B605

        mutating func signedUnitValue() -> CGFloat {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let normalized = Double(state >> 11) / 9_007_199_254_740_992.0
            return CGFloat(normalized * 2 - 1)
        }
    }

    private var calibrationPlatformLabel: String {
#if targetEnvironment(simulator)
        "SIMULATOR"
#else
        "PHYSICAL_DEVICE"
#endif
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    @MainActor
    func testMapChipsRender() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)
        let chipRow = revealChipRow(in: app)
        XCTAssertTrue(waitForNonEmptyFrame(chipRow) || app.buttons["map.city.leiden"].isHittable,
                      "Map city controls are not visible or hittable.")

        for identifier in chipIdentifiers {
            let chip = app.buttons[identifier]
            scrollToElement(chip, in: app, chipRow: chipRow)
            assertExists(chip, named: identifier)
            XCTAssertFalse(chip.frame.isEmpty, "Map chip has an empty frame: \(identifier)")
        }
    }

    @MainActor
    func testMapCityMarkersOpenCityRoutes() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)

        let leiden = revealCityMarker(identifier: "map.city.leiden", in: app)
        assertExists(leiden, named: "map.city.leiden")
        XCTAssertFalse(leiden.frame.isEmpty, "Leiden city tap target has an empty frame.")
        XCTAssertTrue(leiden.isHittable, "Leiden city tap target must be immediately hittable.")
        leiden.tap()
        XCTAssertTrue(app.descendants(matching: .any)["places.mapMode"].waitForExistence(timeout: 5),
                      "Tapping the Leiden city target must open the working city map.")
    }

    @MainActor
    func testProvincePickerExposesAllProvincesAndTheirCities() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)

        let provincePicker = app.descendants(matching: .any)["places.provincePicker"]
        assertExists(provincePicker, named: "places.provincePicker")

        let zeeland = app.buttons["places.provincePicker.zeeland"]
        for _ in 0..<12 where !zeeland.isHittable {
            provincePicker.swipeLeft()
        }
        XCTAssertTrue(zeeland.isHittable, "Zeeland must be reachable in the 12-province picker.")
        zeeland.tap()

        let middelburg = app.buttons["map.city.middelburg"]
        XCTAssertTrue(middelburg.waitForExistence(timeout: 3), "Selecting Zeeland must expose Middelburg.")
        XCTAssertTrue(middelburg.isHittable, "Middelburg must have a tappable 44-point city control.")
        middelburg.tap()

        XCTAssertTrue(app.descendants(matching: .any)["places.mapMode"].waitForExistence(timeout: 5),
                      "Selecting a city must open the working city map.")
    }

    @MainActor
    func testMapVisualMarkerAndAnnotationExposeMinimumTouchTargets() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)

        let surface = app.descendants(matching: .any)["map.provinceInteractionSurface"]
        XCTAssertTrue(waitForNonEmptyFrame(surface), "The rendered province map must expose its real touch surface.")

        // Tap the rendered marker's physical 44 pt target through the map's
        // coordinate space. This deliberately does not activate the synthetic
        // accessibility action, so it exercises the same hit geometry as a finger.
        let cityMarker = app.descendants(matching: .any)["map.visualMarker.leiden"]
        assertMinimumTouchTarget(cityMarker, named: "Leiden visual map marker")
        screenCoordinate(
            in: app.windows.firstMatch,
            at: mapScreenPoint(
                in: surface.frame,
                mapNormalizedPoint: CGPoint(x: 0.275, y: 0.550)
            )
        ).tap()

        let mapMode = app.descendants(matching: .any)["places.mapMode"]
        XCTAssertTrue(mapMode.waitForExistence(timeout: 5),
                      "Tapping the visual city marker must open the MapKit city map.")

        let annotation = firstHittableElement(withIdentifierPrefix: "map.annotation.", in: app)
        assertMinimumTouchTarget(annotation, named: "MapKit annotation")
    }

    @MainActor
    func testVisualProvinceMapTapSelectsGroningen() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)

        let surface = app.descendants(matching: .any)["map.provinceInteractionSurface"]
        assertExists(surface, named: "map.provinceInteractionSurface")
        XCTAssertFalse(surface.frame.isEmpty, "Province interaction surface must expose a real frame.")

        surface.coordinate(withNormalizedOffset: CGVector(dx: 0.67, dy: 0.14)).tap()

        XCTAssertTrue(app.buttons["map.city.groningen"].waitForExistence(timeout: 3),
                      "A visual tap inside Groningen must expose Groningen's city control.")
    }

    /// Interaction calibration on the selected Xcode destination. Reliability
    /// is measured from one injected hardware-path event per sample. App-side
    /// handling starts when SwiftUI delivers the tap; XCUI confirmation also
    /// includes automation and accessibility round-trip overhead.
    @MainActor
    func testProvinceMapHundredTapCalibration() throws {
        let app = launchApp(language: "en", extraArguments: ["-mapHitDebug"])

        try requireAppWindow(in: app)
        openMap(in: app)

        let surface = app.descendants(matching: .any)["map.provinceInteractionSurface"]
        assertExists(surface, named: "map.provinceInteractionSurface")
        XCTAssertTrue(waitForNonEmptyFrame(surface), "Province interaction surface must be hittable before calibration.")
        let appWindow = app.windows.firstMatch
        XCTAssertTrue(waitForNonEmptyFrame(appWindow), "The app window must expose stable screen coordinates.")

        let samples = provinceCalibrationSamples()
        XCTAssertEqual(samples.count, 100, "The calibration run must exercise exactly 100 taps.")
        XCTAssertTrue(
            zip(samples, samples.dropFirst()).allSatisfy { pair in
                pair.0.provinceID != pair.1.provinceID
            },
            "Calibration samples must alternate provinces so every tap requires a state change."
        )

        var responseTimes: [TimeInterval] = []
        var appHandlingTimes: [TimeInterval] = []
        var injectionTimes: [TimeInterval] = []
        var missedTapCount = 0
        var wrongProvinceCount = 0
        var delayedFeedbackCount = 0
        var failureDetails: [String] = []
        for (index, sample) in samples.enumerated() {
            // Re-query the surface after every selected-state update. A cached
            // XCUIElement anchor can retain an obsolete accessibility frame on
            // a physical device even though its `frame` property looks current.
            let currentSurface = app.descendants(matching: .any)["map.provinceInteractionSurface"]
            guard currentSurface.exists, !currentSurface.frame.isEmpty else {
                missedTapCount += samples.count - index
                failureDetails.append("#\(index): surface disappeared with \(samples.count - index) samples remaining")
                break
            }

            XCTAssertEqual(
                app.state,
                .runningForeground,
                "External interruption moved YouNew out of the foreground before tap #\(index)."
            )
            let surfaceFrame = currentSurface.frame
            let intendedScreenPoint = mapScreenPoint(
                in: surfaceFrame,
                mapNormalizedPoint: sample.mapNormalizedPoint
            )
            let sequenceBeforeTap = provinceSnapshot(of: currentSurface).touchSequence
            let injectionStartedAt = ProcessInfo.processInfo.systemUptime
            screenCoordinate(in: appWindow, at: intendedScreenPoint).tap()
            injectionTimes.append(ProcessInfo.processInfo.systemUptime - injectionStartedAt)

            let responseStartedAt = ProcessInfo.processInfo.systemUptime
            let outcome = waitForProvinceValue(
                sample.provinceID,
                in: app,
                startedAt: responseStartedAt,
                timeout: 1.50
            )

            if outcome.matched {
                responseTimes.append(outcome.elapsed)
                if let appHandlingMilliseconds = outcome.appHandlingMilliseconds {
                    let appHandling = appHandlingMilliseconds / 1_000
                    appHandlingTimes.append(appHandling)
                    if appHandling > 0.10 {
                        delayedFeedbackCount += 1
                    }
                }
            } else if outcome.touchSequence == sequenceBeforeTap
                        || outcome.resolvedProvinceID == nil {
                missedTapCount += 1
                failureDetails.append(
                    "#\(index) expected=\(sample.provinceID) result=\(outcome.value.isEmpty ? "<empty>" : outcome.value) sequence=\(outcome.touchSequence.map(String.init) ?? "none") resolved=\(outcome.resolvedProvinceID ?? "none") point=\(outcome.hitPoint ?? "none") intendedScreen=\(formatted(intendedScreenPoint)) surfaceFrame=\(formatted(surfaceFrame)) classification=miss"
                )
            } else {
                wrongProvinceCount += 1
                failureDetails.append(
                    "#\(index) expected=\(sample.provinceID) result=\(outcome.value) sequence=\(outcome.touchSequence.map(String.init) ?? "none") resolved=\(outcome.resolvedProvinceID ?? "none") point=\(outcome.hitPoint ?? "none") intendedScreen=\(formatted(intendedScreenPoint)) surfaceFrame=\(formatted(surfaceFrame)) classification=wrong-neighbour"
                )
            }
        }

        let orderedTimes = responseTimes.sorted()
        let orderedAppHandlingTimes = appHandlingTimes.sorted()
        let orderedInjectionTimes = injectionTimes.sorted()
        let average = orderedTimes.isEmpty ? .infinity : orderedTimes.reduce(0, +) / Double(orderedTimes.count)
        let p95 = percentile(0.95, in: orderedTimes)
        let maximum = orderedTimes.last ?? .infinity
        let appHandlingAverage = orderedAppHandlingTimes.isEmpty
            ? .infinity
            : orderedAppHandlingTimes.reduce(0, +) / Double(orderedAppHandlingTimes.count)
        let appHandlingP95 = percentile(0.95, in: orderedAppHandlingTimes)
        let appHandlingMaximum = orderedAppHandlingTimes.last ?? .infinity
        let injectionAverage = orderedInjectionTimes.isEmpty
            ? .infinity
            : orderedInjectionTimes.reduce(0, +) / Double(orderedInjectionTimes.count)

        let calibrationSummary = String(
            format: "UX_CALIBRATION_\(calibrationPlatformLabel) taps=%d matched=%d missed=%d wrong=%d appHandlingOver100ms=%d avgAppHandling=%.3fms p95AppHandling=%.3fms maxAppHandling=%.3fms avgXCUIConfirmation=%.1fms p95XCUIConfirmation=%.1fms maxXCUIConfirmation=%.1fms avgXCTestDispatch=%.1fms (app-handler timing; XCUI confirmation includes automation overhead)",
            samples.count,
            responseTimes.count,
            missedTapCount,
            wrongProvinceCount,
            delayedFeedbackCount,
            appHandlingAverage * 1_000,
            appHandlingP95 * 1_000,
            appHandlingMaximum * 1_000,
            average * 1_000,
            p95 * 1_000,
            maximum * 1_000,
            injectionAverage * 1_000
        )
        print(calibrationSummary)

        let reportAttachment = XCTAttachment(
            string: ([calibrationSummary] + failureDetails).joined(separator: "\n")
        )
        reportAttachment.name = "UX Province Tap Calibration"
        reportAttachment.lifetime = .keepAlways
        add(reportAttachment)

        XCTAssertEqual(missedTapCount, 0, "The 100-tap calibration run must not miss a province tap.")
        XCTAssertEqual(wrongProvinceCount, 0, "The 100-tap calibration run must never select a neighboring province.")
        XCTAssertEqual(responseTimes.count, samples.count, "Every injected tap must produce the expected province value.")
        XCTAssertEqual(
            appHandlingTimes.count,
            samples.count,
            "Every injected tap must publish an app-side touch-handling measurement."
        )
        XCTAssertEqual(
            delayedFeedbackCount,
            0,
            "Every app-side province handler must commit within the 100 ms responsiveness target."
        )
        XCTAssertLessThan(
            appHandlingAverage,
            0.10,
            "Average app-side province handling must stay below 100 ms."
        )
        XCTAssertLessThan(
            appHandlingP95,
            0.10,
            "The p95 app-side province handling must stay below 100 ms."
        )

        // A scroll-intent drag starts on the map but travels well beyond the map tap slop.
        // It must never commit the province that happened to be under the initial finger-down.
        let finalSurface = app.descendants(matching: .any)["map.provinceInteractionSurface"]
        let valueBeforeScrollIntent = provinceValue(of: finalSurface)
        let frameBeforeScrollIntent = finalSurface.frame
        let dragStart = finalSurface.coordinate(withNormalizedOffset: CGVector(dx: 0.60, dy: 0.68))
        let dragEnd = finalSurface.coordinate(withNormalizedOffset: CGVector(dx: 0.60, dy: 0.34))
        dragStart.press(forDuration: 0.05, thenDragTo: dragEnd)
        RunLoop.current.run(until: Date().addingTimeInterval(0.20))

        let surfaceAfterScroll = app.descendants(matching: .any)["map.provinceInteractionSurface"]
        let scrollDeltaY = surfaceAfterScroll.frame.minY - frameBeforeScrollIntent.minY
        XCTAssertEqual(
            provinceValue(of: surfaceAfterScroll),
            valueBeforeScrollIntent,
            "A scroll-intent drag across the map must not commit a province selection."
        )
        XCTAssertGreaterThan(
            abs(scrollDeltaY),
            20,
            "A map drag beyond tap slop must remain available to the parent ScrollView."
        )
        print(
            String(
                format: "UX_CALIBRATION_SCROLL_INTENT selected=%@ surfaceDeltaY=%.1fpt",
                valueBeforeScrollIntent,
                scrollDeltaY
            )
        )
    }

    /// Measures app-side root navigation from the actual selection-state change
    /// request until the destination root view's `onAppear` callback.
    @MainActor
    func testRootTabNavigationLatency() throws {
        let app = launchApp(language: "en")

        try requireAppWindow(in: app)
        openMap(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["map.hub"].waitForExistence(timeout: 3))

        assertMinimumTouchTarget(
            app.descendants(matching: .any)["tab.home"],
            named: "Home tab"
        )
        assertMinimumTouchTarget(
            app.descendants(matching: .any)["tab.map"],
            named: "Map tab"
        )

        let initialMetricProbe = app.descendants(matching: .any)["root.tabNavigationMetric"]
        XCTAssertTrue(
            initialMetricProbe.waitForExistence(timeout: 2),
            "The UI-testing-only root tab navigation metric must be exposed."
        )
        let initialMetric = try XCTUnwrap(
            rootTabNavigationMetric(from: initialMetricProbe.value),
            "The initial root tab navigation metric must be parseable."
        )

        var homeDurations: [TimeInterval] = []
        var mapDurations: [TimeInterval] = []
        var lastSequence = initialMetric.sequence

        for _ in 0..<5 {
            // Re-query after each root replacement. Holding an XCUIElement
            // snapshot across a tab switch can address the retired tab bar.
            let homeTab = app.descendants(matching: .any)["tab.home"]
            XCTAssertTrue(homeTab.isHittable, "Home tab must accept the first tap.")
            homeTab.tap()
            XCTAssertTrue(
                app.descendants(matching: .any)["screen.home"].waitForExistence(timeout: 2),
                "Home destination must become visible on the first tap."
            )
            let homeMetric = try XCTUnwrap(
                waitForRootTabNavigationMetric(
                    in: app,
                    afterSequence: lastSequence,
                    expectedTab: "home"
                ),
                "Home navigation must publish one fresh app-side latency sample."
            )
            lastSequence = homeMetric.sequence
            homeDurations.append(homeMetric.delayMilliseconds / 1_000)

            let mapTab = app.descendants(matching: .any)["tab.map"]
            XCTAssertTrue(mapTab.isHittable, "Map tab must accept the first tap.")
            mapTab.tap()
            XCTAssertTrue(
                app.descendants(matching: .any)["map.hub"].waitForExistence(timeout: 2),
                "Map destination must become visible on the first tap."
            )
            let mapMetric = try XCTUnwrap(
                waitForRootTabNavigationMetric(
                    in: app,
                    afterSequence: lastSequence,
                    expectedTab: "map"
                ),
                "Map navigation must publish one fresh app-side latency sample."
            )
            lastSequence = mapMetric.sequence
            mapDurations.append(mapMetric.delayMilliseconds / 1_000)
        }

        let allDurations = (homeDurations + mapDurations).sorted()
        let initialTransitionDurations = [homeDurations.first, mapDurations.first].compactMap { $0 }.sorted()
        let steadyStateDurations = Array(homeDurations.dropFirst()) + Array(mapDurations.dropFirst())
        let average = allDurations.reduce(0, +) / Double(allDurations.count)
        let steadyStateAverage = steadyStateDurations.reduce(0, +) / Double(steadyStateDurations.count)
        let homeAverage = homeDurations.reduce(0, +) / Double(homeDurations.count)
        let mapAverage = mapDurations.reduce(0, +) / Double(mapDurations.count)
        let homeSamples = homeDurations
            .map { String(format: "%.1f", $0 * 1_000) }
            .joined(separator: ",")
        let mapSamples = mapDurations
            .map { String(format: "%.1f", $0 * 1_000) }
            .joined(separator: ",")

        print("UX_NAVIGATION_SAMPLES homeMs=[\(homeSamples)] mapMs=[\(mapSamples)]")

        print(
            String(
                format: "UX_NAVIGATION_\(calibrationPlatformLabel) transitions=%d avg=%.1fms homeAvg=%.1fms mapAvg=%.1fms initialMax=%.1fms steadyAvg=%.1fms steadyMax=%.1fms (app state-change-to-presented-root; excludes hardware touch-to-photon latency)",
                allDurations.count,
                average * 1_000,
                homeAverage * 1_000,
                mapAverage * 1_000,
                (initialTransitionDurations.last ?? .infinity) * 1_000,
                steadyStateAverage * 1_000,
                (steadyStateDurations.max() ?? .infinity) * 1_000
            )
        )

        // The first measured pair includes Debug Simulator metadata and layer
        // warm-up. Keep it bounded separately so it cannot hide a regression
        // in the eight repeat transitions that represent normal tab use.
        XCTAssertLessThan(
            initialTransitionDurations.last ?? .infinity,
            0.30,
            "Every initial root transition must stay below the 300 ms Debug Simulator warm-up budget."
        )
        XCTAssertLessThan(
            steadyStateAverage,
            0.10,
            "Average steady-state root tab navigation must stay below 100 ms."
        )
        XCTAssertLessThan(
            steadyStateDurations.max() ?? .infinity,
            0.15,
            "Every steady-state root navigation sample must stay below the 150 ms Debug Simulator jitter ceiling."
        )
    }

    @MainActor
    private func launchApp(language: String, extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        if app.state != .notRunning {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5), "Previous app instance did not terminate before relaunch.")
        }

        app.launchArguments = [
            "-uiTesting",
            "-resetUITestState",
            "-launchLanguage", language,
            "-uiTestingStartTab", "map",
            "-uiTestingCity", "Leiden"
        ] + extraArguments
        app.launch()
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 8), "App window did not appear after launch.")
        return app
    }

    private func provinceCalibrationSamples() -> [ProvinceTapSample] {
        let representativePoints: [String: CGPoint] = [
            "Groningen": CGPoint(x: 0.864, y: 0.092),
            "Friesland": CGPoint(x: 0.640, y: 0.172),
            "Drenthe": CGPoint(x: 0.868, y: 0.240),
            "Noord-Holland": CGPoint(x: 0.388, y: 0.380),
            "Flevoland": CGPoint(x: 0.600, y: 0.384),
            "Overijssel": CGPoint(x: 0.816, y: 0.400),
            "Utrecht": CGPoint(x: 0.520, y: 0.528),
            "Gelderland": CGPoint(x: 0.680, y: 0.532),
            // Exact interior deliberately right of the active Leiden marker
            // and below its label target, including the calibration jitter.
            "Zuid-Holland": CGPoint(x: 0.440, y: 0.600),
            "Zeeland": CGPoint(x: 0.112, y: 0.740),
            "Noord-Brabant": CGPoint(x: 0.580, y: 0.724),
            "Limburg": CGPoint(x: 0.696, y: 0.824)
        ]
        let criticalProvinceIDs = ["Groningen", "Zeeland", "Limburg", "Flevoland", "Utrecht"]
        let otherProvinceIDs = ["Friesland", "Drenthe", "Noord-Holland", "Overijssel", "Gelderland", "Zuid-Holland", "Noord-Brabant"]
        var generator = SeededCalibrationGenerator()

        func randomSample(_ provinceID: String) -> ProvinceTapSample {
            let point = representativePoints[provinceID] ?? .zero
            // A reproducible sub-point jitter exercises the physical delivery
            // path without crossing the deliberately chosen province interior.
            let jitterRadius: CGFloat = 0.005
            return ProvinceTapSample(
                provinceID: provinceID,
                mapNormalizedPoint: CGPoint(
                    x: point.x + generator.signedUnitValue() * jitterRadius,
                    y: point.y + generator.signedUnitValue() * jitterRadius
                )
            )
        }

        var result: [ProvinceTapSample] = []
        for round in 0..<12 {
            for provinceID in criticalProvinceIDs {
                result.append(randomSample(provinceID))
            }
            if round < 5 {
                for provinceID in otherProvinceIDs {
                    result.append(randomSample(provinceID))
                }
            }
        }

        for provinceID in criticalProvinceIDs {
            result.append(randomSample(provinceID))
        }

        return result
    }

    @MainActor
    private func mapScreenPoint(in surfaceFrame: CGRect, mapNormalizedPoint: CGPoint) -> CGPoint {
        let size = surfaceFrame.size
        let paddedWidth = max(1, size.width - 60)
        let paddedHeight = max(1, size.height - 30)
        let aspect: CGFloat = 0.54
        let fittedHeight = min(paddedHeight, paddedWidth / aspect)
        let fittedWidth = fittedHeight * aspect
        let mapRect = CGRect(
            x: 30 + (paddedWidth - fittedWidth) / 2,
            y: 12 + (paddedHeight - fittedHeight) / 2,
            width: fittedWidth,
            height: fittedHeight
        )
        return CGPoint(
            x: surfaceFrame.minX + mapRect.minX + mapNormalizedPoint.x * mapRect.width,
            y: surfaceFrame.minY + mapRect.minY + mapNormalizedPoint.y * mapRect.height
        )
    }

    private func screenCoordinate(in window: XCUIElement, at point: CGPoint) -> XCUICoordinate {
        window.coordinate(withNormalizedOffset: .zero).withOffset(
            CGVector(
                dx: point.x - window.frame.minX,
                dy: point.y - window.frame.minY
            )
        )
    }

    @MainActor
    private func waitForProvinceValue(
        _ expectedValue: String,
        in app: XCUIApplication,
        startedAt: TimeInterval,
        timeout: TimeInterval
    ) -> ProvinceTapOutcome {
        let deadline = ProcessInfo.processInfo.systemUptime + timeout
        var snapshot = provinceSnapshot(
            of: app.descendants(matching: .any)["map.provinceInteractionSurface"]
        )

        while ProcessInfo.processInfo.systemUptime < deadline {
            snapshot = provinceSnapshot(
                of: app.descendants(matching: .any)["map.provinceInteractionSurface"]
            )
            if snapshot.provinceID == expectedValue {
                return ProvinceTapOutcome(
                    matched: true,
                    value: snapshot.provinceID,
                    elapsed: ProcessInfo.processInfo.systemUptime - startedAt,
                    touchSequence: snapshot.touchSequence,
                    resolvedProvinceID: snapshot.resolvedProvinceID,
                    hitPoint: snapshot.hitPoint,
                    appHandlingMilliseconds: snapshot.appHandlingMilliseconds
                )
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }

        return ProvinceTapOutcome(
            matched: false,
            value: snapshot.provinceID,
            elapsed: ProcessInfo.processInfo.systemUptime - startedAt,
            touchSequence: snapshot.touchSequence,
            resolvedProvinceID: snapshot.resolvedProvinceID,
            hitPoint: snapshot.hitPoint,
            appHandlingMilliseconds: snapshot.appHandlingMilliseconds
        )
    }

    private func formatted(_ point: CGPoint) -> String {
        String(format: "(%.1f,%.1f)", point.x, point.y)
    }

    private func formatted(_ rect: CGRect) -> String {
        String(
            format: "(x=%.1f,y=%.1f,w=%.1f,h=%.1f)",
            rect.minX,
            rect.minY,
            rect.width,
            rect.height
        )
    }

    @MainActor
    private func provinceValue(of surface: XCUIElement) -> String {
        provinceSnapshot(of: surface).provinceID
    }

    @MainActor
    private func provinceSnapshot(of surface: XCUIElement) -> ProvinceSurfaceSnapshot {
        let rawValue = surface.value as? String ?? ""
        guard rawValue.hasPrefix("province=") else {
            return ProvinceSurfaceSnapshot(
                provinceID: rawValue,
                touchSequence: nil,
                resolvedProvinceID: nil,
                hitPoint: nil,
                appHandlingMilliseconds: nil
            )
        }

        let fields = rawValue.split(separator: ";", omittingEmptySubsequences: false).reduce(
            into: [String: String]()
        ) { result, field in
            let pair = field.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pair.count == 2 else { return }
            result[String(pair[0])] = String(pair[1])
        }

        return ProvinceSurfaceSnapshot(
            provinceID: fields["province"] ?? "",
            touchSequence: fields["sequence"].flatMap(Int.init),
            resolvedProvinceID: fields["resolved"].flatMap { $0 == "none" ? nil : $0 },
            hitPoint: fields["point"].flatMap { $0 == "none" ? nil : $0 },
            appHandlingMilliseconds: fields["handlingMs"].flatMap(Double.init)
        )
    }

    @MainActor
    private func waitForRootTabNavigationMetric(
        in app: XCUIApplication,
        afterSequence previousSequence: Int,
        expectedTab: String,
        timeout: TimeInterval = 2
    ) -> RootTabNavigationMetric? {
        let deadline = ProcessInfo.processInfo.systemUptime + timeout

        while ProcessInfo.processInfo.systemUptime < deadline {
            // The tab switch replaces the root content hierarchy, so always
            // query the probe again instead of retaining an XCUIElement snapshot.
            let probe = app.descendants(matching: .any)["root.tabNavigationMetric"]
            if probe.exists,
               let metric = rootTabNavigationMetric(from: probe.value),
               metric.sequence > previousSequence,
               metric.tab == expectedTab {
                return metric
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }

        return nil
    }

    private func rootTabNavigationMetric(from value: Any?) -> RootTabNavigationMetric? {
        guard let rawValue = value as? String else { return nil }
        let fields = rawValue.split(separator: ";").reduce(into: [String: String]()) { result, field in
            let pair = field.split(separator: "=", maxSplits: 1).map(String.init)
            guard pair.count == 2 else { return }
            result[pair[0]] = pair[1]
        }

        guard let sequenceValue = fields["sequence"],
              let sequence = Int(sequenceValue),
              let tab = fields["tab"],
              let delayValue = fields["delayMs"],
              let delayMilliseconds = Double(delayValue),
              delayMilliseconds.isFinite,
              delayMilliseconds >= 0
        else { return nil }

        return RootTabNavigationMetric(
            sequence: sequence,
            tab: tab,
            delayMilliseconds: delayMilliseconds
        )
    }

    private func percentile(_ percentile: Double, in orderedValues: [TimeInterval]) -> TimeInterval {
        guard !orderedValues.isEmpty else { return .infinity }
        let rank = max(0, min(orderedValues.count - 1, Int(ceil(Double(orderedValues.count) * percentile)) - 1))
        return orderedValues[rank]
    }

    @MainActor
    private func requireAppWindow(in app: XCUIApplication) throws {
        if !app.windows.firstMatch.waitForExistence(timeout: 4) {
            XCTFail("No app window is exposed for the active UI test destination.")
        }
    }

    @MainActor
    private func openMap(in app: XCUIApplication) {
        if app.descendants(matching: .any)["map.hub"].waitForExistence(timeout: 1) {
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
        let chipRow = app.descendants(matching: .any)["map.city.leiden"]
        for _ in 0..<5 {
            if waitForNonEmptyFrame(chipRow, timeout: 0.5) || app.buttons["map.city.leiden"].isHittable {
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
    private func revealCityMarker(identifier: String, in app: XCUIApplication) -> XCUIElement {
        let marker = app.buttons[identifier]
        for _ in 0..<6 {
            if marker.waitForExistence(timeout: 0.75) {
                return marker
            }
            app.swipeUp()
        }
        return marker
    }

    @MainActor
    private func firstHittableElement(
        withIdentifierPrefix prefix: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 5
    ) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        let matches = app.descendants(matching: .any).matching(predicate)
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            for element in matches.allElementsBoundByIndex where element.isHittable && !element.frame.isEmpty {
                return element
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }

        return matches.firstMatch
    }

    @MainActor
    private func assertMinimumTouchTarget(_ element: XCUIElement, named name: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 4), "Missing control: \(name)")
        XCTAssertTrue(element.isHittable, "\(name) must be hittable.")
        XCTAssertGreaterThanOrEqual(element.frame.width, 43.5, "\(name) must be at least 44 points wide.")
        XCTAssertGreaterThanOrEqual(element.frame.height, 43.5, "\(name) must be at least 44 points high.")
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
