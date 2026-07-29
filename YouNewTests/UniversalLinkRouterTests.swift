import Foundation
import Testing
@testable import YouNew

struct UniversalLinkRouterTests {
    @Test func acceptsOnlyTheYouNewHTTPSDomain() {
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/map/")!)?.tab == .map)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://www.younew.nl/search/")!)?.tab == .guide)
        #expect(UniversalLinkRouter.route(for: URL(string: "http://younew.nl/map/")!) == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://example.nl/map/")!) == nil)
    }

    @Test func mapsPublicSectionsToTheirNativeAreas() {
        let home = UniversalLinkRouter.route(for: URL(string: "https://younew.nl/")!)
        #expect(home?.tab == .home)
        #expect(home?.destination == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/places/")!)?.tab == .map)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/saved/")!)?.tab == .saved)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/app/")!)?.tab == .more)
    }

    @Test func resolvesNativeDestinationsWhenAvailable() {
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/search/")!)?.destination == .searchList)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/categories/housing/")!)?.destination == .practicalGuide(.housingBasics))
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/emergency/")!)?.destination != nil)
    }

    @Test func leavesUnknownWebsitePathsInTheBrowser() {
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/business/apply/")!) == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/not-a-real-section/")!) == nil)
    }
}
