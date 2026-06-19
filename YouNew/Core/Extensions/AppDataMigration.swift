import Foundation

enum AppDataMigration {
    static let currentSchemaVersion = 2
    static let schemaVersionKey = "appDataSchemaVersion"

    @discardableResult
    static func migrateIfNeeded() -> Bool {
        let defaults = UserDefaults.standard
        let storedVersion = defaults.integer(forKey: schemaVersionKey)
        guard storedVersion < currentSchemaVersion else { return false }

        clearLegacyDisplayCaches()
        defaults.set(currentSchemaVersion, forKey: schemaVersionKey)
        return true
    }

    static func resetLocalCachedData() {
        clearLegacyDisplayCaches()
        UserDefaults.standard.set(currentSchemaVersion, forKey: schemaVersionKey)
    }

    private static func clearLegacyDisplayCaches() {
        let defaults = UserDefaults.standard
        [
            "question_search_recent_v1",
            "recent_translations_v1",
            "ai.conversation.v1",
            "ai.activeWorkflow.v1",
            "ai.answerCache.v1",
            "SavedItemsStore.savedItems.v1",
            "map_selected_category_v1",
            "map_selected_journey_v1"
        ].forEach { defaults.removeObject(forKey: $0) }
    }
}
