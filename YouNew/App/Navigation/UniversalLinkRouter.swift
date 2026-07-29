import Foundation

struct UniversalLinkRoute {
    let tab: AppTab
    let destination: AppDestination?
}

enum UniversalLinkRouter {
    static let supportedHosts: Set<String> = ["younew.nl", "www.younew.nl"]

    static func route(for url: URL) -> UniversalLinkRoute? {
        guard url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased(),
              supportedHosts.contains(host)
        else { return nil }

        let components = url.pathComponents.filter { $0 != "/" }
        guard let section = components.first?.lowercased() else {
            return UniversalLinkRoute(tab: .home, destination: nil)
        }

        switch section {
        case "discover":
            return route(tab: .guide, destinationID: "discoverNetherlands")
        case "search":
            return route(tab: .guide, destinationID: "search")
        case "guides", "categories", "journeys":
            let destinationID = components.dropFirst().first ?? section
            return route(tab: .guide, destinationID: destinationID)
        case "map", "places":
            return UniversalLinkRoute(tab: .map, destination: nil)
        case "cities":
            guard let slug = components.dropFirst().first else {
                return route(tab: .guide, destinationID: "cities")
            }
            return route(tab: .guide, destinationID: "city:\(slug)")
        case "provinces":
            guard let slug = components.dropFirst().first else {
                return route(tab: .guide, destinationID: "provinces")
            }
            return route(tab: .guide, destinationID: "province:\(slug)")
        case "organizations":
            return route(tab: .guide, destinationID: "institutions")
        case "emergency":
            return route(tab: .guide, destinationID: "emergency")
        case "saved":
            return UniversalLinkRoute(tab: .saved, destination: nil)
        case "support":
            return route(tab: .more, destinationID: "supportFeedback")
        case "privacy":
            return route(tab: .more, destinationID: "privacyDataControl")
        case "app", "status":
            return UniversalLinkRoute(tab: .more, destination: nil)
        default:
            return nil
        }
    }

    private static func route(tab: AppTab, destinationID: String) -> UniversalLinkRoute {
        UniversalLinkRoute(tab: tab, destination: AppNavigationResolver.destination(for: destinationID))
    }
}
