import Foundation

enum ResourceRelevanceBucket {
    case recommendedNow
    case usefulLater
    case scamSafety
}

enum ResourceRelevanceEngine {
    static func resources(for status: UserStatus?, all: [ResourceLinkItem]) -> [ResourceRelevanceBucket: [ResourceLinkItem]] {
        guard let status else {
            return [
                .recommendedNow: Array(all.prefix(4)),
                .usefulLater: Array(all.dropFirst(4).prefix(4)),
                .scamSafety: all.filter { $0.category == "Scams" }
            ]
        }

        let visible = all.filter { $0.isVisible(for: status.personaTag, scope: .currentAndUniversal) }
        var scored = visible.map { ($0, score(resource: $0, status: status)) }
        scored.sort { $0.1 > $1.1 }

        let ranked = scored.map(\.0)
        let scamSafety = ranked.filter { $0.category == "Scams" || $0.title.localizedCaseInsensitiveContains("Fraude") }
        let scamIDs = Set(scamSafety.map(\.id))
        let recommendedNow = ranked.filter { !scamIDs.contains($0.id) }.prefix(5)
        let recommendedIDs = Set(recommendedNow.map(\.id))
        let usefulLater = ranked.filter { !recommendedIDs.contains($0.id) && !scamIDs.contains($0.id) }.prefix(5)

        return [
            .recommendedNow: Array(recommendedNow),
            .usefulLater: Array(usefulLater),
            .scamSafety: Array(scamSafety.prefix(3))
        ]
    }

    private static func score(resource: ResourceLinkItem, status: UserStatus) -> Int {
        let title = resource.title.lowercased()
        let category = resource.category.lowercased()
        var score = resource.isOfficial ? 8 : 3

        func bump(_ points: Int, ifMatch keywords: [String]) {
            if keywords.contains(where: { title.contains($0) || category.contains($0) }) {
                score += points
            }
        }

        switch status {
        case .student:
            bump(12, ifMatch: ["duo", "education", "student"])
            bump(8, ifMatch: ["housing", "transport"])
        case .worker:
            bump(12, ifMatch: ["uwv", "work"])
            bump(10, ifMatch: ["belasting", "tax"])
        case .expat:
            bump(12, ifMatch: ["belasting", "tax"])
            bump(9, ifMatch: ["ind", "housing"])
        case .highlySkilledMigrant:
            bump(12, ifMatch: ["ind", "sponsor", "belasting", "tax"])
            bump(9, ifMatch: ["housing", "healthcare"])
        case .euCitizen:
            bump(12, ifMatch: ["municipality", "gemeente", "registration"])
            bump(9, ifMatch: ["healthcare", "work", "tax"])
        case .refugee:
            bump(12, ifMatch: ["ind", "immigration"])
            bump(10, ifMatch: ["legal", "juridisch", "healthcare"])
        case .ukrainian:
            bump(11, ifMatch: ["ind", "immigration"])
            bump(8, ifMatch: ["work", "healthcare"])
        case .family:
            bump(10, ifMatch: ["housing", "healthcare"])
            bump(10, ifMatch: ["toeslagen", "tax"])
        case .tourist:
            bump(12, ifMatch: ["immigration", "emergencies"])
            bump(7, ifMatch: ["transport", "scams"])
            if title.contains("duo") || title.contains("uwv") {
                score -= 10
            }
        case .entrepreneur:
            bump(12, ifMatch: ["kvk", "business", "belasting", "tax", "btw", "vat"])
            bump(8, ifMatch: ["insurance", "permit", "legal"])
        case .lgbtNewcomer:
            bump(12, ifMatch: ["lgbt", "lgbtq", "legal", "juridisch", "support"])
            bump(9, ifMatch: ["healthcare", "community", "housing"])
        }

        return score
    }
}
