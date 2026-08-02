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
        case "guides":
            guard let slug = components.dropFirst().first else {
                return UniversalLinkRoute(tab: .guide, destination: nil)
            }
            return UniversalLinkRoute(
                tab: .guide,
                destination: dataProjectDestination(
                    slug: slug,
                    allowedKinds: [.governmentService, .knowledgeTopic]
                )
            )
        case "categories":
            let destinationID = components.dropFirst().first ?? section
            return route(tab: .guide, destinationID: destinationID)
        case "journeys":
            return route(tab: .home, destinationID: "firstSteps")
        case "map":
            return UniversalLinkRoute(tab: .map, destination: nil)
        case "places":
            guard let slug = components.dropFirst().first else {
                return UniversalLinkRoute(tab: .map, destination: nil)
            }
            return UniversalLinkRoute(
                tab: .map,
                destination: dataProjectDestination(
                    slug: slug,
                    allowedKinds: [.place, .attraction, .museum, .park, .restaurant, .cafe, .hotel, .transport]
                )
            )
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
            guard let slug = components.dropFirst().first else {
                return route(tab: .guide, destinationID: "institutions")
            }
            return UniversalLinkRoute(
                tab: .guide,
                destination: dataProjectDestination(
                    slug: slug,
                    allowedKinds: [.healthcare, .university, .localPartner]
                )
            )
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

    private static func dataProjectDestination(
        slug: String,
        allowedKinds: Set<NetherlandsEntityKind>
    ) -> AppDestination? {
        let normalizedSlug = KnowledgeNormalizer.slug(slug)
        guard let entity = NetherlandsKnowledgeDatabase.shared.entities.first(where: { entity in
            allowedKinds.contains(entity.kind) && publicSlug(for: entity.id) == normalizedSlug
        }),
        let canonicalItem = ContentRepository.shared.item(id: entity.id),
        canonicalItem.status == .published
        else {
            return nil
        }

        return .guideArticle(
            sectionID: GuideContent.dataProjectSectionID,
            articleID: canonicalItem.id
        )
    }

    private static func publicSlug(for contentID: String) -> String? {
        guard contentID.contains("."), let suffix = contentID.split(separator: ".").last else {
            return nil
        }
        return KnowledgeNormalizer.slug(String(suffix))
    }
}
