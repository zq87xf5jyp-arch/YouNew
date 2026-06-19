import Foundation

struct KnowledgeGraph {
    let relations: [KnowledgeRelation]
    private let outgoing: [String: [KnowledgeRelation]]

    init(relations: [KnowledgeRelation]) {
        self.relations = relations
        self.outgoing = Dictionary(grouping: relations, by: \.fromID)
            .mapValues { $0.sorted { $0.weight > $1.weight } }
    }

    func neighbors(
        of itemID: String,
        in itemsByID: [String: KnowledgeItem],
        limit: Int = 6
    ) -> [KnowledgeItem] {
        Array((outgoing[itemID] ?? [])
            .compactMap { itemsByID[$0.toID] }
            .prefix(limit))
    }

    static func build(for items: [KnowledgeItem]) -> KnowledgeGraph {
        let itemsByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        let titleIndex = Dictionary(grouping: items) { KnowledgeNormalizer.normalize($0.title(.english)) }
        let categoryIndex = Dictionary(grouping: items) { KnowledgeNormalizer.normalize($0.category) }
        var relations: [KnowledgeRelation] = []

        for item in items {
            if let route = item.routeID,
               let routeTarget = itemsByID["screen:\(route)"] ?? itemsByID["hub:\(route)"] {
                relations.append(KnowledgeRelation(
                    fromID: item.id,
                    toID: routeTarget.id,
                    type: .opensDestination,
                    weight: 0.60,
                    reason: "Item route opens \(route)."
                ))
            }

            for source in item.sources where source.url != nil {
                let sourceID = "source:\(KnowledgeNormalizer.slug(source.title))"
                if itemsByID[sourceID] != nil {
                    relations.append(KnowledgeRelation(
                        fromID: item.id,
                        toID: sourceID,
                        type: .officialSource,
                        weight: 0.90,
                        reason: "Item cites \(source.title)."
                    ))
                }
            }

            for keyword in item.keywords {
                let normalized = KnowledgeNormalizer.normalize(keyword)
                for related in titleIndex[normalized] ?? [] where related.id != item.id {
                    relations.append(KnowledgeRelation(
                        fromID: item.id,
                        toID: related.id,
                        type: .relatedTopic,
                        weight: 0.50,
                        reason: "Keyword matches related item title."
                    ))
                }
            }

            for peer in categoryIndex[KnowledgeNormalizer.normalize(item.category)] ?? [] where peer.id != item.id {
                relations.append(KnowledgeRelation(
                    fromID: item.id,
                    toID: peer.id,
                    type: .sameCategory,
                    weight: 0.18,
                    reason: "Same category."
                ))
            }
        }

        relations += canonicalRelations(itemsByID: itemsByID)

        var seen = Set<String>()
        let unique = relations.filter { relation in
            let key = "\(relation.fromID)|\(relation.toID)|\(relation.type.rawValue)"
            return seen.insert(key).inserted
        }

        return KnowledgeGraph(relations: unique)
    }

    private static func canonicalRelations(itemsByID: [String: KnowledgeItem]) -> [KnowledgeRelation] {
        var relations: [KnowledgeRelation] = []

        func link(_ from: String, _ to: String, _ type: KnowledgeRelationType, _ reason: String, weight: Double = 0.86) {
            guard itemsByID[from] != nil, itemsByID[to] != nil else { return }
            relations.append(KnowledgeRelation(fromID: from, toID: to, type: type, weight: weight, reason: reason))
        }

        link("topic:registration-bsn", "article:documents:bsn", .relatedGuide, "BSN topic opens the BSN guide article.")
        link("topic:registration-bsn", "article:documents:brp", .requires, "BSN depends on municipal BRP registration.")
        link("topic:registration-bsn", "topic:digid", .nextStep, "DigiD is a common next step after BSN.")
        link("topic:registration-bsn", "screen:journeyDocuments", .documentNeeded, "Documents are needed for municipality registration.")
        link("topic:registration-bsn", "hub:government", .opensDestination, "Government hub contains municipality and official-service guidance.")
        link("topic:health-insurance", "article:healthcare:insurance", .relatedGuide, "Health insurance topic opens healthcare guide.")
        link("topic:health-insurance", "topic:healthcare-navigation", .nextStep, "Huisarts and care navigation follow insurance setup.")
        link("topic:digid", "topic:registration-bsn", .requires, "DigiD requires BSN and registered address.")

        return relations
    }
}
