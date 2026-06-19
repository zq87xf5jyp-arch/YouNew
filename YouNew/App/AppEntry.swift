import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct YouNewApp: App {
    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore.shared
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var documentStore = DocumentStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                GlobalBackgroundView()
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(savedItemsStore)
                    .environmentObject(languageManager)
                    .environmentObject(documentStore)
                    .environment(\.locale, Locale(identifier: languageManager.appLanguage.rawValue))
                    .preferredColorScheme(.dark)
                    .onAppear {
                        if AppDataMigration.migrateIfNeeded() {
                            savedItemsStore.clearCachedSavedItemsForSchemaMigration()
                        }
                        configureUITestingIfNeeded()
                        appState.selectedLanguage = languageManager.appLanguage.rawValue
                        KnowledgeIndex.prewarmShared()
                    }
                    .onChange(of: languageManager.appLanguage) { _, newLanguage in
                        appState.selectedLanguage = newLanguage.rawValue
                    }
            }
            .ignoresSafeArea()
        }
    }

    private func configureUITestingIfNeeded() {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-uiTesting") else { return }

        if arguments.contains("-resetUITestState") {
            AppDataMigration.resetLocalCachedData()
            savedItemsStore.clearCachedSavedItemsForSchemaMigration()
            appState.recentlyViewedTopics = []
        }

        appState.hasCompletedQuestionnaire = true
        if let cityIndex = arguments.firstIndex(of: "-uiTestingCity"),
           arguments.indices.contains(cityIndex + 1),
           MockNearbyPlacesData.supportedCities.contains(arguments[cityIndex + 1]) {
            appState.selectedCity = arguments[cityIndex + 1]
        } else {
            appState.selectedCity = "Leiden"
        }
        appState.selectedUserStatus = .worker

        if let languageIndex = arguments.firstIndex(of: "-launchLanguage"),
           arguments.indices.contains(languageIndex + 1),
           let language = AppLanguage(rawValue: arguments[languageIndex + 1]) {
            languageManager.appLanguage = language
        }

#if canImport(UIKit)
        UIView.setAnimationsEnabled(false)
#endif
#endif
    }
}
