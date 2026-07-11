import Foundation

enum AssistantStorage {
    static let conversationStorageKey = "ai.conversation.v2"
    static let workflowStorageKey = "ai.activeWorkflow.v2"
    static let answerCacheStorageKey = "ai.answerCache.v2"
    static let structuredResponsesStorageKey = "ai.structuredResponses.v2"
    static let legacyStorageClearedKey = "ai.legacyStorageCleared.v2"

    static let legacyStorageKeys = [
        "ai.conversation.v1",
        "ai.activeWorkflow.v1",
        "ai.answerCache.v1",
        "ai.structuredResponses.v1"
    ]

    static var activeStorageKeys: [String] {
        [
            conversationStorageKey,
            workflowStorageKey,
            answerCacheStorageKey,
            structuredResponsesStorageKey
        ]
    }

    static var allPersistentKeys: [String] {
        legacyStorageKeys + activeStorageKeys + [legacyStorageClearedKey]
    }
}

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
            "SavedItemsStore.savedItems.v1",
            "map_selected_category_v1",
            "map_selected_journey_v1"
        ].forEach { defaults.removeObject(forKey: $0) }
        AssistantStorage.allPersistentKeys.forEach { defaults.removeObject(forKey: $0) }
    }
}
