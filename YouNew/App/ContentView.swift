import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var savedItemsStore: SavedItemsStore
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        #if os(macOS)
        appRoot
            .onAppear {
                LaunchDiagnostics.mark("Root view loaded")
            }
            .sheet(isPresented: Binding(
                get: { appState.requiresPersonaSelection },
                set: { _ in }
            )) {
                OnboardingQuestionnaireView()
                    .environmentObject(appState)
                    .environmentObject(savedItemsStore)
                    .environmentObject(languageManager)
            }
        #else
        appRoot
            .onAppear {
                LaunchDiagnostics.mark("Root view loaded")
            }
            .fullScreenCover(isPresented: Binding(
                get: { shouldPresentOnboarding },
                set: { _ in }
            )) {
                OnboardingQuestionnaireView()
                    .environmentObject(appState)
                    .environmentObject(savedItemsStore)
                    .environmentObject(languageManager)
            }
        #endif
    }

    private var appRoot: some View {
        RootTabView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
    }

    private var shouldPresentOnboarding: Bool {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTesting"),
           !arguments.contains("-uiTestingShowOnboarding") {
            return false
        }
#endif
        return appState.requiresPersonaSelection
    }
}
