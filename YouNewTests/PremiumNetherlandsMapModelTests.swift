import CoreGraphics
import Testing
@testable import YouNew

@MainActor
struct PremiumNetherlandsMapModelTests {
    @Test func activeCityMarkerRendersAsActive() {
        let marker = PremiumNetherlandsMapModel.marker(
            named: "Amsterdam",
            selectedCity: "Amsterdam",
            mode: .cities
        )

        #expect(marker?.role == .activeCity)
        #expect(marker?.normalizedPosition.x ?? 0 > 0.30)
        #expect(marker?.normalizedPosition.y ?? 0 > 0.35)
    }

    @Test func nonActiveCityMarkersRemainCoolCityMarkers() {
        let marker = PremiumNetherlandsMapModel.marker(
            named: "Rotterdam",
            selectedCity: "Amsterdam",
            mode: .cities
        )

        #expect(marker == nil)
    }

    @Test func mapPreviewSupportsCitiesProvincesAndServicesModes() {
        #expect(PremiumMapDisplayMode.allCases == [.cities, .provinces, .services])

        for mode in PremiumMapDisplayMode.allCases {
            let markers = PremiumNetherlandsMapModel.markers(selectedCity: "Leiden", mode: mode)
            #expect(markers.count == 1)
            #expect(markers.first?.name == "Leiden")
        }

        #expect(PremiumNetherlandsMapModel.markers(selectedCity: "Leiden", mode: .services).allSatisfy {
            $0.role == .activeCity
        })
    }

    @Test func onlySelectedCityMarkerExistsOnRecognizableGeography() {
        let markers = PremiumNetherlandsMapModel.markers(selectedCity: "Amsterdam", mode: .cities)
        #expect(markers.map(\.name) == ["Amsterdam"])

        for marker in markers {
            #expect((0...1).contains(marker.normalizedPosition.x))
            #expect((0...1).contains(marker.normalizedPosition.y))
            #expect((0...1).contains(marker.normalizedLabelPosition.x))
            #expect((0...1).contains(marker.normalizedLabelPosition.y))
        }

        let amsterdam = PremiumNetherlandsMapModel.marker(named: "Amsterdam", selectedCity: "Amsterdam", mode: .cities)
        let rotterdam = PremiumNetherlandsMapModel.marker(named: "Rotterdam", selectedCity: "Amsterdam", mode: .cities)

        #expect(amsterdam?.role == .activeCity)
        #expect(rotterdam == nil)
    }

    @Test func labelsDoNotOverlapCTAInHomePreview() {
        for mode in PremiumMapDisplayMode.allCases {
            #expect(PremiumNetherlandsMapModel.labelsAvoidCTA(selectedCity: "Amsterdam", mode: mode))
            #expect(PremiumNetherlandsMapModel.labelsAvoidCTA(selectedCity: "Leiden", mode: mode))
        }
    }

    @Test func labelsRemainInReadableMapBounds() {
        for mode in PremiumMapDisplayMode.allCases {
            for frame in PremiumNetherlandsMapModel.labelFrames(selectedCity: "Amsterdam", mode: mode) {
                #expect(frame.minX >= 0)
                #expect(frame.maxX <= 1)
                #expect(frame.minY >= 0)
                #expect(frame.maxY <= 1)
            }
        }
    }

    @Test func cityLabelsHaveSafetySpacingForHomePreview() {
        for mode in PremiumMapDisplayMode.allCases {
            let frames = PremiumNetherlandsMapModel.labelFrames(selectedCity: "Amsterdam", mode: mode)

            for lhsIndex in frames.indices {
                for rhsIndex in frames.indices where rhsIndex > lhsIndex {
                    #expect(!frames[lhsIndex].insetBy(dx: -0.006, dy: -0.004).intersects(frames[rhsIndex]))
                }
            }
        }
    }

    @Test func compactWidthAndBottomNavigationReserveAreSupported() {
        #expect(PremiumNetherlandsMapModel.supportsCompactWidth(320))
        #expect(PremiumNetherlandsMapModel.minimumHomeCardHeight >= 420)
        #expect(PremiumNetherlandsMapModel.ctaSafeFrame.maxY < 0.97)
    }

    @Test func denHaagAliasSelectsTheHagueMarker() {
        let marker = PremiumNetherlandsMapModel.marker(
            named: "The Hague",
            selectedCity: "Den Haag",
            mode: .cities
        )

        #expect(marker?.role == .activeCity)
    }

    @Test func mapViewModelUsesSelectedCityDashboardPlacesWithCoordinates() {
        let model = MapViewModel()
        model.activePersona = .tourist
        model.selectedCity = "Rotterdam"

        #expect(!model.filteredPlaces.isEmpty)
        #expect(model.filteredPlaces.allSatisfy { $0.city == "Rotterdam" })
        #expect(model.filteredPlaces.contains { $0.name == "Markthal" })
        #expect(!model.filteredPlaces.contains { $0.city == "Amsterdam" || $0.name == "Rijksmuseum" })

        let dashboardRotterdamWithCoordinates = DashboardPlacesData.visiblePlaces(cityId: "Rotterdam", audience: .tourist, limit: nil)
            .filter { $0.coordinates != nil }
            .map(\.title)
        #expect(dashboardRotterdamWithCoordinates.contains("Markthal"))
        #expect(model.filteredPlaces.contains { dashboardRotterdamWithCoordinates.contains($0.name) })
    }

    @Test func dashboardPlacesWithoutCoordinatesAreNotMapMarkers() {
        let model = MapViewModel()
        model.activePersona = .tourist

        for city in CityDashboardContentData.supportedCityNames {
            model.selectedCity = city
            let noCoordinateTitles = DashboardPlacesData.visiblePlaces(cityId: city, audience: .tourist, limit: nil)
                .filter { $0.coordinates == nil }
                .map(\.title)

            #expect(model.filteredPlaces.allSatisfy { !noCoordinateTitles.contains($0.name) })
            #expect(model.filteredPlaces.allSatisfy { $0.city == city })
        }
    }
}
