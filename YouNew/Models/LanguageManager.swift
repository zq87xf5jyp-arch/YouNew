import Foundation
import SwiftUI
import Combine

final class LanguageManager: ObservableObject {
    private static let defaultLanguage: AppLanguage = .english
    private static let releaseLanguageMigrationKey = "appLanguage.releaseEnglishDefault.2026-06-15"

    @AppStorage("appLanguage") private var storedAppLanguage: AppLanguage = defaultLanguage {
        willSet { objectWillChange.send() }
    }

    var appLanguage: AppLanguage {
        get { storedAppLanguage }
        set {
            guard storedAppLanguage != newValue else { return }
            storedAppLanguage = newValue
        }
    }

    init() {
        if !UserDefaults.standard.bool(forKey: Self.releaseLanguageMigrationKey) {
            storedAppLanguage = Self.defaultLanguage
            UserDefaults.standard.set(true, forKey: Self.releaseLanguageMigrationKey)
        }

        if !AppLanguage.releasePriority.contains(storedAppLanguage) {
            storedAppLanguage = Self.defaultLanguage
        }

#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTesting"),
           let languageIndex = arguments.firstIndex(of: "-launchLanguage"),
           arguments.indices.contains(languageIndex + 1),
           let language = AppLanguage(rawValue: arguments[languageIndex + 1]) {
            storedAppLanguage = language
        }
#endif
    }
}
