import Combine
import Testing
@testable import YouNew

@MainActor
struct TabRouterTests {
    @Test
    func selectionUpdatesCursorWithoutInvalidatingTheRootHierarchy() {
        let router = TabRouter(initialTab: .map)
        var rootInvalidationCount = 0
        let observation = router.objectWillChange.sink {
            rootInvalidationCount += 1
        }

        router.select(TabItem.home)

        #expect(router.selectedTab == .home)
        #expect(rootInvalidationCount == 0)
        withExtendedLifetime(observation) {}
    }

    @Test
    func reselectStillEmitsExactlyOneResetForTheActiveTab() {
        let router = TabRouter(initialTab: .map)
        var homeResetCount = 0
        var mapResetCount = 0
        let homeObservation = router.homeScrollTop.sink {
            homeResetCount += 1
        }
        let mapObservation = router.mapReset.sink {
            mapResetCount += 1
        }

        router.select(TabItem.home)
        #expect(homeResetCount == 0)
        #expect(mapResetCount == 0)

        router.select(TabItem.home)
        #expect(homeResetCount == 1)
        #expect(mapResetCount == 0)

        router.select(TabItem.map)
        #expect(homeResetCount == 1)
        #expect(mapResetCount == 0)

        router.select(TabItem.map)
        #expect(homeResetCount == 1)
        #expect(mapResetCount == 1)

        withExtendedLifetime((homeObservation, mapObservation)) {}
    }
}
