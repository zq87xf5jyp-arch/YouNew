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

    @Test func resolvesPublishedContentSlugsToExactNativeDetails() throws {
        let guideID = try #require(
            ContentRepository.shared.item(id: "government_service.first-registration-in-amsterdam")?.id
        )
        let placeID = try #require(ContentRepository.shared.item(id: "place.adam-lookout")?.id)
        let organizationID = try #require(ContentRepository.shared.item(id: "healthcare.acta")?.id)
        let guide = UniversalLinkRouter.route(
            for: URL(string: "https://younew.nl/guides/first-registration-in-amsterdam/")!
        )
        #expect(guide?.tab == .guide)
        #expect(
            guide?.destination == .guideArticle(
                sectionID: GuideContent.dataProjectSectionID,
                articleID: guideID
            )
        )

        let place = UniversalLinkRouter.route(
            for: URL(string: "https://younew.nl/places/adam-lookout/")!
        )
        #expect(place?.tab == .map)
        #expect(
            place?.destination == .guideArticle(
                sectionID: GuideContent.dataProjectSectionID,
                articleID: placeID
            )
        )

        let organization = UniversalLinkRouter.route(
            for: URL(string: "https://younew.nl/organizations/acta/")!
        )
        #expect(organization?.tab == .guide)
        #expect(
            organization?.destination == .guideArticle(
                sectionID: GuideContent.dataProjectSectionID,
                articleID: organizationID
            )
        )

        for route in [guide, place, organization] {
            let destination = try #require(route?.destination)
            #expect(RelatedContentEngine.isVisible(destination, for: .worker))
        }
    }

    @Test func mapsThePublicJourneyHubToTheNativeJourney() {
        let journey = UniversalLinkRouter.route(for: URL(string: "https://younew.nl/journeys/")!)
        #expect(journey?.tab == .home)
        #expect(journey?.destination == .firstSteps)
    }

    @Test func failsClosedForUnknownPublishedContentSlugs() {
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/guides/not-published/")!)?.destination == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/places/not-published/")!)?.destination == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/organizations/not-published/")!)?.destination == nil)
    }

    @Test func leavesUnknownWebsitePathsInTheBrowser() {
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/business/apply/")!) == nil)
        #expect(UniversalLinkRouter.route(for: URL(string: "https://younew.nl/not-a-real-section/")!) == nil)
    }
}
