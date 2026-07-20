import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum LaunchDiagnostics {
    nonisolated private static let start = DispatchTime.now()

    nonisolated static func mark(_ message: String) {
#if DEBUG
        let startNanoseconds = start.uptimeNanoseconds
        let currentNanoseconds = DispatchTime.now().uptimeNanoseconds
        let elapsedNanoseconds = currentNanoseconds >= startNanoseconds ? currentNanoseconds - startNanoseconds : 0
        let elapsed = Double(elapsedNanoseconds) / 1_000_000
        print("[LaunchDiagnostics] \(String(format: "%.1f", elapsed))ms \(message)")
#endif
    }

    @discardableResult
    nonisolated static func measure<T>(_ label: String, _ work: () -> T) -> T {
#if DEBUG
        mark("\(label) start")
        let blockStart = DispatchTime.now()
        let result = work()
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - blockStart.uptimeNanoseconds) / 1_000_000
        mark("\(label) end \(String(format: "%.1f", elapsed))ms")
        return result
#else
        return work()
#endif
    }
}

@main
struct YouNewApp: App {
    private static var isUITesting: Bool {
#if DEBUG
        ProcessInfo.processInfo.arguments.contains("-uiTesting")
#else
        false
#endif
    }

    @StateObject private var appState = AppStateViewModel()
    @StateObject private var savedItemsStore = SavedItemsStore.shared
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var documentStore = DocumentStore()

    init() {
#if DEBUG
#if canImport(UIKit)
        if Self.isUITesting {
            UIView.setAnimationsEnabled(false)
        }
#endif
#endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                GlobalBackgroundView(animatesAmbientLayer: true)
                ContentView()
                    .environment(\.appRootBackgroundInstalled, true)
                    .environmentObject(appState)
                    .environmentObject(savedItemsStore)
                    .environmentObject(languageManager)
                    .environmentObject(documentStore)
                    .environment(\.locale, Locale(identifier: languageManager.appLanguage.rawValue))
                    .preferredColorScheme(.dark)
                    .onAppear {
                        LaunchDiagnostics.mark("App started")
                        if LaunchDiagnostics.measure("data migration", { AppDataMigration.migrateIfNeeded() }) {
                            savedItemsStore.clearCachedSavedItemsForSchemaMigration()
                        }
                        LaunchDiagnostics.measure("ui testing config", configureUITestingIfNeeded)
                        appState.selectedLanguage = languageManager.appLanguage.rawValue
                        LaunchDiagnostics.mark("selectedCity loaded \(appState.selectedCity)")
                        LaunchDiagnostics.mark("selectedAudience loaded \(appState.selectedUserStatus?.rawValue ?? "nil")")
                        // The guide and search surfaces both depend on the canonical
                        // repository. Build it away from the main actor as soon as the
                        // first screen is visible so a first tab selection never pays
                        // the migration/indexing cost synchronously.
                        Task.detached(priority: .utility) {
                            LaunchDiagnostics.mark("content repository prewarm start")
                            _ = ContentRepository.shared.items.count
                            LaunchDiagnostics.mark("content repository prewarm end")
                        }
                        if !Self.isUITesting {
                            LaunchDiagnostics.mark("data seed prewarm scheduled")
                            DispatchQueue.global(qos: .utility).async {
                                LaunchDiagnostics.mark("data seed loading start")
                                DashboardPlacesData.prewarm()
                                DashboardCalendarData.prewarm()
                                LaunchDiagnostics.mark("data seed loading end")
                            }
                        }
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

        let shouldResetUITestState = arguments.contains("-resetUITestState")
        if shouldResetUITestState {
            AppDataMigration.resetLocalCachedData()
            savedItemsStore.clearCachedSavedItemsForSchemaMigration()
            appState.recentlyViewedTopics = []
        }

        // Resetting persisted test data must not route navigation/scroll tests
        // back into onboarding. Onboarding is opt-in for its own UI tests.
        appState.hasCompletedQuestionnaire = !arguments.contains("-uiTestingShowOnboarding")
        if let cityIndex = arguments.firstIndex(of: "-uiTestingCity"),
           arguments.indices.contains(cityIndex + 1),
           MockNearbyPlacesData.supportedCities.contains(arguments[cityIndex + 1]) {
            appState.selectedCity = CityId.resolve(arguments[cityIndex + 1])?.displayName ?? CityId.leiden.displayName
        } else {
            appState.selectedCity = CityId.leiden.displayName
        }
        if let statusIndex = arguments.firstIndex(of: "-uiTestingStatus"),
           arguments.indices.contains(statusIndex + 1),
           let status = UserStatus(rawValue: arguments[statusIndex + 1]) {
            appState.selectedUserStatus = status
        } else {
            appState.selectedUserStatus = .worker
        }

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
