import Testing
import Foundation
@testable import YouNew

// MARK: - AI Navigator Route Tests

@MainActor
struct AINavigatorRouteTests {

    // MARK: Route completeness

    @Test func quickRoutesContainsAllEightRoutes() {
        #expect(AINavigatorRoutes.quickRoutes.count == 8)
    }

    @Test func quickRouteIDsAreUnique() {
        let ids = AINavigatorRoutes.quickRoutes.map(\.id)
        let unique = Set(ids)
        #expect(ids.count == unique.count, "Duplicate route IDs found: \(ids)")
    }

    // MARK: Per-route structural validity

    @Test func bsnRouteIsStructurallyValid() {
        let route = requireRoute(id: "bsn")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.officialSources.contains("rijksoverheid.nl"))
    }

    @Test func digidRouteIsStructurallyValid() {
        let route = requireRoute(id: "digid")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.officialSources.contains("digid.nl"))
    }

    @Test func housingRouteIsStructurallyValid() {
        let route = requireRoute(id: "housing")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(!route.officialSources.isEmpty)
    }

    @Test func doctorRouteIsStructurallyValid() {
        let route = requireRoute(id: "doctor")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.stepsEN.contains(where: { $0.contains("112") }),
                "Doctor route must reference emergency number 112")
    }

    @Test func workRouteIsStructurallyValid() {
        let route = requireRoute(id: "work")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.officialSources.contains("uwv.nl"))
    }

    @Test func taxesRouteIsStructurallyValid() {
        let route = requireRoute(id: "taxes")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.officialSources.contains("belastingdienst.nl"))
    }

    @Test func emergencyRouteIsStructurallyValid() {
        let route = requireRoute(id: "emergency")
        assertRouteValid(route)
        #expect(route.stepsEN.first?.contains("112") == true,
                "Emergency route first step must reference 112")
        #expect(route.officialSources.contains("112.nl"))
    }

    @Test func dutchRouteIsStructurallyValid() {
        let route = requireRoute(id: "dutch")
        assertRouteValid(route)
        #expect(route.stepsEN.count >= 4)
        #expect(route.officialSources.contains("duo.nl"))
    }

    // MARK: Intent localization

    @Test func allRoutesHaveNonEmptyEnglishIntent() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.intentEN.isEmpty, "Route \(route.id) has empty English intent")
            #expect(route.intent(.english) == route.intentEN)
        }
    }

    @Test func allRoutesHaveNonEmptyDutchIntent() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.intentNL.isEmpty, "Route \(route.id) has empty Dutch intent")
            #expect(route.intent(.dutch) == route.intentNL)
        }
    }

    @Test func allRoutesHaveNonEmptyRussianIntent() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.intentRU.isEmpty, "Route \(route.id) has empty Russian intent")
            #expect(route.intent(.russian) == route.intentRU)
        }
    }

    // MARK: Destination validity

    @Test func bsnRouteDestinationIsGovernmentHub() {
        let route = requireRoute(id: "bsn")
        #expect(route.recommendedDestination == .governmentHub)
    }

    @Test func emergencyRouteDestinationIsEmergencyHub() {
        let route = requireRoute(id: "emergency")
        #expect(route.recommendedDestination == .emergencyHub)
    }

    @Test func dutchRouteDestinationIsLanguageHub() {
        let route = requireRoute(id: "dutch")
        #expect(route.recommendedDestination == .languageHub)
    }

    @Test func allRouteDestinationsAreReachableViaAIRoute() {
        for route in AINavigatorRoutes.quickRoutes {
            let routeID = AppDestination.aiRouteID(from: route.recommendedDestination)
            #expect(routeID != nil,
                    "Route \(route.id) destination \(route.recommendedDestination) has no AI route ID")
        }
    }

    // MARK: Safety disclaimer

    @Test func disclaimerMentionsVerificationAndOfficialSources() {
        let disclaimer = AINavigatorRoutes.disclaimer
        #expect(!disclaimer.isEmpty)
        #expect(disclaimer.localizedCaseInsensitiveContains("official") ||
                disclaimer.localizedCaseInsensitiveContains("verify"))
    }

    @Test func disclaimerExcludesLegalAndMedicalClaims() {
        let disclaimer = AINavigatorRoutes.disclaimer
        #expect(!disclaimer.localizedCaseInsensitiveContains("guaranteed"))
        #expect(!disclaimer.localizedCaseInsensitiveContains("100%"))
    }

    // MARK: Icon validity

    @Test func allRoutesHaveNonEmptyIcon() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.icon.isEmpty, "Route \(route.id) has empty icon")
        }
    }

    // MARK: Steps content

    @Test func allRoutesHaveAtLeastOneStep() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.stepsEN.isEmpty, "Route \(route.id) has no steps")
        }
    }

    @Test func allStepsAreNonEmpty() {
        for route in AINavigatorRoutes.quickRoutes {
            for step in route.stepsEN {
                #expect(!step.trimmingCharacters(in: .whitespaces).isEmpty,
                        "Route \(route.id) has a blank step")
            }
        }
    }

    // MARK: Official sources

    @Test func allRoutesHaveAtLeastOneOfficialSource() {
        for route in AINavigatorRoutes.quickRoutes {
            #expect(!route.officialSources.isEmpty,
                    "Route \(route.id) has no official sources")
        }
    }

    @Test func allOfficialSourcesHaveValidHostFormat() {
        for route in AINavigatorRoutes.quickRoutes {
            for source in route.officialSources {
                let trimmed = source.trimmingCharacters(in: .whitespaces)
                #expect(!trimmed.isEmpty, "Route \(route.id) has blank official source")
                // Sources must look like domain names (contain a dot)
                #expect(trimmed.contains("."),
                        "Route \(route.id) source '\(trimmed)' is not a domain-like string")
            }
        }
    }

    // MARK: Helpers

    private func requireRoute(id: String) -> AINavigatorRoute {
        guard let route = AINavigatorRoutes.quickRoutes.first(where: { $0.id == id }) else {
            Issue.record("Required route '\(id)' not found in AINavigatorRoutes.quickRoutes")
            fatalError("Route '\(id)' missing — test cannot proceed")
        }
        return route
    }

    private func assertRouteValid(_ route: AINavigatorRoute) {
        #expect(!route.id.isEmpty)
        #expect(!route.intentEN.isEmpty)
        #expect(!route.intentNL.isEmpty)
        #expect(!route.intentRU.isEmpty)
        #expect(!route.icon.isEmpty)
        #expect(!route.stepsEN.isEmpty)
        #expect(!route.officialSources.isEmpty)
    }
}
