import Foundation

// Compile with YouNew/Services/SearchHistoryPrivacy.swift. No app/device launch.
@main
struct SearchHistoryPrivacyRegression {
    static func main() throws {
        let suite = "younew.tests.search-history-privacy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let privateQueries = ["person@example.invalid", "BSN 123456782", "my private address"]
        let bookmark = Data("synthetic-bookmark".utf8)
        defaults.set(privateQueries, forKey: "question_search_recent_v1")
        defaults.set(privateQueries, forKey: "map_recent_searches_v1")
        defaults.set(bookmark, forKey: "SavedItemsStore.savedItems.v1")
        defaults.set(2, forKey: "appDataSchemaVersion")
        defaults.set("Leiden", forKey: "map_selected_city_v1")
        defaults.set("synthetic-draft", forKey: "support.lastFeedbackText")

        SearchHistoryPrivacy.removeLegacyQueries(from: defaults)
        precondition(defaults.object(forKey: "question_search_recent_v1") == nil)
        precondition(defaults.object(forKey: "map_recent_searches_v1") == nil)
        precondition(defaults.data(forKey: "SavedItemsStore.savedItems.v1") == bookmark)
        precondition(defaults.integer(forKey: "appDataSchemaVersion") == 2)
        precondition(defaults.string(forKey: "map_selected_city_v1") == "Leiden")
        precondition(defaults.string(forKey: "support.lastFeedbackText") == "synthetic-draft")
        let remaining = defaults.persistentDomain(forName: suite)! as NSDictionary
        SearchHistoryPrivacy.removeLegacyQueries(from: defaults)
        precondition(remaining.isEqual(to: defaults.persistentDomain(forName: suite)!))

        let taxonomy = ["registration", "digid", "housing", "healthInsurance", "work"]
        precondition(SearchHistoryPrivacy.contextTopics(privateQueries, allowedTopics: taxonomy).isEmpty)
        precondition(SearchHistoryPrivacy.contextTopics(
            ["housing for person@example.invalid", "registration BSN 123456782", "arbitrary query"],
            allowedTopics: taxonomy
        ).isEmpty)
        precondition(SearchHistoryPrivacy.contextTopics(
            [" Housing ", "HOUSING", "DigiD", "healthinsurance"],
            allowedTopics: taxonomy
        ) == ["housing", "digid", "healthInsurance"])
        precondition(SearchHistoryPrivacy.contextTopics(["housing"], allowedTopics: []).isEmpty)
        let manyTopics = (1...12).map { "topic\($0)" }
        precondition(SearchHistoryPrivacy.contextTopics(manyTopics, allowedTopics: manyTopics).count == 8)
        print("PASS: 12 privacy assertions; isolated defaults cleaned; no app/device or network access")
    }
}
