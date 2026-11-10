import Foundation

/// Recent queries stay in a view model's memory, never in device preferences.
/// Run before showing search. This removes only the two former query histories.
enum SearchHistoryPrivacy {
    nonisolated static func removeLegacyQueries(from defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: "question_search_recent_v1")
        defaults.removeObject(forKey: "map_recent_searches_v1")
    }

    /// Assistant context may retain exact product-defined topic IDs, not phrases.
    /// The caller supplies the existing taxonomy, so no user text becomes a topic.
    nonisolated static func contextTopics(_ queries: [String], allowedTopics: [String]) -> [String] {
        var seen = Set<String>()
        return queries.compactMap { query in
            let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard let topic = allowedTopics.first(where: { $0.lowercased() == normalized }),
                  seen.insert(topic).inserted
            else { return nil }
            return topic
        }.prefix(8).map { $0 }
    }
}
